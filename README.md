# Meu Bebê: Cápsula do Tempo

> Cada momento, uma lembrança para a vida toda.

Uma cápsula digital da vida de uma criança: fotos, vídeos, cartas, desenhos,
documentos e registros de crescimento, organizados automaticamente por idade
e apresentados como uma linha do tempo.

O objetivo não é ser um gerenciador de arquivos. É passar a sensação de
folhear a história de uma vida.

Aplicativo Flutter para Android e iOS, inteiramente em português.

---

## Como funciona

**Os arquivos ficam no Google Drive de cada família. Os metadados ficam no
Cloud Firestore.**

Cada pessoa que instala entra com a própria conta Google e o aplicativo cria
a pasta `Meu Bebê - Cápsula do Tempo/` no Drive dela. As fotos nunca passam por servidor de
terceiros, e o armazenamento pesado não custa nada para quem publica o app.

Essa separação é o que faz o aplicativo abrir instantâneo: a linha do tempo
e a busca leem o cache local do Firestore, sem nunca varrer a árvore de
pastas do Drive. O Drive é o arquivo permanente - e continua legível por
gente, sem o aplicativo.

```
Meu Bebê - Cápsula do Tempo/
├── Fotos/
│   ├── Ano 0/        Mês 00 · Mês 01 · … · Mês 11
│   ├── Ano 1/        Mês 00 · Mês 01 · … · Mês 11
│   └── Ano 2/ …
├── Vídeos/          (mesma estrutura por idade)
├── Cartas/          (mesma estrutura por idade)
├── Desenhos/
├── Documentos/
├── Crescimento/
└── Informacoes.txt
```

O ano é a gaveta que alguém abre primeiro, e o mês reinicia dentro dela:
`Ano 1 / Mês 03` se lê "1 ano e 3 meses", que é como a idade de uma criança
é dita em voz alta. `Mês 00` é o primeiro mês de vida, antes de completar um
mês.

As pastas de idade nascem sob demanda, no primeiro conteúdo daquela idade -
criar mais de sessenta pastas no primeiro acesso deixaria o cadastro lento
sem necessidade. E somem quando esvaziam: tirar a última mídia de um período
leva junto a pasta dele, porque uma pasta que existe precisa significar que
há algo dentro.

**Duas convenções, dois públicos.** Dentro do aplicativo a galeria continua
em `Semana 07` e `Mês 14`: quem registra hoje pensa em semanas. Quem abre a
pasta daqui a vinte anos pensa em anos, e é essa pessoa que a estrutura do
Drive atende.

O acervo guardado antes desta organização (`Fotos/Semana 07`) muda de lugar
sozinho na abertura seguinte. Move, não copia: no Drive a pasta é uma
propriedade do arquivo, então o id continua o mesmo e nada sobe de novo.

---

## Decisões que moldam o aplicativo

**Envio otimista.** A memória aparece na linha do tempo *antes* de o upload
terminar, com a miniatura local. A compressão e o envio acontecem em segundo
plano. É por isso que guardar uma foto parece instantâneo mesmo com internet
ruim.

**Otimização automática, sem perguntar nada.** Foto vai a metade da
resolução; vídeo vai sempre a 720p. O original nunca sai do celular e o
arquivo temporário é apagado depois do envio. Não há botão de qualidade -
essa escolha já foi feita, e é o que mantém o acervo leve por décadas.

**Busca em memória.** Um acervo familiar tem milhares de itens, não milhões.
Filtrar em memória sobre o cache do Firestore devolve resultado enquanto a
pessoa digita, sem índice externo.

**`drive.file` e nada mais, dentro de uma pasta só.** Esta é a garantia
central do projeto, e vale explicá-la inteira:

O aplicativo pede um único escopo OAuth, `drive.file`, que dá acesso **por
arquivo, apenas ao que o próprio aplicativo criou**. As outras pastas da
conta são invisíveis daqui: não aparecem em listagem nenhuma, e um
`files.get` no id de uma delas responde 404. Isso não é uma escolha do
código - é o que o Google impõe no servidor, porque o token que o aplicativo
recebe não carrega permissão para o resto do Drive.

Por isso, também, **nada no código consulta a raiz do Drive**. O id da pasta
da cápsula fica guardado no Firestore e é reaproveitado; quando falta, a
pasta é criada, nunca procurada. Há um teste que falha o CI se alguém
acrescentar um escopo ou uma busca na raiz.

Uma consequência a saber: se a pessoa já tiver, feita à mão, uma pasta com o
mesmo nome, o aplicativo não a enxerga e cria a sua.

Como `drive.file` não é um escopo sensível, o Google não exige a verificação
pesada do app.

**Os arquivos não passam por servidor nosso - o índice passa.** As fotos vão
do celular direto para o Google Drive. Mas o índice (nome, data de nascimento,
peso, altura, datas e o **texto das cartas**) fica no Firestore de quem
publica o aplicativo, em texto puro. As regras isolam uma família da outra;
não escondem nada de quem é dono do projeto. Isso está dito na tela Sobre, e
precisa estar na política de privacidade.

**Sem EXIF.** As fotos sobem sem o bloco de metadados - o que descarta as
coordenadas de GPS de onde cada foto foi tirada. A orientação é corrigida
antes, então nada muda visualmente.

**Trava opcional, desligada por padrão.** Quem quiser pede a digital, o
rosto ou o PIN do aparelho para abrir o app, em Configurações. Vem desligada
porque num aplicativo de família a trava obrigatória irrita mais do que
protege. Escolher uma foto ou compartilhar leva o app para segundo plano sem
que a pessoa tenha saído: essas passagens são marcadas para a trava não
disparar no meio da tarefa.

**Dá para apagar tudo.** Perfil → *Apagar minha conta e meus dados* remove o
índice do servidor, revoga o acesso ao Drive e encerra a conta, com a opção de
manter ou não os arquivos no Drive. Sair, sozinho, já apaga miniaturas,
downloads e o cache local.

---

## Idade: o coração do aplicativo

Tudo - o nome da pasta, o rótulo na linha do tempo, o agrupamento das
galerias - sai de `lib/core/utils/age_calculator.dart`.

| Idade | Rótulo | Galeria | Pasta no Drive |
|---|---|---|---|
| dia do nascimento | Recém-nascida | `Semana 01` | `Ano 0 / Mês 00` |
| 22 dias | 22 dias | `Semana 04` | `Ano 0 / Mês 00` |
| 2 meses e 11 dias | 2 meses e 11 dias | `Semana 11` | `Ano 0 / Mês 02` |
| 1 ano | 1 ano | `Mês 13` | `Ano 1 / Mês 00` |
| 1 ano e 2 meses | 1 ano e 2 meses | `Mês 15` | `Ano 1 / Mês 02` |
| 2 anos | 2 anos | `Ano 2` | `Ano 2 / Mês 00` |

Os meses são de calendário, não blocos de 30 dias: quem nasce em 31/01
completa um mês em 28/02. Há testes cobrindo anos bissextos, viradas de mês
e uma varredura dia a dia dos três primeiros anos.

---

## Estrutura

```
lib/
├── core/          tema, textos em português, cálculo de idade, formatação, rotas
├── models/        BabyProfile, Entry, EntryFile, GrowthData
├── services/      auth · Drive · Firestore · otimização de mídia · miniaturas
│                  memory_repository.dart orquestra tudo
├── state/         providers do Riverpod
└── features/      uma pasta por tela
firebase/          regras e índices do Firestore
  teste/           regras rodando contra o emulador oficial
test/              idade, formatação, modelos, privacidade e linha do tempo
```

---

## Quero instalar no celular

O caminho sem instalar nada no computador: o GitHub compila e você baixa o
APK. O passo a passo está em **[INSTALAR.md](INSTALAR.md)**.

## Quero mexer no texto do aplicativo

O aplicativo fala seis línguas, e nenhuma frase está escrita dentro de uma
tela. Onde cada texto mora, como acrescentar um, e o que quebra quando algo
fica para trás está em **[TRADUZIR.md](TRADUZIR.md)**.

## Quero publicar na Google Play

O guia completo - OAuth em produção, chave de assinatura, política de
privacidade e ficha da loja - está em **[PUBLICAR.md](PUBLICAR.md)**.

## Rodando

O aplicativo precisa de um projeto Firebase e de credenciais OAuth para
funcionar. O passo a passo completo está em **[SETUP.md](SETUP.md)**.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

---

## Stack

Flutter · Riverpod · go_router · Firebase Auth · Cloud Firestore ·
Google Sign-In · Google Drive API · fl_chart
