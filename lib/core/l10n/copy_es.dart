import '../../models/baby_gender.dart';
import 'copy.dart';

/// As frases sobre a criança, em espanhol.
///
/// A diferença que mais separa do português: o espanhol padrão **não**
/// antepõe artigo a nome próprio. "da Maria" é `de la María` num registro
/// regional, e `de María` no espanhol neutro que este aplicativo usa. Por
/// isso `theName` e `ofName` aqui são mais simples que os do português, e
/// mais parecidos com os do inglês, só que sem o possessivo em 's.
class CopyEs extends Copy {
  const CopyEs(super.name, super.gender);

  @override
  String get theName => name;

  @override
  String get ofName => 'de $name';

  @override
  String get forName => 'para $name';

  /// Frase preposicional invariável, e não um adjetivo que precisaria
  /// concordar com o substantivo possuído - que muda de gênero de uma frase
  /// para outra ("la cuenta" é feminino, "el acervo" é masculino), e um
  /// getter só não sabe qual dos dois vem depois.
  @override
  String get theirs => switch (gender) {
    BabyGender.girl => 'de ella',
    BabyGender.boy => 'de él',
    null => 'de la criatura',
  };

  @override
  String get onboardingSubtitle =>
      'Cada momento merece ser recordado.\n'
      '¿Empezamos a guardar esta historia?';

  @override
  String get addPhotoHint =>
      hasName ? 'Agregar fotos $ofName' : 'Agregar fotos';

  @override
  String get addVideoHint =>
      hasName ? 'Agregar videos $ofName' : 'Agregar videos';

  @override
  String get addLetterHint =>
      hasName ? 'Escribir una carta $forName' : 'Escribir una carta';

  @override
  String get timelineEmptyBody => hasName
      ? 'Toca el + para guardar el primer recuerdo $ofName.'
      : 'Toca el + para guardar el primer recuerdo.';

  @override
  String get babyInfo => hasName ? 'Información $ofName' : 'Información';

  @override
  String get lettersEmptyBody => hasName
      ? 'Escribe el primer mensaje para que $theName lo lea algún día.'
      : 'Escribe el primer mensaje, para ser leído algún día.';

  @override
  String get letterHint => hasName ? 'Para $theName 💜' : 'Para el futuro 💜';

  @override
  String get letterKeepsafe => hasName
      ? 'Esta carta queda guardada en el Drive $ofName. Un día, cuando la '
            'cuenta sea $theirs, va a estar ahí esperando.'
      : 'Esta carta queda guardada en el Drive de la criatura. Un día, '
            'cuando la cuenta sea de la criatura, va a estar ahí esperando.';

  @override
  String get driveOwner => hasName ? name : 'ti';

  @override
  String get ofTheChild => switch (gender) {
    BabyGender.girl => 'de tu hija',
    BabyGender.boy => 'de tu hijo',
    null => 'de la criatura',
  };

  @override
  String get childsGoogleDrive => 'en el Google Drive $ofTheChild';

  @override
  String get deleteConfirmTitle =>
      hasName ? '¿Eliminar la cápsula $ofName?' : '¿Eliminar la cuenta?';

  @override
  String get deleteConfirmBody =>
      'Esto no se puede deshacer. No guardamos copia de seguridad, y no '
      'hay forma de recuperarlo después.\n\n'
      '${hasName ? "Desaparece ahora todo lo que guardamos sobre $theName" : "Desaparece ahora todo lo que guardamos sobre la criatura"}: '
      'el registro, toda la línea de tiempo y el texto de las cartas.\n\n'
      'Las fotos y los videos siguen en Google Drive, porque son tuyos.';

  @override
  String get deleteConfirmAction => 'Eliminar para siempre';

  @override
  String get aboutStorage =>
      'Las fotos, los videos y los documentos quedan guardados en tu '
      'propia cuenta de Google Drive, en carpetas organizadas por edad. El '
      'aplicativo es solo la forma bonita de hojear todo eso.\n\n'
      'Incluso dentro de muchos años, sin este aplicativo, el acervo sigue '
      'ahí: legible, organizado y '
      '${hasName ? theirs : "de quien corresponda"}.';
}
