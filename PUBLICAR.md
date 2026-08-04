# Publicar o Meu Bebê: Cápsula do Tempo na Google Play

Guia para colocar o aplicativo na loja, onde qualquer família baixa e entra
com a **própria** conta Google.

---

## Como funciona o modelo público

Cada pessoa que instala:

1. entra com a conta Google **dela**;
2. o aplicativo cria a pasta `Meu Bebê - Cápsula do Tempo/` **no Drive dela**;
3. as fotos e vídeos ficam no Drive **dela** - você nunca os vê;
4. o Firestore do **seu** projeto guarda só o índice: título de carta, peso,
   altura, datas e os ids dos arquivos.

O isolamento é garantido pelas regras do Firestore (`request.auth.uid == uid`)
e pelo escopo `drive.file`, que só enxerga o que o próprio aplicativo criou.

**Consequência para o seu bolso:** o armazenamento pesado fica distribuído
entre os usuários e não custa nada para você. Só o índice roda na sua conta,
e ele é minúsculo - alguns kilobytes por família.

---

## O que é seu e o que é do usuário

| Item | De quem é | Onde fica |
|---|---|---|
| Projeto Firebase, credenciais OAuth, chave de publicação | **suas** | sua conta de desenvolvedor |
| Fotos, vídeos, cartas, documentos | de cada usuário | Google Drive de cada um |
| Índice da linha do tempo | de cada usuário, no seu projeto | `users/{uid}` no seu Firestore |

O `google-services.json` e o `firebase_options.dart` são a **identidade do
aplicativo** - o crachá que o Google exige para permitir que ele peça login.
Eles vão compilados dentro do APK e não têm nenhuma relação com a conta de
quem instala.

---

## Passo 1 - Firebase na sua conta

Siga o **[SETUP.md](SETUP.md)**, criando o projeto na **sua** conta de
desenvolvedor (não na conta de nenhum familiar).

---

## Passo 2 - Abrir o OAuth para o público

Enquanto a tela de consentimento estiver em **"Teste"**, só os e-mails
cadastrados como testadores conseguem entrar - no máximo 100.

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

## Passo 3 - Chave de publicação

A Play Store recusa qualquer APK assinado com a chave de debug.

```bash
keytool -genkey -v -keystore ~/meu-bebe-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias meu-bebe
```

Para compilar **no seu computador**, copie `android/key.properties.example`
para `android/key.properties` e preencha com o caminho do `.jks` e as senhas.
O arquivo está no `.gitignore` - ele nunca deve ir para o repositório.

Para compilar **pelo GitHub**, a chave vai como segredo e o workflow monta o
`key.properties` sozinho. São quatro segredos, descritos no
[INSTALAR.md](INSTALAR.md), passo 2: `RELEASE_KEYSTORE`,
`KEYSTORE_PASSWORD`, `KEY_ALIAS` e `KEY_PASSWORD`.

> Se faltar qualquer um deles, o workflow para antes de compilar. Isso é de
> propósito: sem a chave o Gradle assinaria com a de debug e o APK sairia
> normal, só sem conseguir logar. Depois do build, um passo confere a
> assinatura do APK e imprime o SHA-1 dela - o valor que precisa estar
> cadastrado no cliente OAuth Android.

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

## Passo 4 - Gerar o pacote

A Play Store pede **AAB**, não APK:

```bash
flutter build appbundle --release
```

O arquivo sai em `build/app/outputs/bundle/release/app-release.aab`.

---

## Passo 5 - Conta e ficha da loja

1. Crie a conta de desenvolvedor: US$ 25, pagamento único.
2. Preencha a ficha. Os nomes já estão definidos:

   | Campo | Valor | Limite |
   |---|---|---|
   | Nome do app (título) | `Meu Bebê: Cápsula do Tempo` | 30 caracteres, e ele usa 26 |
   | Descrição breve | `A história do seu filho, guardada no seu próprio Google Drive.` | 80 |

   > O nome embaixo do ícone no celular é **outro campo**, definido no
   > `AndroidManifest.xml`, e continua sendo o curto `Meu Bebê`. Isso é
   > proposital: o Android corta o rótulo do ícone por volta do 11º
   > caractere, e o nome completo viraria "Meu Bebê: C...".

   Faltam o ícone, as capturas de tela e a categoria.
3. **Política de privacidade** - obrigatória, e com peso extra aqui: o app
   guarda dados de crianças. Ela precisa dizer, com clareza, que
   as fotos vão para o Drive do próprio usuário e que o aplicativo guarda
   apenas metadados.
4. **Segurança dos dados** - declare o que é coletado. Neste app:
   identificadores da conta (para o login) e conteúdo do usuário (o índice
   no Firestore). Nada é vendido nem compartilhado.
5. **Público-alvo** - o aplicativo é usado por **adultos** (os pais), mesmo
   sendo *sobre* crianças. Declarar público infantil por engano ativa as
   regras da política Famílias, bem mais rígidas.

---

## Passo 5.1 - Proteger a sua conta de nuvem

O modelo é generoso com o usuário e desprotegido com você: qualquer pessoa
instala, entra e passa a poder escrever no Firestore do **seu** projeto. Três
medidas, em ordem de importância:

1. **Alerta de orçamento** no projeto do Google Cloud (*Faturamento →
   Orçamentos e alertas*). É o que evita descobrir um problema pela fatura.
   Faça isso antes de publicar, não depois.
2. **App Check com Play Integrity** (*Firebase → App Check*). Sem ele, a chave
   e o id do projeto - que viajam dentro do APK - bastam para chamar o
   Firestore de fora do aplicativo.
3. **Regras validando formato**, já no repositório. Elas recusam documento
   fora do formato esperado e limitam o tamanho dos textos. Rode
   `cd firebase/teste && npm test` depois de qualquer mudança nelas.

---

## Passo 5.2 - Exclusão de conta e política de privacidade

Desde 2023 o Google Play exige, para todo aplicativo com criação de conta:

- exclusão **dentro do aplicativo** - já existe, em *Perfil → Apagar minha
  conta e meus dados*;
- uma **URL pública** onde a exclusão possa ser pedida sem instalar o app.
  Você precisa criar essa página e informá-la no Play Console.

### O que dizer sobre o acesso ao Google Drive

Este é o ponto que mais gera desconfiança - e onde a resposta é forte. Diga,
na ficha da loja e na política, algo com este teor:

> O aplicativo solicita a permissão `drive.file`, que concede acesso
> **apenas aos arquivos criados pelo próprio aplicativo**. Todos eles ficam
> em uma única pasta, `Meu Bebê - Cápsula do Tempo`, criada na sua conta.
> O aplicativo não lê, não lista e não acessa nenhum outro arquivo ou pasta
> do seu Google Drive - essa restrição é aplicada pelos servidores do
> Google, não apenas pelo aplicativo.

É verdade e é verificável: `drive.file` é o escopo mais estreito do Drive, e
o repositório tem testes que falham a integração contínua se alguém
acrescentar um escopo mais amplo ou uma consulta à raiz da conta.

### O que fica em cada lugar

A política de privacidade precisa dizer, sem rodeio:

| O quê | Onde | Quem vê |
|---|---|---|
| Fotos, vídeos, desenhos, documentos | Google Drive do usuário | só o usuário |
| Nome, data de nascimento, hospital, peso, altura, **texto das cartas** | Firestore do **seu** projeto | o usuário e **você**, como administrador |
| E-mail e nome da conta Google | Firebase Auth do seu projeto | o usuário e você |

Dizer "nenhum dado é coletado" no formulário de Segurança dos Dados seria
falso. O correto é declarar informações pessoais e conteúdo do usuário,
armazenados nos seus servidores, não compartilhados e não vendidos, com
exclusão a pedido.

E vale saber o que você está assumindo: com dados de criança em jogo, a LGPD
trata você como **controlador**. Isso traz base legal (art. 14 é específico
sobre criança), canal de contato, atendimento a pedido de exclusão e
comunicação em caso de incidente.

---

## Passo 6 - Testes antes do público

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
      e conferidas no console - não as do "modo de teste"
- [ ] `cd firebase/teste && npm test` passando
- [ ] Alerta de orçamento configurado no Google Cloud
- [ ] App Check ativado com Play Integrity
- [ ] Política de privacidade no ar e acessível
- [ ] URL pública de exclusão de conta no ar e informada no Play Console
- [ ] Testado o "Apagar minha conta e meus dados" de ponta a ponta, conferindo
      no console do Firebase que `users/{uid}` sumiu
- [ ] Conferido no APK que as permissões novas dos lembretes são só
      `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` e `VIBRATE`
      (`aapt dump permissions app-release.apk`).
      **Não pode aparecer `SCHEDULE_EXACT_ALARM` nem `USE_EXACT_ALARM`**: os
      lembretes são agendados em modo inexato justamente para dispensar a
      permissão de alarme exato, que o Google Play audita
- [ ] Testado ligar e desligar os lembretes, e recusar a permissão do sistema
      (a chave tem que voltar sozinha para desligado)
- [ ] Testado em menino **e** menina - os textos concordam com o gênero
- [ ] Testado com internet ruim: o envio continua em segundo plano

---

## Custos

| O quê | Quanto |
|---|---|
| Conta de desenvolvedor Google Play | US$ 25, uma vez |
| Firebase (Firestore, só índice) | gratuito no plano Spark; pay-as-you-go se crescer muito |
| Armazenamento das fotos | **zero** - fica no Drive de cada usuário |
| GitHub Actions | gratuito, porque o repositório é público |
