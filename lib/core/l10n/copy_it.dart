import '../../models/baby_gender.dart';
import 'copy.dart';

/// As frases sobre a criança, em italiano.
///
/// Como o espanhol, o italiano não antepõe artigo a nome próprio em posse:
/// "as fotos da Maria" vira `le foto di Maria`, não `le foto della Maria`
/// (que existe como registro regional/coloquial em algumas partes da
/// Itália, mas não é o italiano neutro que este aplicativo usa).
class CopyIt extends Copy {
  const CopyIt(super.name, super.gender);

  @override
  String get theName => name;

  @override
  String get ofName => 'di $name';

  @override
  String get forName => 'per $name';

  /// Frase preposicional invariável, para não precisar concordar com o
  /// substantivo possuído - que muda de gênero de uma frase para outra
  /// ("l'account" masculino numa, "la raccolta" feminino noutra).
  @override
  String get theirs => switch (gender) {
    BabyGender.girl => 'di lei',
    BabyGender.boy => 'di lui',
    null => 'del bambino',
  };

  @override
  String get onboardingSubtitle =>
      'Ogni momento merita di essere ricordato.\n'
      'Iniziamo a conservare questa storia?';

  @override
  String get addPhotoHint =>
      hasName ? 'Aggiungere le foto $ofName' : 'Aggiungere foto';

  @override
  String get addVideoHint =>
      hasName ? 'Aggiungere i video $ofName' : 'Aggiungere video';

  @override
  String get addLetterHint =>
      hasName ? 'Scrivere una lettera $forName' : 'Scrivere una lettera';

  @override
  String get timelineEmptyBody => hasName
      ? 'Tocca il + per salvare il primo ricordo $ofName.'
      : 'Tocca il + per salvare il primo ricordo.';

  @override
  String get babyInfo => hasName ? 'Informazioni $ofName' : 'Informazioni';

  @override
  String get lettersEmptyBody => hasName
      ? 'Scrivi il primo messaggio perché $theName lo legga un giorno.'
      : 'Scrivi il primo messaggio, da leggere un giorno.';

  @override
  String get letterHint => hasName ? 'Per $theName 💜' : 'Per il futuro 💜';

  @override
  String get letterKeepsafe => hasName
      ? 'Questa lettera resta salvata nel Drive $ofName. Un giorno, '
            'quando l\'account sarà $theirs, sarà lì ad aspettare.'
      : 'Questa lettera resta salvata nel Drive del bambino. Un giorno, '
            'quando l\'account sarà del bambino, sarà lì ad aspettare.';

  @override
  String get driveOwner => hasName ? name : 'te';

  @override
  String get ofTheChild => switch (gender) {
    BabyGender.girl => 'di tua figlia',
    BabyGender.boy => 'di tuo figlio',
    null => 'del bambino',
  };

  @override
  String get childsGoogleDrive => 'nel Google Drive $ofTheChild';

  @override
  String get deleteConfirmTitle =>
      hasName ? 'Eliminare la capsula $ofName?' : 'Eliminare l\'account?';

  @override
  String get deleteConfirmBody =>
      'Questa azione non può essere annullata. Non conserviamo copie di '
      'backup, e non c\'è modo di recuperarlo in seguito.\n\n'
      '${hasName ? "Scompare ora tutto quello che conserviamo su $theName" : "Scompare ora tutto quello che conserviamo sul bambino"}: '
      'il profilo, tutta la cronologia e il testo delle lettere.\n\n'
      'Le foto e i video restano su Google Drive, perché sono tuoi.';

  @override
  String get deleteConfirmAction => 'Elimina per sempre';

  @override
  String get aboutStorage =>
      'Le foto, i video e i documenti restano salvati nel tuo account '
      'Google Drive, in cartelle organizzate per età. L\'app è solo il '
      'modo bello di sfogliare tutto questo.\n\n'
      'Anche tra molti anni, senza questa app, la raccolta resta lì: '
      'leggibile, organizzata e '
      '${hasName ? theirs : "di chi di dovere"}.';
}
