import 'textos.dart';

/// L'application en français.
///
/// Écrit comme du français, et non comme du portugais traduit mot à mot.
/// Là où la phrase portugaise reposait sur un accord de genre, la phrase a
/// été réécrite pour dire la même chose comme on le dit ici. Le
/// vouvoiement est utilisé partout, comme c'est l'usage dans la plupart
/// des applications françaises.
///
/// **Le nom du dossier Google Drive n'est pas ici, et ne doit pas y être.**
/// C'est une constante de `DriveService`, en portugais, et cela reste ainsi
/// pour tout le monde : le traduire ferait que l'application chercherait un
/// dossier avec un autre nom et laisserait derrière elle tout ce que la
/// famille a déjà conservé.
class TextosFr implements Textos {
  const TextosFr();

  @override
  String get codigo => 'fr';

  @override
  String get appName => 'Mon Bébé';

  @override
  String get appFullName => 'Mon Bébé : Capsule Temporelle';

  @override
  String get appSubtitle => 'Capsule Temporelle';

  @override
  String get appTagline => 'Chaque instant, un souvenir pour la vie.';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signInNote =>
      'Tous les souvenirs seront enregistrés sur le compte Google Drive '
      'de votre enfant.';

  @override
  String get signInError =>
      'Impossible de se connecter. Vérifiez la connexion et réessayez.';

  @override
  String get onboardingGreeting => 'Bonjour !';

  @override
  String get fullName => 'Nom complet';

  @override
  String get gender => 'Un garçon ou une fille ?';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get birthTime => 'Heure de naissance';

  @override
  String get birthWeight => 'Poids à la naissance';

  @override
  String get birthHeight => 'Taille à la naissance';

  @override
  String get birthTimeOptional => 'Heure de naissance (facultatif)';

  @override
  String get birthWeightOptional => 'Poids à la naissance (facultatif)';

  @override
  String get birthHeightOptional => 'Taille à la naissance (facultatif)';

  @override
  String get hospitalOptional => 'Hôpital (facultatif)';

  @override
  String get birthPhoto => 'Photo de la naissance';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get preparingDrive => 'Préparation des dossiers sur Google Drive...';

  @override
  String get home => 'Accueil';

  @override
  String get timeline => 'Chronologie';

  @override
  String get search => 'Recherche';

  @override
  String get accountsLabel => 'COMPTES';

  @override
  String get switchAccount => 'Changer de compte';

  @override
  String get profile => 'Profil';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Vidéos';

  @override
  String get letters => 'Lettres';

  @override
  String get drawings => 'Dessins';

  @override
  String get documents => 'Documents';

  @override
  String get growth => 'Croissance';

  @override
  String get stats => 'Statistiques';

  @override
  String get trash => 'Corbeille';

  @override
  String get settings => 'Paramètres';

  @override
  String get about => 'À propos de l\'application';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get storedWithLove => 'Conservé avec amour dans le Drive de';

  @override
  String get addQuestion => 'Que voulez-vous ajouter ?';

  @override
  String get addPhoto => 'Photo';

  @override
  String get addVideo => 'Vidéo';

  @override
  String get addLetter => 'Lettre';

  @override
  String get addDrawing => 'Dessin';

  @override
  String get addDrawingHint => 'Ajouter un dessin';

  @override
  String get addDocument => 'Document';

  @override
  String get addDocumentHint => 'Ajouter des documents importants';

  @override
  String get addGrowth => 'Croissance';

  @override
  String get addGrowthHint => 'Enregistrer le poids et la taille';

  @override
  String get timelineEmptyTitle => 'L\'histoire commence ici';

  @override
  String get birth => 'Naissance';

  @override
  String get photosAdded => 'Photos ajoutées';

  @override
  String get photoAdded => 'Photo ajoutée';

  @override
  String get videoAdded => 'Vidéo ajoutée';

  @override
  String get drawingAdded => 'Dessin ajouté';

  @override
  String get documentAdded => 'Document ajouté';

  @override
  String get growthRecord => 'Mesure de croissance';

  @override
  String get letterPrefix => 'Lettre :';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterTitle => 'Filtrer par type';

  @override
  List<String> get milestoneSuggestions => <String>[
    'Première photo',
    'Premier bain',
    'Première sortie',
    'Premier voyage',
    'Premier sourire',
    'Première dent',
    'Premiers pas',
    'Premier mot',
    'Premier anniversaire',
  ];

  @override
  String get letterStartersTitle => 'Vous ne savez pas comment commencer ?';

  @override
  List<String> get letterStarters => <String>[
    'Aujourd\'hui, je veux te parler de ',
    'Quand tu liras ceci, ',
    'Tu ne le sais pas encore, mais ',
    'Une chose que je ne veux jamais oublier : ',
    'Si je ne pouvais te dire qu\'une seule chose, ce serait ',
    'Le jour où tu ',
    'Dans ce que tu es aujourd\'hui, ce que j\'aime le plus, c\'est ',
  ];

  @override
  String get titleField => 'Titre';

  @override
  String get messageField => 'Message';

  @override
  String get descriptionOptional => 'Description (facultatif)';

  @override
  String get milestoneOptional => 'Étape (facultatif)';

  @override
  String get weightField => 'Poids';

  @override
  String get heightField => 'Taille';

  @override
  String get photoOptional => 'Photo (facultatif)';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get edit => 'Modifier';

  @override
  String get share => 'Partager';

  @override
  String get delete => 'Supprimer';

  @override
  String get restore => 'Restaurer';

  @override
  String get view => 'Afficher';

  @override
  String get download => 'Télécharger';

  @override
  String get retry => 'Réessayer';

  @override
  String get weeks => 'Semaines';

  @override
  String get months => 'Mois';

  @override
  String get years => 'Années';

  @override
  String get photosOptimizedNote =>
      'Les photos sont compressées automatiquement pour optimiser '
      'l\'espace.';

  @override
  String get videoOptimizedNote =>
      'Cette vidéo a été enregistrée en 540p pour optimiser l\'espace.';

  @override
  String get allFilesOptimizedNote =>
      'Tous les fichiers sont optimisés pour économiser de l\'espace.';

  @override
  String get uploadPending => 'En attente d\'envoi';

  @override
  String get uploadOptimizing => 'Optimisation...';

  @override
  String get uploadSending => 'Envoi en cours...';

  @override
  String get uploadFailed => 'Échec de l\'envoi';

  @override
  String get uploadingCount => 'Envoi en cours';

  @override
  String get searchHint => 'Rechercher des souvenirs...';

  @override
  String get searchByCategory => 'Rechercher par catégorie';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String get searchEmpty => 'Rien trouvé ici.';

  @override
  String get clearHistory => 'Effacer l\'historique';

  @override
  String get storageUsed => 'Stockage utilisé';

  @override
  String get storageOf => 'sur';

  @override
  String get capsuleStorage => 'Capsule Temporelle';

  @override
  String get driveStorage => 'Votre Google Drive';

  @override
  String get driveStorageNote =>
      'Le total ci-dessus concerne tout votre compte Google. '
      'L\'application ne voit que les fichiers qu\'elle a elle-même créés, '
      'tous dans le dossier de la capsule. Elle n\'a pas accès au reste de '
      'votre Drive.';

  @override
  String get lockSection => 'Confidentialité';

  @override
  String get lockTitle => 'Verrouillage de l\'application';

  @override
  String get lockBody =>
      'Demande votre empreinte, votre visage ou le code PIN de l\'appareil '
      'pour ouvrir l\'application. Désactivé par défaut.';

  @override
  String get lockUnavailable =>
      'Cet appareil n\'a ni empreinte, ni visage, ni code PIN configuré. '
      'Configurez un verrouillage dans les paramètres Android pour '
      'pouvoir utiliser cette option.';

  @override
  String get lockNote =>
      'Le verrouillage protège contre quelqu\'un qui prendrait votre '
      'téléphone déjà déverrouillé. Il ne chiffre rien : c\'est une porte '
      'de plus, pas un coffre-fort.';

  @override
  String get lockFailed =>
      'Impossible de confirmer. Le verrouillage reste désactivé.';

  @override
  String get lockReason =>
      'Confirmez que c\'est bien vous pour ouvrir les souvenirs.';

  @override
  String get lockedTitle => 'Application verrouillée';

  @override
  String get lockedBody => 'Confirmez votre identité pour voir les souvenirs.';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get viewChart => 'Voir le graphique';

  @override
  String get growthChart => 'Graphique de croissance';

  @override
  String get growthEmptyTitle => 'Aucune mesure pour l\'instant';

  @override
  String get growthEmptyBody =>
      'Enregistrez le poids et la taille pour suivre la croissance.';

  @override
  String get trashEmptyTitle => 'La corbeille est vide';

  @override
  String get trashEmptyBody =>
      'Les éléments supprimés restent ici jusqu\'à ce que vous les '
      'supprimiez définitivement.';

  @override
  String get trashNote =>
      'Les fichiers vont aussi dans la corbeille de Google Drive.';

  @override
  String get deleteForever => 'Supprimer définitivement';

  @override
  String get deleteConfirmTitle => 'Supprimer cet élément ?';

  @override
  String get deleteConfirmBody =>
      'Il ira dans la corbeille et pourra être restauré plus tard.';

  @override
  String get deleteForeverConfirmBody => 'Cette action est irréversible.';

  @override
  String get currentAge => 'Âge actuel';

  @override
  String get birthDateShort => 'Naissance';

  @override
  String get signOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get signOutConfirmBody =>
      'Vos souvenirs restent conservés sur votre Google Drive. Les '
      'miniatures et les fichiers téléchargés sont effacés de cet '
      'appareil.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get accountDeletionTitle => 'Suppression du compte et des données';

  @override
  String get accountDeletionShort => 'Supprimer le compte';

  @override
  String get goToDeleteAccount => 'Aller à la suppression du compte';

  @override
  String get deleteAccount => 'Supprimer mon compte et mes données';

  @override
  String get deleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountBody =>
      'Nous supprimons de notre serveur tout ce que nous conservons à '
      'votre sujet : le profil, la chronologie, les mesures de croissance '
      'et le texte des lettres. Nous renonçons aussi à notre autorisation '
      'd\'accès à votre Google Drive.\n\n'
      'Cette action est irréversible.';

  @override
  String get deleteAccountDriveQuestion =>
      'Et le dossier « Meu Bebê - Cápsula do Tempo » sur votre Drive ?';

  @override
  String get deleteAccountKeepDrive => 'Garder les fichiers';

  @override
  String get deleteAccountKeepDriveHint =>
      'Les photos, vidéos et documents restent sur votre Drive, organisés '
      'par âge. Recommandé.';

  @override
  String get deleteAccountTrashDrive => 'Envoyer à la corbeille';

  @override
  String get deleteAccountTrashDriveHint =>
      'Le dossier va dans la corbeille de Google Drive et peut être '
      'récupéré pendant 30 jours.';

  @override
  String get deleteAccountWorking => 'Suppression en cours...';

  @override
  String get deleteAccountDone => 'Compte supprimé.';

  @override
  String get genericError => 'Un problème est survenu. Réessayez.';

  @override
  String get noItemsYet => 'Rien ici pour l\'instant.';

  @override
  String get requiredField => 'Remplissez ce champ';

  @override
  String get invalidNumber => 'Indiquez un nombre valide';

  @override
  String get codigoIntl => 'fr';

  @override
  String get padraoData => 'dd/MM/yyyy';

  @override
  String get padraoDiaMes => 'dd/MM';

  @override
  String get padraoDataLonga => "d MMMM yyyy";

  @override
  String get padraoMesAno => "MMMM yyyy";

  @override
  String get padraoHora => 'HH:mm';

  @override
  String get entreDatas => 'au';

  @override
  String get hoje => 'Aujourd\'hui';

  @override
  String get ontem => 'Hier';

  @override
  String saudacao(int hora) {
    if (hora < 12) return 'Bonjour';
    if (hora < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  String haTempo(int dias) {
    if (dias <= 0) return 'aujourd\'hui';
    if (dias == 1) return 'hier';
    if (dias < 14) return 'il y a $dias jours';
    if (dias < 60) {
      final int semanas = dias ~/ 7;
      return semanas == 1 ? 'il y a 1 semaine' : 'il y a $semanas semaines';
    }
    if (dias < 365) {
      final int meses = dias ~/ 30;
      return meses == 1 ? 'il y a 1 mois' : 'il y a $meses mois';
    }
    final int anos = dias ~/ 365;
    return anos == 1 ? 'il y a 1 an' : 'il y a $anos ans';
  }

  @override
  String ordinal(int n) => switch (n) {
    1 => 'premier',
    2 => 'deuxième',
    3 => 'troisième',
    4 => 'quatrième',
    5 => 'cinquième',
    6 => 'sixième',
    7 => 'septième',
    8 => 'huitième',
    9 => 'neuvième',
    10 => 'dixième',
    _ => '${n}e',
  };

  @override
  String contarDias(int n) => n == 1 ? '1 jour' : '$n jours';

  @override
  String contarMeses(int n) => n == 1 ? '1 mois' : '$n mois';

  @override
  String contarAnos(int n) => n == 1 ? '1 an' : '$n ans';

  @override
  String contarItens(int n) => n == 1 ? '1 élément' : '$n éléments';

  @override
  String contarFotos(int n) => n == 1 ? '1 photo' : '$n photos';

  @override
  String contarVideos(int n) => n == 1 ? '1 vidéo' : '$n vidéos';

  @override
  String get lastBirth => 'Dernière naissance';

  @override
  String get lastPhoto => 'Dernière photo';

  @override
  String get lastVideo => 'Dernière vidéo';

  @override
  String get lastLetter => 'Dernière lettre';

  @override
  String get lastDrawing => 'Dernier dessin';

  @override
  String get lastDocument => 'Dernier document';

  @override
  String get lastGrowth => 'Dernière mesure';

  @override
  String get oneVideo => 'vidéo';

  @override
  String get oneGrowth => 'mesure';

  @override
  String get imageOpenFailed => 'Impossible d\'ouvrir cette image.';

  @override
  String get videoOpenFailed => 'Impossible d\'ouvrir cette vidéo.';

  @override
  String get documentNotFound => 'Document introuvable';

  @override
  String get letterNotFound => 'Lettre introuvable';

  @override
  String get entryNotFound => 'Souvenir introuvable';

  @override
  String get driveSpaceFailed =>
      'Impossible de lire l\'espace disponible sur Google Drive.';

  @override
  String get firstVideoHint => 'Touchez le + pour ajouter la première vidéo.';

  @override
  String get documentsEmptyBody =>
      'Acte de naissance, carnet de santé, passeport : tout au même '
      'endroit.';

  @override
  String get isToday => 'C\'est aujourd\'hui';

  @override
  String get isTodayBang => 'C\'est aujourd\'hui !';

  @override
  String get tomorrow => 'Demain';

  @override
  String get nextMilestone => 'Prochaine étape';

  @override
  String faltamDias(int dias) => 'Dans ${contarDias(dias)}';

  @override
  String get seeInspiration => 'Voir des idées';

  @override
  String get forYou => 'Pour vous';

  @override
  String get notYet => 'pas encore';

  @override
  String get inspirations => 'Idées';

  @override
  String get inspirationsLoadFailed => 'Impossible de charger les idées';

  @override
  String get inspirationSearchHint => 'Que voulez-vous savoir ?';

  @override
  String get suggestionsByAge =>
      'Les suggestions apparaissent selon l\'âge et le calendrier.';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get savedTitle => 'C\'est enregistré';

  @override
  String get willBeSaved => 'Ce sera enregistré';

  @override
  String get sendMemoryError => 'Envoyer le souvenir';

  @override
  String get dateFromFile =>
      'Date lue depuis le fichier lui-même. Touchez pour la changer.';

  @override
  String get deletedOn => 'Supprimé le ';

  @override
  String get itemDeleted => 'Élément supprimé.';

  @override
  String get documentNameSuggestion => 'Acte de naissance';

  @override
  String get saveInfo => 'Enregistrer les informations';

  @override
  String get editInfo => 'Modifier les informations';

  @override
  String get notProvided => 'Non renseignée';

  @override
  String get automatic => 'Automatique';

  @override
  String get reviewIntro => 'Revoir la présentation';

  @override
  String get lastUpdatedLabel => 'Dernière mise à jour';

  @override
  String get optimization => 'Optimisation';

  @override
  String get photoMaxSide => 'Jusqu\'à 960 px sur le plus grand côté';

  @override
  String get optimizationNote =>
      'L\'optimisation est automatique et ne peut pas être désactivée : '
      'c\'est ce qui garde l\'ensemble léger pendant de longues années.';

  @override
  String get languageSection => 'Langue';

  @override
  String get clearCacheBody =>
      'Efface les miniatures, les fichiers temporaires et les documents '
      'déjà téléchargés. Rien n\'est perdu : tout reste sur Google Drive.';

  @override
  String get cacheCleared => 'Cache effacé.';

  @override
  String get clearCache => 'Effacer le cache';

  @override
  String get storageOnDevice => 'Stockage sur l\'appareil';

  @override
  String get remindersSection => 'Rappels';

  @override
  String get remindersOff => 'Désactivés';

  @override
  String get startupFailedTitle => 'L\'application n\'a pas pu démarrer';

  @override
  String get technicalDetail => 'Détail technique';

  @override
  String get premiumInviteAction => 'Compris';

  @override
  String get introTitle1 => 'L\'enfance passe vite.';

  @override
  String get introTitle2 => 'Chaque souvenir a sa place.';

  @override
  String get introBody2 =>
      'Photos, vidéos, lettres, dessins, documents et mesures de '
      'croissance. Tout réuni au même endroit.';

  @override
  String get introTitle3 => 'Chaque souvenir en son temps.';

  @override
  String get introTitle4 => 'On crée cette capsule ?';

  @override
  String get sealBody =>
      'Ceci reste fermé jusqu\'à la date que vous choisirez. Le contenu '
      'reste sur votre Drive, et vous pouvez l\'ouvrir avant si vous le '
      'souhaitez : c\'est un cachet, comme celui d\'une capsule enterrée '
      'dans le jardin, pas un coffre-fort.';

  @override
  String get aboutPhotos =>
      'Aucune photo ne passe par un serveur qui nous appartient : elles '
      'vont directement du téléphone à Google Drive.';

  @override
  String get aboutScope =>
      'L\'application ne voit pas le reste de votre Drive. '
      'L\'autorisation que vous accordez ne donne accès qu\'aux fichiers '
      'qu\'elle crée elle-même, tous dans le dossier « Meu Bebê - Cápsula '
      'do Tempo ». Vos autres dossiers lui sont invisibles.';

  @override
  String get aboutIndex =>
      'Ce qui reste sur notre serveur, c\'est l\'index : le nom, la date '
      'de naissance, le poids, la taille, les dates et le texte des '
      'lettres. C\'est ce qui fait fonctionner la chronologie et la '
      'recherche. Vous pouvez tout effacer à tout moment, dans votre '
      'profil.';

  @override
  String get aboutLastingTitle => 'Pour que la capsule dure';

  @override
  String get deleteDriveNote =>
      'Même envoyés à la corbeille, les fichiers vous appartiennent et '
      'restent sur votre Drive : l\'application n\'en a jamais eu de '
      'copie.';

  @override
  String get profilePhotoNote =>
      'La photo de profil provient des souvenirs déjà enregistrés. '
      'Ajoutez une photo pour pouvoir en choisir une.';

  @override
  String get remindersHowTitle => 'À quel sujet';

  @override
  String get remindersMarkedTitle => 'Ce qui est coché';

  @override
  String get remindersFrequency =>
      'Au maximum deux par semaine, jamais deux le même jour.';

  @override
  String get remindersOffNote =>
      'Désactivé. Rien n\'est envoyé. Si le téléphone a refusé les '
      'notifications, autorisez-les dans Paramètres, Applications, '
      'Meu Bebê.';

  @override
  String get remindersNothingSoon =>
      'Rien dans les prochaines semaines. C\'est normal : les rappels '
      'apparaissent seulement quand une date approche vraiment.';

  @override
  String get remindersPrivacy =>
      'Les rappels sont calculés sur votre téléphone, à partir de ce qui '
      's\'y trouve déjà. Rien n\'est envoyé à aucun serveur pour cela, et '
      'aucune notification ne cite ce que vous avez enregistré.';

  @override
  String get remindersDenied =>
      'Android n\'a pas autorisé les notifications. Vous pouvez les '
      'autoriser dans les paramètres du téléphone, dans Applications, '
      'Meu Bebê.';

  @override
  String get sealedEmptyBody =>
      'En enregistrant une lettre ou une vidéo, vous pouvez choisir une '
      'date à laquelle elle s\'ouvrira : un anniversaire, la majorité, ou '
      'toute autre date. Elle attend ici jusque-là.';

  @override
  String get growthChartHint =>
      'À partir de deux mesures, le graphique commence à raconter '
      'l\'histoire.';

  @override
  String get introBody1 =>
      'Gardez les petits moments avant qu\'ils ne deviennent que des '
      'souvenirs.';

  @override
  String get introTitle4b => 'Un cadeau pour l\'avenir.';

  @override
  String get introBody3 =>
      'Nous organisons tout selon l\'âge auquel c\'est arrivé, formant '
      'une véritable chronologie de l\'enfance.';

  @override
  String get introBody4 =>
      'Un jour, cette capsule pourra être ouverte par la personne qui '
      'compte le plus : votre enfant.';

  @override
  String get introBody5 =>
      'Nous recommandons d\'utiliser un compte Google réservé à la '
      'conservation de tous ces souvenirs pendant de longues années.';

  @override
  String get premiumInviteLetters => 'Les lettres font partie du plan Premium';

  @override
  String get premiumInviteDrawings => 'Les dessins font partie du plan Premium';

  @override
  String get premiumInviteDocuments =>
      'Les documents font partie du plan Premium';

  @override
  String get premiumInviteGrowth => 'La croissance fait partie du plan Premium';

  @override
  String get premiumInviteGeneric => 'Ceci fait partie du plan Premium';

  @override
  String get premiumInvitePrice =>
      'C\'est un abonnement annuel, facturé et géré par Google Play, qui '
      'affiche le prix dans la devise de votre pays.';

  @override
  String get premiumInviteKeeps =>
      'Sans lui, rien ne disparaît : les photos et les vidéos restent '
      'libres, et tout ce qui est déjà enregistré reste accessible pour '
      'toujours.';

  @override
  String get documentNameQuestion => 'Comment voulez-vous appeler';

  @override
  String get videosLabel => 'Vidéos';

  @override
  String get sendMemory => 'Envoyer le souvenir';

  @override
  String get languageNote =>
      'Le choix est déjà enregistré, mais la traduction est encore en '
      'cours : pour l\'instant, l\'application reste en portugais.';

  @override
  String get videoOptimizedShort => '540p avec débit optimisé';

  @override
  String get originalFiles => 'Fichiers originaux';

  @override
  String get originalFilesNote => 'Restent sur le téléphone, intacts';

  @override
  String get loginCapsuleHint =>
      'Pour créer le compte de la capsule : touchez ci-dessous, et sur '
      'l\'écran Google, choisissez Ajouter un autre compte.';

  @override
  String get startupFirebaseHint =>
      'C\'est presque toujours une configuration Firebase : le fichier '
      'google-services.json et le fichier firebase_options.dart doivent '
      'provenir du même projet, et Firestore ainsi que la connexion '
      'Google doivent être activés dans la console.';

  @override
  String get sentToDrive => 'C\'est enregistré';

  @override
  String get dateNotFoundMedia =>
      'Nous n\'avons pas trouvé de date dans le fichier multimédia, donc '
      'celle d\'aujourd\'hui est utilisée. Touchez pour la changer.';

  @override
  String get dateNotFoundFile =>
      'Nous n\'avons pas trouvé de date dans le fichier, donc celle '
      'd\'aujourd\'hui est utilisée. Touchez pour la changer.';

  @override
  String inspirationsSubtitle(String nome) =>
      'Des idées pour l\'étape que $nome vit en ce moment.';

  @override
  String suggestionsGrowNote(String nome) =>
      'Les suggestions reviennent à mesure que $nome grandit et que les '
      'dates approchent.';

  @override
  String remindersIntroNamed(String nome) =>
      'Les rappels sont activés par défaut, car une capsule temporelle ne '
      'tient sa promesse que si quelqu\'un y revient. Ils sont peu '
      'nombreux, et existent pour que vous ne manquiez pas le jour où '
      '$nome fête un mois de plus.';

  @override
  String remindersHourNote(int hora) =>
      'Toujours entre 8h et ${hora}h. L\'application ne réveille personne '
      'en pleine nuit.';

  @override
  String remindersSummary(int marcados, int total, int hora) =>
      '$marcados sur $total types, à ${hora}h';

  @override
  String birthdayOrdinal(int anos) => 'Pour le ${ordinal(anos)} anniversaire';

  @override
  String todayWithDate(String data) => 'C\'est aujourd\'hui, $data';

  @override
  String tomorrowWithDate(String data) => 'Demain, $data';

  @override
  String searchNoResults(String termo) =>
      'Nous n\'avons trouvé aucun article avec « $termo ».';

  @override
  String growthFromBirth(String data) => 'De la naissance jusqu\'au $data';

  @override
  String savedInDrive(String dono) => 'C\'est enregistré $dono.';

  @override
  String lastUpdated(String data) => 'Dernière mise à jour : $data';

  @override
  String batchManyDays(int dias) =>
      'Attention : ce que vous avez choisi provient de $dias jours '
      'différents, et tout sera enregistré avec cette date. Pour '
      'séparer, envoyez un jour à la fois.';

  @override
  String get inspirationsSubtitleGeneric => 'Des idées pour cette étape.';

  @override
  String willBeSavedIn(String dono) => 'Ce sera enregistré $dono.';

  @override
  String get remindersIntroGeneric =>
      'Les rappels sont activés par défaut, car une capsule temporelle ne '
      'tient sa promesse que si quelqu\'un y revient. Ils sont peu '
      'nombreux, et existent pour les dates qui passent sans que '
      'personne ne s\'en aperçoive.';

  @override
  String get sealedEmptyIntro =>
      'En enregistrant une lettre ou une vidéo, vous pouvez choisir une '
      'date d\'ouverture : les 15 ans, les 18 ans, ou toute autre date. '
      'Elle attend ici jusque-là.';

  @override
  String get aboutPhotosNote =>
      'Aucune photo ne passe par un serveur qui nous appartient : elles '
      'vont directement de votre appareil au Google Drive de votre '
      'compte.';

  @override
  String get profilePhotoEmpty =>
      'La photo de profil provient des souvenirs déjà enregistrés. '
      'Ajoutez une photo pour pouvoir en choisir une.';

  @override
  String remindersHourRange(int inicio, int fim) =>
      'Entre ${inicio}h et ${fim}h. L\'application ne réveille personne '
      'en pleine nuit.';

  @override
  String get typeOneBirth => 'naissance';

  @override
  String get typeOnePhoto => 'photo';

  @override
  String get typeOneLetter => 'lettre';

  @override
  String get typeOneDrawing => 'dessin';

  @override
  String get typeOneDocument => 'document';

  @override
  String get typeManyBirths => 'naissances';

  @override
  String get typeManyPhotos => 'photos';

  @override
  String get typeManyVideos => 'vidéos';

  @override
  String get typeManyLetters => 'lettres';

  @override
  String get typeManyDrawings => 'dessins';

  @override
  String get typeManyDocuments => 'documents';

  @override
  String get typeManyGrowth => 'mesures';

  @override
  String get theGrowth => 'la croissance';

  @override
  String get documentNameQuestionFull => 'Comment voulez-vous appeler';

  @override
  String get loginCreateAccountHint =>
      'Pour créer le compte de la capsule : touchez ci-dessous, et dans '
      'la fenêtre Google, choisissez « Ajouter un autre compte » puis '
      '« Créer un compte ».';

  @override
  String get aboutInactivity =>
      'Google supprime les comptes inutilisés depuis deux ans, et avec '
      'eux, tout ce qui se trouve sur leur Drive. Cela concerne surtout '
      'les personnes ayant créé un compte uniquement pour la capsule.'
      '\n\nOuvrir cette application de temps en temps compte déjà comme '
      'une utilisation, donc rien de plus n\'est nécessaire. Malgré '
      'cela, si vous restez presque un an sans vous connecter, '
      'l\'application vous avertit une fois, et cet avertissement peut '
      'être désactivé dans Paramètres.';

  @override
  String get profilePhotoFromMemories =>
      'La photo de profil provient des souvenirs déjà enregistrés. '
      'Ajoutez une photo et elle apparaîtra ici.';

  @override
  String premiumInviteWhat(String tipos, String deQuem, String outros) =>
      'Enregistrer $tipos dans la capsule$deQuem fait partie du Premium, '
      'avec $outros.';

  @override
  String profilePhotoEmptyOf(String deQuem) =>
      'La photo de profil provient des souvenirs déjà enregistrés. '
      'Ajoutez une photo $deQuem et elle apparaîtra ici.';

  @override
  String comArtigo(String plural) => 'les $plural';

  @override
  String get errNoConnection => 'Pas de connexion internet. Réessayez.';

  @override
  String get errFileRead => 'Impossible de lire le fichier sur l\'appareil.';

  @override
  String get errPermissionDenied =>
      'Le serveur a refusé l\'enregistrement. Déconnectez-vous et '
      'reconnectez-vous ; si cela persiste, c\'est une configuration de '
      'l\'application, pas la vôtre.';

  @override
  String get errSessionExpired =>
      'Votre session a expiré. Reconnectez-vous pour continuer.';

  @override
  String get errMissingIndex =>
      'Vos souvenirs sont enregistrés, mais le serveur ne parvient pas '
      'encore à les organiser pour les afficher ici. C\'est une '
      'configuration de l\'application, pas la vôtre.';

  @override
  String get errServerQuiet =>
      'Le serveur n\'a pas répondu. Réessayez dans un instant.';

  @override
  String get errRecentLogin =>
      'Pour des raisons de sécurité, reconnectez-vous avant de '
      'continuer.';

  @override
  String get errGeneric => 'Impossible de terminer. Réessayez.';

  @override
  String get errDriveExpired =>
      'L\'accès à Google Drive a expiré. Déconnectez-vous et '
      'reconnectez-vous pour renouveler l\'autorisation.';

  @override
  String get errDriveNotEnabled =>
      'Google Drive n\'est pas encore activé pour cette application. '
      'C\'est une configuration de notre côté, pas du vôtre : rien de ce '
      'que vous avez saisi n\'est perdu.';

  @override
  String get errDriveFull =>
      'Votre Google Drive n\'a plus d\'espace. Libérez de l\'espace sur '
      'le compte et réessayez.';

  @override
  String get errDriveRateLimit =>
      'Google Drive a demandé d\'attendre un peu. Réessayez dans un '
      'instant.';

  @override
  String get errDriveForbidden =>
      'Google Drive a refusé l\'accès. Déconnectez-vous et '
      'reconnectez-vous pour autoriser le dossier de la capsule.';

  @override
  String get errDriveFolderMissing =>
      'Le dossier de la capsule est introuvable sur votre Google Drive.';

  @override
  String get errDriveQuiet =>
      'Google Drive n\'a pas répondu. Réessayez dans un instant ; rien de '
      'ce que vous avez saisi n\'est perdu.';

  @override
  String get errDriveGeneric =>
      'Impossible de contacter Google Drive. Réessayez.';

  @override
  String get authSlow =>
      'La connexion avec Google met du temps à répondre. Vérifiez la '
      'connexion et réessayez.';

  @override
  String get authUnsupported =>
      'Cet appareil ne propose pas la connexion avec Google.';

  @override
  String get authNoIdentifier =>
      'Nous n\'avons pas reçu l\'identifiant du compte. Vérifiez la '
      'configuration de la connexion Google et réessayez.';

  @override
  String get authOtherAccount =>
      'L\'autorisation enregistrée provient d\'un autre compte Google. '
      'Reconnectez-vous pour continuer à enregistrer dans cette capsule.';

  @override
  String get authRenewDrive =>
      'Nous devons renouveler l\'autorisation de Google Drive.';

  @override
  String get authSignInToContinue =>
      'Connectez-vous avec le compte Google pour continuer.';

  @override
  String get authDriveRefused =>
      'Vous n\'avez pas autorisé l\'accès à Google Drive. C\'est là que '
      'les souvenirs sont conservés, sur votre propre compte.';

  @override
  String get authReloginToDelete =>
      'Pour supprimer le compte, reconnectez-vous et recommencez '
      'l\'opération.';

  @override
  String get authScreenFailed =>
      'Impossible d\'ouvrir l\'écran Google. Réessayez.';

  @override
  String get authConfigIncomplete =>
      'La configuration de la connexion Google est incomplète.';

  @override
  String get authServicesUnavailable =>
      'Services Google indisponibles sur cet appareil.';

  @override
  String get authWrongAccount =>
      'Le compte choisi est différent du compte utilisé.';

  @override
  String get emptyDocuments => 'Aucun document pour l\'instant';

  @override
  String get emptyDrawings => 'Aucun dessin pour l\'instant';

  @override
  String get emptyLetters => 'Aucune lettre pour l\'instant';

  @override
  String get emptyPhotos => 'Aucune photo pour l\'instant';

  @override
  String get emptySealed => 'Rien de scellé pour l\'instant';

  @override
  String get emptyMoments => 'Rien en attente ici';

  @override
  String get emptyInspirations => 'Rien ici pour le moment';

  @override
  String get emptySearchTopic => 'Rien sur ce sujet pour l\'instant';

  @override
  String get firstPhotosHint =>
      'Touchez le + pour ajouter les premières photos.';

  @override
  String daysLeft(int dias) =>
      dias == 1 ? 'Il reste 1 jour' : 'Il reste $dias jours';

  @override
  String daysLeftWithDate(int dias, String data) =>
      'Il reste $dias jours, $data';

  @override
  String remindersSummaryFull(int marcados, int total, int hora) =>
      '$marcados sur $total types, à ${hora}h';

  @override
  String contarSemanas(int n) => n == 1 ? '1 semaine' : '$n semaines';

  @override
  String semanaNumero(int n) => 'Semaine $n';

  @override
  String mesNumero(int n) => 'Mois $n';

  @override
  String uploadWithDate(String oQue, String data) =>
      '$oQue avec la date du $data.';

  @override
  String uploadBornThatDay(String nome) => 'C\'est le jour où $nome est né.';

  @override
  String uploadBornThatDayGeneric() => 'C\'était le jour de la naissance.';

  @override
  String uploadAgeThen(String nome, String idade) =>
      'À cette date, $nome avait $idade.';

  @override
  String uploadAgeThenGeneric(String idade) => 'Âge à cette date : $idade.';

  @override
  String uploadWhereInDrive(String caminho) =>
      'Sur le Drive, cela ira dans $caminho.';

  @override
  String get holidayNewYear => 'Nouvel An';

  @override
  String get holidayCarnival => 'Carnaval';

  @override
  String get holidayEaster => 'Pâques';

  @override
  String get holidayMothers => 'Fête des Mères';

  @override
  String get holidayFathers => 'Fête des Pères';

  @override
  String get holidayChristmas => 'Noël';

  @override
  String get kindLetter => 'Idée de lettre';

  @override
  String get kindReading => 'Lecture';

  @override
  String get kindPrep => 'Préparatif';

  @override
  String get kindRoutine => 'Routine et organisation';

  @override
  String get kindEveryday => 'Du quotidien';

  @override
  String get kindPlay => 'Jeu';

  @override
  String get notifChannelName => 'Rappels de la capsule';

  @override
  String get notifChannelDescription =>
      'Dates rondes, anniversaires et rappels pour enregistrer un '
      'souvenir.';

  @override
  String get errPhotoCompress => 'Impossible de compresser cette photo.';

  @override
  String get errVideoConvert => 'Impossible de convertir cette vidéo.';

  @override
  String get errOriginalsMissing =>
      'Les fichiers originaux ne sont pas sur cet appareil.';

  @override
  String get errPickPhotoAgain =>
      'Choisissez la photo à nouveau pour l\'enregistrer.';

  @override
  String get errOriginalsMissingFull =>
      'Les fichiers originaux ne sont pas sur cet appareil. Renvoyez-les '
      'depuis le téléphone où ils ont été choisis.';

  @override
  String get errFileGoneFull =>
      'Le fichier a quitté cet appareil avant la fin de l\'envoi. '
      'Choisissez la photo à nouveau pour l\'enregistrer.';

  @override
  String get kindOuting => 'Sortie et plein air';

  @override
  String get kindPhoto => 'Idée de photo';

  @override
  String get reminderRoundLabel => 'Dates rondes';

  @override
  String get reminderRoundDesc =>
      'Mensiversaires et le passage de chaque année';

  @override
  String get reminderBirthdayLabel => 'Anniversaire';

  @override
  String get reminderBirthdayDesc => 'Une semaine avant, et le jour même';

  @override
  String get reminderSpecialLabel => 'Premières fois de l\'année';

  @override
  String get reminderSpecialDesc => 'Noël, Pâques, Fête des Mères';

  @override
  String get reminderInspirationLabel => 'Des idées au bon moment';

  @override
  String get reminderInspirationDesc =>
      'Quand une idée n\'est utile que maintenant';

  @override
  String get reminderAbsenceLabel => 'Rappel bienveillant';

  @override
  String get reminderAbsenceDesc =>
      'Quand cela fait longtemps que rien n\'a été enregistré';

  @override
  String get reminderInactiveLabel => 'Le compte Google';

  @override
  String get reminderInactiveDesc =>
      'Un avis par an, pour que la capsule ne se perde pas';

  @override
  String get notifWeekLeftTitle => 'Il reste une semaine';

  @override
  String get notifBirthdayTodayGeneric =>
      'C\'est aujourd\'hui. Enregistrez quelque chose de ce jour.';

  @override
  String get notifMomentTitle => 'Un instant d\'aujourd\'hui';

  @override
  String get notifInactiveTitle =>
      'La capsule a besoin de vous pendant une minute';

  @override
  String get notifPhotoWorthIt =>
      'Une photo d\'aujourd\'hui vaudra beaucoup dans vingt ans.';

  @override
  String get notifAbsenceGeneric =>
      'Cela fait un moment depuis le dernier souvenir. Une photo '
      'quelconque, peu importe la journée, suffit déjà.';

  @override
  String get notifInactiveGeneric =>
      'Cela fait presque un an que vous ne vous êtes pas connecté. '
      'Google supprime les comptes inutilisés après deux ans, et c\'est '
      'dans l\'un d\'eux que vivent les souvenirs. Se connecter de temps '
      'en temps suffit déjà.';

  @override
  String get theChild => 'l\'enfant';

  @override
  String notifFirstBirthdaySoon(String quem) =>
      'Le premier anniversaire $quem est dans sept jours. Bon moment pour '
      'choisir les photos de la première année.';

  @override
  String notifBirthdaySoon(String quem, int anos) =>
      '$quem fête ses $anos ans dans sept jours.';

  @override
  String notifBirthdayTitle(int anos) =>
      anos == 1 ? 'Un an aujourd\'hui' : '$anos ans aujourd\'hui';

  @override
  String notifBirthdayToday(String deQuem) =>
      'C\'est aujourd\'hui le jour $deQuem. Enregistrez quelque chose de '
      'ce jour.';

  @override
  String notifMonthsTitle(int meses) =>
      meses == 1 ? '1 mois aujourd\'hui' : '$meses mois aujourd\'hui';

  @override
  String notifMonthsBody(String nome, int meses) =>
      '$nome fête ${contarMeses(meses)} aujourd\'hui. Une photo '
      'd\'aujourd\'hui vaudra beaucoup dans vingt ans.';

  @override
  String notifFirstHolidayTitle(String data) => 'Le premier $data';

  @override
  String notifFirstHolidayBody(String data, String deQuem) =>
      'Dans trois jours, c\'est le premier $data $deQuem. Une photo '
      's\'impose.';

  @override
  String notifFirstHolidayBodyGeneric(String data) =>
      'Dans trois jours, c\'est le premier $data. Une photo s\'impose.';

  @override
  String notifAbsenceBody(String deQuem) =>
      'Cela fait un moment depuis le dernier souvenir $deQuem. Une photo '
      'quelconque, peu importe la journée, suffit déjà.';

  @override
  String notifInactiveBody(String deQuem) =>
      'Cela fait presque un an que vous ne vous êtes pas connecté. '
      'Google supprime les comptes inutilisés après deux ans, et c\'est '
      'dans l\'un d\'eux que vivent les souvenirs $deQuem. Se connecter '
      'de temps en temps suffit déjà.';

  @override
  String tituloDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'Le premier Noël',
    'primeiro-ano-novo' => 'Le premier Nouvel An',
    'primeiro-carnaval' => 'Le premier Carnaval',
    'primeira-pascoa' => 'Le premier Pâques',
    'primeiro-dia-das-maes' => 'La première Fête des Mères',
    'primeiro-dia-dos-pais' => 'La première Fête des Pères',
    'primeiro-aniversario' => 'Préparer le premier anniversaire',
    'primeiro-sorriso' => 'Le premier sourire',
    'primeiro-dentinho' => 'La première petite dent',
    'primeira-palavra' => 'Le premier mot',
    'primeiros-passos' => 'Les premiers pas',
    'primeiro-corte-cabelo' => 'La première coupe de cheveux',
    'primeira-viagem' => 'Le premier voyage',
    'primeira-praia' => 'La première plage',
    'primeira-escola' => 'Le premier jour d\'école',
    'primeira-bicicleta' => 'Le premier vélo',
    _ => id,
  };

  @override
  String? notaDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'Le premier Noël {nome} approche.',
    'primeiro-ano-novo' => 'Le premier passage à l\'an neuf {nome}.',
    'primeiro-carnaval' => 'Un déguisement, une photo, et voilà.',
    'primeiro-dia-das-maes' =>
      'Et si vous écriviez une lettre que {nome} lira dans de nombreuses '
          'années ?',
    'primeiro-aniversario' => 'La première année {nome} approche.',
    'primeiro-sorriso' => 'Apparaît en général vers six semaines.',
    'primeira-palavra' =>
      'Enregistrez la voix {nome}. Dans vingt ans, cela n\'aura pas de '
          'prix.',
    'primeiros-passos' => 'Ça vaut plus en vidéo qu\'en photo.',
    'primeiro-corte-cabelo' => 'Avant et après, si possible.',
    _ => null,
  };

  @override
  List<String> checklistDoAniversario() => <String>[
    'Choisir le thème',
    'Définir les invités',
    'Choisir le gâteau',
    'Acheter les vêtements',
    'Enregistrer une vidéo',
    'Écrire une lettre pour l\'avenir',
  ];

  @override
  String get languageStepTitle => 'Dans quelle langue ?';

  @override
  String get languageStepNote =>
      'S\'applique à toute l\'application et aux noms des dossiers sur '
      'Google Drive. Les dossiers gardent la langue d\'aujourd\'hui pour '
      'toujours, même si vous changez celle de l\'application plus tard.';
}
