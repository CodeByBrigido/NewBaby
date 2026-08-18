/// A política de privacidade, por inteiro.
///
/// Mora aqui, e não num arquivo de texto baixado da internet, por dois
/// motivos. O primeiro é que ler a política não pode depender de ter rede:
/// quem está decidindo se confia o registro de um filho a um aplicativo
/// merece poder ler os termos no avião. O segundo é que assim ela viaja
/// junto da versão: a política que você leu é a política daquela versão do
/// aplicativo, e não a que estiver no ar hoje.
///
/// O `POLITICA-DE-PRIVACIDADE.md` da raiz do repositório é gerado deste
/// mesmo conteúdo, e um teste confere que os dois não se separam.
library;

/// Data da última revisão do texto.
const String privacyPolicyDate = '18 de agosto de 2026';

/// Responsável pelo tratamento, no sentido do Art. 4(7) do GDPR.
///
/// O nome completo é exigência legal: só o endereço de email não identifica
/// o controlador para quem quiser exercer um direito judicialmente.
const String privacyController = 'Rodrigo Andrade Brigido';
const String privacyEmail = 'mybabytimecapsule@gmail.com';

/// Uma seção do documento.
class PrivacySection {
  const PrivacySection({required this.title, required this.body});

  final String title;

  /// Parágrafos. Itens de lista começam com `• `.
  final List<String> body;
}

const List<PrivacySection> privacyPolicy = <PrivacySection>[
  PrivacySection(
    title: 'Em resumo',
    body: <String>[
      'As fotos, os vídeos e os documentos nunca passam por '
          'servidor nosso: vão direto do seu aparelho para o Google Drive da '
          'sua própria conta.',
      'O aplicativo guarda em servidor apenas um índice de texto, que é o '
          'que faz a linha do tempo e a busca funcionarem.',
      'Não há publicidade, rastreamento, perfilamento nem venda de dados.',
      'A assinatura Premium é cobrada pelo Google Play. Nenhum dado de '
          'pagamento passa por nós.',
      'Você apaga tudo isso a qualquer momento, dentro do aplicativo, sem '
          'precisar pedir a ninguém.',
    ],
  ),
  PrivacySection(
    title: 'Quem é o responsável',
    body: <String>[
      'Responsável pelo tratamento dos dados pessoais (controlador, nos '
          'termos do Art. 4(7) do GDPR): $privacyController, pessoa física, '
          'desenvolvedor individual.',
      'Contato: $privacyEmail',
      'Todo pedido relativo a dados pessoais deve ser enviado a esse '
          'endereço. Respondemos em até 30 dias, que é o prazo do Art. 12(3) '
          'do GDPR.',
    ],
  ),
  PrivacySection(
    title: 'O que fica no seu Google Drive',
    body: <String>[
      'Ao entrar, você autoriza o aplicativo a usar o Google Drive da sua '
          'conta com o escopo drive.file. Esse escopo dá acesso apenas aos '
          'arquivos que o próprio aplicativo cria. Ele não permite ler, '
          'listar ou modificar nenhum outro arquivo do seu Drive, e essa '
          'limitação é imposta pelo Google, não por nós.',
      'Ficam no seu Drive, dentro da pasta "Meu Bebê - Cápsula do Tempo": '
          'as fotos, os vídeos, os desenhos e os documentos que você enviar.',
      'Ficam também dois arquivos de texto, escritos pelo aplicativo: um '
          'com o cadastro e os registros de crescimento, e um por carta que '
          'você escrever. Eles existem para que este acervo continue fazendo '
          'sentido sem o aplicativo: uma foto se explica sozinha numa pasta, '
          'uma carta e um registro de peso não.',
      'Esses arquivos são seus. Não temos cópia deles, não conseguimos '
          'vê-los e não temos meio técnico de acessá-los fora do aplicativo '
          'em uso na sua sessão.',
      'As coordenadas de GPS são removidas de toda foto antes do envio.',
    ],
  ),
  PrivacySection(
    title: 'O que fica no nosso índice',
    body: <String>[
      'O índice fica no Cloud Firestore, serviço do Google Cloud. Esta é a '
          'lista completa do que ele guarda:',
      '• Do cadastro: nome da criança, data de nascimento, sexo informado, '
          'peso e altura de nascimento, nome do hospital se preenchido, e o '
          'identificador da pasta raiz no seu Drive.',
      '• Do plano: um único valor, sim ou não, dizendo se a conta tem a '
          'assinatura Premium. Nada mais sobre pagamento passa por aqui.',
      '• De cada memória: tipo, data, idade em dias, título, descrição e, no '
          'caso das cartas, o texto integral da carta; peso e altura dos '
          'registros de crescimento; a data de abertura, quando a memória é '
          'lacrada; e o identificador, nome, tipo e tamanho de cada arquivo '
          'no seu Drive.',
      '• De apoio: o cache dos identificadores das pastas criadas no Drive e '
          'o progresso das sugestões que você marcou.',
      '• Da autenticação: o Firebase Authentication guarda seu identificador '
          'de usuário, seu email, seu nome e o endereço da sua foto de '
          'perfil do Google.',
      'Cada índice é isolado por conta. Regras de segurança no servidor '
          'impedem que qualquer conta leia ou escreva os dados de outra, e '
          'essas regras são verificadas por testes automatizados a cada '
          'alteração do aplicativo.',
    ],
  ),
  PrivacySection(
    title: 'O pagamento da assinatura',
    body: <String>[
      'Quem cobra a assinatura Premium é o Google Play, e não nós. Cartão, '
          'endereço de cobrança, nota fiscal e histórico de compras ficam com '
          'ele, sob a política de privacidade dele.',
      'Nós não recebemos, não vemos e não guardamos nenhum dado de pagamento. '
          'Do lado de cá fica só o valor de sim ou não descrito acima, no '
          'índice daquela conta, que é o que faz o aplicativo saber se libera '
          'guardar carta, desenho, documento e crescimento.',
      'Como a assinatura vale por conta, e cada criança tem a própria conta '
          'do Google, esse valor nunca é comparado entre contas nem usado '
          'para ligar uma conta à outra.',
    ],
  ),
  PrivacySection(
    title: 'O que nunca sai do aparelho',
    body: <String>[
      'Ajustes de lembretes, a marca de que a apresentação inicial já foi '
          'vista, as inspirações já vistas e lidas, a preferência de '
          'bloqueio por '
          'biometria e o cache de miniaturas das fotos.',
      'Nada disso é enviado para lugar nenhum. Sai do aparelho quando você '
          'sai da conta ou desinstala o aplicativo.',
    ],
  ),
  PrivacySection(
    title: 'O que não é coletado',
    body: <String>[
      'Esta é uma lista fechada:',
      '• Nenhum dado de uso, estatística ou analytics. O aplicativo não tem '
          'Google Analytics, Firebase Analytics, Crashlytics nem qualquer '
          'ferramenta equivalente.',
      '• Nenhuma publicidade e nenhum identificador de anúncio.',
      '• Nenhum perfilamento e nenhuma decisão automatizada sobre você.',
      '• Nenhuma localização, contatos, agenda, microfone em segundo plano '
          'ou histórico de navegação.',
      '• Nenhuma venda, aluguel ou troca de dados com terceiros, em '
          'nenhuma circunstância.',
      '• Nenhuma notificação vinda de servidor. Os lembretes são calculados '
          'e agendados dentro do próprio aparelho.',
      'Se isso mudar em alguma versão futura, esta política muda antes, e o '
          'aviso aparece no aplicativo.',
    ],
  ),
  PrivacySection(
    title: 'Com quem os dados são compartilhados',
    body: <String>[
      'Apenas com o Google, que atua como operador (processador, nos termos '
          'do Art. 28 do GDPR), pelos serviços de que o aplicativo depende:',
      '• Google Sign-In, para entrar na sua conta.',
      '• Firebase Authentication, para manter a sessão.',
      '• Cloud Firestore, para guardar o índice.',
      '• Google Drive, para guardar os seus arquivos, na sua conta.',
      '• Google Play, para cobrar a assinatura Premium e responder se ela '
          'está ativa, para quem assinar.',
      'Não há nenhum outro destinatário. Não usamos rede de anúncios, '
          'corretor de dados nem serviço de análise.',
      'O tratamento pelo Google é regido pelos termos dele, em '
          'policies.google.com/privacy',
    ],
  ),
  PrivacySection(
    title: 'Base legal de cada tratamento',
    body: <String>[
      '• Cadastro, índice e envio de arquivos: execução do contrato, Art. '
          '6(1)(b) do GDPR. Sem esses dados o aplicativo não funciona.',
      '• Autenticação: execução do contrato, Art. 6(1)(b).',
      '• Notificações de lembrete: consentimento, Art. 6(1)(a), revogável a '
          'qualquer momento nas Configurações.',
      '• Registro do plano contratado: execução do contrato, Art. 6(1)(b). '
          'Sem ele não há como saber o que a assinatura liberou.',
      'Não usamos interesse legítimo como base para nada, e não há '
          'tratamento que você não consiga interromper apagando a conta.',
    ],
  ),
  PrivacySection(
    title: 'Dados de uma criança',
    body: <String>[
      'O aplicativo guarda dados sobre uma criança, mas não é destinado a '
          'crianças e não é usado por elas. Quem instala, cadastra e envia '
          'conteúdo é o pai, a mãe ou o responsável legal, maior de 18 anos.',
      'Ao cadastrar uma criança, você declara ser o responsável legal dela e '
          'ter autoridade para fornecer esses dados.',
      'Não há cadastro público, perfil visível, rede social, comentários, '
          'mensagens entre usuários nem qualquer forma de exposição do '
          'conteúdo a terceiros. A cápsula é privada por construção: os '
          'arquivos estão no Drive de quem os enviou e o índice é isolado '
          'por conta.',
      'Quando a criança atingir a maioridade, os dados dela passam a ser '
          'dela. O aplicativo foi desenhado para que isso não dependa de '
          'nós: a conta do Google onde tudo está pode ser entregue '
          'diretamente.',
    ],
  ),
  PrivacySection(
    title: 'Por quanto tempo, e como apagar',
    body: <String>[
      'Os dados ficam enquanto a conta existir. Não há prazo automático de '
          'descarte, porque a finalidade do produto é justamente a guarda de '
          'longo prazo.',
      'Em Perfil, "Apagar minha conta e meus dados", você apaga todo o '
          'índice no nosso servidor, varrendo cada coleção, com confirmação '
          'no servidor e não no cache local; a sua conta de autenticação; e '
          'todos os dados guardados no aparelho.',
      'Na mesma tela você escolhe o que fazer com a pasta do Google Drive. '
          'Por padrão ela é mantida, porque os arquivos são seus e o '
          'aplicativo nunca teve cópia deles. Se você pedir, ele move a '
          'pasta para a lixeira do seu Drive.',
      'A exclusão do índice é imediata e não reversível. Não guardamos '
          'backup dos seus dados depois da exclusão.',
    ],
  ),
  PrivacySection(
    title: 'Seus direitos',
    body: <String>[
      'Sob o GDPR (Arts. 15 a 22) e a LGPD (Art. 18), você tem direito a '
          'acesso, correção, exclusão, portabilidade, restrição de '
          'tratamento, oposição e revogação do consentimento.',
      'Na prática, quase todos se exercem sem falar conosco: os dados estão '
          'visíveis no aplicativo, editáveis no aplicativo e apagáveis no '
          'aplicativo. Para qualquer coisa que o aplicativo não resolva, '
          'escreva para $privacyEmail',
      'Você não precisa justificar o pedido, e exercer um direito nunca '
          'custa nada.',
    ],
  ),
  PrivacySection(
    title: 'Transferência internacional',
    body: <String>[
      'A infraestrutura do Google pode tratar dados fora do Espaço '
          'Econômico Europeu. Essas transferências são cobertas pelas '
          'Cláusulas Contratuais Padrão aprovadas pela Comissão Europeia, '
          'adotadas pelo Google nos termos do Art. 46 do GDPR.',
    ],
  ),
  PrivacySection(
    title: 'Segurança',
    body: <String>[
      'Todo tráfego é cifrado em trânsito, e os dados em repouso são '
          'cifrados pela infraestrutura do Google. O acesso ao índice é '
          'controlado por regras de segurança no servidor que exigem '
          'autenticação e restringem cada conta aos próprios dados. O '
          'aplicativo oferece bloqueio por biometria ou senha do aparelho.',
      'Nenhum sistema é totalmente seguro, e não prometemos o contrário. O '
          'que reduz o risco de forma estrutural aqui é o desenho: as fotos '
          'e os vídeos não estão em servidor nosso, então não existe uma '
          'base de mídia nossa para ser vazada.',
    ],
  ),
  PrivacySection(
    title: 'Menores de idade',
    body: <String>[
      'O aplicativo não se destina a menores de 18 anos e não deve ser '
          'usado por eles.',
    ],
  ),
  PrivacySection(
    title: 'Mudanças nesta política',
    body: <String>[
      'Alterações relevantes são anunciadas dentro do aplicativo antes de '
          'entrarem em vigor. A data no topo indica a versão vigente, e as '
          'versões anteriores ficam disponíveis no histórico público do '
          'repositório.',
    ],
  ),
  PrivacySection(
    title: 'Reclamação',
    body: <String>[
      'Se você acreditar que o tratamento dos seus dados viola a lei, pode '
          'reclamar à autoridade de controle do seu país. No Brasil, a '
          'ANPD. Na União Europeia, a autoridade do seu Estado-membro de '
          'residência.',
    ],
  ),
];

/// O mesmo conteúdo, em Markdown, para o arquivo público do repositório.
///
/// Fica aqui junto do texto, e não numa ferramenta à parte, porque assim o
/// arquivo publicado e a tela nunca podem divergir: são a mesma fonte.
String politicaEmMarkdown() {
  final StringBuffer saida = StringBuffer()
    ..writeln('# Política de Privacidade')
    ..writeln()
    ..writeln('**Meu Bebê: Cápsula do Tempo**')
    ..writeln()
    ..writeln('_Última atualização: ${privacyPolicyDate}_')
    ..writeln()
    ..writeln(
      '> Este arquivo é gerado de `lib/core/l10n/privacy_policy.dart`, '
      'que é o mesmo texto exibido dentro do aplicativo. Não edite aqui: '
      'edite lá e rode `dart run tool/gerar_politica.dart`.',
    );

  for (final PrivacySection secao in privacyPolicy) {
    saida
      ..writeln()
      ..writeln('## ${secao.title}')
      ..writeln();
    for (final String paragrafo in secao.body) {
      saida
        ..writeln(
          paragrafo.startsWith('• ')
              ? '- ${paragrafo.substring(2)}'
              : paragrafo,
        )
        ..writeln();
    }
  }

  return '${saida.toString().trimRight()}\n';
}
