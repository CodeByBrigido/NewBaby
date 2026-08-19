# Política de Privacidade

**Meu Bebê: Cápsula do Tempo**

_Última atualização: 18 de agosto de 2026_

> Este arquivo é gerado de `lib/core/l10n/privacy_policy.dart`, que é o mesmo texto exibido dentro do aplicativo. Não edite aqui: edite lá e rode `dart run tool/gerar_politica.dart`.

## Em resumo

As fotos, os vídeos e os documentos nunca passam por servidor nosso: vão direto do seu aparelho para o Google Drive da sua própria conta.

O aplicativo guarda em servidor apenas um índice de texto, que é o que faz a linha do tempo e a busca funcionarem.

Não há publicidade, rastreamento, perfilamento nem venda de dados.

A assinatura Premium é cobrada pelo Google Play. Nenhum dado de pagamento passa por nós.

Você apaga tudo isso a qualquer momento, dentro do aplicativo, sem precisar pedir a ninguém.


## Quem é o responsável

Responsável pelo tratamento dos dados pessoais (controlador, nos termos do Art. 4(7) do GDPR): Rodrigo Andrade Brigido, pessoa física, desenvolvedor individual, estabelecido na Irlanda.

Estar estabelecido dentro da União Europeia tem duas consequências boas para você. A primeira é que o GDPR se aplica na origem, e não por extensão: não há discussão sobre alcance. A segunda é que a autoridade principal é a Comissão de Proteção de Dados da Irlanda, pelo mecanismo de balcão único do Art. 56 do GDPR, e você pode reclamar tanto a ela quanto à autoridade do seu próprio país.

Contato: mybabytimecapsule@gmail.com

Todo pedido relativo a dados pessoais deve ser enviado a esse endereço. Respondemos em até 30 dias, que é o prazo do Art. 12(3) do GDPR.


## Seu papel e o nosso

Registrar a própria família é, na linguagem do GDPR, uma "atividade exclusivamente pessoal ou doméstica" (Art. 2(2)(c)). Isso quer dizer que, ao guardar a memória do seu filho, **você não se torna controlador de dados pessoais perante a lei**, e não assume nenhuma das obrigações que a lei impõe a uma empresa. Você continua sendo só o pai, a mãe ou o responsável, registrando a própria criança.

O aplicativo é para esse uso: pessoal e familiar, sem fim comercial. Usá-lo para registrar crianças que não são suas nem estão sob sua responsabilidade legal, ou para oferecer este serviço a terceiros, foge do que os planos cobrem.

Nós temos dois papéis diferentes, e eles não se misturam. Para o índice (o cadastro, a linha do tempo, o texto das cartas), somos controlador, no sentido do Art. 4(7) do GDPR: decidimos como esse índice é tratado, e respondemos por ele. Para os seus arquivos no Google Drive, não somos nada: eles vão do seu aparelho direto para a sua própria conta do Google, por uma autorização que você dá diretamente a ela, e nós nunca recebemos cópia, nunca vemos e não temos como acessá-los. Ali, a sua relação é com o Google, e a nossa função é só a de um programa que opera com a sua permissão.


## O que fica no seu Google Drive

Ao entrar, você autoriza o aplicativo a usar o Google Drive da sua conta com o escopo drive.file. Esse escopo dá acesso apenas aos arquivos que o próprio aplicativo cria. Ele não permite ler, listar ou modificar nenhum outro arquivo do seu Drive, e essa limitação é imposta pelo Google, não por nós.

Ficam no seu Drive, dentro da pasta "Meu Bebê - Cápsula do Tempo": as fotos, os vídeos, os desenhos e os documentos que você enviar.

Ficam também dois arquivos de texto, escritos pelo aplicativo: um com o cadastro e os registros de crescimento, e um por carta que você escrever. Eles existem para que este acervo continue fazendo sentido sem o aplicativo: uma foto se explica sozinha numa pasta, uma carta e um registro de peso não.

Esses arquivos são seus. Não temos cópia deles, não conseguimos vê-los e não temos meio técnico de acessá-los fora do aplicativo em uso na sua sessão.

As coordenadas de GPS são removidas de toda foto antes do envio.


## O que fica no nosso índice

O índice fica no Cloud Firestore, serviço do Google Cloud. Esta é a lista completa do que ele guarda:

- Do cadastro: nome da criança, data de nascimento, sexo informado, peso e altura de nascimento, nome do hospital se preenchido, e o identificador da pasta raiz no seu Drive.

- Do plano: um único valor, sim ou não, dizendo se a conta tem a assinatura Premium. Nada mais sobre pagamento passa por aqui.

- De cada memória: tipo, data, idade em dias, título, descrição e, no caso das cartas, o texto integral da carta; peso e altura dos registros de crescimento; a data de abertura, quando a memória é lacrada; e o identificador, nome, tipo e tamanho de cada arquivo no seu Drive.

- De apoio: o cache dos identificadores das pastas criadas no Drive e o progresso das sugestões que você marcou.

- Da autenticação: o Firebase Authentication guarda seu identificador de usuário, seu email, seu nome e o endereço da sua foto de perfil do Google.

Cada índice é isolado por conta. Regras de segurança no servidor impedem que qualquer conta leia ou escreva os dados de outra, e essas regras são verificadas por testes automatizados a cada alteração do aplicativo.


## O pagamento da assinatura

Quem cobra a assinatura Premium é o Google Play, e não nós. Cartão, endereço de cobrança, nota fiscal e histórico de compras ficam com ele, sob a política de privacidade dele.

Nós não recebemos, não vemos e não guardamos nenhum dado de pagamento. Do lado de cá fica só o valor de sim ou não descrito acima, no índice daquela conta, que é o que faz o aplicativo saber se libera guardar carta, desenho, documento e crescimento.

Como a assinatura vale por conta, e cada criança tem a própria conta do Google, esse valor nunca é comparado entre contas nem usado para ligar uma conta à outra.


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

- Google Play, para cobrar a assinatura Premium e responder se ela está ativa, para quem assinar.

Não há nenhum outro destinatário. Não usamos rede de anúncios, corretor de dados nem serviço de análise.

O tratamento pelo Google é regido pelos termos dele, em policies.google.com/privacy

O GDPR exige, no Art. 28, um contrato por escrito entre controlador e operador antes de qualquer tratamento. Esse contrato existe: é o Cloud Data Processing Addendum do Google, aceito ao usar o Google Cloud e o Firebase, e cobre exatamente os serviços listados acima.


## Base legal de cada tratamento

- Cadastro, índice e envio de arquivos: execução do contrato, Art. 6(1)(b) do GDPR. Sem esses dados o aplicativo não funciona.

- Autenticação: execução do contrato, Art. 6(1)(b).

- Notificações de lembrete: consentimento, Art. 6(1)(a), revogável a qualquer momento nas Configurações.

- Registro do plano contratado: execução do contrato, Art. 6(1)(b). Sem ele não há como saber o que a assinatura liberou.

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


## Seus direitos, onde quer que você more

O nome da lei muda de país para país. Os direitos, na prática, são os mesmos, e nós damos todos eles a todo mundo, sem perguntar onde você mora: acesso, correção, exclusão, portabilidade, restrição, oposição e revogação do consentimento.

- União Europeia e Espaço Econômico Europeu: GDPR, Arts. 15 a 22.

- Reino Unido: UK GDPR e Data Protection Act 2018, com os mesmos artigos.

- Brasil: LGPD, Art. 18.

- Argentina: Ley 25.326, com uma reforma em andamento. Argentina é um dos poucos países fora da Europa com decisão de adequação da União Europeia, o que diz bastante sobre o nível de proteção que a lei de lá já exige.

- Uruguai: Ley 18.331, também com adequação da União Europeia.

- Chile: Ley 19.628, sendo substituída pela Ley 21.719, aprovada em dezembro de 2024 e inspirada no GDPR, com entrada em vigor progressiva.

- Colômbia: Ley 1581 de 2012 (Habeas Data), com regra própria e mais exigente para dado de criança: o tratamento precisa respeitar o melhor interesse dela, e não só o consentimento do responsável. É um padrão mais alto que o nosso desenho já atende, porque o único propósito aqui é a própria cápsula da criança, sem exposição a terceiro nenhum.

- Peru: Ley 29733. Equador: Lei Orgânica de Proteção de Dados Pessoais (LOPDP), de 2021.

- Nos demais países da América do Sul, sem lei abrangente própria ainda: os mesmos direitos, pela nossa política.

- Estados Unidos: a Califórnia tem a lei mais exigente (CCPA e CPRA, ver a seção seguinte), e uma lista crescente de outros estados como Virgínia, Colorado, Connecticut e Utah tem leis parecidas, com os mesmos direitos de saber, apagar, corrigir, portar e recusar venda ou compartilhamento. Como não vendemos nem compartilhamos dado nenhum em circunstância alguma, esse último direito já vem exercido por padrão, em todo estado, tenha ele lei específica ou não.

- Suíça: nLPD. Canadá: PIPEDA. Austrália: Privacy Act e os Australian Privacy Principles. África do Sul: POPIA. Japão: APPI. Índia: DPDPA, a partir da entrada em vigor de cada dispositivo.

- Em qualquer outro lugar: os mesmos direitos, pela nossa política, mesmo onde a lei local ainda não os exija.

Na prática, quase todos se exercem sem falar conosco: os dados estão visíveis no aplicativo, editáveis no aplicativo e apagáveis no aplicativo. Para qualquer coisa que o aplicativo não resolva, escreva para mybabytimecapsule@gmail.com

Você não precisa justificar o pedido, exercer um direito nunca custa nada, e nunca reduzimos o serviço de quem exerce um.


## Se você mora na Califórnia

A CCPA, alterada pela CPRA, pede que algumas frases sejam ditas com todas as letras, e todas elas são verdade aqui:

- **Não vendemos** informação pessoal, e nunca vendemos.

- **Não compartilhamos** informação pessoal para publicidade comportamental entre sites ou aplicativos. Não há publicidade nenhuma neste aplicativo.

- Não usamos nem divulgamos informação pessoal sensível para nada além de prestar o serviço que você pediu.

- Não oferecemos incentivo financeiro em troca de dados.

- Não discriminamos quem exerce um direito: o aplicativo funciona igual antes e depois.

Como não vendemos nem compartilhamos nada, não existe botão de "Do Not Sell or Share My Personal Information", porque não haveria o que desligar.

As categorias que coletamos, por que, e com quem são compartilhadas estão nas seções acima, e aquela lista é fechada.

Se você mora em outro estado americano com lei de privacidade própria, as mesmas seis frases acima valem para você também: elas descrevem como o aplicativo funciona, não uma exceção pensada só para quem mora na Califórnia.


## Transferência internacional

Os seus arquivos ficam no Google Drive da sua própria conta, e a localização deles é a que o Google dá à sua conta, não uma escolha nossa. O índice fica na infraestrutura do Cloud Firestore, que pode tratar dados fora do seu país.

Essas transferências são cobertas pelas Cláusulas Contratuais Padrão aprovadas pela Comissão Europeia, adotadas pelo Google nos termos do Art. 46 do GDPR, e pelo adendo do Reino Unido a essas mesmas cláusulas. O Google Cloud também é certificado no Data Privacy Framework entre a União Europeia e os Estados Unidos.

Para quem está no Brasil, a transferência se apoia no Art. 33 da LGPD, pelas mesmas cláusulas contratuais.

Nós não movemos dados para lugar nenhum por conta própria: não temos servidor, não fazemos cópia e não exportamos nada.


## Segurança

Todo tráfego é cifrado em trânsito, e os dados em repouso são cifrados pela infraestrutura do Google. O acesso ao índice é controlado por regras de segurança no servidor que exigem autenticação e restringem cada conta aos próprios dados. O aplicativo oferece bloqueio por biometria ou senha do aparelho.

Nenhum sistema é totalmente seguro, e não prometemos o contrário. O que reduz o risco de forma estrutural aqui é o desenho: as fotos e os vídeos não estão em servidor nosso, então não existe uma base de mídia nossa para ser vazada.

Se acontecer uma violação de dados que afete o índice, notificamos a Comissão de Proteção de Dados da Irlanda em até 72 horas depois de sabermos, como manda o Art. 33 do GDPR, e avisamos você diretamente quando o risco for alto para os seus direitos, como manda o Art. 34. Onde outra lei do seu país impuser prazo ou destinatário diferente, como a LGPD (Art. 48) ou a CCPA, cumprimos os dois.


## Crianças, e por que este aplicativo é diferente

Este aplicativo guarda dados **sobre** uma criança, e não é usado **por** ela. Quem instala, entra e registra é o pai, a mãe ou quem responde legalmente por ela, e precisa ser maior de idade.

Por isso o aplicativo não é dirigido a crianças no sentido da COPPA, a lei americana, nem se enquadra no programa de Famílias da Google Play: não há conteúdo feito para a criança usar, nem publicidade, nem coleta de dados de quem quer que seja menor de idade navegando por conta própria.

Os dados da criança que existem aqui foram digitados pelo responsável dela, com o propósito único de montar a cápsula que um dia será entregue à própria criança, sob a isenção de uso pessoal ou doméstico descrita na seção "Seu papel e o nosso". Sob a LGPD, essa mesma ideia está no Art. 14; sob a COPPA, é tratamento com consentimento verificável do responsável.

Quando a criança crescer e assumir a conta, ela passa a ser a titular desses dados e a exercer todos os direitos da seção acima diretamente, sem precisar de nós para nada.

Vários países vêm criando um código de proteção específico para produtos que uma criança pode vir a acessar, como o Children’s Code do Reino Unido. Nós não formalizamos certificação nenhuma nesse sentido, mas o desenho do aplicativo já segue os mesmos princípios: nenhuma publicidade, nenhum perfilamento, nenhuma notificação pensada para prender atenção, nenhum jogo, nenhuma recompensa por engajamento e nenhum compartilhamento público por padrão. Uma memória pode ainda ser lacrada, para só abrir numa data futura escolhida por quem a guardou, o oposto de um desenho pensado para maximizar uso.


## Mudanças nesta política

Alterações relevantes são anunciadas dentro do aplicativo antes de entrarem em vigor. A data no topo indica a versão vigente, e as versões anteriores ficam disponíveis no histórico público do repositório.


## Reclamação

Se você acreditar que o tratamento dos seus dados viola a lei, pode reclamar à autoridade do lugar onde mora, e não precisa falar conosco antes.

- Autoridade principal, para qualquer pessoa: Data Protection Commission da Irlanda, dataprotection.ie, que é a do lugar onde o responsável está estabelecido.

- União Europeia: você pode preferir a autoridade do seu próprio Estado-membro, e ela encaminha. A lista está em edpb.europa.eu

- Brasil: ANPD, gov.br/anpd

- Argentina: Agencia de Acceso a la Información Pública (AAIP).

- Uruguai: Unidad Reguladora y de Control de Datos Personales (URCDP).

- Chile: a nova Agencia de Protección de Datos Personales, à medida que a Ley 21.719 entrar em vigor.

- Colômbia: Superintendencia de Industria y Comercio (SIC).

- Reino Unido: ICO, ico.org.uk

- Suíça: PFPDT. Canadá: OPC. Austrália: OAIC.

- Califórnia: California Privacy Protection Agency, cppa.ca.gov, ou o Procurador-Geral do estado.

Se preferir tentar conosco primeiro, escreva para mybabytimecapsule@gmail.com. Respondemos em até 30 dias, e uma resposta nossa nunca é condição para você procurar a autoridade.
