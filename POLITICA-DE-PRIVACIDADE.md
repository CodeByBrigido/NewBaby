# Política de Privacidade

**Meu Bebê: Cápsula do Tempo**

_Última atualização: 9 de agosto de 2026_

> Este arquivo é gerado de `lib/core/l10n/privacy_policy.dart`, que é o mesmo texto exibido dentro do aplicativo. Não edite aqui: edite lá e rode `dart run tool/gerar_politica.dart`.

## Em resumo

As fotos, os vídeos e os documentos nunca passam por servidor nosso: vão direto do seu aparelho para o Google Drive da sua própria conta.

O aplicativo guarda em servidor apenas um índice de texto, que é o que faz a linha do tempo e a busca funcionarem.

Não há publicidade, rastreamento, perfilamento nem venda de dados.

Você apaga tudo isso a qualquer momento, dentro do aplicativo, sem precisar pedir a ninguém.


## Quem é o responsável

Responsável pelo tratamento dos dados pessoais (controlador, nos termos do Art. 4(7) do GDPR): Rodrigo Andrade Brigido, pessoa física, desenvolvedor individual.

Contato: mybabytimecapsule@gmail.com

Todo pedido relativo a dados pessoais deve ser enviado a esse endereço. Respondemos em até 30 dias, que é o prazo do Art. 12(3) do GDPR.


## O que fica no seu Google Drive

Ao entrar, você autoriza o aplicativo a usar o Google Drive da sua conta com o escopo drive.file. Esse escopo dá acesso apenas aos arquivos que o próprio aplicativo cria. Ele não permite ler, listar ou modificar nenhum outro arquivo do seu Drive, e essa limitação é imposta pelo Google, não por nós.

Ficam no seu Drive, dentro da pasta "Meu Bebê - Cápsula do Tempo": as fotos, os vídeos, os desenhos e os documentos que você enviar.

Ficam também dois arquivos de texto, escritos pelo aplicativo: um com o cadastro e os registros de crescimento, e um por carta que você escrever. Eles existem para que este acervo continue fazendo sentido sem o aplicativo: uma foto se explica sozinha numa pasta, uma carta e um registro de peso não.

Esses arquivos são seus. Não temos cópia deles, não conseguimos vê-los e não temos meio técnico de acessá-los fora do aplicativo em uso na sua sessão.

As coordenadas de GPS são removidas de toda foto antes do envio.


## O que fica no nosso índice

O índice fica no Cloud Firestore, serviço do Google Cloud. Esta é a lista completa do que ele guarda:

- Do cadastro: nome da criança, data de nascimento, sexo informado, peso e altura de nascimento, nome do hospital se preenchido, e o identificador da pasta raiz no seu Drive.

- De cada memória: tipo, data, idade em dias, título, descrição e, no caso das cartas, o texto integral da carta; peso e altura dos registros de crescimento; a data de abertura, quando a memória é lacrada; e o identificador, nome, tipo e tamanho de cada arquivo no seu Drive.

- De apoio: o cache dos identificadores das pastas criadas no Drive e o progresso das sugestões que você marcou.

- Da autenticação: o Firebase Authentication guarda seu identificador de usuário, seu email, seu nome e o endereço da sua foto de perfil do Google.

Cada índice é isolado por conta. Regras de segurança no servidor impedem que qualquer conta leia ou escreva os dados de outra, e essas regras são verificadas por testes automatizados a cada alteração do aplicativo.


## O que nunca sai do aparelho

Ajustes de lembretes, a marca de que a apresentação inicial já foi vista, as inspirações já vistas e lidas, a preferência de bloqueio por biometria e o cache de miniaturas das fotos.

Nada disso é enviado para lugar nenhum. Sai do aparelho quando você sai da conta ou desinstala o aplicativo.


## O que não é coletado

Esta é uma lista fechada:

- Nenhum dado de uso, estatística ou analytics. O aplicativo não tem Google Analytics, Firebase Analytics, Crashlytics nem qualquer ferramenta equivalente.

- Nenhuma publicidade e nenhum identificador de anúncio.

- Nenhum perfilamento e nenhuma decisão automatizada sobre você.

- Nenhuma localização, contatos, agenda, microfone em segundo plano ou histórico de navegação.

- Nenhuma venda, aluguel ou troca de dados com terceiros, em nenhuma circunstância.

- Nenhuma notificação vinda de servidor. Os lembretes são calculados e agendados dentro do próprio aparelho.

Se isso mudar em alguma versão futura, esta política muda antes, e o aviso aparece no aplicativo.


## Com quem os dados são compartilhados

Apenas com o Google, que atua como operador (processador, nos termos do Art. 28 do GDPR), pelos serviços de que o aplicativo depende:

- Google Sign-In, para entrar na sua conta.

- Firebase Authentication, para manter a sessão.

- Cloud Firestore, para guardar o índice.

- Google Drive, para guardar os seus arquivos, na sua conta.

Não há nenhum outro destinatário. Não usamos rede de anúncios, corretor de dados nem serviço de análise.

O tratamento pelo Google é regido pelos termos dele, em policies.google.com/privacy


## Base legal de cada tratamento

- Cadastro, índice e envio de arquivos: execução do contrato, Art. 6(1)(b) do GDPR. Sem esses dados o aplicativo não funciona.

- Autenticação: execução do contrato, Art. 6(1)(b).

- Notificações de lembrete: consentimento, Art. 6(1)(a), revogável a qualquer momento nas Configurações.

Não usamos interesse legítimo como base para nada, e não há tratamento que você não consiga interromper apagando a conta.


## Dados de uma criança

O aplicativo guarda dados sobre uma criança, mas não é destinado a crianças e não é usado por elas. Quem instala, cadastra e envia conteúdo é o pai, a mãe ou o responsável legal, maior de 18 anos.

Ao cadastrar uma criança, você declara ser o responsável legal dela e ter autoridade para fornecer esses dados.

Não há cadastro público, perfil visível, rede social, comentários, mensagens entre usuários nem qualquer forma de exposição do conteúdo a terceiros. A cápsula é privada por construção: os arquivos estão no Drive de quem os enviou e o índice é isolado por conta.

Quando a criança atingir a maioridade, os dados dela passam a ser dela. O aplicativo foi desenhado para que isso não dependa de nós: a conta do Google onde tudo está pode ser entregue diretamente.


## Por quanto tempo, e como apagar

Os dados ficam enquanto a conta existir. Não há prazo automático de descarte, porque a finalidade do produto é justamente a guarda de longo prazo.

Em Perfil, "Apagar minha conta e meus dados", você apaga todo o índice no nosso servidor, varrendo cada coleção, com confirmação no servidor e não no cache local; a sua conta de autenticação; e todos os dados guardados no aparelho.

Na mesma tela você escolhe o que fazer com a pasta do Google Drive. Por padrão ela é mantida, porque os arquivos são seus e o aplicativo nunca teve cópia deles. Se você pedir, ele move a pasta para a lixeira do seu Drive.

A exclusão do índice é imediata e não reversível. Não guardamos backup dos seus dados depois da exclusão.


## Seus direitos

Sob o GDPR (Arts. 15 a 22) e a LGPD (Art. 18), você tem direito a acesso, correção, exclusão, portabilidade, restrição de tratamento, oposição e revogação do consentimento.

Na prática, quase todos se exercem sem falar conosco: os dados estão visíveis no aplicativo, editáveis no aplicativo e apagáveis no aplicativo. Para qualquer coisa que o aplicativo não resolva, escreva para mybabytimecapsule@gmail.com

Você não precisa justificar o pedido, e exercer um direito nunca custa nada.


## Transferência internacional

A infraestrutura do Google pode tratar dados fora do Espaço Econômico Europeu. Essas transferências são cobertas pelas Cláusulas Contratuais Padrão aprovadas pela Comissão Europeia, adotadas pelo Google nos termos do Art. 46 do GDPR.


## Segurança

Todo tráfego é cifrado em trânsito, e os dados em repouso são cifrados pela infraestrutura do Google. O acesso ao índice é controlado por regras de segurança no servidor que exigem autenticação e restringem cada conta aos próprios dados. O aplicativo oferece bloqueio por biometria ou senha do aparelho.

Nenhum sistema é totalmente seguro, e não prometemos o contrário. O que reduz o risco de forma estrutural aqui é o desenho: as fotos e os vídeos não estão em servidor nosso, então não existe uma base de mídia nossa para ser vazada.


## Menores de idade

O aplicativo não se destina a menores de 18 anos e não deve ser usado por eles.


## Mudanças nesta política

Alterações relevantes são anunciadas dentro do aplicativo antes de entrarem em vigor. A data no topo indica a versão vigente, e as versões anteriores ficam disponíveis no histórico público do repositório.


## Reclamação

Se você acreditar que o tratamento dos seus dados viola a lei, pode reclamar à autoridade de controle do seu país. No Brasil, a ANPD. Na União Europeia, a autoridade do seu Estado-membro de residência.
