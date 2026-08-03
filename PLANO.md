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

## O bloqueio técnico do item 6

**Compartilhar a pasta no Drive não faz o aplicativo do familiar
conseguir ler os arquivos.**

O escopo é `drive.file`, que dá acesso apenas ao que *aquele aplicativo,
naquela conta*, criou. Quando o pai compartilha a pasta, o familiar passa
a ver o conteúdo em `drive.google.com`, mas o aplicativo instalado no
celular dele continua sem permissão: não foi ele quem criou aqueles
arquivos.

Isto não é um detalhe de implementação. É a diferença entre o item 6
funcionar e não funcionar.

As saídas possíveis:

| Caminho | O que custa |
|---|---|
| **Google Picker** (recomendado) | O familiar escolhe uma vez a pasta compartilhada. É o caminho oficial do Google para este caso exato, e serve de brinde como a validação "o Drive realmente foi compartilhado" que você já queria. Precisa de uma tela web embutida. |
| Ampliar o escopo do familiar para `drive.readonly` | O aplicativo passaria a poder ler o Drive inteiro da pessoa. É exatamente o risco que você levantou lá atrás e que o projeto foi construído para evitar. Descartado. |
| Link público (`anyoneWithLink`) | Fotos de criança acessíveis por quem tiver o link. Inaceitável. |

Recomendo o Picker. **Preciso confirmar na documentação se escolher uma
pasta cascateia o acesso para o conteúdo dela**, ou se o acesso é item a
item; isso muda o desenho da tela e eu não vou afirmar sem verificar.

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

## Fases

São seis, não três. A sua lista é grande e algumas partes dependem de
outras; espremer em três criaria fases que não compilam no meio. Cada uma
abaixo termina com o aplicativo compilando, testado e instalável.

A ordem é por retorno emocional dividido por risco. O compartilhamento
vai por último de propósito: é o único item que mexe em privacidade.

### Fase 1 - Identidade e linguagem

Base de tudo que vem depois. Sem isto, cada tela nova nasce com o problema.

- Paleta adaptável ao sexo via `ThemeExtension`, com as três famílias de
  cor (menina: lilás, rosa claro, pêssego; menino: azul, verde água,
  cinza) e a neutra para antes do cadastro
- Ícones e elementos decorativos acompanhando a paleta
- Helper de copy reescrito para usar o **nome da criança** por padrão
- Varredura de "sua bebê" / "seu bebê" e de toda frase que só funciona num
  dos sexos
- Revisão de estados vazios, títulos e rótulos

Arquivos: `core/theme/*`, `core/l10n/*`, e passagem mecânica pelos 61
arquivos que citam `AppColors`.

**Pronto quando:** trocar o sexo no cadastro muda o app inteiro, e não
sobra nenhuma frase de gênero fixo.

### Fase 2 - Home viva e timeline agrupada

O maior salto visual pelo menor custo.

- Home com saudação por horário, idade por extenso, cartões dinâmicos
  (hoje faz exatamente X, faltam N dias para o aniversário, última foto,
  última carta, último crescimento)
- Botão "Registrar momento" abrindo o BottomSheet que já existe
- Timeline agrupada por dia, com resumo e expansão

Arquivos: `features/home/*`, `features/timeline/*`, novos componentes
reutilizáveis.

**Pronto quando:** a Home responde "como está a Maria hoje" sem rolar a
tela, e a timeline mostra o dia antes de mostrar os arquivos.

### Fase 3 - Momentos, eventos e checklists

Os itens 3, 4 e 7 são a mesma espinha: um catálogo de sugestões avaliado
contra a idade e a data. Feitos juntos, é um motor. Feitos separados, são
três motores parecidos.

- Catálogo declarativo de sugestões, fácil de estender sem tocar em lógica
- Momentos importantes (primeiro sorriso, primeira palavra, primeiros
  passos), sempre como sugestão, nunca assumindo que aconteceram
- Eventos por data (primeiro Natal, primeira Páscoa, primeiro aniversário)
- Checklists automáticos, com o do primeiro aniversário como primeiro caso

**Pronto quando:** acrescentar um momento novo é acrescentar uma linha ao
catálogo.

### Fase 4 - Aba Inspirações

- Nova aba na navegação inferior, no lugar da Busca
- Busca migra para a lupa no AppBar, sem perder nada
- Feed por faixa etária, conteúdo em asset local, atrás de uma interface
  de repositório que aceite um backend depois sem tocar na tela

**Pronto quando:** trocar o asset por uma chamada de rede é trocar uma
classe.

### Fase 5 - Notificações inteligentes

Reaproveita o motor de regras da Fase 3.

- Agendamento local, sem servidor
- Regras contextuais a partir dos dados existentes
- Linguagem afetiva com o nome da criança
- Tela de ajuste em Configurações, para ligar, desligar e escolher o tom

**Pronto quando:** acrescentar uma notificação nova é acrescentar uma
regra, e nada dispara sem a pessoa ter permitido.

### Fase 6 - Compartilhamento com familiares

A maior e a única que mexe em privacidade. Só começa com as duas perguntas
acima respondidas e o Picker confirmado.

- Escolha de papel no primeiro acesso
- Tela de convite: nome, email, compartilhamento da pasta, código de 48h
- Entrada por código, com validação tripla (código, email, acesso ao Drive)
- Timeline em modo leitura, sem nenhum caminho de escrita
- Regras do Firestore para o novo modelo, testadas no emulador como as
  atuais

**Pronto quando:** o familiar vê o que foi liberado e nada além, provado
por teste no emulador e não por inspeção de tela.

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

Nada ainda.
