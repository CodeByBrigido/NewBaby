import '../../models/baby_gender.dart';
import 'copy.dart';

/// As frases sobre a criança, em francês.
///
/// Como o espanhol, o francês não antepõe artigo a nome próprio: "as fotos
/// da Maria" vira `les photos de Marie`, não `les photos de la Marie`. A
/// diferença própria do francês é a elisão: `de` vira `d'` diante de nome
/// que começa com vogal ou h mudo, e ignorar isso deixaria "d'Emma" escrito
/// como "de Emma", um erro visível para qualquer leitor da língua.
class CopyFr extends Copy {
  const CopyFr(super.name, super.gender);

  static final RegExp _somVocalico = RegExp(
    r'^[aeiouyàâäéèêëïîôöùûühAEIOUYÀÂÄÉÈÊËÏÎÔÖÙÛÜH]',
  );

  /// `de ` ou `d'`, conforme o nome começar com som vocálico.
  String get _de => _somVocalico.hasMatch(name) ? "d'" : 'de ';

  @override
  String get theName => name;

  @override
  String get ofName => '$_de$name';

  @override
  String get forName => 'pour $name';

  /// Frase preposicional invariável ("appartient à elle"/"à elle"), que não
  /// precisa concordar com o substantivo possuído - ao contrário de um
  /// adjetivo possessivo francês, que concordaria com "le compte" ou
  /// "l'ensemble" de formas diferentes.
  @override
  String get theirs => switch (gender) {
    BabyGender.girl => 'à elle',
    BabyGender.boy => 'à lui',
    null => "à l'enfant",
  };

  @override
  String get onboardingSubtitle =>
      'Chaque instant mérite d\'être gardé en mémoire.\n'
      'On commence à conserver cette histoire ?';

  @override
  String get addPhotoHint =>
      hasName ? 'Ajouter les photos $ofName' : 'Ajouter des photos';

  @override
  String get addVideoHint =>
      hasName ? 'Ajouter les vidéos $ofName' : 'Ajouter des vidéos';

  @override
  String get addLetterHint =>
      hasName ? 'Écrire une lettre $forName' : 'Écrire une lettre';

  @override
  String get timelineEmptyBody => hasName
      ? "Touchez le + pour garder le premier souvenir $ofName."
      : 'Touchez le + pour garder le premier souvenir.';

  @override
  String get babyInfo => hasName ? 'Informations $ofName' : 'Informations';

  @override
  String get lettersEmptyBody => hasName
      ? 'Écrivez le premier message pour que $theName le lise un jour.'
      : 'Écrivez le premier message, pour être lu un jour.';

  @override
  String get letterHint => hasName ? 'Pour $theName 💜' : "Pour l'avenir 💜";

  @override
  String get letterKeepsafe => hasName
      ? "Cette lettre reste conservée dans le Drive $ofName. Un jour, "
            'quand le compte appartiendra $theirs, elle sera là à attendre.'
      : "Cette lettre reste conservée dans le Drive de l'enfant. Un jour, "
            "quand le compte appartiendra à l'enfant, elle sera là à "
            'attendre.';

  @override
  String get driveOwner => hasName ? name : 'vous';

  @override
  String get ofTheChild => switch (gender) {
    BabyGender.girl => 'de votre fille',
    BabyGender.boy => 'de votre fils',
    null => "de l'enfant",
  };

  @override
  String get childsGoogleDrive => 'dans le Google Drive $ofTheChild';

  @override
  String get deleteConfirmTitle =>
      hasName ? 'Supprimer la capsule $ofName ?' : 'Supprimer le compte ?';

  @override
  String get deleteConfirmBody =>
      'Cette action est irréversible. Nous ne conservons aucune '
      'sauvegarde, et il n\'y a aucun moyen de récupérer cela après '
      'coup.\n\n'
      '${hasName ? "Disparaît maintenant tout ce que nous conservons à propos $ofName" : "Disparaît maintenant tout ce que nous conservons à propos de l'enfant"}'
      ' : le profil, toute la chronologie et le texte des lettres.\n\n'
      'Les photos et les vidéos restent sur Google Drive, car elles vous '
      'appartiennent.';

  @override
  String get deleteConfirmAction => 'Supprimer pour toujours';

  @override
  String get aboutStorage =>
      'Les photos, les vidéos et les documents restent conservés sur '
      'votre propre compte Google Drive, dans des dossiers organisés par '
      'âge. L\'application n\'est que la belle façon de tout feuilleter.'
      '\n\nMême dans de nombreuses années, sans cette application, '
      'l\'ensemble reste là : lisible, organisé et '
      '${hasName ? theirs : "à qui de droit"}.';
}
