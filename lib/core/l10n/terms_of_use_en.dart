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
      'The app is for keeping a record of a child\'s early years. It '
          'stores media files and documents directly in the Google Drive of '
          'the account you authorise, and not on a server of our own.',
      'There are two plans. On Basic, which is free, you read everything '
          'you have already kept and carry on keeping photos and videos. '
          'Premium, a yearly subscription, adds keeping letters, drawings, '
          'documents and growth records.',
      'The content is yours. We do not look at it, use it or sell any of '
          'what you keep.',
      'You must be at least $idadeMinima, or the age of majority where you '
          'live if that is higher, and be responsible for the child to create '
          'the account.',
      'The app does not replace an independent backup, nor medical, '
          'psychological or legal advice.',
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
      'It is an organiser, not a storage service of its own: the space '
          'used is that of the Google account you authorise. The storage '
          'rules, space limits and charges that apply to Google Drive are '
          'Google\'s.',
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
      'The subscription applies to the account that signs in to the app, '
          'not to the device nor to the person who made the payment. If the '
          'app uses separate accounts for different children, the '
          'availability of Premium is determined by the account and its '
          'corresponding subscription, according to the service configuration '
          'in force.',
      'Going without the subscription never closes anything that is '
          'already yours. At the end of the paid period the app returns to '
          'Basic: the letters, drawings, documents and measurements you '
          'already kept stay in plain view, and the files stay in the '
          'child\'s Google Drive. What stops is keeping new things of those '
          'four kinds.',
    ],
  ),
  PrivacySection(
    title: 'The subscription, the payment and cancelling',
    body: <String>[
      'The subscription purchase is processed by Google Play, not by the '
          'app. The price and the conditions that apply appear in Google Play '
          'before the purchase is confirmed.',
      'The subscription is yearly and renews on its own, through the '
          'Google Play account that made the purchase, until you cancel it.',
      'Cancelling or changing the subscription is done in Google Play, '
          'under Payments and subscriptions. A refund request also follows '
          'the applicable Google Play mechanisms and policies. We have no '
          'access to your payment method details and cannot change a charge '
          'directly on your behalf.',
      'On cancelling, access to Premium normally continues until the end '
          'of the period already paid for. We do not offer a pro rata refund '
          'on our own initiative, except where required by applicable law or '
          'by Google Play refund policies. Mandatory consumer rights are not '
          'set aside by these Terms.',
      'If the price changes, the change applies to later renewals, and '
          'Google Play gives notice beforehand, by the route it uses for '
          'that. You can cancel before the renewal happens.',
      'Where applicable law gives the consumer a right of withdrawal or '
          'cancellation, that right prevails over any provision of these '
          'Terms. In the European Union and the United Kingdom the general '
          'statutory period for distance contracts is 14 days, subject to the '
          'rules and exceptions applicable to the type of service or digital '
          'content contracted. In Brazil, the Consumer Protection Code '
          'provides, as a rule, 7 days for contracts entered into away from '
          'business premises. Other countries may set their own periods and '
          'conditions. A cancellation or refund request should follow the '
          'applicable channel indicated by Google Play, without prejudice to '
          'the consumer\'s legal rights.',
      'Deleting the account inside the app does not cancel the '
          'subscription. They are separate things: one is ours, the other is '
          'Google Play\'s. Cancel there too, or the billing continues.',
    ],
  ),
  PrivacySection(
    title: 'Who can use it',
    body: <String>[
      'To create an account you declare that you are at least '
          '$idadeMinima, or the minimum legal age applicable in the country '
          'where you live if that is higher, and that you are the mother, '
          'father or guardian of the child whose data you are going to '
          'record, or that you hold adequate authorisation to do so.',
      'This is not a mere formality. Data relating to children may receive '
          'heightened protection under different laws, among them the LGPD in '
          'Brazil, the GDPR in the European Union, the UK GDPR in the United '
          'Kingdom and, in certain situations, COPPA in the United States. '
          'The user must have adequate authority to provide the child\'s data '
          'and to use the app for that purpose.',
      'The app is not for the child to use while she is a child. It is '
          'written for whoever is recording today, and made to be handed to '
          'her when she is an adult.',
    ],
  ),
  PrivacySection(
    title: 'The account and access',
    body: <String>[
      'You sign in with a Google account. You are responsible for keeping '
          'that account secure and for controlling who has access to the '
          'device where the app is installed.',
      'The app requests the Google Drive access scope intended for the '
          'files it creates itself. Within that scope, it does not request '
          'general access to the pre-existing files in your account.',
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
      'Use the app for commercial purposes, to provide the service to '
          'third parties without authorisation, or to record a child\'s data '
          'without holding adequate authority to do so. The app is intended '
          'for personal and family use. The legal characterisation of the '
          'activities carried out by the user depends on applicable law; '
          'these Terms do not purport to declare that the user is '
          'automatically exempt from any legal data protection obligation.',
      'Use the app to keep, solicit, produce or distribute illegal '
          'content, especially material of sexual abuse or exploitation of '
          'children and adolescents.',
      'Use the app to violate the privacy of third parties or to keep '
          'content about people who did not consent.',
      'Try to get around the app\'s protections, access data from other '
          'accounts, or interfere with the running of the service.',
      'On discovering any of these, we may terminate access to the app. We '
          'have no way to delete what is in someone else\'s Drive, and '
          'reports of crime go to the authorities.',
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
      'To the maximum extent permitted by applicable law, we will not be '
          'liable for lost profits, indirect or consequential damages arising '
          'from the use of or inability to use the app. This does not limit '
          'liabilities that cannot legally be excluded or limited.',
      'Nothing in this section excludes or limits liability where such '
          'exclusion or limitation is prohibited by applicable law. In '
          'particular, these Terms do not purport to exclude liability for '
          'death or personal injury where the law does not allow it, nor '
          'consumer rights or other rights that are legally non-waivable. If '
          'a given limitation is not valid in your jurisdiction, it applies '
          'only to the extent permitted, and the remaining provisions of '
          'these Terms remain in force.',
    ],
  ),
  PrivacySection(
    title: 'If you want to stop',
    body: <String>[
      'You can sign out, uninstall the app or request deletion of the '
          'account and the data at any time, without giving a reason and at '
          'no charge for that request, save for any legal retention '
          'obligations.',
      'The path is described on the account deletion page, and it works '
          'even for someone who has already uninstalled the app.',
      'If you have Premium, remember to cancel the subscription in Google '
          'Play as well. Deleting the account here does not cancel it '
          'there.',
      'We may suspend or terminate access to the account where there is a '
          'material breach of these Terms, illegal use, a security risk, or '
          'where the service ceases to be offered. Where termination follows '
          'a planned decision to discontinue the service, we will try to give '
          'reasonable notice where possible. Because the files are stored in '
          'your Google Drive, they are not automatically deleted when the app '
          'ends, although certain organising or reading features may stop '
          'working.',
    ],
  ),
  PrivacySection(
    title: 'Changes to these terms',
    body: <String>[
      'These terms may change when the app changes. The date at the top of '
          'this page says which version you are reading.',
      'Every version of the app carries the terms of that version inside '
          'it, so the text you read when you installed is still there, even '
          'if what is published is now different.',
      'Where a material change requires fresh consent or a specific notice '
          'under applicable law, it will be presented appropriately before it '
          'takes effect. For other changes, continuing to use the app after '
          'the new version is published may mean acceptance of the updated '
          'Terms. If you do not agree with a change that applies to you, you '
          'may stop using the app and request deletion of the account, '
          'subject to any legal rights that apply.',
    ],
  ),
  PrivacySection(
    title: 'Where the app is offered',
    body: <String>[
      'The app is distributed through Google Play and can be used in any '
          'country where the store offers it. The interface and these '
          'documents exist in Portuguese and in English.',
      'The publisher is an individual established in Ireland, not a '
          'company incorporated in every country where the app may be '
          'available. This does not purport to reduce mandatory consumer or '
          'data protection rights. The law applicable to the relationship may '
          'depend on the consumer\'s country of residence and on '
          'conflict-of-laws rules.',
      'Availability of the app may vary according to applicable laws, '
          'sanctions, Google Play policies and distribution restrictions.',
      'The app may not be made available in certain countries or regions '
          'where local law, data localisation requirements, sanctions or the '
          'technical conditions of the cloud services used legitimately '
          'prevent its operation. The architecture of the app depends on '
          'Google\'s global infrastructure and may not meet local '
          'requirements demanding storage exclusively inside a given '
          'jurisdiction.',
    ],
  ),
  PrivacySection(
    title: 'Applicable law and where to complain',
    body: <String>[
      'These Terms are governed by Irish law, without prejudice to '
          'mandatory consumer protection rules and other mandatory rules that '
          'apply to your relationship with the app.',
      'Where conflict-of-laws rules determine that the law of the '
          'consumer\'s country of habitual residence applies, or where there '
          'are mandatory rights that cannot be set aside by contract, those '
          'rights prevail over any provision of these Terms that is '
          'incompatible with them.',
      'Where applicable law gives the consumer the right to bring '
          'proceedings before the courts of their country or place of '
          'residence, that right is preserved. In the European Union, '
          'specific rules of jurisdiction protect consumers in certain '
          'circumstances. In Brazil, the Consumer Protection Code also '
          'provides protection as to the consumer\'s forum, as applicable to '
          'the case.',
      'Consumers in the European Union may, where available and applicable '
          'to the type of dispute, use the national alternative dispute '
          'resolution mechanisms provided for by the law of their country, or '
          'approach the competent European Consumer Centre. The former '
          'European online dispute resolution platform has been shut down and '
          'is not indicated as a channel.',
      'Nothing here forces you into arbitration or purports to prevent the '
          'exercise of procedural rights guaranteed by applicable law. If you '
          'would rather talk to us before taking any other step, the address '
          'is in the last section. We will try to reply without undue delay '
          'and, where the request concerns data protection rights, we will '
          'observe the deadlines set by applicable law.',
    ],
  ),
  PrivacySection(
    title: 'How to reach us',
    body: <String>[
      'Questions, complaints or requests about the app or about your data: '
          '$privacyEmail.',
      'Responsible: $privacyController.',
    ],
  ),
];
