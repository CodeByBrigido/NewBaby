import 'privacy_policy.dart';

/// Die Datenschutzerklärung, auf Deutsch.
///
/// Getreu aus dem Portugiesischen übersetzt, Abschnitt für Abschnitt und
/// Absatz für Absatz, damit keine Zusage in einer Sprache schwächer klingt
/// als in einer anderen.
/// Das auf der öffentlichen Seite angezeigte Datum.
const String privacyPolicyDateDe = '18. August 2026';

const List<PrivacySection> privacyPolicyDe = <PrivacySection>[
  PrivacySection(
    title: 'Kurz gesagt',
    body: <String>[
      'Fotos, Videos und Dokumente laufen niemals über einen Server von '
          'uns: Sie gehen direkt von Ihrem Gerät zum Google Drive Ihres '
          'eigenen Kontos.',
      'Die App speichert auf einem Server nur einen Textindex, der die '
          'Zeitleiste und die Suche funktionieren lässt.',
      'Es gibt keine Werbung, kein Tracking, kein Profiling und keinen '
          'Verkauf von Daten.',
      'Das Premium-Abonnement wird von Google Play abgerechnet. Kein '
          'Zahlungsdatum läuft über uns.',
      'Sie löschen all das jederzeit selbst, innerhalb der App, ohne '
          'jemanden fragen zu müssen.',
    ],
  ),
  PrivacySection(
    title: 'Wer verantwortlich ist',
    body: <String>[
      'Verantwortlicher für die Verarbeitung der personenbezogenen Daten '
          '(Verantwortlicher im Sinne von Art. 4(7) DSGVO): '
          '$privacyController, natürliche Person, Einzelentwickler, '
          'niedergelassen in Irland.',
      'Da der für die App Verantwortliche in Irland niedergelassen ist, '
          'gilt die DSGVO für die von ihrem Anwendungsbereich erfassten '
          'Verarbeitungen. Bei Anwendbarkeit des One-Stop-Shop-Mechanismus '
          'für grenzüberschreitende Verarbeitungen wird die federführende '
          'Aufsichtsbehörde gemäß Art. 56 DSGVO bestimmt. Sie können auch '
          'eine Beschwerde bei der Datenschutzbehörde des Landes einreichen, '
          'in dem Sie wohnen oder arbeiten, oder des Ortes, an dem der '
          'mutmaßliche Verstoß stattgefunden hat.',
      'Kontakt: $privacyEmail',
      'Jede Anfrage zu personenbezogenen Daten kann an diese Adresse '
          'gesendet werden. Wir antworten unverzüglich und in der Regel '
          'innerhalb eines Monats, gemäß Art. 12(3) DSGVO. Wenn das Gesetz '
          'eine Verlängerung dieser Frist erlaubt, informieren wir Sie '
          'innerhalb des ersten Monats und erläutern die Gründe.',
    ],
  ),
  PrivacySection(
    title: 'Ihre Rolle und unsere',
    body: <String>[
      'Wenn eine Person die App ausschließlich nutzt, um Erinnerungen an '
          'die eigene Familie zu erfassen und aufzubewahren, kann diese '
          'Nutzung unter die Ausnahme für ausschließlich persönliche oder '
          'familiäre Tätigkeiten nach Art. 2(2)(c) DSGVO fallen. Diese '
          'Ausnahme betrifft die Anwendung der DSGVO auf die von der Person '
          'selbst durchgeführte Verarbeitung und ändert nichts an den '
          'Verantwortlichkeiten, die der App hinsichtlich der von ihr selbst '
          'verarbeiteten personenbezogenen Daten obliegen können.',
      'Die App ist für diese Nutzung gedacht: persönlich und familiär, '
          'ohne kommerziellen Zweck. Sie zu nutzen, um Kinder zu erfassen, '
          'die nicht Ihre eigenen sind oder nicht in Ihrer rechtlichen '
          'Verantwortung stehen, oder um diesen Dienst Dritten anzubieten, '
          'geht über das hinaus, was die Pläne abdecken.',
      'Wir haben je nach Datum und beteiligtem Dienst unterschiedliche '
          'Verantwortlichkeiten. Für den Index, den wir zum Betrieb der App '
          'führen, wie Profil, Zeitleiste und Brieftext, sind wir '
          'verantwortlich für die Festlegung der Zwecke und wesentlichen '
          'Mittel dieser Verarbeitung und handeln, sofern die DSGVO '
          'anwendbar ist, als Verantwortlicher für diese Daten. Für Dateien, '
          'die direkt an das Google-Drive-Konto des Nutzers gesendet werden, '
          'erhält die App keine Kopie dieser Dateien und speichert sie nicht '
          'auf eigenen Servern. Die Nutzung von Google Drive unterliegt '
          'zudem den Bedingungen und der Datenschutzerklärung von Google. '
          'Unsere App agiert ausschließlich innerhalb der vom Nutzer '
          'erteilten Berechtigungen.',
    ],
  ),
  PrivacySection(
    title: 'Was in Ihrem Google Drive bleibt',
    body: <String>[
      'Bei der Anmeldung autorisieren Sie die App, das Google Drive '
          'Ihres Kontos mit dem Umfang drive.file zu verwenden. Dieser '
          'Umfang gewährt nur Zugriff auf Dateien, die die App selbst '
          'erstellt. Er erlaubt weder das Lesen, Auflisten noch Ändern '
          'anderer Dateien in Ihrem Drive, und diese Einschränkung wird von '
          'Google auferlegt, nicht von uns.',
      'In Ihrem Drive bleiben, im Ordner „Meu Bebê - Cápsula do Tempo": '
          'die Fotos, Videos, Zeichnungen und Dokumente, die Sie hochladen.',
      'Außerdem bleiben zwei von der App geschriebene Textdateien: eine '
          'mit dem Profil und den Wachstumseinträgen, und eine für jeden '
          'Brief, den Sie schreiben. Sie existieren, damit diese Sammlung '
          'auch ohne die App weiterhin Sinn ergibt: Ein Foto erklärt sich '
          'in einem Ordner von selbst, ein Brief und ein Gewichtseintrag '
          'nicht.',
      'Diese Dateien gehören Ihnen. Wir haben keine Kopie davon, können '
          'sie nicht sehen und haben kein technisches Mittel, um außerhalb '
          'der in Ihrer Sitzung verwendeten App darauf zuzugreifen.',
      'GPS-Koordinaten werden vor dem Hochladen aus jedem Foto entfernt.',
    ],
  ),
  PrivacySection(
    title: 'Was in unserem Index bleibt',
    body: <String>[
      'Der Index befindet sich auf Cloud Firestore, einem Dienst von '
          'Google Cloud. Dies ist die vollständige Liste dessen, was er '
          'speichert:',
      '• Vom Profil: Name des Kindes, Geburtsdatum, angegebenes '
          'Geschlecht, Geburtsgewicht und -größe, Name des Krankenhauses, '
          'falls angegeben, und die Kennung des Stammordners in Ihrem '
          'Drive.',
      '• Vom Plan: ein einzelner Wert, ja oder nein, der angibt, ob das '
          'Konto das Premium-Abonnement hat. Nichts weiteres zur Zahlung '
          'läuft hierüber.',
      '• Von jeder Erinnerung: Typ, Datum, Alter in Tagen, Titel, '
          'Beschreibung und, bei Briefen, der vollständige Brieftext; '
          'Gewicht und Größe der Wachstumseinträge; das Öffnungsdatum, wenn '
          'die Erinnerung versiegelt ist; sowie Kennung, Name, Typ und '
          'Größe jeder Datei in Ihrem Drive.',
      '• Unterstützende Daten: der Zwischenspeicher der Kennungen der im '
          'Drive erstellten Ordner und der Fortschritt der von Ihnen '
          'markierten Vorschläge.',
      '• Von der Authentifizierung: Firebase Authentication speichert '
          'Ihre Nutzerkennung, Ihre E-Mail-Adresse, Ihren Namen und die '
          'Adresse Ihres Google-Profilfotos.',
      'Jeder Index ist pro Konto isoliert. Sicherheitsregeln auf dem '
          'Server verhindern, dass ein Konto die Daten eines anderen liest '
          'oder schreibt, und diese Regeln werden bei jeder Änderung der '
          'App durch automatisierte Tests überprüft.',
    ],
  ),
  PrivacySection(
    title: 'Die Zahlung des Abonnements',
    body: <String>[
      'Das Premium-Abonnement wird von Google Play abgerechnet, nicht '
          'von uns. Karte, Rechnungsadresse, Rechnung und Kaufverlauf '
          'bleiben dort, unter deren Datenschutzerklärung.',
      'Wir erhalten, sehen und speichern keine Zahlungsdaten. Auf '
          'unserer Seite bleibt nur der oben beschriebene Ja-Nein-Wert im '
          'Index dieses Kontos, der der App mitteilt, ob sie das Speichern '
          'von Briefen, Zeichnungen, Dokumenten und Wachstumseinträgen '
          'freigeben soll.',
      'Da das Abonnement pro Konto gilt und jedes Kind sein eigenes '
          'Google-Konto hat, wird dieser Wert niemals zwischen Konten '
          'verglichen oder verwendet, um ein Konto mit einem anderen zu '
          'verknüpfen.',
    ],
  ),
  PrivacySection(
    title: 'Was das Gerät niemals verlässt',
    body: <String>[
      'Erinnerungseinstellungen, die Markierung, dass die '
          'Einführungspräsentation bereits gesehen wurde, bereits gesehene '
          'und gelesene Ideen, die Präferenz für die biometrische Sperre '
          'und der Zwischenspeicher der Fotominiaturen.',
      'Nichts davon wird irgendwohin gesendet. Es verlässt das Gerät, '
          'wenn Sie sich abmelden oder die App deinstallieren.',
    ],
  ),
  PrivacySection(
    title: 'Was nicht erhoben wird',
    body: <String>[
      'Dies ist eine abschließende Liste:',
      '• Keine Nutzungsdaten, Statistiken oder Analysen. Die App hat '
          'weder Google Analytics, Firebase Analytics, Crashlytics noch ein '
          'vergleichbares Werkzeug.',
      '• Keine Werbung und keine Werbekennung.',
      '• Kein Profiling und keine automatisierte Entscheidung über Sie.',
      '• Kein Standort, keine Kontakte, kein Kalender, kein Mikrofon im '
          'Hintergrund und kein Browserverlauf.',
      '• Kein Verkauf, keine Vermietung und kein Austausch von Daten mit '
          'Dritten, unter keinen Umständen.',
      '• Keine Benachrichtigung von einem Server. Erinnerungen werden '
          'direkt auf dem Gerät berechnet und geplant.',
      'Sollte sich dies in einer künftigen Version ändern, ändert sich '
          'zuerst diese Erklärung, und der Hinweis erscheint in der App.',
    ],
  ),
  PrivacySection(
    title: 'Mit wem die Daten geteilt werden',
    body: <String>[
      'Die Daten werden mit Google-Diensten geteilt oder von ihnen '
          'verarbeitet, die für bestimmte Funktionen der App notwendig '
          'sind:',
      '• Google Sign-In, für die Anmeldung an Ihrem Konto.',
      '• Firebase Authentication, um die Sitzung aufrechtzuerhalten.',
      '• Cloud Firestore, um den Index zu speichern.',
      '• Google Drive, um Ihre Dateien in Ihrem eigenen Konto zu '
          'speichern.',
      '• Google Play, um das Premium-Abonnement abzurechnen und für '
          'Abonnenten anzuzeigen, ob es aktiv ist.',
      'Es gibt keinen weiteren von uns gewählten Empfänger. Wir nutzen '
          'kein Werbenetzwerk, keinen Datenhändler und keinen '
          'Analysedienst.',
      'Das auf jeden Google-Dienst anwendbare Rechtsverhältnis hängt vom '
          'genutzten Produkt, der Kontokonfiguration und den entsprechenden '
          'Vertragsbedingungen ab. Wenn Google als Auftragsverarbeiter für '
          'die von uns durchgeführte Verarbeitung handelt, richtet sich '
          'diese Verarbeitung nach dem anwendbaren Vertragsinstrument, '
          'einschließlich der Datenschutzbedingungen von Google '
          'Cloud/Firebase. Bei Diensten, bei denen Google im eigenen Namen '
          'oder direkt gegenüber dem Nutzer handelt, gelten zusätzlich die '
          'Bedingungen und die Datenschutzerklärung von Google.',
      'Die Verarbeitung durch Google wird in dessen Datenschutzerklärung '
          'beschrieben: policies.google.com/privacy',
    ],
  ),
  PrivacySection(
    title: 'Rechtsgrundlage jeder Verarbeitung',
    body: <String>[
      '• Profil, Index, Authentifizierung und wesentlicher Kontobetrieb: '
          'Vertragserfüllung, Art. 6(1)(b) DSGVO, sofern diese Verarbeitung '
          'zur Bereitstellung der angeforderten Funktionalität notwendig '
          'ist.',
      '• Erinnerungsbenachrichtigungen: Einwilligung, Art. 6(1)(a), '
          'jederzeit widerrufbar in den Einstellungen.',
      '• Erfassung des gebuchten Plans: Vertragserfüllung, Art. '
          '6(1)(b), soweit notwendig, um das Abonnement zu verwalten und '
          'die entsprechenden Funktionen freizuschalten.',
      '• Hochladen und Speichern von Dateien auf Google Drive: vom '
          'Nutzer angeforderter Vorgang, ausgeführt über die Google Drive '
          'erteilte Autorisierung, ohne dass die App eine eigene Kopie '
          'dieser Dateien vorhält.',
      'Wir stützen die in dieser Erklärung beschriebenen Verarbeitungen '
          'nicht auf berechtigtes Interesse. Erfordert eine gesetzliche '
          'Pflicht die Aufbewahrung bestimmter Daten nach Löschung des '
          'Kontos, können diese Daten für die gesetzlich vorgeschriebene '
          'Dauer aufbewahrt werden.',
    ],
  ),
  PrivacySection(
    title: 'Daten eines Kindes',
    body: <String>[
      'Die App speichert Daten über ein Kind, ist aber nicht für Kinder '
          'bestimmt und wird nicht von ihnen genutzt. Wer installiert, '
          'registriert und Inhalte hochlädt, ist die Mutter, der Vater oder '
          'der gesetzliche Vertreter, volljährig.',
      'Bei der Registrierung eines Kindes erklären Sie, dessen '
          'gesetzlicher Vertreter zu sein und zur Bereitstellung dieser '
          'Daten befugt zu sein.',
      'Es gibt keine öffentliche Registrierung, kein sichtbares Profil, '
          'kein soziales Netzwerk, keine Kommentare, keine Nachrichten '
          'zwischen Nutzern und keine Form der Offenlegung von Inhalten '
          'gegenüber Dritten. Die Kapsel ist durch ihre Konzeption privat: '
          'Die Dateien befinden sich im Drive der Person, die sie '
          'hochgeladen hat, und der Index ist pro Konto isoliert.',
      'Wenn das Kind volljährig wird, kann es die auf seine '
          'personenbezogenen Daten anwendbaren Rechte direkt ausüben, unter '
          'Beachtung der geltenden Gesetzgebung. Die App wurde entwickelt, '
          'um diese Kontinuität zu erleichtern: Die Dateien bleiben im von '
          'der Familie genutzten Google-Konto und können der Person selbst '
          'zugänglich gemacht werden, ohne von einer Übertragung von auf '
          'unseren Servern gespeicherten Dateien abhängig zu sein.',
    ],
  ),
  PrivacySection(
    title: 'Wie lange, und wie man löscht',
    body: <String>[
      'Die Daten bleiben, solange das Konto besteht. Es gibt keine '
          'automatische Löschfrist, solange das Konto aktiv bleibt, denn '
          'der Zweck des Produkts ist gerade die langfristige '
          'Aufbewahrung. Besteht eine gesetzliche Aufbewahrungspflicht oder '
          'eine andere Rechtsgrundlage, die die Aufbewahrung bestimmter '
          'Daten erfordert, können diese für den notwendigen Zeitraum '
          'aufbewahrt werden.',
      'Unter Profil, „Mein Konto und meine Daten löschen", löschen Sie '
          'den gesamten Index auf unserem Server, indem jede Sammlung '
          'durchlaufen wird, mit Bestätigung auf dem Server und nicht im '
          'lokalen Zwischenspeicher; Ihr Authentifizierungskonto; und alle '
          'auf dem Gerät gespeicherten Daten.',
      'Auf demselben Bildschirm wählen Sie, was mit dem Google-Drive-'
          'Ordner geschehen soll. Standardmäßig wird er beibehalten, da die '
          'Dateien direkt in Ihrem Konto gespeichert werden und die App '
          'keine eigene Kopie davon vorhält. Sofern die zu diesem Zeitpunkt '
          'verfügbare Berechtigung und die Google-APIs es zulassen, können '
          'Sie beantragen, dass die App den Ordner in den Papierkorb Ihres '
          'Drive verschiebt. Die endgültige Löschung der Dateien innerhalb '
          'von Google Drive hängt zudem von den Löschregeln und '
          '-mechanismen von Google selbst ab.',
      'Die Löschung des Index beginnt sofort und kann nach Abschluss '
          'nicht von der App rückgängig gemacht werden. Wir führen keine '
          'operative Sicherung des Index, um ein gelöschtes Konto '
          'wiederherzustellen. Daten, die aufgrund gesetzlicher '
          'Verpflichtung aufbewahrt werden müssen, können für den '
          'vorgeschriebenen Zeitraum bestehen bleiben und werden gegen mit '
          'diesem Zweck unvereinbare Nutzung geschützt.',
    ],
  ),
  PrivacySection(
    title: 'Ihre Rechte, wo auch immer Sie leben',
    body: <String>[
      'Der Name des Gesetzes ändert sich von Land zu Land. Die Rechte '
          'sind in der Praxis dieselben, und wir gewähren sie allen, ohne '
          'zu fragen, wo Sie leben: Auskunft, Berichtigung, Löschung, '
          'Übertragbarkeit, Einschränkung, Widerspruch und Widerruf der '
          'Einwilligung.',
      '• Europäische Union und Europäischer Wirtschaftsraum: DSGVO, Art. '
          '15 bis 22.',
      '• Vereinigtes Königreich: UK GDPR und Data Protection Act 2018, '
          'mit denselben Artikeln.',
      '• Brasilien: LGPD, Art. 18.',
      '• Argentinien: Ley 25.326, mit laufender Reform. Argentinien ist '
          'eines der wenigen Länder außerhalb Europas mit einem '
          'Angemessenheitsbeschluss der Europäischen Union, was einiges '
          'über das dort bereits geforderte Schutzniveau aussagt.',
      '• Uruguay: Ley 18.331, ebenfalls mit Angemessenheit der '
          'Europäischen Union.',
      '• Chile: Ley 19.628, ersetzt durch die im Dezember 2024 '
          'verabschiedete, an der DSGVO orientierte Ley 21.719, mit '
          'schrittweisem Inkrafttreten.',
      '• Kolumbien: Ley 1581 von 2012 (Habeas Data), mit einer eigenen, '
          'strengeren Regel für Kinderdaten: Die Verarbeitung muss dessen '
          'Kindeswohl beachten, und nicht nur die Einwilligung des '
          'Vertreters. Das ist ein höherer Standard, als unser Design '
          'bereits erfüllt, da der einzige Zweck hier die eigene Kapsel des '
          'Kindes ist, ohne jede Offenlegung gegenüber Dritten.',
      '• Peru: Ley 29733. Ecuador: Organgesetz zum Schutz '
          'personenbezogener Daten (LOPDP), von 2021.',
      '• In den übrigen südamerikanischen Ländern, noch ohne eigenes '
          'umfassendes Gesetz: dieselben Rechte, gemäß unserer Erklärung.',
      '• Vereinigte Staaten: Kalifornien hat das strengste Gesetz (CCPA '
          'und CPRA, siehe folgenden Abschnitt), und eine wachsende Liste '
          'anderer Bundesstaaten wie Virginia, Colorado, Connecticut und '
          'Utah hat ähnliche Gesetze, mit denselben Rechten auf Auskunft, '
          'Löschung, Berichtigung, Übertragbarkeit und Widerspruch gegen '
          'Verkauf oder Weitergabe. Da wir unter keinen Umständen Daten '
          'verkaufen oder weitergeben, wird dieses letzte Recht bereits '
          'standardmäßig ausgeübt, in jedem Bundesstaat, mit oder ohne '
          'eigenes Gesetz.',
      '• Schweiz: nDSG. Kanada: PIPEDA. Australien: Privacy Act und die '
          'Australian Privacy Principles. Südafrika: POPIA. Japan: APPI. '
          'Indien: DPDPA, mit Inkrafttreten jeder einzelnen Bestimmung.',
      '• Überall sonst: dieselben Rechte, gemäß unserer Erklärung, auch '
          'dort, wo das örtliche Gesetz sie noch nicht verlangt.',
      'In der Praxis lassen sich fast alle ausüben, ohne mit uns zu '
          'sprechen: Die Daten sind in der App sichtbar, in der App '
          'bearbeitbar und in der App löschbar. Für alles, was die App '
          'nicht löst, schreiben Sie an $privacyEmail',
      'Sie müssen die Anfrage nicht begründen, die Ausübung eines '
          'Rechts kostet nie etwas, und wir schränken den Dienst für '
          'niemanden ein, der eines ausübt.',
    ],
  ),
  PrivacySection(
    title: 'Wenn Sie in Kalifornien leben',
    body: <String>[
      'Der CCPA, geändert durch den CPRA, verlangt, dass bestimmte '
          'Aussagen ausdrücklich getroffen werden, und alle sind hier '
          'wahr:',
      '• Wir **verkaufen** keine personenbezogenen Informationen, und '
          'verkaufen sie nie.',
      '• Wir **geben** keine personenbezogenen Informationen für '
          'verhaltensbasierte Werbung zwischen Websites oder Apps weiter. '
          'Es gibt keinerlei Werbung in dieser App.',
      '• Wir verwenden oder offenbaren keine sensiblen personenbezogenen '
          'Informationen für etwas anderes als die Bereitstellung des von '
          'Ihnen angeforderten Dienstes.',
      '• Wir bieten keinen finanziellen Anreiz im Austausch gegen Daten.',
      '• Wir diskriminieren niemanden, der ein Recht ausübt: Die App '
          'funktioniert vorher und nachher gleich.',
      'Da wir nichts verkaufen oder weitergeben, gibt es keine '
          'Schaltfläche „Do Not Sell or Share My Personal Information", '
          'weil es nichts zum Deaktivieren gäbe.',
      'Die von uns erhobenen Kategorien, warum, und mit wem sie geteilt '
          'werden, stehen in den obigen Abschnitten, und diese Liste ist '
          'abschließend.',
      'Wenn Sie in einem anderen US-Bundesstaat mit eigenem '
          'Datenschutzgesetz leben, gelten dieselben sechs oben genannten '
          'Aussagen auch für Sie: Sie beschreiben, wie die App '
          'funktioniert, keine Ausnahme, die nur für Kalifornien gedacht '
          'ist.',
    ],
  ),
  PrivacySection(
    title: 'Internationale Übermittlung',
    body: <String>[
      'Ihre Dateien bleiben im Google Drive Ihres eigenen Kontos, und '
          'ihr Standort ist der, den Google Ihrem Konto zuweist, keine '
          'Entscheidung von uns. Der Index befindet sich auf der '
          'Infrastruktur von Cloud Firestore, die Daten außerhalb Ihres '
          'Landes verarbeiten kann.',
      'Diese Übermittlungen sind durch die von der Europäischen '
          'Kommission genehmigten Standardvertragsklauseln abgedeckt, die '
          'Google gemäß Art. 46 DSGVO übernommen hat, sowie durch den '
          'britischen Anhang zu diesen Klauseln. Google Cloud ist zudem im '
          'Data Privacy Framework zwischen der Europäischen Union und den '
          'Vereinigten Staaten zertifiziert.',
      'Für Personen in Brasilien stützt sich die Übermittlung auf Art. '
          '33 LGPD, mittels derselben Vertragsklauseln.',
      'Wir nehmen keine internationalen Übermittlungen aus eigener '
          'Initiative vor, über die zum Betrieb der in dieser Erklärung '
          'beschriebenen Infrastrukturdienste notwendige Verarbeitung '
          'hinaus. Der Index kann auf der Infrastruktur von Google Cloud '
          'verarbeitet werden, auch an Orten außerhalb des Landes des '
          'Nutzers, entsprechend der Konfiguration und den Bedingungen der '
          'genutzten Dienste. Die Dateien in Google Drive bleiben der '
          'Infrastruktur und der Kontokonfiguration des Google-Kontos des '
          'Nutzers selbst unterworfen.',
    ],
  ),
  PrivacySection(
    title: 'Sicherheit',
    body: <String>[
      'Der gesamte Datenverkehr ist während der Übertragung '
          'verschlüsselt, und ruhende Daten werden durch die Infrastruktur '
          'von Google verschlüsselt. Der Zugriff auf den Index wird durch '
          'serverseitige Sicherheitsregeln kontrolliert, die eine '
          'Authentifizierung verlangen und jedes Konto auf die eigenen '
          'Daten beschränken. Die App bietet eine Sperre per Biometrie oder '
          'Gerätecode.',
      'Kein System ist vollständig sicher, und wir versprechen nichts '
          'Gegenteiliges. Was hier das Risiko strukturell verringert, ist '
          'das Design: Fotos und Videos befinden sich nicht auf einem '
          'Server von uns, daher gibt es keine Mediendatenbank von uns, '
          'die durchsickern könnte.',
      'Kommt es zu einer Datenschutzverletzung, die den Index betrifft, '
          'benachrichtigen wir die irische Datenschutzkommission innerhalb '
          'von 72 Stunden nach Kenntnisnahme, wie es Art. 33 DSGVO '
          'vorschreibt, und informieren Sie direkt, wenn das Risiko für '
          'Ihre Rechte hoch ist, wie es Art. 34 vorschreibt. Schreibt ein '
          'anderes Gesetz Ihres Landes eine abweichende Frist oder einen '
          'anderen Empfänger vor, wie die LGPD (Art. 48) oder der CCPA, '
          'erfüllen wir beide.',
    ],
  ),
  PrivacySection(
    title: 'Kinder, und warum diese App anders ist',
    body: <String>[
      'Diese App speichert Daten **über** ein Kind und wird nicht '
          '**von** ihm genutzt. Wer installiert, sich anmeldet und '
          'registriert, ist die Mutter, der Vater oder der gesetzliche '
          'Vertreter, und muss volljährig sein.',
      'Deshalb richtet sich die App nicht an Kinder und wurde nicht so '
          'konzipiert, dass Minderjährige eigenständig Konten erstellen '
          'oder nutzen. Wer installiert, sich anmeldet und Informationen '
          'registriert, muss ein verantwortlicher Erwachsener sein. Es '
          'gibt keine Werbung, kein öffentliches Profil, keine Interaktion '
          'zwischen Nutzern und keine Funktionen, die eine eigenständige '
          'Nutzung durch Kinder fördern sollen.',
      'Die Daten über das Kind werden vom verantwortlichen Erwachsenen '
          'zum Zweck der Erstellung und Aufbewahrung der Zeitkapsel '
          'bereitgestellt. Die Verarbeitung von Daten von Kindern und '
          'Jugendlichen erfolgt unter Beachtung der geltenden Gesetzgebung '
          'und, soweit einschlägig, der Grundsätze des umfassenden Schutzes '
          'und des Kindeswohls.',
      'Wenn das Kind heranwächst und das Konto übernimmt, wird es zum '
          'Inhaber dieser Daten und übt alle Rechte des obigen Abschnitts '
          'direkt aus, ohne uns dafür zu benötigen.',
      'Mehrere Länder entwickeln einen spezifischen Schutzkodex für '
          'Produkte, auf die ein Kind zugreifen könnte, wie den '
          'britischen Children\'s Code. Wir haben keine formelle '
          'Zertifizierung in diesem Sinne, aber das Design der App folgt '
          'bereits denselben Grundsätzen: keine Werbung, kein Profiling, '
          'keine auf Aufmerksamkeitsbindung ausgelegte Benachrichtigung, '
          'kein Spiel, keine Belohnung für Engagement und kein '
          'öffentliches Teilen standardmäßig. Eine Erinnerung kann sogar '
          'versiegelt werden, um erst an einem zukünftigen, von der '
          'aufbewahrenden Person gewählten Datum geöffnet zu werden - das '
          'Gegenteil eines auf maximale Nutzung ausgelegten Designs.',
    ],
  ),
  PrivacySection(
    title: 'Änderungen dieser Erklärung',
    body: <String>[
      'Wesentliche Änderungen werden innerhalb der App angekündigt, '
          'bevor sie in Kraft treten. Das Datum oben zeigt die geltende '
          'Version an, und frühere Versionen bleiben im öffentlichen '
          'Verlauf des Repositorys verfügbar.',
    ],
  ),
  PrivacySection(
    title: 'Beschwerde',
    body: <String>[
      'Wenn Sie glauben, dass die Verarbeitung Ihrer Daten gegen das '
          'Gesetz verstößt, können Sie sich bei der Behörde Ihres '
          'Wohnorts beschweren, ohne vorher mit uns sprechen zu müssen.',
      '• Irland: Data Protection Commission (DPC), insbesondere wenn '
          'die DPC die zuständige oder federführende Aufsichtsbehörde im '
          'Sinne der DSGVO ist.',
      '• Europäische Union: Sie können die Behörde Ihres eigenen '
          'Mitgliedstaats bevorzugen, die weiterleitet. Die Liste finden '
          'Sie unter edpb.europa.eu',
      '• Brasilien: ANPD, gov.br/anpd',
      '• Argentinien: Agencia de Acceso a la Información Pública (AAIP).',
      '• Uruguay: Unidad Reguladora y de Control de Datos Personales '
          '(URCDP).',
      '• Chile: die neue Agencia de Protección de Datos Personales, '
          'sobald die Ley 21.719 in Kraft tritt.',
      '• Kolumbien: Superintendencia de Industria y Comercio (SIC).',
      '• Vereinigtes Königreich: ICO, ico.org.uk',
      '• Schweiz: EDÖB. Kanada: OPC. Australien: OAIC.',
      '• Kalifornien: California Privacy Protection Agency, cppa.ca.gov, '
          'oder der Generalstaatsanwalt des Bundesstaats.',
      'Wenn Sie es zuerst mit uns versuchen möchten, schreiben Sie an '
          '$privacyEmail. Wir antworten innerhalb von maximal 30 Tagen, '
          'und eine Antwort von uns ist niemals Voraussetzung dafür, dass '
          'Sie sich an die Behörde wenden.',
    ],
  ),
];
