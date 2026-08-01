# Publicar o Meu Bebê na Google Play

Guia para colocar o aplicativo na loja, onde qualquer família baixa e entra
com a **própria** conta Google.

---

## Como funciona o modelo público

Cada pessoa que instala:

1. entra com a conta Google **dela**;
2. o aplicativo cria a pasta `Meu Bebê/` **no Drive dela**;
3. as fotos e vídeos ficam no Drive **dela** — você nunca os vê;
4. o Firestore do **seu** projeto guarda só o índice: título de carta, peso,
   altura, datas e os ids dos arquivos.

O isolamento é garantido pelas regras do Firestore (`request.auth.uid == uid`)
e pelo escopo `drive.file`, que só enxerga o que o próprio aplicativo criou.

**Consequência para o seu bolso:** o armazenamento pesado fica distribuído
entre os usuários e não custa nada para você. Só o índice roda na sua conta,
e ele é minúsculo — alguns kilobytes por família.

---

## O que é seu e o que é do usuário

| Item | De quem é | Onde fica |
|---|---|---|
| Projeto Firebase, credenciais OAuth, chave de publicação | **suas** | sua conta de desenvolvedor |
| Fotos, vídeos, cartas, documentos | de cada usuário | Google Drive de cada um |
| Índice da linha do tempo | de cada usuário, no seu projeto | `users/{uid}` no seu Firestore |

O `google-services.json` e o `firebase_options.dart` são a **identidade do
aplicativo** — o crachá que o Google exige para permitir que ele peça login.
Eles vão compilados dentro do APK e não têm nenhuma relação com a conta de
quem instala.

---

## Passo 1 — Firebase na sua conta

Siga o **[SETUP.md](SETUP.md)**, criando o projeto na **sua** conta de
desenvolvedor (não na conta de nenhum familiar).

---

## Passo 2 — Abrir o OAuth para o público

Enquanto a tela de consentimento estiver em **"Teste"**, só os e-mails
cadastrados como testadores conseguem entrar — no máximo 100.

Em **APIs e serviços → Tela de permissão OAuth**, clique em
**Publicar aplicativo** para mover o estado para *Em produção*.

> **Confirme a política vigente antes de marcar uma data de lançamento.**
> O `drive.file` é o escopo mais estreito que existe e foi escolhido
> justamente por ser o que o Google recomenda para evitar a revisão pesada.
> Ainda assim, as regras de verificação mudam: se a sua tela cair em
> análise, o prazo é de semanas, não de horas. Verifique isso **antes** de
> prometer a data para alguém.

Você vai precisar, no mínimo, de:

- domínio do aplicativo e **link para a política de privacidade**;
- domínios autorizados;
- e-mail de contato do desenvolvedor.

---

## Passo 3 — Chave de publicação

A Play Store recusa qualquer APK assinado com a chave de debug.

```bash
keytool -genkey -v -keystore ~/meu-bebe-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias meu-bebe
```

Copie `android/key.properties.example` para `android/key.properties` e
preencha com o caminho do `.jks` e as senhas. O arquivo está no
`.gitignore` — ele nunca deve ir para o repositório.

> ⚠️ **Guarde o `.jks` e as senhas em lugar seguro, com cópia.** Se você
> perder essa chave, não existe forma de publicar atualização do aplicativo:
> a Play Store trata como se fosse outro app. É o erro mais caro e mais
> comum de quem publica pela primeira vez.

Não esqueça de cadastrar o **SHA-1 da chave de release** (e o da chave do
Play App Signing, se usar) como cliente OAuth Android, senão o login falha
só na versão da loja:

```bash
keytool -list -v -keystore ~/meu-bebe-release.jks -alias meu-bebe | grep SHA1
```

---

## Passo 4 — Gerar o pacote

A Play Store pede **AAB**, não APK:

```bash
flutter build appbundle --release
```

O arquivo sai em `build/app/outputs/bundle/release/app-release.aab`.

---

## Passo 5 — Conta e ficha da loja

1. Crie a conta de desenvolvedor: US$ 25, pagamento único.
2. Preencha a ficha: nome, descrição, ícone, capturas de tela, categoria.
3. **Política de privacidade** — obrigatória, e com peso extra aqui: o app
   guarda dados de crianças. Ela precisa dizer, com clareza, que
   as fotos vão para o Drive do próprio usuário e que o aplicativo guarda
   apenas metadados.
4. **Segurança dos dados** — declare o que é coletado. Neste app:
   identificadores da conta (para o login) e conteúdo do usuário (o índice
   no Firestore). Nada é vendido nem compartilhado.
5. **Público-alvo** — o aplicativo é usado por **adultos** (os pais), mesmo
   sendo *sobre* crianças. Declarar público infantil por engano ativa as
   regras da política Famílias, bem mais rígidas.

---

## Passo 6 — Testes antes do público

Comece por **teste interno** (libera em minutos, até 100 pessoas) para você
e a família validarem o login e o envio de verdade. Depois promova para
produção.

---

## Antes de apertar publicar

- [ ] Login funciona com uma conta que **não** é a sua, sem estar na lista de testadores
- [ ] Tela de consentimento OAuth em *Em produção*
- [ ] SHA-1 da chave de release cadastrado no cliente OAuth Android
- [ ] `android/key.properties` fora do repositório, com cópia da chave guardada
- [ ] Regras do Firestore publicadas (`firebase deploy --only firestore:rules`)
- [ ] Política de privacidade no ar e acessível
- [ ] Testado em menino **e** menina — os textos concordam com o gênero
- [ ] Testado com internet ruim: o envio continua em segundo plano

---

## Custos

| O quê | Quanto |
|---|---|
| Conta de desenvolvedor Google Play | US$ 25, uma vez |
| Firebase (Firestore, só índice) | gratuito no plano Spark; pay-as-you-go se crescer muito |
| Armazenamento das fotos | **zero** — fica no Drive de cada usuário |
| GitHub Actions | gratuito, porque o repositório é público |
