import 'privacy_policy.dart';
import 'terms_of_use.dart';

/// The terms of use, in English.
///
/// Mesma ordem de seções da portuguesa. **Isto não é parecer jurídico**, e a
/// ressalva vale igual nas duas línguas.
const List<PrivacySection> termsOfUseEn = <PrivacySection>[
  PrivacySection(
    title: 'In short',
    body: <String>[
      'The app is for keeping a record of a child\'s early years. It stores '
          'the files in the Google Drive of whichever account you use, not on '
          'a server of ours.',
      'There are two plans. On Basic, which is free, you read everything you '
          'have already kept and carry on keeping photos and videos. Premium, '
          'a yearly subscription, adds keeping letters, drawings, documents '
          'and growth records.',
      'The content is yours. We do not look at it, use it or sell any of what '
          'you keep.',
      'You must be at least $idadeMinima, or the age of majority where you '
          'live if that is higher, and be responsible for the child to create '
          'the account.',
      'The app is not a backup, and it is not medical or legal advice.',
    ],
  ),
  PrivacySection(
    title: 'What this app is',
    body: <String>[
      'Meu Bebê: Cápsula do Tempo is a digital time capsule. It organises '
          'photos, videos, letters, drawings, documents and growth records by '
          'the age of the child, so that one day she can open it herself and '
          'live her own childhood again.',
      'There is no advertising, and never was. What exists is an optional '
          'subscription, described in the next section, that widens what you '
          'can keep.',
      'It is an organiser, not a storage service: the space used is that of '
          'your Google account, and the rules about space and charges are '
          "Google's, not ours.",
    ],
  ),
  PrivacySection(
    title: 'The Basic and Premium plans',
    body: <String>[
      'The Basic plan is free and has no time limit. With it you sign in, '
          'walk the whole timeline, open and read everything already kept, '
          'and carry on keeping photos and videos.',
      'The Premium plan is a yearly subscription. It adds keeping letters, '
          'drawings, documents and growth records, which are the parts where '
          'the capsule stops being an album.',
      'The subscription belongs to the account that signs in, not to the '
          'device nor to whoever paid. If you record more than one child, '
          'each has their own Google account, and each account needs its own '
          'subscription.',
      'Going without the subscription never closes anything that is already '
          'yours. At the end of the paid period the app returns to Basic: the '
          'letters, drawings, documents and measurements you already kept '
          'stay in plain view, and the files stay in the child\'s Google '
          'Drive. What stops is keeping new things of those four kinds.',
    ],
  ),
  PrivacySection(
    title: 'The subscription, the payment and cancelling',
    body: <String>[
      'Billing is done by Google Play, not by us. The price appears in your '
          "country's currency, inside the store itself, before you confirm.",
      'The subscription is yearly and renews on its own, through the Google '
          'Play account that made the purchase, until you cancel it.',
      'Cancelling, changing the payment method or asking for a refund is done '
          'in Google Play, under Payments and subscriptions. We have no '
          'access to your payment method and cannot charge, cancel or refund '
          'on your behalf.',
      'Once cancelled, access to Premium continues until the end of the '
          'period already paid for. There is no pro rata refund for unused '
          'days, and the refund rules are Google Play\'s, alongside the rights '
          'your law guarantees and that nobody can waive.',
      'If the price changes, the change applies to later renewals, and Google '
          'Play gives notice beforehand, by the route it uses for that. You '
          'can cancel before the renewal happens.',
      'Where the law of your country gives you a window to withdraw from a '
          'distance purchase, that window applies, and it applies above '
          'anything written here. It is fourteen days in the European Union '
          'and the United Kingdom, seven days in Brazil, and other periods in '
          'many other places. The request is made in Google Play, which is '
          'who received the payment.',
      'Deleting the account inside the app does not cancel the subscription. '
          'They are separate things: one is ours, the other is Google '
          "Play's. Cancel there too, or the billing continues.",
    ],
  ),
  PrivacySection(
    title: 'Who can use it',
    body: <String>[
      'To create an account you declare that you are at least $idadeMinima, '
          'or the age of majority in the country where you live if that is '
          'higher, and that you are the mother, father or legal guardian of '
          'the child whose data you are going to record, or that you have '
          'authorisation from whoever is.',
      'This is not a formality. Children\'s data receives heightened care in '
          'practically every data protection law in the world, among them the '
          'LGPD in Brazil, the GDPR in the European Union, the UK GDPR in the '
          'United Kingdom and COPPA in the United States. In all of them, '
          'whoever authorises the recording has to be whoever is legally '
          'responsible for the child.',
      'The app is not for the child to use while she is a child. It is '
          'written for whoever is recording today, and made to be handed to '
          'her when she is an adult.',
    ],
  ),
  PrivacySection(
    title: 'The account and access',
    body: <String>[
      'You sign in with a Google account. You are responsible for keeping '
          'that account secure, and for who has access to the device where '
          'the app is installed.',
      'The app asks for permission to your Google Drive only for the files it '
          'creates itself. It cannot see, list or reach anything that was '
          'already in your account.',
      'You can revoke that permission at any time, through your Google '
          'account. Once revoked, the app can no longer keep new things, and '
          'the files already sent stay in your Drive.',
    ],
  ),
  PrivacySection(
    title: 'The content is yours',
    body: <String>[
      'Everything you keep remains yours. We acquire no right over your '
          'photos, your videos or the texts you write.',
      'We ask for no licence to use them, we publish nothing anywhere and we '
          'do not use your content to train any system.',
      'You are responsible for what you keep, including having the right to '
          'keep it. Photographing someone else\'s daughter and keeping it '
          'here is your decision, and so are the consequences.',
    ],
  ),
  PrivacySection(
    title: 'What you may not do',
    body: <String>[
      'Use the app for commercial purposes, to provide this service to third '
          'parties, or to record a child who is neither yours nor under your '
          'legal responsibility. The app is for personal and family use, and '
          'it is that restricted use that frees you, the person recording, '
          'from any data controller obligation under the law.',
      'Use the app to keep or distribute illegal content, in particular any '
          'material of child abuse or exploitation.',
      'Use the app to violate the privacy of third parties or to keep content '
          'about people who did not consent.',
      'Try to get around the app\'s protections, access data from other '
          'accounts, or interfere with the running of the service.',
      'On discovering any of these, we may terminate access to the app. We '
          "have no way to delete what is in someone else's Drive, and reports "
          'of crime go to the authorities.',
    ],
  ),
  PrivacySection(
    title: 'What we do not promise',
    body: <String>[
      'The app is offered as is. We do not guarantee that it will always be '
          'available, free of faults or compatible with every device.',
      'We are not a backup service. A file you send lives in your Google '
          'Drive, and its preservation depends on your Google account '
          'continuing to exist and to have space. Keep copies of whatever is '
          'irreplaceable.',
      'We depend on Google services to sign in and to store. If they change '
          'their rules, their prices or go offline, that affects the app, and '
          'it is outside our control.',
      'The inspirations and suggestions inside the app are editorial content, '
          'written to follow the stage the child is in. They are not medical, '
          'psychological or legal guidance, and none of them says what a '
          'child "should" be doing.',
    ],
  ),
  PrivacySection(
    title: 'The limit of our liability',
    body: <String>[
      'To the extent the law allows, we are not liable for loss of content, '
          'lost profits or indirect damage arising from use of the app.',
      'This does not set aside anything the law does not allow to be set '
          'aside, wherever you live. Nowhere do we limit liability for wilful '
          'misconduct, gross negligence, death or injury, or for any right '
          'your consumer law declares non-waivable. Where your law does not '
          'admit the limit written above, it simply does not apply to you, '
          'and the rest of these terms stands.',
    ],
  ),
  PrivacySection(
    title: 'If you want to stop',
    body: <String>[
      'You can sign out, uninstall the app or delete the account and the data '
          'at any time, without giving a reason and at no cost.',
      'The path is described on the account deletion page, and it works even '
          'for someone who has already uninstalled the app.',
      'If you have Premium, remember to cancel the subscription in Google '
          'Play as well. Deleting the account here does not cancel it there.',
      'We may terminate the service or your account in case of illegal use, '
          'or if one day the app ceases to exist. In that case we will give as '
          'much notice as we can, and your files stay in your Google Drive, '
          'organised in readable folders, even without the app.',
    ],
  ),
  PrivacySection(
    title: 'Changes to these terms',
    body: <String>[
      'These terms may change when the app changes. The date at the top of '
          'this page says which version you are reading.',
      'Every version of the app carries the terms of that version inside it, '
          'so the text you read when you installed is still there, even if '
          'what is published is now different.',
      'Continuing to use it after a change means agreeing with it. If you do '
          'not agree, you can delete the account by the path above.',
    ],
  ),
  PrivacySection(
    title: 'Where the app is offered',
    body: <String>[
      'The app is distributed through Google Play and can be used in any '
          'country where the store offers it. The interface and these '
          'documents exist in Portuguese and in English.',
      'The publisher is an individual established in Ireland, not a company '
          'with an office in each country. That does not reduce your rights: '
          'the law of the place where you live still applies to you, and the '
          'next section explains how the two live together.',
      'We do not offer the app in countries under sanctions that prevent '
          'providing the service, and Google Play controls that distribution.',
      'We also do not offer it where local law requires data to be stored '
          'physically inside the country, as is the case today in China and '
          'Russia, among others. Our architecture depends on Google\'s global '
          'cloud, and meeting such a requirement would demand our own '
          'infrastructure inside that country, which this project does not '
          'have. We would rather say so plainly than pretend to comply with a '
          'rule we do not.',
    ],
  ),
  PrivacySection(
    title: 'Applicable law and where to complain',
    body: <String>[
      'These terms are governed by Irish law and European Union law, which is '
          'the law of the place from which the app is operated.',
      'That does **not** set aside the mandatory protection your country of '
          'residence gives you as a consumer. If you live in the European '
          'Union, the United Kingdom, Brazil, the United States, Canada, '
          'Australia or anywhere whose consumer law cannot be set aside by '
          'contract, it still applies, and it prevails over any clause here '
          'that contradicts it.',
      'You can go to the courts of the place where you live. In the European '
          'Union that is the court of your country of residence, guaranteed '
          'by Regulation 1215/2012; in Brazil it is the court of the '
          "consumer's domicile, guaranteed by the Consumer Protection Code; "
          'and an equivalent rule exists in much of the world.',
      'Consumers in the European Union may also approach an alternative '
          'dispute resolution body in their own country, provided for by '
          'Directive 2013/11/EU, or the European Consumer Centre for their '
          'region, at eccnet.eu. The European Commission\'s former online '
          'dispute resolution platform was shut down in July 2025 and does '
          'not replace those routes.',
      'Nothing here forces you into arbitration, and there is no waiver of '
          'class action. If you would rather simply talk to us before any of '
          'that, the address is in the last section, and the answer comes '
          'within 30 days.',
    ],
  ),
  PrivacySection(
    title: 'How to reach us',
    body: <String>[
      'Questions, complaints or requests about your data: $privacyEmail.',
      'Controller: $privacyController.',
    ],
  ),
];
