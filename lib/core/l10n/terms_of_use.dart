/// Os termos de uso, por inteiro.
///
/// Mora aqui, e não num arquivo baixado da internet, pelo mesmo motivo da
/// política de privacidade: quem está decidindo se confia o registro de um
/// filho a um aplicativo merece poder ler os termos sem rede, e ler os termos
/// **daquela versão** do aplicativo, e não os que estiverem no ar hoje.
///
/// O `TERMOS-DE-USO.md` da raiz do repositório e a página `docs/termos.html`
/// são gerados deste mesmo conteúdo, e um teste confere que os três não se
/// separam.
///
/// **Isto não é parecer jurídico.** É um texto escrito para descrever com
/// honestidade o que o aplicativo faz e o que ele não promete. Antes de
/// publicar na loja, vale passar por alguém da área.
library;

import 'privacy_policy.dart';

/// Data da última revisão do texto.
const String termsOfUseDate = '18 de agosto de 2026';

/// Idade mínima para criar a conta, em anos.
///
/// Dezoito porque quem cria a conta assume responsabilidade por dados de uma
/// criança, e a LGPD trata dado de criança com cuidado reforçado: o
/// consentimento tem que vir de quem responde legalmente por ela.
const int idadeMinima = 18;

const List<PrivacySection> termsOfUse = <PrivacySection>[
  PrivacySection(
    title: 'Em resumo',
    body: <String>[
      'O aplicativo é gratuito e serve para registrar a infância de uma '
          'criança. Ele guarda os arquivos no Google Drive da conta que você '
          'usar, e não em servidor nosso.',
      'O conteúdo é seu. Nós não olhamos, não usamos e não vendemos nada do '
          'que você guarda.',
      'Você precisa ser maior de $idadeMinima anos e responsável pela '
          'criança para criar a conta.',
      'O aplicativo não substitui um backup, e nem conselho médico ou '
          'jurídico.',
    ],
  ),
  PrivacySection(
    title: 'O que este aplicativo é',
    body: <String>[
      'O Meu Bebê: Cápsula do Tempo é uma cápsula do tempo digital. Ele '
          'organiza fotos, '
          'vídeos, cartas, desenhos, documentos e registros de crescimento '
          'pela idade da criança, para que um dia ela mesma possa abrir e '
          'reviver a própria infância.',
      'O uso é gratuito. Não há compra dentro do aplicativo, assinatura nem '
          'anúncio. Se um dia isso mudar, o que já estiver guardado continua '
          'seu e acessível.',
      'Ele é um organizador, e não um serviço de armazenamento: o espaço '
          'usado é o da conta do Google, e as regras de espaço e de cobrança '
          'são as do Google, não as nossas.',
    ],
  ),
  PrivacySection(
    title: 'Quem pode usar',
    body: <String>[
      'Para criar uma conta você declara que tem pelo menos $idadeMinima '
          'anos e que é mãe, pai ou responsável legal pela criança cujos '
          'dados vai registrar, ou que tem autorização de quem é.',
      'Isto não é formalidade. Os dados de uma criança são tratados com '
          'cuidado reforçado pela Lei Geral de Proteção de Dados, e quem '
          'autoriza o registro precisa ser quem responde por ela.',
      'O aplicativo não é para a própria criança usar enquanto for criança. '
          'Ele é escrito para quem registra hoje, e feito para ser entregue a '
          'ela quando ela for adulta.',
    ],
  ),
  PrivacySection(
    title: 'A conta e o acesso',
    body: <String>[
      'A entrada é feita com uma conta do Google. Você é responsável por '
          'manter essa conta segura, e por quem tem acesso ao aparelho onde o '
          'aplicativo está instalado.',
      'O aplicativo pede permissão de acesso ao Google Drive apenas para os '
          'arquivos que ele mesmo cria. Ele não enxerga, não lista e não '
          'alcança nada que já estivesse na sua conta.',
      'Você pode revogar essa permissão a qualquer momento, pela sua conta do '
          'Google. Revogando, o aplicativo deixa de conseguir guardar coisas '
          'novas, e os arquivos já enviados continuam no seu Drive.',
    ],
  ),
  PrivacySection(
    title: 'O conteúdo é seu',
    body: <String>[
      'Tudo o que você guarda continua sendo seu. Nós não adquirimos direito '
          'nenhum sobre as suas fotos, os seus vídeos ou os textos que você '
          'escreve.',
      'Nós não pedimos licença de uso, não publicamos nada em lugar nenhum e '
          'não usamos o seu conteúdo para treinar sistema algum.',
      'Você é responsável pelo que guarda, inclusive por ter o direito de '
          'guardar aquilo. Fotografar a filha de outra pessoa e guardar aqui é '
          'uma decisão sua, e as consequências dela também.',
    ],
  ),
  PrivacySection(
    title: 'O que não se pode fazer',
    body: <String>[
      'Usar o aplicativo para guardar ou distribuir conteúdo ilegal, em '
          'especial qualquer material de abuso ou exploração de crianças.',
      'Usar o aplicativo para violar a privacidade de terceiros ou guardar '
          'conteúdo sobre pessoas que não autorizaram.',
      'Tentar burlar as proteções do aplicativo, acessar dados de outras '
          'contas ou interferir no funcionamento do serviço.',
      'Descobrindo qualquer uma dessas coisas, podemos encerrar o acesso ao '
          'aplicativo. Não temos como apagar o que está no Drive de outra '
          'pessoa, e denúncias de crime vão para as autoridades.',
    ],
  ),
  PrivacySection(
    title: 'O que não prometemos',
    body: <String>[
      'O aplicativo é oferecido como está. Não garantimos que ele estará '
          'sempre disponível, livre de falhas ou compatível com todo aparelho.',
      'Não somos um serviço de backup. Um arquivo enviado fica no seu Google '
          'Drive, e a preservação dele depende da sua conta do Google '
          'continuar existindo e com espaço. Guarde cópias do que for '
          'insubstituível.',
      'Dependemos de serviços do Google para entrar e para guardar. Se eles '
          'mudarem de regra, de preço ou saírem do ar, isso afeta o '
          'aplicativo, e não está sob nosso controle.',
      'As inspirações e as sugestões dentro do aplicativo são conteúdo '
          'editorial, escrito para acompanhar a fase da criança. Não são '
          'orientação médica, psicológica nem jurídica, e nenhuma delas diz o '
          'que uma criança "deveria" estar fazendo.',
    ],
  ),
  PrivacySection(
    title: 'Limite da nossa responsabilidade',
    body: <String>[
      'Na medida do que a lei permitir, não respondemos por perda de '
          'conteúdo, lucro cessante ou dano indireto decorrente do uso do '
          'aplicativo.',
      'Isto não afasta as responsabilidades que a lei brasileira não deixa '
          'afastar, inclusive as do Código de Defesa do Consumidor, quando ele '
          'se aplicar.',
    ],
  ),
  PrivacySection(
    title: 'Se você quiser parar',
    body: <String>[
      'Você pode sair do aplicativo, desinstalá-lo ou apagar a conta e os '
          'dados a qualquer momento, sem precisar dar explicação e sem custo.',
      'O caminho está descrito na página de exclusão de conta, e ele funciona '
          'mesmo para quem já desinstalou o aplicativo.',
      'Podemos encerrar o serviço ou a sua conta em caso de uso ilegal, ou se '
          'um dia o aplicativo deixar de existir. Nesse caso avisaremos com a '
          'antecedência que der, e os seus arquivos continuam no seu Google '
          'Drive, organizados em pastas legíveis, mesmo sem o aplicativo.',
    ],
  ),
  PrivacySection(
    title: 'Mudanças nestes termos',
    body: <String>[
      'Estes termos podem mudar quando o aplicativo mudar. A data no alto '
          'desta página diz de quando é a versão que você está lendo.',
      'Cada versão do aplicativo carrega dentro dela os termos daquela '
          'versão, então o texto que você leu ao instalar continua ali, mesmo '
          'que o que esteja no ar seja outro.',
      'Continuar usando depois de uma mudança significa concordar com ela. '
          'Se não concordar, você pode apagar a conta pelo caminho acima.',
    ],
  ),
  PrivacySection(
    title: 'Lei aplicável',
    body: <String>[
      'Estes termos são regidos pela lei brasileira.',
      'Fica eleito o foro do domicílio do usuário para resolver qualquer '
          'questão, como manda o Código de Defesa do Consumidor.',
    ],
  ),
  PrivacySection(
    title: 'Como falar com a gente',
    body: <String>[
      'Dúvida, reclamação ou pedido sobre os seus dados: $privacyEmail.',
      'Responsável: $privacyController.',
    ],
  ),
];

/// Os termos em Markdown, para o arquivo público do repositório.
///
/// Mesmo texto, outro formato: quem lê no GitHub e quem lê no aplicativo não
/// podem estar lendo coisas diferentes.
String termosEmMarkdown() {
  final StringBuffer saida = StringBuffer()
    ..writeln('# Termos de Uso')
    ..writeln()
    ..writeln('**Meu Bebê: Cápsula do Tempo**')
    ..writeln()
    ..writeln('_Última atualização: ${termsOfUseDate}_')
    ..writeln()
    ..writeln(
      '> Este arquivo é gerado de `lib/core/l10n/terms_of_use.dart`, '
      'que é o mesmo texto exibido dentro do aplicativo. Não edite aqui: '
      'edite lá e rode `dart run tool/gerar_termos.dart`.',
    );

  for (final PrivacySection secao in termsOfUse) {
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
