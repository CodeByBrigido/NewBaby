# Plano de evolução

Documento de acompanhamento. Releia antes de cada fase; ao concluir uma,
mova o bloco para [Concluído](#concluído), no fim do arquivo.

## A régua

Este aplicativo não é um álbum de fotos. É uma cápsula do tempo digital.

Toda decisão de UX responde a uma pergunta só: **daqui a 20 ou 30 anos, a
própria criança vai abrir isto e reviver a infância dela.** Quando houver
dúvida entre duas soluções, ganha a que serve melhor a essa pessoa, não a
que é mais fácil para quem registra hoje.

O Google Drive é só o armazenamento. O aplicativo esconde isso por
completo: ninguém vê pasta, arquivo, sincronização ou cota.

---

## Auditoria do que existe hoje

63 arquivos, 11.452 linhas, 113 testes. A base de armazenamento está
sólida. O que segue é o que a lista de adicionais encosta.

### A paleta é constante de compilação

`AppColors` é `abstract final` com tudo `static const`, e há **158 usos em
61 arquivos**. Adaptar a cor ao sexo da criança não é trocar valores: é
trocar o mecanismo. Uma constante não muda em tempo de execução.

Caminho escolhido: `ThemeExtension<AppPalette>`, com a paleta ativa
resolvida a partir do perfil e lida por um atalho curto (`context.cores`).
É mais trabalho do que um global mutável, mas é o que sobrevive a tema
escuro, a testes e a troca de perfil sem gambiarra.

O trabalho é mecânico e o analisador aponta cada ponto. Alto volume de
diff, baixo risco.

### O helper de gênero existe, e fala exatamente o que você quer eliminar

`lib/core/l10n/gendered.dart` já centraliza a concordância, mas a API dele
é construída em cima de `yourBaby` e `ofYourBaby`, que produzem "sua bebê"
e "do seu bebê". Está espalhado por telas vazias, dicas e o cadastro.

O perfil já tem `firstName`. A correção não é substituir string por
string: é o helper passar a receber o perfil inteiro, para que a frase
padrão vire "as memórias da Maria" e a forma genérica só apareça enquanto
o nome ainda não existe (login e primeira etapa do cadastro).

### A timeline já agrupa por dia, só não mostra assim

`timeline_screen.dart:140` já faz `groupBy` por dia. O que falta é o
cabeçalho com o resumo ("5 fotos, 1 vídeo, 1 carta") e o recolher/expandir.
O item 9 é mais barato do que parece.

### O BottomSheet do item 8 já existe

`lib/features/shell/add_sheet.dart` já oferece foto, vídeo, carta,
documento, desenho e crescimento. A Home só precisa do botão que o abre.

### Não existe nenhuma infraestrutura de notificação

Nem `firebase_messaging`, nem `flutter_local_notifications`.

**Decisão: notificações locais, não push.** Todas as condições que você
descreveu ("7 dias sem foto", "40 dias sem medir") são calculáveis no
próprio aparelho, a partir de dados que o app já tem. Push exigiria Cloud
Functions, que exige o plano Blaze, que exige cartão de crédito e vira
custo recorrente para observar algo que o celular já sabe. Local é mais
barato, funciona sem rede e não manda dado nenhum para fora.

### As regras do Firestore são estritamente do dono

Todo `match` exige `isOwner(uid)`, e há um `allow read, write: if false`
final fechando o resto. Isso foi deliberado e é o que blinda o projeto.
Compartilhamento exige um modelo novo por cima, sem afrouxar o que existe.

---

## O que não está na lista dos 12 e entra assim mesmo

A lista numerada não é o escopo inteiro. Duas outras coisas pertencem a
este plano, e ficaram de fora da primeira versão dele por engano meu.

### Pendências já conhecidas

- **Ícone do aplicativo.** Ainda é o do Flutter, idêntico ao do modelo
- **Foto da criança como avatar.** O campo `photoDriveId` existe, nunca é
  gravado (o envio retorna antes do upload terminar) e nunca é lido
- **Ajuste visual** conforme a referência enviada no início do projeto
- **Itens da Play Store:** política de privacidade publicada, URL de
  exclusão de conta, alerta de orçamento no Firebase, App Check

### O que a régua da cápsula exige e o produto ainda não tem

- **Voz.** Os tipos são foto, vídeo, carta, desenho, documento e
  crescimento. Nenhum áudio. A voz é a primeira coisa que a memória perde
  e a mais densa que existe: trinta segundos da mãe dizendo "hoje você deu
  o primeiro passo" valem mais que duzentas fotos. O encanamento de upload
  já existe, então o custo é baixo e o retorno é o maior da lista inteira
- **Cápsula lacrada.** O aplicativo se chama Cápsula do Tempo e não tem
  cápsula. Carta hoje é texto com data. Falta lacrar algo com data de
  abertura ("abrir quando você fizer 18 anos"), que é o que transforma
  arquivo em presente
- **A cápsula pode morrer antes da criança.** O Google apaga contas
  inativas por 2 anos. Se esta conta parar de ser usada daqui a 8 anos, o
  acervo vai junto e a cápsula de 20 anos vira nada
- **O aplicativo é o elo mais frágil da corrente.** Em 25 anos o Flutter,
  o Firebase e o Android terão mudado. A cápsula precisa ser legível **sem
  o aplicativo**: uma exportação que gere pasta navegável com as mídias e
  um índice que abra em qualquer computador do futuro. Um produto de longo
  prazo precisa presumir a própria morte

---

## Fases

Sete já saíram. O compartilhamento familiar ficou para depois (seção
"Adiado", abaixo). O que resta se divide em duas listas:

**Agora, com o aplicativo ainda em teste:** a 10 inteira (a primeira
impressão de quem instala) e a 11 (mais de um filho). A 8a já está feita, a
8b foi descartada e a 10a está pronta.

**Quando você der o comando de publicar:** a 9 inteira. Ela é o que bloqueia
a submissão, e ficou para depois por escolha sua: assinar o pacote definitivo
só faz sentido quando o aplicativo estiver do jeito que você quer.

**Depois do lançamento:** a 12 (exportação) e a 13 (assinatura). As duas são
grandes, e nenhuma família perde nada por esperar por elas.

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
- Ligar os dois no aplicativo, na tela Sobre

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

#### 9d. A ficha da loja

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

#### 9e. Depois de estar no ar

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

#### 10c. O sistema de movimento

Movimento como sistema, não efeitos espalhados. O que entra:

- transição entre telas, com identidade própria
- **miniatura crescendo até virar a foto em tela cheia**, saindo do lugar
  exato onde estava. Num aplicativo de fotos é o ganho mais óbvio de todos
- cartões da linha do tempo entrando conforme a rolagem
- o botão + e a folha de adicionar subindo
- esqueleto do conteúdo no lugar da bolinha girando
- um instante de destaque quando aparece uma data redonda

O que **não** entra, por decisão tomada: texto aparecendo letra por letra.
Atrasa a leitura de quem está com o bebê no colo tentando ver uma foto com
uma mão só.

O ajuste de acessibilidade do Android que remove animações é respeitado.
Ignorá-lo é problema real para quem tem enxaqueca vestibular, e é uma linha
de código.

### Fase 11 - Mais de um filho

Um botão no canto superior direito do perfil para acrescentar outra criança,
e um jeito de trocar entre elas.

**É a maior mudança estrutural que sobrou**, e não parece. Hoje a cápsula é
uma só por conta: tudo vive em `users/{uid}`, com o cadastro num documento
fixo em `perfil/bebe`. Passar a ter várias significa:

- mover tudo para `users/{uid}/criancas/{id}/...`, com regras novas
- uma pasta raiz no Drive por criança
- **migrar quem já usa**, sem perder nada e sem pedir nada
- um seletor de criança ativa, e todo provedor de dados passando por ele
- os lembretes e as inspirações passam a ser por criança

O seletor de criança ativa é exatamente a mesma forma do
`capsuleOwnerProvider` que existiu para o compartilhamento familiar: um
ponto único por onde toda leitura passa. O desenho já foi provado uma vez.

Fica depois do lançamento por ser grande e por mexer em dado de gente que já
está usando. Migração malfeita aqui não é tela quebrada, é memória perdida.

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

*(Revisada depois da primeira entrega: o conteúdo era raso e as âncoras só
sabiam faixa de idade. Ver "O que mudou na revisão", abaixo.)*

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

### Fase 4 - Voz e cápsula lacrada ✅

**Voz.** Novo tipo de memória, gravado dentro do aplicativo, em AAC dentro
de contêiner MP4: toca em qualquer aparelho e em qualquer computador, hoje
e daqui a vinte anos. Formato exótico envelhece mal, e este acervo precisa
continuar legível. Limite de cinco minutos, para a gravação não rodar
esquecida no bolso.

Reprodução na própria linha do tempo, com o arquivo baixado só ao tocar:
um dia com dez áudios não baixa dez arquivos que ninguém pediu. Áudio não
passa pelo compressor, porque já sai comprimido.

**Uma mudança de política que precisa estar escrita.** O CI tinha uma
barreira dura recusando permissões perigosas, e `RECORD_AUDIO` estava
nela. Ela saiu de lá e entrou na lista fixa, com a razão registrada no
próprio workflow: as outras dão acesso ao acervo que já existe no aparelho
sem a pessoa escolher item por item; o microfone não lê nada que exista,
só abre enquanto ela está gravando, depois de apertar gravar. E não há
substituto: existe seletor de fotos do sistema, não existe seletor de voz.

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
