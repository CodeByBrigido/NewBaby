# Meu Bebê

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
a pasta `Meu Bebê/` no Drive dela. As fotos nunca passam por servidor de
terceiros, e o armazenamento pesado não custa nada para quem publica o app.

Essa separação é o que faz o aplicativo abrir instantâneo: a linha do tempo
e a busca leem o cache local do Firestore, sem nunca varrer a árvore de
pastas do Drive. O Drive é o arquivo permanente — e continua legível por
gente, sem o aplicativo.

```
Meu Bebê/
├── Fotos/
│   ├── Semana 01 · Semana 02 · … · Semana 52
│   ├── Mês 13 · Mês 14 · … · Mês 24
│   └── Ano 2 · Ano 3 · …
├── Vídeos/          (mesma estrutura por idade)
├── Cartas/
├── Desenhos/
├── Documentos/
└── Crescimento/
```

As pastas de idade nascem sob demanda, no primeiro conteúdo daquela idade —
criar mais de cem pastas no primeiro acesso deixaria o cadastro lento sem
necessidade.

---

## Decisões que moldam o aplicativo

**Envio otimista.** A memória aparece na linha do tempo *antes* de o upload
terminar, com a miniatura local. A compressão e o envio acontecem em segundo
plano. É por isso que guardar uma foto parece instantâneo mesmo com internet
ruim.

**Otimização automática, sem perguntar nada.** Foto vai a metade da
resolução; vídeo vai sempre a 720p. O original nunca sai do celular e o
arquivo temporário é apagado depois do envio. Não há botão de qualidade —
essa escolha já foi feita, e é o que mantém o acervo leve por décadas.

**Busca em memória.** Um acervo familiar tem milhares de itens, não milhões.
Filtrar em memória sobre o cache do Firestore devolve resultado enquanto a
pessoa digita, sem índice externo.

**`drive.file` e nada mais.** O aplicativo só enxerga o que ele mesmo criou.
Não é um escopo sensível, então o Google não exige verificação do app.

**Nada passa por servidor nosso.** As fotos vão do celular direto para o
Google Drive.

---

## Idade: o coração do aplicativo

Tudo — o nome da pasta, o rótulo na linha do tempo, o agrupamento das
galerias — sai de `lib/core/utils/age_calculator.dart`.

| Idade | Rótulo | Pasta |
|---|---|---|
| dia do nascimento | Recém-nascida | `Semana 01` |
| 22 dias | 22 dias | `Semana 04` |
| 2 meses e 11 dias | 2 meses e 11 dias | `Semana 11` |
| 1 ano | 1 ano | `Mês 13` |
| 1 ano e 2 meses | 1 ano e 2 meses | `Mês 15` |
| 2 anos | 2 anos | `Ano 2` |

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
test/              idade, formatação, modelos e linha do tempo
```

---

## Quero instalar no celular

O caminho sem instalar nada no computador: o GitHub compila e você baixa o
APK. O passo a passo está em **[INSTALAR.md](INSTALAR.md)**.

## Quero publicar na Google Play

O guia completo — OAuth em produção, chave de assinatura, política de
privacidade e ficha da loja — está em **[PUBLICAR.md](PUBLICAR.md)**.

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
