# Como funciona a tradução

Guia para quem vai mexer no texto do aplicativo: acrescentar, mudar, remover
ou traduzir para uma língua nova.

O aplicativo fala seis línguas: **inglês, português, espanhol, francês,
alemão e italiano**, nessa ordem no seletor.

---

## A regra, em uma frase

**Nenhuma frase que a pessoa lê está escrita dentro de uma tela.** Toda ela
mora numa tabela de idioma, e a tela pede a frase à tabela.

Se você escrever `Text('Salvar')` dentro de um widget, o teste
`nenhum_texto_solto_test.dart` reprova a mudança antes de ela chegar ao
aplicativo. É de propósito: foi exatamente assim que o aplicativo passou
meses com metade das telas em português depois de já ter sido traduzido.

---

## Mapa: onde mora cada tipo de texto

| O que é | Onde mora | Como a tela pede |
|---|---|---|
| Texto de interface (botões, títulos, avisos, erros) | `lib/core/l10n/textos.dart` e as seis `textos_XX.dart` | `S.nomeDoTexto` |
| Frases que citam a criança pelo nome ou concordam com o sexo | `lib/core/l10n/copy.dart` e as seis `copy_XX.dart` | `Copy.of(profile).nomeDaFrase` |
| Postagens do blog | `assets/inspiracoes/<língua>/<id>.json` | carregadas por `InspirationSource` |
| Política de privacidade | `privacy_policy.dart` + `_en _es _fr _de _it` | telas e site |
| Termos de uso | `terms_of_use.dart` + `_en _es _fr _de _it` | telas e site |
| Exclusão de conta | `account_deletion.dart` + `_en _es _fr _de _it` | telas e site |
| Nomes das pastas no Google Drive | `lib/core/l10n/nomes_de_pasta.dart` | `NomesDePasta.de(codigo)` |
| Formato de data, hora e número | `S.padraoData`, `S.codigoIntl` e `lib/core/utils/formatters.dart` | `Fmt.date(...)` |
| Páginas públicas em HTML | `lib/core/l10n/pagina_web.dart` | geradas em `docs/` |

Uma regra prática para decidir entre as duas primeiras linhas: se a frase
**cita a criança**, é `Copy`; se não cita, é `S`.

---

## Como a língua é escolhida e aplicada

A corrente inteira tem cinco elos, e vale conhecê-los porque quase todo bug
de tradução é um deles fora do lugar.

1. **`lib/state/idioma_providers.dart`** guarda a escolha no aparelho
   (`SharedPreferences`, chave `idioma`). Quando ninguém escolheu ainda, vale
   a língua do próprio aparelho; uma língua que o aplicativo não oferece cai
   no português.

2. **`lib/app.dart`** observa essa escolha **na raiz** da árvore
   (`ref.watch(idiomaProvider)`) e chama `definirTextos(...)`.

   Observar na raiz é o que faz a troca aparecer na tela. `S` lê de uma
   variável global, e trocar uma global não avisa widget nenhum: sem esse
   `watch`, a tela continuaria com o texto já desenhado até alguém navegar
   para outro lugar.

3. **`lib/core/l10n/strings.dart`** guarda a implementação ativa e expõe
   `S`, `codigoAtivo` e `textosPara(codigo)`.

4. **`S`** devolve a classe da língua ativa. `S.appName` em português é
   `TextosPt.appName`, em alemão é `TextosDe.appName`.

5. **`Copy.of(profile)`** olha `codigoAtivo` e escolhe entre `CopyPt`,
   `CopyEn`, `CopyEs`, `CopyFr`, `CopyDe` e `CopyIt`.

O mesmo `idioma` também vai para o `MaterialApp` como `locale`, para o
calendário, o menu de recortar e colar e o leitor de tela do próprio Flutter
acompanharem. Um seletor de data em português dentro de uma tela em alemão
denuncia a tradução pela metade.

---

## A garantia: o compilador cobra

`textos.dart` é uma `abstract interface class` com **474 membros**, e cada
língua a implementa com `implements`:

```dart
class TextosEs implements Textos { ... }
```

`implements` obriga a classe a ter **todos** os membros. Acrescentar um
texto na interface e esquecer o italiano **não compila**. Isso não é uma
convenção que alguém precisa lembrar: é o compilador dizendo não.

`Copy` funciona igual, com `extends` e 20 membros abstratos.

É por isso que acrescentar uma língua é caro e acrescentar um texto é
barato: o custo de uma língua nova é 474 frases escritas uma vez, e o
compilador não deixa entregar pela metade.

---

## Receitas

### Acrescentar um texto novo (tela nova, botão novo, aviso novo)

1. Abra `lib/core/l10n/textos.dart` e declare o membro na interface:

   ```dart
   /// O botão que arquiva uma memória sem apagá-la.
   String get archiveLabel;
   ```

   Escreva o comentário quando o texto tiver alguma sutileza (onde aparece,
   por que essa palavra e não outra, limite de largura). O arquivo inteiro é
   escrito assim.

2. Rode a análise. Ela vai apontar **seis** erros, um por língua.

3. Implemente nos seis arquivos, em ordem alfabética de membro, junto dos
   vizinhos do mesmo assunto:

   ```dart
   // textos_pt.dart
   @override
   String get archiveLabel => 'Arquivar';

   // textos_en.dart
   @override
   String get archiveLabel => 'Archive';
   ```

4. Na tela, use `Text(S.archiveLabel)`.

**Texto com número ou nome dentro** vira função, não getter:

```dart
// na interface
String memoriasArquivadas(int quantas);

// no português
@override
String memoriasArquivadas(int quantas) =>
    quantas == 1 ? '1 memória arquivada' : '$quantas memórias arquivadas';
```

Monte a frase **inteira** dentro da língua. Não concatene um pedaço
traduzido com uma preposição fixa na tela: a ordem das palavras muda de
língua para língua, e foi assim que a caixa de envio ficou metade em
português depois de já traduzida.

### Mudar a redação de um texto que já existe

Procure o nome do membro nos seis arquivos e mude os seis. Se mudar só o
português, nada quebra e nada avisa: as outras cinco línguas continuam com a
redação velha, e isso é o tipo de coisa que só aparece quando alguém abre o
aplicativo em italiano.

Se a frase muda de **forma** (deixa de ter número, passa a ter o nome da
criança), mude a assinatura na interface primeiro: aí o compilador cobra as
seis.

### Remover um texto

Apague o membro da interface **e** as seis implementações. Deixar a
implementação sem a interface compila e vira peso morto; deixar a interface
sem a implementação não compila. Apague os dois lados.

### Acrescentar ou editar uma postagem do blog

O português na raiz de `assets/inspiracoes/` decide **quais** postagens
existem. Uma tradução sem original na raiz nunca é lida.

Para acrescentar uma postagem:

1. Crie `assets/inspiracoes/<id>.json` em português.
2. Crie o mesmo `<id>.json` nas cinco subpastas `en`, `es`, `fr`, `de`, `it`.

O formato:

```json
{
  "titulo": "...",
  "resumo": "...",
  "tipo": "foto",
  "quando": { "tipo": "idade", "deDias": 0, "ateDias": 150 },
  "registrar": "foto",
  "secoes": [
    { "titulo": "...", "texto": "..." },
    { "titulo": "...", "itens": ["...", "..."] }
  ]
}
```

**`tipo`, `registrar` e `quando` têm de ser iguais em todas as línguas, letra
por letra.** Eles decidem *quando* a postagem aparece na linha do tempo. Se
divergissem, a mesma postagem chegaria com idades diferentes conforme a
língua, e o catálogo deixaria de ser o mesmo produto. Só `titulo`, `resumo` e
os textos das seções são traduzidos.

O carregador cai no português quando falta uma tradução, em silêncio. Por
isso o teste `postagens_traduzidas_test.dart` confere que as seis línguas
têm exatamente os mesmos ids e a mesma forma.

### Mudar a política de privacidade, os termos ou a exclusão de conta

Estes têm um passo a mais, porque o mesmo texto vai para três lugares: o
aplicativo, os `.md` na raiz do repositório e as páginas em `docs/`.

1. Edite os seis arquivos (`privacy_policy.dart`, `privacy_policy_en.dart`,
   `_es`, `_fr`, `_de`, `_it`).
2. Alguém precisa regerar os arquivos com:

   ```
   dart run tool/gerar_politica.dart
   dart run tool/gerar_termos.dart
   dart run tool/gerar_exclusao.dart
   dart run tool/gerar_site.dart
   ```

Se o passo 2 for esquecido, `politica_test.dart`, `termos_test.dart` e
`exclusao_test.dart` reprovam: eles comparam o arquivo no disco com o que a
ferramenta geraria. Ou seja, a CI acusa em vez de deixar no ar uma política
diferente da que está no aplicativo.

### Acrescentar uma língua nova

Este é o trabalho grande. A ordem importa, porque cada passo faz o
compilador apontar o próximo.

1. **`lib/state/idioma_providers.dart`**: acrescente o valor no enum
   `Idioma`, com código, nome na própria língua e `Locale`. **A ordem
   declarada aqui é a ordem que a pessoa vê no seletor**, nas configurações
   e no cadastro: as duas telas percorrem `Idioma.values` direto.

2. **`lib/core/l10n/textos_XX.dart`**: crie a classe com
   `implements Textos` e implemente os 474 membros. O jeito mais seguro é
   copiar `textos_en.dart` inteiro e traduzir de cima a baixo, porque assim
   nenhum membro se perde no caminho.

3. **`lib/core/l10n/strings.dart`**: acrescente o import, a constante
   (`const Textos textosXx = TextosXx();`) e a entrada em `todasAsTextos`.

4. **`lib/core/l10n/copy_XX.dart`**: crie a classe com `extends Copy`,
   implemente os 20 membros, e acrescente o `case` em `Copy.para`.

5. **`lib/core/l10n/nomes_de_pasta.dart`**: acrescente a convenção de nomes
   de pasta e o `case` no método `de(codigo)`.

6. **Documentos jurídicos**: `privacy_policy_XX.dart`,
   `terms_of_use_XX.dart` e `account_deletion_XX.dart`.

7. **`lib/core/l10n/pagina_web.dart`**: a `_Moldura` da língua nova e as
   quatro funções de página; depois acrescente as quatro linhas em
   `tool/gerar_site.dart`.

8. **`assets/inspiracoes/XX/`**: as 46 postagens, e a linha da pasta no
   `pubspec.yaml`.

9. **Testes**: acrescente a língua na lista de `idiomas_novos_test.dart` e
   na constante `linguas` de `postagens_traduzidas_test.dart`.

Uma língua a mais é também um documento jurídico a mais para manter em dia
em cada revisão futura. Um texto legal desatualizado é pior que um idioma a
menos.

### Remover uma língua

Desfaça os nove passos acima, na ordem inversa, e apague os arquivos.

Um cuidado que não é óbvio: quem já criou a cápsula naquela língua tem
`idiomaDasPastas` gravado no perfil com aquele código, e as pastas no Drive
dessa pessoa continuam com aqueles nomes. `NomesDePasta.de(codigo)` cai no
português quando não reconhece o código, e aí a **busca de emergência** (a
que acha a pasta pelo nome quando o id se perde) passa a procurar o nome
errado. Não achar nada faz o aplicativo criar uma segunda cápsula ao lado da
primeira. Se uma língua sair, a convenção de pastas dela precisa **ficar**
em `nomes_de_pasta.dart`, mesmo sem aparecer no seletor.

---

## As guardas: o que quebra e o que aquilo quer dizer

Tudo isto roda na CI, no job **Análise e testes**.

| Teste | O que ele pega |
|---|---|
| `nenhum_texto_solto_test.dart` | Uma frase escrita direto num widget, em qualquer língua |
| `idiomas_novos_test.dart` | Tradução preguiçosa: a frase em português esquecida dentro do arquivo estrangeiro |
| `idioma_do_aplicativo_test.dart` | O mesmo, para português e inglês, com mais detalhe |
| `idioma_test.dart` | Os seis idiomas, na ordem do seletor, e a preferência guardada |
| `postagens_traduzidas_test.dart` | Postagem sem tradução, ou com gatilho divergente do português |
| `politica_test.dart`, `termos_test.dart`, `exclusao_test.dart` | Documento gerado desatualizado em relação ao texto do aplicativo |
| `periodo_test.dart`, `age_calculator_test.dart` | Idade e períodos voltando a ter português fixo dentro do cálculo |

**Como ler a lista de exceções.** `nenhum_texto_solto_test.dart` tem um mapa
`permitido` que hoje está **vazio**. Cada linha acrescentada ali é a promessa
de que aquele texto nunca chega aos olhos de quem usa o aplicativo em outra
língua, e esse é justamente o tipo de promessa que envelhece sem ninguém
perceber. Antes de acrescentar uma exceção, vale conferir se o texto não
deveria simplesmente ir para `S`.

---

## Armadilhas conhecidas

Todas estas já morderam este projeto pelo menos uma vez.

**`const` não convive com `S`.** `const Text(S.algo)` não compila, e é o
resultado certo: o valor depende de uma escolha feita em tempo de execução.
Onde o `const` sai, o widget continua idêntico e não custa nada.

**Campo de enum precisa de valor constante.** Um rótulo que depende da
língua não pode ser campo de enum, porque a constante congela a língua na
primeira leitura. Tem de ser getter, como em `lib/core/utils/periodo.dart`.

**Valor padrão de parâmetro também precisa ser constante.** Em vez de
`String rotulo = S.algo` (que não compila), declare `String? rotulo` e
resolva `rotulo ?? S.algo` dentro do corpo.

**Declarar uma pasta de assets no Flutter não alcança as subpastas dela.**
`assets/inspiracoes/` no `pubspec.yaml` não faz o Flutter enxergar
`assets/inspiracoes/it/`. Cada subpasta precisa da própria linha, e sem ela
a tradução some sem erro nenhum: todo mundo lê em português.

**Nome de pasta do Drive não é língua de interface.** A interface troca de
língua quando a pessoa quiser. As pastas do Drive não podem trocar: elas já
existem, já têm arquivos dentro, e a pessoa já as viu. A língua das pastas é
escolhida uma vez, quando a cápsula nasce, e fica gravada no perfil
(`idiomaDasPastas`). Quem criou em inglês continua com pastas em inglês para
sempre, mesmo lendo o aplicativo em português.

**Nome de arquivo não é texto de interface.** `Fmt` formata datas na língua
ativa, com uma exceção deliberada: o carimbo `yyyy-MM-dd_HHmmss` que nomeia
os arquivos no Drive continua fixo. Se a língua mudasse esse padrão, a mesma
pasta acabaria com dois jeitos de ordenar.

**Título gravado é conteúdo, não interface.** Os títulos semeados no
cadastro ("Nascimento", "Primeira foto") são gravados no índice na língua
escolhida e viram conteúdo do acervo a partir dali, como um título que a
pessoa tivesse digitado. Eles **não** se retraduzem quando a pessoa troca de
idioma, e isso é intencional: retraduzir seria reescrever o que alguém
escreveu.

---

## O que ainda não segue a língua

Lista honesta, para não procurar bug onde não há e para saber o que falta.

**`Informacoes.txt` está fixo em português.** O arquivo que fica na pasta da
cápsula no Drive (`lib/core/l10n/informacoes.dart`) escreve
`INFORMAÇÕES DA CRIANÇA`, `Nome:`, `Peso ao nascer:` e o resto em português,
em qualquer língua. Ele não usa `S` em lugar nenhum. É o arquivo que a
criança abre daqui a vinte anos sem o aplicativo, então o buraco é real e
não é pequeno. Corrigir significa fazê-lo receber a `NomesDePasta` (a língua
**da cápsula**, não a da interface, pelo mesmo motivo das pastas) e trocar os
rótulos por campos dela.

**O nome embaixo do ícone está fixo em "Meu Bebê".** Ele vem do
`android:label` no `AndroidManifest.xml`, e o Android só o traduz por
arquivos `res/values-XX/strings.xml`, que o projeto não tem. Traduzir o
rótulo do lançador é um trabalho de Android, não de Dart.

**As postagens não têm capa em nenhuma língua.** As imagens `<id>.webp` não
existem ainda. Quando existirem, elas são compartilhadas entre as seis
línguas, então isso não multiplica trabalho de tradução.
