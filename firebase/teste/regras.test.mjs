import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  setDoc,
  deleteDoc,
  collection,
  getDocs,
  query,
  where,
  Bytes,
} from 'firebase/firestore';

const env = await initializeTestEnvironment({
  projectId: 'demo-meubebe',
  firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 8080 },
});

// Banco limpo a cada rodada. Sem isto, um documento deixado por uma execução
// anterior faz um teste passar por engano - e o teste que passa por engano é
// justamente o do vínculo familiar, que é o que menos pode falhar em silêncio.
await env.clearFirestore();

const ana = env.authenticatedContext('ana').firestore();
const bruno = env.authenticatedContext('bruno').firestore();
const anonimo = env.unauthenticatedContext().firestore();

// A avó e a tia entram com email no token: as regras de convite dependem
// disso, porque o convite é amarrado a um endereço específico.
const avo = env.authenticatedContext('avo', { email: 'avo@gmail.com' }).firestore();
const tia = env.authenticatedContext('tia', { email: 'tia@gmail.com' }).firestore();

const entradaValida = {
  tipo: 'carta',
  data: new Date(),
  criadoEm: new Date(),
  idadeDias: 78,
  balde: 'S12',
  baldeNome: 'Semana 12',
  titulo: 'Para quando você crescer',
  descricao: 'Hoje você riu pela primeira vez.',
  arquivos: [],
  status: 'ativo',
  uploadStatus: 'pronto',
  // Sempre presente, mesmo valendo nulo. É o que permite ao familiar pedir
  // "as não lacradas" numa consulta: no Firestore, campo ausente não é
  // alcançado por filtro nenhum, e uma memória some sem ninguém perceber.
  lacradoAte: null,
};

/// Uns poucos bytes fazendo as vezes de uma miniatura JPEG.
const bytesDeTeste = Bytes.fromUint8Array(
  new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10]),
);

/// Os tipos que a família enxerga. Precisa bater com `firestore.rules`.
const tiposVisiveis = ['nascimento', 'foto', 'video', 'documento', 'crescimento'];

/// A consulta que o aplicativo do familiar faz de verdade.
///
/// Está aqui, e não espalhada pelos casos, porque ela é um contrato: se a
/// regra apertar, é esta linha que precisa mudar junto - e o teste avisa.
const consultaDaFamilia = (db) => query(
  collection(db, 'users/ana/entradas'),
  where('status', '==', 'ativo'),
  where('tipo', 'in', tiposVisiveis),
  where('lacradoAte', '==', null),
);

// Cada caso é uma função, não uma promessa já disparada.
//
// A diferença importa: com promessas, tudo saía ao mesmo tempo e a ordem
// virava sorteio. O compartilhamento familiar depende de ordem - o vínculo
// precisa existir antes de a avó tentar ler - e um teste que às vezes passa
// é pior que teste nenhum.
const casos = [];
const checar = (nome, executar) => casos.push({ nome, executar });

// --- o caminho feliz precisa continuar funcionando ---
checar('dona grava o próprio perfil',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/perfil/bebe'),
    { nome: 'Alice', nascimento: new Date(), genero: 'menina', pastaRaizId: 'abc' })));
checar('dona grava a própria entrada',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/e1'), entradaValida)));
checar('dona lê a própria entrada',
  () => assertSucceeds(getDoc(doc(ana, 'users/ana/entradas/e1'))));
checar('dona grava o cache de pastas',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/pastas/Fotos__Semana_12'),
    { caminho: 'Fotos/Semana 12', driveId: 'xyz', criadoEm: new Date() })));
checar('dona apaga a própria entrada (exclusão de conta)',
  () => assertSucceeds(deleteDoc(doc(ana, 'users/ana/entradas/e1'))));
checar('dona apaga o próprio documento raiz',
  () => assertSucceeds(deleteDoc(doc(ana, 'users/ana'))));

// --- isolamento entre contas ---
checar('outra conta não lê o perfil alheio',
  () => assertFails(getDoc(doc(bruno, 'users/ana/perfil/bebe'))));
checar('outra conta não escreve na linha do tempo alheia',
  () => assertFails(setDoc(doc(bruno, 'users/ana/entradas/e2'), entradaValida)));
checar('outra conta não lista as entradas alheias',
  () => assertFails(getDocs(collection(bruno, 'users/ana/entradas'))));
checar('sem login não se lê nada',
  () => assertFails(getDoc(doc(anonimo, 'users/ana/perfil/bebe'))));
checar('ninguém lista a coleção de usuários',
  () => assertFails(getDocs(collection(ana, 'users'))));

// --- validação de formato ---
checar('campo desconhecido é recusado',
  () => assertFails(setDoc(doc(ana, 'users/ana/entradas/e3'),
    { ...entradaValida, cargaQualquer: 'x'.repeat(100) })));
checar('descrição gigante é recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/entradas/e4'),
    { ...entradaValida, descricao: 'x'.repeat(20001) })));
checar('título gigante é recusado',
  () => assertFails(setDoc(doc(ana, 'users/ana/entradas/e5'),
    { ...entradaValida, titulo: 'x'.repeat(201) })));
checar('lista de arquivos absurda é recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/entradas/e6'),
    { ...entradaValida, arquivos: new Array(61).fill({ driveId: 'a' }) })));
checar('perfil com campo estranho é recusado',
  () => assertFails(setDoc(doc(ana, 'users/ana/perfil/bebe'), { nome: 'Alice', extra: 1 })));
checar('subcoleção desconhecida é recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/qualquer/coisa'), { a: 1 })));
checar('não dá para criar o documento raiz do usuário',
  () => assertFails(setDoc(doc(ana, 'users/ana'), { qualquer: 'coisa' })));
checar('descrição no limite ainda passa',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/e7'),
    { ...entradaValida, descricao: 'x'.repeat(20000) })));

// --- lacre ---
checar('uma entrada pode ser guardada para o futuro',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/lacrada'),
    { ...entradaValida, lacradoAte: new Date(2045, 0, 22) })));
checar('e o lacre pode ser tirado',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/lacrada'),
    { ...entradaValida, lacradoAte: null })));
checar('outra pessoa nao le uma entrada lacrada',
  () => assertFails(getDoc(doc(bruno, 'users/ana/entradas/lacrada'))));

// --- sugestões ---
checar('a pessoa marca uma sugestão como feita',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/sugestoes/primeiro-sorriso'),
    { feita: true, dispensada: false, marcados: [] })));
checar('a pessoa marca itens do checklist',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/sugestoes/primeiro-aniversario'),
    { feita: false, dispensada: false, marcados: ['Escolher o bolo'] })));
checar('outra pessoa nao le as sugestoes de ninguem',
  () => assertFails(getDoc(doc(bruno, 'users/ana/sugestoes/primeiro-sorriso'))));
checar('outra pessoa nao escreve nas sugestoes de ninguem',
  () => assertFails(setDoc(doc(bruno, 'users/ana/sugestoes/primeiro-sorriso'), { feita: true })));
checar('anonimo sem login nao alcanca as sugestoes',
  () => assertFails(getDoc(doc(anonimo, 'users/ana/sugestoes/primeiro-sorriso'))));
checar('campo estranho na sugestao e recusado',
  () => assertFails(setDoc(doc(ana, 'users/ana/sugestoes/x'), { feita: true, carga: 'x'.repeat(100) })));
checar('tipo errado na sugestao e recusado',
  () => assertFails(setDoc(doc(ana, 'users/ana/sugestoes/y'), { feita: 'sim' })));
checar('lista de marcados absurda e recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/sugestoes/z'),
    { marcados: new Array(41).fill('item') })));

// --- compartilhamento familiar ---
//
// O Drive controla quem lê os arquivos; estas regras controlam quem pertence
// a qual cápsula. É aqui que o código de convite vira acesso, e é a peça
// mais delicada do projeto inteiro.

const agora = new Date();
const daquiA48h = new Date(agora.getTime() + 48 * 3600 * 1000);
const ontem = new Date(agora.getTime() - 24 * 3600 * 1000);

const convite = (email, expiraEm = daquiA48h) => ({
  ownerUid: 'ana',
  folderId: 'pasta-da-ana',
  email,
  nome: 'Vó Maria',
  criadoEm: agora,
  expiraEm,
  status: 'pending',
});

const vinculo = (codigo) => ({
  ownerUid: 'ana',
  folderId: 'pasta-da-ana',
  role: 'viewer',
  email: 'avo@gmail.com',
  codigo,
  criadoEm: agora,
});

// Semeadura fora das regras: o que precisa existir antes dos testes.
await env.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  await setDoc(doc(db, 'shareCodes/AB-ABCD-8KQ2'), convite('avo@gmail.com'));
  await setDoc(doc(db, 'shareCodes/EX-PIRA-DO01'), convite('avo@gmail.com', ontem));
  await setDoc(doc(db, 'shareCodes/US-ADO-0001'), { ...convite('avo@gmail.com'), status: 'used' });
  await setDoc(doc(db, 'users/ana/perfil/bebe'), { nome: 'Maria', nascimento: agora });
  await setDoc(doc(db, 'users/ana/entradas/foto1'), { ...entradaValida, tipo: 'foto' });
  await setDoc(doc(db, 'users/ana/entradas/carta1'), { ...entradaValida, tipo: 'carta' });
  await setDoc(doc(db, 'users/ana/entradas/lacrada1'), {
    ...entradaValida, tipo: 'foto', lacradoAte: new Date(2099, 0, 1),
  });
  await setDoc(doc(db, 'users/ana/entradas/lixo1'), {
    ...entradaValida, tipo: 'foto', status: 'excluido', excluidoEm: agora,
  });

  // Uma miniatura para cada uma, para provar que o que manda é a entrada
  // dona, e não a miniatura em si.
  for (const [id, entrada] of Object.entries({
    'drive-foto1': 'foto1',
    'drive-carta1': 'carta1',
    'drive-lacrada1': 'lacrada1',
    'drive-lixo1': 'lixo1',
  })) {
    await setDoc(doc(db, `users/ana/miniaturas/${id}`), {
      entradaId: entrada,
      bytes: bytesDeTeste,
      criadoEm: agora,
    });
  }
});

// O dono cria o convite.
checar('o dono cria um convite para um email',
  () => assertSucceeds(setDoc(doc(ana, 'shareCodes/NO-VO-0001'), convite('tia@gmail.com'))));
checar('ninguem cria convite em nome de outro dono',
  () => assertFails(setDoc(doc(bruno, 'shareCodes/FA-LSO-0001'), convite('tia@gmail.com'))));
checar('convite nao nasce ja usado',
  () => assertFails(setDoc(doc(ana, 'shareCodes/RU-IM-0001'), { ...convite('tia@gmail.com'), status: 'used' })));
checar('campo estranho no convite e recusado',
  () => assertFails(setDoc(doc(ana, 'shareCodes/RU-IM-0002'), { ...convite('tia@gmail.com'), carga: 'x' })));

// Ler o convite.
checar('o email convidado le o proprio convite',
  () => assertSucceeds(getDoc(doc(avo, 'shareCodes/AB-ABCD-8KQ2'))));
checar('o dono le o convite que criou',
  () => assertSucceeds(getDoc(doc(ana, 'shareCodes/AB-ABCD-8KQ2'))));
checar('outro email nao le o convite mesmo sabendo o codigo',
  () => assertFails(getDoc(doc(tia, 'shareCodes/AB-ABCD-8KQ2'))));
checar('anonimo nao le convite nenhum',
  () => assertFails(getDoc(doc(anonimo, 'shareCodes/AB-ABCD-8KQ2'))));
checar('ninguem lista os convites',
  () => assertFails(getDocs(collection(ana, 'shareCodes'))));

// Resgatar o codigo: criar o vinculo.
checar('o convidado cria o proprio vinculo com um codigo valido',
  () => assertSucceeds(setDoc(doc(avo, 'familyAccess/avo'), vinculo('AB-ABCD-8KQ2'))));
checar('codigo expirado nao vira vinculo',
  () => assertFails(setDoc(doc(avo, 'familyAccess/avo2'), vinculo('EX-PIRA-DO01'))));
checar('codigo ja usado nao vira vinculo',
  () => assertFails(setDoc(doc(avo, 'familyAccess/avo3'), vinculo('US-ADO-0001'))));
checar('codigo inexistente nao vira vinculo',
  () => assertFails(setDoc(doc(avo, 'familyAccess/avo4'), vinculo('NA-DA-0000'))));
checar('outro email nao resgata um codigo que nao e dele',
  () => assertFails(setDoc(doc(tia, 'familyAccess/tia'), { ...vinculo('AB-ABCD-8KQ2'), email: 'tia@gmail.com' })));
checar('ninguem cria vinculo no lugar de outra pessoa',
  () => assertFails(setDoc(doc(avo, 'familyAccess/bruno'), vinculo('AB-ABCD-8KQ2'))));
checar('ninguem se promove a dono',
  () => assertFails(setDoc(doc(avo, 'familyAccess/avo5'), { ...vinculo('AB-ABCD-8KQ2'), role: 'owner' })));
checar('vinculo nao aponta para pasta diferente da do convite',
  () => assertFails(setDoc(doc(avo, 'familyAccess/avo6'), { ...vinculo('AB-ABCD-8KQ2'), folderId: 'outra-pasta' })));

// O que o familiar enxerga.
checar('a familia le o perfil da crianca',
  () => assertSucceeds(getDoc(doc(avo, 'users/ana/perfil/bebe'))));
checar('a familia le uma foto',
  () => assertSucceeds(getDoc(doc(avo, 'users/ana/entradas/foto1'))));
checar('a familia NAO le uma carta',
  () => assertFails(getDoc(doc(avo, 'users/ana/entradas/carta1'))));
checar('a familia NAO le uma entrada lacrada',
  () => assertFails(getDoc(doc(avo, 'users/ana/entradas/lacrada1'))));
checar('a familia nao escreve nada',
  () => assertFails(setDoc(doc(avo, 'users/ana/entradas/nova'), entradaValida)));
checar('a familia nao apaga nada',
  () => assertFails(deleteDoc(doc(avo, 'users/ana/entradas/foto1'))));
checar('a familia nao mexe no perfil',
  () => assertFails(setDoc(doc(avo, 'users/ana/perfil/bebe'), { nome: 'Outro' })));
checar('a familia NAO le o que foi para a lixeira',
  () => assertFails(getDoc(doc(avo, 'users/ana/entradas/lixo1'))));

// As miniaturas.
//
// Sao o que faz a linha do tempo do familiar ter imagem sem uma unica
// chamada ao Google Drive. Quem manda e a entrada dona: se ela e carta,
// esta lacrada ou foi para a lixeira, a miniatura vai junto.
checar('a familia ve a miniatura de uma foto',
  () => assertSucceeds(getDoc(doc(avo, 'users/ana/miniaturas/drive-foto1'))));
checar('a familia NAO ve a miniatura de uma carta',
  () => assertFails(getDoc(doc(avo, 'users/ana/miniaturas/drive-carta1'))));
checar('a familia NAO ve a miniatura de uma entrada lacrada',
  () => assertFails(getDoc(doc(avo, 'users/ana/miniaturas/drive-lacrada1'))));
checar('a familia NAO ve a miniatura do que esta na lixeira',
  () => assertFails(getDoc(doc(avo, 'users/ana/miniaturas/drive-lixo1'))));
checar('ninguem lista as miniaturas, nem a dona',
  () => assertFails(getDocs(collection(ana, 'users/ana/miniaturas'))));
checar('a familia nao grava miniatura nenhuma',
  () => assertFails(setDoc(doc(avo, 'users/ana/miniaturas/drive-nova'),
    { entradaId: 'foto1', bytes: bytesDeTeste, criadoEm: agora })));
checar('a dona grava a propria miniatura',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/miniaturas/drive-nova'),
    { entradaId: 'foto1', bytes: bytesDeTeste, criadoEm: agora })));
checar('miniatura gigante e recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/miniaturas/drive-gorda'),
    { entradaId: 'foto1', bytes: Bytes.fromUint8Array(new Uint8Array(200 * 1024 + 1)), criadoEm: agora })));
checar('campo estranho na miniatura e recusado',
  () => assertFails(setDoc(doc(ana, 'users/ana/miniaturas/drive-x'),
    { entradaId: 'foto1', bytes: bytesDeTeste, criadoEm: agora, carga: 'x' })));
checar('outra conta nao le miniatura alheia',
  () => assertFails(getDoc(doc(bruno, 'users/ana/miniaturas/drive-foto1'))));
checar('quem nao tem vinculo continua sem ler nada',
  () => assertFails(getDoc(doc(tia, 'users/ana/entradas/foto1'))));

// A consulta de lista, que é como a linha do tempo carrega de verdade.
//
// No Firestore, regra não é filtro: a consulta inteira falha se **um** dos
// documentos que ela traria for negado. Então o aplicativo do familiar
// precisa perguntar exatamente o que pode ver. Estes três casos são o
// contrato entre a regra e a consulta, e é por isso que existem.
checar('a familia NAO lista as entradas sem filtro nenhum',
  () => assertFails(getDocs(collection(avo, 'users/ana/entradas'))));
checar('a familia NAO lista so filtrando por tipo, porque a lacrada entraria',
  () => assertFails(getDocs(query(
    collection(avo, 'users/ana/entradas'),
    where('tipo', 'in', tiposVisiveis)))));
checar('a familia NAO lista so filtrando por lacre, porque a carta entraria',
  () => assertFails(getDocs(query(
    collection(avo, 'users/ana/entradas'),
    where('lacradoAte', '==', null)))));
checar('a familia NAO lista sem dizer que quer so o que esta ativo',
  () => assertFails(getDocs(query(
    collection(avo, 'users/ana/entradas'),
    where('tipo', 'in', tiposVisiveis),
    where('lacradoAte', '==', null)))));
checar('a familia lista o que a regra de fato permite',
  () => assertSucceeds(getDocs(consultaDaFamilia(avo))));
checar('e essa consulta nao traz a lacrada, nem a carta, nem a da lixeira',
  async () => {
    const r = await getDocs(consultaDaFamilia(avo));
    const ids = r.docs.map((d) => d.id).sort();
    if (ids.join(',') !== 'foto1') {
      throw new Error(`a familia enxergou ${JSON.stringify(ids)}, esperado ["foto1"]`);
    }
  });
checar('a dona continua listando tudo, sem filtro',
  () => assertSucceeds(getDocs(collection(ana, 'users/ana/entradas'))));

// Sair e revogar.
checar('o vinculo e imutavel',
  () => assertFails(setDoc(doc(avo, 'familyAccess/avo'), { ...vinculo('AB-ABCD-8KQ2'), folderId: 'outra' })));
checar('o dono revoga o vinculo',
  () => assertSucceeds(deleteDoc(doc(ana, 'familyAccess/avo'))));

let falhas = 0;
for (const { nome, executar } of casos) {
  try {
    await executar();
    console.log(`  ok   ${nome}`);
  } catch (e) {
    falhas++;
    console.log(`  FALHOU  ${nome}\n         ${e.message.split('\n').join(' ')}`);
  }
}

await env.cleanup();
console.log(falhas === 0 ? `\n${casos.length} verificações passaram.` : `\n${falhas} de ${casos.length} FALHARAM.`);
process.exit(falhas === 0 ? 0 : 1);
