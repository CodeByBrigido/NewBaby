import '../../models/baby_gender.dart';
import 'copy.dart';

/// As frases sobre a criança, em português.
///
/// O trabalho aqui é a concordância. A regra do produto é **usar o nome
/// sempre que houver nome**, e isso dissolve quase toda ela: "as memórias da
/// Maria" e "as memórias do Pedro" só diferem no artigo. Quando não há nome,
/// a frase é reescrita para não precisar de referente, em vez de cair numa
/// forma genérica desajeitada.
class CopyPt extends Copy {
  const CopyPt(super.name, super.gender);

  /// `a` / `o`, para concordar com o nome próprio.
  ///
  /// Cadastro sem sexo informado devolve vazio: "de Maria" é correto em
  /// português e é melhor que arriscar "do Maria".
  String get _article => switch (gender) {
    BabyGender.girl => 'a',
    BabyGender.boy => 'o',
    null => '',
  };

  @override
  String get theName => _article.isEmpty ? name : '$_article $name';

  @override
  String get ofName => _article.isEmpty ? 'de $name' : 'd$_article $name';

  @override
  String get forName =>
      _article.isEmpty ? 'para $name' : 'para $_article $name';

  @override
  String get theirs => switch (gender) {
    BabyGender.girl => 'dela',
    BabyGender.boy => 'dele',
    null => 'da criança',
  };

  @override
  String get onboardingSubtitle =>
      'Cada momento merece ser lembrado.\n'
      'Vamos começar a guardar essa história?';

  @override
  String get addPhotoHint =>
      hasName ? 'Adicionar fotos $ofName' : 'Adicionar fotos';

  @override
  String get addVideoHint =>
      hasName ? 'Adicionar vídeos $ofName' : 'Adicionar vídeos';

  @override
  String get addLetterHint =>
      hasName ? 'Escrever uma carta $forName' : 'Escrever uma carta';

  @override
  String get timelineEmptyBody => hasName
      ? 'Toque no + para guardar a primeira memória $ofName.'
      : 'Toque no + para guardar a primeira memória.';

  @override
  String get babyInfo => hasName ? 'Informações $ofName' : 'Informações';

  @override
  String get lettersEmptyBody => hasName
      ? 'Escreva a primeira mensagem para $theName ler um dia.'
      : 'Escreva a primeira mensagem para ser lida um dia.';

  @override
  String get letterHint => hasName ? 'Para $theName 💜' : 'Para o futuro 💜';

  @override
  String get letterKeepsafe => hasName
      ? 'Esta carta fica guardada no Drive $ofName. Um dia, quando a conta '
            'for $theirs, ela vai estar lá esperando.'
      : 'Esta carta fica guardada no Drive da criança. Um dia, quando a '
            'conta for dela, ela vai estar lá esperando.';

  @override
  String get driveOwner => hasName ? name : 'você';

  @override
  String get ofTheChild => switch (gender) {
    BabyGender.girl => 'da sua filha',
    BabyGender.boy => 'do seu filho',
    null => 'da criança',
  };

  @override
  String get deleteConfirmTitle =>
      hasName ? 'Apagar a cápsula $ofName?' : 'Apagar a conta?';

  @override
  String get deleteConfirmBody =>
      'Isto não pode ser desfeito. Não guardamos backup, e não há como '
      'recuperar depois.\n\n'
      '${hasName ? "Some agora tudo o que guardamos sobre $theName" : "Some agora tudo o que guardamos sobre a criança"}: '
      'o cadastro, a linha do tempo inteira e o texto das cartas.\n\n'
      'As fotos e os vídeos continuam no Google Drive, porque são seus.';

  @override
  String get deleteConfirmAction => 'Apagar para sempre';

  @override
  String get aboutStorage =>
      'As fotos, os vídeos e os documentos ficam guardados no Google Drive '
      'da sua própria conta, em pastas organizadas por idade. O aplicativo é '
      'só a maneira bonita de folhear tudo isso.\n\n'
      'Mesmo daqui a muitos anos, sem este aplicativo, o acervo continua '
      'lá: legível, organizado e ${hasName ? theirs : "de quem é de direito"}.';
}
