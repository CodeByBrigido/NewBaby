import 'textos.dart';

/// El aplicativo en español.
///
/// Escrito como español, y no como portugués traducido palabra por palabra.
/// Donde la frase portuguesa dependía de una concordancia que el español
/// resuelve distinto, la frase fue reescrita para decir lo mismo del modo en
/// que se dice aquí.
///
/// **El nombre de la carpeta en Google Drive no está aquí, y no debe estar.**
/// Es una constante de `DriveService`, en portugués, y sigue así para todo el
/// mundo: traducirlo haría que el aplicativo buscara una carpeta con otro
/// nombre y dejara atrás todo lo que la familia ya guardó.
class TextosEs implements Textos {
  const TextosEs();

  @override
  String get codigo => 'es';

  @override
  String get appName => 'Mi Bebé';

  @override
  String get appFullName => 'Mi Bebé: Cápsula del Tiempo';

  @override
  String get appSubtitle => 'Cápsula del Tiempo';

  @override
  String get appTagline => 'Cada momento, un recuerdo para toda la vida.';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signInNote =>
      'Todos los recuerdos se guardarán en la cuenta de Google Drive de '
      'tu hijo/a.';

  @override
  String get signInError =>
      'No se pudo iniciar sesión. Revisa la conexión e inténtalo de nuevo.';

  @override
  String get onboardingGreeting => '¡Hola!';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get gender => '¿Niño o niña?';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get birthTime => 'Hora de nacimiento';

  @override
  String get birthWeight => 'Peso al nacer';

  @override
  String get birthHeight => 'Altura al nacer';

  @override
  String get birthTimeOptional => 'Hora de nacimiento (opcional)';

  @override
  String get birthWeightOptional => 'Peso al nacer (opcional)';

  @override
  String get birthHeightOptional => 'Altura al nacer (opcional)';

  @override
  String get hospitalOptional => 'Hospital (opcional)';

  @override
  String get birthPhoto => 'Foto del nacimiento';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get preparingDrive => 'Preparando las carpetas en Google Drive...';

  @override
  String get home => 'Inicio';

  @override
  String get timeline => 'Línea de Tiempo';

  @override
  String get search => 'Buscar';

  @override
  String get accountsLabel => 'CUENTAS';

  @override
  String get switchAccount => 'Cambiar de cuenta';

  @override
  String get profile => 'Perfil';

  @override
  String get photos => 'Fotos';

  @override
  String get videos => 'Videos';

  @override
  String get letters => 'Cartas';

  @override
  String get drawings => 'Dibujos';

  @override
  String get documents => 'Documentos';

  @override
  String get growth => 'Crecimiento';

  @override
  String get stats => 'Estadísticas';

  @override
  String get trash => 'Papelera';

  @override
  String get settings => 'Configuración';

  @override
  String get about => 'Acerca del aplicativo';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get storedWithLove => 'Guardado con cariño en el Drive de';

  @override
  String get addQuestion => '¿Qué quieres agregar?';

  @override
  String get addPhoto => 'Foto';

  @override
  String get addVideo => 'Video';

  @override
  String get addLetter => 'Carta';

  @override
  String get addDrawing => 'Dibujo';

  @override
  String get addDrawingHint => 'Agregar un dibujo';

  @override
  String get addDocument => 'Documento';

  @override
  String get addDocumentHint => 'Agregar documentos importantes';

  @override
  String get addGrowth => 'Crecimiento';

  @override
  String get addGrowthHint => 'Registrar peso y altura';

  @override
  String get timelineEmptyTitle => 'La historia empieza aquí';

  @override
  String get birth => 'Nacimiento';

  @override
  String get photosAdded => 'Fotos agregadas';

  @override
  String get photoAdded => 'Foto agregada';

  @override
  String get videoAdded => 'Video agregado';

  @override
  String get drawingAdded => 'Dibujo agregado';

  @override
  String get documentAdded => 'Documento agregado';

  @override
  String get growthRecord => 'Registro de crecimiento';

  @override
  String get letterPrefix => 'Carta:';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterTitle => 'Filtrar por tipo';

  @override
  List<String> get milestoneSuggestions => <String>[
    'Primera foto',
    'Primer baño',
    'Primer paseo',
    'Primer viaje',
    'Primera sonrisa',
    'Primer diente',
    'Primeros pasos',
    'Primera palabra',
    'Primer cumpleaños',
  ];

  @override
  String get letterStartersTitle => '¿No sabes cómo empezar?';

  @override
  List<String> get letterStarters => <String>[
    'Hoy quiero contarte sobre ',
    'Cuando leas esto, ',
    'Todavía no lo sabes, pero ',
    'Una cosa que nunca quiero olvidar: ',
    'Si pudiera decirte solo una cosa, sería ',
    'El día en que tú ',
    'De como eres hoy, lo que más amo es ',
  ];

  @override
  String get titleField => 'Título';

  @override
  String get messageField => 'Mensaje';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get milestoneOptional => 'Hito (opcional)';

  @override
  String get weightField => 'Peso';

  @override
  String get heightField => 'Altura';

  @override
  String get photoOptional => 'Foto (opcional)';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get edit => 'Editar';

  @override
  String get share => 'Compartir';

  @override
  String get delete => 'Eliminar';

  @override
  String get restore => 'Restaurar';

  @override
  String get view => 'Ver';

  @override
  String get download => 'Descargar';

  @override
  String get retry => 'Intentar de nuevo';

  @override
  String get weeks => 'Semanas';

  @override
  String get months => 'Meses';

  @override
  String get years => 'Años';

  @override
  String get photosOptimizedNote =>
      'Las fotos se comprimen automáticamente para optimizar espacio.';

  @override
  String get videoOptimizedNote =>
      'Este video se guardó en 540p para optimizar espacio.';

  @override
  String get allFilesOptimizedNote =>
      'Todos los archivos se optimizan para ahorrar espacio.';

  @override
  String get uploadPending => 'Esperando envío';

  @override
  String get uploadOptimizing => 'Optimizando...';

  @override
  String get uploadSending => 'Enviando...';

  @override
  String get uploadFailed => 'Error en el envío';

  @override
  String get uploadingCount => 'Enviando';

  @override
  String get searchHint => 'Buscar recuerdos...';

  @override
  String get searchByCategory => 'Buscar por categoría';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String get searchEmpty => 'No se encontró nada por aquí.';

  @override
  String get clearHistory => 'Borrar historial';

  @override
  String get storageUsed => 'Almacenamiento usado';

  @override
  String get storageOf => 'de';

  @override
  String get capsuleStorage => 'Cápsula del Tiempo';

  @override
  String get driveStorage => 'Tu Google Drive';

  @override
  String get driveStorageNote =>
      'El total de arriba es de toda tu cuenta de Google. El aplicativo solo '
      've los archivos que él mismo creó, dentro de la carpeta de la '
      'cápsula. No alcanza el contenido del resto de tu Drive.';

  @override
  String get lockSection => 'Privacidad';

  @override
  String get lockTitle => 'Bloqueo del aplicativo';

  @override
  String get lockBody =>
      'Pide tu huella, tu rostro o el PIN del dispositivo para abrir el '
      'aplicativo. Viene apagado.';

  @override
  String get lockUnavailable =>
      'Este dispositivo no tiene huella, rostro ni PIN configurado. '
      'Configura un bloqueo en los ajustes de Android para poder usar '
      'esta opción.';

  @override
  String get lockNote =>
      'El bloqueo protege a quien toma tu celular ya desbloqueado. No '
      'cifra nada: es una puerta más, no una caja fuerte.';

  @override
  String get lockFailed => 'No se pudo confirmar. El bloqueo sigue apagado.';

  @override
  String get lockReason => 'Confirma que eres tú para abrir los recuerdos.';

  @override
  String get lockedTitle => 'Aplicativo bloqueado';

  @override
  String get lockedBody => 'Confirma tu identidad para ver los recuerdos.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get viewChart => 'Ver gráfico';

  @override
  String get growthChart => 'Gráfico de crecimiento';

  @override
  String get growthEmptyTitle => 'Ningún registro todavía';

  @override
  String get growthEmptyBody =>
      'Registra el peso y la altura para seguir el crecimiento.';

  @override
  String get trashEmptyTitle => 'La papelera está vacía';

  @override
  String get trashEmptyBody =>
      'Los elementos eliminados quedan aquí hasta que los borres del todo.';

  @override
  String get trashNote =>
      'Los archivos también van a la papelera de Google Drive.';

  @override
  String get deleteForever => 'Eliminar definitivamente';

  @override
  String get deleteConfirmTitle => '¿Eliminar este elemento?';

  @override
  String get deleteConfirmBody =>
      'Va a la papelera y se puede restaurar después.';

  @override
  String get deleteForeverConfirmBody => 'Esta acción no se puede deshacer.';

  @override
  String get currentAge => 'Edad actual';

  @override
  String get birthDateShort => 'Nacimiento';

  @override
  String get signOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get signOutConfirmBody =>
      'Tus recuerdos siguen guardados en tu Google Drive. Las miniaturas '
      'y los archivos descargados se borran de este dispositivo.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de Uso';

  @override
  String get accountDeletionTitle => 'Eliminación de cuenta y de datos';

  @override
  String get accountDeletionShort => 'Eliminar cuenta';

  @override
  String get goToDeleteAccount => 'Ir a la eliminación de la cuenta';

  @override
  String get deleteAccount => 'Eliminar mi cuenta y mis datos';

  @override
  String get deleteAccountTitle => '¿Eliminar la cuenta?';

  @override
  String get deleteAccountBody =>
      'Eliminamos de nuestro servidor todo lo que guardamos sobre ti: el '
      'registro, la línea de tiempo, los registros de crecimiento y el '
      'texto de las cartas. También retiramos el permiso de acceso a tu '
      'Google Drive.\n\n'
      'Esta acción no se puede deshacer.';

  @override
  String get deleteAccountDriveQuestion =>
      '¿Y la carpeta "Meu Bebê - Cápsula do Tempo" en tu Drive?';

  @override
  String get deleteAccountKeepDrive => 'Mantener los archivos';

  @override
  String get deleteAccountKeepDriveHint =>
      'Las fotos, los videos y los documentos siguen en tu Drive, '
      'organizados por edad. Recomendado.';

  @override
  String get deleteAccountTrashDrive => 'Enviar a la papelera';

  @override
  String get deleteAccountTrashDriveHint =>
      'La carpeta va a la papelera de Google Drive y se puede recuperar '
      'durante 30 días.';

  @override
  String get deleteAccountWorking => 'Eliminando...';

  @override
  String get deleteAccountDone => 'Cuenta eliminada.';

  @override
  String get genericError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get noItemsYet => 'Todavía no hay nada por aquí.';

  @override
  String get requiredField => 'Completa este campo';

  @override
  String get invalidNumber => 'Ingresa un número válido';

  @override
  String get codigoIntl => 'es';

  @override
  String get padraoData => 'dd/MM/yyyy';

  @override
  String get padraoDiaMes => 'dd/MM';

  @override
  String get padraoDataLonga => "d 'de' MMMM 'de' yyyy";

  @override
  String get padraoMesAno => "MMMM 'de' yyyy";

  @override
  String get padraoHora => 'HH:mm';

  @override
  String get entreDatas => 'al';

  @override
  String get hoje => 'Hoy';

  @override
  String get ontem => 'Ayer';

  @override
  String saudacao(int hora) {
    if (hora < 12) return 'Buenos días';
    if (hora < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  String haTempo(int dias) {
    if (dias <= 0) return 'hoy';
    if (dias == 1) return 'ayer';
    if (dias < 14) return 'hace $dias días';
    if (dias < 60) {
      final int semanas = dias ~/ 7;
      return semanas == 1 ? 'hace 1 semana' : 'hace $semanas semanas';
    }
    if (dias < 365) {
      final int meses = dias ~/ 30;
      return meses == 1 ? 'hace 1 mes' : 'hace $meses meses';
    }
    final int anos = dias ~/ 365;
    return anos == 1 ? 'hace 1 año' : 'hace $anos años';
  }

  @override
  String ordinal(int n) => switch (n) {
    1 => 'primero',
    2 => 'segundo',
    3 => 'tercero',
    4 => 'cuarto',
    5 => 'quinto',
    6 => 'sexto',
    7 => 'séptimo',
    8 => 'octavo',
    9 => 'noveno',
    10 => 'décimo',
    _ => '$nº',
  };

  @override
  String contarDias(int n) => n == 1 ? '1 día' : '$n días';

  @override
  String contarMeses(int n) => n == 1 ? '1 mes' : '$n meses';

  @override
  String contarAnos(int n) => n == 1 ? '1 año' : '$n años';

  @override
  String contarItens(int n) => n == 1 ? '1 elemento' : '$n elementos';

  @override
  String contarFotos(int n) => n == 1 ? '1 foto' : '$n fotos';

  @override
  String contarVideos(int n) => n == 1 ? '1 video' : '$n videos';

  @override
  String get lastBirth => 'Último nacimiento';

  @override
  String get lastPhoto => 'Última foto';

  @override
  String get lastVideo => 'Último video';

  @override
  String get lastLetter => 'Última carta';

  @override
  String get lastDrawing => 'Último dibujo';

  @override
  String get lastDocument => 'Último documento';

  @override
  String get lastGrowth => 'Última medición';

  @override
  String get oneVideo => 'video';

  @override
  String get oneGrowth => 'medición';

  @override
  String get imageOpenFailed => 'No se pudo abrir esta imagen.';

  @override
  String get videoOpenFailed => 'No se pudo abrir este video.';

  @override
  String get documentNotFound => 'Documento no encontrado';

  @override
  String get letterNotFound => 'Carta no encontrada';

  @override
  String get entryNotFound => 'Recuerdo no encontrado';

  @override
  String get driveSpaceFailed => 'No se pudo leer el espacio de Google Drive.';

  @override
  String get firstVideoHint => 'Toca el + para agregar el primer video.';

  @override
  String get documentsEmptyBody =>
      'Certificado de nacimiento, cartilla de vacunación, pasaporte: todo '
      'en un solo lugar.';

  @override
  String get isToday => 'Es hoy';

  @override
  String get isTodayBang => '¡Es hoy!';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get nextMilestone => 'Próximo hito';

  @override
  String faltamDias(int dias) => 'Dentro de ${contarDias(dias)}';

  @override
  String get seeInspiration => 'Ver inspiración';

  @override
  String get forYou => 'Para ti';

  @override
  String get notYet => 'todavía no';

  @override
  String get inspirations => 'Inspiraciones';

  @override
  String get inspirationsLoadFailed => 'No se pudieron cargar las ideas';

  @override
  String get inspirationSearchHint => '¿Qué quieres saber?';

  @override
  String get suggestionsByAge =>
      'Las sugerencias aparecen según la edad y el calendario.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get savedTitle => 'Está guardado';

  @override
  String get willBeSaved => 'Se va a guardar';

  @override
  String get sendMemoryError => 'Enviar recuerdo';

  @override
  String get dateFromFile =>
      'Fecha leída del propio archivo. Toca para cambiarla.';

  @override
  String get deletedOn => 'Eliminado el ';

  @override
  String get itemDeleted => 'Elemento eliminado.';

  @override
  String get documentNameSuggestion => 'Certificado de nacimiento';

  @override
  String get saveInfo => 'Guardar información';

  @override
  String get editInfo => 'Editar información';

  @override
  String get notProvided => 'No indicada';

  @override
  String get automatic => 'Automática';

  @override
  String get reviewIntro => 'Volver a ver la presentación';

  @override
  String get lastUpdatedLabel => 'Última actualización';

  @override
  String get optimization => 'Optimización';

  @override
  String get photoMaxSide => 'Hasta 960 px en el lado mayor';

  @override
  String get optimizationNote =>
      'La optimización es automática y no se puede apagar: es lo que '
      'mantiene el acervo liviano por muchos años.';

  @override
  String get languageSection => 'Idioma';

  @override
  String get clearCacheBody =>
      'Borra miniaturas, archivos temporales y los documentos ya '
      'descargados. Nada se pierde: todo sigue en Google Drive.';

  @override
  String get cacheCleared => 'Caché borrado.';

  @override
  String get clearCache => 'Borrar caché';

  @override
  String get storageOnDevice => 'Almacenamiento en el dispositivo';

  @override
  String get remindersSection => 'Recordatorios';

  @override
  String get remindersOff => 'Apagados';

  @override
  String get startupFailedTitle => 'El aplicativo no pudo iniciar';

  @override
  String get technicalDetail => 'Detalle técnico';

  @override
  String get premiumInviteAction => 'Entendido';

  @override
  String get introTitle1 => 'La infancia pasa rápido.';

  @override
  String get introTitle2 => 'Cada recuerdo tiene su lugar.';

  @override
  String get introBody2 =>
      'Fotos, videos, cartas, dibujos, documentos y registros de '
      'crecimiento. Todo reunido en un solo lugar.';

  @override
  String get introTitle3 => 'Cada recuerdo en su momento.';

  @override
  String get introTitle4 => '¿Creamos esta cápsula?';

  @override
  String get sealBody =>
      'Esto queda cerrado hasta la fecha que elijas. El contenido sigue en '
      'tu Drive, y puedes abrirlo antes si quieres: es un precinto, como el '
      'de la cápsula enterrada en el jardín, no una caja fuerte.';

  @override
  String get aboutPhotos =>
      'Ninguna foto pasa por un servidor nuestro: van directo del celular '
      'a Google Drive.';

  @override
  String get aboutScope =>
      'El aplicativo no ve el resto de tu Drive. El permiso que concedes '
      'da acceso solo a los archivos que él mismo crea, todos dentro de la '
      'carpeta "Meu Bebê - Cápsula do Tempo". Tus demás carpetas son '
      'invisibles para él.';

  @override
  String get aboutIndex =>
      'Lo que queda en nuestro servidor es el índice: nombre, fecha de '
      'nacimiento, peso, altura, fechas y el texto de las cartas. Es lo que '
      'hace que la línea de tiempo y la búsqueda funcionen. Puedes borrar '
      'todo esto cuando quieras, en tu perfil.';

  @override
  String get aboutLastingTitle => 'Para que la cápsula dure';

  @override
  String get deleteDriveNote =>
      'Aunque los envíes a la papelera, los archivos son tuyos y están en '
      'tu Drive: el aplicativo nunca tuvo una copia de ellos.';

  @override
  String get profilePhotoNote =>
      'La foto de perfil sale de los recuerdos ya guardados. Agrega una '
      'foto para poder elegir.';

  @override
  String get remindersHowTitle => 'Sobre qué';

  @override
  String get remindersMarkedTitle => 'Lo que está marcado';

  @override
  String get remindersFrequency =>
      'Como máximo dos por semana, nunca dos el mismo día.';

  @override
  String get remindersOffNote =>
      'Apagado. No se envía nada. Si el celular ha negado las '
      'notificaciones, habilítalas en Ajustes, Aplicaciones, Meu Bebê.';

  @override
  String get remindersNothingSoon =>
      'Nada en las próximas semanas. Eso es normal: los recordatorios '
      'aparecen cuando de verdad hay una fecha cerca.';

  @override
  String get remindersPrivacy =>
      'Los recordatorios se calculan dentro de tu celular, a partir de lo '
      'que ya está aquí. Nada se envía a ningún servidor para que esto '
      'ocurra, y ningún aviso cita lo que has guardado.';

  @override
  String get remindersDenied =>
      'Android no autorizó las notificaciones. Puedes habilitarlas en los '
      'ajustes del celular, en Aplicaciones, Meu Bebê.';

  @override
  String get sealedEmptyBody =>
      'Al guardar una carta o un video, puedes elegir una fecha para que '
      'se abra: un cumpleaños, la mayoría de edad, o cualquier otra. '
      'Queda esperando aquí hasta entonces.';

  @override
  String get growthChartHint =>
      'A partir de dos registros, el gráfico empieza a contar la historia.';

  @override
  String get introBody1 =>
      'Guarda los pequeños momentos antes de que se conviertan solo en '
      'recuerdos.';

  @override
  String get introTitle4b => 'Un regalo para el futuro.';

  @override
  String get introBody3 =>
      'Organizamos todo por la edad en que ocurrió, formando una '
      'verdadera línea de tiempo de la infancia.';

  @override
  String get introBody4 =>
      'Un día, esta cápsula podrá ser abierta por quien más importa: '
      'tu hijo.';

  @override
  String get introBody5 =>
      'Recomendamos usar una cuenta de Google exclusiva para guardar todos '
      'estos recuerdos por muchos años.';

  @override
  String get premiumInviteLetters => 'Las cartas son del plan Premium';

  @override
  String get premiumInviteDrawings => 'Los dibujos son del plan Premium';

  @override
  String get premiumInviteDocuments => 'Los documentos son del plan Premium';

  @override
  String get premiumInviteGrowth => 'El crecimiento es del plan Premium';

  @override
  String get premiumInviteGeneric => 'Esto es del plan Premium';

  @override
  String get premiumInvitePrice =>
      'Es una suscripción anual, cobrada y administrada por Google Play, '
      'que muestra el precio en la moneda de tu país.';

  @override
  String get premiumInviteKeeps =>
      'Sin ella nada desaparece: las fotos y los videos siguen libres, y '
      'todo lo que ya está guardado sigue abierto para siempre.';

  @override
  String get documentNameQuestion => 'Cómo quieres llamar a';

  @override
  String get videosLabel => 'Videos';

  @override
  String get sendMemory => 'Enviar recuerdo';

  @override
  String get languageNote =>
      'La elección queda guardada en este dispositivo y vale para todas las '
      'pantallas. Las carpetas ya creadas en Google Drive conservan los '
      'nombres que recibieron.';

  @override
  String get videoOptimizedShort => '540p con bitrate optimizado';

  @override
  String get originalFiles => 'Archivos originales';

  @override
  String get originalFilesNote => 'Siguen en el celular, intactos';

  @override
  String get loginCapsuleHint =>
      'Para crear la cuenta de la cápsula: toca abajo, y en la pantalla de '
      'Google elige Agregar otra cuenta.';

  @override
  String get startupFirebaseHint =>
      'Esto casi siempre es configuración de Firebase: el '
      'google-services.json y el firebase_options.dart deben ser del mismo '
      'proyecto, y Firestore y el inicio de sesión con Google deben estar '
      'activados en la consola.';

  @override
  String get sentToDrive => 'Está guardado';

  @override
  String get dateNotFoundMedia =>
      'No encontramos la fecha dentro del archivo multimedia, así que vale '
      'la de hoy. Toca para cambiarla.';

  @override
  String get dateNotFoundFile =>
      'No encontramos la fecha dentro del archivo, así que vale la de hoy. '
      'Toca para cambiarla.';

  @override
  String inspirationsSubtitle(String nome) =>
      'Ideas para la etapa que $nome está viviendo ahora.';

  @override
  String suggestionsGrowNote(String nome) =>
      'Las sugerencias vuelven a medida que $nome crece y las fechas se '
      'acercan.';

  @override
  String remindersIntroNamed(String nome) =>
      'Los recordatorios vienen activados porque una cápsula del tiempo '
      'solo cumple la promesa si alguien vuelve a ella. Son pocos, y '
      'existen para que no te pierdas el día en que $nome cumple un mes '
      'más.';

  @override
  String remindersHourNote(int hora) =>
      'Siempre entre las 8 y las ${hora}h. El aplicativo no despierta a '
      'nadie de madrugada.';

  @override
  String remindersSummary(int marcados, int total, int hora) =>
      '$marcados de $total tipos, a las ${hora}h';

  @override
  String birthdayOrdinal(int anos) => 'Para el ${ordinal(anos)} cumpleaños';

  @override
  String todayWithDate(String data) => 'Es hoy, $data';

  @override
  String tomorrowWithDate(String data) => 'Mañana, $data';

  @override
  String searchNoResults(String termo) =>
      'No encontramos ninguna publicación con "$termo".';

  @override
  String growthFromBirth(String data) => 'Del nacimiento hasta $data';

  @override
  String savedInDrive(String dono) => 'Está guardado $dono.';

  @override
  String lastUpdated(String data) => 'Última actualización: $data';

  @override
  String batchManyDays(int dias) =>
      'Atención: lo que elegiste es de $dias días diferentes, y todo se '
      'va a guardar con esta fecha. Para separarlo, envía un día a la vez.';

  @override
  String get inspirationsSubtitleGeneric => 'Ideas para la etapa de ahora.';

  @override
  String willBeSavedIn(String dono) => 'Se va a guardar $dono.';

  @override
  String get remindersIntroGeneric =>
      'Los recordatorios vienen activados porque una cápsula del tiempo '
      'solo cumple la promesa si alguien vuelve a ella. Son pocos, y '
      'existen para fechas que pasan sin que nadie se dé cuenta.';

  @override
  String get sealedEmptyIntro =>
      'Al guardar una carta o un video, puedes elegir una fecha de '
      'apertura: los 15 años, los 18, o cualquier otra. Queda esperando '
      'aquí hasta entonces.';

  @override
  String get aboutPhotosNote =>
      'Ninguna foto pasa por un servidor nuestro: van directo de tu '
      'dispositivo al Google Drive de tu cuenta.';

  @override
  String get profilePhotoEmpty =>
      'La foto de perfil sale de los recuerdos ya guardados. Agrega una '
      'foto para poder elegir.';

  @override
  String remindersHourRange(int inicio, int fim) =>
      'Entre las $inicio y las ${fim}h. El aplicativo no despierta a nadie '
      'de madrugada.';

  @override
  String get typeOneBirth => 'nacimiento';

  @override
  String get typeOnePhoto => 'foto';

  @override
  String get typeOneLetter => 'carta';

  @override
  String get typeOneDrawing => 'dibujo';

  @override
  String get typeOneDocument => 'documento';

  @override
  String get typeManyBirths => 'nacimientos';

  @override
  String get typeManyPhotos => 'fotos';

  @override
  String get typeManyVideos => 'videos';

  @override
  String get typeManyLetters => 'cartas';

  @override
  String get typeManyDrawings => 'dibujos';

  @override
  String get typeManyDocuments => 'documentos';

  @override
  String get typeManyGrowth => 'mediciones';

  @override
  String get theGrowth => 'el crecimiento';

  @override
  String get documentNameQuestionFull => 'Cómo quieres llamar a';

  @override
  String get loginCreateAccountHint =>
      'Para crear la cuenta de la cápsula: toca abajo, y en el cuadro de '
      'Google elige "Agregar otra cuenta" y después "Crear cuenta".';

  @override
  String get aboutInactivity =>
      'Google elimina las cuentas que pasan dos años sin uso, y con ellas '
      'se va lo que esté en su Drive. Esto vale sobre todo para quien creó '
      'una cuenta solo para la cápsula.\n\nAbrir este aplicativo de vez en '
      'cuando ya cuenta como uso, así que no hace falta hacer nada más. '
      'Aun así, si pasas casi un año sin aparecer, el aplicativo avisa una '
      'vez, y ese aviso se puede apagar en Configuración.';

  @override
  String get profilePhotoFromMemories =>
      'La foto de perfil sale de los recuerdos ya guardados. Agrega una '
      'foto y aparecerá aquí.';

  @override
  String premiumInviteWhat(String tipos, String deQuem, String outros) =>
      'Guardar $tipos en la cápsula$deQuem es parte del Premium, junto '
      'con $outros.';

  @override
  String profilePhotoEmptyOf(String deQuem) =>
      'La foto de perfil sale de los recuerdos ya guardados. Agrega una '
      'foto $deQuem y aparecerá aquí.';

  @override
  String comArtigo(String plural) => 'los $plural';

  @override
  String get errNoConnection => 'Sin conexión a internet. Inténtalo de nuevo.';

  @override
  String get errFileRead => 'No se pudo leer el archivo en el dispositivo.';

  @override
  String get errPermissionDenied =>
      'El servidor rechazó la escritura. Cierra la sesión y vuelve a '
      'entrar; si continúa, es una configuración del aplicativo, no tuya.';

  @override
  String get errSessionExpired =>
      'Tu sesión expiró. Vuelve a entrar para continuar.';

  @override
  String get errMissingIndex =>
      'Tus recuerdos están guardados, pero el servidor todavía no puede '
      'organizarlos para mostrarlos aquí. Es una configuración del '
      'aplicativo, no tuya.';

  @override
  String get errServerQuiet =>
      'El servidor no respondió. Inténtalo de nuevo en unos instantes.';

  @override
  String get errRecentLogin =>
      'Por seguridad, vuelve a entrar antes de continuar.';

  @override
  String get errGeneric => 'No se pudo completar. Inténtalo de nuevo.';

  @override
  String get errDriveExpired =>
      'El acceso a Google Drive expiró. Cierra la sesión y vuelve a '
      'entrar para renovar el permiso.';

  @override
  String get errDriveNotEnabled =>
      'Google Drive todavía no está habilitado para este aplicativo. Es '
      'una configuración nuestra, no tuya: nada de lo que completaste se '
      'perdió.';

  @override
  String get errDriveFull =>
      'Tu Google Drive se quedó sin espacio. Libera espacio en la cuenta '
      'e inténtalo de nuevo.';

  @override
  String get errDriveRateLimit =>
      'Google Drive pidió esperar un poco. Inténtalo de nuevo en unos '
      'instantes.';

  @override
  String get errDriveForbidden =>
      'Google Drive rechazó el acceso. Cierra la sesión y vuelve a entrar '
      'para autorizar la carpeta de la cápsula.';

  @override
  String get errDriveFolderMissing =>
      'No se encontró la carpeta de la cápsula en tu Google Drive.';

  @override
  String get errDriveQuiet =>
      'Google Drive no respondió. Inténtalo de nuevo en unos instantes; '
      'nada de lo que completaste se perdió.';

  @override
  String get errDriveGeneric =>
      'No se pudo contactar a Google Drive. Inténtalo de nuevo.';

  @override
  String get authSlow =>
      'El inicio de sesión con Google está tardando en responder. Revisa '
      'la conexión e inténtalo de nuevo.';

  @override
  String get authUnsupported =>
      'Este dispositivo no ofrece el inicio de sesión con Google.';

  @override
  String get authNoIdentifier =>
      'No recibimos el identificador de la cuenta. Revisa la '
      'configuración del inicio de sesión con Google e inténtalo de nuevo.';

  @override
  String get authOtherAccount =>
      'El permiso guardado es de otra cuenta de Google. Vuelve a entrar '
      'para seguir guardando en esta cápsula.';

  @override
  String get authRenewDrive =>
      'Necesitamos renovar el permiso de Google Drive.';

  @override
  String get authSignInToContinue =>
      'Entra con tu cuenta de Google para continuar.';

  @override
  String get authDriveRefused =>
      'No autorizaste el acceso a Google Drive. Ahí es donde se guardan '
      'los recuerdos, en tu propia cuenta.';

  @override
  String get authReloginToDelete =>
      'Para eliminar la cuenta, vuelve a entrar y repite la operación.';

  @override
  String get authScreenFailed =>
      'No se pudo abrir la pantalla de Google. Inténtalo de nuevo.';

  @override
  String get authConfigIncomplete =>
      'La configuración del inicio de sesión con Google está incompleta.';

  @override
  String get authServicesUnavailable =>
      'Servicios de Google no disponibles en este dispositivo.';

  @override
  String get authWrongAccount =>
      'La cuenta elegida es distinta de la cuenta en uso.';

  @override
  String get emptyDocuments => 'Todavía no hay documentos';

  @override
  String get emptyDrawings => 'Todavía no hay dibujos';

  @override
  String get emptyLetters => 'Todavía no hay cartas';

  @override
  String get emptyPhotos => 'Todavía no hay fotos';

  @override
  String get emptySealed => 'Nada precintado todavía';

  @override
  String get emptyMoments => 'Nada pendiente por aquí';

  @override
  String get emptyInspirations => 'Nada por aquí ahora';

  @override
  String get emptySearchTopic => 'Nada sobre esto todavía';

  @override
  String get firstPhotosHint => 'Toca el + para agregar las primeras fotos.';

  @override
  String daysLeft(int dias) => dias == 1 ? 'Falta 1 día' : 'Faltan $dias días';

  @override
  String daysLeftWithDate(int dias, String data) => 'Faltan $dias días, $data';

  @override
  String remindersSummaryFull(int marcados, int total, int hora) =>
      '$marcados de $total tipos, a las ${hora}h';

  @override
  String contarSemanas(int n) => n == 1 ? '1 semana' : '$n semanas';

  @override
  String semanaNumero(String n) => 'Semana $n';

  @override
  String mesNumero(String n) => 'Mes $n';

  @override
  String anoNumero(String n) => 'Año $n';

  @override
  String uploadWithDate(String oQue, String data) =>
      '$oQue con la fecha del $data.';

  @override
  String uploadBornThatDay(String nome) => 'Fue el día en que nació $nome.';

  @override
  String uploadBornThatDayGeneric() => 'Fue el día del nacimiento.';

  @override
  String uploadAgeThen(String nome, String idade) =>
      'En esa fecha $nome tenía $idade.';

  @override
  String uploadAgeThenGeneric(String idade) => 'Edad en esa fecha: $idade.';

  @override
  String uploadWhereInDrive(String caminho) =>
      'En el Drive, va a quedar en $caminho.';

  @override
  String get holidayNewYear => 'Año Nuevo';

  @override
  String get holidayCarnival => 'Carnaval';

  @override
  String get holidayEaster => 'Pascua';

  @override
  String get holidayMothers => 'Día de la Madre';

  @override
  String get holidayFathers => 'Día del Padre';

  @override
  String get holidayChristmas => 'Navidad';

  @override
  String get kindLetter => 'Idea de carta';

  @override
  String get kindReading => 'Lectura';

  @override
  String get kindPrep => 'Preparativo';

  @override
  String get kindRoutine => 'Rutina y organización';

  @override
  String get kindEveryday => 'Del día a día';

  @override
  String get kindPlay => 'Juego';

  @override
  String get notifChannelName => 'Recordatorios de la cápsula';

  @override
  String get notifChannelDescription =>
      'Fechas redondas, cumpleaños y recordatorios de guardar un recuerdo.';

  @override
  String get errPhotoCompress => 'No se pudo comprimir esta foto.';

  @override
  String get errVideoConvert => 'No se pudo convertir este video.';

  @override
  String get errOriginalsMissing =>
      'Los archivos originales no están en este dispositivo.';

  @override
  String get errPickPhotoAgain => 'Elige la foto de nuevo para guardarla.';

  @override
  String get errOriginalsMissingFull =>
      'Los archivos originales no están en este dispositivo. Vuelve a '
      'enviarlos desde el celular donde fueron elegidos.';

  @override
  String get errFileGoneFull =>
      'El archivo salió de este dispositivo antes de que el envío '
      'terminara. Elige la foto de nuevo para guardarla.';

  @override
  String get kindOuting => 'Paseo y aire libre';

  @override
  String get kindPhoto => 'Idea de foto';

  @override
  String get reminderRoundLabel => 'Fechas redondas';

  @override
  String get reminderRoundDesc => 'Mensiversarios y el cambio de cada año';

  @override
  String get reminderBirthdayLabel => 'Cumpleaños';

  @override
  String get reminderBirthdayDesc => 'Una semana antes, y el mismo día';

  @override
  String get reminderSpecialLabel => 'Primeras veces del año';

  @override
  String get reminderSpecialDesc => 'Navidad, Pascua, Día de la Madre';

  @override
  String get reminderInspirationLabel => 'Ideas en el momento justo';

  @override
  String get reminderInspirationDesc => 'Cuando una idea solo sirve ahora';

  @override
  String get reminderAbsenceLabel => 'Recordatorio amable';

  @override
  String get reminderAbsenceDesc =>
      'Cuando hace mucho tiempo que no registras nada';

  @override
  String get reminderInactiveLabel => 'La cuenta de Google';

  @override
  String get reminderInactiveDesc =>
      'Un aviso al año, para que la cápsula no se pierda';

  @override
  String get notifWeekLeftTitle => 'Falta una semana';

  @override
  String get notifBirthdayTodayGeneric => 'Es hoy. Guarda algo de este día.';

  @override
  String get notifMomentTitle => 'Un instante de hoy';

  @override
  String get notifInactiveTitle => 'La cápsula te necesita por un minuto';

  @override
  String get notifPhotoWorthIt =>
      'Una foto de hoy va a valer mucho dentro de veinte años.';

  @override
  String get notifAbsenceGeneric =>
      'Hace tiempo desde el último recuerdo. Una foto cualquiera, del modo '
      'en que esté el día, ya alcanza.';

  @override
  String get notifInactiveGeneric =>
      'Hace casi un año que no abres. Google elimina cuentas sin uso '
      'después de dos años, y en una de ellas viven los recuerdos. Abrir '
      'de vez en cuando ya alcanza.';

  @override
  String get theChild => 'el niño o la niña';

  @override
  String notifFirstBirthdaySoon(String quem) =>
      'El primer cumpleaños $quem es dentro de siete días. Buen momento '
      'para elegir las fotos del primer año.';

  @override
  String notifBirthdaySoon(String quem, int anos) =>
      '$quem cumple $anos años dentro de siete días.';

  @override
  String notifBirthdayTitle(int anos) =>
      anos == 1 ? 'Un año hoy' : '$anos años hoy';

  @override
  String notifBirthdayToday(String deQuem) =>
      'Hoy es el día $deQuem. Guarda algo de este día.';

  @override
  String notifMonthsTitle(int meses) =>
      meses == 1 ? 'Hoy es 1 mes' : 'Hoy son $meses meses';

  @override
  String notifMonthsBody(String nome, int meses) =>
      '$nome cumple ${contarMeses(meses)} hoy. Una foto de hoy va a valer '
      'mucho dentro de veinte años.';

  @override
  String notifFirstHolidayTitle(String data) => 'El primer $data';

  @override
  String notifFirstHolidayBody(String data, String deQuem) =>
      'Dentro de tres días es el primer $data $deQuem. Vale una foto.';

  @override
  String notifFirstHolidayBodyGeneric(String data) =>
      'Dentro de tres días es el primer $data. Vale una foto.';

  @override
  String notifAbsenceBody(String deQuem) =>
      'Hace tiempo desde el último recuerdo $deQuem. Una foto cualquiera, '
      'del modo en que esté el día, ya alcanza.';

  @override
  String notifInactiveBody(String deQuem) =>
      'Hace casi un año que no abres. Google elimina cuentas sin uso '
      'después de dos años, y en una de ellas viven los recuerdos $deQuem. '
      'Abrir de vez en cuando ya alcanza.';

  @override
  String tituloDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'La primera Navidad',
    'primeiro-ano-novo' => 'El primer Año Nuevo',
    'primeiro-carnaval' => 'El primer Carnaval',
    'primeira-pascoa' => 'La primera Pascua',
    'primeiro-dia-das-maes' => 'El primer Día de la Madre',
    'primeiro-dia-dos-pais' => 'El primer Día del Padre',
    'primeiro-aniversario' => 'Preparando el primer cumpleaños',
    'primeiro-sorriso' => 'La primera sonrisa',
    'primeiro-dentinho' => 'El primer dientecito',
    'primeira-palavra' => 'La primera palabra',
    'primeiros-passos' => 'Los primeros pasos',
    'primeiro-corte-cabelo' => 'El primer corte de pelo',
    'primeira-viagem' => 'El primer viaje',
    'primeira-praia' => 'La primera playa',
    'primeira-escola' => 'El primer día de escuela',
    'primeira-bicicleta' => 'La primera bicicleta',
    _ => id,
  };

  @override
  String? notaDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'La primera Navidad {nome} está llegando.',
    'primeiro-ano-novo' => 'El primer cambio de año {nome}.',
    'primeiro-carnaval' => 'Un disfraz, una foto, y listo.',
    'primeiro-dia-das-maes' =>
      '¿Qué tal una carta para que {nome} lea dentro de muchos años?',
    'primeiro-aniversario' => 'El primer año {nome} está llegando.',
    'primeiro-sorriso' => 'Suele aparecer alrededor de las seis semanas.',
    'primeira-palavra' =>
      'Graba la voz {nome}. Dentro de veinte años, eso no tiene precio.',
    'primeiros-passos' => 'Vale más en video que en foto.',
    'primeiro-corte-cabelo' => 'Antes y después, si se puede.',
    _ => null,
  };

  @override
  List<String> checklistDoAniversario() => <String>[
    'Elegir el tema',
    'Definir a los invitados',
    'Elegir el pastel',
    'Comprar la ropa',
    'Grabar un video',
    'Escribir una carta para el futuro',
  ];

  @override
  String get languageStepTitle => '¿En qué idioma?';

  @override
  String get languageStepNote =>
      'Vale para todo el aplicativo y para los nombres de las carpetas en '
      'Google Drive. Las carpetas quedan con el idioma de ahora para '
      'siempre, aunque cambies el del aplicativo después.';

  @override
  String get closeLabel => 'Cerrar';

  @override
  String get skip => 'Saltar';

  @override
  String get createRecommendedAccount => 'Crear la cuenta recomendada';

  @override
  String get useCurrentAccount => 'Usar mi cuenta actual';

  @override
  String get exactlyToday => 'Hoy se cumplen exactamente';

  @override
  String get beenAWhile => 'Hace un tiempo';

  @override
  String get toLiveNow => 'Para vivir ahora';

  @override
  String forNameNow(String nome) => 'Para $nome, ahora';

  @override
  String get readThePost => 'Leer la publicación';

  @override
  String get inspirationsChangeNote =>
      'Las ideas cambian según la edad. Vuelve pronto.';

  @override
  String get savingEllipsis => 'Guardando...';

  @override
  String get viewFolder => 'Ver la carpeta';

  @override
  String get viewDrawing => 'Ver el dibujo';

  @override
  String get documentName => 'Nombre del documento';

  @override
  String documentNameOf(int atual, int total) =>
      'Nombre del documento $atual de $total';

  @override
  String get keep => 'Guardar';

  @override
  String get keepForFuture => 'Guardar para el futuro';

  @override
  String get savedForFuture => 'Guardado para el futuro';

  @override
  String get opensToday => 'Se abre hoy';

  @override
  String opensOn(String data) => 'Se abre el $data';

  @override
  String sealedUntilNotice(String data) => 'Guardado para abrirse el $data.';

  @override
  String whenTurns(int anos) => 'Cuando cumpla $anos años';

  @override
  String opensInYearsAtAge(int anos, int idade) =>
      'Dentro de ${contarAnos(anos)}, a los $idade';

  @override
  String get writeSomethingFirst => 'Escribe algo antes de guardar.';

  @override
  String get noAppForFile => 'Ninguna aplicación puede abrir este archivo.';

  @override
  String get drawingsEmptyBody =>
      'Fotografía un dibujo y quedará guardado para siempre.';

  @override
  String birthdayAgeOf(int anos, String deQuem) =>
      '${contarAnos(anos)} $deQuem';

  @override
  String get atBirth => 'Al nacer';

  @override
  String get conjuncaoE => 'y';

  @override
  String savedInFolder(String pasta, String conta) =>
      'Está guardado en $pasta, $conta.';

  @override
  String willBeSavedInFolder(String pasta) => 'Se va a guardar en $pasta.';

  @override
  String get renameDocument => 'Renombrar documento';

  @override
  String get rename => 'Renombrar';

  @override
  String get addedOn => 'Añadido el';

  @override
  String get sizeLabel => 'Tamaño';

  @override
  String get fewRecords => 'Pocos registros';

  @override
  String get recentPhotos => 'Fotos recientes';

  @override
  String get seeAll => 'Ver todas';

  @override
  String get record => 'Registrar';

  @override
  String get searchPosts => 'Buscar en las publicaciones';

  @override
  String get searchPostsHint => 'Buscar en las publicaciones...';

  @override
  String get clearLabel => 'Borrar';

  @override
  String get tryAgainShortly => 'Intenta abrirlo de nuevo en un momento.';

  @override
  String get write => 'Escribir';

  @override
  String get importantMoments => 'Momentos importantes';

  @override
  String get hospital => 'Hospital';

  @override
  String get girl => 'Niña';

  @override
  String get boy => 'Niño';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get changeProfilePhoto => 'Cambiar la foto de perfil';

  @override
  String get receiveReminders => 'Recibir recordatorios';

  @override
  String get atWhatTime => 'A qué hora';

  @override
  String get chooseAnotherDate => 'Elegir otra fecha';

  @override
  String get removeSeal => 'Quitar el sello';

  @override
  String get checkTheDate => '¿La fecha es correcta?';

  @override
  String get savingDrawing => 'Guardando el dibujo...';

  @override
  String get convertingAndSending => 'Convirtiendo a 540p y enviando...';

  @override
  String get viewDocument => 'Ver el documento';

  @override
  String get viewDocuments => 'Ver los documentos';

  @override
  String get groupBy => 'Agrupar por';

  @override
  String umDoTipo(String tipo) => 'Un $tipo';
  @override
  String get titleHintExample => 'Primera sonrisa';
}
