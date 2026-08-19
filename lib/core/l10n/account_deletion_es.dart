import 'privacy_policy.dart';

/// La página de eliminación de cuenta, en español.
///
/// Nueve secciones, no diez: la versión portuguesa termina con un apéndice
/// en inglés para quien revisa la ficha de la tienda y no lee portugués.
/// Aquí ese apéndice no hace falta, porque la página inglesa completa ya
/// existe en `docs/en/deletion.html` para quien la necesite.
const String deletionPageDateEs = '18 de agosto de 2026';

const List<PrivacySection> accountDeletionPageEs = <PrivacySection>[
  PrivacySection(
    title: 'Qué es esta página',
    body: <String>[
      'Esta página explica cómo pedir la eliminación de tu cuenta del '
          'aplicativo Meu Bebê: Cápsula do Tempo y de todos los datos '
          'asociados a ella.',
      'Existe para funcionar incluso si ya desinstalaste el aplicativo. '
          'No necesitas instalar nada, registrarte ni iniciar sesión en '
          'ningún lugar para usar lo que hay aquí.',
      'El derecho a borrar existe con nombres distintos en lugares '
          'distintos: supresión en el RGPD (Art. 17) y en el UK GDPR, '
          'eliminación en la LGPD (Art. 18), eliminación en la CCPA de '
          'California, y derechos equivalentes en muchas otras '
          'jurisdicciones. Aquí el camino es el mismo para todo el mundo, y '
          'no condicionamos la solicitud a que indiques en qué país vives.',
      'Responsable del tratamiento: $privacyController. Contacto: '
          '$privacyEmail',
    ],
  ),
  PrivacySection(
    title: 'Si todavía tienes el aplicativo',
    body: <String>[
      'Este es el camino más rápido, y el único que borra todo al '
          'instante, sin esperar a nadie:',
      '• Abre el aplicativo e inicia sesión con la cuenta que quieres '
          'borrar',
      '• Toca en Perfil',
      '• Toca en "Eliminación de cuenta y de datos"',
      '• Lee la página, que es esta misma, y toca en "Ir a la '
          'eliminación de la cuenta", al final',
      '• Elige qué hacer con la carpeta de Google Drive',
      '• Toca en "Eliminar mi cuenta y mis datos" y confirma',
      'La lectura viene antes del botón a propósito. Borrar es inmediato '
          'y no se puede deshacer, y nadie debería llegar al botón sin saber '
          'qué se queda y qué desaparece.',
      'Sobre la carpeta del Drive, hay dos opciones: mantenerla, que es '
          'lo predeterminado, porque los archivos son tuyos y nunca tuvimos '
          'copia de ellos; o enviarla a la papelera de tu Drive.',
    ],
  ),
  PrivacySection(
    title: 'Si ya no tienes el aplicativo',
    body: <String>[
      'Escribe a $privacyEmail con el asunto "Eliminar mi cuenta".',
      'La solicitud debe venir de la dirección de correo de la cuenta de '
          'Google que usaste para entrar al aplicativo. Es la única forma '
          'que tenemos de saber que la solicitud es tuya: sin esta '
          'comprobación, cualquiera podría borrar la colección de otra '
          'persona con solo escribir un correo.',
      'Responderemos a esa misma dirección confirmando la eliminación. Si '
          'la solicitud llega desde otra dirección, pediremos que se '
          'reenvíe desde la dirección de la cuenta, y no borraremos nada '
          'hasta que eso ocurra.',
      'La solicitud se procesará sin demora indebida y, cuando esté '
          'sujeta al RGPD, por regla general en el plazo de un mes. Cuando '
          'otra legislación aplicable establezca un plazo distinto, '
          'observaremos el plazo legal correspondiente. No necesitas '
          'justificar la solicitud, y no cobramos por pedirla.',
    ],
  ),
  PrivacySection(
    title: 'Qué se borra',
    body: <String>[
      'Todo lo que existe de tu lado en nuestro servidor, sin excepción:',
      '• El registro del niño o la niña: nombre, fecha y hora de '
          'nacimiento, sexo, peso, altura y hospital',
      '• Toda la línea de tiempo: la fecha, la edad, el título, la '
          'descripción y el tipo de cada recuerdo',
      '• El texto íntegro de las cartas, que es el único contenido tuyo '
          'que queda en nuestro índice',
      '• Los identificadores de las carpetas del Drive y el progreso de '
          'las sugerencias',
      '• Tu cuenta de autenticación, con el email y el nombre '
          'provenientes de Google',
      'La eliminación de los datos del índice y de la cuenta de '
          'autenticación se inicia de inmediato tras la confirmación y, una '
          'vez completada, no puede deshacerse desde el aplicativo. No '
          'mantenemos copia de seguridad operativa del índice para '
          'restaurar una cuenta eliminada. Los datos que deban conservarse '
          'por obligación legal o los registros técnicos mantenidos por la '
          'infraestructura de Google podrán permanecer por el período '
          'aplicable, sin usarse para fines incompatibles.',
    ],
  ),
  PrivacySection(
    title: 'Qué no se borra, y por qué',
    body: <String>[
      'Tus fotos, videos, dibujos y documentos **no se borran**, porque '
          'nunca fueron nuestros.',
      'Quedan en una carpeta llamada "Meu Bebê - Cápsula do Tempo", en '
          'el Google Drive de tu propia cuenta. El aplicativo nunca tuvo '
          'copia de ellos en ningún servidor: van de tu dispositivo '
          'directo a tu Drive.',
      'Después de que se borra la cuenta, el aplicativo revoca la '
          'autorización usada para acceder a los archivos que él mismo creó '
          'en Google Drive. El alcance usado es '
          'https://www.googleapis.com/auth/drive.file, que limita el '
          'acceso a los archivos creados o abiertos por el aplicativo '
          'dentro de los permisos concedidos por Google. Tras la '
          'revocación, el aplicativo deja de tener autorización para '
          'operar esos archivos. Por eso, los archivos permanecen bajo el '
          'control de tu cuenta de Google, salvo que decidas borrarlos '
          'directamente en el Drive o, cuando esté disponible, solicites al '
          'aplicativo que los envíe a la papelera antes de eliminar la '
          'cuenta.',
      'Si también quieres borrar los archivos, hazlo directo en el '
          'Drive, y toma dos toques:',
      '• Abre drive.google.com con la misma cuenta',
      '• Busca la carpeta "Meu Bebê - Cápsula do Tempo"',
      '• Haz clic derecho y elige "Quitar"',
      'Si prefieres solicitar al aplicativo que envíe la carpeta a la '
          'papelera del Drive, hazlo **antes** de completar la eliminación '
          'de la cuenta, en la misma pantalla de eliminación. La '
          'disponibilidad y el resultado definitivo de la operación '
          'dependen de los permisos concedidos y de los mecanismos de '
          'Google Drive.',
    ],
  ),
  PrivacySection(
    title: 'La suscripción Premium no se cancela aquí',
    body: <String>[
      'Si tienes la suscripción Premium, **borrar la cuenta no cancela '
          'la suscripción**. Son dos cosas en lugares distintos: la cuenta '
          'es nuestra, la suscripción es de Google Play.',
      'Sin cancelarla allá, el cobro anual sigue ocurriendo incluso '
          'después de haber borrado la cápsula. Nosotros no tenemos acceso '
          'a tu forma de pago y no podemos cancelarla por ti.',
      'Cancélala antes de borrar la cuenta, y toma pocos toques:',
      '• Abre Google Play Store',
      '• Toca tu foto, arriba a la derecha',
      '• Ve a "Pagos y suscripciones" y luego a "Suscripciones"',
      '• Elige Meu Bebê: Cápsula do Tempo y toca "Cancelar suscripción"',
      'Al cancelar, el Premium normalmente sigue vigente hasta el final '
          'del período ya pagado. Si borras la cuenta antes de eso, el '
          'acceso al Premium asociado a esa cuenta terminará cuando la '
          'cuenta se elimine. No ofrecemos devolución proporcional por '
          'iniciativa propia, salvo cuando lo exija la legislación '
          'aplicable o las políticas de reembolso de Google Play.',
    ],
  ),
  PrivacySection(
    title: 'Borrar solo una parte',
    body: <String>[
      'No necesitas borrar la cuenta entera para borrar algo.',
      'Dentro del aplicativo, cualquier recuerdo puede ir a la papelera '
          'y borrarse definitivamente, uno por uno. El registro del niño o '
          'la niña se puede editar en cualquier momento. Nada de esto pasa '
          'por nosotros ni depende de una solicitud.',
      'Si lo que quieres es dejar de usar el aplicativo sin borrar nada, '
          'basta con cerrar sesión en Perfil: los datos en el dispositivo se '
          'borran al salir, y la colección en tu Drive sigue donde está.',
    ],
  ),
  PrivacySection(
    title: 'Una cuenta por niño o niña',
    body: <String>[
      'El aplicativo usa una cuenta de Google por niño o niña, para que '
          'algún día cada uno reciba su propia cápsula completa.',
      'Esto significa que borrar una cuenta borra la cápsula de ese niño '
          'o niña, y solo la de él o ella. Si usas más de una cuenta, la '
          'solicitud debe hacerse una vez por cada una, desde el correo de '
          'cada cuenta.',
      'La suscripción Premium también es por cuenta. Borrar la cápsula '
          'de un niño o una niña no afecta la suscripción de los demás, y '
          'cada una sigue vigente, o se cancela, por su cuenta.',
    ],
  ),
  PrivacySection(
    title: 'Registros técnicos',
    body: <String>[
      'La infraestructura que aloja el índice usa servicios de Firebase '
          'y Google Cloud. Como cualquier servicio en la nube, esos '
          'servicios pueden mantener registros técnicos y operativos '
          'necesarios para la seguridad, el funcionamiento, la prevención '
          'de abusos y la auditoría, sujetos a las políticas de retención '
          'aplicables de Google.',
      'Esos registros de infraestructura no forman parte del índice que '
          'mantenemos para operar tu cápsula y no los usamos para '
          'reconstruir el contenido eliminado. Algunos registros técnicos '
          'pueden permanecer por períodos determinados por Google o por '
          'obligaciones legales aplicables. Por eso, no prometemos que '
          'absolutamente ningún registro técnico pueda existir en ningún '
          'sistema de infraestructura después de la eliminación.',
    ],
  ),
];
