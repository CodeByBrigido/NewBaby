import '../../models/baby_gender.dart';
import 'copy.dart';

/// As frases sobre a criança, em alemão.
///
/// O alemão resolve posse quase como o inglês: genitivo em -s, sem
/// apóstrofo antes de nome que não termina em som sibilante ("Marias
/// Briefe"), e só com apóstrofo quando termina em s/ß/z/x/tz ("Lukas'
/// Briefe"). Onde `theirs` precisaria de um adjetivo possessivo que
/// concorda em gênero e caso com o substantivo possuído - dois
/// substantivos diferentes, em duas frases diferentes - a frase foi escrita
/// em torno de "gehört" (pertence a), que pede só um pronome no dativo e
/// não concorda com nada.
class CopyDe extends Copy {
  const CopyDe(super.name, super.gender);

  static const Set<String> _terminacoesComApostrofo = <String>{
    's',
    'ß',
    'z',
    'x',
  };

  /// `Marias` / `Lukas'`.
  String get _genitivo {
    if (name.isEmpty) return name;
    final String ultima = name[name.length - 1].toLowerCase();
    return _terminacoesComApostrofo.contains(ultima) ? "$name'" : '${name}s';
  }

  @override
  String get theName => name;

  @override
  String get ofName => _genitivo;

  @override
  String get forName => 'für $name';

  /// Pronome no dativo, para usar com "gehört" (pertence a): "gehört ihr"
  /// (pertence a ela), e não um adjetivo possessivo que mudaria de forma
  /// conforme o substantivo que viesse depois.
  @override
  String get theirs => switch (gender) {
    BabyGender.girl => 'ihr',
    BabyGender.boy => 'ihm',
    null => 'dem Kind',
  };

  @override
  String get onboardingSubtitle =>
      'Jeder Moment verdient es, erinnert zu werden.\n'
      'Fangen wir an, diese Geschichte festzuhalten?';

  @override
  String get addPhotoHint =>
      hasName ? '$_genitivo Fotos hinzufügen' : 'Fotos hinzufügen';

  @override
  String get addVideoHint =>
      hasName ? '$_genitivo Videos hinzufügen' : 'Videos hinzufügen';

  @override
  String get addLetterHint =>
      hasName ? 'Einen Brief $forName schreiben' : 'Einen Brief schreiben';

  @override
  String get timelineEmptyBody => hasName
      ? 'Tippen Sie auf das +, um $_genitivo erste Erinnerung zu speichern.'
      : 'Tippen Sie auf das +, um die erste Erinnerung zu speichern.';

  @override
  String get babyInfo => hasName ? '$_genitivo Informationen' : 'Informationen';

  @override
  String get lettersEmptyBody => hasName
      ? 'Schreiben Sie die erste Nachricht, die $theName eines Tages lesen '
            'soll.'
      : 'Schreiben Sie die erste Nachricht, die eines Tages gelesen werden '
            'soll.';

  @override
  String get letterHint => hasName ? 'Für $theName 💜' : 'Für die Zukunft 💜';

  @override
  String get letterKeepsafe => hasName
      ? 'Dieser Brief bleibt in $_genitivo Drive gespeichert. Eines Tages, '
            'wenn das Konto $theirs gehört, wird er dort auf sie oder ihn '
            'warten.'
      : 'Dieser Brief bleibt im Drive des Kindes gespeichert. Eines Tages, '
            'wenn das Konto dem Kind gehört, wird er dort warten.';

  @override
  String get driveOwner => hasName ? name : 'Ihnen';

  @override
  String get ofTheChild => switch (gender) {
    BabyGender.girl => 'Ihrer Tochter',
    BabyGender.boy => 'Ihres Sohnes',
    null => 'des Kindes',
  };

  @override
  String get childsGoogleDrive => 'im Google Drive $ofTheChild';

  @override
  String get deleteConfirmTitle =>
      hasName ? '$_genitivo Kapsel löschen?' : 'Konto löschen?';

  @override
  String get deleteConfirmBody =>
      'Das kann nicht rückgängig gemacht werden. Wir führen kein Backup, '
      'und es gibt keine Möglichkeit, es später wiederherzustellen.\n\n'
      '${hasName ? "Alles, was wir über $theName speichern, verschwindet jetzt" : "Alles, was wir über das Kind speichern, verschwindet jetzt"}: '
      'das Profil, die gesamte Zeitleiste und der Text der Briefe.\n\n'
      'Die Fotos und Videos bleiben in Google Drive, denn sie gehören '
      'Ihnen.';

  @override
  String get deleteConfirmAction => 'Endgültig löschen';

  @override
  String get aboutStorage =>
      'Die Fotos, Videos und Dokumente bleiben in Ihrem eigenen '
      'Google-Konto gespeichert, in nach Alter geordneten Ordnern. Die '
      'App ist nur die schöne Art, das alles durchzublättern.\n\n'
      'Auch in vielen Jahren, ohne diese App, bleibt die Sammlung dort: '
      'lesbar, geordnet und '
      '${hasName ? "$theirs gehörend" : "gehörend, wem sie zusteht"}.';
}
