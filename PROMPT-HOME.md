# Prompt para levar a outra IA

Copie tudo daqui para baixo.

---

Você é designer de produto e de interface, especialista em aplicativos
móveis. Quero que me ajude a redesenhar a tela inicial de um aplicativo que
já está construído e funcionando. Leia todo o contexto antes de responder.

## O produto

Chama-se **Meu Bebê: Cápsula do Tempo**. É um aplicativo em português do
Brasil, para Android, feito para os pais registrarem a infância de um filho.

**A regra que define tudo:** este aplicativo **não é um álbum de fotos**. É
uma cápsula do tempo digital. O objetivo é que daqui a 20 ou 30 anos a
própria criança abra o aplicativo e reviva a infância inteira. Cada criança
tem a própria conta do Google desde o primeiro dia, e um dia recebe essa
conta inteira, com login e senha. Os arquivos ficam no Google Drive da
criança; o aplicativo é só a porta de entrada e o índice.

Ou seja: há dois públicos, separados por décadas. Quem usa hoje são os pais.
Quem vai usar no fim é a criança adulta. Qualquer decisão de tela precisa
servir aos dois.

## O que o aplicativo já tem

Barra inferior com quatro abas e um botão "+" central:

1. **Início** (a tela que quero redesenhar)
2. **Linha do tempo**
3. **Inspirações** (um blog interno com textos sobre maternidade e infância)
4. **Perfil**

Há também um menu lateral com: Linha do tempo, Fotos, Vídeos, Cartas,
Desenhos, Documentos, Crescimento, Momentos, Guardado, Estatísticas,
Lixeira e Configurações.

O que se pode registrar: **foto, vídeo, carta, desenho, documento** (certidão,
carteira de vacinação) e **medição de crescimento** (peso e altura).

A **carta** é o item mais importante do produto: é uma mensagem escrita pelos
pais para a criança ler no futuro, e pode ser **lacrada** com uma data de
abertura (por exemplo, os 18 anos). É a única coisa que um álbum de fotos
comum não faz.

## A tela "Linha do tempo" (já pronta, e ficou boa)

Foi reformulada recentemente e agora resolve muito bem a navegação do acervo:

- Agrupa as memórias por período, com um menu no topo direito para escolher
  entre **Anos, Meses e Semanas**. Abre em Meses.
- Cada seção mostra o rótulo do período à esquerda ("Setembro de 2027") e a
  quantidade de itens à direita ("10 itens").
- Abaixo, as fotos e vídeos aparecem num **mosaico de linhas justificadas**,
  cada imagem com a própria proporção e tamanhos variados, no estilo do
  Google Fotos.
- Cartas, medições e documentos aparecem como cartões, porque não têm o que
  mostrar numa miniatura.
- Quando o período contém uma data redonda (1 ano, 8 meses), aparece um selo.
- Há um filtro por tipo de memória.

## A tela "Início" hoje, e o problema

Ela é uma lista vertical com, nesta ordem:

1. **Painel do topo:** saudação ("Boa tarde!"), a frase "Hoje a Maria está
   com" e a idade em destaque ("1 ano, 9 meses e 14 dias"), com a foto de
   perfil da criança ao lado.
2. **Cartões de ocasião:** aparecem só em dias especiais (data redonda,
   aniversário chegando). Na esmagadora maioria dos dias não aparecem.
3. **"Momentos para registrar":** uma sugestão contextual do tipo "que tal
   registrar as primeiras palavras?", com opção de dispensar.
4. **Faixa de envio:** aparece quando há upload em andamento ou que falhou.
5. **Seção "Acervo":** uma grade de 6 atalhos quadrados (Fotos, Vídeos,
   Cartas, Desenhos, Documentos, Crescimento).
6. **Seção "Fotos recentes":** uma grade de 6 miniaturas quadradas, com um
   botão "Ver todas".

**O problema que preciso resolver:** desde que a linha do tempo ficou boa, os
itens 5 e 6 viraram repetição.

- Os 6 atalhos do "Acervo" levam a lugares que o menu lateral já lista. São
  um terceiro caminho para o mesmo lugar.
- As "Fotos recentes" são uma versão pior da linha do tempo: 6 quadrados
  cortados, contra o mosaico com as proporções corretas que já existe a um
  toque de distância.

Quero remover os dois. **A questão é o que colocar no lugar**, para a tela
inicial deixar de ser um índice e passar a ter razão de existir ao lado da
linha do tempo.

## Dados que o aplicativo já tem em mãos (sem nada novo a construir)

Use isto como matéria-prima. Tudo abaixo já está calculado e disponível na
memória do aplicativo, sem custo de rede:

- Data de nascimento, nome, sexo e foto de perfil da criança
- A idade exata de hoje (anos, meses e dias)
- Se hoje é uma data redonda (1 ano, 8 meses, 3 semanas)
- Quantos dias faltam para o próximo aniversário, e qual aniversário é
- A data do último registro de cada tipo (última foto, última carta, etc.)
- A lista completa de memórias, cada uma com data, tipo, título, descrição e
  arquivos
- Quantas memórias existem de cada tipo
- Quanto do Google Drive está ocupado
- As cartas lacradas e a data em que cada uma abre
- Peso e altura ao longo do tempo, com gráfico já pronto

## Design System (respeite, não invente)

- Fonte: **Plus Jakarta Sans**
- Escala de texto: 34 / 28 / 24 (títulos grandes), 20 / 16 / 14 (títulos),
  16 / 14 / 12 (corpo), 13 / 12 (rótulos)
- Espaçamentos: múltiplos de 4, sendo 8, 12, 16, 20, 24 e 32 os mais usados.
  Margem lateral da página: 16.
- Raios: cartão 20, botão 18, campo 14, mídia 16, pílula infinita
- Sombras muito suaves, quase imperceptíveis
- Altura mínima de botão: 44 a 56

Paleta (versão menina; existem versões menino e neutra, com a mesma
estrutura e outros tons):

| papel | cor |
|---|---|
| fundo da tela | `#FCF3EE` (creme) |
| superfície de cartão | branco |
| superfície suave | `#F7EDF5` |
| primária | `#C87AA8` (rosa) |
| primária escura | `#B56696` |
| primária suave | `#F1DFEC` |
| acento | `#9B87C4` (lilás) |
| acento suave | `#EDE4F5` |
| painel do topo | `#C893AC` |
| texto sobre o painel | `#32292E` |
| texto principal | `#32292E` |
| texto secundário | `#6D6468` |
| borda | `#EADBE5` |

O tom geral é **acolhedor, calmo e adulto**. Nada infantilizado, nada de
desenhos de ursinho, nada de cores saturadas.

## O que já foi tentado e recusado

Estas cinco ideias foram desenhadas e **não agradaram**. Não as repita:

1. **"Neste dia":** mostrar a foto do mesmo dia em anos anteriores
2. **Contagem regressiva do lacre:** "faltam 5.938 dias para ela abrir sua
   carta", com barra de progresso
3. **Régua da vida até os 18 anos:** uma barra do nascimento aos 18 com a
   posição de hoje
4. **"O que falta":** "ela vai receber 340 fotos e nenhuma carta", com um
   botão para escrever a primeira
5. **Frase para a criança:** "quando você abrir isto, vai encontrar 1.204
   fotos, 18 cartas e 3 anos de história"

Preciso de caminhos diferentes destes.

## O que eu quero que você entregue

**Primeiro**, uma análise curta: na sua leitura, qual é o verdadeiro papel de
uma tela inicial num aplicativo cuja navegação de acervo já está resolvida
por outra aba? O que faria alguém abrir este aplicativo num dia em que não
tem nada para guardar?

**Depois, e é o principal: crie 5 layouts completos e diferentes entre si
para a mesma tela inicial.** Não são 5 blocos soltos: são 5 versões inteiras
da tela, cada uma com uma aposta diferente sobre o que a Home é.

Para cada layout, entregue:

1. **Um nome e a aposta em uma frase** (o que essa versão acredita que a Home
   deve ser)
2. **A tela de cima para baixo**, bloco por bloco, na ordem, dizendo para
   cada bloco: o que mostra, de onde vem o dado, que tamanho ocupa e o que
   acontece ao tocar
3. **Os textos reais em português do Brasil**, escritos como apareceriam na
   tela, e não descritos. Nada de "aqui vai uma mensagem motivacional".
4. **O estado vazio:** como essa tela fica no primeiro dia de uso, com um
   recém-nascido e nenhuma memória guardada. Este ponto é obrigatório: várias
   ideias boas desmoronam aqui.
5. **Um desenho em ASCII ou em blocos** representando o layout na vertical,
   numa tela de celular
6. **O ponto fraco honesto** dessa versão

**Por fim**, diga qual das 5 você escolheria e por quê, e o que você
descartaria de primeira.

### Regras

- Português do Brasil em todos os textos de interface
- **Nunca use travessão (o caractere "—") em texto nenhum.** Use vírgula,
  dois-pontos ou reescreva a frase.
- Nada que exija servidor novo, inteligência artificial, rede social,
  compartilhamento público ou dado que o aplicativo não tenha
- Nada de gamificação com pontos, medalhas, ofensivas ou sequências diárias
- Considere que quem abre o aplicativo é uma pessoa cansada, muitas vezes
  segurando um bebê com a outra mão
