# Configuração do Meu Bebê

Este guia deixa o aplicativo rodando no celular. Leva cerca de trinta
minutos e só precisa ser feito uma vez.

## Primeiro, o que este guia NÃO pede

Ele **não** pede a conta nem o Google Drive de ninguém da sua família.

O que você vai criar aqui é a **identidade do aplicativo**: um projeto
Firebase e credenciais OAuth registrados em **seu nome, como
desenvolvedor**. É o crachá que o Google exige para deixar o app pedir
login — mais parecido com o CNPJ da empresa do que com o CPF do cliente.

Como esse crachá vai compilado dentro do APK, ele precisa existir **antes**
de compilar. Sem ele, o Google recusa qualquer tentativa de login.

Quem instalar o aplicativo entra com a **própria** conta Google, e as fotos
vão para o Drive **dessa pessoa**. Você nunca as vê: seu projeto guarda
apenas o índice (títulos, datas, peso, altura e os ids dos arquivos).

Para publicar na Google Play, veja também o **[PUBLICAR.md](PUBLICAR.md)**.

---

## 1. Instalar as ferramentas

```bash
# Flutter 3.44 ou superior
flutter --version

# CLI do Firebase
npm install -g firebase-tools
firebase login

# CLI do FlutterFire
dart pub global activate flutterfire_cli
```

---

## 2. Criar o projeto Firebase

1. Abra <https://console.firebase.google.com> entrando com a **sua** conta
   de desenvolvedor. É o projeto do aplicativo, não o acervo de ninguém.
2. Crie um projeto (por exemplo `meu-bebe`). Pode desativar o Google Analytics.
3. Em **Criação → Firestore Database**, clique em *Criar banco de dados*.
   Escolha o modo de produção e a região `southamerica-east1` (São Paulo).
4. Em **Criação → Authentication → Sign-in method**, ative o provedor
   **Google**.

O plano gratuito (Spark) dá conta com folga: o Firestore guarda só
metadados — nenhuma foto passa por ele.

---

## 3. Gerar a configuração do Flutter

Na raiz do projeto:

```bash
flutterfire configure --project=meu-bebe
```

Marque **android** e **ios**. O comando sobrescreve:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Os dois últimos estão no `.gitignore` de propósito. Os arquivos
`.example` ao lado deles mostram o formato esperado.

---

## 4. Ativar a Google Drive API

1. Abra <https://console.cloud.google.com> no mesmo projeto.
2. **APIs e serviços → Biblioteca** → procure **Google Drive API** → *Ativar*.

---

## 5. Configurar a tela de consentimento OAuth

Em **APIs e serviços → Tela de permissão OAuth**:

- Tipo de usuário: **Externo**
- Nome do app: `Meu Bebê`
- E-mail de suporte e de contato: o **seu**
- Em **Escopos**, adicione:
  `https://www.googleapis.com/auth/drive.file`
- Em **Usuários de teste**, adicione os e-mails que vão testar.

> Enquanto a tela estiver em "Teste", **só os e-mails cadastrados aqui
> conseguem entrar** (limite de 100). Para abrir ao público da loja é
> preciso publicar a tela em produção — veja o
> [PUBLICAR.md](PUBLICAR.md).

> `drive.file` dá acesso **apenas** aos arquivos que o próprio aplicativo
> cria — é o escopo mais estreito do Drive, escolhido justamente por ser o
> que o Google recomenda para evitar a revisão pesada. Com os usuários de
> teste cadastrados, funciona sem verificação nenhuma. Para abrir ao
> público, confirme a política vigente: veja o [PUBLICAR.md](PUBLICAR.md).

---

## 6. Criar os clientes OAuth

Em **APIs e serviços → Credenciais → Criar credenciais → ID do cliente OAuth**.

### 6.1 Android

Você precisa do SHA-1 da chave que assina o aplicativo.

```bash
# Chave de debug (para `flutter run`)
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android | grep SHA1
```

- Tipo: **Android**
- Nome do pacote: `br.com.brigido.meu_bebe`
- SHA-1: o valor acima

Ao gerar a versão de release, repita com o SHA-1 da sua chave de publicação
(e com o da chave do Google Play, se usar o Play App Signing).

### 6.2 iOS

- Tipo: **iOS**
- ID do pacote: `br.com.brigido.meuBebe`

### 6.3 Web — o mais importante

- Tipo: **Aplicativo da Web**
- Nome: `Meu Bebê (serverClientId)`

Copie o **ID do cliente** gerado e coloque em
`lib/firebase_options.dart`:

```dart
static const String serverClientId =
    'SEU_WEB_CLIENT_ID.apps.googleusercontent.com';
```

> Sem esse valor o login falha no Android: é ele que faz o Google devolver o
> `idToken` que o Firebase Auth aceita. Como o `flutterfire configure`
> sobrescreve o arquivo, confira essa linha depois de rodá-lo de novo.

---

## 7. iOS: registrar o esquema de URL

Abra `ios/Runner/GoogleService-Info.plist`, copie o valor de
**REVERSED_CLIENT_ID** e adicione ao `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.SEU_ID_INVERTIDO</string>
    </array>
  </dict>
</array>
```

---

## 8. Publicar as regras do Firestore

As regras deste repositório garantem que cada conta só enxerga os próprios
dados.

```bash
firebase init firestore   # aponte para firebase/firestore.rules e firebase/firestore.indexes.json
firebase deploy --only firestore:rules,firestore:indexes
```

Ou cole o conteúdo de `firebase/firestore.rules` direto no console, em
**Firestore Database → Regras**.

> **Confira que as regras subiram.** Elas são a única barreira entre os dados
> de uma família e os de outra. No console, em *Firestore Database → Regras*,
> o texto exibido tem que ser o do repositório. Se estiver lá o padrão do
> "modo de teste", o banco fica aberto a qualquer pessoa até a data que
> aparece na primeira linha.

Para conferir o comportamento das regras, e não só o texto:

```bash
cd firebase/teste
npm install
npm test     # sobe o emulador oficial e roda 19 verificações
```

Isso testa isolamento entre contas, listagem negada e recusa de documentos
fora do formato. Roda também a cada pull request.

---

## 9. Rodar

```bash
flutter pub get
flutter run
```

No primeiro acesso o aplicativo pede o login, cria a pasta `Meu Bebê` no
Google Drive com as seis subpastas e abre o cadastro inicial.

---

## Não quer instalar Flutter no computador?

Depois de concluir os passos acima, o **[INSTALAR.md](INSTALAR.md)** mostra
como fazer o próprio GitHub compilar o APK para você — basta guardar dois
segredos no repositório e clicar num botão.

---

## Verificação rápida

```bash
flutter analyze   # deve terminar sem nenhum aviso
flutter test      # cálculo de idade, pastas, formatação e linha do tempo
```

---

## Problemas comuns

**`ApiException: 10` no login (Android)**
O SHA-1 cadastrado não bate com a chave que assinou o aplicativo. Rode o
`keytool` de novo e confira o valor no cliente OAuth Android.

**"Não recebemos o identificador da conta"**
O `serverClientId` em `lib/firebase_options.dart` está vazio ou é o cliente
errado. Ele tem que ser o ID do cliente **Web** (passo 6.3).

**"Acesso bloqueado: este app não foi verificado"**
Falta adicionar o e-mail em **Usuários de teste**, no passo 5.

**A foto sobe mas a pasta não aparece no Drive**
Procure por `Meu Bebê` na raiz do Drive **da conta que está logada no
aplicativo**. Se você entrou com outra conta, a pasta está lá.

**O vídeo falha ao converter**
Vídeos muito longos podem estourar a memória em aparelhos antigos. O
original continua intacto na galeria; tente de novo pela linha do tempo,
no cartão marcado com erro.

---

## Onde cada coisa fica

| O quê | Onde |
|---|---|
| Fotos, vídeos, desenhos, documentos | Google Drive de quem está logado, em `Meu Bebê/` |
| Texto das cartas, peso e altura, índice da linha do tempo | Cloud Firestore do seu projeto, em `users/{uid}` |
| Miniaturas e arquivos temporários | Cache do próprio aparelho |
| Fotos e vídeos originais | Continuam na galeria do celular, intactos |

Se um dia este aplicativo deixar de existir, o acervo continua no Drive de
cada família — organizado por idade, com nomes de arquivo por data, e
navegável por qualquer pessoa.
