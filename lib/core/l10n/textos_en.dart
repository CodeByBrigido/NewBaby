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
      'No photo passes through a server of ours: they go straight from your device to the Google Drive of your account.';

  @override
  String get aboutScope =>
      'The app cannot see the rest of your Drive. The permission you grant gives access only to the files it creates itself, all inside the "Meu Bebê - Cápsula do Tempo" folder. Your other folders are invisible to it.';

  @override
  String get aboutIndex =>
      'What stays on our server is the index: name, date of birth, weight, length, dates and the text of the letters. It is what makes the timeline and the search work. You can delete all of it whenever you want.';

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
}
