import 'privacy_policy.dart';

/// The account deletion page, in English.
///
/// Mesma estrutura da portuguesa, seção por seção: o teste que confere a
/// ordem das seções vale para as duas, e o revisor da Play Store precisa
/// encontrar as mesmas coisas nos mesmos lugares.
const List<PrivacySection> accountDeletionPageEn = <PrivacySection>[
  PrivacySection(
    title: 'What this page is',
    body: <String>[
      'This page explains how to request deletion of your Meu Bebê: '
          'Cápsula do Tempo account and all the data attached to it.',
      'It exists so that it works even if you have already uninstalled the '
          'app. You do not need to install anything, create an account or '
          'sign in anywhere to use what is here.',
      'The right to erasure has different names in different places: '
          'erasure under the GDPR (Art. 17) and the UK GDPR, elimination '
          'under the LGPD (Art. 18), deletion under California\'s CCPA, and '
          'equivalent rights in several other jurisdictions. Here the path is '
          'the same for everyone, and we do not make the request conditional '
          'on telling us where you live.',
      'Controller: $privacyController. Contact: $privacyEmail',
    ],
  ),
  PrivacySection(
    title: 'If you still have the app',
    body: <String>[
      'This is the fastest path, and the only one that deletes everything on '
          'the spot, without waiting for anyone:',
      '• Open the app and sign in with the account you want to delete',
      '• Tap Profile',
      '• Tap "Exclusão de conta e de dados" (Account and data deletion)',
      '• Read the page, which is this same one, and tap "Ir para a exclusão '
          'da conta" (Go to account deletion) at the bottom',
      '• Choose what to do with the Google Drive folder',
      '• Tap "Apagar minha conta e meus dados" (Delete my account and my '
          'data) and confirm',
      'The reading comes before the button on purpose. Deleting is immediate '
          'and cannot be undone, and nobody should reach the button without '
          'knowing what stays and what goes.',
      'About the Drive folder, there are two options: keep it, which is the '
          'default, because the files are yours and we never had a copy; or '
          'move it to your Drive trash.',
    ],
  ),
  PrivacySection(
    title: 'If you no longer have the app',
    body: <String>[
      'Write to $privacyEmail with the subject "Excluir minha conta" '
          '(Delete my account).',
      'The request must come from the email address of the Google account '
          'you used to sign in. It is the only way for us to know the request '
          'is yours: without that check, anyone could delete someone '
          'else\'s archive by sending an email.',
      'We reply to that same address confirming the deletion. If the '
          'request arrives from another address, we will ask for it to be '
          'sent again from the account address, and we will not delete '
          'anything until that happens.',
      'The request is handled without undue delay and, where the GDPR '
          'applies, as a rule within one month. Where other applicable law '
          'sets a different deadline, we observe that legal deadline. You do '
          'not need to justify the request, and we do not charge for a '
          'deletion request.',
    ],
  ),
  PrivacySection(
    title: 'What is deleted',
    body: <String>[
      'Everything of yours on our server, without exception:',
      '• The child profile: name, date and time of birth, sex, weight, '
          'length and hospital',
      '• The whole timeline: the date, the age, the title, the description '
          'and the type of every memory',
      '• The full text of the letters, which is the only content of yours '
          'that lives in our index',
      '• The Drive folder identifiers and the progress of the '
          'suggestions',
      '• Your authentication account, with the email and name from '
          'Google',
      'Deletion of the index data and of the authentication account starts '
          'immediately after confirmation and, once complete, cannot be '
          'undone by the app. We keep no operational backup of the index to '
          'restore a deleted account. Data that must be kept under a legal '
          'obligation, or technical records held by Google\'s '
          'infrastructure, may remain for the applicable period, without '
          'being used for incompatible purposes.',
    ],
  ),
  PrivacySection(
    title: 'What is not deleted, and why',
    body: <String>[
      'Your photos, videos, drawings and documents are **not deleted**, '
          'because they were never ours.',
      'They live in a folder in the Google Drive of your own account. The '
          'app never had a copy of them on any server: they go from your '
          'device straight to your Drive.',
      'After the account is deleted, the app revokes the authorisation it '
          'used to access the files it created in Google Drive. The scope '
          'used is https://www.googleapis.com/auth/drive.file, which limits '
          'access to files created or opened by the app within the '
          'permissions granted by Google. After revocation, the app no longer '
          'has authorisation to operate on those files. The files therefore '
          'remain under the control of your Google account, unless you choose '
          'to delete them directly in Drive or, where available, ask the app '
          'to send them to the trash before the account is deleted.',
      'If you also want to delete the files, do it directly in Drive, and '
          'it takes two taps:',
      '• Open drive.google.com with the same account',
      '• Find the capsule folder, named "Meu Bebê - Cápsula do Tempo" or '
          '"My Baby - Time Capsule" depending on the language the capsule was '
          'created in',
      '• Right-click and choose "Remove"',
      'If you would rather ask the app to send the folder to the Drive '
          'trash, do it **before** completing the account deletion, on the '
          'same deletion screen. Availability and the final outcome of the '
          'operation depend on the permissions granted and on Google Drive\'s '
          'mechanisms.',
    ],
  ),
  PrivacySection(
    title: 'The Premium subscription is not cancelled here',
    body: <String>[
      'If you subscribe to Premium, **deleting the account does not cancel '
          'the subscription**. They are two things in different places: the '
          'account is ours, the subscription is Google Play\'s.',
      'Without cancelling there, the yearly charge keeps happening even '
          'after the capsule has been deleted. We have no access to your '
          'payment method and cannot cancel for you.',
      'Cancel before deleting the account, and it takes a few taps:',
      '• Open the Google Play Store',
      '• Tap your photo, top right',
      '• Go to "Payments and subscriptions" and then "Subscriptions"',
      '• Choose Meu Bebê: Cápsula do Tempo and tap "Cancel subscription"',
      'Once cancelled, Premium normally stays valid until the end of the '
          'period already paid for. If you delete the account before that, '
          'the Premium access tied to that account ends when the account is '
          'deleted. We do not offer a pro rata refund on our own initiative, '
          'except where required by applicable law or by Google Play refund '
          'policies.',
    ],
  ),
  PrivacySection(
    title: 'Deleting only part of it',
    body: <String>[
      'You do not need to delete the whole account to delete something.',
      'Inside the app, any memory can go to the trash and be deleted for '
          'good, one by one. The child profile can be edited at any time. '
          'None of that goes through us or depends on a request.',
      'If what you want is to stop using the app without deleting anything, '
          'just sign out in Profile: the data on the device is cleared on the '
          'way out, and the archive in your Drive stays where it is.',
    ],
  ),
  PrivacySection(
    title: 'One account per child',
    body: <String>[
      'The app uses one Google account per child, so that one day each of '
          'them receives their own whole capsule.',
      'That means deleting one account deletes that child\'s capsule, and '
          'only theirs. If you use more than one account, the request has to '
          'be made once for each, from the email of each one.',
      'The Premium subscription is also per account. Deleting one child\'s '
          'capsule does not touch the subscription of the others, and each '
          'one carries on, or is cancelled, on its own.',
    ],
  ),
  PrivacySection(
    title: 'Technical logs',
    body: <String>[
      'The infrastructure hosting the index uses Firebase and Google Cloud '
          'services. Like any cloud service, those services may keep '
          'technical and operational records needed for security, operation, '
          'abuse prevention and auditing, subject to Google\'s applicable '
          'retention policies.',
      'Those infrastructure records are not part of the index we keep to '
          'run your capsule, and we do not use them to reconstruct deleted '
          'content. Some technical records may remain for periods determined '
          'by Google or by applicable legal obligations. For that reason, we '
          'do not promise that absolutely no technical record can exist in '
          'every infrastructure system after deletion.',
    ],
  ),
];
