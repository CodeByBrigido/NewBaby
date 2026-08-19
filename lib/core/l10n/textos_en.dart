import 'textos.dart';

/// The app in English.
///
/// Escrito como inglês, e não como português traduzido palavra a palavra.
/// Onde a frase portuguesa dependia de um jeito de dizer que não existe em
/// inglês, a frase inglesa foi reescrita para dizer a mesma coisa do jeito
/// que se diz lá.
///
/// **O nome da pasta no Google Drive não está aqui, e não deve estar.** Ele é
/// uma constante do `DriveService`, em português, e continua assim para todo
/// mundo: traduzi-lo faria o aplicativo procurar uma pasta com outro nome e
/// deixar para trás tudo o que a família já guardou.
class TextosEn implements Textos {
  const TextosEn();

  @override
  String get codigo => 'en';

  @override
  String get appName => 'My Baby';

  @override
  String get appFullName => 'My Baby: Time Capsule';

  @override
  String get appSubtitle => 'Time Capsule';

  @override
  String get appTagline => 'Every moment, a memory for life.';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInNote =>
      'Every memory is saved to your child\'s own Google Drive account.';

  @override
  String get signInError =>
      'Could not sign in. Check your connection and try again.';

  @override
  String get onboardingGreeting => 'Hello!';

  @override
  String get fullName => 'Full name';

  @override
  String get gender => 'Boy or girl?';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get birthTime => 'Time of birth';

  @override
  String get birthWeight => 'Birth weight';

  @override
  String get birthHeight => 'Birth length';

  @override
  String get birthTimeOptional => 'Time of birth (optional)';

  @override
  String get birthWeightOptional => 'Birth weight (optional)';

  @override
  String get birthHeightOptional => 'Birth length (optional)';

  @override
  String get hospitalOptional => 'Hospital (optional)';

  @override
  String get birthPhoto => 'Birth photo';

  @override
  String get continueLabel => 'Continue';

  @override
  String get preparingDrive => 'Setting up the folders in Google Drive...';

  @override
  String get home => 'Home';

  @override
  String get timeline => 'Timeline';

  @override
  String get search => 'Search';

  @override
  String get accountsLabel => 'ACCOUNTS';

  @override
  String get switchAccount => 'Switch account';

  @override
  String get profile => 'Profile';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get letters => 'Letters';

  @override
  String get drawings => 'Drawings';

  @override
  String get documents => 'Documents';

  @override
  String get growth => 'Growth';

  @override
  String get stats => 'Statistics';

  @override
  String get trash => 'Trash';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About this app';

  @override
  String get signOut => 'Sign out';

  @override
  String get storedWithLove => 'Kept with love in the Drive of';

  @override
  String get addQuestion => 'What would you like to add?';

  @override
  String get addPhoto => 'Photo';

  @override
  String get addVideo => 'Video';

  @override
  String get addLetter => 'Letter';

  @override
  String get addDrawing => 'Drawing';

  @override
  String get addDrawingHint => 'Add a drawing';

  @override
  String get addDocument => 'Document';

  @override
  String get addDocumentHint => 'Add important documents';

  @override
  String get addGrowth => 'Growth';

  @override
  String get addGrowthHint => 'Record weight and length';

  @override
  String get timelineEmptyTitle => 'The story starts here';

  @override
  String get birth => 'Birth';

  @override
  String get photosAdded => 'Photos added';

  @override
  String get photoAdded => 'Photo added';

  @override
  String get videoAdded => 'Video added';

  @override
  String get drawingAdded => 'Drawing added';

  @override
  String get documentAdded => 'Document added';

  @override
  String get growthRecord => 'Growth record';

  @override
  String get letterPrefix => 'Letter:';

  @override
  String get filterAll => 'All';

  @override
  String get filterTitle => 'Filter by type';

  @override
  List<String> get milestoneSuggestions => const <String>[
    'First photo',
    'First bath',
    'First outing',
    'First trip',
    'First smile',
    'First tooth',
    'First steps',
    'First word',
    'First birthday',
  ];

  @override
  String get letterStartersTitle => 'Not sure how to start?';

  @override
  List<String> get letterStarters => const <String>[
    'Today I want to tell you about ',
    'By the time you read this, ',
    'You do not know it yet, but ',
    'One thing I never want to forget: ',
    'If I could tell you only one thing, it would be ',
    'The day you ',
    'Of everything you are today, what I love most is ',
  ];

  @override
  String get titleField => 'Title';

  @override
  String get messageField => 'Message';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get milestoneOptional => 'Milestone (optional)';

  @override
  String get weightField => 'Weight';

  @override
  String get heightField => 'Length';

  @override
  String get photoOptional => 'Photo (optional)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get restore => 'Restore';

  @override
  String get view => 'View';

  @override
  String get download => 'Download';

  @override
  String get retry => 'Try again';

  @override
  String get weeks => 'Weeks';

  @override
  String get months => 'Months';

  @override
  String get years => 'Years';

  @override
  String get photosOptimizedNote =>
      'Photos are compressed automatically to save space.';

  @override
  String get videoOptimizedNote =>
      'This video was saved at 540p to save space.';

  @override
  String get allFilesOptimizedNote => 'Every file is optimised to save space.';

  @override
  String get uploadPending => 'Waiting to upload';

  @override
  String get uploadOptimizing => 'Optimising...';

  @override
  String get uploadSending => 'Uploading...';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get uploadingCount => 'Uploading';

  @override
  String get searchHint => 'Search memories...';

  @override
  String get searchByCategory => 'Search by category';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get searchEmpty => 'Nothing found here.';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get storageUsed => 'Storage used';

  @override
  String get storageOf => 'of';

  @override
  String get capsuleStorage => 'Time Capsule';

  @override
  String get driveStorage => 'Your Google Drive';

  @override
  String get driveStorageNote =>
      'The total above is for your whole Google account. The app can only '
      'see the files it created itself, inside the capsule folder. It cannot '
      'reach anything else in your Drive.';

  @override
  String get lockSection => 'Privacy';

  @override
  String get lockTitle => 'App lock';

  @override
  String get lockBody =>
      'Asks for your fingerprint, face or device PIN to open the app. Off by '
      'default.';

  @override
  String get lockUnavailable =>
      'This device has no fingerprint, face or PIN set up. Set up a screen '
      'lock in your Android settings to use this option.';

  @override
  String get lockNote =>
      'The lock protects you from someone picking up your phone already '
      'unlocked. It does not encrypt anything: it is one more door, not a '
      'safe.';

  @override
  String get lockFailed => 'Could not confirm. The lock stays off.';

  @override
  String get lockReason => 'Confirm it is you to open the memories.';

  @override
  String get lockedTitle => 'App locked';

  @override
  String get lockedBody => 'Confirm your identity to see the memories.';

  @override
  String get unlock => 'Unlock';

  @override
  String get viewChart => 'View chart';

  @override
  String get growthChart => 'Growth chart';

  @override
  String get growthEmptyTitle => 'No records yet';

  @override
  String get growthEmptyBody =>
      'Record weight and length to follow the growth.';

  @override
  String get trashEmptyTitle => 'The trash is empty';

  @override
  String get trashEmptyBody =>
      'Deleted items stay here until you remove them for good.';

  @override
  String get trashNote => 'The files also go to your Google Drive trash.';

  @override
  String get deleteForever => 'Delete for good';

  @override
  String get deleteConfirmTitle => 'Delete this item?';

  @override
  String get deleteConfirmBody =>
      'It goes to the trash and can be restored later.';

  @override
  String get deleteForeverConfirmBody => 'This cannot be undone.';

  @override
  String get currentAge => 'Age today';

  @override
  String get birthDateShort => 'Born';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody =>
      'Your memories stay in your Google Drive. Thumbnails and downloaded '
      'files are cleared from this device.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get accountDeletionTitle => 'Account and data deletion';

  @override
  String get accountDeletionShort => 'Delete account';

  @override
  String get goToDeleteAccount => 'Go to account deletion';

  @override
  String get deleteAccount => 'Delete my account and my data';

  @override
  String get deleteAccountTitle => 'Delete the account?';

  @override
  String get deleteAccountBody =>
      'We delete everything we keep about you on our server: the profile, the '
      'timeline, the growth records and the text of the letters. We also give '
      'up our permission to your Google Drive.\n\n'
      'This cannot be undone.';

  @override
  String get deleteAccountDriveQuestion =>
      'And the "Meu Bebê - Cápsula do Tempo" folder in your Drive?';

  @override
  String get deleteAccountKeepDrive => 'Keep the files';

  @override
  String get deleteAccountKeepDriveHint =>
      'The photos, videos and documents stay in your Drive, organised by age. '
      'Recommended.';

  @override
  String get deleteAccountTrashDrive => 'Move to trash';

  @override
  String get deleteAccountTrashDriveHint =>
      'The folder goes to the Google Drive trash and can be recovered for 30 '
      'days.';

  @override
  String get deleteAccountWorking => 'Deleting...';

  @override
  String get deleteAccountDone => 'Account deleted.';

  @override
  String get genericError => 'Something went wrong. Try again.';

  @override
  String get noItemsYet => 'Nothing here yet.';

  @override
  String get requiredField => 'Please fill this in';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get codigoIntl => 'en';

  @override
  String get padraoData => 'MM/dd/yyyy';

  @override
  String get padraoDiaMes => 'MM/dd';

  @override
  String get padraoDataLonga => 'MMMM d, yyyy';

  @override
  String get padraoMesAno => 'MMMM yyyy';

  @override
  String get padraoHora => 'h:mm a';

  @override
  String get entreDatas => 'to';

  @override
  String get hoje => 'Today';

  @override
  String get ontem => 'Yesterday';

  @override
  String saudacao(int hora) {
    if (hora < 12) return 'Good morning';
    if (hora < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  String haTempo(int dias) {
    if (dias <= 0) return 'today';
    if (dias == 1) return 'yesterday';
    if (dias < 14) return '$dias days ago';
    if (dias < 60) {
      final int semanas = dias ~/ 7;
      return semanas == 1 ? '1 week ago' : '$semanas weeks ago';
    }
    if (dias < 365) {
      final int meses = dias ~/ 30;
      return meses == 1 ? '1 month ago' : '$meses months ago';
    }
    final int anos = dias ~/ 365;
    return anos == 1 ? '1 year ago' : '$anos years ago';
  }

  @override
  String ordinal(int n) => switch (n) {
    1 => 'first',
    2 => 'second',
    3 => 'third',
    4 => 'fourth',
    5 => 'fifth',
    6 => 'sixth',
    7 => 'seventh',
    8 => 'eighth',
    9 => 'ninth',
    10 => 'tenth',
    // 11th, 12th, 13th fogem da regra do último dígito.
    _ when n % 100 >= 11 && n % 100 <= 13 => '${n}th',
    _ when n % 10 == 1 => '${n}st',
    _ when n % 10 == 2 => '${n}nd',
    _ when n % 10 == 3 => '${n}rd',
    _ => '${n}th',
  };

  @override
  String contarDias(int n) => n == 1 ? '1 day' : '$n days';

  @override
  String contarMeses(int n) => n == 1 ? '1 month' : '$n months';

  @override
  String contarAnos(int n) => n == 1 ? '1 year' : '$n years';

  @override
  String contarItens(int n) => n == 1 ? '1 item' : '$n items';

  @override
  String contarFotos(int n) => n == 1 ? '1 photo' : '$n photos';

  @override
  String contarVideos(int n) => n == 1 ? '1 video' : '$n videos';

  @override
  String get lastBirth => 'Latest birth';

  @override
  String get lastPhoto => 'Latest photo';

  @override
  String get lastVideo => 'Latest video';

  @override
  String get lastLetter => 'Latest letter';

  @override
  String get lastDrawing => 'Latest drawing';

  @override
  String get lastDocument => 'Latest document';

  @override
  String get lastGrowth => 'Latest measurement';

  @override
  String get oneVideo => 'video';

  @override
  String get oneGrowth => 'measurement';

  @override
  String get imageOpenFailed => 'Could not open this image.';

  @override
  String get videoOpenFailed => 'Could not open this video.';

  @override
  String get documentNotFound => 'Document not found';

  @override
  String get letterNotFound => 'Letter not found';

  @override
  String get entryNotFound => 'Memory not found';

  @override
  String get driveSpaceFailed => 'Could not read your Google Drive space.';

  @override
  String get firstVideoHint => 'Tap + to add the first video.';

  @override
  String get documentsEmptyBody =>
      'Birth certificate, vaccination record, passport: all in one place.';

  @override
  String get isToday => 'Today';

  @override
  String get isTodayBang => 'Today!';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get nextMilestone => 'Next milestone';

  @override
  String faltamDias(int dias) => '${contarDias(dias)} from now';

  @override
  String get seeInspiration => 'Read more';

  @override
  String get forYou => 'For you';

  @override
  String get notYet => 'not yet';

  @override
  String get inspirations => 'Inspirations';

  @override
  String get inspirationsLoadFailed => 'Could not load the ideas';

  @override
  String get inspirationSearchHint => 'What would you like to know?';

  @override
  String get suggestionsByAge =>
      'Suggestions appear as the age and the calendar move along.';

  @override
  String get notNow => 'Not now';

  @override
  String get savedTitle => 'It is saved';

  @override
  String get willBeSaved => 'It will be saved';

  @override
  String get sendMemoryError => 'Save memory';

  @override
  String get dateFromFile => 'Date read from the file itself. Tap to change.';

  @override
  String get deletedOn => 'Deleted on ';

  @override
  String get itemDeleted => 'Item deleted.';

  @override
  String get documentNameSuggestion => 'Birth certificate';

  @override
  String get saveInfo => 'Save details';

  @override
  String get editInfo => 'Edit details';

  @override
  String get notProvided => 'Not provided';

  @override
  String get automatic => 'Automatic';

  @override
  String get reviewIntro => 'See the introduction again';

  @override
  String get lastUpdatedLabel => 'Last updated';

  @override
  String get optimization => 'Optimisation';

  @override
  String get photoMaxSide => 'Up to 960 px on the long side';

  @override
  String get optimizationNote =>
      'Optimisation is automatic and cannot be turned off: it is what keeps the archive light for many years.';

  @override
  String get languageSection => 'Language';

  @override
  String get clearCacheBody =>
      'Clears thumbnails, temporary files and documents already downloaded. Nothing is lost: everything stays in Google Drive.';

  @override
  String get cacheCleared => 'Cache cleared.';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get storageOnDevice => 'Storage on this device';

  @override
  String get remindersSection => 'Reminders';

  @override
  String get remindersOff => 'Off';

  @override
  String get startupFailedTitle => 'The app could not start';

  @override
  String get technicalDetail => 'Technical detail';

  @override
  String get premiumInviteAction => 'Got it';

  @override
  String get introTitle1 => 'Childhood goes by fast.';

  @override
  String get introTitle2 => 'Every memory has its place.';

  @override
  String get introBody2 =>
      'Photos, videos, letters, drawings, documents and growth records. All gathered in one place.';

  @override
  String get introTitle3 => 'Each memory in its own time.';

  @override
  String get introTitle4 => 'Shall we create this capsule?';

  @override
  String get sealBody =>
      'This stays closed until the date you choose. The content remains in your Drive, and you can open it earlier if you want: it is a seal, like the one on a capsule buried in the garden, not a safe.';

  @override
  String get aboutPhotos =>
      'No photo passes through a server of ours: they go straight from your '
      'phone to Google Drive.';

  @override
  String get aboutScope =>
      'The app cannot see the rest of your Drive. The permission you grant gives access only to the files it creates itself, all inside the "Meu Bebê - Cápsula do Tempo" folder. Your other folders are invisible to it.';

  @override
  String get aboutIndex =>
      'What stays on our server is the index: name, date of birth, weight, '
      'length, dates and the text of the letters. It is what makes the '
      'timeline and the search work. You can delete all of it at any time, in '
      'your profile.';

  @override
  String get aboutLastingTitle => 'For the capsule to last';

  @override
  String get deleteDriveNote =>
      'Even when moved to the trash, the files are yours and live in your Drive: the app never had a copy of them.';

  @override
  String get profilePhotoNote =>
      'The profile photo comes from the memories already kept. Add a photo to be able to choose one.';

  @override
  String get remindersHowTitle => 'About what';

  @override
  String get remindersMarkedTitle => 'What is scheduled';

  @override
  String get remindersFrequency =>
      'Two a week at most, never two on the same day.';

  @override
  String get remindersOffNote =>
      'Off. Nothing is sent. If your phone has denied notifications, allow them in Settings, Apps, My Baby.';

  @override
  String get remindersNothingSoon =>
      'Nothing in the coming weeks. That is normal: reminders show up when there really is a date nearby.';

  @override
  String get remindersPrivacy =>
      'Reminders are worked out inside your phone, from what is already here. Nothing is sent to any server for that to happen, and no notification mentions what you kept.';

  @override
  String get remindersDenied =>
      'Android has not allowed notifications. You can allow them in your phone settings, under Apps, My Baby.';

  @override
  String get sealedEmptyBody =>
      'When you keep a letter or a video, you can choose a date for it to open: a birthday, coming of age, or any other. It waits here until then.';

  @override
  String get growthChartHint =>
      'From two records on, the chart starts telling the story.';

  @override
  String get introBody1 =>
      'Keep the small moments before they become only memories.';

  @override
  String get introTitle4b => 'A gift for the future.';

  @override
  String get introBody3 =>
      'We organise everything by the age it happened, making a real timeline of childhood.';

  @override
  String get introBody4 =>
      'One day, this capsule can be opened by the person who matters most: your child.';

  @override
  String get introBody5 =>
      'We recommend using a dedicated Google account to keep all these memories for many years.';

  @override
  String get premiumInviteLetters => 'Letters are part of Premium';

  @override
  String get premiumInviteDrawings => 'Drawings are part of Premium';

  @override
  String get premiumInviteDocuments => 'Documents are part of Premium';

  @override
  String get premiumInviteGrowth => 'Growth is part of Premium';

  @override
  String get premiumInviteGeneric => 'This is part of Premium';

  @override
  String get premiumInvitePrice =>
      'It is a yearly subscription, billed and managed by Google Play, which shows the price in your country’s currency.';

  @override
  String get premiumInviteKeeps =>
      'Without it nothing disappears: photos and videos stay free, and everything already kept stays open forever.';

  @override
  String get documentNameQuestion => 'What would you like to call';

  @override
  String get videosLabel => 'Videos';

  @override
  String get sendMemory => 'Save memory';

  @override
  String get languageNote =>
      'Your choice is already saved. The app is fully translated: switching here changes every screen.';

  @override
  String get videoOptimizedShort => '540p with optimised bitrate';

  @override
  String get originalFiles => 'Original files';

  @override
  String get originalFilesNote => 'Stay on your phone, untouched';

  @override
  String get loginCapsuleHint =>
      'To create the capsule account: tap below, and on the Google screen choose Add another account.';

  @override
  String get startupFirebaseHint =>
      'This is almost always Firebase configuration: google-services.json and '
      'firebase_options.dart must come from the same project, and Firestore '
      'and Google sign-in must be enabled in the console.';

  @override
  String get sentToDrive => 'It is saved';

  @override
  String get dateNotFoundMedia =>
      'We could not find the date inside the media, so today applies. Tap to change.';

  @override
  String get dateNotFoundFile =>
      'We could not find the date inside the file, so today applies. Tap to change.';

  @override
  String inspirationsSubtitle(String nome) =>
      'Ideas for the stage $nome is living through right now.';

  @override
  String suggestionsGrowNote(String nome) =>
      'Suggestions come back as $nome grows and the dates get closer.';

  @override
  String remindersIntroNamed(String nome) =>
      'Reminders come switched on because a time capsule only keeps its '
      'promise if someone comes back to it. There are few of them, and '
      'they exist so you do not miss the day $nome turns another month.';

  @override
  String remindersHourNote(int hora) =>
      'Always between 8am and $hora:00. The app does not wake anyone in the '
      'middle of the night.';

  @override
  String remindersSummary(int marcados, int total, int hora) =>
      '$marcados of $total types, at $hora:00';

  @override
  String birthdayOrdinal(int anos) => 'For the ${ordinal(anos)} birthday';

  @override
  String todayWithDate(String data) => 'Today, $data';

  @override
  String tomorrowWithDate(String data) => 'Tomorrow, $data';

  @override
  String searchNoResults(String termo) => 'We found no post matching "$termo".';

  @override
  String growthFromBirth(String data) => 'From birth to $data';

  @override
  String savedInDrive(String dono) => 'It is saved in $dono Drive.';

  @override
  String lastUpdated(String data) => 'Last updated: $data';

  @override
  String batchManyDays(int dias) =>
      'Careful: what you picked spans $dias different days, and all of it will '
      'be saved with this one date. To keep them apart, send one day at a '
      'time.';

  @override
  String get inspirationsSubtitleGeneric => 'Ideas for the stage right now.';

  @override
  String willBeSavedIn(String dono) => 'It will be saved in $dono Drive.';

  @override
  String get remindersIntroGeneric =>
      'Reminders come switched on because a time capsule only keeps its promise if someone comes back to it. There are few of them, and they exist for dates that slip by unnoticed.';

  @override
  String get sealedEmptyIntro =>
      'When you keep a letter or a video, you can choose an opening date: '
      'turning 15, turning 18, or any other. It waits here until then.';

  @override
  String get aboutPhotosNote =>
      'No photo passes through a server of ours: they go straight from your device to the Google Drive of your account.';

  @override
  String get profilePhotoEmpty =>
      'The profile photo comes from the memories already kept. Add a photo to be able to choose one.';

  @override
  String remindersHourRange(int inicio, int fim) =>
      'Between $inicio:00 and $fim:00. The app does not wake anyone in the '
      'middle of the night.';

  @override
  String get typeOneBirth => 'birth';

  @override
  String get typeOnePhoto => 'photo';

  @override
  String get typeOneLetter => 'letter';

  @override
  String get typeOneDrawing => 'drawing';

  @override
  String get typeOneDocument => 'document';

  @override
  String get typeManyBirths => 'births';

  @override
  String get typeManyPhotos => 'photos';

  @override
  String get typeManyVideos => 'videos';

  @override
  String get typeManyLetters => 'letters';

  @override
  String get typeManyDrawings => 'drawings';

  @override
  String get typeManyDocuments => 'documents';

  @override
  String get typeManyGrowth => 'measurements';

  @override
  String get theGrowth => 'growth';

  @override
  String get documentNameQuestionFull => 'What would you like to call it';

  @override
  String get loginCreateAccountHint =>
      'To create the capsule account: tap below, and in the Google box choose "Add another account" and then "Create account".';

  @override
  String get aboutInactivity =>
      'Google deletes accounts left unused for two years, and whatever is in their Drive goes with them. That matters most for anyone who created an account just for the capsule.\n\nOpening this app now and then already counts as use, so there is nothing else to do. Even so, if you go almost a year without showing up, the app warns you once, and that warning can be switched off in Settings.';

  @override
  String get profilePhotoFromMemories =>
      'The profile photo comes from the memories already kept. Add a photo and it shows up here.';

  @override
  String premiumInviteWhat(String tipos, String deQuem, String outros) =>
      'Keeping $tipos in$deQuem capsule is part of Premium, along with '
      '$outros.';

  @override
  String profilePhotoEmptyOf(String deQuem) =>
      'The profile photo comes from the memories already kept. Add a photo of '
      '$deQuem and it shows up here.';

  @override
  String comArtigo(String plural) => plural;

  @override
  String get errNoConnection => 'No internet connection. Try again.';

  @override
  String get errFileRead => 'Could not read the file on this device.';

  @override
  String get errPermissionDenied =>
      'The server refused the write. Sign out and back in; if it keeps happening, it is a setting in the app, not yours.';

  @override
  String get errSessionExpired =>
      'Your session has expired. Sign in again to continue.';

  @override
  String get errMissingIndex =>
      'Your memories are saved, but the server cannot organise them for display yet. It is a setting in the app, not yours.';

  @override
  String get errServerQuiet =>
      'The server did not answer. Try again in a moment.';

  @override
  String get errRecentLogin => 'For security, sign in again before continuing.';

  @override
  String get errGeneric => 'Could not finish. Try again.';

  @override
  String get errDriveExpired =>
      'Access to Google Drive has expired. Sign out and back in to renew the permission.';

  @override
  String get errDriveNotEnabled =>
      'Google Drive is not enabled for this app yet. That is a setting on our side, not yours: nothing you filled in was lost.';

  @override
  String get errDriveFull =>
      'Your Google Drive is out of space. Free some space on the account and try again.';

  @override
  String get errDriveRateLimit =>
      'Google Drive asked us to wait a moment. Try again shortly.';

  @override
  String get errDriveForbidden =>
      'Google Drive refused access. Sign out and back in to authorise the capsule folder.';

  @override
  String get errDriveFolderMissing =>
      'The capsule folder was not found in your Google Drive.';

  @override
  String get errDriveQuiet =>
      'Google Drive did not answer. Try again shortly; nothing you filled in was lost.';

  @override
  String get errDriveGeneric => 'Could not reach Google Drive. Try again.';

  @override
  String get authSlow =>
      'Google sign-in is taking too long to answer. Check your connection and try again.';

  @override
  String get authUnsupported => 'This device does not support Google sign-in.';

  @override
  String get authNoIdentifier =>
      'We did not receive the account identifier. Check the Google sign-in setup and try again.';

  @override
  String get authOtherAccount =>
      'The stored permission belongs to a different Google account. Sign in again to keep saving into this capsule.';

  @override
  String get authRenewDrive => 'We need to renew the Google Drive permission.';

  @override
  String get authSignInToContinue =>
      'Sign in with your Google account to continue.';

  @override
  String get authDriveRefused =>
      'You did not authorise access to Google Drive. That is where the memories are kept, in your own account.';

  @override
  String get authReloginToDelete =>
      'To delete the account, sign in again and repeat the operation.';

  @override
  String get authScreenFailed => 'Could not open the Google screen. Try again.';

  @override
  String get authConfigIncomplete => 'The Google sign-in setup is incomplete.';

  @override
  String get authServicesUnavailable =>
      'Google services are unavailable on this device.';

  @override
  String get authWrongAccount =>
      'The account you picked is different from the one in use.';

  @override
  String get emptyDocuments => 'No documents yet';

  @override
  String get emptyDrawings => 'No drawings yet';

  @override
  String get emptyLetters => 'No letters yet';

  @override
  String get emptyPhotos => 'No photos yet';

  @override
  String get emptySealed => 'Nothing sealed yet';

  @override
  String get emptyMoments => 'Nothing pending here';

  @override
  String get emptyInspirations => 'Nothing here right now';

  @override
  String get emptySearchTopic => 'Nothing on that yet';

  @override
  String get firstPhotosHint => 'Tap + to add the first photos.';

  @override
  String daysLeft(int dias) => dias == 1 ? '1 day to go' : '$dias days to go';

  @override
  String daysLeftWithDate(int dias, String data) => '$dias days to go, $data';

  @override
  String remindersSummaryFull(int marcados, int total, int hora) =>
      '$marcados of $total types, at $hora:00';

  @override
  String contarSemanas(int n) => n == 1 ? '1 week' : '$n weeks';

  @override
  String semanaNumero(String n) => 'Week $n';

  @override
  String mesNumero(String n) => 'Month $n';

  @override
  String anoNumero(String n) => 'Year $n';

  @override
  String uploadWithDate(String oQue, String data) => '$oQue dated $data.';

  @override
  String uploadBornThatDay(String nome) => 'That was the day $nome was born.';

  @override
  String uploadBornThatDayGeneric() => 'That was the day of the birth.';

  @override
  String uploadAgeThen(String nome, String idade) =>
      'On that date $nome was $idade.';

  @override
  String uploadAgeThenGeneric(String idade) => 'Age on that date: $idade.';

  @override
  String uploadWhereInDrive(String caminho) => 'In Drive, it goes to $caminho.';

  @override
  String get holidayNewYear => 'New Year';

  @override
  String get holidayCarnival => 'Carnival';

  @override
  String get holidayEaster => 'Easter';

  @override
  String get holidayMothers => 'Mother\'s Day';

  @override
  String get holidayFathers => 'Father\'s Day';

  @override
  String get holidayChristmas => 'Christmas';

  @override
  String get kindLetter => 'Letter idea';

  @override
  String get kindReading => 'Reading';

  @override
  String get kindPrep => 'Getting ready';

  @override
  String get kindRoutine => 'Routine and organisation';

  @override
  String get kindEveryday => 'Everyday life';

  @override
  String get kindPlay => 'Play';

  @override
  String get notifChannelName => 'Capsule reminders';

  @override
  String get notifChannelDescription =>
      'Round dates, birthdays and nudges to keep a memory.';

  @override
  String get errPhotoCompress => 'Could not compress this photo.';

  @override
  String get errVideoConvert => 'Could not convert this video.';

  @override
  String get errOriginalsMissing =>
      'The original files are not on this device.';

  @override
  String get errPickPhotoAgain => 'Pick the photo again to keep it.';

  @override
  String get errOriginalsMissingFull =>
      'The original files are not on this device. Send them again from the phone where they were picked.';

  @override
  String get errFileGoneFull =>
      'The file left this device before the upload finished. Pick the photo again to keep it.';

  @override
  String get kindOuting => 'Outings and fresh air';

  @override
  String get kindPhoto => 'Photo idea';

  @override
  String get reminderRoundLabel => 'Round dates';

  @override
  String get reminderRoundDesc => 'Monthly milestones and each year turning';

  @override
  String get reminderBirthdayLabel => 'Birthday';

  @override
  String get reminderBirthdayDesc => 'A week before, and on the day';

  @override
  String get reminderSpecialLabel => 'Firsts of the year';

  @override
  String get reminderSpecialDesc => 'Christmas, Easter, Mother\'s Day';

  @override
  String get reminderInspirationLabel => 'Ideas at the right time';

  @override
  String get reminderInspirationDesc => 'When an idea is only good now';

  @override
  String get reminderAbsenceLabel => 'A gentle nudge';

  @override
  String get reminderAbsenceDesc =>
      'When it has been a long time without keeping anything';

  @override
  String get reminderInactiveLabel => 'The Google account';

  @override
  String get reminderInactiveDesc =>
      'One warning a year, so the capsule is not lost';

  @override
  String get notifWeekLeftTitle => 'One week to go';

  @override
  String get notifBirthdayTodayGeneric =>
      'It is today. Keep something from this day.';

  @override
  String get notifMomentTitle => 'A moment from today';

  @override
  String get notifInactiveTitle => 'The capsule needs a minute of your time';

  @override
  String get notifPhotoWorthIt =>
      'A photo from today will mean a lot twenty years from now.';

  @override
  String get notifAbsenceGeneric =>
      'It has been a while since the last memory. Any photo at all, however the day looks, is enough.';

  @override
  String get notifInactiveGeneric =>
      'It has been almost a year since you opened the app. Google deletes accounts left unused for two years, and that is where the memories live. Opening it now and then is enough.';

  @override
  String get theChild => 'the child';

  @override
  String notifFirstBirthdaySoon(String quem) =>
      '$quem first birthday is seven days away. A good time to pick the photos '
      'from the first year.';

  @override
  String notifBirthdaySoon(String quem, int anos) =>
      '$quem turns $anos in seven days.';

  @override
  String notifBirthdayTitle(int anos) =>
      anos == 1 ? 'One year today' : '$anos years today';

  @override
  String notifBirthdayToday(String deQuem) =>
      'Today is $deQuem day. Keep something from this day.';

  @override
  String notifMonthsTitle(int meses) => '$meses months today';

  @override
  String notifMonthsBody(String nome, int meses) =>
      '$nome turns ${contarMeses(meses)} today. A photo from today will '
      'mean a lot twenty years from now.';

  @override
  String notifFirstHolidayTitle(String data) => 'The first $data';

  @override
  String notifFirstHolidayBody(String data, String deQuem) =>
      'In three days it is $deQuem first $data. Worth a photo.';

  @override
  String notifFirstHolidayBodyGeneric(String data) =>
      'In three days it is the first $data. Worth a photo.';

  @override
  String notifAbsenceBody(String deQuem) =>
      'It has been a while since $deQuem last memory. Any photo at all, however '
      'the day looks, is enough.';

  @override
  String notifInactiveBody(String deQuem) =>
      'It has been almost a year since you opened the app. Google deletes '
      'accounts left unused for two years, and that is where $deQuem memories '
      'live. Opening it now and then is enough.';

  @override
  String tituloDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'The first Christmas',
    'primeiro-ano-novo' => 'The first New Year',
    'primeiro-carnaval' => 'The first Carnival',
    'primeira-pascoa' => 'The first Easter',
    'primeiro-dia-das-maes' => 'The first Mother\'s Day',
    'primeiro-dia-dos-pais' => 'The first Father\'s Day',
    'primeiro-aniversario' => 'Getting ready for the first birthday',
    'primeiro-sorriso' => 'The first smile',
    'primeiro-dentinho' => 'The first tooth',
    'primeira-palavra' => 'The first word',
    'primeiros-passos' => 'The first steps',
    'primeiro-corte-cabelo' => 'The first haircut',
    'primeira-viagem' => 'The first trip',
    'primeira-praia' => 'The first time at the beach',
    'primeira-escola' => 'The first day of school',
    'primeira-bicicleta' => 'The first bicycle',
    _ => id,
  };

  @override
  String? notaDaSugestao(String id) => switch (id) {
    'primeiro-natal' => '{nome} first Christmas is coming.',
    'primeiro-ano-novo' => '{nome} first turn of the year.',
    'primeiro-carnaval' => 'A costume, a photo, and done.',
    'primeiro-dia-das-maes' =>
      'How about a letter for {nome} to read many years from now?',
    'primeiro-aniversario' => '{nome} first year is coming.',
    'primeiro-sorriso' => 'It usually shows up around six weeks.',
    'primeira-palavra' =>
      'Record {nome} voice. Twenty years from now, that is priceless.',
    'primeiros-passos' => 'Worth more on video than in a photo.',
    'primeiro-corte-cabelo' => 'Before and after, if you can.',
    _ => null,
  };

  @override
  List<String> checklistDoAniversario() => <String>[
    'Choose the theme',
    'Decide the guest list',
    'Choose the cake',
    'Buy the outfit',
    'Record a video',
    'Write a letter for the future',
  ];

  @override
  String get languageStepTitle => 'Which language?';

  @override
  String get languageStepNote =>
      'This applies to the whole app and to the folder names in Google Drive. The folders keep this language forever, even if you change the app language later.';

  @override
  String get closeLabel => 'Close';

  @override
  String get skip => 'Skip';

  @override
  String get createRecommendedAccount => 'Create the recommended account';

  @override
  String get useCurrentAccount => 'Use my current account';

  @override
  String get exactlyToday => 'Today marks exactly';

  @override
  String get beenAWhile => 'It has been a while';

  @override
  String get toLiveNow => 'To live right now';

  @override
  String forNameNow(String nome) => 'For $nome, right now';

  @override
  String get readThePost => 'Read the post';

  @override
  String get inspirationsChangeNote =>
      'The ideas change with age. Come back soon.';

  @override
  String get savingEllipsis => 'Saving...';

  @override
  String get viewFolder => 'View the folder';

  @override
  String get viewDrawing => 'View the drawing';

  @override
  String get documentName => 'Document name';

  @override
  String documentNameOf(int atual, int total) =>
      'Document name $atual of $total';

  @override
  String get keep => 'Keep';

  @override
  String get keepForFuture => 'Keep for the future';

  @override
  String get savedForFuture => 'Kept for the future';

  @override
  String get opensToday => 'Opens today';

  @override
  String opensOn(String data) => 'Opens on $data';

  @override
  String sealedUntilNotice(String data) => 'Kept to be opened on $data.';

  @override
  String whenTurns(int anos) => 'When they turn $anos';

  @override
  String opensInYearsAtAge(int anos, int idade) =>
      'In ${contarAnos(anos)}, at age $idade';

  @override
  String get writeSomethingFirst => 'Write something before saving.';

  @override
  String get noAppForFile => 'No app on this device can open this file.';

  @override
  String get drawingsEmptyBody =>
      'Photograph a drawing and it is kept for good.';

  @override
  String birthdayAgeOf(int anos, String deQuem) =>
      '$deQuem ${contarAnos(anos)}';

  @override
  String get atBirth => 'At birth';

  @override
  String get conjuncaoE => 'and';

  @override
  String savedInFolder(String pasta, String conta) =>
      'It is saved in $pasta, $conta.';

  @override
  String willBeSavedInFolder(String pasta) => 'It will be saved in $pasta.';

  @override
  String get renameDocument => 'Rename document';

  @override
  String get rename => 'Rename';

  @override
  String get addedOn => 'Added on';

  @override
  String get sizeLabel => 'Size';

  @override
  String get fewRecords => 'Not enough records';

  @override
  String get recentPhotos => 'Recent photos';

  @override
  String get seeAll => 'See all';

  @override
  String get record => 'Record it';

  @override
  String get searchPosts => 'Search the posts';

  @override
  String get searchPostsHint => 'Search the posts...';

  @override
  String get clearLabel => 'Clear';

  @override
  String get tryAgainShortly => 'Try opening it again in a moment.';

  @override
  String get write => 'Write';

  @override
  String get importantMoments => 'Important moments';

  @override
  String get hospital => 'Hospital';

  @override
  String get girl => 'Girl';

  @override
  String get boy => 'Boy';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get changeProfilePhoto => 'Change the profile photo';

  @override
  String get receiveReminders => 'Receive reminders';

  @override
  String get atWhatTime => 'At what time';

  @override
  String get chooseAnotherDate => 'Choose another date';

  @override
  String get removeSeal => 'Remove the seal';

  @override
  String get checkTheDate => 'Is the date right?';

  @override
  String get savingDrawing => 'Saving the drawing...';

  @override
  String get convertingAndSending => 'Converting to 540p and sending...';

  @override
  String get viewDocument => 'View the document';

  @override
  String get viewDocuments => 'View the documents';

  @override
  String get groupBy => 'Group by';

  @override
  String umDoTipo(String tipo) => 'A $tipo';
  @override
  String get titleHintExample => 'First smile';
}
