import 'textos.dart';

/// Die App auf Deutsch.
///
/// Geschrieben als Deutsch, nicht als Wort-für-Wort-Übersetzung aus dem
/// Portugiesischen. Wo der portugiesische Satz auf einer Genusübereinstimmung
/// beruhte, die es im Deutschen so nicht gibt, wurde der Satz neu formuliert.
/// Durchgehend wird die Sie-Form verwendet, wie es in deutschsprachiger
/// Software üblich ist.
///
/// **Der Name des Google-Drive-Ordners steht hier nicht, und das ist
/// Absicht.** Er ist eine Konstante in `DriveService`, auf Portugiesisch, und
/// bleibt das für alle: eine Übersetzung würde dazu führen, dass die App
/// nach einem Ordner mit einem anderen Namen sucht und alles zurücklässt,
/// was die Familie bereits gespeichert hat.
class TextosDe implements Textos {
  const TextosDe();

  @override
  String get codigo => 'de';

  @override
  String get appName => 'Mein Baby';

  @override
  String get appFullName => 'Mein Baby: Zeitkapsel';

  @override
  String get appSubtitle => 'Zeitkapsel';

  @override
  String get appTagline => 'Jeder Moment eine Erinnerung fürs Leben.';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get signInNote =>
      'Alle Erinnerungen werden im Google-Drive-Konto Ihres Kindes '
      'gespeichert.';

  @override
  String get signInError =>
      'Anmeldung fehlgeschlagen. Verbindung prüfen und erneut versuchen.';

  @override
  String get onboardingGreeting => 'Hallo!';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get gender => 'Junge oder Mädchen?';

  @override
  String get birthDate => 'Geburtsdatum';

  @override
  String get birthTime => 'Geburtszeit';

  @override
  String get birthWeight => 'Geburtsgewicht';

  @override
  String get birthHeight => 'Körperlänge bei Geburt';

  @override
  String get birthTimeOptional => 'Geburtszeit (optional)';

  @override
  String get birthWeightOptional => 'Geburtsgewicht (optional)';

  @override
  String get birthHeightOptional => 'Körperlänge bei Geburt (optional)';

  @override
  String get hospitalOptional => 'Krankenhaus (optional)';

  @override
  String get birthPhoto => 'Foto von der Geburt';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get preparingDrive => 'Ordner werden in Google Drive vorbereitet...';

  @override
  String get home => 'Start';

  @override
  String get timeline => 'Zeitleiste';

  @override
  String get search => 'Suche';

  @override
  String get accountsLabel => 'KONTEN';

  @override
  String get switchAccount => 'Konto wechseln';

  @override
  String get profile => 'Profil';

  @override
  String get photos => 'Fotos';

  @override
  String get videos => 'Videos';

  @override
  String get letters => 'Briefe';

  @override
  String get drawings => 'Zeichnungen';

  @override
  String get documents => 'Dokumente';

  @override
  String get growth => 'Wachstum';

  @override
  String get stats => 'Statistiken';

  @override
  String get trash => 'Papierkorb';

  @override
  String get settings => 'Einstellungen';

  @override
  String get about => 'Über die App';

  @override
  String get signOut => 'Abmelden';

  @override
  String get storedWithLove => 'Mit Liebe gespeichert im Drive von';

  @override
  String get addQuestion => 'Was möchten Sie hinzufügen?';

  @override
  String get addPhoto => 'Foto';

  @override
  String get addVideo => 'Video';

  @override
  String get addLetter => 'Brief';

  @override
  String get addDrawing => 'Zeichnung';

  @override
  String get addDrawingHint => 'Eine Zeichnung hinzufügen';

  @override
  String get addDocument => 'Dokument';

  @override
  String get addDocumentHint => 'Wichtige Dokumente hinzufügen';

  @override
  String get addGrowth => 'Wachstum';

  @override
  String get addGrowthHint => 'Gewicht und Größe erfassen';

  @override
  String get timelineEmptyTitle => 'Die Geschichte beginnt hier';

  @override
  String get birth => 'Geburt';

  @override
  String get photosAdded => 'Fotos hinzugefügt';

  @override
  String get photoAdded => 'Foto hinzugefügt';

  @override
  String get videoAdded => 'Video hinzugefügt';

  @override
  String get drawingAdded => 'Zeichnung hinzugefügt';

  @override
  String get documentAdded => 'Dokument hinzugefügt';

  @override
  String get growthRecord => 'Wachstumseintrag';

  @override
  String get letterPrefix => 'Brief:';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterTitle => 'Nach Typ filtern';

  @override
  List<String> get milestoneSuggestions => <String>[
    'Erstes Foto',
    'Erstes Bad',
    'Erster Ausflug',
    'Erste Reise',
    'Erstes Lächeln',
    'Erster Zahn',
    'Erste Schritte',
    'Erstes Wort',
    'Erster Geburtstag',
  ];

  @override
  String get letterStartersTitle =>
      'Wissen Sie nicht, wie Sie anfangen sollen?';

  @override
  List<String> get letterStarters => <String>[
    'Heute möchte ich dir erzählen von ',
    'Wenn du das liest, ',
    'Du weißt es noch nicht, aber ',
    'Etwas, das ich nie vergessen möchte: ',
    'Wenn ich dir nur eine Sache sagen könnte, wäre es ',
    'Der Tag, an dem du ',
    'An dir, so wie du heute bist, liebe ich am meisten ',
  ];

  @override
  String get titleField => 'Titel';

  @override
  String get messageField => 'Nachricht';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get milestoneOptional => 'Meilenstein (optional)';

  @override
  String get weightField => 'Gewicht';

  @override
  String get heightField => 'Größe';

  @override
  String get photoOptional => 'Foto (optional)';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get share => 'Teilen';

  @override
  String get delete => 'Löschen';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get view => 'Anzeigen';

  @override
  String get download => 'Herunterladen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get weeks => 'Wochen';

  @override
  String get months => 'Monate';

  @override
  String get years => 'Jahre';

  @override
  String get photosOptimizedNote =>
      'Fotos werden automatisch komprimiert, um Speicherplatz zu sparen.';

  @override
  String get videoOptimizedNote =>
      'Dieses Video wurde in 540p gespeichert, um Speicherplatz zu sparen.';

  @override
  String get allFilesOptimizedNote =>
      'Alle Dateien werden optimiert, um Speicherplatz zu sparen.';

  @override
  String get uploadPending => 'Warten auf Übertragung';

  @override
  String get uploadOptimizing => 'Wird optimiert...';

  @override
  String get uploadSending => 'Wird gesendet...';

  @override
  String get uploadFailed => 'Übertragung fehlgeschlagen';

  @override
  String get uploadingCount => 'Wird gesendet';

  @override
  String get searchHint => 'Erinnerungen durchsuchen...';

  @override
  String get searchByCategory => 'Nach Kategorie suchen';

  @override
  String get recentSearches => 'Letzte Suchen';

  @override
  String get searchEmpty => 'Hier wurde nichts gefunden.';

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get storageUsed => 'Verwendeter Speicher';

  @override
  String get storageOf => 'von';

  @override
  String get capsuleStorage => 'Zeitkapsel';

  @override
  String get driveStorage => 'Ihr Google Drive';

  @override
  String get driveStorageNote =>
      'Die Summe oben bezieht sich auf Ihr gesamtes Google-Konto. Die App '
      'sieht nur die Dateien, die sie selbst erstellt hat, innerhalb des '
      'Kapsel-Ordners. Auf den Rest Ihres Drive hat sie keinen Zugriff.';

  @override
  String get lockSection => 'Datenschutz';

  @override
  String get lockTitle => 'App-Sperre';

  @override
  String get lockBody =>
      'Fragt beim Öffnen der App nach Fingerabdruck, Gesicht oder PIN des '
      'Geräts. Standardmäßig ausgeschaltet.';

  @override
  String get lockUnavailable =>
      'Dieses Gerät hat weder Fingerabdruck noch Gesichtserkennung noch '
      'PIN eingerichtet. Richten Sie eine Sperre in den '
      'Android-Einstellungen ein, um diese Option nutzen zu können.';

  @override
  String get lockNote =>
      'Die Sperre schützt vor jemandem, der Ihr bereits entsperrtes '
      'Telefon in die Hand nimmt. Sie verschlüsselt nichts: eine weitere '
      'Tür, kein Tresor.';

  @override
  String get lockFailed =>
      'Bestätigung nicht möglich. Die Sperre bleibt ausgeschaltet.';

  @override
  String get lockReason =>
      'Bestätigen Sie, dass Sie es sind, um die Erinnerungen zu öffnen.';

  @override
  String get lockedTitle => 'App gesperrt';

  @override
  String get lockedBody =>
      'Bestätigen Sie Ihre Identität, um die Erinnerungen zu sehen.';

  @override
  String get unlock => 'Entsperren';

  @override
  String get viewChart => 'Diagramm ansehen';

  @override
  String get growthChart => 'Wachstumsdiagramm';

  @override
  String get growthEmptyTitle => 'Noch kein Eintrag';

  @override
  String get growthEmptyBody =>
      'Erfassen Sie Gewicht und Größe, um das Wachstum zu verfolgen.';

  @override
  String get trashEmptyTitle => 'Der Papierkorb ist leer';

  @override
  String get trashEmptyBody =>
      'Gelöschte Elemente bleiben hier, bis Sie sie endgültig entfernen.';

  @override
  String get trashNote =>
      'Die Dateien landen auch im Papierkorb von Google Drive.';

  @override
  String get deleteForever => 'Endgültig löschen';

  @override
  String get deleteConfirmTitle => 'Dieses Element löschen?';

  @override
  String get deleteConfirmBody =>
      'Es kommt in den Papierkorb und kann später wiederhergestellt '
      'werden.';

  @override
  String get deleteForeverConfirmBody =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get currentAge => 'Aktuelles Alter';

  @override
  String get birthDateShort => 'Geburt';

  @override
  String get signOutConfirmTitle => 'Abmelden?';

  @override
  String get signOutConfirmBody =>
      'Ihre Erinnerungen bleiben in Ihrem Google Drive gespeichert. '
      'Miniaturansichten und heruntergeladene Dateien werden von diesem '
      'Gerät entfernt.';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get accountDeletionTitle => 'Konto- und Datenlöschung';

  @override
  String get accountDeletionShort => 'Konto löschen';

  @override
  String get goToDeleteAccount => 'Zur Kontolöschung';

  @override
  String get deleteAccount => 'Mein Konto und meine Daten löschen';

  @override
  String get deleteAccountTitle => 'Konto löschen?';

  @override
  String get deleteAccountBody =>
      'Wir löschen von unserem Server alles, was wir über Sie speichern: '
      'das Profil, die Zeitleiste, die Wachstumseinträge und den Text der '
      'Briefe. Außerdem geben wir die Berechtigung für Ihr Google Drive '
      'zurück.\n\n'
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get deleteAccountDriveQuestion =>
      'Und der Ordner „Meu Bebê - Cápsula do Tempo" im Drive?';

  @override
  String get deleteAccountKeepDrive => 'Dateien behalten';

  @override
  String get deleteAccountKeepDriveHint =>
      'Die Fotos, Videos und Dokumente bleiben in Ihrem Drive, nach Alter '
      'geordnet. Empfohlen.';

  @override
  String get deleteAccountTrashDrive => 'In den Papierkorb verschieben';

  @override
  String get deleteAccountTrashDriveHint =>
      'Der Ordner kommt in den Papierkorb von Google Drive und kann 30 '
      'Tage lang wiederhergestellt werden.';

  @override
  String get deleteAccountWorking => 'Wird gelöscht...';

  @override
  String get deleteAccountDone => 'Konto gelöscht.';

  @override
  String get genericError => 'Etwas ist schiefgelaufen. Erneut versuchen.';

  @override
  String get noItemsYet => 'Hier ist noch nichts.';

  @override
  String get requiredField => 'Bitte füllen Sie dieses Feld aus';

  @override
  String get invalidNumber => 'Geben Sie eine gültige Zahl ein';

  @override
  String get codigoIntl => 'de';

  @override
  String get padraoData => 'dd.MM.yyyy';

  @override
  String get padraoDiaMes => 'dd.MM.';

  @override
  String get padraoDataLonga => 'd. MMMM yyyy';

  @override
  String get padraoMesAno => 'MMMM yyyy';

  @override
  String get padraoHora => 'HH:mm';

  @override
  String get entreDatas => 'bis';

  @override
  String get hoje => 'Heute';

  @override
  String get ontem => 'Gestern';

  @override
  String saudacao(int hora) {
    if (hora < 12) return 'Guten Morgen';
    if (hora < 18) return 'Guten Tag';
    return 'Guten Abend';
  }

  @override
  String haTempo(int dias) {
    if (dias <= 0) return 'heute';
    if (dias == 1) return 'gestern';
    if (dias < 14) return 'vor $dias Tagen';
    if (dias < 60) {
      final int semanas = dias ~/ 7;
      return semanas == 1 ? 'vor 1 Woche' : 'vor $semanas Wochen';
    }
    if (dias < 365) {
      final int meses = dias ~/ 30;
      return meses == 1 ? 'vor 1 Monat' : 'vor $meses Monaten';
    }
    final int anos = dias ~/ 365;
    return anos == 1 ? 'vor 1 Jahr' : 'vor $anos Jahren';
  }

  @override
  String ordinal(int n) => switch (n) {
    1 => 'erste',
    2 => 'zweite',
    3 => 'dritte',
    4 => 'vierte',
    5 => 'fünfte',
    6 => 'sechste',
    7 => 'siebte',
    8 => 'achte',
    9 => 'neunte',
    10 => 'zehnte',
    _ => '$n.',
  };

  @override
  String contarDias(int n) => n == 1 ? '1 Tag' : '$n Tage';

  @override
  String contarMeses(int n) => n == 1 ? '1 Monat' : '$n Monate';

  @override
  String contarAnos(int n) => n == 1 ? '1 Jahr' : '$n Jahre';

  @override
  String contarItens(int n) => n == 1 ? '1 Eintrag' : '$n Einträge';

  @override
  String contarFotos(int n) => n == 1 ? '1 Foto' : '$n Fotos';

  @override
  String contarVideos(int n) => n == 1 ? '1 Video' : '$n Videos';

  @override
  String get lastBirth => 'Letzte Geburt';

  @override
  String get lastPhoto => 'Letztes Foto';

  @override
  String get lastVideo => 'Letztes Video';

  @override
  String get lastLetter => 'Letzter Brief';

  @override
  String get lastDrawing => 'Letzte Zeichnung';

  @override
  String get lastDocument => 'Letztes Dokument';

  @override
  String get lastGrowth => 'Letzte Messung';

  @override
  String get oneVideo => 'Video';

  @override
  String get oneGrowth => 'Messung';

  @override
  String get imageOpenFailed => 'Dieses Bild konnte nicht geöffnet werden.';

  @override
  String get videoOpenFailed => 'Dieses Video konnte nicht geöffnet werden.';

  @override
  String get documentNotFound => 'Dokument nicht gefunden';

  @override
  String get letterNotFound => 'Brief nicht gefunden';

  @override
  String get entryNotFound => 'Erinnerung nicht gefunden';

  @override
  String get driveSpaceFailed =>
      'Der Speicherplatz von Google Drive konnte nicht gelesen werden.';

  @override
  String get firstVideoHint =>
      'Tippen Sie auf das +, um das erste Video hinzuzufügen.';

  @override
  String get documentsEmptyBody =>
      'Geburtsurkunde, Impfausweis, Reisepass: alles an einem Ort.';

  @override
  String get isToday => 'Ist heute';

  @override
  String get isTodayBang => 'Ist heute!';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get nextMilestone => 'Nächster Meilenstein';

  @override
  String faltamDias(int dias) => 'In ${contarDias(dias)}';

  @override
  String get seeInspiration => 'Ideen ansehen';

  @override
  String get forYou => 'Für Sie';

  @override
  String get notYet => 'noch nicht';

  @override
  String get inspirations => 'Ideen';

  @override
  String get inspirationsLoadFailed => 'Die Ideen konnten nicht geladen werden';

  @override
  String get inspirationSearchHint => 'Was möchten Sie wissen?';

  @override
  String get suggestionsByAge =>
      'Die Vorschläge richten sich nach Alter und Kalender.';

  @override
  String get notNow => 'Jetzt nicht';

  @override
  String get savedTitle => 'Gespeichert';

  @override
  String get willBeSaved => 'Wird gespeichert';

  @override
  String get sendMemoryError => 'Erinnerung senden';

  @override
  String get dateFromFile =>
      'Datum aus der Datei selbst gelesen. Zum Ändern tippen.';

  @override
  String get deletedOn => 'Gelöscht am ';

  @override
  String get itemDeleted => 'Element gelöscht.';

  @override
  String get documentNameSuggestion => 'Geburtsurkunde';

  @override
  String get saveInfo => 'Informationen speichern';

  @override
  String get editInfo => 'Informationen bearbeiten';

  @override
  String get notProvided => 'Nicht angegeben';

  @override
  String get automatic => 'Automatisch';

  @override
  String get reviewIntro => 'Einführung erneut ansehen';

  @override
  String get lastUpdatedLabel => 'Letzte Aktualisierung';

  @override
  String get optimization => 'Optimierung';

  @override
  String get photoMaxSide => 'Bis zu 960 px an der längeren Seite';

  @override
  String get optimizationNote =>
      'Die Optimierung erfolgt automatisch und kann nicht abgeschaltet '
      'werden: Sie hält die Sammlung über viele Jahre hinweg schlank.';

  @override
  String get languageSection => 'Sprache';

  @override
  String get clearCacheBody =>
      'Löscht Miniaturansichten, temporäre Dateien und bereits '
      'heruntergeladene Dokumente. Nichts geht verloren: Alles bleibt in '
      'Google Drive.';

  @override
  String get cacheCleared => 'Cache geleert.';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get storageOnDevice => 'Speicher auf dem Gerät';

  @override
  String get remindersSection => 'Erinnerungen';

  @override
  String get remindersOff => 'Ausgeschaltet';

  @override
  String get startupFailedTitle => 'Die App konnte nicht gestartet werden';

  @override
  String get technicalDetail => 'Technisches Detail';

  @override
  String get premiumInviteAction => 'Verstanden';

  @override
  String get introTitle1 => 'Die Kindheit vergeht schnell.';

  @override
  String get introTitle2 => 'Jede Erinnerung hat ihren Platz.';

  @override
  String get introBody2 =>
      'Fotos, Videos, Briefe, Zeichnungen, Dokumente und '
      'Wachstumseinträge. Alles an einem einzigen Ort vereint.';

  @override
  String get introTitle3 => 'Jede Erinnerung zu ihrer Zeit.';

  @override
  String get introTitle4 => 'Diese Kapsel erstellen?';

  @override
  String get sealBody =>
      'Das bleibt verschlossen bis zu dem Datum, das Sie wählen. Der '
      'Inhalt bleibt in Ihrem Drive, und Sie können ihn auf Wunsch auch '
      'früher öffnen: Es ist ein Siegel, wie das einer im Garten '
      'vergrabenen Kapsel, kein Tresor.';

  @override
  String get aboutPhotos =>
      'Kein Foto läuft über einen Server von uns: Sie gehen direkt vom '
      'Handy zu Google Drive.';

  @override
  String get aboutScope =>
      'Die App sieht den Rest Ihres Drive nicht. Die von Ihnen erteilte '
      'Berechtigung gewährt nur Zugriff auf die Dateien, die sie selbst '
      'erstellt, alle innerhalb des Ordners „Meu Bebê - Cápsula do '
      'Tempo". Ihre übrigen Ordner sind für sie unsichtbar.';

  @override
  String get aboutIndex =>
      'Was auf unserem Server bleibt, ist der Index: Name, Geburtsdatum, '
      'Gewicht, Größe, Daten und der Text der Briefe. Das ist es, was die '
      'Zeitleiste und die Suche funktionieren lässt. Sie können all das '
      'jederzeit in Ihrem Profil löschen.';

  @override
  String get aboutLastingTitle => 'Damit die Kapsel Bestand hat';

  @override
  String get deleteDriveNote =>
      'Auch im Papierkorb gehören die Dateien Ihnen und bleiben in Ihrem '
      'Drive: Die App hatte nie eine Kopie davon.';

  @override
  String get profilePhotoNote =>
      'Das Profilfoto stammt aus den bereits gespeicherten Erinnerungen. '
      'Fügen Sie ein Foto hinzu, um eines auswählen zu können.';

  @override
  String get remindersHowTitle => 'Worum es geht';

  @override
  String get remindersMarkedTitle => 'Was markiert ist';

  @override
  String get remindersFrequency =>
      'Höchstens zwei pro Woche, nie zwei am selben Tag.';

  @override
  String get remindersOffNote =>
      'Ausgeschaltet. Es wird nichts gesendet. Falls das Handy '
      'Benachrichtigungen verweigert hat, aktivieren Sie sie unter '
      'Einstellungen, Apps, Meu Bebê.';

  @override
  String get remindersNothingSoon =>
      'In den nächsten Wochen nichts. Das ist normal: Erinnerungen '
      'erscheinen erst, wenn wirklich ein Termin naht.';

  @override
  String get remindersPrivacy =>
      'Die Erinnerungen werden auf Ihrem Handy berechnet, ausgehend von '
      'dem, was bereits hier ist. Dafür wird nichts an irgendeinen '
      'Server gesendet, und keine Benachrichtigung nennt, was Sie '
      'gespeichert haben.';

  @override
  String get remindersDenied =>
      'Android hat die Benachrichtigungen nicht zugelassen. Sie können '
      'sie in den Handy-Einstellungen freigeben, unter Apps, Meu Bebê.';

  @override
  String get sealedEmptyBody =>
      'Beim Speichern eines Briefes oder Videos können Sie ein Datum '
      'wählen, zu dem es sich öffnet: ein Geburtstag, die Volljährigkeit '
      'oder ein beliebiges anderes Datum. Es wartet hier bis dahin.';

  @override
  String get growthChartHint =>
      'Ab zwei Einträgen beginnt das Diagramm, die Geschichte zu '
      'erzählen.';

  @override
  String get introBody1 =>
      'Bewahren Sie die kleinen Momente, bevor sie nur noch Erinnerungen '
      'sind.';

  @override
  String get introTitle4b => 'Ein Geschenk für die Zukunft.';

  @override
  String get introBody3 =>
      'Wir ordnen alles nach dem Alter, in dem es geschah, und formen so '
      'eine echte Zeitleiste der Kindheit.';

  @override
  String get introBody4 =>
      'Eines Tages kann diese Kapsel von der Person geöffnet werden, die '
      'am meisten zählt: Ihrem Kind.';

  @override
  String get introBody5 =>
      'Wir empfehlen ein eigenes Google-Konto, um all diese Erinnerungen '
      'über viele Jahre zu bewahren.';

  @override
  String get premiumInviteLetters => 'Briefe gehören zum Premium-Plan';

  @override
  String get premiumInviteDrawings => 'Zeichnungen gehören zum Premium-Plan';

  @override
  String get premiumInviteDocuments => 'Dokumente gehören zum Premium-Plan';

  @override
  String get premiumInviteGrowth => 'Wachstum gehört zum Premium-Plan';

  @override
  String get premiumInviteGeneric => 'Das gehört zum Premium-Plan';

  @override
  String get premiumInvitePrice =>
      'Es ist ein Jahresabonnement, das über Google Play abgerechnet und '
      'verwaltet wird und den Preis in der Währung Ihres Landes anzeigt.';

  @override
  String get premiumInviteKeeps =>
      'Ohne es verschwindet nichts: Fotos und Videos bleiben weiterhin '
      'frei, und alles bereits Gespeicherte bleibt für immer zugänglich.';

  @override
  String get documentNameQuestion => 'Wie möchten Sie es nennen:';

  @override
  String get videosLabel => 'Videos';

  @override
  String get sendMemory => 'Erinnerung senden';

  @override
  String get languageNote =>
      'Die Auswahl wird bereits gespeichert, aber die Übersetzung wird '
      'noch erstellt: Vorerst bleibt die App auf Portugiesisch.';

  @override
  String get videoOptimizedShort => '540p mit optimierter Bitrate';

  @override
  String get originalFiles => 'Originaldateien';

  @override
  String get originalFilesNote => 'Bleiben unverändert auf dem Handy';

  @override
  String get loginCapsuleHint =>
      'Um das Konto der Kapsel zu erstellen: unten tippen und auf dem '
      'Google-Bildschirm Weiteres Konto hinzufügen wählen.';

  @override
  String get startupFirebaseHint =>
      'Das ist fast immer eine Firebase-Konfiguration: Die '
      'google-services.json und die firebase_options.dart müssen vom '
      'selben Projekt stammen, und Firestore sowie die Google-Anmeldung '
      'müssen in der Konsole aktiviert sein.';

  @override
  String get sentToDrive => 'Gespeichert';

  @override
  String get dateNotFoundMedia =>
      'Wir haben kein Datum in der Mediendatei gefunden, daher gilt das '
      'heutige. Zum Ändern tippen.';

  @override
  String get dateNotFoundFile =>
      'Wir haben kein Datum in der Datei gefunden, daher gilt das '
      'heutige. Zum Ändern tippen.';

  @override
  String inspirationsSubtitle(String nome) =>
      'Ideen für die Phase, die $nome gerade durchlebt.';

  @override
  String suggestionsGrowNote(String nome) =>
      'Die Vorschläge kehren zurück, während $nome wächst und sich die '
      'Termine nähern.';

  @override
  String remindersIntroNamed(String nome) =>
      'Die Erinnerungen sind standardmäßig aktiviert, denn eine '
      'Zeitkapsel erfüllt ihr Versprechen nur, wenn jemand zu ihr '
      'zurückkehrt. Es sind wenige, und sie sorgen dafür, dass Sie den '
      'Tag nicht verpassen, an dem $nome einen weiteren Monat vollendet.';

  @override
  String remindersHourNote(int hora) =>
      'Immer zwischen 8 und $hora Uhr. Die App weckt niemanden mitten '
      'in der Nacht.';

  @override
  String remindersSummary(int marcados, int total, int hora) =>
      '$marcados von $total Arten, um $hora Uhr';

  @override
  String birthdayOrdinal(int anos) => 'Für den ${ordinal(anos)} Geburtstag';

  @override
  String todayWithDate(String data) => 'Ist heute, $data';

  @override
  String tomorrowWithDate(String data) => 'Morgen, $data';

  @override
  String searchNoResults(String termo) =>
      'Wir haben keinen Beitrag mit „$termo" gefunden.';

  @override
  String growthFromBirth(String data) => 'Von der Geburt bis $data';

  @override
  String savedInDrive(String dono) => 'Gespeichert $dono.';

  @override
  String lastUpdated(String data) => 'Letzte Aktualisierung: $data';

  @override
  String batchManyDays(int dias) =>
      'Achtung: Ihre Auswahl stammt aus $dias verschiedenen Tagen, und '
      'alles wird mit diesem Datum gespeichert. Zum Trennen senden Sie '
      'jeweils einen Tag einzeln.';

  @override
  String get inspirationsSubtitleGeneric => 'Ideen für die aktuelle Phase.';

  @override
  String willBeSavedIn(String dono) => 'Wird $dono gespeichert.';

  @override
  String get remindersIntroGeneric =>
      'Die Erinnerungen sind standardmäßig aktiviert, denn eine '
      'Zeitkapsel erfüllt ihr Versprechen nur, wenn jemand zu ihr '
      'zurückkehrt. Es sind wenige, und sie gelten Terminen, die '
      'unbemerkt vorübergehen.';

  @override
  String get sealedEmptyIntro =>
      'Beim Speichern eines Briefes oder Videos können Sie ein '
      'Öffnungsdatum wählen: den 15. Geburtstag, den 18. oder ein '
      'beliebiges anderes. Es wartet hier bis dahin.';

  @override
  String get aboutPhotosNote =>
      'Kein Foto läuft über einen Server von uns: Sie gehen direkt von '
      'Ihrem Gerät zum Google Drive Ihres Kontos.';

  @override
  String get profilePhotoEmpty =>
      'Das Profilfoto stammt aus den bereits gespeicherten Erinnerungen. '
      'Fügen Sie ein Foto hinzu, um eines auswählen zu können.';

  @override
  String remindersHourRange(int inicio, int fim) =>
      'Zwischen $inicio und $fim Uhr. Die App weckt niemanden mitten in '
      'der Nacht.';

  @override
  String get typeOneBirth => 'Geburt';

  @override
  String get typeOnePhoto => 'Foto';

  @override
  String get typeOneLetter => 'Brief';

  @override
  String get typeOneDrawing => 'Zeichnung';

  @override
  String get typeOneDocument => 'Dokument';

  @override
  String get typeManyBirths => 'Geburten';

  @override
  String get typeManyPhotos => 'Fotos';

  @override
  String get typeManyVideos => 'Videos';

  @override
  String get typeManyLetters => 'Briefe';

  @override
  String get typeManyDrawings => 'Zeichnungen';

  @override
  String get typeManyDocuments => 'Dokumente';

  @override
  String get typeManyGrowth => 'Messungen';

  @override
  String get theGrowth => 'das Wachstum';

  @override
  String get documentNameQuestionFull => 'Wie möchten Sie es nennen:';

  @override
  String get loginCreateAccountHint =>
      'Um das Konto der Kapsel zu erstellen: unten tippen und im '
      'Google-Fenster „Weiteres Konto hinzufügen" und dann „Konto '
      'erstellen" wählen.';

  @override
  String get aboutInactivity =>
      'Google löscht Konten, die zwei Jahre lang nicht genutzt werden, '
      'und mit ihnen alles, was sich in ihrem Drive befindet. Das gilt '
      'vor allem für alle, die ein Konto ausschließlich für die Kapsel '
      'erstellt haben.\n\nDiese App gelegentlich zu öffnen, zählt bereits '
      'als Nutzung, mehr ist nicht nötig. Wenn Sie dennoch fast ein Jahr '
      'lang nicht erscheinen, warnt die App Sie einmal, und diese Warnung '
      'kann in den Einstellungen abgeschaltet werden.';

  @override
  String get profilePhotoFromMemories =>
      'Das Profilfoto stammt aus den bereits gespeicherten Erinnerungen. '
      'Fügen Sie ein Foto hinzu, und es erscheint hier.';

  @override
  String premiumInviteWhat(String tipos, String deQuem, String outros) =>
      'Das Speichern von $tipos in der Kapsel$deQuem gehört zum Premium, '
      'zusammen mit $outros.';

  @override
  String profilePhotoEmptyOf(String deQuem) =>
      'Das Profilfoto stammt aus den bereits gespeicherten Erinnerungen. '
      'Fügen Sie ein Foto $deQuem hinzu, und es erscheint hier.';

  @override
  String comArtigo(String plural) => plural;

  @override
  String get errNoConnection => 'Keine Internetverbindung. Erneut versuchen.';

  @override
  String get errFileRead => 'Die Datei konnte nicht vom Gerät gelesen werden.';

  @override
  String get errPermissionDenied =>
      'Der Server hat das Speichern abgelehnt. Melden Sie sich ab und '
      'wieder an; falls es weiterhin auftritt, liegt es an einer '
      'Konfiguration der App, nicht an Ihnen.';

  @override
  String get errSessionExpired =>
      'Ihre Sitzung ist abgelaufen. Melden Sie sich erneut an, um '
      'fortzufahren.';

  @override
  String get errMissingIndex =>
      'Ihre Erinnerungen sind gespeichert, aber der Server kann sie noch '
      'nicht ordnen, um sie hier anzuzeigen. Das liegt an einer '
      'Konfiguration der App, nicht an Ihnen.';

  @override
  String get errServerQuiet =>
      'Der Server hat nicht geantwortet. In Kürze erneut versuchen.';

  @override
  String get errRecentLogin =>
      'Melden Sie sich aus Sicherheitsgründen erneut an, bevor Sie '
      'fortfahren.';

  @override
  String get errGeneric =>
      'Konnte nicht abgeschlossen werden. Erneut versuchen.';

  @override
  String get errDriveExpired =>
      'Der Zugriff auf Google Drive ist abgelaufen. Melden Sie sich ab '
      'und wieder an, um die Berechtigung zu erneuern.';

  @override
  String get errDriveNotEnabled =>
      'Google Drive ist für diese App noch nicht freigegeben. Das ist '
      'eine Konfiguration unsererseits, nicht Ihrerseits: Nichts von dem, '
      'was Sie eingegeben haben, ist verloren gegangen.';

  @override
  String get errDriveFull =>
      'Ihr Google Drive hat keinen Speicherplatz mehr. Geben Sie Platz '
      'im Konto frei und versuchen Sie es erneut.';

  @override
  String get errDriveRateLimit =>
      'Google Drive bat um etwas Geduld. In Kürze erneut versuchen.';

  @override
  String get errDriveForbidden =>
      'Google Drive hat den Zugriff verweigert. Melden Sie sich ab und '
      'wieder an, um den Ordner der Kapsel zu autorisieren.';

  @override
  String get errDriveFolderMissing =>
      'Der Ordner der Kapsel wurde in Ihrem Google Drive nicht gefunden.';

  @override
  String get errDriveQuiet =>
      'Google Drive hat nicht geantwortet. In Kürze erneut versuchen; '
      'nichts von dem, was Sie eingegeben haben, ist verloren gegangen.';

  @override
  String get errDriveGeneric =>
      'Google Drive konnte nicht erreicht werden. Erneut versuchen.';

  @override
  String get authSlow =>
      'Die Anmeldung mit Google braucht lange für eine Antwort. '
      'Verbindung prüfen und erneut versuchen.';

  @override
  String get authUnsupported =>
      'Dieses Gerät bietet keine Anmeldung mit Google.';

  @override
  String get authNoIdentifier =>
      'Wir haben die Kennung des Kontos nicht erhalten. Prüfen Sie die '
      'Konfiguration der Google-Anmeldung und versuchen Sie es erneut.';

  @override
  String get authOtherAccount =>
      'Die gespeicherte Berechtigung stammt von einem anderen '
      'Google-Konto. Melden Sie sich erneut an, um weiter in dieser '
      'Kapsel zu speichern.';

  @override
  String get authRenewDrive =>
      'Wir müssen die Berechtigung für Google Drive erneuern.';

  @override
  String get authSignInToContinue =>
      'Melden Sie sich mit dem Google-Konto an, um fortzufahren.';

  @override
  String get authDriveRefused =>
      'Sie haben den Zugriff auf Google Drive nicht autorisiert. Dort '
      'werden die Erinnerungen gespeichert, auf Ihrem eigenen Konto.';

  @override
  String get authReloginToDelete =>
      'Um das Konto zu löschen, melden Sie sich erneut an und '
      'wiederholen Sie den Vorgang.';

  @override
  String get authScreenFailed =>
      'Der Google-Bildschirm konnte nicht geöffnet werden. Erneut '
      'versuchen.';

  @override
  String get authConfigIncomplete =>
      'Die Konfiguration der Google-Anmeldung ist unvollständig.';

  @override
  String get authServicesUnavailable =>
      'Google-Dienste auf diesem Gerät nicht verfügbar.';

  @override
  String get authWrongAccount =>
      'Das gewählte Konto unterscheidet sich vom verwendeten Konto.';

  @override
  String get emptyDocuments => 'Noch keine Dokumente';

  @override
  String get emptyDrawings => 'Noch keine Zeichnungen';

  @override
  String get emptyLetters => 'Noch keine Briefe';

  @override
  String get emptyPhotos => 'Noch keine Fotos';

  @override
  String get emptySealed => 'Noch nichts versiegelt';

  @override
  String get emptyMoments => 'Hier steht nichts aus';

  @override
  String get emptyInspirations => 'Hier gibt es jetzt nichts';

  @override
  String get emptySearchTopic => 'Dazu noch nichts';

  @override
  String get firstPhotosHint =>
      'Tippen Sie auf das +, um die ersten Fotos hinzuzufügen.';

  @override
  String daysLeft(int dias) => dias == 1 ? 'Noch 1 Tag' : 'Noch $dias Tage';

  @override
  String daysLeftWithDate(int dias, String data) => 'Noch $dias Tage, $data';

  @override
  String remindersSummaryFull(int marcados, int total, int hora) =>
      '$marcados von $total Arten, um $hora Uhr';

  @override
  String contarSemanas(int n) => n == 1 ? '1 Woche' : '$n Wochen';

  @override
  String semanaNumero(int n) => 'Woche $n';

  @override
  String mesNumero(int n) => 'Monat $n';

  @override
  String uploadWithDate(String oQue, String data) =>
      '$oQue mit dem Datum $data.';

  @override
  String uploadBornThatDay(String nome) =>
      'Das war der Tag, an dem $nome geboren wurde.';

  @override
  String uploadBornThatDayGeneric() => 'Das war der Tag der Geburt.';

  @override
  String uploadAgeThen(String nome, String idade) =>
      'An diesem Datum war $nome $idade alt.';

  @override
  String uploadAgeThenGeneric(String idade) => 'Alter an diesem Datum: $idade.';

  @override
  String uploadWhereInDrive(String caminho) =>
      'Im Drive landet das unter $caminho.';

  @override
  String get holidayNewYear => 'Neujahr';

  @override
  String get holidayCarnival => 'Karneval';

  @override
  String get holidayEaster => 'Ostern';

  @override
  String get holidayMothers => 'Muttertag';

  @override
  String get holidayFathers => 'Vatertag';

  @override
  String get holidayChristmas => 'Weihnachten';

  @override
  String get kindLetter => 'Briefidee';

  @override
  String get kindReading => 'Lesestoff';

  @override
  String get kindPrep => 'Vorbereitung';

  @override
  String get kindRoutine => 'Routine und Organisation';

  @override
  String get kindEveryday => 'Aus dem Alltag';

  @override
  String get kindPlay => 'Spiel';

  @override
  String get notifChannelName => 'Erinnerungen der Kapsel';

  @override
  String get notifChannelDescription =>
      'Runde Daten, Geburtstage und Erinnerungen, eine Erinnerung zu '
      'speichern.';

  @override
  String get errPhotoCompress => 'Dieses Foto konnte nicht komprimiert werden.';

  @override
  String get errVideoConvert => 'Dieses Video konnte nicht konvertiert werden.';

  @override
  String get errOriginalsMissing =>
      'Die Originaldateien befinden sich nicht auf diesem Gerät.';

  @override
  String get errPickPhotoAgain =>
      'Wählen Sie das Foto erneut aus, um es zu speichern.';

  @override
  String get errOriginalsMissingFull =>
      'Die Originaldateien befinden sich nicht auf diesem Gerät. Senden '
      'Sie sie erneut von dem Handy, auf dem sie ausgewählt wurden.';

  @override
  String get errFileGoneFull =>
      'Die Datei hat dieses Gerät verlassen, bevor die Übertragung '
      'abgeschlossen war. Wählen Sie das Foto erneut aus, um es zu '
      'speichern.';

  @override
  String get kindOuting => 'Ausflug und frische Luft';

  @override
  String get kindPhoto => 'Fotoidee';

  @override
  String get reminderRoundLabel => 'Runde Daten';

  @override
  String get reminderRoundDesc => 'Monatstage und der Wechsel jedes Jahres';

  @override
  String get reminderBirthdayLabel => 'Geburtstag';

  @override
  String get reminderBirthdayDesc => 'Eine Woche vorher und am selben Tag';

  @override
  String get reminderSpecialLabel => 'Erste Male des Jahres';

  @override
  String get reminderSpecialDesc => 'Weihnachten, Ostern, Muttertag';

  @override
  String get reminderInspirationLabel => 'Ideen zur richtigen Zeit';

  @override
  String get reminderInspirationDesc => 'Wenn eine Idee nur jetzt passt';

  @override
  String get reminderAbsenceLabel => 'Sanfte Erinnerung';

  @override
  String get reminderAbsenceDesc => 'Wenn lange nichts mehr gespeichert wurde';

  @override
  String get reminderInactiveLabel => 'Das Google-Konto';

  @override
  String get reminderInactiveDesc =>
      'Ein Hinweis pro Jahr, damit die Kapsel nicht verloren geht';

  @override
  String get notifWeekLeftTitle => 'Noch eine Woche';

  @override
  String get notifBirthdayTodayGeneric =>
      'Es ist heute. Speichern Sie etwas von diesem Tag.';

  @override
  String get notifMomentTitle => 'Ein Augenblick von heute';

  @override
  String get notifInactiveTitle => 'Die Kapsel braucht Sie für eine Minute';

  @override
  String get notifPhotoWorthIt =>
      'Ein Foto von heute wird in zwanzig Jahren viel wert sein.';

  @override
  String get notifAbsenceGeneric =>
      'Es ist eine Weile her seit der letzten Erinnerung. Ein '
      'beliebiges Foto, ganz gleich wie der Tag verläuft, reicht schon.';

  @override
  String get notifInactiveGeneric =>
      'Es ist fast ein Jahr her, dass Sie zuletzt geöffnet haben. Google '
      'löscht ungenutzte Konten nach zwei Jahren, und in einem davon '
      'wohnen die Erinnerungen. Gelegentliches Öffnen reicht schon.';

  @override
  String get theChild => 'das Kind';

  @override
  String notifFirstBirthdaySoon(String quem) =>
      'Der erste Geburtstag $quem ist in sieben Tagen. Guter Zeitpunkt, '
      'um die Fotos des ersten Jahres auszuwählen.';

  @override
  String notifBirthdaySoon(String quem, int anos) =>
      '$quem wird in sieben Tagen $anos Jahre alt.';

  @override
  String notifBirthdayTitle(int anos) =>
      anos == 1 ? 'Ein Jahr heute' : '$anos Jahre heute';

  @override
  String notifBirthdayToday(String deQuem) =>
      'Heute ist der Tag $deQuem. Speichern Sie etwas von diesem Tag.';

  @override
  String notifMonthsTitle(int meses) =>
      meses == 1 ? '1 Monat heute' : '$meses Monate heute';

  @override
  String notifMonthsBody(String nome, int meses) =>
      '$nome wird heute ${contarMeses(meses)} alt. Ein Foto von heute '
      'wird in zwanzig Jahren viel wert sein.';

  @override
  String notifFirstHolidayTitle(String data) => 'Der erste $data';

  @override
  String notifFirstHolidayBody(String data, String deQuem) =>
      'In drei Tagen ist der erste $data $deQuem. Ein Foto lohnt sich.';

  @override
  String notifFirstHolidayBodyGeneric(String data) =>
      'In drei Tagen ist der erste $data. Ein Foto lohnt sich.';

  @override
  String notifAbsenceBody(String deQuem) =>
      'Es ist eine Weile her seit der letzten Erinnerung $deQuem. Ein '
      'beliebiges Foto, ganz gleich wie der Tag verläuft, reicht schon.';

  @override
  String notifInactiveBody(String deQuem) =>
      'Es ist fast ein Jahr her, dass Sie zuletzt geöffnet haben. Google '
      'löscht ungenutzte Konten nach zwei Jahren, und in einem davon '
      'wohnen die Erinnerungen $deQuem. Gelegentliches Öffnen reicht '
      'schon.';

  @override
  String tituloDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'Das erste Weihnachtsfest',
    'primeiro-ano-novo' => 'Das erste Neujahr',
    'primeiro-carnaval' => 'Der erste Karneval',
    'primeira-pascoa' => 'Das erste Osterfest',
    'primeiro-dia-das-maes' => 'Der erste Muttertag',
    'primeiro-dia-dos-pais' => 'Der erste Vatertag',
    'primeiro-aniversario' => 'Den ersten Geburtstag vorbereiten',
    'primeiro-sorriso' => 'Das erste Lächeln',
    'primeiro-dentinho' => 'Das erste Zähnchen',
    'primeira-palavra' => 'Das erste Wort',
    'primeiros-passos' => 'Die ersten Schritte',
    'primeiro-corte-cabelo' => 'Der erste Haarschnitt',
    'primeira-viagem' => 'Die erste Reise',
    'primeira-praia' => 'Der erste Strandbesuch',
    'primeira-escola' => 'Der erste Schultag',
    'primeira-bicicleta' => 'Das erste Fahrrad',
    _ => id,
  };

  @override
  String? notaDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'Das erste Weihnachtsfest {nome} steht bevor.',
    'primeiro-ano-novo' => 'Der erste Jahreswechsel {nome}.',
    'primeiro-carnaval' => 'Ein Kostüm, ein Foto, fertig.',
    'primeiro-dia-das-maes' =>
      'Wie wäre es mit einem Brief, den {nome} in vielen Jahren lesen '
          'wird?',
    'primeiro-aniversario' => 'Das erste Lebensjahr {nome} steht bevor.',
    'primeiro-sorriso' => 'Erscheint meist um die sechste Woche.',
    'primeira-palavra' =>
      'Nehmen Sie die Stimme {nome} auf. In zwanzig Jahren ist das '
          'unbezahlbar.',
    'primeiros-passos' => 'Lohnt sich mehr im Video als im Foto.',
    'primeiro-corte-cabelo' => 'Vorher und nachher, wenn möglich.',
    _ => null,
  };

  @override
  List<String> checklistDoAniversario() => <String>[
    'Das Motto wählen',
    'Die Gästeliste festlegen',
    'Die Torte aussuchen',
    'Die Kleidung kaufen',
    'Ein Video aufnehmen',
    'Einen Brief für die Zukunft schreiben',
  ];

  @override
  String get languageStepTitle => 'In welcher Sprache?';

  @override
  String get languageStepNote =>
      'Gilt für die gesamte App und für die Namen der Ordner in Google '
      'Drive. Die Ordner behalten für immer die jetzige Sprache, auch '
      'wenn Sie die der App später ändern.';
}
