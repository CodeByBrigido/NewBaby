import '../../models/baby_gender.dart';
import '../../models/baby_profile.dart';
import 'copy_en.dart';
import 'copy_pt.dart';
import 'strings.dart';

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
/// A base comum: quem é a criança, e nada mais.
///
/// As frases moram nas subclasses, uma por língua, porque a diferença entre
/// elas não é vocabulário: o português concorda em gênero e o inglês não, e
/// isso muda a **forma** da frase, não só as palavras dela.
abstract class Copy {
  const Copy(this._name, this._gender);

  /// Textos para uma criança já cadastrada, na língua ativa.
  factory Copy.of(BabyProfile? profile) =>
      Copy.para(profile?.firstName, profile?.gender);

  /// A mesma coisa, a partir das partes soltas. Os testes usam isto.
  factory Copy.para(String? nome, BabyGender? sexo) =>
      emIngles ? CopyEn(nome, sexo) : CopyPt(nome, sexo);

  /// Antes de o cadastro existir.
  ///
  /// Deixou de ser `const`: a língua é escolhida em tempo de execução, e uma
  /// constante teria congelado a primeira que aparecesse.
  static Copy get generic => Copy.para(null, null);

  final String? _name;
  final BabyGender? _gender;

  /// Se dá para falar da criança pelo nome.
  bool get hasName => _name != null && _name.trim().isNotEmpty;

  String get name => _name?.trim() ?? '';

  BabyGender? get gender => _gender;

  // ------------------------------------------------------------ concordância

  /// `a Maria` / `o Pedro` / `Maria` / `Maria` em inglês.
  String get theName;

  /// `da Maria` / `do Pedro` / `Maria's`
  String get ofName;

  /// `para a Maria` / `for Maria`
  String get forName;

  /// `dela` / `dele` / `hers` / `his`
  String get theirs;

  // ----------------------------------------------------------------- frases
  //
  // Cada língua escreve as suas. O que o português resolve com artigo, o
  // inglês resolve com possessivo, e algumas frases precisam ser
  // reescritas inteiras em vez de traduzidas.

  String get onboardingSubtitle;

  String get addPhotoHint;

  String get addVideoHint;

  String get addLetterHint;

  String get timelineEmptyBody;

  String get babyInfo;

  String get lettersEmptyBody;

  String get letterHint;

  String get letterKeepsafe;

  String get driveOwner;

  String get ofTheChild;

  String get deleteConfirmTitle;

  String get deleteConfirmBody;

  String get deleteConfirmAction;

  String get aboutStorage;
}
