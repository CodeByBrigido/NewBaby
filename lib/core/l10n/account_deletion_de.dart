import 'privacy_policy.dart';

/// Die Seite zur Kontolöschung, auf Deutsch.
const String deletionPageDateDe = '18. August 2026';

const List<PrivacySection> accountDeletionPageDe = <PrivacySection>[
  PrivacySection(
    title: 'Was diese Seite ist',
    body: <String>[
      'Diese Seite erklärt, wie Sie die Löschung Ihres Kontos der App '
          'Meu Bebê: Cápsula do Tempo und aller damit verbundenen Daten '
          'beantragen können.',
      'Sie funktioniert auch, wenn Sie die App bereits deinstalliert '
          'haben. Sie müssen nichts installieren, sich nirgends '
          'registrieren oder anmelden, um das hier zu nutzen.',
      'Das Recht auf Löschung hat je nach Ort verschiedene Namen: '
          'Löschung in der DSGVO (Art. 17) und im UK GDPR, Eliminierung in '
          'der LGPD (Art. 18), Löschung im kalifornischen CCPA, und '
          'gleichwertige Rechte in vielen anderen Rechtsordnungen. Hier ist '
          'der Weg für alle derselbe, und wir machen den Antrag nicht davon '
          'abhängig, welches Land Sie als Wohnsitz angeben.',
      'Verantwortlicher: $privacyController. Kontakt: $privacyEmail',
    ],
  ),
  PrivacySection(
    title: 'Wenn Sie die App noch haben',
    body: <String>[
      'Das ist der schnellste Weg, und der einzige, der alles sofort '
          'löscht, ohne auf jemanden zu warten:',
      '• Öffnen Sie die App und melden Sie sich mit dem zu löschenden '
          'Konto an',
      '• Tippen Sie auf Profil',
      '• Tippen Sie auf „Konto- und Datenlöschung"',
      '• Lesen Sie die Seite, die dieselbe wie hier ist, und tippen Sie '
          'am Ende auf „Zur Kontolöschung"',
      '• Wählen Sie, was mit dem Google-Drive-Ordner geschehen soll',
      '• Tippen Sie auf „Mein Konto und meine Daten löschen" und '
          'bestätigen Sie',
      'Das Lesen kommt absichtlich vor dem Knopf. Das Löschen ist '
          'sofort und kann nicht rückgängig gemacht werden, und niemand '
          'sollte den Knopf erreichen, ohne zu wissen, was bleibt und was '
          'verschwindet.',
      'Zum Drive-Ordner gibt es zwei Optionen: ihn beizubehalten, was '
          'der Standard ist, da die Dateien Ihnen gehören und wir nie eine '
          'Kopie davon hatten; oder ihn in den Papierkorb Ihres Drive zu '
          'verschieben.',
    ],
  ),
  PrivacySection(
    title: 'Wenn Sie die App nicht mehr haben',
    body: <String>[
      'Schreiben Sie an $privacyEmail mit dem Betreff „Mein Konto '
          'löschen".',
      'Die Anfrage muss von der E-Mail-Adresse des Google-Kontos '
          'kommen, mit dem Sie sich bei der App angemeldet haben. Das ist '
          'unsere einzige Möglichkeit, zu wissen, dass die Anfrage von '
          'Ihnen stammt: Ohne diese Prüfung könnte jeder die Sammlung '
          'einer anderen Person löschen, indem er einfach eine E-Mail '
          'schreibt.',
      'Wir antworten an dieselbe Adresse, um die Löschung zu '
          'bestätigen. Kommt die Anfrage von einer anderen Adresse, bitten '
          'wir darum, sie von der Kontoadresse aus erneut zu senden, und '
          'löschen nichts, bevor das geschieht.',
      'Die Anfrage wird ohne unangemessene Verzögerung bearbeitet und, '
          'sofern sie der DSGVO unterliegt, in der Regel innerhalb eines '
          'Monats. Legt eine andere geltende Gesetzgebung eine andere '
          'Frist fest, halten wir die entsprechende gesetzliche Frist ein. '
          'Sie müssen die Anfrage nicht begründen, und wir berechnen keine '
          'Gebühr dafür.',
    ],
  ),
  PrivacySection(
    title: 'Was gelöscht wird',
    body: <String>[
      'Alles, was auf unserem Server über Sie existiert, ohne '
          'Ausnahme:',
      '• Das Profil des Kindes: Name, Geburtsdatum und -uhrzeit, '
          'Geschlecht, Gewicht, Größe und Krankenhaus',
      '• Die gesamte Zeitleiste: Datum, Alter, Titel, Beschreibung und '
          'Typ jeder Erinnerung',
      '• Der vollständige Text der Briefe, der einzige Ihrer Inhalte, '
          'der in unserem Index verbleibt',
      '• Die Kennungen der Drive-Ordner und der Fortschritt der '
          'Vorschläge',
      '• Ihr Authentifizierungskonto, mit der von Google stammenden '
          'E-Mail-Adresse und dem Namen',
      'Die Löschung der Indexdaten und des Authentifizierungskontos '
          'beginnt sofort nach der Bestätigung und kann nach Abschluss '
          'nicht von der App rückgängig gemacht werden. Wir führen keine '
          'operative Sicherung des Index, um ein gelöschtes Konto '
          'wiederherzustellen. Daten, die aufgrund gesetzlicher '
          'Verpflichtung aufbewahrt werden müssen, oder technische '
          'Aufzeichnungen der Google-Infrastruktur können für den '
          'geltenden Zeitraum bestehen bleiben, ohne für damit unvereinbare '
          'Zwecke verwendet zu werden.',
    ],
  ),
  PrivacySection(
    title: 'Was nicht gelöscht wird, und warum',
    body: <String>[
      'Ihre Fotos, Videos, Zeichnungen und Dokumente werden **nicht '
          'gelöscht**, weil sie nie uns gehörten.',
      'Sie befinden sich in einem Ordner namens „Meu Bebê - Cápsula do '
          'Tempo" im Google Drive Ihres eigenen Kontos. Die App hatte nie '
          'eine Kopie davon auf irgendeinem Server: Sie gehen von Ihrem '
          'Gerät direkt in Ihr Drive.',
      'Nach der Löschung des Kontos widerruft die App die Autorisierung, '
          'die für den Zugriff auf die von ihr in Google Drive erstellten '
          'Dateien verwendet wurde. Der verwendete Umfang ist '
          'https://www.googleapis.com/auth/drive.file, der den Zugriff auf '
          'von der App erstellte oder geöffnete Dateien innerhalb der von '
          'Google gewährten Berechtigungen beschränkt. Nach dem Widerruf '
          'hat die App keine Autorisierung mehr, um diese Dateien zu '
          'verwalten. Daher bleiben die Dateien unter der Kontrolle Ihres '
          'Google-Kontos, es sei denn, Sie löschen sie direkt im Drive '
          'oder beantragen, sofern verfügbar, dass die App sie vor der '
          'Kontolöschung in den Papierkorb verschiebt.',
      'Möchten Sie die Dateien auch löschen, tun Sie dies direkt im '
          'Drive, in zwei Schritten:',
      '• Öffnen Sie drive.google.com mit demselben Konto',
      '• Suchen Sie den Ordner „Meu Bebê - Cápsula do Tempo"',
      '• Klicken Sie mit der rechten Maustaste und wählen Sie '
          '„Entfernen"',
      'Möchten Sie lieber beantragen, dass die App den Ordner in den '
          'Papierkorb des Drive verschiebt, tun Sie dies **vor** Abschluss '
          'der Kontolöschung, auf demselben Löschbildschirm. Die '
          'Verfügbarkeit und das endgültige Ergebnis des Vorgangs hängen '
          'von den erteilten Berechtigungen und den Mechanismen von Google '
          'Drive ab.',
    ],
  ),
  PrivacySection(
    title: 'Das Premium-Abonnement wird hier nicht gekündigt',
    body: <String>[
      'Wenn Sie den Premium-Plan abonniert haben, **kündigt das Löschen '
          'des Kontos das Abonnement nicht**. Es sind zwei Dinge an '
          'verschiedenen Orten: Das Konto gehört uns, das Abonnement '
          'gehört Google Play.',
      'Ohne Kündigung dort läuft die jährliche Abbuchung auch nach dem '
          'Löschen der Kapsel weiter. Wir haben keinen Zugriff auf Ihr '
          'Zahlungsmittel und können es nicht für Sie kündigen.',
      'Kündigen Sie es, bevor Sie das Konto löschen, in wenigen '
          'Schritten:',
      '• Öffnen Sie den Google Play Store',
      '• Tippen Sie oben rechts auf Ihr Foto',
      '• Gehen Sie zu „Zahlungen und Abos" und dann zu „Abos"',
      '• Wählen Sie Meu Bebê: Cápsula do Tempo und tippen Sie auf '
          '„Abo kündigen"',
      'Nach der Kündigung bleibt Premium normalerweise bis zum Ende des '
          'bereits bezahlten Zeitraums gültig. Löschen Sie das Konto '
          'vorher, endet der mit diesem Konto verbundene Premium-Zugang '
          'mit der Löschung des Kontos. Wir bieten keine anteilige '
          'Rückerstattung aus eigener Initiative an, außer wenn dies durch '
          'geltendes Recht oder die Rückerstattungsrichtlinien von Google '
          'Play vorgeschrieben ist.',
    ],
  ),
  PrivacySection(
    title: 'Nur einen Teil löschen',
    body: <String>[
      'Sie müssen nicht das gesamte Konto löschen, um etwas zu löschen.',
      'In der App kann jede Erinnerung einzeln in den Papierkorb '
          'verschoben und endgültig gelöscht werden. Das Profil des '
          'Kindes kann jederzeit bearbeitet werden. Nichts davon läuft '
          'über uns oder erfordert einen Antrag.',
      'Möchten Sie die App einfach nicht mehr nutzen, ohne etwas zu '
          'löschen, genügt es, sich unter Profil abzumelden: Die Daten auf '
          'dem Gerät werden beim Abmelden gelöscht, und die Sammlung in '
          'Ihrem Drive bleibt, wo sie ist.',
    ],
  ),
  PrivacySection(
    title: 'Ein Konto pro Kind',
    body: <String>[
      'Die App verwendet ein Google-Konto pro Kind, damit eines Tages '
          'jedes seine eigene vollständige Kapsel erhält.',
      'Das bedeutet, dass das Löschen eines Kontos die Kapsel dieses '
          'Kindes löscht, und nur dessen. Nutzen Sie mehrere Konten, muss '
          'die Anfrage für jedes einzeln gestellt werden, von der E-Mail '
          'jedes Kontos aus.',
      'Das Premium-Abonnement gilt ebenfalls pro Konto. Das Löschen der '
          'Kapsel eines Kindes betrifft nicht das Abonnement der anderen, '
          'und jedes bleibt unabhängig gültig oder wird unabhängig '
          'gekündigt.',
    ],
  ),
  PrivacySection(
    title: 'Technische Aufzeichnungen',
    body: <String>[
      'Die Infrastruktur, die den Index hostet, nutzt Dienste von '
          'Firebase und Google Cloud. Wie jeder Cloud-Dienst können diese '
          'Dienste technische und betriebliche Aufzeichnungen führen, die '
          'für Sicherheit, Betrieb, Missbrauchsprävention und Audit '
          'notwendig sind, vorbehaltlich der geltenden '
          'Aufbewahrungsrichtlinien von Google.',
      'Diese Infrastrukturaufzeichnungen sind nicht Teil des Index, den '
          'wir zum Betrieb Ihrer Kapsel führen, und werden von uns nicht '
          'verwendet, um gelöschte Inhalte zu rekonstruieren. Einige '
          'technische Aufzeichnungen können für von Google oder durch '
          'geltendes Recht bestimmte Zeiträume bestehen bleiben. Deshalb '
          'versprechen wir nicht, dass nach der Löschung absolut keine '
          'technische Aufzeichnung in irgendeinem Infrastruktursystem mehr '
          'existieren kann.',
    ],
  ),
];
