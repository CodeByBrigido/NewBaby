import 'account_deletion.dart';
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
      'This page explains how to request deletion of your Meu Bebê: Cápsula '
          'do Tempo account and all the data attached to it.',
      'It exists so that it works even if you have already uninstalled the '
          'app. You do not need to install anything, create an account or '
          'sign in anywhere to use what is here.',
      'The right to erasure has different names in different places: erasure '
          'under the GDPR (Art. 17) and the UK GDPR, elimination under '
          "Brazil's LGPD (Art. 18), deletion under California's CCPA, and "
          'equivalents in Canada, Australia, Switzerland and many other '
          'countries. Here the path is the same for everyone, and we do not '
          'ask where you live before deleting.',
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
          'is yours: without that check, anyone could delete someone else\'s '
          'archive by sending an email.',
      'We reply to that same address confirming the deletion. If the request '
          'arrives from another address, we will ask for it to be sent again '
          'from the account address, and we will not delete anything until '
          'that happens.',
      'The maximum is $deletionDeadlineDays days, and in practice it takes a '
          'few. You do not need to justify the request, and it costs nothing.',
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
      '• The Drive folder identifiers and the progress of the suggestions',
      '• Your authentication account, with the email and name from Google',
      'Deletion is immediate and irreversible. We keep no backup of your '
          'data afterwards, and there is no grace period in which it could be '
          'recovered.',
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
      'Once the account is deleted, we lose any access to that folder. The '
          'permission the app asks Google for is the narrowest that exists '
          '(https://www.googleapis.com/auth/drive.file), it reaches only '
          'files the app itself created, and it is revoked on deletion. It is '
          'not a choice of ours: after that there is no way to delete them '
          'even if you ask.',
      'If you also want to delete the files, do it directly in Drive, and it '
          'takes two taps:',
      '• Open drive.google.com with the same account',
      '• Find the capsule folder, named "Meu Bebê - Cápsula do Tempo" or '
          '"My Baby - Time Capsule" depending on the language the capsule was '
          'created in',
      '• Right-click and choose "Remove"',
      'If you prefer to delete the folder from the app, do it **before** '
          'deleting the account, on the same deletion screen: there is an '
          'option there to move the folder to the Drive trash.',
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
      'Once cancelled, Premium stays valid until the end of the period you '
          'already paid for. If you delete the account before that, the '
          'remaining time is lost, and there is no pro rata refund for it.',
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
      'The infrastructure hosting the index is Firebase, from Google. Like '
          'any cloud service, it keeps operational access logs, subject to '
          "Google's own retention policy.",
      'Those logs do not contain the content of your memories, and we neither '
          'consult nor export them. We say this here because promising '
          '"nothing remains anywhere" would be a promise outside our control.',
    ],
  ),
];
