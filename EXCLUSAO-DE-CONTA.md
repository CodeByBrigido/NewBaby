# Exclusão de conta e de dados

**Meu Bebê: Cápsula do Tempo**

_Última atualização: 18 de agosto de 2026_

> Este arquivo é gerado de `lib/core/l10n/account_deletion.dart`. Não edite aqui: edite lá e rode `dart run tool/gerar_exclusao.dart`.

## O que esta página é

Esta página explica como pedir a exclusão da sua conta do aplicativo Meu Bebê: Cápsula do Tempo e de todos os dados associados a ela.

Ela existe para funcionar mesmo que você já tenha desinstalado o aplicativo. Você não precisa instalar nada, criar cadastro nem entrar em lugar nenhum para usar o que está aqui.

Responsável pelo tratamento: Rodrigo Andrade Brigido. Contato: mybabytimecapsule@gmail.com


## Se você ainda tem o aplicativo

Este é o caminho mais rápido, e o único que apaga tudo na hora, sem esperar por ninguém:

- Abra o aplicativo e entre com a conta que quer apagar

- Toque em Perfil

- Toque em "Apagar minha conta e meus dados"

- Confirme

A exclusão acontece imediatamente e não pode ser desfeita.

Nessa tela você também escolhe o que fazer com a pasta do Google Drive: mantê-la (o padrão, porque os arquivos são seus) ou mandá-la para a lixeira do seu Drive.


## Se você não tem mais o aplicativo

Escreva para mybabytimecapsule@gmail.com com o assunto "Excluir minha conta".

O pedido precisa partir do endereço de email da conta Google que você usou para entrar no aplicativo. É o único jeito de sabermos que o pedido é seu: sem essa checagem, qualquer pessoa poderia apagar o acervo de outra escrevendo um email.

Responderemos para esse mesmo endereço confirmando a exclusão. Se o pedido chegar de outro endereço, vamos pedir que ele seja reenviado do endereço da conta, e não vamos apagar nada até isso acontecer.

O prazo máximo é de 30 dias, e na prática costuma levar poucos dias. Você não precisa justificar o pedido, e ele não custa nada.


## O que é apagado

Tudo o que existe do seu lado no nosso servidor, sem exceção:

- O cadastro da criança: nome, data e hora de nascimento, sexo, peso, altura e hospital

- A linha do tempo inteira: a data, a idade, o título, a descrição e o tipo de cada memória

- O texto integral das cartas, que é o único conteúdo seu que fica no nosso índice

- Os identificadores das pastas do Drive e o progresso das sugestões

- A sua conta de autenticação, com o email e o nome vindos do Google

A exclusão é imediata e não é reversível. Não guardamos backup dos seus dados depois dela, e não existe um período de carência em que daria para recuperar.


## O que não é apagado, e por quê

As suas fotos, vídeos, desenhos e documentos **não são apagados**, porque eles nunca foram nossos.

Eles ficam numa pasta chamada "Meu Bebê - Cápsula do Tempo", no Google Drive da sua própria conta. O aplicativo nunca teve cópia deles em servidor nenhum: eles vão do seu aparelho direto para o seu Drive.

Depois que a conta é apagada, nós deixamos de ter qualquer acesso a essa pasta. A permissão que o aplicativo pede ao Google é a mais estreita que existe (https://www.googleapis.com/auth/drive.file), ela só alcança arquivos que o próprio aplicativo criou, e é revogada na exclusão. Não é uma questão de escolha nossa: depois disso não há como apagá-los mesmo que você peça.

Se você também quiser apagar os arquivos, faça direto no Drive, e leva dois toques:

- Abra drive.google.com com a mesma conta

- Ache a pasta "Meu Bebê - Cápsula do Tempo"

- Clique com o botão direito e escolha "Remover"

Se preferir apagar a pasta pelo aplicativo, faça isso **antes** de excluir a conta, na mesma tela de exclusão: ali há a opção de mandar a pasta para a lixeira do Drive.


## A assinatura Premium não é cancelada aqui

Se você assina o plano Premium, **apagar a conta não cancela a assinatura**. São duas coisas em lugares diferentes: a conta é nossa, a assinatura é da Google Play.

Sem cancelar lá, a cobrança anual continua acontecendo mesmo depois de a cápsula ter sido apagada. Nós não temos acesso à sua forma de pagamento e não conseguimos cancelar por você.

Cancele antes de apagar a conta, e leva poucos toques:

- Abra a Google Play Store

- Toque na sua foto, no alto à direita

- Vá em "Pagamentos e assinaturas" e depois em "Assinaturas"

- Escolha Meu Bebê: Cápsula do Tempo e toque em "Cancelar assinatura"

Cancelando, o Premium continua valendo até o fim do período já pago. Se você apagar a conta antes disso, esse tempo restante se perde, e não há devolução proporcional por ele.


## Apagar só uma parte

Você não precisa apagar a conta inteira para apagar alguma coisa.

Dentro do aplicativo, qualquer memória pode ir para a lixeira e ser apagada de vez, uma a uma. O cadastro da criança pode ser editado a qualquer momento. Nada disso passa por nós nem depende de pedido.

Se o que você quer é parar de usar o aplicativo sem apagar nada, basta sair da conta em Perfil: os dados no aparelho são apagados na saída, e o acervo no seu Drive continua onde está.


## Uma conta por criança

O aplicativo usa uma conta do Google por criança, para que um dia cada uma receba a própria cápsula inteira.

Isso quer dizer que apagar uma conta apaga a cápsula daquela criança, e só dela. Se você usa mais de uma conta, o pedido precisa ser feito uma vez para cada, a partir do email de cada uma.

A assinatura Premium também é por conta. Apagar a cápsula de uma criança não mexe na assinatura das outras, e cada uma segue valendo, ou sendo cancelada, por si.


## Registros técnicos

A infraestrutura que hospeda o índice é o Firebase, do Google. Como qualquer serviço de nuvem, ele mantém registros operacionais de acesso, sujeitos à política de retenção do próprio Google.

Esses registros não contêm o conteúdo das suas memórias, e nós não os consultamos nem os exportamos. Dizemos isto aqui porque prometer "nada resta em lugar nenhum" seria uma promessa que não está sob o nosso controle.


## Account deletion (English)

To delete your Meu Bebê: Cápsula do Tempo account and all associated data, either use Profile > "Apagar minha conta e meus dados" inside the app, or email mybabytimecapsule@gmail.com from the Google account address you signed in with.

We delete the entire server-side index (child profile, timeline metadata, letter text, folder identifiers) and your authentication account. Deletion is immediate and irreversible; no backups are kept. Email requests are honoured within 30 days.

If you subscribe to the Premium plan, deleting your account does **not** cancel the subscription: billing is handled by Google Play, not by us. Cancel it in the Play Store under "Payments and subscriptions" before deleting your account, otherwise the yearly charge continues.

Your photos and videos are stored in your own Google Drive and are never deleted by us, because we never had a copy: the app uses the https://www.googleapis.com/auth/drive.file scope, which reaches only files the app itself created, and that access is revoked on deletion. You can delete the folder "Meu Bebê - Cápsula do Tempo" yourself at drive.google.com.
