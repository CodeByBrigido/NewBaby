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

## O desenho do compartilhamento (item 6)

O modelo mental é o do próprio Drive, e está certo: o pai compartilha a
pasta `Meu Bebê - Cápsula do Tempo` como leitor com um email específico, o
código de 48 horas amarra o convite àquele email, e o familiar precisa das
duas coisas para entrar.

Só um passo não fecha sozinho.

**O aplicativo do familiar não consegue ler a pasta só porque ela foi
compartilhada.** O escopo `drive.file` dá acesso ao que *aquele
aplicativo, naquela conta*, criou. A pasta foi criada pelo aplicativo na
conta do pai. Para o aplicativo do familiar, aquilo é arquivo de estranho,
mesmo aparecendo no Drive dele.

Para o aplicativo achar a pasta sozinho, ele precisaria poder listar o
Drive do familiar. Aí passaria a poder ler tudo que a pessoa tem, que é
exatamente o risco que este projeto foi construído para evitar.

**A saída é o familiar apontar a pasta uma vez**, pelo Google Picker: uma
tela, um toque, "escolha a pasta que foi compartilhada com você". Dali em
diante o aplicativo alcança aquela pasta e nada mais, garantido pelo
Google e não por promessa nossa.

Esse toque não é fricção, é a prova. Ele é o consentimento explícito e é
também a validação "o Drive foi mesmo compartilhado" que o fluxo já pedia.
As duas coisas viram uma.

### O que isso destrava, e o que não trava

Timeline, datas, tipos e gráfico de crescimento moram no **Firestore**,
não no Drive. Só as fotos e os vídeos em si estão no Drive.

Então o aplicativo do familiar mostra a linha do tempo e o crescimento
**antes** de ele apontar a pasta. O Picker destrava só as imagens. Quem
nunca fizer esse passo não fica com um aplicativo quebrado, fica com um
aplicativo sem foto.

Isso também define a ordem de construção: o modo leitura funciona primeiro,
o Picker entra depois.

### Descartados, e por quê

| Caminho | Motivo |
|---|---|
| Ampliar o escopo do familiar para `drive.readonly` | Devolveria ao aplicativo o Drive inteiro da pessoa |
| Link público (`anyoneWithLink`) | Foto de criança acessível por quem tiver o link |
| Espelhar as mídias no Firebase Storage | Novo armazenamento, novo custo, e contraria o Drive como fonte única |

**A confirmar antes de codificar:** se escolher uma pasta no Picker
cascateia o acesso para o conteúdo dela ou se é item a item. Muda o
desenho da tela e não vou afirmar sem verificar.

### Duas perguntas do item 6 que ainda não têm resposta

1. **"Pai: controle total. Mãe: controle total."** Hoje é uma conta, um
   Drive, uma cápsula. Dois responsáveis com controle total é
   co-propriedade, problema diferente (e maior) do que familiar somente
   leitura. Os dois escrevem na mesma pasta do Drive de quem? O que
   acontece se um deles apagar a conta?
2. **Compartilhamento granular.** Você marcou fotos, vídeos e crescimento;
   cartas e documentos ficam de fora. Isso é regra fixa do produto ou o
   pai escolhe caso a caso? A regra do Firestore fica diferente em cada
   caso.

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

São nove. A lista é grande, algumas partes dependem de outras, e espremer
em três criaria fases que não compilam no meio. Cada uma abaixo termina
com o aplicativo compilando, testado e instalável.

A ordem é por retorno emocional dividido por risco. O compartilhamento vai
tarde de propósito: é o único item que mexe em privacidade.

### Fase 4 - Voz e cápsula lacrada

Não estava na lista numerada. É a fase de maior retorno emocional do plano
inteiro, e a que mais responde à régua dos 20 anos.

- Novo tipo de memória: **áudio**, com gravação dentro do aplicativo
- Reprodução na timeline, sem sair para outro aplicativo
- **Lacre com data de abertura** em cartas, vídeos e áudios: guardado
  agora, abre no aniversário de 15, de 18, ou na data que a pessoa
  escolher
- Tela que mostra o que está lacrado sem revelar o conteúdo, porque a
  espera faz parte do presente

O encanamento de upload, otimização e organização por idade já existe;
áudio entra como mais um `EntryType`.

**Pronto quando:** dá para gravar a voz da mãe e lacrar para 2044.

### Fase 5 - Aba Inspirações

- Nova aba na navegação inferior, no lugar da Busca
- Busca migra para a lupa no AppBar, sem perder nada
- Feed por faixa etária, conteúdo em asset local, atrás de uma interface
  de repositório que aceite um backend depois sem tocar na tela

**Pronto quando:** trocar o asset por uma chamada de rede é trocar uma
classe.

### Fase 6 - Notificações inteligentes

Reaproveita o motor de regras da Fase 3.

- Agendamento local, sem servidor
- Regras contextuais a partir dos dados existentes
- Linguagem afetiva com o nome da criança
- Tela de ajuste em Configurações, para ligar, desligar e escolher o tom

**Pronto quando:** acrescentar uma notificação nova é acrescentar uma
regra, e nada dispara sem a pessoa ter permitido.

### Fase 7 - Compartilhamento com familiares

A maior e a única que mexe em privacidade. Só começa com as duas perguntas
acima respondidas e o comportamento do Picker confirmado.

Construída em duas metades, porque a primeira já entrega valor sozinha:

**7a, sem Drive.** Escolha de papel no primeiro acesso; tela de convite
(nome, email, compartilhamento da pasta, código de 48h); entrada por
código com validação de código e email; timeline e crescimento em modo
leitura, sem nenhum caminho de escrita; regras do Firestore para o novo
modelo, testadas no emulador como as atuais.

**7b, com Drive.** Google Picker para o familiar apontar a pasta
compartilhada, destravando as fotos e os vídeos, e a validação de que o
compartilhamento realmente aconteceu.

**Pronto quando:** o familiar vê o que foi liberado e nada além, provado
por teste no emulador e não por inspeção de tela.

### Fase 8 - Longevidade

A fase que quase nenhum aplicativo faz e que este precisa fazer, porque o
horizonte dele é de décadas.

- **Exportação legível sem o aplicativo:** pasta navegável com as mídias e
  um índice que abra em qualquer computador, hoje ou em 2051
- **Aviso de conta inativa:** o Google apaga contas sem uso por 2 anos.
  Quem guarda uma cápsula de 20 anos precisa saber disso e ser lembrado
- Instruções de herança: como a criança recebe a cápsula quando crescer

**Pronto quando:** dá para entregar a cápsula inteira a alguém que nunca
ouviu falar deste aplicativo.

### Fase 9 - Publicação na Play Store

- Política de privacidade publicada e acessível
- URL de exclusão de conta exigida pela loja
- Alerta de orçamento no Firebase
- App Check
- Ficha da loja, capturas de tela, classificação

**Pronto quando:** o aplicativo passa na revisão da Play Store.

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

## Concluído

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
