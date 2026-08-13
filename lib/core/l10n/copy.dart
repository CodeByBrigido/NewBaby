import '../../models/baby_gender.dart';
import '../../models/baby_profile.dart';

/// Os textos que dependem de quem é a criança.
///
/// Substituiu o antigo helper de gênero, que resolvia a concordância
/// escolhendo entre "sua bebê" e "seu bebê". Resolvia o problema errado: o
/// aplicativo guarda a vida de uma pessoa com nome, e chamá-la de "bebê"
/// envelhece mal - aos três anos ela já não é, e aos vinte e cinco, quando
/// abrir isto para reviver a infância, muito menos.
///
/// A regra passa a ser: **usar o nome sempre que houver nome.** Isso também
/// dissolve quase toda a concordância, porque "as memórias da Maria" e "as
/// memórias do Pedro" só diferem no artigo.
///
/// Quando não há nome (login, primeira etapa do cadastro), a frase é
/// reescrita para não precisar de referente nenhum, em vez de cair numa
/// forma genérica desajeitada.
class Copy {
  const Copy._(this._name, this._gender);

  /// Textos para uma criança já cadastrada.
  factory Copy.of(BabyProfile? profile) =>
      Copy._(profile?.firstName, profile?.gender);

  /// Antes de o cadastro existir.
  static const Copy generic = Copy._(null, null);

  final String? _name;
  final BabyGender? _gender;

  /// Se dá para falar da criança pelo nome.
  bool get hasName => _name != null && _name.trim().isNotEmpty;

  String get name => _name?.trim() ?? '';

  // ------------------------------------------------------------ concordância

  /// `a` / `o`, para concordar com o nome próprio.
  ///
  /// Cadastro sem sexo informado devolve vazio: "de Maria" é correto em
  /// português e é melhor que arriscar "do Maria".
  String get _article => switch (_gender) {
    BabyGender.girl => 'a',
    BabyGender.boy => 'o',
    null => '',
  };

  /// `a Maria` / `o Pedro` / `Maria`
  String get theName => _article.isEmpty ? name : '$_article $name';

  /// `da Maria` / `do Pedro` / `de Maria`
  String get ofName => _article.isEmpty ? 'de $name' : 'd$_article $name';

  /// `para a Maria` / `para o Pedro` / `para Maria`
  String get forName =>
      _article.isEmpty ? 'para $name' : 'para $_article $name';

  /// `dela` / `dele` - só para quando repetir o nome ficaria pesado.
  String get theirs => switch (_gender) {
    BabyGender.girl => 'dela',
    BabyGender.boy => 'dele',
    null => 'da criança',
  };

  // ----------------------------------------------------------------- frases
  //
  // Cada uma tem duas formas. A com nome é a que a pessoa vê em 99% do uso.
  // A sem nome não é uma versão pior da mesma frase: é outra frase, escrita
  // para não precisar do referente.

  /// Subtítulo do cadastro. Nunca tem nome: é onde o nome está sendo digitado.
  ///
  /// A quebra de linha é escrita à mão porque as duas frases são duas ideias,
  /// e deixar o texto quebrar sozinho poria "Vamos começar" no fim da
  /// primeira linha em alguns aparelhos e não em outros.
  String get onboardingSubtitle =>
      'Cada momento merece ser lembrado.\n'
      'Vamos começar a guardar essa história?';

  String get addPhotoHint =>
      hasName ? 'Adicionar fotos $ofName' : 'Adicionar fotos';

  String get addVideoHint =>
      hasName ? 'Adicionar vídeos $ofName' : 'Adicionar vídeos';

  String get addLetterHint =>
      hasName ? 'Escrever uma carta $forName' : 'Escrever uma carta';

  String get timelineEmptyBody => hasName
      ? 'Toque no + para guardar a primeira memória $ofName.'
      : 'Toque no + para guardar a primeira memória.';

  /// Título da tela de cadastro da criança.
  ///
  /// Com nome, o problema de concordância que existia aqui simplesmente
  /// desaparece: "Informações da Maria" não precisa escolher entre
  /// "da bebê" e "do bebê".
  String get babyInfo => hasName ? 'Informações $ofName' : 'Informações';

  String get lettersEmptyBody => hasName
      ? 'Escreva a primeira mensagem para $theName ler um dia.'
      : 'Escreva a primeira mensagem para ser lida um dia.';

  String get letterHint => hasName ? 'Para $theName 💜' : 'Para o futuro 💜';

  /// O que fica escrito embaixo do campo, enquanto a carta está sendo
  /// escrita.
  ///
  /// É a promessa do produto inteiro dita no único lugar em que ela é
  /// literal. Foto e vídeo se explicam sozinhos; uma carta não, porque
  /// quem escreve precisa saber que existe alguém do outro lado e que a
  /// espera vale a pena. Sem isso, escrever para o futuro parece falar
  /// sozinho.
  String get letterKeepsafe => hasName
      ? 'Esta carta fica guardada no Drive $ofName. Um dia, quando a conta '
            'for $theirs, ela vai estar lá esperando.'
      : 'Esta carta fica guardada no Drive da criança. Um dia, quando a '
            'conta for dela, ela vai estar lá esperando.';

  /// Rodapé do menu lateral, depois de "Guardado com amor no Drive de".
  String get driveOwner => hasName ? name : 'você';

  // ------------------------------------------------- a última pergunta feita

  /// A pergunta do aviso que aparece antes de apagar a conta.
  ///
  /// Com o nome, e não "a conta": é o que separa uma confirmação de rotina
  /// de uma pergunta que a pessoa lê de verdade. Ninguém pula um aviso que
  /// diz o nome do próprio filho.
  String get deleteConfirmTitle =>
      hasName ? 'Apagar a cápsula $ofName?' : 'Apagar a conta?';

  /// O corpo do aviso.
  ///
  /// Escrito para o aviso, e não copiado do cartão que está logo acima na
  /// tela: um aviso que repete o que a pessoa acabou de ler é um aviso que
  /// ela pula. E a frase que mais importa vem primeiro, não no fim.
  String get deleteConfirmBody =>
      'Isto não pode ser desfeito. Não guardamos backup, e não há como '
      'recuperar depois.\n\n'
      '${hasName ? "Some agora tudo o que guardamos sobre $theName" : "Some agora tudo o que guardamos sobre a criança"}: '
      'o cadastro, a linha do tempo inteira e o texto das cartas.\n\n'
      'As fotos e os vídeos continuam no Google Drive, porque são seus.';

  /// O botão que confirma.
  ///
  /// Diz o que acontece ao ser tocado. "Sim" e "Confirmar" servem para
  /// qualquer coisa, e é justamente por isso que são tocados no automático.
  String get deleteConfirmAction => 'Apagar para sempre';

  String get aboutStorage =>
      'As fotos, os vídeos e os documentos ficam guardados no Google Drive '
      'da sua própria conta, em pastas organizadas por idade. O aplicativo é '
      'só a maneira bonita de folhear tudo isso.\n\n'
      'Mesmo daqui a muitos anos, sem este aplicativo, o acervo continua '
      'lá: legível, organizado e ${hasName ? theirs : "de quem é de direito"}.';
}
