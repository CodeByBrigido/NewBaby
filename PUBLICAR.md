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

Não esqueça de cadastrar o **SHA-1 da chave de release** como cliente OAuth
Android, senão o login falha só na versão da loja:

```bash
keytool -list -v -keystore ~/meu-bebe-release.jks -alias meu-bebe | grep SHA1
```

> ### A armadilha que quebra o login de todo mundo, menos o seu
>
> Com o **Play App Signing**, o aplicativo que chega ao celular das pessoas
> **não é assinado pela sua chave**. Você assina com a chave de upload, o
> Google reassina com a chave dele antes de distribuir.
>
> Ou seja: o SHA-1 que você tira do seu `.jks` **não** é o SHA-1 do
> aplicativo que a loja entrega. Se só ele estiver cadastrado, o login
> funciona no APK que você instala na mão e falha para cada pessoa que
> baixar da Play Store, com a mesma mensagem de "Login cancelado".
>
> **Cadastre os dois**: o SHA-1 da sua chave de upload e o SHA-1 do
> certificado do Play App Signing, que aparece no Play Console em
> *Versões → Configuração → Assinatura de apps*.
>
> É o tipo de erro que só aparece depois de publicado, com gente real sem
> conseguir entrar.

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
   guarda dados de crianças. Ela precisa dizer, com clareza, que as fotos e
   os vídeos vão para o Google Drive do próprio usuário e que o aplicativo
   guarda apenas metadados.
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
   fora do formato esperado e limitam o tamanho dos textos. O CI as testa
   contra o emulador oficial a cada pull request.

---

## Passo 5.1.1 - Publicar as regras e os índices (sem terminal)

**As regras e os índices são a parte deste repositório que não viaja dentro
do aplicativo.** Eles moram no servidor do Firebase, e o aplicativo
instalado no celular obedece à versão publicada lá, não à que está aqui.

Quando as versões se separam, o sintoma é cruel e mudo, e sempre parece
defeito do aplicativo:

| O que ficou para trás | O que a pessoa vê |
|---|---|
| Regra | o cadastro é aceito, o servidor recusa dois segundos depois, e ela volta ao formulário |
| Índice | a linha do tempo abre vazia, como se as memórias tivessem sumido |

Os dois aconteceram de verdade, um atrás do outro: o campo `arquivoInfoId`
entrou no aplicativo e nas regras do repositório mas não no servidor, e os
índices da linha do tempo nunca tinham sido publicados.

Existe um fluxo do GitHub Actions que publica os dois sozinho: **Publicar
as regras e os índices do Firestore**. Ele roda quando o arquivo muda na `main`, e também no botão
*Run workflow*, igual ao que gera o APK. Antes de publicar, ele roda a
suíte de regras contra o emulador: uma regra que fecha a porta errada
tranca famílias reais para fora do próprio acervo.

### O que fazer uma vez só, para o botão funcionar

Tudo pelo navegador. Nenhum comando.

**1. Criar a credencial** (Google Cloud Console, projeto do Firebase):

- *IAM e administrador → Contas de serviço → *Criar conta de serviço*
- Nome: `publicar-regras`
- Em *Conceder acesso*, adicione os dois papéis:
  - **Firebase Rules Admin** (`roles/firebaserules.admin`)
  - **Firebase Admin SDK Administrator Service Agent**, ou simplesmente
    **Editor** se preferir não caçar papel
- Concluir. Depois abra a conta criada → aba **Chaves** → *Adicionar chave
  → Criar nova chave → JSON*. O arquivo baixa sozinho

**2. Guardar no GitHub** (*Settings → Secrets and variables → Actions →
New repository secret*), dois segredos:

| Nome | Valor |
|---|---|
| `FIREBASE_SERVICE_ACCOUNT` | o conteúdo **inteiro** do arquivo JSON baixado, colado |
| `FIREBASE_PROJECT_ID` | `meu-bebe-16a7d` |

**3. Publicar**: aba *Actions* → **Publicar as regras do Firestore** → *Run
workflow*. Em um minuto as regras do repositório estão no ar, e daí em
diante isso acontece sozinho a cada mudança na `main`.

O arquivo JSON baixado é uma credencial de verdade: apague o download
depois de colar, e **não** o coloque no repositório.

### O caminho manual, se preferir não criar a credencial agora

Também é só navegador, e desbloqueia na hora:

**Regras:**

1. Abra `firebase/firestore.rules` no GitHub e copie o conteúdo
2. *Firebase Console → Firestore Database → aba Regras*
3. Apague o que está no editor, cole, e **Publicar**

**Índices:** o console não aceita colar o arquivo, mas o próprio erro do
aplicativo traz um link que cria o índice que faltou, com um clique. Os
três que o aplicativo usa estão em `firebase/firestore.indexes.json`, e
levam alguns minutos para ficarem prontos depois de criados.

A desvantagem é que é preciso lembrar de refazer isso toda vez que as
regras mudarem, e esquecer é exatamente o defeito que o fluxo automático
existe para eliminar.

---

## Passo 5.2 - Exclusão de conta e política de privacidade

Desde 2023 o Google Play exige, para todo aplicativo com criação de conta:

- exclusão **dentro do aplicativo** - já existe, em *Perfil → Apagar minha
  conta e meus dados*;
- uma **URL pública** onde a exclusão possa ser pedida sem instalar o app.

As duas páginas já estão escritas e estão em `docs/`. Falta só ligar o
GitHub Pages, que é de graça.

### Como pôr as duas páginas no ar

As páginas são geradas do mesmo texto que o aplicativo mostra:

```bash
dart run tool/gerar_site.dart
```

Isso escreve `docs/index.html`, `docs/privacidade.html` e
`docs/exclusao.html`. **Não edite esses arquivos à mão**: edite
`lib/core/l10n/privacy_policy.dart` ou `lib/core/l10n/account_deletion.dart`
e rode o comando de novo. O `exclusao_test.dart` compara os arquivos com o
que a ferramenta geraria, então esquecer de rodar quebra a suíte em vez de
deixar no ar uma página que descreve outro aplicativo.

Para publicar, uma vez só:

1. O repositório precisa ser **público** (o GitHub Pages só é gratuito em
   repositório público). Nada aqui é segredo: a chave de assinatura e o
   `key.properties` já ficam fora do repositório.
2. No GitHub, *Settings → Pages*
3. Em *Source*, escolha **Deploy from a branch**
4. Branch `main`, pasta **`/docs`**, e *Save*
5. Em um ou dois minutos os endereços ficam de pé:

| Página | Endereço |
|---|---|
| Política de privacidade | `https://codebybrigido.github.io/NewBaby/privacidade.html` |
| Exclusão de conta | `https://codebybrigido.github.io/NewBaby/exclusao.html` |

Confira os dois numa aba anônima, **sem estar logado no GitHub**: é assim
que o revisor da loja vai abrir.

### Onde informar cada um no Play Console

- *Política → Conteúdo do app → Política de privacidade*: o endereço da
  política
- *Política → Segurança dos dados*, no fim do formulário, em **"URL de
  solicitação de exclusão de conta"**: o endereço da exclusão
- *Ficha da loja*, no campo de política de privacidade: o mesmo da política

O campo da exclusão é o que costuma reprovar a revisão quando fica vazio, e
ele é separado do campo da política: preencher um não preenche o outro.

### O que a página de exclusão diz, e por quê

Ela cobre as arestas que a revisão cobra, e algumas que ela não cobra:

- funciona **sem o aplicativo instalado**, que é a razão de ela existir;
- exige que o pedido parta do **email da própria conta Google**. Sem isso,
  um email bastaria para apagar o acervo de outra pessoa;
- promete um prazo de **30 dias**, que é o limite do Art. 12(3) do GDPR;
- separa **o que é apagado** do **que não é apagado**, um logo depois do
  outro. As fotos não são apagadas porque nunca foram nossas, e depois da
  exclusão o acesso `drive.file` é revogado: nem se você pedir dá para
  mexer nelas. A página ensina a apagar a pasta pelo próprio Drive;
- diz que dá para **apagar só uma parte** sem apagar a conta, que é uma
  pergunta explícita do formulário de Segurança dos Dados;
- lembra que é **uma conta por criança**, então o pedido é um por conta;
- é honesta sobre os **registros operacionais do Firebase**, que são do
  Google e não estão sob o nosso controle;
- tem uma seção em **inglês**, porque o revisor raramente lê português e
  uma URL ilegível custa um ciclo inteiro de revisão.

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

## Passo 5.3 - Recriar o repositório antes de enviar

**Faça isto por último, e antes do envio.** É o único passo da lista que
não dá para refazer depois: o que já foi publicado num repositório público
não volta atrás.

### Por que recriar, e não limpar

O repositório é público, e assim fica: é o que mantém o GitHub Pages
gratuito servindo as duas URLs do passo anterior. O custo é que estas
coisas estão à vista desde o primeiro commit:

- `android/app/google-services.json`, com o `project_id` e a API key
- a mesma chave repetida em `lib/firebase_options.dart`

Elas **não são segredo** no modelo do Firebase: identificam o projeto, e
quem protege os dados são as regras do Firestore. O que permitem é **abuso
de cota**, ou seja, conta no fim do mês, e é por isso que isto entra junto
com o App Check e o alerta de orçamento do passo 5.1.

E não adianta `git rm --cached`: ele não apaga o passado, e o GitHub
mantém os commits órfãos alcançáveis por SHA mesmo depois de um
force-push. Só apagar o repositório tira aquilo do ar.

### A ordem, que importa

Rotacionar **antes** de recriar. Ao contrário, você só muda o endereço em
que a chave velha está publicada.

1. **Rotacionar a API key** no Google Cloud, em *APIs e Serviços →
   Credenciais*: criar uma nova, restringir a **aplicativos Android** com o
   pacote `br.com.brigido.meu_bebe` e o SHA-1 da chave de release, e só
   então apagar a antiga
2. Baixar o `google-services.json` novo e regerar o `firebase_options.dart`
   (`flutterfire configure`)
3. Ver o que mais passou pelo histórico, antes de decidir:

   ```bash
   git log --all --full-history --name-only --pretty=format: \
     | sort -u | grep -iE "google-services|key\.properties|\.jks|\.env"
   ```

4. Criar o **repositório novo**, já público, e subir **um commit só** a
   partir da árvore de trabalho, com o `.gitignore` valendo desde o começo.
   O histórico antigo não vem: é ele o problema
5. Conferir que nada sensível entrou. Tem que voltar vazio:

   ```bash
   git ls-files | grep -iE "google-services|key\.properties|\.jks|\.keystore|\.env"
   ```

   Os arquivos `.example` continuam: documentam o formato sem entregar
   conteúdo
6. Recriar os segredos do Actions, em *Settings → Secrets and variables →
   Actions*. Eles não viajam com o código:
   `GOOGLE_SERVICES_JSON`, `FIREBASE_OPTIONS_DART`, `RELEASE_KEYSTORE`,
   `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
7. Religar o **GitHub Pages** em `main` / `/docs` e abrir as duas URLs em
   aba anônima
8. **Apagar o repositório antigo**
9. Se o nome do repositório mudar, atualizar as duas URLs no Play Console e
   no `PUBLICAR.md`

### O que nunca entra, nem no repositório novo

O `android/key.properties` e o `.jks`. Esses **são** segredo de verdade:
quem tem a chave de assinatura publica atualização no seu lugar, e o Google
não troca a chave de um aplicativo já publicado.

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
- [ ] Regras do Firestore publicadas pelo fluxo *Publicar as regras do
      Firestore* (passo 5.1.1) e conferidas no console - não as do
      "modo de teste". O campo `arquivoInfoId` tem que aparecer lá
- [ ] `cd firebase/teste && npm test` passando
- [ ] Alerta de orçamento configurado no Google Cloud
- [ ] App Check ativado com Play Integrity
- [ ] API key do Firebase **rotacionada** e restrita ao pacote + SHA-1 de
      release, com a antiga apagada no Google Cloud
- [ ] Repositório recriado do zero, sem o histórico antigo, e o antigo
      apagado (passo 5.3). `git ls-files | grep -iE "google-services|
      key\.properties|\.jks"` volta vazio
- [ ] Segredos do Actions recriados e o CI verde no repositório novo
- [ ] GitHub Pages ligado em `main` / `/docs`, e as duas páginas abrindo
      numa aba anônima
- [ ] Política de privacidade no ar e acessível
- [ ] URL pública de exclusão de conta no ar e informada no Play Console, no
      campo próprio de *Segurança dos dados* (não é o mesmo campo da política)
- [ ] Testado o "Apagar minha conta e meus dados" de ponta a ponta, conferindo
      no console do Firebase que `users/{uid}` sumiu
- [ ] Conferido no APK que as permissões dos lembretes são só
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
