import '../../models/baby_gender.dart';

/// Os textos que mudam conforme a criança é menino ou menina.
///
/// Tudo que não muda continua em [S]. Aqui ficam só as frases em que o
/// português exige concordância — e a forma neutra, para as telas que
/// aparecem antes de o cadastro existir (login e início do cadastro).
///
/// A escolha do neutro é o masculino porque "bebê" é substantivo masculino
/// em português: "o bebê" vale para os dois, "a bebê" só para menina.
class G {
  const G._(this._gender);

  /// Textos para uma criança já cadastrada.
  factory G.of(BabyGender? gender) => G._(gender);

  /// Antes de saber o gênero — login e primeira parte do cadastro.
  static const G neutral = G._(null);

  final BabyGender? _gender;

  bool get _isGirl => _gender?.isGirl ?? false;

  String _pick(String feminine, String masculine) =>
      _isGirl ? feminine : masculine;

  // ---------------------------------------------------------- referências

  /// `sua bebê` / `seu bebê`
  String get yourBaby => _pick('sua bebê', 'seu bebê');

  /// `da sua bebê` / `do seu bebê`
  String get ofYourBaby => _pick('da sua bebê', 'do seu bebê');

  /// `dela` / `dele`
  String get theirs => _pick('dela', 'dele');

  /// `para ela` / `para ele`
  String get forThem => _pick('para ela', 'para ele');

  /// `a` / `o` — artigo para concordar com um nome próprio.
  String get article => _pick('a', 'o');

  // -------------------------------------------------------------- frases

  String get onboardingSubtitle =>
      'Vamos configurar o app para guardar todas as memórias $ofYourBaby.';

  String get addPhotoHint => 'Adicionar fotos $ofYourBaby';

  String get addVideoHint => 'Adicionar vídeos $ofYourBaby';

  String get addLetterHint => 'Escrever uma carta $forThem';

  String get timelineEmptyBody =>
      'Toque no + para guardar a primeira memória $ofYourBaby.';

  String get babyInfo => _pick('Informações da bebê', 'Informações do bebê');

  String get lettersEmptyBody =>
      'Escreva a primeira mensagem $forThem ler um dia.';

  String get letterHint => _pick('Para minha filha 💜', 'Para meu filho 💜');

  String get aboutStorage =>
      'As fotos, os vídeos e os documentos ficam guardados no Google Drive '
      'da sua própria conta, em pastas organizadas por idade. O aplicativo é '
      'só a maneira bonita de folhear tudo isso.\n\n'
      'Mesmo daqui a muitos anos, sem este aplicativo, o acervo continua '
      'lá — legível, organizado e $theirs.';
}
