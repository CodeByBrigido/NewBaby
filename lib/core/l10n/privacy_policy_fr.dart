import 'privacy_policy.dart';

/// La politique de confidentialité, en français.
///
/// Traduite fidèlement à partir du portugais, section par section et
/// paragraphe par paragraphe, pour qu'aucun engagement ne soit énoncé avec
/// moins de force dans une langue que dans une autre.
/// La date affichée sur la page publique.
const String privacyPolicyDateFr = '18 août 2026';

const List<PrivacySection> privacyPolicyFr = <PrivacySection>[
  PrivacySection(
    title: 'En bref',
    body: <String>[
      'Les photos, les vidéos et les documents ne transitent jamais par '
          'un serveur nous appartenant : ils vont directement de votre '
          'appareil vers le Google Drive de votre propre compte.',
      'L\'application ne conserve sur un serveur qu\'un index texte, qui '
          'est ce qui fait fonctionner la chronologie et la recherche.',
      'Il n\'y a ni publicité, ni suivi, ni profilage, ni vente de '
          'données.',
      'L\'abonnement Premium est facturé par Google Play. Aucune donnée '
          'de paiement ne transite par nous.',
      'Vous pouvez tout supprimer à tout moment, dans l\'application, '
          'sans avoir à le demander à personne.',
    ],
  ),
  PrivacySection(
    title: 'Qui est responsable',
    body: <String>[
      'Responsable du traitement des données personnelles (responsable '
          'du traitement, au sens de l\'Art. 4(7) du RGPD) : '
          '$privacyController, personne physique, développeur individuel, '
          'établi en Irlande.',
      'Le responsable de l\'application étant établi en Irlande, le RGPD '
          's\'applique aux traitements relevant de son champ d\'application. '
          'Lorsque le mécanisme de guichet unique s\'applique aux '
          'traitements transfrontaliers, l\'autorité de contrôle chef de '
          'file sera déterminée conformément à l\'Art. 56 du RGPD. Vous '
          'pouvez également déposer une réclamation auprès de l\'autorité de '
          'protection des données du pays où vous résidez ou travaillez, ou '
          'du lieu où la violation présumée a eu lieu.',
      'Contact : $privacyEmail',
      'Toute demande relative aux données personnelles peut être envoyée '
          'à cette adresse. Nous répondons sans retard indu et, en règle '
          'générale, dans un délai d\'un mois, conformément à l\'Art. 12(3) '
          'du RGPD. Lorsque la législation permet une prolongation de ce '
          'délai, nous vous en informerons dans le premier mois et en '
          'expliquerons les motifs.',
    ],
  ),
  PrivacySection(
    title: 'Votre rôle et le nôtre',
    body: <String>[
      'Lorsqu\'une personne utilise l\'application exclusivement pour '
          'enregistrer et conserver les souvenirs de sa propre famille, cet '
          'usage peut relever de l\'exception d\'activité exclusivement '
          'personnelle ou domestique prévue à l\'Art. 2(2)(c) du RGPD. Cette '
          'exception concerne l\'application du RGPD au traitement réalisé '
          'par la personne elle-même et ne modifie pas les responsabilités '
          'pouvant incomber à l\'application concernant les données '
          'personnelles qu\'elle traite elle-même.',
      'L\'application est destinée à cet usage : personnel et familial, '
          'sans but commercial. L\'utiliser pour enregistrer des enfants qui '
          'ne sont pas les vôtres ni sous votre responsabilité légale, ou '
          'pour offrir ce service à des tiers, sort de ce que couvrent les '
          'offres.',
      'Nous avons des responsabilités différentes selon la donnée et le '
          'service concernés. Pour l\'index que nous maintenons afin de '
          'faire fonctionner l\'application, comme le profil, la '
          'chronologie et le texte des lettres, nous sommes responsables de '
          'définir les finalités et les moyens essentiels de ce traitement '
          'et, lorsque le RGPD s\'applique, nous agissons en tant que '
          'responsable de ces données. Pour les fichiers envoyés '
          'directement au compte Google Drive de l\'utilisateur, '
          'l\'application ne reçoit aucune copie de ces fichiers et ne les '
          'stocke pas sur des serveurs propres. L\'utilisation de Google '
          'Drive est également soumise aux conditions et à la politique de '
          'confidentialité de Google. Notre application agit uniquement '
          'dans les limites des autorisations accordées par l\'utilisateur.',
    ],
  ),
  PrivacySection(
    title: 'Ce qui reste sur votre Google Drive',
    body: <String>[
      'En vous connectant, vous autorisez l\'application à utiliser le '
          'Google Drive de votre compte avec le champ d\'application '
          'drive.file. Ce champ d\'application donne accès uniquement aux '
          'fichiers que l\'application elle-même crée. Il ne permet pas de '
          'lire, lister ou modifier aucun autre fichier de votre Drive, et '
          'cette limitation est imposée par Google, pas par nous.',
      'Restent dans votre Drive, dans le dossier « Meu Bebê - Cápsula do '
          'Tempo » : les photos, les vidéos, les dessins et les documents '
          'que vous envoyez.',
      'Restent également deux fichiers texte, écrits par l\'application : '
          'l\'un avec le profil et les mesures de croissance, l\'autre pour '
          'chaque lettre que vous écrivez. Ils existent pour que cet '
          'ensemble continue d\'avoir un sens sans l\'application : une '
          'photo s\'explique d\'elle-même dans un dossier, une lettre et une '
          'mesure de poids non.',
      'Ces fichiers sont les vôtres. Nous n\'en avons pas de copie, nous '
          'ne pouvons pas les voir et nous n\'avons aucun moyen technique '
          'd\'y accéder en dehors de l\'application utilisée lors de votre '
          'session.',
      'Les coordonnées GPS sont retirées de chaque photo avant l\'envoi.',
    ],
  ),
  PrivacySection(
    title: 'Ce qui reste dans notre index',
    body: <String>[
      'L\'index se trouve sur Cloud Firestore, un service de Google '
          'Cloud. Voici la liste complète de ce qu\'il conserve :',
      '• Du profil : nom de l\'enfant, date de naissance, sexe indiqué, '
          'poids et taille à la naissance, nom de l\'hôpital si renseigné, '
          'et l\'identifiant du dossier racine sur votre Drive.',
      '• De l\'offre : une seule valeur, oui ou non, indiquant si le '
          'compte a l\'abonnement Premium. Rien d\'autre concernant le '
          'paiement ne transite par ici.',
      '• De chaque souvenir : le type, la date, l\'âge en jours, le '
          'titre, la description et, pour les lettres, le texte intégral de '
          'la lettre ; le poids et la taille des mesures de croissance ; la '
          'date d\'ouverture, quand le souvenir est scellé ; et '
          'l\'identifiant, le nom, le type et la taille de chaque fichier '
          'sur votre Drive.',
      '• De soutien : le cache des identifiants des dossiers créés sur le '
          'Drive et la progression des suggestions que vous avez cochées.',
      '• De l\'authentification : Firebase Authentication conserve votre '
          'identifiant utilisateur, votre email, votre nom et l\'adresse de '
          'votre photo de profil Google.',
      'Chaque index est isolé par compte. Des règles de sécurité côté '
          'serveur empêchent tout compte de lire ou d\'écrire les données '
          'd\'un autre, et ces règles sont vérifiées par des tests '
          'automatisés à chaque modification de l\'application.',
    ],
  ),
  PrivacySection(
    title: 'Le paiement de l\'abonnement',
    body: <String>[
      'C\'est Google Play qui facture l\'abonnement Premium, pas nous. '
          'La carte, l\'adresse de facturation, la facture et l\'historique '
          'd\'achats restent chez eux, sous leur politique de '
          'confidentialité.',
      'Nous ne recevons, ne voyons et ne conservons aucune donnée de '
          'paiement. De notre côté ne reste que la valeur oui ou non décrite '
          'ci-dessus, dans l\'index de ce compte, qui indique à '
          'l\'application si elle doit autoriser l\'enregistrement de '
          'lettres, dessins, documents et mesures de croissance.',
      'L\'abonnement étant valable par compte, et chaque enfant ayant son '
          'propre compte Google, cette valeur n\'est jamais comparée entre '
          'comptes ni utilisée pour relier un compte à un autre.',
    ],
  ),
  PrivacySection(
    title: 'Ce qui ne quitte jamais l\'appareil',
    body: <String>[
      'Les réglages de rappels, la marque indiquant que la présentation '
          'initiale a déjà été vue, les idées déjà vues et lues, la '
          'préférence de verrouillage biométrique et le cache des '
          'miniatures des photos.',
      'Rien de tout cela n\'est envoyé où que ce soit. Cela quitte '
          'l\'appareil quand vous vous déconnectez ou désinstallez '
          'l\'application.',
    ],
  ),
  PrivacySection(
    title: 'Ce qui n\'est pas collecté',
    body: <String>[
      'Voici une liste fermée :',
      '• Aucune donnée d\'usage, statistique ou analytique. '
          'L\'application n\'a ni Google Analytics, ni Firebase Analytics, '
          'ni Crashlytics, ni aucun outil équivalent.',
      '• Aucune publicité et aucun identifiant publicitaire.',
      '• Aucun profilage et aucune décision automatisée vous concernant.',
      '• Aucune localisation, aucun contact, agenda, micro en arrière-'
          'plan ni historique de navigation.',
      '• Aucune vente, location ou échange de données avec des tiers, en '
          'aucune circonstance.',
      '• Aucune notification provenant d\'un serveur. Les rappels sont '
          'calculés et programmés directement sur l\'appareil.',
      'Si cela devait changer dans une future version, cette politique '
          'changerait d\'abord, et l\'avis apparaîtrait dans l\'application.',
    ],
  ),
  PrivacySection(
    title: 'Avec qui les données sont partagées',
    body: <String>[
      'Les données sont partagées ou traitées par des services Google '
          'nécessaires à certaines fonctions de l\'application :',
      '• Google Sign-In, pour vous connecter à votre compte.',
      '• Firebase Authentication, pour maintenir la session.',
      '• Cloud Firestore, pour conserver l\'index.',
      '• Google Drive, pour conserver vos fichiers sur votre propre '
          'compte.',
      '• Google Play, pour facturer l\'abonnement Premium et indiquer '
          's\'il est actif, pour qui s\'abonne.',
      'Il n\'y a aucun autre destinataire choisi par nous. Nous '
          'n\'utilisons ni régie publicitaire, ni courtier en données, ni '
          'service d\'analyse.',
      'La relation juridique applicable à chaque service Google dépend '
          'du produit utilisé, de la configuration du compte et des '
          'conditions contractuelles correspondantes. Lorsque Google agit '
          'en tant que sous-traitant à l\'égard du traitement que nous '
          'réalisons, ce traitement est régi par l\'instrument contractuel '
          'applicable, y compris les conditions de protection des données '
          'de Google Cloud/Firebase. Pour les services où Google agit en '
          'son nom propre ou directement vis-à-vis de l\'utilisateur, les '
          'conditions et la politique de confidentialité de Google '
          's\'appliquent également.',
      'Le traitement effectué par Google est décrit dans sa politique de '
          'confidentialité : policies.google.com/privacy',
    ],
  ),
  PrivacySection(
    title: 'Base légale de chaque traitement',
    body: <String>[
      '• Profil, index, authentification et fonctionnement essentiel du '
          'compte : exécution du contrat, Art. 6(1)(b) du RGPD, lorsque ce '
          'traitement est nécessaire pour fournir la fonctionnalité '
          'demandée.',
      '• Notifications de rappel : consentement, Art. 6(1)(a), révocable '
          'à tout moment dans les Paramètres.',
      '• Enregistrement de l\'offre souscrite : exécution du contrat, '
          'Art. 6(1)(b), dans la mesure nécessaire pour gérer l\'abonnement '
          'et débloquer les fonctionnalités correspondantes.',
      '• Envoi et stockage de fichiers sur Google Drive : opération '
          'demandée par l\'utilisateur et réalisée grâce à l\'autorisation '
          'accordée à Google Drive, sans que l\'application ne conserve sa '
          'propre copie de ces fichiers.',
      'Nous n\'utilisons pas l\'intérêt légitime comme base pour les '
          'traitements décrits dans cette politique. Si une obligation '
          'légale exige la conservation de certaines données après la '
          'suppression du compte, ces données pourront être conservées '
          'pendant la durée exigée par la loi.',
    ],
  ),
  PrivacySection(
    title: 'Données d\'un enfant',
    body: <String>[
      'L\'application conserve des données concernant un enfant, mais '
          'n\'est pas destinée aux enfants et n\'est pas utilisée par eux. '
          'Celui ou celle qui installe, enregistre et envoie du contenu est '
          'la mère, le père ou le représentant légal, majeur.',
      'En enregistrant un enfant, vous déclarez être son représentant '
          'légal et avoir l\'autorité pour fournir ces données.',
      'Il n\'y a ni inscription publique, ni profil visible, ni réseau '
          'social, ni commentaires, ni messages entre utilisateurs, ni '
          'aucune forme d\'exposition du contenu à des tiers. La capsule '
          'est privée par conception : les fichiers se trouvent dans le '
          'Drive de celui qui les a envoyés et l\'index est isolé par '
          'compte.',
      'Lorsque l\'enfant atteindra la majorité, il pourra exercer '
          'directement les droits applicables à ses données personnelles, '
          'conformément à la législation en vigueur. L\'application a été '
          'conçue pour faciliter cette continuité : les fichiers restent '
          'sur le compte Google utilisé par la famille et peuvent être mis '
          'à la disposition de la personne elle-même, sans dépendre d\'un '
          'transfert de fichiers stockés sur nos serveurs.',
    ],
  ),
  PrivacySection(
    title: 'Pendant combien de temps, et comment supprimer',
    body: <String>[
      'Les données restent tant que le compte existe. Il n\'y a pas de '
          'délai automatique de suppression tant que le compte reste actif, '
          'car la finalité du produit est justement la conservation à long '
          'terme. Lorsqu\'il existe une obligation légale de conservation '
          'ou une autre base juridique exigeant la conservation d\'une '
          'donnée déterminée, elle pourra être conservée pendant la durée '
          'nécessaire.',
      'Dans Profil, « Supprimer mon compte et mes données », vous '
          'supprimez tout l\'index sur notre serveur, en parcourant chaque '
          'collection, avec confirmation côté serveur et non dans le cache '
          'local ; votre compte d\'authentification ; et toutes les données '
          'conservées sur l\'appareil.',
      'Sur le même écran, vous choisissez ce qu\'il advient du dossier '
          'Google Drive. Par défaut, il est conservé, car les fichiers sont '
          'stockés directement sur votre compte et l\'application n\'en '
          'conserve pas de copie propre. Si l\'autorisation et les API de '
          'Google disponibles à ce moment-là le permettent, vous pouvez '
          'demander à l\'application de déplacer le dossier vers la '
          'corbeille de votre Drive. La suppression définitive des fichiers '
          'dans Google Drive dépend également des règles et des mécanismes '
          'de suppression propres à Google.',
      'La suppression de l\'index débute immédiatement et, une fois '
          'terminée, ne peut pas être annulée par l\'application. Nous ne '
          'conservons aucune sauvegarde opérationnelle de l\'index '
          'permettant de restaurer un compte supprimé. Les données devant '
          'être conservées pour une obligation légale pourront être '
          'maintenues pendant la durée exigée et seront protégées contre '
          'tout usage incompatible avec cette finalité.',
    ],
  ),
  PrivacySection(
    title: 'Vos droits, où que vous viviez',
    body: <String>[
      'Le nom de la loi change d\'un pays à l\'autre. Les droits, en '
          'pratique, sont les mêmes, et nous les accordons tous à tout le '
          'monde, sans demander où vous vivez : accès, rectification, '
          'suppression, portabilité, limitation, opposition et retrait du '
          'consentement.',
      '• Union européenne et Espace économique européen : RGPD, Art. 15 '
          'à 22.',
      '• Royaume-Uni : UK GDPR et Data Protection Act 2018, avec les '
          'mêmes articles.',
      '• Brésil : LGPD, Art. 18.',
      '• Argentine : Ley 25.326, avec une réforme en cours. L\'Argentine '
          'est l\'un des rares pays hors d\'Europe bénéficiant d\'une '
          'décision d\'adéquation de l\'Union européenne, ce qui en dit long '
          'sur le niveau de protection déjà exigé par sa loi.',
      '• Uruguay : Ley 18.331, également avec une adéquation de l\'Union '
          'européenne.',
      '• Chili : Ley 19.628, remplacée par la Ley 21.719, adoptée en '
          'décembre 2024 et inspirée du RGPD, avec une entrée en vigueur '
          'progressive.',
      '• Colombie : Ley 1581 de 2012 (Habeas Data), avec une règle '
          'propre et plus exigeante pour les données d\'enfants : le '
          'traitement doit respecter son intérêt supérieur, et pas '
          'seulement le consentement du représentant légal. C\'est une '
          'norme plus élevée que ce que notre conception respecte déjà, '
          'puisque le seul but ici est la propre capsule de l\'enfant, sans '
          'exposition à des tiers.',
      '• Pérou : Ley 29733. Équateur : Loi organique de protection des '
          'données personnelles (LOPDP), de 2021.',
      '• Dans les autres pays d\'Amérique du Sud, sans loi globale '
          'propre encore : les mêmes droits, selon notre politique.',
      '• États-Unis : la Californie a la loi la plus exigeante (CCPA et '
          'CPRA, voir la section suivante), et une liste croissante d\'autres '
          'États comme la Virginie, le Colorado, le Connecticut et l\'Utah '
          'ont des lois similaires, avec les mêmes droits de savoir, '
          'supprimer, corriger, porter et refuser la vente ou le partage. '
          'Comme nous ne vendons ni ne partageons aucune donnée en aucune '
          'circonstance, ce dernier droit est déjà exercé par défaut, dans '
          'chaque État, qu\'il ait ou non une loi spécifique.',
      '• Suisse : nLPD. Canada : LPRPDE. Australie : Privacy Act et les '
          'Australian Privacy Principles. Afrique du Sud : POPIA. Japon : '
          'APPI. Inde : DPDPA, à mesure de l\'entrée en vigueur de chaque '
          'disposition.',
      '• Partout ailleurs : les mêmes droits, selon notre politique, '
          'même là où la loi locale ne les exige pas encore.',
      'En pratique, presque tous s\'exercent sans avoir à nous '
          'contacter : les données sont visibles dans l\'application, '
          'modifiables dans l\'application et supprimables dans '
          'l\'application. Pour tout ce que l\'application ne résout pas, '
          'écrivez à $privacyEmail',
      'Vous n\'avez pas à justifier votre demande, exercer un droit ne '
          'coûte jamais rien, et nous ne réduisons jamais le service de '
          'quiconque exerce l\'un d\'entre eux.',
    ],
  ),
  PrivacySection(
    title: 'Si vous vivez en Californie',
    body: <String>[
      'Le CCPA, modifié par le CPRA, demande que certaines phrases '
          'soient dites explicitement, et elles sont toutes vraies ici :',
      '• Nous **ne vendons pas** d\'informations personnelles, et ne les '
          'vendons jamais.',
      '• Nous **ne partageons pas** d\'informations personnelles à des '
          'fins de publicité comportementale entre sites ou applications. '
          'Il n\'y a aucune publicité dans cette application.',
      '• Nous n\'utilisons ni ne divulguons d\'informations personnelles '
          'sensibles pour autre chose que de fournir le service que vous '
          'avez demandé.',
      '• Nous n\'offrons aucune incitation financière en échange de '
          'données.',
      '• Nous ne discriminons personne qui exerce un droit : '
          'l\'application fonctionne de la même façon avant et après.',
      'Comme nous ne vendons ni ne partageons rien, il n\'existe aucun '
          'bouton « Do Not Sell or Share My Personal Information », car il '
          'n\'y aurait rien à désactiver.',
      'Les catégories que nous collectons, pourquoi, et avec qui elles '
          'sont partagées figurent dans les sections ci-dessus, et cette '
          'liste est fermée.',
      'Si vous vivez dans un autre État américain doté de sa propre loi '
          'sur la confidentialité, les six mêmes phrases ci-dessus valent '
          'également pour vous : elles décrivent le fonctionnement de '
          'l\'application, et non une exception pensée uniquement pour la '
          'Californie.',
    ],
  ),
  PrivacySection(
    title: 'Transfert international',
    body: <String>[
      'Vos fichiers restent sur le Google Drive de votre propre compte, '
          'et leur emplacement est celui que Google attribue à votre '
          'compte, pas un choix de notre part. L\'index se trouve sur '
          'l\'infrastructure de Cloud Firestore, qui peut traiter des '
          'données hors de votre pays.',
      'Ces transferts sont couverts par les clauses contractuelles types '
          'approuvées par la Commission européenne, adoptées par Google '
          'conformément à l\'Art. 46 du RGPD, et par l\'addendum britannique '
          'à ces mêmes clauses. Google Cloud est également certifié dans le '
          'cadre du Data Privacy Framework entre l\'Union européenne et les '
          'États-Unis.',
      'Pour les personnes au Brésil, le transfert s\'appuie sur l\'Art. '
          '33 de la LGPD, via les mêmes clauses contractuelles.',
      'Nous ne réalisons pas de transferts internationaux de notre '
          'propre initiative, au-delà du traitement nécessaire pour faire '
          'fonctionner les services d\'infrastructure décrits dans cette '
          'politique. L\'index peut être traité sur l\'infrastructure de '
          'Google Cloud, y compris dans des lieux situés hors du pays de '
          'l\'utilisateur, selon la configuration et les conditions des '
          'services utilisés. Les fichiers de Google Drive restent soumis à '
          'l\'infrastructure et à la configuration du compte Google de '
          'l\'utilisateur lui-même.',
    ],
  ),
  PrivacySection(
    title: 'Sécurité',
    body: <String>[
      'Tout le trafic est chiffré en transit, et les données au repos '
          'sont chiffrées par l\'infrastructure de Google. L\'accès à '
          'l\'index est contrôlé par des règles de sécurité côté serveur '
          'qui exigent une authentification et limitent chaque compte à '
          'ses propres données. L\'application propose un verrouillage par '
          'biométrie ou par code de l\'appareil.',
      'Aucun système n\'est totalement sûr, et nous ne prétendons pas le '
          'contraire. Ce qui réduit structurellement le risque ici, c\'est '
          'la conception : les photos et les vidéos ne se trouvent pas sur '
          'un serveur nous appartenant, donc il n\'existe aucune base de '
          'médias nous appartenant qui pourrait fuiter.',
      'En cas de violation de données affectant l\'index, nous notifions '
          'la Commission de protection des données d\'Irlande dans les 72 '
          'heures suivant sa découverte, comme l\'exige l\'Art. 33 du RGPD, '
          'et nous vous en informons directement lorsque le risque est '
          'élevé pour vos droits, comme l\'exige l\'Art. 34. Lorsqu\'une '
          'autre loi de votre pays impose un délai ou un destinataire '
          'différent, comme la LGPD (Art. 48) ou le CCPA, nous respectons '
          'les deux.',
    ],
  ),
  PrivacySection(
    title: 'Les enfants, et pourquoi cette application est différente',
    body: <String>[
      'Cette application conserve des données **sur** un enfant, et '
          'n\'est pas utilisée **par** lui. Celui ou celle qui installe, se '
          'connecte et enregistre est la mère, le père ou son représentant '
          'légal, et doit être majeur.',
      'C\'est pourquoi l\'application n\'est pas destinée aux enfants et '
          'n\'a pas été conçue pour que des mineurs créent ou utilisent des '
          'comptes de leur propre initiative. Celui ou celle qui installe, '
          'se connecte et enregistre des informations doit être un adulte '
          'responsable. Il n\'y a ni publicité, ni profil public, ni '
          'interaction entre utilisateurs, ni fonctionnalité destinée à '
          'encourager une utilisation autonome par des enfants.',
      'Les données concernant l\'enfant sont fournies par l\'adulte '
          'responsable dans le but de créer et de conserver la capsule '
          'temporelle. Le traitement des données d\'enfants et '
          'd\'adolescents respectera la législation applicable et, le cas '
          'échéant, les principes de protection intégrale et d\'intérêt '
          'supérieur de l\'enfant.',
      'Lorsque l\'enfant grandira et prendra en charge le compte, il '
          'deviendra titulaire de ces données et exercera directement tous '
          'les droits de la section ci-dessus, sans avoir besoin de nous '
          'pour quoi que ce soit.',
      'Plusieurs pays élaborent un code de protection spécifique pour '
          'les produits qu\'un enfant pourrait être amené à utiliser, comme '
          'le Children\'s Code britannique. Nous n\'avons formalisé aucune '
          'certification en ce sens, mais la conception de l\'application '
          'suit déjà les mêmes principes : aucune publicité, aucun '
          'profilage, aucune notification conçue pour capter l\'attention, '
          'aucun jeu, aucune récompense pour l\'engagement et aucun partage '
          'public par défaut. Un souvenir peut même être scellé, pour '
          'n\'être ouvert qu\'à une date future choisie par celui qui l\'a '
          'conservé, à l\'opposé d\'une conception pensée pour maximiser '
          'l\'usage.',
    ],
  ),
  PrivacySection(
    title: 'Modifications de cette politique',
    body: <String>[
      'Les modifications significatives sont annoncées dans '
          'l\'application avant d\'entrer en vigueur. La date en haut de '
          'page indique la version en vigueur, et les versions antérieures '
          'restent disponibles dans l\'historique public du dépôt.',
    ],
  ),
  PrivacySection(
    title: 'Réclamation',
    body: <String>[
      'Si vous pensez que le traitement de vos données enfreint la loi, '
          'vous pouvez déposer une réclamation auprès de l\'autorité du '
          'lieu où vous vivez, sans avoir à nous contacter au préalable.',
      '• Irlande : Data Protection Commission (DPC), en particulier '
          'lorsque la DPC est l\'autorité de contrôle compétente ou chef de '
          'file au sens du RGPD.',
      '• Union européenne : vous pouvez préférer l\'autorité de votre '
          'propre État membre, qui transmettra. La liste se trouve sur '
          'edpb.europa.eu',
      '• Brésil : ANPD, gov.br/anpd',
      '• Argentine : Agencia de Acceso a la Información Pública (AAIP).',
      '• Uruguay : Unidad Reguladora y de Control de Datos Personales '
          '(URCDP).',
      '• Chili : la nouvelle Agencia de Protección de Datos Personales, '
          'à mesure que la Ley 21.719 entre en vigueur.',
      '• Colombie : Superintendencia de Industria y Comercio (SIC).',
      '• Royaume-Uni : ICO, ico.org.uk',
      '• Suisse : PFPDT. Canada : CPVP. Australie : OAIC.',
      '• Californie : California Privacy Protection Agency, cppa.ca.gov, '
          'ou le procureur général de l\'État.',
      'Si vous préférez d\'abord essayer avec nous, écrivez à '
          '$privacyEmail. Nous répondons sous 30 jours maximum, et une '
          'réponse de notre part n\'est jamais une condition pour saisir '
          'l\'autorité.',
    ],
  ),
];
