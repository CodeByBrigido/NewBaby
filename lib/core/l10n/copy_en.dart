import '../../models/baby_gender.dart';
import 'copy.dart';

/// As frases sobre a criança, em inglês.
///
/// A concordância de gênero do português desaparece aqui, e isso não é só
/// simplificação: muda a forma da frase. `da Maria` vira `Maria's`, que é
/// possessivo e vem **antes** do substantivo, então `as memórias da Maria`
/// não vira `the memories of Maria` e sim `Maria's memories`. Onde a ordem
/// muda, a frase foi reescrita em vez de traduzida.
///
/// O sexo continua importando em um lugar: `his` e `hers`, e `your son` e
/// `your daughter`. Sem sexo informado, o inglês tem uma saída melhor que o
/// português, que é o `their` singular.
class CopyEn extends Copy {
  const CopyEn(super.name, super.gender);

  @override
  String get theName => name;

  /// `Maria's`, e `Lucas'` quando o nome já termina em s.
  @override
  String get ofName => name.endsWith('s') ? "$name'" : "$name's";

  @override
  String get forName => 'for $name';

  @override
  String get theirs => switch (gender) {
    BabyGender.girl => 'hers',
    BabyGender.boy => 'his',
    null => 'theirs',
  };

  @override
  String get onboardingSubtitle =>
      'Every moment deserves to be remembered.\n'
      'Shall we start keeping this story?';

  @override
  String get addPhotoHint => hasName ? "Add $ofName photos" : 'Add photos';

  @override
  String get addVideoHint => hasName ? "Add $ofName videos" : 'Add videos';

  @override
  String get addLetterHint =>
      hasName ? 'Write a letter $forName' : 'Write a letter';

  @override
  String get timelineEmptyBody => hasName
      ? "Tap + to keep $ofName first memory."
      : 'Tap + to keep the first memory.';

  @override
  String get babyInfo => hasName ? "$ofName details" : 'Details';

  @override
  String get lettersEmptyBody => hasName
      ? 'Write the first message for $theName to read one day.'
      : 'Write the first message, to be read one day.';

  @override
  String get letterHint => hasName ? 'For $theName 💜' : 'For the future 💜';

  @override
  String get letterKeepsafe => hasName
      ? "This letter is kept in $ofName Drive. One day, when the account is "
            '$theirs, it will be there waiting.'
      : "This letter is kept in the child's Drive. One day, when the account "
            'is theirs, it will be there waiting.';

  @override
  String get driveOwner => hasName ? name : 'you';

  @override
  String get ofTheChild => switch (gender) {
    BabyGender.girl => 'your daughter',
    BabyGender.boy => 'your son',
    null => 'the child',
  };

  @override
  String get deleteConfirmTitle =>
      hasName ? "Delete $ofName capsule?" : 'Delete the account?';

  @override
  String get deleteConfirmBody =>
      'This cannot be undone. We keep no backup, and there is no way to '
      'recover it later.\n\n'
      '${hasName ? "Everything we keep about $theName goes now" : "Everything we keep about the child goes now"}: '
      'the profile, the whole timeline and the text of the letters.\n\n'
      'The photos and videos stay in Google Drive, because they are yours.';

  @override
  String get deleteConfirmAction => 'Delete forever';

  @override
  String get aboutStorage =>
      'The photos, videos and documents are kept in your own Google Drive '
      'account, in folders organised by age. The app is just the pretty way '
      'to leaf through all of it.\n\n'
      'Even many years from now, without this app, the archive is still '
      'there: readable, organised, and '
      '${hasName ? theirs : "belonging to whoever it is due"}.';
}
