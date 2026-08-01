# Instalar o Meu Bebê no celular

O que está neste repositório é **código-fonte**, não um aplicativo pronto.
Alguém precisa compilar. Este guia faz o GitHub compilar para você - sem
instalar Flutter, Android Studio nem nada no seu computador.

**Você vai precisar de:** uma conta Google, um celular Android e cerca de
meia hora, quase toda no passo 0.

---

## Antes de tudo: o passo que ninguém pula

O aplicativo **não funciona** sem um projeto Firebase e credenciais OAuth
registrados em seu nome - a *identidade do aplicativo*, não a conta de
ninguém da família. Nenhum APK resolve isso: sem essa configuração o app
abre, mostra a tela de login e falha ali.

👉 **Faça o [SETUP.md](SETUP.md) primeiro.** Ele leva você até ter três
arquivos gerados:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist` (só se um dia for usar iPhone)

Volte aqui quando tiver os dois primeiros.

---

## Passo 1 - guardar a configuração no GitHub

Os arquivos acima ficam fora do repositório de propósito: eles identificam
o **seu** projeto. Vamos guardá-los como **segredos**, que ninguém vê e que
não são expostos nem em repositório público.

Na pasta do projeto, no seu computador, rode:

```bash
base64 -w0 android/app/google-services.json ; echo
base64 -w0 lib/firebase_options.dart        ; echo
```

> No macOS o `base64` não tem `-w0`. Use `base64 -i arquivo` no lugar.

Cada comando cospe uma linha comprida de letras e números. Agora:

1. Abra **Settings → Secrets and variables → Actions** no repositório.
2. Clique em **New repository secret**.
3. Crie os dois, colando a linha correspondente:

| Nome do segredo | O que colar |
|---|---|
| `GOOGLE_SERVICES_JSON` | a saída do primeiro comando |
| `FIREBASE_OPTIONS_DART` | a saída do segundo comando |

O nome tem que ser exatamente esse, em maiúsculas.

---

## Passo 2 - mandar o GitHub gerar o APK

1. Vá na aba **Actions** do repositório.
2. Na lista da esquerda, escolha **Android**.
3. Clique em **Run workflow** → **Run workflow**.

Leva uns cinco minutos. Quando terminar com um ✅, abra a execução e role
até o fim: em **Artifacts** vai estar **`meu-bebe-apk`**. Baixe - vem um
`.zip` com três arquivos:

| Arquivo | Para quem |
|---|---|
| **`app-arm64-v8a-release.apk`** | **é este.** Praticamente todo celular dos últimos dez anos |
| `app-armeabi-v7a-release.apk` | aparelhos bem antigos |
| `app-x86_64-release.apk` | emuladores |

Na dúvida, pegue o **arm64-v8a**. Se ele não instalar, tente o armeabi-v7a.

---

## Passo 3 - instalar no celular

1. Mande o APK para o celular (WhatsApp para você mesmo, Drive, cabo - tanto faz).
2. Toque no arquivo.
3. O Android vai avisar que não instala apps de "fontes desconhecidas".
   Toque em **Configurações**, ligue a permissão para o app que está
   abrindo o arquivo (Arquivos, Chrome, WhatsApp...), e volte.
4. **Instalar**.

O aviso é normal: ele aparece para qualquer app que não venha da Play
Store. Você está instalando algo que você mesmo mandou compilar.

Abra o app, entre com a sua conta Google, autorize o acesso ao Drive e
preencha o cadastro - nome, se é menino ou menina, data de nascimento.
Pronto.

A pasta `Cápsula do Tempo - Meu Bebê/` é criada no Drive da conta que fez login. Quem instalar
depois, com outra conta, terá a própria pasta e a própria linha do tempo.

---

## Atualizar depois

Rode o workflow de novo e instale o novo APK por cima do antigo. **Nada se
perde**: as fotos estão no Google Drive e a linha do tempo no Firestore -
o celular não guarda nada que não possa ser baixado de novo.

Só não desinstale para reinstalar; instalar por cima preserva a sessão.

---

## Quando quiser marcar uma versão

Em vez de rodar na mão, crie uma tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

O GitHub gera os APKs e cria um **Release** com eles anexados. Fica mais
fácil de achar depois - e dá para mandar o link para a mãe instalar no
celular dela.

---

## E o iPhone?

Aqui a resposta é desconfortável, e é melhor ser direto: **hoje não há
caminho instalável.** A Apple não permite instalar um aplicativo sem que
ele seja assinado por um desenvolvedor registrado. Isso não é limitação
deste projeto - é como o iOS funciona.

As duas saídas reais:

| Caminho | Custo | Como é na prática |
|---|---|---|
| **Apple Developer Program + TestFlight** | US$ 99/ano | O melhor. Instala pelo ar, cada build vale 90 dias, dá para adicionar a mãe como testadora. Funciona **mesmo sem Mac**: este repositório é público, então os runners macOS do GitHub são gratuitos |
| **Mac + Apple ID gratuito** | grátis, mas exige um Mac | Instala pelo Xcode com o iPhone no cabo. **O app para de abrir a cada 7 dias** e precisa ser reinstalado. Serve para experimentar, não para o dia a dia |

O código iOS já está escrito e o workflow **iOS** confere a cada mudança na
`main` que ele continua compilando - para que, no dia em que você decidir
investir, não haja meses de quebra acumulada.

---

## Quando algo dá errado

**O workflow falha dizendo "Falta o segredo..."**
Os segredos do passo 1 não foram criados, ou o nome está diferente.
Confira maiúsculas e se não sobrou espaço no início.

**Falha em "Restaurar a configuração real do Firebase"**
O base64 foi copiado pela metade. Ele é uma linha só, bem comprida - copie
tudo, sem quebra de linha.

**Falha dizendo que o `serverClientId` ainda é placeholder**
Você rodou o `flutterfire configure` mas não colou o Client ID **Web** no
`lib/firebase_options.dart`. É o passo 6.3 do SETUP.md, e sem ele o login
falha no Android. Corrija o arquivo, gere o base64 de novo e atualize o
segredo.

**"App não instalado" no celular**
Quase sempre é o APK da arquitetura errada. Tente o `armeabi-v7a`. Se você
já tinha uma versão instalada assinada com outra chave, desinstale antes.

**O app instala mas trava no login**
A configuração do OAuth está incompleta. O erro `ApiException: 10` significa
SHA-1 errado - veja "Problemas comuns" no SETUP.md.

---

## E a Play Store?

Dá para publicar, e aí qualquer família instala como qualquer outro
aplicativo - cada uma entrando com a própria conta Google. O passo a passo
está em **[PUBLICAR.md](PUBLICAR.md)**: conta de desenvolvedor (US$ 25, uma
vez só), chave de assinatura, tela de consentimento em produção e política
de privacidade.

Para instalar em dois ou três celulares da mesma família, o APK direto
continua sendo mais simples e resolve igual.
