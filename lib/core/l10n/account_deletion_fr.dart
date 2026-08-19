import 'privacy_policy.dart';

/// La page de suppression de compte, en français.
const String deletionPageDateFr = '18 août 2026';

const List<PrivacySection> accountDeletionPageFr = <PrivacySection>[
  PrivacySection(
    title: 'Ce qu\'est cette page',
    body: <String>[
      'Cette page explique comment demander la suppression de votre '
          'compte de l\'application Meu Bebê : Cápsula do Tempo et de '
          'toutes les données qui y sont associées.',
      'Elle est conçue pour fonctionner même si vous avez déjà '
          'désinstallé l\'application. Vous n\'avez besoin de rien '
          'installer, de rien enregistrer ni de vous connecter nulle part '
          'pour utiliser ce qui se trouve ici.',
      'Le droit à l\'effacement existe sous des noms différents selon '
          'les endroits : effacement dans le RGPD (Art. 17) et le UK GDPR, '
          'élimination dans la LGPD (Art. 18), suppression dans le CCPA '
          'californien, et des droits équivalents dans de nombreuses autres '
          'juridictions. Ici, la démarche est la même pour tout le monde, '
          'et nous ne conditionnons pas la demande à l\'indication de votre '
          'pays de résidence.',
      'Responsable du traitement : $privacyController. Contact : '
          '$privacyEmail',
    ],
  ),
  PrivacySection(
    title: 'Si vous avez encore l\'application',
    body: <String>[
      'C\'est le chemin le plus rapide, et le seul qui supprime tout '
          'instantanément, sans attendre personne :',
      '• Ouvrez l\'application et connectez-vous avec le compte à '
          'supprimer',
      '• Touchez Profil',
      '• Touchez « Suppression du compte et des données »',
      '• Lisez la page, qui est celle-ci même, et touchez « Aller à la '
          'suppression du compte », en bas de page',
      '• Choisissez ce qu\'il advient du dossier Google Drive',
      '• Touchez « Supprimer mon compte et mes données » et confirmez',
      'La lecture précède le bouton intentionnellement. La suppression '
          'est immédiate et irréversible, et personne ne devrait atteindre '
          'le bouton sans savoir ce qui reste et ce qui disparaît.',
      'Concernant le dossier Drive, deux options s\'offrent à vous : le '
          'conserver, ce qui est le choix par défaut, car les fichiers vous '
          'appartiennent et nous n\'en avons jamais eu de copie ; ou '
          'l\'envoyer à la corbeille de votre Drive.',
    ],
  ),
  PrivacySection(
    title: 'Si vous n\'avez plus l\'application',
    body: <String>[
      'Écrivez à $privacyEmail avec pour objet « Supprimer mon compte ».',
      'La demande doit provenir de l\'adresse email du compte Google que '
          'vous avez utilisé pour vous connecter à l\'application. C\'est '
          'notre seul moyen de savoir que la demande vient bien de vous : '
          'sans cette vérification, n\'importe qui pourrait supprimer la '
          'collection d\'une autre personne simplement en écrivant un '
          'email.',
      'Nous répondrons à cette même adresse pour confirmer la '
          'suppression. Si la demande provient d\'une autre adresse, nous '
          'demanderons qu\'elle soit renvoyée depuis l\'adresse du compte, '
          'et nous ne supprimerons rien avant que cela n\'arrive.',
      'La demande sera traitée sans retard indu et, lorsqu\'elle relève '
          'du RGPD, en règle générale dans un délai d\'un mois. Lorsqu\'une '
          'autre législation applicable fixe un délai différent, nous '
          'respecterons le délai légal correspondant. Vous n\'avez pas à '
          'justifier votre demande, et nous ne facturons pas cette '
          'demande.',
    ],
  ),
  PrivacySection(
    title: 'Ce qui est supprimé',
    body: <String>[
      'Tout ce qui existe de votre côté sur notre serveur, sans '
          'exception :',
      '• Le profil de l\'enfant : nom, date et heure de naissance, '
          'sexe, poids, taille et hôpital',
      '• Toute la chronologie : la date, l\'âge, le titre, la '
          'description et le type de chaque souvenir',
      '• Le texte intégral des lettres, seul contenu vous appartenant '
          'qui reste dans notre index',
      '• Les identifiants des dossiers Drive et la progression des '
          'suggestions',
      '• Votre compte d\'authentification, avec l\'email et le nom '
          'provenant de Google',
      'La suppression des données de l\'index et du compte '
          'd\'authentification débute immédiatement après confirmation et, '
          'une fois terminée, ne peut être annulée par l\'application. Nous '
          'ne conservons aucune sauvegarde opérationnelle de l\'index '
          'permettant de restaurer un compte supprimé. Les données devant '
          'être conservées pour obligation légale ou les journaux '
          'techniques maintenus par l\'infrastructure de Google pourront '
          'subsister pendant la durée applicable, sans être utilisés à des '
          'fins incompatibles.',
    ],
  ),
  PrivacySection(
    title: 'Ce qui n\'est pas supprimé, et pourquoi',
    body: <String>[
      'Vos photos, vidéos, dessins et documents **ne sont pas '
          'supprimés**, car ils ne nous ont jamais appartenu.',
      'Ils se trouvent dans un dossier nommé « Meu Bebê - Cápsula do '
          'Tempo », sur le Google Drive de votre propre compte. '
          'L\'application n\'en a jamais eu de copie sur aucun serveur : '
          'ils vont de votre appareil directement vers votre Drive.',
      'Une fois le compte supprimé, l\'application révoque '
          'l\'autorisation utilisée pour accéder aux fichiers qu\'elle a '
          'créés sur Google Drive. Le champ d\'application utilisé est '
          'https://www.googleapis.com/auth/drive.file, qui limite l\'accès '
          'aux fichiers créés ou ouverts par l\'application dans le cadre '
          'des autorisations accordées par Google. Après la révocation, '
          'l\'application n\'est plus autorisée à opérer sur ces fichiers. '
          'C\'est pourquoi les fichiers restent sous le contrôle de votre '
          'compte Google, sauf si vous choisissez de les supprimer '
          'directement sur le Drive ou, lorsque cela est possible, de '
          'demander à l\'application de les envoyer à la corbeille avant '
          'la suppression du compte.',
      'Si vous souhaitez également supprimer les fichiers, faites-le '
          'directement sur le Drive, en deux gestes :',
      '• Ouvrez drive.google.com avec le même compte',
      '• Trouvez le dossier « Meu Bebê - Cápsula do Tempo »',
      '• Cliquez avec le bouton droit et choisissez « Supprimer »',
      'Si vous préférez demander à l\'application d\'envoyer le dossier '
          'à la corbeille du Drive, faites-le **avant** de finaliser la '
          'suppression du compte, sur le même écran de suppression. La '
          'disponibilité et le résultat définitif de l\'opération dépendent '
          'des autorisations accordées et des mécanismes de Google Drive.',
    ],
  ),
  PrivacySection(
    title: 'L\'abonnement Premium n\'est pas annulé ici',
    body: <String>[
      'Si vous êtes abonné à l\'offre Premium, **supprimer le compte '
          'n\'annule pas l\'abonnement**. Ce sont deux choses situées à des '
          'endroits différents : le compte nous appartient, l\'abonnement '
          'appartient à Google Play.',
      'Sans l\'annuler là-bas, le prélèvement annuel continue même après '
          'la suppression de la capsule. Nous n\'avons pas accès à votre '
          'moyen de paiement et ne pouvons pas l\'annuler à votre place.',
      'Annulez-le avant de supprimer le compte, en quelques gestes :',
      '• Ouvrez le Google Play Store',
      '• Touchez votre photo, en haut à droite',
      '• Allez dans « Paiements et abonnements » puis « Abonnements »',
      '• Choisissez Meu Bebê : Cápsula do Tempo et touchez « Annuler '
          'l\'abonnement »',
      'Après l\'annulation, le Premium reste normalement actif jusqu\'à '
          'la fin de la période déjà payée. Si vous supprimez le compte '
          'avant cela, l\'accès au Premium associé à ce compte prendra fin '
          'dès la suppression du compte. Nous n\'offrons pas de '
          'remboursement proportionnel de notre propre initiative, sauf si '
          'la législation applicable ou les politiques de remboursement de '
          'Google Play l\'exigent.',
    ],
  ),
  PrivacySection(
    title: 'Supprimer seulement une partie',
    body: <String>[
      'Vous n\'avez pas besoin de supprimer tout le compte pour '
          'supprimer quelque chose.',
      'Dans l\'application, tout souvenir peut être envoyé à la '
          'corbeille et supprimé définitivement, un par un. Le profil de '
          'l\'enfant peut être modifié à tout moment. Rien de tout cela ne '
          'passe par nous ni ne nécessite de demande.',
      'Si vous souhaitez simplement arrêter d\'utiliser l\'application '
          'sans rien supprimer, il suffit de vous déconnecter depuis '
          'Profil : les données sur l\'appareil sont supprimées à la '
          'déconnexion, et la collection sur votre Drive reste là où elle '
          'est.',
    ],
  ),
  PrivacySection(
    title: 'Un compte par enfant',
    body: <String>[
      'L\'application utilise un compte Google par enfant, afin qu\'un '
          'jour chacun reçoive sa propre capsule complète.',
      'Cela signifie que supprimer un compte supprime la capsule de cet '
          'enfant, et uniquement la sienne. Si vous utilisez plusieurs '
          'comptes, la demande doit être faite une fois pour chacun, '
          'depuis l\'email de chaque compte.',
      'L\'abonnement Premium est également par compte. Supprimer la '
          'capsule d\'un enfant n\'affecte pas l\'abonnement des autres, et '
          'chacun reste actif, ou est annulé, indépendamment.',
    ],
  ),
  PrivacySection(
    title: 'Journaux techniques',
    body: <String>[
      'L\'infrastructure qui héberge l\'index utilise des services '
          'Firebase et Google Cloud. Comme tout service en nuage, ces '
          'services peuvent conserver des journaux techniques et '
          'opérationnels nécessaires à la sécurité, au fonctionnement, à la '
          'prévention des abus et à l\'audit, sous réserve des politiques '
          'de conservation applicables de Google.',
      'Ces journaux d\'infrastructure ne font pas partie de l\'index que '
          'nous maintenons pour faire fonctionner votre capsule et ne sont '
          'pas utilisés par nous pour reconstituer le contenu supprimé. '
          'Certains journaux techniques peuvent subsister pendant des '
          'durées déterminées par Google ou par des obligations légales '
          'applicables. C\'est pourquoi nous ne promettons pas qu\'absolument '
          'aucun journal technique ne puisse exister dans aucun système '
          'd\'infrastructure après la suppression.',
    ],
  ),
];
