import 'privacy_policy.dart';

/// The privacy policy, in English.
///
/// Mesma ordem de seções da portuguesa: o teste que cobra as seções exigidas
/// por lei vale para as duas.
const List<PrivacySection> privacyPolicyEn = <PrivacySection>[
  PrivacySection(
    title: 'In short',
    body: <String>[
      'Photos, videos and documents never pass through a server of ours: they '
          'go straight from your device to the Google Drive of your own '
          'account.',
      'The app keeps on a server only a text index, which is what makes the '
          'timeline and the search work.',
      'There is no advertising, tracking, profiling or sale of data.',
      'The Premium subscription is billed by Google Play. No payment data '
          'passes through us.',
      'You can delete all of it at any time, inside the app, without asking '
          'anyone.',
    ],
  ),
  PrivacySection(
    title: 'Who is responsible',
    body: <String>[
      'Controller of the personal data, in the sense of Art. 4(7) of the '
          'GDPR: $privacyController, an individual, sole developer, '
          'established in Ireland.',
      'Being established inside the European Union has two good consequences '
          'for you. The first is that the GDPR applies at the source, not by '
          'extension: there is no argument about reach. The second is that '
          'the lead authority is the Data Protection Commission of Ireland, '
          'through the one-stop-shop mechanism of Art. 56 of the GDPR, and '
          'you may complain either to it or to the authority of your own '
          'country.',
      'Contact: $privacyEmail',
      'Every request about personal data should be sent to that address. We '
          'reply within 30 days, the deadline of Art. 12(3) of the GDPR.',
    ],
  ),
  PrivacySection(
    title: 'Your role and ours',
    body: <String>[
      'Recording your own family is, in the language of the GDPR, a "purely '
          'personal or household activity" (Art. 2(2)(c)). That means that, '
          'in keeping your child\'s memories, **you do not become a '
          'controller of personal data before the law**, and you take on none '
          'of the obligations the law places on a company. You remain simply '
          'the parent or guardian, recording your own child.',
      'The app is for that use: personal and family, with no commercial '
          'purpose. Using it to record children who are not yours and not '
          'under your legal responsibility, or to offer this service to third '
          'parties, falls outside what the plans cover.',
      'We have two different roles, and they do not mix. For the index (the '
          'profile, the timeline, the text of the letters), we are the '
          'controller, in the sense of Art. 4(7) of the GDPR: we decide how '
          'that index is processed, and we answer for it. For your files in '
          'Google Drive, we are nothing: they go from your device straight to '
          'your own Google account, under a permission you grant directly to '
          'it, and we never receive a copy, never see them and have no way to '
          'access them. There, your relationship is with Google, and our role '
          'is only that of a program operating with your permission.',
    ],
  ),
  PrivacySection(
    title: 'What stays in your Google Drive',
    body: <String>[
      'When you sign in, you authorise the app to use the Google Drive of '
          'your account with the drive.file scope. That scope gives access '
          'only to the files the app itself creates. It does not allow '
          'reading, listing or modifying any other file in your Drive, and '
          'that limitation is imposed by Google, not by us.',
      'Inside the capsule folder in your Drive live the photos, videos, '
          'drawings and documents you send.',
      'Two text files written by the app live there too: one with the profile '
          'and the growth records, and one per letter you write. They exist so '
          'that this archive still makes sense without the app: a photo '
          'explains itself in a folder, a letter and a weight record do not.',
      'Those files are yours. We have no copy of them, we cannot see them and '
          'we have no technical means of reaching them outside the app in use '
          'in your session.',
      'GPS coordinates are stripped from every photo before it is sent.',
    ],
  ),
  PrivacySection(
    title: 'What stays in our index',
    body: <String>[
      'The index lives in Cloud Firestore, a Google Cloud service. This is '
          'the complete list of what it holds:',
      '• From the profile: the child\'s name, date of birth, sex as informed, '
          'birth weight and length, hospital name if filled in, and the '
          'identifier of the root folder in your Drive.',
      '• From the plan: a single value, yes or no, saying whether the account '
          'has the Premium subscription. Nothing else about payment passes '
          'through here.',
      '• From each memory: type, date, age in days, title, description and, '
          'in the case of letters, the full text of the letter; weight and '
          'length of the growth records; the opening date, when a memory is '
          'sealed; and the identifier, name, type and size of each file in '
          'your Drive.',
      '• Supporting data: the cache of identifiers of the folders created in '
          'Drive and the progress of the suggestions you have ticked.',
      '• From authentication: Firebase Authentication holds your user '
          'identifier, your email, your name and the address of your Google '
          'profile photo.',
      'Each index is isolated per account. Security rules on the server stop '
          'any account from reading or writing another\'s data, and those '
          'rules are checked by automated tests on every change to the app.',
    ],
  ),
  PrivacySection(
    title: 'The subscription payment',
    body: <String>[
      'The Premium subscription is billed by Google Play, not by us. Card, '
          'billing address, invoice and purchase history stay with them, '
          'under their privacy policy.',
      'We do not receive, see or keep any payment data. On our side there is '
          'only the yes or no value described above, in that account\'s '
          'index, which is what lets the app know whether to allow keeping '
          'letters, drawings, documents and growth.',
      'Because the subscription is per account, and each child has their own '
          'Google account, that value is never compared between accounts nor '
          'used to link one account to another.',
    ],
  ),
  PrivacySection(
    title: 'What never leaves the device',
    body: <String>[
      'Reminder settings, the mark that the introduction has been seen, the '
          'inspirations already seen and read, the biometric lock preference '
          'and the cache of photo thumbnails.',
      'None of it is sent anywhere. It leaves the device when you sign out or '
          'uninstall the app.',
    ],
  ),
  PrivacySection(
    title: 'What is not collected',
    body: <String>[
      'This is a closed list:',
      '• No usage data, statistics or analytics. The app has no Google '
          'Analytics, Firebase Analytics, Crashlytics or any equivalent tool.',
      '• No advertising and no advertising identifier.',
      '• No profiling and no automated decision about you.',
      '• No location, contacts, calendar, background microphone or browsing '
          'history.',
      '• No sale, rental or exchange of data with third parties, under any '
          'circumstances.',
      '• No notification coming from a server. Reminders are worked out and '
          'scheduled inside the device itself.',
      'If that changes in some future version, this policy changes first, and '
          'the notice appears in the app.',
    ],
  ),
  PrivacySection(
    title: 'Who the data is shared with',
    body: <String>[
      'Only with Google, acting as processor in the terms of Art. 28 of the '
          'GDPR, for the services the app depends on:',
      '• Google Sign-In, to sign in to your account.',
      '• Firebase Authentication, to keep the session.',
      '• Cloud Firestore, to hold the index.',
      '• Google Drive, to hold your files, in your account.',
      '• Google Play, to bill the Premium subscription and answer whether it '
          'is active, for anyone who subscribes.',
      'There is no other recipient. We use no ad network, data broker or '
          'analytics service.',
      'Processing by Google is governed by their terms, at '
          'policies.google.com/privacy',
      'The GDPR requires, in Art. 28, a written contract between controller '
          'and processor before any processing. That contract exists: it is '
          "Google's Cloud Data Processing Addendum, accepted by using Google "
          'Cloud and Firebase, and it covers exactly the services listed '
          'above.',
    ],
  ),
  PrivacySection(
    title: 'Legal basis for each processing',
    body: <String>[
      '• Profile, index and file upload: performance of the contract, Art. '
          '6(1)(b) of the GDPR. Without that data the app does not work.',
      '• Authentication: performance of the contract, Art. 6(1)(b).',
      '• Reminder notifications: consent, Art. 6(1)(a), revocable at any time '
          'in Settings.',
      '• Record of the plan contracted: performance of the contract, Art. '
          '6(1)(b). Without it there is no way to know what the subscription '
          'unlocked.',
      'We do not use legitimate interest as a basis for anything, and there '
          'is no processing you cannot stop by deleting the account.',
    ],
  ),
  PrivacySection(
    title: "A child's data",
    body: <String>[
      'The app holds data about a child, but is not intended for children and '
          'is not used by them. Whoever installs, registers and sends content '
          'is the parent or legal guardian, over 18.',
      'By registering a child, you declare that you are their legal guardian '
          'and have authority to provide that data.',
      'There is no public listing, visible profile, social network, comments, '
          'messages between users or any form of exposing the content to '
          'third parties. The capsule is private by construction: the files '
          'are in the Drive of whoever sent them and the index is isolated '
          'per account.',
      'When the child comes of age, the data becomes theirs. The app was '
          'designed so that this does not depend on us: the Google account '
          'where everything lives can be handed over directly.',
    ],
  ),
  PrivacySection(
    title: 'For how long, and how to delete',
    body: <String>[
      'The data stays as long as the account exists. There is no automatic '
          'disposal period, because the purpose of the product is precisely '
          'long-term keeping.',
      'In Profile, "Apagar minha conta e meus dados" (Delete my account and '
          'my data), you delete the entire index on our server, sweeping '
          'every collection, with confirmation on the server and not in the '
          'local cache; your authentication account; and all data held on the '
          'device.',
      'On the same screen you choose what to do with the Google Drive folder. '
          'By default it is kept, because the files are yours and the app '
          'never had a copy of them. If you ask, it moves the folder to your '
          'Drive trash.',
      'Deleting the index is immediate and irreversible. We keep no backup of '
          'your data after deletion.',
    ],
  ),
  PrivacySection(
    title: 'Your rights, wherever you live',
    body: <String>[
      'The name of the law changes from country to country. The rights, in '
          'practice, are the same, and we give all of them to everyone, '
          'without asking where you live: access, correction, deletion, '
          'portability, restriction, objection and withdrawal of consent.',
      '• European Union and European Economic Area: GDPR, Arts. 15 to 22.',
      '• United Kingdom: UK GDPR and Data Protection Act 2018, same articles.',
      '• Brazil: LGPD, Art. 18.',
      '• Argentina: Ley 25.326, with a reform under way. Argentina is one of '
          'the few countries outside Europe with an adequacy decision from '
          'the European Union, which says a good deal about the level of '
          'protection its law already demands.',
      '• Uruguay: Ley 18.331, also with European Union adequacy.',
      '• Chile: Ley 19.628, being replaced by Ley 21.719, approved in '
          'December 2024 and modelled on the GDPR, coming into force in '
          'stages.',
      '• Colombia: Ley 1581 of 2012 (Habeas Data), with its own and stricter '
          "rule for children's data: the processing must respect the child's "
          'best interest, not merely the guardian\'s consent. That is a '
          'higher standard, and our design already meets it, because the only '
          'purpose here is the child\'s own capsule, with no exposure to any '
          'third party.',
      '• Peru: Ley 29733. Ecuador: Organic Law on Protection of Personal Data '
          '(LOPDP), of 2021.',
      '• In the other South American countries, without a comprehensive law '
          'of their own yet: the same rights, by our policy.',
      '• United States: California has the most demanding law (CCPA and CPRA, '
          'see the next section), and a growing list of other states such as '
          'Virginia, Colorado, Connecticut and Utah have similar laws, with '
          'the same rights to know, delete, correct, port and refuse sale or '
          'sharing. As we sell and share no data under any circumstances, '
          'that last right comes exercised by default, in every state, with '
          'or without a specific law.',
      '• Switzerland: nFADP. Canada: PIPEDA. Australia: Privacy Act and the '
          'Australian Privacy Principles. South Africa: POPIA. Japan: APPI. '
          'India: DPDPA, as each provision comes into force.',
      '• Anywhere else: the same rights, by our policy, even where local law '
          'does not yet require them.',
      'In practice, almost all of them are exercised without talking to us: '
          'the data is visible in the app, editable in the app and deletable '
          'in the app. For anything the app does not solve, write to '
          '$privacyEmail',
      'You do not need to justify the request, exercising a right never costs '
          'anything, and we never reduce the service of anyone who exercises '
          'one.',
    ],
  ),
  PrivacySection(
    title: 'If you live in California',
    body: <String>[
      'The CCPA, as amended by the CPRA, asks for some sentences to be said '
          'in plain words, and all of them are true here:',
      '• We **do not sell** personal information, and never have.',
      '• We **do not share** personal information for cross-context '
          'behavioural advertising. There is no advertising at all in this '
          'app.',
      '• We do not use or disclose sensitive personal information for '
          'anything beyond providing the service you asked for.',
      '• We offer no financial incentive in exchange for data.',
      '• We do not discriminate against anyone who exercises a right: the app '
          'works the same before and after.',
      'Because we neither sell nor share anything, there is no "Do Not Sell '
          'or Share My Personal Information" button, since there would be '
          'nothing to switch off.',
      'The categories we collect, why, and who they are shared with are in '
          'the sections above, and that list is closed.',
      'If you live in another US state with its own privacy law, the same six '
          'sentences above apply to you too: they describe how the app works, '
          'not an exception thought up only for people in California.',
    ],
  ),
  PrivacySection(
    title: 'International transfer',
    body: <String>[
      'Your files live in the Google Drive of your own account, and their '
          'location is whatever Google gives your account, not a choice of '
          'ours. The index lives on Cloud Firestore infrastructure, which may '
          'process data outside your country.',
      'Those transfers are covered by the Standard Contractual Clauses '
          'approved by the European Commission, adopted by Google under Art. '
          '46 of the GDPR, and by the United Kingdom addendum to those same '
          'clauses. Google Cloud is also certified under the EU-US Data '
          'Privacy Framework.',
      'For anyone in Brazil, the transfer rests on Art. 33 of the LGPD, under '
          'the same contractual clauses.',
      'We move data nowhere of our own accord: we have no server, we make no '
          'copy and we export nothing.',
    ],
  ),
  PrivacySection(
    title: 'Security',
    body: <String>[
      'All traffic is encrypted in transit, and data at rest is encrypted by '
          "Google's infrastructure. Access to the index is controlled by "
          'server-side security rules that require authentication and '
          'restrict each account to its own data. The app offers a lock by '
          'biometrics or device PIN.',
      'No system is entirely secure, and we do not promise otherwise. What '
          'reduces the risk structurally here is the design: the photos and '
          'videos are not on a server of ours, so there is no media database '
          'of ours to be leaked.',
      'If a data breach affecting the index happens, we notify the Data '
          'Protection Commission of Ireland within 72 hours of becoming aware, '
          'as Art. 33 of the GDPR requires, and we tell you directly when the '
          'risk to your rights is high, as Art. 34 requires. Where another '
          'law of your country imposes a different deadline or recipient, '
          'such as the LGPD (Art. 48) or the CCPA, we meet both.',
    ],
  ),
  PrivacySection(
    title: 'Children, and why this app is different',
    body: <String>[
      'This app holds data **about** a child, and is not used **by** her. '
          'Whoever installs, signs in and records is the parent or whoever is '
          'legally responsible for her, and must be of age.',
      'That is why the app is not directed to children in the sense of COPPA, '
          'the American law, nor does it fall under the Google Play Families '
          'programme: there is no content made for the child to use, no '
          'advertising, and no collection of data from anyone underage '
          'browsing on their own.',
      'The child\'s data that exists here was typed in by her guardian, for '
          'the single purpose of building the capsule that one day will be '
          'handed to the child herself, under the household exemption '
          'described in "Your role and ours". Under the LGPD, that same idea '
          'is in Art. 14; under COPPA, it is processing with verifiable '
          'guardian consent.',
      'When the child grows up and takes over the account, she becomes the '
          'data subject and exercises all the rights in the section above '
          'directly, without needing us for anything.',
      'Several countries are creating a specific protection code for products '
          'a child might come to access, such as the United Kingdom\'s '
          'Children\'s Code. We claim no certification in that direction, but '
          'the design of the app already follows the same principles: no '
          'advertising, no profiling, no notification designed to hold '
          'attention, no games, no engagement rewards and no public sharing '
          'by default. A memory can even be sealed, to open only on a future '
          'date chosen by whoever kept it, the opposite of a design meant to '
          'maximise use.',
    ],
  ),
  PrivacySection(
    title: 'Changes to this policy',
    body: <String>[
      'Relevant changes are announced inside the app before they take effect. '
          'The date at the top indicates the version in force, and previous '
          'versions remain available in the public history of the repository.',
    ],
  ),
  PrivacySection(
    title: 'Complaints',
    body: <String>[
      'If you believe the processing of your data breaks the law, you can '
          'complain to the authority of the place where you live, and you do '
          'not need to talk to us first.',
      '• Lead authority, for anyone: Data Protection Commission of Ireland, '
          'dataprotection.ie, which is the one where the controller is '
          'established.',
      '• European Union: you may prefer the authority of your own Member '
          'State, and it forwards. The list is at edpb.europa.eu',
      '• Brazil: ANPD, gov.br/anpd',
      '• Argentina: Agencia de Acceso a la Información Pública (AAIP).',
      '• Uruguay: Unidad Reguladora y de Control de Datos Personales (URCDP).',
      '• Chile: the new Agencia de Protección de Datos Personales, as Ley '
          '21.719 comes into force.',
      '• Colombia: Superintendencia de Industria y Comercio (SIC).',
      '• United Kingdom: ICO, ico.org.uk',
      '• Switzerland: FDPIC. Canada: OPC. Australia: OAIC.',
      '• California: California Privacy Protection Agency, cppa.ca.gov, or '
          'the state Attorney General.',
      'If you would rather try us first, write to $privacyEmail. We reply '
          'within 30 days, and an answer from us is never a condition for you '
          'to approach the authority.',
    ],
  ),
];
