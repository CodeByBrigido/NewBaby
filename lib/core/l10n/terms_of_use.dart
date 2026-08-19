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

import 'terms_of_use_en.dart';
import 'strings.dart';

import 'privacy_policy.dart';

/// Data da última revisão do texto.
const String termsOfUseDate = '18 de agosto de 2026';

/// Idade mínima para criar a conta, em anos.
///
/// Dezoito porque quem cria a conta assume responsabilidade por dados de uma
/// criança, e a LGPD trata dado de criança com cuidado reforçado: o
/// consentimento tem que vir de quem responde legalmente por ela.
const int idadeMinima = 18;

const List<PrivacySection> termsOfUsePt = <PrivacySection>[
  PrivacySection(
    title: 'Em resumo',
    body: <String>[
      'O aplicativo serve para registrar a infância de uma criança. Ele '
          'guarda os arquivos de mídia e documentos diretamente no Google '
          'Drive da conta que você autorizar, e não em um servidor próprio '
          'nosso.',
      'Há dois planos. No Básico, que é gratuito, você lê tudo o que já '
          'guardou e continua guardando fotos e vídeos. O Premium, que é uma '
          'assinatura anual, acrescenta guardar cartas, desenhos, documentos '
          'e registros de crescimento.',
      'O conteúdo é seu. Nós não olhamos, não usamos e não vendemos nada '
          'do que você guarda.',
      'Você precisa ter pelo menos $idadeMinima anos, ou a maioridade do '
          'lugar onde mora se ela for maior, e ser responsável pela criança '
          'para criar a conta.',
      'O aplicativo não substitui um backup independente nem orientação '
          'médica, psicológica ou jurídica.',
    ],
  ),
  PrivacySection(
    title: 'O que este aplicativo é',
    body: <String>[
      'O Meu Bebê: Cápsula do Tempo é uma cápsula do tempo digital. Ele '
          'organiza fotos, vídeos, cartas, desenhos, documentos e registros '
          'de crescimento pela idade da criança, para que um dia ela mesma '
          'possa abrir e reviver a própria infância.',
      'Não há anúncio, e nunca houve. O que existe é uma assinatura '
          'opcional, descrita na seção seguinte, que amplia o que dá para '
          'guardar.',
      'Ele é um organizador, e não um serviço de armazenamento próprio: o '
          'espaço utilizado é o da conta Google que você autorizar. As regras '
          'de armazenamento, limites de espaço e cobrança aplicáveis ao '
          'Google Drive são as do Google.',
    ],
  ),
  PrivacySection(
    title: 'Os planos Básico e Premium',
    body: <String>[
      'O plano Básico é gratuito e não tem prazo. Com ele você entra, '
          'percorre a linha do tempo inteira, abre e lê tudo o que já está '
          'guardado, e continua guardando fotos e vídeos.',
      'O plano Premium é uma assinatura anual. Ele acrescenta guardar '
          'cartas, desenhos, documentos e registros de crescimento, que são '
          'as partes em que a cápsula deixa de ser um álbum.',
      'A assinatura vale para a conta que entra no aplicativo, e não para '
          'o aparelho nem para a pessoa que realizou o pagamento. Se o '
          'aplicativo utilizar contas separadas para diferentes crianças, a '
          'disponibilidade do Premium será determinada pela conta e pela '
          'assinatura correspondente, conforme a configuração vigente do '
          'serviço.',
      'Ficar sem a assinatura nunca fecha nada que já é seu. Ao fim do '
          'período pago, o aplicativo volta ao Básico: as cartas, os '
          'desenhos, os documentos e as medições que você já guardou '
          'continuam à vista, e os arquivos continuam no Google Drive da '
          'criança. O que para é guardar coisa nova desses quatro tipos.',
    ],
  ),
  PrivacySection(
    title: 'A assinatura, o pagamento e o cancelamento',
    body: <String>[
      'A compra da assinatura é processada pelo Google Play, e não pelo '
          'aplicativo. O preço e as condições aplicáveis aparecem no Google '
          'Play antes da confirmação da compra.',
      'A assinatura é anual e se renova sozinha, pela conta do Google '
          'Play que fez a compra, até que você a cancele.',
      'Cancelar ou alterar a assinatura é feito no Google Play, em '
          'Pagamentos e assinaturas. O pedido de reembolso também segue os '
          'mecanismos e as políticas aplicáveis do Google Play. Nós não temos '
          'acesso aos dados do seu meio de pagamento e não conseguimos '
          'alterar uma cobrança diretamente em seu nome.',
      'Ao cancelar, o acesso ao Premium normalmente continua até o fim do '
          'período já pago. Não oferecemos devolução proporcional por '
          'iniciativa própria, salvo quando exigida pela legislação aplicável '
          'ou pelas políticas de reembolso do Google Play. Os direitos '
          'obrigatórios do consumidor não são afastados por estes Termos.',
      'Se o preço mudar, a mudança vale para as renovações seguintes, e o '
          'Google Play avisa antes, pelo caminho que ele usa para isso. Você '
          'pode cancelar antes de a renovação acontecer.',
      'Onde a legislação aplicável conceder ao consumidor um direito de '
          'desistência ou arrependimento, esse direito prevalece sobre '
          'qualquer disposição destes Termos. Na União Europeia e no Reino '
          'Unido, o prazo legal geral para contratos à distância é de 14 '
          'dias, sujeito às regras e exceções aplicáveis ao tipo de serviço '
          'ou conteúdo digital contratado. No Brasil, o Código de Defesa do '
          'Consumidor prevê, em regra, 7 dias para contratações realizadas '
          'fora do estabelecimento comercial. Outros países podem estabelecer '
          'prazos e condições próprios. O pedido de cancelamento ou reembolso '
          'deve seguir o canal aplicável indicado pelo Google Play, sem '
          'prejuízo dos direitos legais do consumidor.',
      'Apagar a conta dentro do aplicativo não cancela a assinatura. São '
          'coisas separadas: uma é nossa, a outra é da Google Play. Cancele '
          'também na loja, senão a cobrança continua.',
    ],
  ),
  PrivacySection(
    title: 'Quem pode usar',
    body: <String>[
      'Para criar uma conta você declara que tem pelo menos $idadeMinima '
          'anos, ou a idade mínima legal aplicável no país onde mora, se esta '
          'for superior, e que é mãe, pai ou responsável pela criança cujos '
          'dados vai registrar, ou que possui autorização adequada para '
          'fazê-lo.',
      'Isto não é mera formalidade. Dados relacionados a crianças podem '
          'receber proteção reforçada em diferentes legislações, entre elas a '
          'LGPD no Brasil, o GDPR na União Europeia, o UK GDPR no Reino Unido '
          'e, em determinadas situações, a COPPA nos Estados Unidos. O '
          'usuário deve ter autoridade adequada para fornecer os dados da '
          'criança e utilizar o aplicativo para essa finalidade.',
      'O aplicativo não é para a própria criança usar enquanto for '
          'criança. Ele é escrito para quem registra hoje, e feito para ser '
          'entregue a ela quando ela for adulta.',
    ],
  ),
  PrivacySection(
    title: 'A conta e o acesso',
    body: <String>[
      'A entrada é feita com uma conta do Google. Você é responsável por '
          'manter essa conta segura e por controlar quem tem acesso ao '
          'aparelho onde o aplicativo está instalado.',
      'O aplicativo solicita o escopo de acesso ao Google Drive destinado '
          'aos arquivos que ele próprio cria. Dentro desse escopo, ele não '
          'solicita acesso geral aos arquivos preexistentes da sua conta.',
      'Você pode revogar essa permissão a qualquer momento, pela sua '
          'conta do Google. Revogando, o aplicativo deixa de conseguir '
          'guardar coisas novas, e os arquivos já enviados continuam no seu '
          'Drive.',
    ],
  ),
  PrivacySection(
    title: 'O conteúdo é seu',
    body: <String>[
      'Tudo o que você guarda continua sendo seu. Nós não adquirimos '
          'direito nenhum sobre as suas fotos, os seus vídeos ou os textos '
          'que você escreve.',
      'Nós não pedimos licença de uso, não publicamos nada em lugar '
          'nenhum e não usamos o seu conteúdo para treinar sistema algum.',
      'Você é responsável pelo que guarda, inclusive por ter o direito de '
          'guardar aquilo. Fotografar a filha de outra pessoa e guardar aqui '
          'é uma decisão sua, e as consequências dela também.',
    ],
  ),
  PrivacySection(
    title: 'O que não se pode fazer',
    body: <String>[
      'Usar o aplicativo para finalidade comercial, para prestar o '
          'serviço a terceiros sem autorização, ou para registrar dados de '
          'uma criança sem possuir autoridade adequada para isso. O '
          'aplicativo é destinado a uso pessoal e familiar. O enquadramento '
          'jurídico das atividades realizadas pelo usuário depende da '
          'legislação aplicável; estes Termos não pretendem declarar que o '
          'usuário esteja automaticamente isento de qualquer obrigação legal '
          'de proteção de dados.',
      'Usar o aplicativo para guardar, solicitar, produzir ou distribuir '
          'conteúdo ilegal, especialmente material de abuso ou exploração '
          'sexual de crianças e adolescentes.',
      'Usar o aplicativo para violar a privacidade de terceiros ou '
          'guardar conteúdo sobre pessoas que não autorizaram.',
      'Tentar burlar as proteções do aplicativo, acessar dados de outras '
          'contas ou interferir no funcionamento do serviço.',
      'Descobrindo qualquer uma dessas coisas, podemos encerrar o acesso '
          'ao aplicativo. Não temos como apagar o que está no Drive de outra '
          'pessoa, e denúncias de crime vão para as autoridades.',
    ],
  ),
  PrivacySection(
    title: 'O que não prometemos',
    body: <String>[
      'O aplicativo é oferecido como está. Não garantimos que ele estará '
          'sempre disponível, livre de falhas ou compatível com todo '
          'aparelho.',
      'Não somos um serviço de backup. Um arquivo enviado fica no seu '
          'Google Drive, e a preservação dele depende da sua conta do Google '
          'continuar existindo e com espaço. Guarde cópias do que for '
          'insubstituível.',
      'Dependemos de serviços do Google para entrar e para guardar. Se '
          'eles mudarem de regra, de preço ou saírem do ar, isso afeta o '
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
      'Na medida máxima permitida pela legislação aplicável, não seremos '
          'responsáveis por lucros cessantes, danos indiretos ou '
          'consequenciais decorrentes do uso ou da impossibilidade de uso do '
          'aplicativo. Isso não limita responsabilidades que não possam ser '
          'legalmente excluídas ou limitadas.',
      'Nada nesta seção exclui ou limita responsabilidade quando essa '
          'exclusão ou limitação for proibida pela legislação aplicável. Em '
          'particular, estes Termos não pretendem excluir responsabilidades '
          'por morte ou lesão corporal quando a lei não permitir, nem '
          'direitos do consumidor ou outros direitos que sejam legalmente '
          'irrenunciáveis. Se determinada limitação não for válida em sua '
          'jurisdição, ela será aplicada somente na extensão permitida, e as '
          'demais disposições destes Termos continuarão vigentes.',
    ],
  ),
  PrivacySection(
    title: 'Se você quiser parar',
    body: <String>[
      'Você pode sair do aplicativo, desinstalá-lo ou solicitar a '
          'exclusão da conta e dos dados a qualquer momento, sem precisar '
          'apresentar justificativa e sem cobrança por essa solicitação, '
          'ressalvadas eventuais obrigações legais de retenção.',
      'O caminho está descrito na página de exclusão de conta, e ele '
          'funciona mesmo para quem já desinstalou o aplicativo.',
      'Se você tiver o Premium, lembre de cancelar a assinatura também na '
          'Google Play. Apagar a conta aqui não a cancela lá.',
      'Podemos suspender ou encerrar o acesso à conta quando houver '
          'violação material destes Termos, uso ilegal, risco de segurança ou '
          'quando o serviço deixar de ser oferecido. Quando o encerramento '
          'decorrer de uma decisão planejada de descontinuação do serviço, '
          'procuraremos avisar com antecedência razoável, quando possível. '
          'Como os arquivos são armazenados no seu Google Drive, eles não são '
          'automaticamente apagados pelo encerramento do aplicativo, embora '
          'determinadas funções de organização ou leitura possam deixar de '
          'funcionar.',
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
      'Quando uma alteração material exigir novo consentimento ou aviso '
          'específico pela legislação aplicável, ela será apresentada de '
          'forma adequada antes de produzir efeitos. Nas demais alterações, a '
          'continuação do uso após a publicação da nova versão poderá '
          'significar aceitação dos Termos atualizados. Se não concordar com '
          'uma alteração aplicável, você poderá deixar de usar o aplicativo e '
          'solicitar a exclusão da conta, observados os direitos legais que '
          'se apliquem.',
    ],
  ),
  PrivacySection(
    title: 'Onde o aplicativo é oferecido',
    body: <String>[
      'O aplicativo é distribuído pela Google Play e pode ser usado em '
          'qualquer país onde a loja o ofereça. A interface e estes '
          'documentos existem em português e em inglês.',
      'Quem publica é uma pessoa física estabelecida na Irlanda, e não '
          'uma empresa constituída em cada país onde o aplicativo possa estar '
          'disponível. Isso não pretende reduzir direitos obrigatórios do '
          'consumidor ou de proteção de dados. A legislação aplicável à '
          'relação poderá depender do país de residência do consumidor e das '
          'regras de conflito de leis.',
      'A disponibilidade do aplicativo pode variar de acordo com as leis '
          'aplicáveis, sanções, políticas do Google Play e restrições de '
          'distribuição.',
      'O aplicativo pode não ser disponibilizado em determinados países '
          'ou regiões quando a legislação local, os requisitos de localização '
          'de dados, as sanções ou as condições técnicas dos serviços de '
          'nuvem utilizados impedirem legitimamente sua operação. A '
          'arquitetura do aplicativo depende da infraestrutura global do '
          'Google e pode não atender a requisitos locais que exijam '
          'armazenamento exclusivamente dentro de determinada jurisdição.',
    ],
  ),
  PrivacySection(
    title: 'Lei aplicável e onde reclamar',
    body: <String>[
      'Estes Termos são regidos pela lei irlandesa, sem prejuízo das '
          'normas obrigatórias de proteção do consumidor e de outras normas '
          'imperativas que sejam aplicáveis à sua relação com o aplicativo.',
      'Quando a legislação de conflito de leis determinar que a lei do '
          'país de residência habitual do consumidor se aplica, ou quando '
          'houver direitos obrigatórios que não possam ser afastados por '
          'contrato, esses direitos prevalecerão sobre qualquer disposição '
          'destes Termos que seja incompatível com eles.',
      'Quando a legislação aplicável conceder ao consumidor o direito de '
          'ajuizar ação perante os tribunais de seu país ou local de '
          'residência, esse direito permanece preservado. Na União Europeia, '
          'regras específicas de competência jurisdicional protegem '
          'consumidores em determinadas circunstâncias. No Brasil, o Código '
          'de Defesa do Consumidor também prevê proteção quanto ao foro do '
          'consumidor, conforme aplicável ao caso.',
      'Consumidores da União Europeia podem, quando disponível e '
          'aplicável ao tipo de disputa, recorrer aos mecanismos nacionais de '
          'resolução alternativa de litígios previstos pela legislação de seu '
          'país ou procurar o Centro Europeu do Consumidor competente. A '
          'antiga plataforma europeia de resolução de litígios em linha foi '
          'encerrada e não é indicada como canal de atendimento.',
      'Nada aqui obriga você a arbitragem nem pretende impedir o '
          'exercício de direitos processuais que a legislação aplicável '
          'assegure. Se preferir falar conosco antes de qualquer outra '
          'medida, o endereço está na última seção. Procuraremos responder '
          'sem demora indevida e, quando o pedido envolver direitos de '
          'proteção de dados, observaremos os prazos previstos na legislação '
          'aplicável.',
    ],
  ),
  PrivacySection(
    title: 'Como falar com a gente',
    body: <String>[
      'Dúvida, reclamação ou pedido sobre o aplicativo ou sobre os seus '
          'dados: $privacyEmail.',
      'Responsável: $privacyController.',
    ],
  ),
];

/// Os termos de uso na língua ativa.
///
/// O nome de antes vira este getter, para as telas continuarem escrevendo
/// `termsOfUse` sem saber que agora há duas versões. Deixou de ser `const`
/// porque a escolha é feita em tempo de execução.
List<PrivacySection> get termsOfUse => emIngles ? termsOfUseEn : termsOfUsePt;

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
