/// A página pública de exclusão de conta.
///
/// O Google Play exige, desde 2023, que todo aplicativo com criação de conta
/// tenha **duas** portas de saída: uma dentro do aplicativo e um endereço na
/// internet que funcione para quem já desinstalou. Esta é a segunda.
///
/// Mora aqui, junto da política, pelo mesmo motivo: o texto é uma lista de
/// promessas sobre o que o código faz, e um teste prende cada uma delas ao
/// código de verdade. Uma página de exclusão que descreve um aplicativo que
/// não existe mais é pior que não ter página, porque quem a lê toma decisão
/// com base nela.
library;

import 'account_deletion_de.dart';
import 'account_deletion_en.dart';
import 'account_deletion_es.dart';
import 'account_deletion_fr.dart';
import 'account_deletion_it.dart';
import 'strings.dart';

import 'privacy_policy.dart';

/// Data da última revisão do texto.
const String deletionPageDate = '18 de agosto de 2026';

/// Prazo máximo para atender um pedido que chega por email.
///
/// Trinta dias é o limite do GDPR (Art. 12(3)) para responder ao titular, e
/// é o número que a página promete. Na prática o pedido é atendido em
/// poucos dias: o que leva tempo é o vaivém de confirmação, e não a
/// exclusão em si.
const int deletionDeadlineDays = 30;

/// O nome da pasta e o escopo aparecem escritos por extenso, e não lidos de
/// [DriveService] e [AuthService], porque este arquivo precisa compilar em
/// Dart puro: é dele que `tool/gerar_exclusao.dart` gera o `.md` público, e
/// importar os serviços traria os plugins do Flutter junto.
///
/// A cópia à mão não fica solta: o `exclusao_test.dart` compara as duas
/// frases com os valores reais do código e quebra se alguém mudar um sem
/// mudar o outro.
const List<PrivacySection> accountDeletionPagePt = <PrivacySection>[
  PrivacySection(
    title: 'O que esta página é',
    body: <String>[
      'Esta página explica como pedir a exclusão da sua conta do '
          'aplicativo Meu Bebê: Cápsula do Tempo e de todos os dados '
          'associados a ela.',
      'Ela existe para funcionar mesmo que você já tenha desinstalado o '
          'aplicativo. Você não precisa instalar nada, criar cadastro nem '
          'entrar em lugar nenhum para usar o que está aqui.',
      'O direito de apagar existe com nomes diferentes em lugares '
          'diferentes: apagamento no GDPR (Art. 17) e no UK GDPR, eliminação '
          'na LGPD (Art. 18), exclusão na CCPA da Califórnia, e direitos '
          'equivalentes em várias outras jurisdições. Aqui o caminho é o '
          'mesmo para todo mundo, e não condicionamos a solicitação à '
          'indicação do país onde você mora.',
      'Responsável pelo tratamento: $privacyController. Contato: '
          '$privacyEmail',
    ],
  ),
  PrivacySection(
    title: 'Se você ainda tem o aplicativo',
    body: <String>[
      'Este é o caminho mais rápido, e o único que apaga tudo na hora, '
          'sem esperar por ninguém:',
      '• Abra o aplicativo e entre com a conta que quer apagar',
      '• Toque em Perfil',
      '• Toque em "Exclusão de conta e de dados"',
      '• Leia a página, que é esta mesma, e toque em "Ir para a exclusão '
          'da conta", no fim dela',
      '• Escolha o que fazer com a pasta do Google Drive',
      '• Toque em "Apagar minha conta e meus dados" e confirme',
      'A leitura vem antes do botão de propósito. Apagar é imediato e não '
          'pode ser desfeito, e ninguém deveria chegar ao botão sem saber o '
          'que fica e o que some.',
      'Sobre a pasta do Drive, são duas opções: mantê-la, que é o padrão, '
          'porque os arquivos são seus e nunca tivemos cópia deles; ou '
          'mandá-la para a lixeira do seu Drive.',
    ],
  ),
  PrivacySection(
    title: 'Se você não tem mais o aplicativo',
    body: <String>[
      'Escreva para $privacyEmail com o assunto "Excluir minha conta".',
      'O pedido precisa partir do endereço de email da conta Google que '
          'você usou para entrar no aplicativo. É o único jeito de sabermos '
          'que o pedido é seu: sem essa checagem, qualquer pessoa poderia '
          'apagar o acervo de outra escrevendo um email.',
      'Responderemos para esse mesmo endereço confirmando a exclusão. Se '
          'o pedido chegar de outro endereço, vamos pedir que ele seja '
          'reenviado do endereço da conta, e não vamos apagar nada até isso '
          'acontecer.',
      'O pedido será processado sem demora indevida e, quando estiver '
          'sujeito ao GDPR, em regra no prazo de um mês. Quando outra '
          'legislação aplicável estabelecer prazo diferente, observaremos o '
          'prazo legal correspondente. Você não precisa justificar o pedido, '
          'e não cobramos pela solicitação de exclusão.',
    ],
  ),
  PrivacySection(
    title: 'O que é apagado',
    body: <String>[
      'Tudo o que existe do seu lado no nosso servidor, sem exceção:',
      '• O cadastro da criança: nome, data e hora de nascimento, sexo, '
          'peso, altura e hospital',
      '• A linha do tempo inteira: a data, a idade, o título, a descrição '
          'e o tipo de cada memória',
      '• O texto integral das cartas, que é o único conteúdo seu que fica '
          'no nosso índice',
      '• Os identificadores das pastas do Drive e o progresso das '
          'sugestões',
      '• A sua conta de autenticação, com o email e o nome vindos do '
          'Google',
      'A exclusão dos dados do índice e da conta de autenticação é '
          'iniciada imediatamente após a confirmação e, uma vez concluída, '
          'não pode ser desfeita pelo aplicativo. Não mantemos backup '
          'operacional do índice para restaurar uma conta excluída. Dados que '
          'precisem ser conservados por obrigação legal ou registros técnicos '
          'mantidos pela infraestrutura do Google poderão permanecer pelo '
          'período aplicável, sem serem utilizados para finalidades '
          'incompatíveis.',
    ],
  ),
  PrivacySection(
    title: 'O que não é apagado, e por quê',
    body: <String>[
      'As suas fotos, vídeos, desenhos e documentos **não são apagados**, '
          'porque eles nunca foram nossos.',
      'Eles ficam numa pasta chamada "Meu Bebê - Cápsula do Tempo", no '
          'Google Drive da sua própria conta. O aplicativo nunca teve cópia '
          'deles em servidor nenhum: eles vão do seu aparelho direto para o '
          'seu Drive.',
      'Depois que a conta é apagada, o aplicativo revoga a autorização '
          'utilizada para acessar os arquivos criados por ele no Google '
          'Drive. O escopo utilizado é o '
          'https://www.googleapis.com/auth/drive.file, que limita o acesso '
          'aos arquivos criados ou abertos pelo aplicativo dentro das '
          'permissões concedidas pelo Google. Após a revogação, o aplicativo '
          'deixa de ter autorização para operar esses arquivos. Por isso, os '
          'arquivos permanecem sob o controle da sua conta Google, salvo se '
          'você optar por apagá-los diretamente no Drive ou, quando '
          'disponível, solicitar ao aplicativo que os envie para a lixeira '
          'antes da exclusão da conta.',
      'Se você também quiser apagar os arquivos, faça direto no Drive, e '
          'leva dois toques:',
      '• Abra drive.google.com com a mesma conta',
      '• Ache a pasta "Meu Bebê - Cápsula do Tempo"',
      '• Clique com o botão direito e escolha "Remover"',
      'Se preferir solicitar ao aplicativo que envie a pasta para a '
          'lixeira do Drive, faça isso **antes** de concluir a exclusão da '
          'conta, na mesma tela de exclusão. A disponibilidade e o resultado '
          'definitivo da operação dependem das permissões concedidas e dos '
          'mecanismos do Google Drive.',
    ],
  ),
  PrivacySection(
    title: 'A assinatura Premium não é cancelada aqui',
    body: <String>[
      'Se você assina o plano Premium, **apagar a conta não cancela a '
          'assinatura**. São duas coisas em lugares diferentes: a conta é '
          'nossa, a assinatura é da Google Play.',
      'Sem cancelar lá, a cobrança anual continua acontecendo mesmo '
          'depois de a cápsula ter sido apagada. Nós não temos acesso à sua '
          'forma de pagamento e não conseguimos cancelar por você.',
      'Cancele antes de apagar a conta, e leva poucos toques:',
      '• Abra a Google Play Store',
      '• Toque na sua foto, no alto à direita',
      '• Vá em "Pagamentos e assinaturas" e depois em "Assinaturas"',
      '• Escolha Meu Bebê: Cápsula do Tempo e toque em "Cancelar '
          'assinatura"',
      'Cancelando, o Premium normalmente continua valendo até o fim do '
          'período já pago. Se você apagar a conta antes disso, o acesso ao '
          'Premium associado àquela conta será encerrado quando a conta for '
          'excluída. Não oferecemos devolução proporcional por iniciativa '
          'própria, salvo quando exigida pela legislação aplicável ou pelas '
          'políticas de reembolso do Google Play.',
    ],
  ),
  PrivacySection(
    title: 'Apagar só uma parte',
    body: <String>[
      'Você não precisa apagar a conta inteira para apagar alguma coisa.',
      'Dentro do aplicativo, qualquer memória pode ir para a lixeira e '
          'ser apagada de vez, uma a uma. O cadastro da criança pode ser '
          'editado a qualquer momento. Nada disso passa por nós nem depende '
          'de pedido.',
      'Se o que você quer é parar de usar o aplicativo sem apagar nada, '
          'basta sair da conta em Perfil: os dados no aparelho são apagados '
          'na saída, e o acervo no seu Drive continua onde está.',
    ],
  ),
  PrivacySection(
    title: 'Uma conta por criança',
    body: <String>[
      'O aplicativo usa uma conta do Google por criança, para que um dia '
          'cada uma receba a própria cápsula inteira.',
      'Isso quer dizer que apagar uma conta apaga a cápsula daquela '
          'criança, e só dela. Se você usa mais de uma conta, o pedido '
          'precisa ser feito uma vez para cada, a partir do email de cada '
          'uma.',
      'A assinatura Premium também é por conta. Apagar a cápsula de uma '
          'criança não mexe na assinatura das outras, e cada uma segue '
          'valendo, ou sendo cancelada, por si.',
    ],
  ),
  PrivacySection(
    title: 'Registros técnicos',
    body: <String>[
      'A infraestrutura que hospeda o índice utiliza serviços do Firebase '
          'e Google Cloud. Como qualquer serviço de nuvem, esses serviços '
          'podem manter registros técnicos e operacionais necessários à '
          'segurança, funcionamento, prevenção de abuso e auditoria, sujeitos '
          'às políticas de retenção aplicáveis do Google.',
      'Esses registros de infraestrutura não fazem parte do índice que '
          'mantemos para operar sua cápsula e não são utilizados por nós para '
          'reconstruir o conteúdo excluído. Alguns registros técnicos podem '
          'permanecer por períodos determinados pelo Google ou por obrigações '
          'legais aplicáveis. Por isso, não prometemos que absolutamente '
          'nenhum registro técnico possa existir em todos os sistemas de '
          'infraestrutura após a exclusão.',
    ],
  ),
  PrivacySection(
    title: 'Account deletion (English)',
    body: <String>[
      'To delete your Meu Bebê: Cápsula do Tempo account and all '
          'associated data, open the app and go to Profile > "Exclusão de '
          'conta e de dados" (Account and data deletion), then tap "Ir para a '
          'exclusão da conta" (Go to account deletion) at the bottom of that '
          'page, choose what to do with your Google Drive folder, and confirm '
          'with "Apagar minha conta e meus dados" (Delete my account and my '
          'data). You can also email $privacyEmail from the Google account '
          'address you signed in with.',
      'This works the same wherever you live. Deletion is offered to '
          'everyone under the same general process, whether or not your '
          'country has a law requiring it (including GDPR Art. 17, UK GDPR, '
          'LGPD Art. 18, CCPA, and equivalent rights elsewhere).',
      'We delete the server-side index associated with the account '
          '(including the child profile, timeline metadata, letter text, and '
          'folder identifiers) and the application\'s authentication account. '
          'Deletion is initiated immediately after confirmation and cannot be '
          'undone by the app once completed. We do not keep an operational '
          'backup of the deleted index for account restoration. Technical or '
          'legally required records may remain for the applicable retention '
          'period. Email requests are handled without undue delay and, where '
          'GDPR applies, normally within one month.',
      'If you subscribe to the Premium plan, deleting your account does '
          '**not** cancel the subscription: billing is handled by Google '
          'Play, not by us. Cancel it in the Play Store under "Payments and '
          'subscriptions" before deleting your account, otherwise the yearly '
          'charge continues.',
      'Your photos, videos, drawings and documents are stored in your own '
          'Google Drive and are not part of the server-side index that we '
          'delete. The app uses the '
          'https://www.googleapis.com/auth/drive.file scope, which limits '
          'access to files created or opened by the app within the '
          'permissions granted by Google. On account deletion, the app '
          'revokes its authorization to access those files. You can delete '
          'the folder "Meu Bebê - Cápsula do Tempo" yourself in Google Drive, '
          'or request that the app send it to the Drive trash before '
          'completing account deletion when that option is available.',
    ],
  ),
];

/// A página de exclusão na língua ativa.
///
/// O nome de antes vira este getter, para as telas continuarem escrevendo
/// `accountDeletionPage` sem saber que agora há duas versões. Deixou de ser `const`
/// porque a escolha é feita em tempo de execução.
List<PrivacySection> get accountDeletionPage => switch (codigoAtivo) {
  'en' => accountDeletionPageEn,
  'es' => accountDeletionPageEs,
  'fr' => accountDeletionPageFr,
  'de' => accountDeletionPageDe,
  'it' => accountDeletionPageIt,
  _ => accountDeletionPagePt,
};

/// O arquivo público, gerado deste mesmo texto.
String exclusaoEmMarkdown() {
  final StringBuffer saida = StringBuffer()
    ..writeln('# Exclusão de conta e de dados')
    ..writeln()
    ..writeln('**Meu Bebê: Cápsula do Tempo**')
    ..writeln()
    ..writeln('_Última atualização: ${deletionPageDate}_')
    ..writeln()
    ..writeln(
      '> Este arquivo é gerado de `lib/core/l10n/account_deletion.dart`. '
      'Não edite aqui: edite lá e rode `dart run tool/gerar_exclusao.dart`.',
    );

  for (final PrivacySection secao in accountDeletionPage) {
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
