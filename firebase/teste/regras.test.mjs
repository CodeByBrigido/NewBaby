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
} from 'firebase/firestore';

const env = await initializeTestEnvironment({
  projectId: 'demo-meubebe',
  firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 8080 },
});

// Banco limpo a cada rodada. Sem isto, um documento deixado por uma execução
// anterior faz um teste passar por engano, e teste que passa por engano é
// pior que teste nenhum.
await env.clearFirestore();

const ana = env.authenticatedContext('ana').firestore();
const bruno = env.authenticatedContext('bruno').firestore();
const anonimo = env.unauthenticatedContext().firestore();

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
  lacradoAte: null,
};

// Cada caso é uma função, não uma promessa já disparada: com promessas, tudo
// saía ao mesmo tempo e a ordem virava sorteio.
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
// A posição escolhida à mão na lista de documentos. O campo é novo, e
// campo novo só passa se estiver na lista de permitidos das regras.
checar('a ordem escolhida à mão é aceita',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/e7'),
    { ...entradaValida, ordem: 3 })));
checar('ordem nula é aceita (nunca foi arrastado)',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/e8'),
    { ...entradaValida, ordem: null })));
checar('ordem que não é número é recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/entradas/e9'),
    { ...entradaValida, ordem: 'primeiro' })));
checar('perfil com campo estranho é recusado',
  () => assertFails(setDoc(doc(ana, 'users/ana/perfil/bebe'), { nome: 'Alice', extra: 1 })));
checar('o id do Informacoes.txt cabe no perfil',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/perfil/bebe'),
    { nome: 'Alice', nascimento: new Date(), genero: 'menina', pastaRaizId: 'abc', arquivoInfoId: 'info-1' })));

// --- a licença do plano Premium ---
//
// O campo é virado à mão no Firebase Console enquanto o faturamento não
// existe, e depois pela confirmação da compra. O aplicativo nunca o envia.
const cadastro = {
  nome: 'Alice', nascimento: new Date(), genero: 'menina', pastaRaizId: 'abc',
};
checar('a licença cabe no perfil',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/perfil/licenca'),
    { ...cadastro, premium: true })));
checar('licença que não é booleana é recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/perfil/licenca'),
    { ...cadastro, premium: 'sim' })));
// O teste que justifica a linha nas regras. Com a licença já gravada, o
// documento resultante de qualquer merge carrega o campo, mesmo que a
// escrita não o mencione. Se `premium` não estivesse no `hasOnly`, virar a
// licença no console travaria toda edição de cadastro daquela conta, e o
// erro apareceria numa tela que não tem nada a ver com assinatura.
checar('com a licença gravada, salvar o cadastro continua passando',
  async () => {
    await setDoc(doc(ana, 'users/ana/perfil/licenca'),
      { ...cadastro, premium: true });
    await assertSucceeds(setDoc(doc(ana, 'users/ana/perfil/licenca'),
      { nome: 'Alice Souza' }, { merge: true }));
  });


// --- a lingua das pastas do Drive ---
//
// Gravada uma vez, no cadastro, e nunca mais. Precisa estar no hasOnly pelo
// mesmo motivo do premium: o merge valida o documento resultante.
checar('a língua das pastas cabe no perfil',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/perfil/pastas'),
    { ...cadastro, idiomaDasPastas: 'en' })));
checar('com a língua gravada, salvar o cadastro continua passando',
  async () => {
    await setDoc(doc(ana, 'users/ana/perfil/pastas'),
      { ...cadastro, idiomaDasPastas: 'en' });
    await assertSucceeds(setDoc(doc(ana, 'users/ana/perfil/pastas'),
      { nome: 'Alice Souza' }, { merge: true }));
  });
checar('língua absurdamente longa é recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/perfil/pastas'),
    { ...cadastro, idiomaDasPastas: 'x'.repeat(50) })));

checar('subcoleção desconhecida é recusada',
  () => assertFails(setDoc(doc(ana, 'users/ana/qualquer/coisa'), { a: 1 })));
checar('não dá para criar o documento raiz do usuário',
  () => assertFails(setDoc(doc(ana, 'users/ana'), { qualquer: 'coisa' })));
checar('descrição no limite ainda passa',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/e7'),
    { ...entradaValida, descricao: 'x'.repeat(20000) })));

// --- lacre ---
checar('o id do .txt da carta cabe na entrada',
  () => assertSucceeds(setDoc(doc(ana, 'users/ana/entradas/carta-txt'),
    { ...entradaValida, arquivoTextoId: 'drive-txt-1' })));

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

// --- restos do compartilhamento familiar ---
//
// A função saiu antes da publicação, mas quem instalou a versão de teste tem
// documentos gravados. Estas três verificações protegem a promessa de que
// "apagar minha conta e meus dados" não deixa rastro.
checar('a dona ainda le e apaga uma miniatura antiga',
  () => assertSucceeds(deleteDoc(doc(ana, 'users/ana/miniaturas/qualquer'))));
checar('a dona ainda apaga uma imagem antiga',
  () => assertSucceeds(deleteDoc(doc(ana, 'users/ana/imagens/qualquer'))));
checar('ninguem grava miniatura nova, nem a dona',
  () => assertFails(setDoc(doc(ana, 'users/ana/miniaturas/nova'), { a: 1 })));
checar('outra conta nao alcanca as miniaturas alheias',
  () => assertFails(getDoc(doc(bruno, 'users/ana/miniaturas/qualquer'))));

// --- as colecoes que sairam ficam fechadas ---
checar('ninguem cria codigo de convite',
  () => assertFails(setDoc(doc(ana, 'shareCodes/QUALQUER'), { a: 1 })));
checar('ninguem cria vinculo familiar',
  () => assertFails(setDoc(doc(ana, 'familyAccess/ana'), { a: 1 })));
checar('ninguem le vinculo familiar',
  () => assertFails(getDoc(doc(ana, 'familyAccess/ana'))));

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
