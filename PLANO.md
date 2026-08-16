# Plano de evolução

Documento de acompanhamento, e o primeiro arquivo a ler ao retomar o
projeto. Comece por [Onde estamos](#onde-estamos-15082026), que diz o estado
de hoje, e por [O próximo passo](#o-próximo-passo-exato).

Uma fase concluída ganha ✅ no próprio título e fica onde está quando o
texto dela ainda explica uma decisão viva; as que fecharam por completo vão
para [Concluído](#concluído), no fim do arquivo. Fase que muda de desenho é
**reescrita**, e não apagada: o desenho antigo e a razão da troca são metade
do valor deste documento.

## A régua

Este aplicativo não é um álbum de fotos. É uma cápsula do tempo digital.

Toda decisão de UX responde a uma pergunta só: **daqui a 20 ou 30 anos, a
própria criança vai abrir isto e reviver a infância dela.** Quando houver
dúvida entre duas soluções, ganha a que serve melhor a essa pessoa, não a
que é mais fácil para quem registra hoje.

O Google Drive é só o armazenamento. O aplicativo esconde isso por
completo: ninguém vê pasta, arquivo, sincronização ou cota.

---

## Onde estamos (15/08/2026)

101 arquivos em `lib/`, 23.202 linhas, 43 arquivos de teste, **565 testes
verdes**. `flutter analyze --fatal-infos --fatal-warnings` limpo.

O aplicativo está em teste no aparelho, instalado pelo APK que o CI gera a
cada merge na `main`. Não foi submetido à Play Store.

**Último trabalho:** PR #21, rascunho, CI verde nos quatro trabalhos
(análise e testes, regras do Firestore, compila o Android; o "Gerar APK" só
roda no merge, e por isso aparece como skipped no PR). Falta o merge.

### O que foi feito e não estava escrito aqui

Muito do trabalho recente não nasceu de fase nenhuma: veio do uso no
aparelho. Ficou registrado em [Concluído](#concluído), no fim do arquivo,
porque decisão sem registro vira decisão para refazer.

- [A estrutura do Drive](#a-estrutura-do-drive-), com `Informacoes.txt` e
  nomenclatura por ano
- [A privacidade da sessão](#a-privacidade-da-sessão-), incluindo a abertura
  que não pede mais a conta do Google
- [O tamanho dos arquivos](#o-tamanho-dos-arquivos-), com teto fixo de 960 px
  e vídeo em 540p
- [A janela do envio](#a-janela-do-envio-), que acompanha e diz onde a
  memória foi parar
- [As pastas divididas por dentro](#as-pastas-divididas-por-dentro-), com o
  mês em semanas e o ano em meses
- [O blog](#o-blog-), com 46 postagens, capa, busca própria e página de
  leitura

Uma fase mudou de desenho e foi reescrita no lugar: a
[Fase 11](#fase-11---mais-de-um-filho--o-desenho-mudou-por-inteiro), que
agora é uma conta do Google por filho. O áudio saiu do produto junto com
ela, e a razão está na [Fase 4](#fase-4---cápsula-lacrada-a-voz-entrou-e-saiu-).

### Restrições que valem para sempre neste projeto

Não são preferências. Cada uma tem consequência fora do código.

- **O escopo do Google continua sendo só `drive.file`.** Qualquer escopo
  restrito (`drive.readonly` e parentes) obriga auditoria de segurança anual
  paga por terceiro para publicar na loja. Isso está fora do orçamento e
  fora do prazo, e mudar de escopo sem dizer isso com todas as letras é
  risco jurídico, não detalhe técnico
- **Nenhum travessão em nenhum texto do projeto**, nem em código, nem em
  comentário, nem em documento. Há teste varrendo
- **Nenhum link de sessão do Claude em nada que vá para o GitHub**, nem em
  commit, nem em corpo de PR. Quando a ferramenta injeta um, ele é removido
  logo depois de criar o PR
- **O Design System manda na cor.** Cor não se mede de arte nem se ajusta no
  tema caso a caso

---

## Defeitos conhecidos e pendências

### 1. O envio que trava, e ainda não foi resolvido

**O único defeito aberto de comportamento.** Relatado no aparelho: um envio
falha e o "Tentar de novo" não sai do lugar.

Duas causas foram encontradas e corrigidas ao longo da sessão (o arquivo
temporário que já não existe mais no disco, e a recusa de permissão que
estourava para fora da repetição em vez de virar mensagem). O relato
continuou depois disso.

**O que falta para seguir:** o texto exato do aviso de falha, lido no
aparelho. A mensagem diz de qual dos três degraus de autorização veio o
erro, e sem ela qualquer conserto é chute. Foi pedido e ainda não veio.

### 2. As 46 capas do blog não existem

Cada postagem é um par de arquivos com o mesmo nome, o `.json` e o `.webp`.
Os 46 `.json` estão lá; nenhum `.webp` está. Enquanto a capa falta, entra a
ilustração desenhada por `InspirationArt`, então nada quebra e nada avisa.

Basta soltar os arquivos em `assets/inspiracoes/`. Sem código, sem
`pubspec.yaml`, sem catálogo. O `LEIA-ME.md` da pasta explica.

### 3. ~~Uma pergunta em aberto sobre a cor~~ resolvida

O fundo creme tinha sido aplicado às três paletas. Ficou decidido que na Sky
ele não serve, e o menino passou a ter papel frio (`#F1F5FB`). Ver
[O papel de cada tema](#o-papel-de-cada-tema-).

### 4. A pasta `Crescimento` nasce vazia

`topLevelFolders` ainda cria `Crescimento` no Drive, mas peso e altura
passaram a viver no `Informacoes.txt` e nada mais é gravado nessa pasta. É
uma pasta vazia na cápsula de quem abrir o Drive. Nit, não defeito.

### 5. Itens da Play Store que dependem de você, não de código

Ligar o GitHub Pages (*Settings → Pages → `main` / `/docs`*), o alerta de
orçamento no Google Cloud e o App Check em modo monitoramento. O passo a
passo está no `PUBLICAR.md`.

---

## O próximo passo exato

**Dar merge no PR #21.** A CI está verde e o APK sai do merge.

Depois disso, instalar o APK e conferir duas coisas no aparelho:

1. **A janela do envio aparece?** Mandar uma foto, e ver se aparece a de
   progresso e depois a de "Guardado" com o botão de ir para a pasta. É o
   que o PR #21 conserta, e é o único jeito de confirmar
2. **Se um envio falhar, qual é a frase exata do aviso?** É o dado que falta
   para o defeito 1 acima. Anotar ou fotografar a tela

Com essas duas respostas, a próxima sessão começa sabendo se o conserto
pegou e tendo com que trabalhar no envio travado.

---

## O que a régua da cápsula exige e o produto ainda não tem

- **A cápsula pode morrer antes da criança.** O Google apaga contas
  inativas por 2 anos. Se esta conta parar de ser usada daqui a 8 anos, o
  acervo vai junto e a cápsula de 20 anos vira nada. Tratado na Fase 8a, com
  o aviso que vive fora da janela de reagendamento
- **O aplicativo é o elo mais frágil da corrente.** Em 25 anos o Flutter,
  o Firebase e o Android terão mudado. A cápsula precisa ser legível **sem
  o aplicativo**: uma exportação que gere pasta navegável com as mídias e
  um índice que abra em qualquer computador do futuro. Um produto de longo
  prazo precisa presumir a própria morte. É a Fase 12
- **Voz.** Foi construída e foi retirada. A razão está registrada em
  [Fase 4](#fase-4---cápsula-lacrada-a-voz-entrou-e-saiu-), e a decisão de
  tirar foi de produto, não técnica

---

## Fases

As fases 1 a 8, 10 e 11 saíram. O compartilhamento familiar ficou para depois
(seção "Adiado", abaixo). **Sobram três**, e nenhuma está em andamento:

**Quando você der o comando de publicar:** a 9 inteira. Ela é o que bloqueia
a submissão, e ficou para depois por escolha sua: assinar o pacote definitivo
só faz sentido quando o aplicativo estiver do jeito que você quer. Dentro
dela, a 9b já está escrita e só falta ligar o GitHub Pages.

**Depois do lançamento:** a 12 (exportação) e a 13 (assinatura). As duas são
grandes, e nenhuma família perde nada por esperar por elas.

O trabalho de hoje não é de fase: é acerto de tela e de defeito, vindo do uso
no aparelho. Está em [Defeitos conhecidos](#defeitos-conhecidos-e-pendências)
e em [O próximo passo](#o-próximo-passo-exato).

Cada passo abaixo termina com o aplicativo compilando, testado e
instalável.

### Fase 9 - Publicar na Play Store

Subdividida porque é a única fase com prazo externo, e porque metade dela
não é código: é formulário, texto e espera de revisão. Cada passo abaixo
termina com algo conferível, e a ordem é por bloqueio, não por gosto.

#### 9a. O pacote que a loja aceita

**Bloqueia tudo o mais, e é o passo que faltava.** O CI de hoje gera `.apk`,
e a Play Store não aceita APK para aplicativo novo: exige App Bundle
(`.aab`). Hoje não existe artefato que dê para enviar.

- Novo trabalho no `android.yml` rodando `flutter build appbundle --release`
- Assinatura com a chave de upload de verdade, vinda dos segredos do
  repositório, e não com a de depuração
- Conferir no artefato que o `.aab` saiu assinado com a chave certa
  (`jarsigner -verify` ou `bundletool`), porque um pacote assinado com a
  chave errada é recusado depois de enviado, não antes

**Pronto quando:** existe um `.aab` baixável do CI, assinado com a chave que
vai ficar sendo a do aplicativo para sempre.

#### 9b. Os dois endereços públicos

A loja exige dois URLs que hoje não existem: a política de privacidade e a
página de exclusão de conta. Sem eles o formulário não fecha.

- ~~Escrever os dois textos. A política precisa dizer com todas as letras que
  as fotos e os vídeos ficam no Google Drive **da própria pessoa**, que o
  aplicativo guarda apenas metadados, e que apagar a conta apaga tudo~~
  Feito. Os dois moram em `lib/core/l10n/`, junto do texto que o aplicativo
  mostra, e `dart run tool/gerar_site.dart` os transforma nas páginas de
  `docs/`. Um teste compara as páginas com o código e quebra a suíte se
  alguém mudar um sem regerar o outro
- Publicar de graça no GitHub Pages do próprio repositório. Falta só ligar:
  *Settings → Pages → Deploy from a branch → `main` / `/docs`*. O passo a
  passo e onde colar cada endereço no Play Console estão no `PUBLICAR.md`
- ~~Ligar os dois no aplicativo, na tela Sobre~~ Feito, e em dois lugares
  melhores que o Sobre: cada um tem o próprio item no Perfil, e os dois
  abrem no rodapé da tela de entrada, **antes** do login. Ler o que o
  aplicativo faz com os dados de um filho é o que se faz antes de entregar
  a conta; um texto atrás do login chega tarde para a decisão que ele
  deveria informar

**Pronto quando:** os dois endereços abrem no navegador de qualquer pessoa,
sem login.

#### 9c. Proteger o bolso antes de abrir a porta

Não bloqueia a submissão, e mesmo assim não se publica sem. A partir do
momento em que o aplicativo é público, qualquer pessoa instala e passa a
escrever no Firestore por sua conta.

- Alerta de orçamento no Google Cloud, com aviso por email
- App Check com Play Integrity, **em modo monitoramento**, não obrigatório

O modo monitoramento é deliberado: ligar a obrigatoriedade junto com o
lançamento é a receita para descobrir uma configuração errada com usuários
reais trancados do lado de fora. Primeiro se olha o painel, depois se aperta.

**Pronto quando:** o painel do App Check mostra requisições verificadas
chegando, e o alerta de orçamento dispara num teste.

#### 9d. O repositório recriado, com os segredos fora do histórico

**O último passo antes do envio, e o único que não dá para refazer depois.**

O repositório é público hoje, e continua público de propósito: é o que
mantém o GitHub Pages de graça servindo as duas URLs que a loja exige, e é
o que permite trabalhar aqui de forma autônoma, sem um vaivém de arquivo a
cada mudança.

O preço disso é que três coisas estão à vista de qualquer pessoa desde o
primeiro commit:

- `android/app/google-services.json`, com o `project_id` e a API key do
  Android
- a mesma API key repetida em `lib/firebase_options.dart`
- todo o histórico, incluindo qualquer coisa que já tenha sido corrigida
  depois

No modelo do Firebase essas chaves **não são segredo**: elas identificam o
projeto, e quem protege os dados são as regras do Firestore, que já estão
fechadas e cobertas por 39 verificações. O que elas permitem é **abuso de
cota**, ou seja, conta no fim do mês. Enquanto o aplicativo não está na
loja, isso é aceitável. No dia em que ele estiver, deixa de ser.

E `.gitignore` não resolve: ele não desrastreia o que já está rastreado, e
`git rm --cached` não apaga o passado. O GitHub ainda guarda os commits
órfãos, alcançáveis por SHA, mesmo depois de um force-push. Por isso o
passo é **recriar**, e não limpar.

##### A ordem, que importa

Rotacionar **antes** de recriar. Recriar primeiro só troca o endereço de
onde a chave velha está publicada.

1. **Rotacionar a API key** no Google Cloud (*APIs e Serviços → Credenciais*).
   Gerar uma nova, aplicar restrição por **pacote `br.com.brigido.meu_bebe`
   + SHA-1 da chave de release**, e só então apagar a antiga
2. Baixar o `google-services.json` novo e regerar o `firebase_options.dart`
3. **Conferir o que mais está no histórico** antes de decidir o que salvar:

   ```bash
   git log --all --full-history --name-only --pretty=format: \
     | sort -u | grep -iE "google-services|key\.properties|\.jks|\.env"
   ```

4. **Repositório novo**, criado já público, com o `.gitignore` valendo desde
   o primeiro commit. Um commit inicial só, a partir da árvore de trabalho:
   o histórico antigo não vem junto, porque é justamente ele o problema
5. Conferir que nada sensível entrou:

   ```bash
   git ls-files | grep -iE "google-services|key\.properties|\.jks|\.keystore|\.env"
   ```

   Tem que voltar vazio. O `.example` de cada um fica, porque documenta o
   formato sem entregar o conteúdo
6. Recriar os segredos do Actions, que não viajam com o código:
   `GOOGLE_SERVICES_JSON`, `FIREBASE_OPTIONS_DART`, `RELEASE_KEYSTORE`,
   `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
7. Religar o GitHub Pages em `main` / `/docs` e conferir as duas URLs numa
   aba anônima
8. Apagar o repositório antigo. É o que tira os commits órfãos do ar
9. Atualizar as duas URLs no Play Console se o nome do repositório mudar

##### O que continua fora do repositório, para sempre

O `key.properties` e o `.jks` da assinatura. Esses **são** segredo de
verdade: quem tem a chave de assinatura publica atualização no lugar do
dono, e o Google não troca chave de aplicativo já publicado.

**Pronto quando:** o `git ls-files` do repositório novo volta vazio para a
busca acima, a API key antiga não existe mais no Google Cloud, o CI passa
verde com os segredos recriados, e as duas URLs abrem em aba anônima.

#### 9e. A ficha da loja

Metade texto, metade formulário, e a parte que mais reprova gente na revisão.

- Nome, descrição curta e longa, ícone, capturas de tela
- Questionário de **Segurança dos Dados**: identificadores da conta, para o
  login, e conteúdo do usuário, no índice do Firestore. Nada é vendido nem
  compartilhado
- Classificação de conteúdo
- **Público-alvo: adultos.** Declarar público infantil por engano, num
  aplicativo *sobre* crianças mas usado por pais, ativa a política Famílias,
  que é bem mais rígida

**Pronto quando:** o envio é aceito e entra em revisão.

#### 9f. Depois de estar no ar

- Ligar a obrigatoriedade do App Check, depois de alguns dias olhando o
  painel
- Acompanhar os primeiros relatos de falha e travamento

### Fase 8 - Longevidade

A fase que quase nenhum aplicativo faz e que este precisa fazer, porque o
horizonte dele é de décadas. A parte grande dela, a exportação, virou a
Fase 12: ela é maior que tudo que sobrou aqui e não cabia como subitem.

#### 8a. O aviso que ninguém dá ✅

Feito. Sexto tipo de lembrete, com botão próprio nas Configurações e
desligável como os outros, mais uma seção na tela Sobre.

Um problema de desenho apareceu na hora de escrever, e ele valia a parada: o
motor só marca 45 dias à frente, porque reagenda tudo a cada abertura. Só
que este aviso existe justamente para quem **parou** de abrir o aplicativo.
Dependendo de reagendamento, ele nunca dispararia. Por isso é o único tipo
que vive fora dessa janela, marcado onze meses à frente, e cada abertura o
empurra para mais longe. Quem continua aparecendo nunca o recebe.

Onze meses, e não os dois anos que o Google leva: um aviso que chega no
último dia é um aviso que chega tarde.

#### 8b. Instruções de herança ❌ descartada

Construída e removida no mesmo dia, e a razão vale mais que o código.

Eu escrevi uma seção "Entregar a cápsula um dia" explicando como passar a
conta adiante quando a criança crescesse. O desenho do produto não tem essa
etapa: **a conta já é da criança desde o primeiro dia.** É por isso que a
sugestão é criar uma conta nova do Google para a cápsula. Os pais usam essa
conta enquanto ela é pequena, e um dia ela simplesmente continua usando a
própria conta, sem entrega, sem transferência e sem herança nenhuma.

Um texto explicando como entregar algo que nunca precisa ser entregue não é
só supérfluo: ele planta a ideia de que existe um momento perigoso à frente,
onde não existe.

O que sobrou da preocupação legítima continua no aplicativo, na seção "Para
a cápsula durar" (8a): a conta não pode ficar dois anos sem uso. Esse é o
único risco real de longo prazo, e ele já está dito.

### Fase 10 - Antes de abrir a porta

Três coisas que não bloqueiam a submissão e que mesmo assim entram antes
dela, porque primeira impressão só acontece uma vez.

#### 10a. A data da memória ✅

Feito. Uma faixa no topo da folha de adicionar, acima das opções: "Aconteceu
hoje", e um toque abre o calendário. Sem data futura e sem data anterior ao
nascimento.

Fica antes de escolher os arquivos, e não depois, por dois motivos. A data
vale para o lote inteiro, que é exatamente o caso de quem está trazendo anos
de fotos de uma vez. E a pasta do Drive sai da idade naquela data: decidir
antes do envio evita ter de mover arquivo de pasta depois.

O caminho normal não mudou de tamanho. A faixa começa em "hoje", que é quase
todo envio, e quem não precisa dela só passa por cima. Quando há data
escolhida, a faixa muda de cor e ganha um botão para voltar para hoje: data
antiga esquecida ligada seria pior que não ter a função, porque as próximas
fotos entrariam caladas na idade errada.

A data escolhida também vale para carta, áudio, desenho, documento e para o
editor de crescimento, que já a recebe preenchida.

Depois de escolher os arquivos, e antes de qualquer envio, vem a
confirmação: quantos itens, com que data, que idade a criança tinha naquele
dia e em que semana aquilo vai ficar guardado. A data pode ser corrigida ali
mesmo. É o último ponto em que corrigir é barato, porque depois o arquivo já
subiu para o lugar daquela idade.

A idade é o que de fato evita o engano. "10 de abril de 2027" não diz nada a
quem está trazendo o acervo antigo; "tinha 2 meses e 19 dias" diz na hora se
a data está certa ou não.

Um lote de documentos pergunta uma vez só, e não uma vez por arquivo:
confirmar cinco vezes seguidas é o jeito mais rápido de a pessoa parar de ler
o que está confirmando.

**Descartado de propósito:** ler a data de dentro da foto (EXIF). Foto
baixada ou recebida por outro aplicativo chega sem metadado nenhum, e um
preenchimento que acerta às vezes é pior que nenhum, porque a pessoa para de
conferir.

Um detalhe que só aparece no Drive: o seletor devolve meia-noite, e o nome do
arquivo começa pela data e hora. Um lote inteiro marcado 00:00:00 geraria
nomes iguais dentro da pasta. A hora do relógio vai junto do dia escolhido.

**O menor item desta lista e o de maior ganho por linha escrita.**

#### 10b. As telas de apresentação ✅

Antes do login, no formato de slides que todo mundo reconhece:

1. **O que é isto** - não é um álbum de fotos, é uma cápsula que a sua filha
   vai abrir daqui a vinte anos
2. **Onde ficam as fotos** - no Google Drive **da própria pessoa**, não num
   servidor nosso. É o que faz a cápsula sobreviver a este aplicativo
3. **A conta** - a sugestão de criar uma conta Google só para a cápsula

O argumento da terceira tela não é espaço, é a entrega: no dia em que ela
fizer dezoito anos, você passa a conta inteira. Login e senha, e a cápsula é
dela. Com a conta pessoal isso é impossível, porque junto iriam suas
conversas e seus documentos.

**Sugestão, nunca exigência.** Dois botões do mesmo tamanho: "criar uma conta
nova" e "usar a minha conta". Obrigar a criar conta antes de ver o aplicativo
é o pedido mais caro possível no momento de maior desistência.

Vistas uma vez, guardadas no aparelho, com um jeito de rever no Sobre.

**Feito.** Duas decisões que só apareceram construindo:

A marca de "já vi" começa ligada, e não desligada, enquanto o disco não
responde. Mostrar a apresentação meio segundo depois a quem nunca viu é
barato; mostrá-la de novo a quem já passou por ela é irritante.

"Criar uma conta" não cria conta nenhuma: quem cria é o Google, dentro da
própria caixa de login. O que faltava a quem escolhe esse caminho é saber
onde tocar lá dentro, então a escolha viaja até a tela de login e vira uma
instrução de uma frase. Sem isso a pessoa escolhe criar uma conta e cai numa
tela que não diz uma palavra sobre como criar.

**Refeito com arte, em cinco telas.** As três de texto e ícone deram lugar a
cinco com ilustração: a infância passa depressa, toda lembrança tem seu
lugar, cada memória no seu tempo, um presente para o futuro, e o convite a
criar a cápsula.

A estrutura ficou: `OnboardingPage` desenha uma tela, `IntroScreen` folheia
as cinco, e a lista `introSlides` é o único lugar onde há texto. A rota, a
marca de "já vi", o recado que viaja até o login e o caminho de rever pelo
Sobre continuam iguais, porque o que mudou foi a apresentação e não o fluxo.

O ícone passou a sair de um arquivo só, `assets/images/icon/icon.png`, lido
pelo `flutter_launcher_icons`, pela abertura e pela última tela. O desenho
por código de `tool/gerar_icone.py` saiu: ele era a fonte quando não havia
arte, e manter os dois deixaria duas verdades sobre qual é a marca.

#### 10c. O sistema de movimento ✅

Feito. Movimento como sistema, não efeitos espalhados: as durações vivem em
`Motion`, dentro de `tokens.dart`, e quem for animar algo novo escolhe entre
elas em vez de inventar um número. É o que faz o aplicativo inteiro parecer
ter sido feito pela mesma pessoa.

Entrou tudo o que estava previsto: transição entre telas, a **miniatura
crescendo até virar a foto em tela cheia** saindo do lugar exato onde estava
(`HeroDaMidia`), os cartões da linha do tempo entrando conforme a rolagem, o
botão + e a folha subindo, o esqueleto no lugar da bolinha girando, e o
instante de destaque numa data redonda.

O que **não** entrou, por decisão tomada: texto aparecendo letra por letra.
Atrasa a leitura de quem está com o bebê no colo tentando ver uma foto com
uma mão só.

O ajuste de acessibilidade do Android que remove animações é respeitado
(`MediaQuery.disableAnimationsOf`). Ignorá-lo é problema real para quem tem
enxaqueca vestibular, e é uma linha de código.

Uma duração foge do sistema de propósito, e o motivo está escrito ao lado
dela: o brilho do esqueleto é muito mais lento que o resto, porque é o único
movimento que se repete sem parar. Na velocidade dos outros ele viraria
pisca-pisca e chamaria mais atenção que o conteúdo.

### Fase 11 - Mais de um filho ✅ (o desenho mudou por inteiro)

**O texto antigo desta fase estava errado, e o erro era meu.** Eu tinha
planejado várias crianças dentro de uma conta só: `users/{uid}/criancas/{id}`,
regras novas, uma pasta raiz por criança no Drive, um seletor de criança
ativa e uma migração para quem já usava. Nada disso foi feito, e nada disso
precisa ser.

**Cada filho tem a própria conta do Google.** A Maria tem a dela, o Pedro
tem a dele. Entra-se com a conta da Maria e tudo vai para o Drive da Maria;
troca-se para a do Pedro e o aplicativo inteiro passa a mostrar a cápsula
dele.

Isso é coerente com o que o produto prega desde a apresentação: a conta é da
criança desde o primeiro dia, e um dia ela recebe a conta inteira, login e
senha, sem transferência nenhuma. Duas crianças na mesma conta contradiria
justamente isso.

E resolve o problema difícil de graça. Contas diferentes do Google são `uid`
diferentes no Firebase, então o isolamento entre os filhos **já existe**, é
imposto pelo servidor, e é o mesmo que separa duas famílias quaisquer. A
regra "conteúdo de um filho nunca vai para a pasta do outro" passa a ser
verdade por construção, e não por filtro de consulta que alguém pode
esquecer de aplicar. A migração some junto, porque não há o que migrar.

**Como ficou:** `switchAccount()` em `session_service.dart`, e no Perfil uma
pílula "CONTAS ▾" que vai direto para o seletor do Google. "Acrescentar uma
criança" é entrar com outra conta, no mesmo botão, e a tela de cadastro
aparece sozinha porque aquele `uid` ainda não tem perfil.

**Nenhuma lista nossa de contas.** O seletor do Google já mostra os nomes,
os emails e as fotos das contas do aparelho, e ele é a fonte da verdade
sobre quais existem. Manter uma lista paralela seria uma segunda verdade
para ficar errada.

#### Duas consequências, ditas antes de serem descobertas

**A troca passa pelo seletor do Google toda vez.** Não é uma aba: são três
ou quatro toques. Isso é do modelo, não da implementação, e é o preço de
cada filho ter a própria conta.

**Os lembretes são só do filho ativo.** Quem tem dois filhos e passou o mês
na conta da Maria não recebe o aviso do aniversário do Pedro. O aparelho só
calcula lembretes da conta que está aberta. Limitação conhecida, para
resolver depois se incomodar.

### Fase 12 - Exportação legível sem o aplicativo

Era a 8c. Virou fase própria porque é a maior peça que sobrou e a que de
fato cumpre a régua: uma pasta navegável com as mídias e um índice em HTML
que abra em qualquer computador, hoje ou em 2051.

Precisa baixar tudo do Drive, montar a estrutura, gerar o índice e empacotar,
com o aplicativo aguentando ser fechado no meio.

**Pronto quando:** dá para entregar a cápsula inteira a alguém que nunca
ouviu falar deste aplicativo.

### Fase 13 - Plano Premium

Assinatura mensal, com o básico livre e o resto pago.

**Livre:** linha do tempo inteira, enviar fotos e vídeos, aba Inspirações,
perfil. Dá para viver no aplicativo sem pagar nada.

**Pago:** crescimento (peso e altura), desenhos, voz, documentos. A pessoa
entra na seção, vê o conteúdo desfocado e recebe o convite para assinar.

#### O que muda em relação ao que você descreveu

**Você não precisa calcular moeda nenhuma.** A Play Store faz isso: define-se
o preço em euro e o Google converte para cada país, já arredondando pelo
padrão local de preço. Um euro vira o valor local que parece preço, não
resultado de conversão. Não há código de câmbio a escrever.

**A cobrança tem que ser do Google.** Vender funcionalidade dentro de um
aplicativo Android por fora do faturamento da Play Store é violação de
política e tira o aplicativo do ar. Então é o Google Play Billing, com o
produto de assinatura criado no Play Console.

**A verificação não é por email.** O direito de uso fica preso à conta Google
que comprou, e quem responde é a biblioteca de faturamento no próprio
aparelho, não uma consulta nossa por endereço.

#### A limitação, dita antes de ser descoberta

Conferir a assinatura só no aparelho é burlável por quem sabe mexer. Fechar
isso de verdade exige servidor conversando com a API do Google, o que
significa Cloud Functions, plano Blaze e custo recorrente. Para uma
assinatura de um euro, o aperto não paga o preço. Fica registrado como
escolha consciente, não como descuido.

#### A linha que eu não cruzaria

**Pagar libera criar, nunca libera ver o que já é seu.** Se alguém registrar
o peso do filho durante três meses pagos e parar de pagar, esses registros
têm que continuar visíveis. Este aplicativo promete que a criança abre a
cápsula daqui a vinte anos; um aplicativo que esconde memória já guardada
por falta de pagamento quebrou a própria promessa e vira problema de suporte
e de reputação.

Também recomendo **lançar de graça e trazer a assinatura na primeira
atualização**. Faturamento é a parte mais fácil de errar de um aplicativo, e
errar nela com a loja em revisão é atrasar o lançamento inteiro. Com zero
usuários, não existe o desgaste de "era grátis e agora cobram".

---

## Critérios que valem em toda fase

- Material Design 3, aplicativo leve e rápido
- `dart format`, `flutter analyze --fatal-infos --fatal-warnings` e
  `flutter test` limpos antes de cada entrega
- Nenhuma regressão nas telas atuais
- Nenhuma leitura da estrutura do Drive para descobrir o que existe: o
  índice é o Firestore
- Componentes reutilizáveis em vez de repetição
- Comentário só onde o código não se explica

---

## Adiado: compartilhamento com familiares

Construído inteiro, testado, e **retirado antes da publicação**. Não por
falhar: por custar dinheiro numa hora em que ninguém sabe ainda se alguém
vai pedir.

### O nó, exato

O aplicativo pede ao Google só a permissão `drive.file`: "ver, editar, criar
e apagar apenas os arquivos específicos que você usa com este app". Essa
lista é por pessoa **e** por aplicativo, e um arquivo só entra nela se
aquele app o criou naquela conta.

Daí o que trava, e é contraintuitivo: o pai pode compartilhar a pasta pelo
Google Drive, e a avó vê tudo perfeitamente **no aplicativo do Drive**. Mas
o nosso aplicativo, na conta dela, nunca criou nada, então para ele o Drive
inteiro é invisível. Não é a pasta que está escondida: é o aplicativo que
está de vendas, e as vendas foram postas de propósito.

### Os dois caminhos, com o preço de cada um

**Ler o Drive direto**, que é o desenho mais honesto para um aplicativo que
promete ser uma ponte. Exige pedir `drive.readonly` ao familiar: "ver e
baixar **todos** os seus arquivos do Google Drive". Google não oferece um
escopo "só o que compartilharam comigo". Funciona nativo, inclusive vídeo,
sem cópia nenhuma. Preço: escopo restrito, e publicar aberto na Play Store
com ele exige auditoria de segurança anual paga por terceiro.

**Cópias reduzidas no Firestore**, que é o que chegou a ser construído.
Nenhuma auditoria, publicação livre. Preço: o armazenamento sai do Drive de
cada família e passa para a conta de quem publica, inclusive por quem nunca
vai convidar ninguém.

### Por que ficou para depois

A publicação é em semanas, a auditoria não cabe nesse prazo nem nesse
orçamento, e pagar armazenamento por uma função que talvez ninguém use é
pagar para descobrir. Com base instalada, dá para responder as duas coisas
que hoje são chute: quantos pedem, e quanto custaria.

### Onde está, para retomar sem refazer

Quatro commits, nesta ordem:

- `0dad56b` regras do vínculo, medidas no emulador. Duas descobertas ficaram
  registradas nos comentários e valem mais que o código: a consulta de lista
  no Firestore é avaliada **contra a consulta**, não contra cada documento
  devolvido, e por isso a formulação tolerante do lacre vazava; e os testes
  disparavam concorrentes num banco sujo, o que fazia o teste do vínculo
  passar por sorteio
- `ea43431` convite com código ditável por telefone, vínculo,
  `capsuleOwnerProvider` como ponto único de troca, e modo leitura
- `74e5cb9` miniaturas no Firestore
- `e8c3a42` foto em tela cheia dentro do aplicativo

O que ficou de pé no código de hoje: as coleções `miniaturas` e `imagens`
continuam na varredura de exclusão de conta, porque quem instalou a versão
de teste tem documentos gravados nelas.

## Concluído

### A estrutura do Drive ✅

Cinco pastas criadas no cadastro, mais o arquivo de informações. As pastas
de idade nascem no primeiro conteúdo que precisa delas.

```
Meu Bebê - Cápsula do Tempo/
├── Fotos/
│   └── Primeiro Ano/     <- só quando a primeira foto chega
├── Vídeos/
├── Cartas/
├── Desenhos/
├── Documentos/
└── Informacoes.txt
```

**A nomenclatura por ano vale só no Drive.** `Primeiro Ano`, `1 Ano`,
`2 Anos`, por `AgeBucket.driveFolderName`. Dentro do aplicativo a galeria
continua em `Semana 07` e `Mês 14`, por `folderName`. Públicos diferentes:
quem abre a pasta daqui a vinte anos quer anos, quem registra hoje quer a
semana.

**Carta virou `.txt` no Drive**, na pasta da idade, reescrito quando editada.
Sem isso a pasta `Cartas` ficaria vazia para sempre e as cartas continuariam
morrendo junto com o aplicativo.

**O `Informacoes.txt`** guarda o cadastro e todas as medições em texto
legível, reescrito inteiro a cada mudança, por id de arquivo guardado no
Firestore. **O aplicativo nunca lê esse arquivo:** o Firestore continua sendo
a fonte da verdade, e o `.txt` é representação para quem abrir a pasta sem o
aplicativo. Peso e altura deixaram de ter pasta e passaram a viver ali.

**O acervo antigo não precisou de migração.** As pastas de idade antigas
(`Semana 07`) continuam válidas, com o id guardado no Firestore. As duas
convenções convivem, e isso é aceitável: o Drive fica com um pouco de
história.

### A privacidade da sessão ✅

**Abrir o aplicativo não pede mais a conta do Google.** O seletor aparecia em
toda abertura, com a linha do tempo já carregada atrás dele: a sessão estava
restaurada e a escolha era inútil.

A causa levou investigação no código do plugin, e vale registrada porque o
nome do método mente. `attemptLightweightAuthentication` promete restauração
silenciosa, mas no Android o plugin faz **duas** tentativas em sequência: a
primeira com `filterToAuthorized: true` e `autoSelectEnabled: true`, de fato
silenciosa; e, quando essa devolve nulo, uma segunda com as duas em falso,
que é a folha do Credential Manager com todas as contas do aparelho. Em
aparelho com mais de uma conta, cai sempre na segunda.

Quem sustenta a sessão é o Firebase Auth, lido do disco sem rede. A conta do
Google só faz falta para o Drive, e por isso a recuperação foi adiada para o
momento em que o Drive precisa dela.

**O envio não precisa da conta, só da autorização.** Tirar a chamada da
abertura quebrou o envio, e o conserto de verdade foi um degrau novo:
`authorizationClient.authorizationForScopes`, que devolve o token do Drive
sem usuário nenhum e sem abrir tela, porque o consentimento fica guardado no
aparelho. Três degraus, nesta ordem: com a conta que já está em mãos, sem
conta nenhuma, e só então o caminho interativo.

**O degrau sem conta tem um risco, e ele é conferido.** Ele não diz de qual
conta é o token. Num aparelho com duas contas autorizadas, o sistema pode
devolver a errada, e aí as memórias de um filho entrariam no Drive do outro:
silencioso na hora e irreversível depois. Por isso `_conferirDono` compara o
dono do Drive com o email do Firebase, uma vez por sessão, e recusa em vez de
usar. Quando não há o que comparar (sem email, sem rede), deixa passar:
recusar por falta de informação deixaria o envio impossível em vez de seguro.

Há teste lendo o código para as três coisas, porque o defeito não aparece em
teste de widget nem no `analyze`: ele só se vê num aparelho com duas contas,
que é justamente onde ninguém roda a suíte.

### O tamanho dos arquivos ✅

**Teto fixo de 960 px no lado maior, qualidade 78.** Vídeo em 540p.

A regra é um teto, e essa palavra foi o pedido: nenhum aparelho e nenhuma
contagem de megapixels pode ser reduzido de forma diferente de outro. Foto
que já é menor que o teto não é ampliada.

**Um erro meu no caminho, e ele ensina algo.** A primeira tentativa deixou a
foto **maior** (101 KB viraram 181 KB). O teto de então era 1.600 px e não
encostava nas fotos daquele aparelho, que já eram menores; só a qualidade
valia, e qualidade 80 sobre o tamanho inteiro pesa mais que qualidade 88
sobre a metade. Baixar o teto para onde ele de fato corta foi o que resolveu.
A lição: um teto que não encosta em nada não reduz nada, e medir antes de
concluir teria evitado a viagem.

### A janela do envio ✅

Antes, o envio avisava por uma tarja que sumia sozinha em seis segundos. Ela
dizia que o envio começou e nunca dizia que terminou, então quem mandava algo
e trocava de tela não descobria se deu certo, e principalmente não descobria
**onde** aquilo foi parar. Numa cápsula organizada por idade, esse "onde" é
metade da informação.

`EnvioEmAndamento` acompanha do começo ao fim e termina apontando o lugar,
com botão que leva até lá: "Ver a pasta" para foto e vídeo, "Ver o desenho",
"Ver o documento". Carta, crescimento e nascimento não entram em pasta de
idade, então não ganham botão, e a frase diz Drive em vez de citar uma semana
que seria mentira.

Recebe uma **lista** de memórias, e não uma só, porque documento é enviado um
por arquivo: três documentos são três memórias, e uma janela por arquivo
seguraria o envio do próximo até alguém fechar a anterior.

Ela lê o fluxo de progresso **e** a lista de entradas. Sem a segunda, um
envio que termina antes de a janela abrir deixaria ela girando para sempre.

#### O defeito que ela teve, e que vale guardar

A janela não aparecia. O `context` que chegava no envio era o da própria
folha de adicionar; fechar a folha desmonta a rota, e a partir daí
`context.mounted` é falso. O envio é assíncrono e demora bem mais que a
animação de fechamento, então quando a janela ia ser pedida o guarda de
segurança pegava primeiro e a função retornava calada. Sem exceção, sem
aviso, sem nada no `analyze`.

O conserto é guardar o `NavigatorState` da raiz **antes** do `pop`: ele não é
o que está sendo fechado.

O teste disso teve uma segunda lição. A primeira versão dele passava com o
conserto revertido, porque eu tinha usado um envio instantâneo, e com envio
instantâneo a rota ainda está de pé e a janela abre até pelo contexto errado.
O defeito só existe porque o envio demora, e o teste só vale se demorar
também.

### As pastas divididas por dentro ✅

Abrir o `Mês 14` era rolar uma parede de fotos sem nenhuma pista de quando
cada uma aconteceu. Agora o mês se divide por semana e o ano se divide por
mês, por `secoesDoBalde`, uma função pura.

**A contagem é relativa à pasta**, e é aí que mora o erro fácil: dentro do
`Mês 14` a primeira semana é a `Semana 1`, e não a `Semana 57`. Quem abriu a
pasta do mês está pensando naquele mês.

**Sub-período vazio não vira seção.** Um mês com fotos só na quarta semana
mostra `Semana 4` e mais nada; `Semana 1`, `2` e `3` não aparecem como
buracos. Uma semana em que ninguém registrou não é informação.

A pasta de semana volta com uma seção só, de título vazio, e nenhum cabeçalho
é desenhado: sete dias não têm o que separar.

O visualizador em tela cheia continua deslizando pela pasta inteira, e não só
pela seção em que se tocou: quem está olhando uma foto da Semana 2 espera
chegar na Semana 3 arrastando.

### O papel de cada tema ✅

O creme (`#FCF3EE`) tinha ido para as três paletas. Na Lavender ele está
certo, mas ele é um papel **quente** (matiz 21°) e não sai da paleta de
ninguém: existe para harmonizar com o rosa. Sobre a Sky, que é fria inteira,
ele briga.

A Sky passou a ter papel próprio, `#F1F5FB`, tirado dela mesma: matiz 216° e
saturação 56%, contra 213° e 57% do `primary`, clareado até dar exatamente a
mesma presença do creme contra um cartão branco (1,0941:1 nos dois). Os dois
temas têm o mesmo peso de papel, e só a temperatura muda.

#### O preenchimento teve de mudar junto, e esse é o aprendizado

Trocar só o fundo teria quebrado a tela em silêncio. O que separa
`surfaceMuted` do papel na Lavender é a **temperatura**: o fundo tem b* +3,5
e o preenchimento b* -2,7, e essa virada responde por quase todo o ΔE 6,87
entre os dois. Com o fundo frio, o preenchimento azul de antes caía para
ΔE 1,48, abaixo do limiar em que o olho separa duas cores, e o esqueleto, a
miniatura e o cartão sumiriam dentro da tela.

A saída estava na própria paleta, no verde-água do `accent`: `#E9F2EE`,
ΔE 5,71 do papel novo, com a mesma presença do preenchimento da Lavender. O
eixo mudou de temperatura para matiz, o resultado é o mesmo.

#### Um defeito antigo que apareceu junto

A guarda nova reprovou também o tema **Welcome**, e ali o problema já existia
havia meses: fundo `#FCF3EE` e preenchimento `#F8F0EB` a ΔE 1,18. Esqueleto e
cartão eram desenhados e não apareciam, justamente nas telas de apresentação
e de login, que são as primeiras que alguém vê. Passou despercebido porque
**nada dá erro quando uma cor some**. Corrigido para `#F5E9E0`, areia.

#### Por que a regra da WCAG não pegava nada disso

Contraste da WCAG só enxerga claro contra escuro. Duas cores de luminância
parecida e matizes diferentes voltam com razão perto de 1 mesmo sendo
perfeitamente distinguíveis, e o contrário também: no caso da Sky a razão ia
de 1,007 para 1,101, e nenhum dos dois números diz nada sobre sumir. Por isso
o teste novo mede distância em CIE Lab, que é o espaço onde "o olho separa"
tem significado.

### O acerto visual ✅

Fundo creme (`#FCF3EE`), painel do topo com cor própria, barra sem contorno,
o texto do painel centralizado de verdade, e a Home mais enxuta: a data de
nascimento saiu de lá, porque quem abre o aplicativo todo dia já sabe.

O visualizador em tela cheia ganhou ícones em branco forte. Vale registrar o
detalhe, porque custou tempo: `appBarTheme.iconTheme` **vence** o
`foregroundColor` do widget, então mudar a cor no lugar óbvio não faz nada.

A foto em tela cheia ganhou zoom por toque duplo no ponto tocado, e o
`PageView` para de deslizar enquanto está ampliada, senão arrastar para
enquadrar viraria trocar de foto. E ganhou o botão de apagar do acervo.

Os rótulos dos campos passaram de 9,75 px para 14. O motivo é uma armadilha
do Flutter: o rótulo flutuante é encolhido por uma **transformação** de 0,75,
e não por uma fonte menor, então quem quer 14 px na tela precisa pedir
14 / 0,75. Medido na tela, não deduzido, e há teste.

**A pergunta em aberto:** o fundo creme foi aplicado às três paletas,
inclusive a de menino. Ver
[Defeitos conhecidos](#defeitos-conhecidos-e-pendências).

### O blog ✅

As inspirações viraram um blog de verdade: capa, página de leitura, busca
própria e uma porta de saída. **46 postagens**, todas com texto.

**Uma postagem é um par de arquivos com o mesmo nome**, o `.json` e o
`.webp`, e o nome do arquivo **é** o identificador. Não existe campo `id`
dentro do JSON, não existe catálogo central e não existe linha para
acrescentar no `pubspec.yaml`: o aplicativo descobre a pasta em tempo de
execução e a suíte passa a cobrir a postagem nova sozinha.

As capas ainda não existem. Ver [Defeitos conhecidos](#defeitos-conhecidos-e-pendências).

### Fase 6 - Notificações inteligentes ✅

Locais, sem servidor. Tudo o que o aplicativo precisa para lembrar de algo
já está no aparelho: a data de nascimento, o que foi registrado e quando.
Push exigiria Cloud Functions, plano pago e mandar para fora um dado que o
celular tem na mão.

**O motor é uma função pura.** `planReminders` recebe a cápsula e o dia e
devolve a agenda; não toca em rede, plataforma nem relógio. É o que permite
testar em segundos o que levaria dois anos para observar num aparelho, e é
o que cumpre o critério combinado: acrescentar um lembrete novo é
acrescentar uma regra, e nada mais.

**Cinco motivos, cada um com botão próprio:** datas redondas, aniversário,
primeiras vezes do ano, ideias com prazo e o lembrete gentil. Separados
porque um interruptor único transforma "isso me irrita" em "desliguei
tudo", e aí a pessoa perde também o que gostaria de saber.

**O número mais importante da fase é o teto:** no máximo um por dia, no
máximo dois em qualquer sete dias, e o teto vale acima de qualquer regra.
Se houver cinco motivos válidos numa semana, três não são enviados. Um
aplicativo de memórias que avisa demais vira um aplicativo desligado, e um
aplicativo desligado não lembra de nada.

**O lembrete gentil é o mais fácil de errar**, e por isso é o mais
cuidadoso: não existe em cápsula ainda vazia, não diz há quantos dias, e
perde o dia para qualquer outro aviso. Quem não registrou nada em duas
semanas pode ter passado duas semanas num hospital.

**Ligados por padrão, e essa foi uma decisão de produto explícita.** Uma
cápsula do tempo só cumpre a promessa se alguém voltar a ela, e quem tem um
bebê pequeno não volta por conta própria: as semanas somem. Deixar
desligado significaria que quase ninguém liga, e aí os lembretes existiriam
no código e não na vida de ninguém. Só se sustenta porque o teto é pequeno.

Isto não é permissão. No Android 13 em diante quem decide é o sistema, e
ele pergunta: o aplicativo pede a permissão na primeira vez que a tela
inicial aparece, que é depois de a cápsula existir, e nunca mais insiste.
Se a resposta for não, a chave volta sozinha para desligado - uma chave
ligada que nunca toca é pior que uma desligada, porque ninguém vai procurar
o defeito.

**Nenhum aviso cita o que foi escrito.** Notificação aparece na tela
bloqueada e quem está do lado vê. Há teste varrendo os textos atrás de
"carta", "lacrado" e afins.

O aplicativo **não pede alarme exato**. Os lembretes são agendados em modo
inexato, o que dispensa a permissão que o sistema apresenta com cara de
coisa séria e que o Google Play audita. Um lembrete de tirar uma foto pode
chegar meia hora depois e continua valendo. Há teste no manifesto para o
dia em que alguém trocar o modo de agendamento sem perceber a conta que
vem junto.

Quem foi convidado não recebe lembrete nenhum: cobrar da avó duas semanas
sem foto seria cobrar uma coisa que ela nem pode fazer.

33 testes novos.


### Fase 5 - Aba Inspirações ✅

*(Revisada duas vezes. Primeiro porque o conteúdo era raso e as âncoras só
sabiam faixa de idade, e é o que a seção "O que mudou na revisão" conta
abaixo. Depois a aba virou um blog, com capa, página de leitura e busca
própria, e o catálogo passou de 42 para 46 postagens: ver [O
blog](#o-blog-). O que continua valendo deste bloco é a régua do conteúdo,
que é a parte que mais importa.)*

Nova aba na barra de baixo, no lugar da Busca. A busca não sumiu: foi para
a lupa no topo da Home, da linha do tempo e da própria aba nova, que é onde
a mão procura por ela.

**Não é um blog.** Cada cartão é uma coisa que dá para fazer hoje, com o
que existe em casa, e quase sempre termina em algo que vale guardar. Texto
bonito sem ação vira leitura passiva, e este aplicativo não quer tempo de
tela: quer que a pessoa levante e vá brincar. Por isso os cartões com o
botão "Registrar agora".

**Nada aqui diz o que a criança deveria estar fazendo.** Foi a decisão mais
importante do conteúdo. Uma tabela de desenvolvimento numa tela de memórias
transforma um álbum em avaliação, e quem lê "aos seis meses já senta" com
um filho que ainda não senta ganha uma angústia que não pediu. As faixas de
idade escolhem a hora de sugerir, nunca dizem se está atrasado. Um teste
varre o catálogo e reprova o CI se algum texto novo escorregar para esse
tom.

**Trocar por um backend é trocar uma classe.** `InspirationSource` é a
interface; `AssetInspirationSource` lê o JSON que viaja dentro do
aplicativo. E isso não é só um provisório: assim o feed funciona sem rede,
sem custo de servidor, e não manda a idade da criança para lugar nenhum,
que é o que uma consulta a um backend inevitavelmente entregaria.

#### O que mudou na revisão

**Âncoras, não só faixas de idade.** "Três semanas antes do primeiro
aniversário" não é uma idade, é uma contagem regressiva, e uma criança
nascida em março chega nesse ponto num dia do ano diferente de uma nascida
em outubro. Agora há três tipos de âncora: faixa de idade, contagem até um
aniversário e contagem até uma data do calendário (com as datas móveis já
resolvidas na Fase 3). O que tem prazo vem sempre no topo do feed.

**Texto longo.** Os conteúdos que pedem profundidade abrem numa página
própria, com seções e listas: onde fazer a festa, o que servir, o que
registrar antes que o dia passe. O resumo continua curto no cartão, porque
resumo longo transforma a lista num artigo.

**Selo de novidade.** Quem ainda não abriu vê "novo" no cartão e um número
na aba. Guardado no aparelho, não no Firestore: é preferência de leitura,
não memória. Abrir já conta como lido, porque o selo existe para avisar que
chegou algo, não para cobrar leitura até o fim.

**42 conteúdos**, dez deles com texto longo. Os destaques são poucos de
propósito: se tudo é destaque, nada é, e um teste reprova o CI se passarem
de um terço do catálogo.

O que encosta em saúde aponta para a pediatra e diz explicitamente que não
é orientação médica. Um teste garante isso no conteúdo de introdução
alimentar.

**Capas desenhadas em código.** Cada tipo de conteúdo tem uma ilustração
própria (bolas, colinas, bandeirinhas, envelope, páginas) pintada pelo
próprio aplicativo, nas cores da paleta: a mesma capa sai em rosa para uma
menina e em azul para um menino. Foto de banco de imagens exigiria licença,
engordaria o APK e colocaria o bebê de outra pessoa num aplicativo que é
sobre uma criança específica; buscar na internet faria o aplicativo avisar
um servidor a cada abertura da aba.

**Leituras relacionadas** no fim do artigo, até três, escolhidas por
assunto e só entre as que valem hoje. Fica registrado que eu recomendei uma
só, para não virar rolagem sem fim; a escolha pela lista foi do dono do
produto. O botão flutuante continua sendo o de registrar, não o de ler
mais.

**Verificação:** 217 testes (26 só de inspirações), analisador e formatador
limpos. Os testes cobrem a contagem regressiva chegando na hora, sumindo
depois da festa, funcionando para quem nasceu em 29 de fevereiro, e o feed
nunca ficando vazio em doze idades diferentes.

### Fase 4 - Cápsula lacrada (a voz entrou e saiu) ✅

**A voz foi construída inteira e depois retirada do produto.** Ela era um
tipo de memória gravado no aplicativo, em AAC dentro de contêiner MP4, com
limite de cinco minutos. Saiu por decisão de produto, e o registro do porquê
importa mais que o código que existiu.

O que saiu junto: `features/audio/`, o `EntryType.audio`, a opção na folha
de adicionar, as cores da paleta, as dependências `record` e `just_audio`, e
a permissão `RECORD_AUDIO` do manifesto. Ela era **a única permissão
perigosa** que o aplicativo pedia, e o aplicativo hoje não pede nenhuma.

**A armadilha da remoção, que quase custou memória de gente.**
`EntryType.fromId` tem `orElse: () => EntryType.photo`. Apagar o valor do
enum faria toda gravação já feita **virar foto** na linha do tempo, com um
`.m4a` que a galeria tentaria desenhar. Por isso a remoção veio com uma
limpeza única (`limparRestosDeAudio`), que apaga do Firestore as entradas de
áudio e manda a pasta `Áudios` do Drive para a lixeira, uma vez por
aparelho. Há teste garantindo que uma entrada antiga de áudio não é lida
como foto.

**Cápsula lacrada.** Qualquer entrada aceita uma data de abertura. A
escolha fica junto do título, e não escondida num menu, porque decidir
lacrar é do mesmo momento em que se decide o que escrever. Atalhos para os
15, 18, 21, 25 e 30 anos, calculados a partir do nascimento.

Enquanto o lacre vale, a linha do tempo não mostra o conteúdo **nem o
título**. A tela "Guardado para o futuro" mostra só o tipo, a data e quanto
falta: a espera é metade do presente.

**Isto é um lacre, não um cofre**, e está dito na própria tela. O conteúdo
segue no Drive de quem gravou. Poderia ser criptografia de verdade, mas uma
chave perdida em vinte anos apagaria a memória para sempre, e num acervo
feito para durar décadas esse risco é maior que o de alguém espiar o
próprio presente.

Um teste garante o erro que apagaria um presente: corrigir um título em
2030 não pode abrir sozinha a carta dos 18 anos.

**Verificação:** 191 testes Dart (14 novos) e 30 no emulador (3 novos).

### Fase 3 - Momentos, eventos e checklists ✅

Os itens 3, 4 e 7 viraram uma coisa só, porque eram o mesmo problema:
um catálogo de sugestões avaliado contra a idade e a data.

**Acrescentar uma sugestão é acrescentar uma linha.** `Suggestions.all` é
só dado; quem decide se ela vale hoje é um `Trigger` de três tipos:
`AgeWindow` (por volta dos quatro meses), `FirstSpecialDate` (perto do
primeiro Natal) e `BeforeBirthday` (faltando 45 dias). Era o pedido
explícito para os checklists, e vale igual para o resto.

**O calendário brasileiro, calculado.** Páscoa pelo algoritmo de
Meeus/Jones/Butcher, Carnaval 47 dias antes, dias das mães e dos pais no
segundo domingo de maio e agosto. Conferido ano a ano contra o calendário
de verdade, e com as invariantes checadas em 35 anos: Páscoa sempre num
domingo, Carnaval sempre numa terça, o segundo domingo sempre entre os
dias 8 e 14.

Chutar "sempre em abril" faria o aplicativo lembrar do primeiro Natal na
data errada, e data errada é pior que data nenhuma: estraga a confiança em
tudo o mais que ele diz.

**Nada é assumido.** O aplicativo não sabe se a criança já sorriu, e dar
isso como certo seria inventar a memória de outra pessoa. Um teste reprova
o CI se algum título passar a afirmar em vez de sugerir.

**"Primeiro" quer dizer primeiro.** A sugestão do primeiro Natal só
aparece se o Natal que vem for de fato o primeiro depois do nascimento; no
segundo ano ela não volta. E o que foi dispensado ou marcado como feito
nunca reaparece.

**Onde vive.** Tela "Momentos importantes" no menu, e na tela inicial só a
sugestão mais urgente, uma por vez. Lista de pendências na Home vira
cobrança.

**Verificação:** 177 testes Dart (30 novos) e 27 no emulador do Firestore
(8 novos, cobrindo a coleção `sugestoes`: dono lê e escreve, terceiro não
lê nem escreve, anônimo não alcança, campo estranho e tipo errado
recusados). A coleção nova também entrou na exclusão de conta.

### Fase 2 - Home viva e timeline agrupada ✅

**As contas saíram da tela.** `CapsulePulse` responde, sem tocar em rede,
que idade a criança tem hoje, se hoje é data redonda, quanto falta para o
próximo aniversário e há quantos dias foi o último registro de cada tipo.
Vive separado porque data erra em silêncio, e porque as notificações da
Fase 6 precisam exatamente destas mesmas contas.

16 casos de borda cobertos, incluindo nascida em 29 de fevereiro (o
aniversário some três anos em cada quatro se ninguém tratar), nascida em
31, virada de ano, e registro com data futura virando número negativo.

**Home.** Saudação por horário, "Hoje a Maria está com 8 meses e 12 dias"
em destaque, e cartões que só aparecem quando têm resposta: cartão vazio é
ruído, e ruído na primeira tela faz a pessoa parar de olhar. Cada cartão
de "última foto" leva para a categoria ao ser tocado. Botão "Registrar
momento" abrindo o BottomSheet que já existia.

Quando um tipo nunca aconteceu, o cartão convida em vez de acusar.

**Timeline agrupada.** Dia com mais de 4 itens abre recolhido, mostrando
"12 fotos" com um toque para expandir. Dia curto nunca recolhe: esconder
duas fotos atrás de um toque seria trocar a memória por um menu. O resumo
junta como se escreve em português, "2 fotos, 1 vídeo e 1 carta", e mantém
sempre a mesma ordem para que dois dias parecidos se pareçam na tela.

**Avatar.** O caminho antigo tentava gravar `photoDriveId` logo depois de
escolher a foto, mas o envio ao Drive é assíncrono e naquele instante o id
ainda é vazio: a foto nunca chegava ao perfil. Agora o avatar é derivado
das entradas, então aparece sozinho quando o envio termina e sobrevive à
exclusão da foto escolhida. O caminho morto saiu.

**Verificação:** 147 testes (26 novos), analisador e formatador limpos.
Um dos testes novos pegou um erro que teria ido para o celular: o cartão
do aniversário mostraria "19 faltam 19 dias".

### Fase 1 - Identidade e linguagem ✅

**Paleta adaptável ao sexo.** `AppColors` era `abstract final` com tudo
`static const`, e constante não muda em tempo de execução. Virou
`AppPalette extends ThemeExtension`, com três variantes: menina
(rosa-malva, lilás, pêssego), menino (azul suave, verde água, cinza) e
neutra (lavanda acinzentada) para antes do cadastro. O `MaterialApp` lê o
perfil e anima a transição sozinho.

158 usos em 61 arquivos migrados para `context.cores`, guiados pelo
analisador. Os getters de cor por categoria viraram métodos que recebem o
contexto, porque uma extensão sobre enum não tem de onde tirar a paleta.

**Linguagem pelo nome.** O helper `G`, que escolhia entre "sua bebê" e
"seu bebê", virou `Copy`, que recebe o perfil inteiro e usa o nome:
"Adicionar fotos da Maria", "Informações do Pedro". Isso dissolve quase
toda a concordância de uma vez, porque as duas formas passam a diferir só
no artigo.

Onde não há nome (login, início do cadastro), a frase foi reescrita para
não precisar de referente, em vez de cair numa forma genérica desajeitada.
Cadastro antigo sem sexo informado dispensa o artigo ("de Alex"), que é
correto em português e melhor que arriscar a forma errada.

**Ícone do aplicativo.** Coração dentro de um anel, sobre degradê do lilás
ao azul: as duas cores de marca no mesmo ícone, já que ele é um só para
todo mundo. Legado e adaptativo, cinco densidades. Desenhado por código em
`tool/gerar_icone.py`, sem dependência externa, para ter fonte em vez de
ser um binário sem origem.

**Verificação:** 121 testes (8 novos), `flutter analyze
--fatal-infos --fatal-warnings` limpo, `dart format` limpo. O novo
`test/copy_test.dart` inclui uma varredura que falha o CI se "sua bebê"
voltar a qualquer arquivo de interface.
