import 'textos.dart';

/// L'app in italiano.
///
/// Scritto come italiano, e non come portoghese tradotto parola per parola.
/// Dove la frase portoghese dipendeva da un accordo di genere risolto in
/// modo diverso, la frase è stata riscritta per dire la stessa cosa nel modo
/// in cui si dice qui.
///
/// **Il nome della cartella su Google Drive non è qui, e non deve esserci.**
/// È una costante di `DriveService`, in portoghese, e resta così per tutti:
/// tradurlo farebbe sì che l'app cerchi una cartella con un altro nome e
/// lasci indietro tutto ciò che la famiglia ha già conservato.
class TextosIt implements Textos {
  const TextosIt();

  @override
  String get codigo => 'it';

  @override
  String get appName => 'Mio Bebè';

  @override
  String get appFullName => 'Mio Bebè: Capsula del Tempo';

  @override
  String get appSubtitle => 'Capsula del Tempo';

  @override
  String get appTagline => 'Ogni momento, un ricordo per tutta la vita.';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get signInNote =>
      'Tutti i ricordi verranno salvati nell\'account Google Drive di '
      'tuo figlio/a.';

  @override
  String get signInError =>
      'Non è stato possibile accedere. Controlla la connessione e '
      'riprova.';

  @override
  String get onboardingGreeting => 'Ciao!';

  @override
  String get fullName => 'Nome completo';

  @override
  String get gender => 'Maschio o femmina?';

  @override
  String get birthDate => 'Data di nascita';

  @override
  String get birthTime => 'Ora di nascita';

  @override
  String get birthWeight => 'Peso alla nascita';

  @override
  String get birthHeight => 'Altezza alla nascita';

  @override
  String get birthTimeOptional => 'Ora di nascita (facoltativo)';

  @override
  String get birthWeightOptional => 'Peso alla nascita (facoltativo)';

  @override
  String get birthHeightOptional => 'Altezza alla nascita (facoltativo)';

  @override
  String get hospitalOptional => 'Ospedale (facoltativo)';

  @override
  String get birthPhoto => 'Foto della nascita';

  @override
  String get continueLabel => 'Continua';

  @override
  String get preparingDrive => 'Preparazione delle cartelle su Google Drive...';

  @override
  String get home => 'Home';

  @override
  String get timeline => 'Cronologia';

  @override
  String get search => 'Cerca';

  @override
  String get accountsLabel => 'ACCOUNT';

  @override
  String get switchAccount => 'Cambia account';

  @override
  String get profile => 'Profilo';

  @override
  String get photos => 'Foto';

  @override
  String get videos => 'Video';

  @override
  String get letters => 'Lettere';

  @override
  String get drawings => 'Disegni';

  @override
  String get documents => 'Documenti';

  @override
  String get growth => 'Crescita';

  @override
  String get stats => 'Statistiche';

  @override
  String get trash => 'Cestino';

  @override
  String get settings => 'Impostazioni';

  @override
  String get about => 'Informazioni sull\'app';

  @override
  String get signOut => 'Esci';

  @override
  String get storedWithLove => 'Conservato con amore nel Drive di';

  @override
  String get addQuestion => 'Cosa vuoi aggiungere?';

  @override
  String get addPhoto => 'Foto';

  @override
  String get addVideo => 'Video';

  @override
  String get addLetter => 'Lettera';

  @override
  String get addDrawing => 'Disegno';

  @override
  String get addDrawingHint => 'Aggiungi un disegno';

  @override
  String get addDocument => 'Documento';

  @override
  String get addDocumentHint => 'Aggiungi documenti importanti';

  @override
  String get addGrowth => 'Crescita';

  @override
  String get addGrowthHint => 'Registra peso e altezza';

  @override
  String get timelineEmptyTitle => 'La storia inizia qui';

  @override
  String get birth => 'Nascita';

  @override
  String get photosAdded => 'Foto aggiunte';

  @override
  String get photoAdded => 'Foto aggiunta';

  @override
  String get videoAdded => 'Video aggiunto';

  @override
  String get drawingAdded => 'Disegno aggiunto';

  @override
  String get documentAdded => 'Documento aggiunto';

  @override
  String get growthRecord => 'Registrazione di crescita';

  @override
  String get letterPrefix => 'Lettera:';

  @override
  String get filterAll => 'Tutto';

  @override
  String get filterTitle => 'Filtra per tipo';

  @override
  List<String> get milestoneSuggestions => <String>[
    'Prima foto',
    'Primo bagnetto',
    'Prima uscita',
    'Primo viaggio',
    'Primo sorriso',
    'Primo dentino',
    'Primi passi',
    'Prima parola',
    'Primo compleanno',
  ];

  @override
  String get letterStartersTitle => 'Non sai come iniziare?';

  @override
  List<String> get letterStarters => <String>[
    'Oggi voglio raccontarti di ',
    'Quando leggerai questo, ',
    'Ancora non lo sai, ma ',
    'Una cosa che non voglio mai dimenticare: ',
    'Se potessi dirti solo una cosa, sarebbe ',
    'Il giorno in cui tu ',
    'Di come sei oggi, quello che amo di più è ',
  ];

  @override
  String get titleField => 'Titolo';

  @override
  String get messageField => 'Messaggio';

  @override
  String get descriptionOptional => 'Descrizione (facoltativo)';

  @override
  String get milestoneOptional => 'Traguardo (facoltativo)';

  @override
  String get weightField => 'Peso';

  @override
  String get heightField => 'Altezza';

  @override
  String get photoOptional => 'Foto (facoltativo)';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get edit => 'Modifica';

  @override
  String get share => 'Condividi';

  @override
  String get delete => 'Elimina';

  @override
  String get restore => 'Ripristina';

  @override
  String get view => 'Visualizza';

  @override
  String get download => 'Scarica';

  @override
  String get retry => 'Riprova';

  @override
  String get weeks => 'Settimane';

  @override
  String get months => 'Mesi';

  @override
  String get years => 'Anni';

  @override
  String get photosOptimizedNote =>
      'Le foto vengono compresse automaticamente per ottimizzare lo '
      'spazio.';

  @override
  String get videoOptimizedNote =>
      'Questo video è stato salvato in 540p per ottimizzare lo spazio.';

  @override
  String get allFilesOptimizedNote =>
      'Tutti i file vengono ottimizzati per risparmiare spazio.';

  @override
  String get uploadPending => 'In attesa di invio';

  @override
  String get uploadOptimizing => 'Ottimizzazione...';

  @override
  String get uploadSending => 'Invio in corso...';

  @override
  String get uploadFailed => 'Invio non riuscito';

  @override
  String get uploadingCount => 'Invio in corso';

  @override
  String get searchHint => 'Cerca ricordi...';

  @override
  String get searchByCategory => 'Cerca per categoria';

  @override
  String get recentSearches => 'Ricerche recenti';

  @override
  String get searchEmpty => 'Non è stato trovato nulla qui.';

  @override
  String get clearHistory => 'Cancella cronologia';

  @override
  String get storageUsed => 'Spazio utilizzato';

  @override
  String get storageOf => 'di';

  @override
  String get capsuleStorage => 'Capsula del Tempo';

  @override
  String get driveStorage => 'Il tuo Google Drive';

  @override
  String get driveStorageNote =>
      'Il totale sopra riguarda tutto il tuo account Google. L\'app vede '
      'solo i file che ha creato lei stessa, all\'interno della cartella '
      'della capsula. Non ha accesso al resto del tuo Drive.';

  @override
  String get lockSection => 'Privacy';

  @override
  String get lockTitle => 'Blocco dell\'app';

  @override
  String get lockBody =>
      'Richiede l\'impronta, il volto o il PIN del dispositivo per '
      'aprire l\'app. Di default è disattivato.';

  @override
  String get lockUnavailable =>
      'Questo dispositivo non ha impronta, volto né PIN configurati. '
      'Configura un blocco nelle impostazioni Android per poter '
      'utilizzare questa opzione.';

  @override
  String get lockNote =>
      'Il blocco protegge da chi prende in mano il tuo telefono già '
      'sbloccato. Non cifra nulla: è una porta in più, non una '
      'cassaforte.';

  @override
  String get lockFailed =>
      'Non è stato possibile confermare. Il blocco resta disattivato.';

  @override
  String get lockReason => 'Conferma che sei tu per aprire i ricordi.';

  @override
  String get lockedTitle => 'App bloccata';

  @override
  String get lockedBody => 'Conferma la tua identità per vedere i ricordi.';

  @override
  String get unlock => 'Sblocca';

  @override
  String get viewChart => 'Vedi grafico';

  @override
  String get growthChart => 'Grafico di crescita';

  @override
  String get growthEmptyTitle => 'Ancora nessuna registrazione';

  @override
  String get growthEmptyBody =>
      'Registra il peso e l\'altezza per seguire la crescita.';

  @override
  String get trashEmptyTitle => 'Il cestino è vuoto';

  @override
  String get trashEmptyBody =>
      'Gli elementi eliminati restano qui finché non li rimuovi '
      'definitivamente.';

  @override
  String get trashNote => 'I file vanno anche nel cestino di Google Drive.';

  @override
  String get deleteForever => 'Elimina definitivamente';

  @override
  String get deleteConfirmTitle => 'Eliminare questo elemento?';

  @override
  String get deleteConfirmBody =>
      'Andrà nel cestino e potrà essere ripristinato in seguito.';

  @override
  String get deleteForeverConfirmBody =>
      'Questa azione non può essere annullata.';

  @override
  String get currentAge => 'Età attuale';

  @override
  String get birthDateShort => 'Nascita';

  @override
  String get signOutConfirmTitle => 'Uscire dall\'account?';

  @override
  String get signOutConfirmBody =>
      'I tuoi ricordi restano salvati nel tuo Google Drive. Le miniature '
      'e i file scaricati vengono rimossi da questo dispositivo.';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get termsOfUse => 'Termini di utilizzo';

  @override
  String get accountDeletionTitle => 'Eliminazione dell\'account e dei dati';

  @override
  String get accountDeletionShort => 'Elimina account';

  @override
  String get goToDeleteAccount => 'Vai all\'eliminazione dell\'account';

  @override
  String get deleteAccount => 'Elimina il mio account e i miei dati';

  @override
  String get deleteAccountTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountBody =>
      'Eliminiamo dal nostro server tutto ciò che conserviamo su di te: '
      'il profilo, la cronologia, le registrazioni di crescita e il '
      'testo delle lettere. Rinunciamo anche all\'autorizzazione di '
      'accesso al tuo Google Drive.\n\n'
      'Questa azione non può essere annullata.';

  @override
  String get deleteAccountDriveQuestion =>
      'E la cartella "Meu Bebê - Cápsula do Tempo" nel tuo Drive?';

  @override
  String get deleteAccountKeepDrive => 'Mantieni i file';

  @override
  String get deleteAccountKeepDriveHint =>
      'Le foto, i video e i documenti restano nel tuo Drive, organizzati '
      'per età. Consigliato.';

  @override
  String get deleteAccountTrashDrive => 'Sposta nel cestino';

  @override
  String get deleteAccountTrashDriveHint =>
      'La cartella va nel cestino di Google Drive e può essere '
      'recuperata per 30 giorni.';

  @override
  String get deleteAccountWorking => 'Eliminazione in corso...';

  @override
  String get deleteAccountDone => 'Account eliminato.';

  @override
  String get genericError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get noItemsYet => 'Ancora niente qui.';

  @override
  String get requiredField => 'Compila questo campo';

  @override
  String get invalidNumber => 'Inserisci un numero valido';

  @override
  String get codigoIntl => 'it';

  @override
  String get padraoData => 'dd/MM/yyyy';

  @override
  String get padraoDiaMes => 'dd/MM';

  @override
  String get padraoDataLonga => 'd MMMM yyyy';

  @override
  String get padraoMesAno => 'MMMM yyyy';

  @override
  String get padraoHora => 'HH:mm';

  @override
  String get entreDatas => 'al';

  @override
  String get hoje => 'Oggi';

  @override
  String get ontem => 'Ieri';

  @override
  String saudacao(int hora) {
    if (hora < 12) return 'Buongiorno';
    if (hora < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  @override
  String haTempo(int dias) {
    if (dias <= 0) return 'oggi';
    if (dias == 1) return 'ieri';
    if (dias < 14) return '$dias giorni fa';
    if (dias < 60) {
      final int semanas = dias ~/ 7;
      return semanas == 1 ? '1 settimana fa' : '$semanas settimane fa';
    }
    if (dias < 365) {
      final int meses = dias ~/ 30;
      return meses == 1 ? '1 mese fa' : '$meses mesi fa';
    }
    final int anos = dias ~/ 365;
    return anos == 1 ? '1 anno fa' : '$anos anni fa';
  }

  @override
  String ordinal(int n) => switch (n) {
    1 => 'primo',
    2 => 'secondo',
    3 => 'terzo',
    4 => 'quarto',
    5 => 'quinto',
    6 => 'sesto',
    7 => 'settimo',
    8 => 'ottavo',
    9 => 'nono',
    10 => 'decimo',
    _ => '$nº',
  };

  @override
  String contarDias(int n) => n == 1 ? '1 giorno' : '$n giorni';

  @override
  String contarMeses(int n) => n == 1 ? '1 mese' : '$n mesi';

  @override
  String contarAnos(int n) => n == 1 ? '1 anno' : '$n anni';

  @override
  String contarItens(int n) => n == 1 ? '1 elemento' : '$n elementi';

  @override
  String contarFotos(int n) => n == 1 ? '1 foto' : '$n foto';

  @override
  String contarVideos(int n) => n == 1 ? '1 video' : '$n video';

  @override
  String get lastBirth => 'Ultima nascita';

  @override
  String get lastPhoto => 'Ultima foto';

  @override
  String get lastVideo => 'Ultimo video';

  @override
  String get lastLetter => 'Ultima lettera';

  @override
  String get lastDrawing => 'Ultimo disegno';

  @override
  String get lastDocument => 'Ultimo documento';

  @override
  String get lastGrowth => 'Ultima misurazione';

  @override
  String get oneVideo => 'video';

  @override
  String get oneGrowth => 'misurazione';

  @override
  String get imageOpenFailed => 'Non è stato possibile aprire questa immagine.';

  @override
  String get videoOpenFailed => 'Non è stato possibile aprire questo video.';

  @override
  String get documentNotFound => 'Documento non trovato';

  @override
  String get letterNotFound => 'Lettera non trovata';

  @override
  String get entryNotFound => 'Ricordo non trovato';

  @override
  String get driveSpaceFailed =>
      'Non è stato possibile leggere lo spazio di Google Drive.';

  @override
  String get firstVideoHint => 'Tocca il + per aggiungere il primo video.';

  @override
  String get documentsEmptyBody =>
      'Certificato di nascita, libretto delle vaccinazioni, passaporto: '
      'tutto in un unico posto.';

  @override
  String get isToday => 'È oggi';

  @override
  String get isTodayBang => 'È oggi!';

  @override
  String get tomorrow => 'Domani';

  @override
  String get nextMilestone => 'Prossimo traguardo';

  @override
  String faltamDias(int dias) => 'Tra ${contarDias(dias)}';

  @override
  String get seeInspiration => 'Vedi ispirazione';

  @override
  String get forYou => 'Per te';

  @override
  String get notYet => 'non ancora';

  @override
  String get inspirations => 'Ispirazioni';

  @override
  String get inspirationsLoadFailed => 'Non è stato possibile caricare le idee';

  @override
  String get inspirationSearchHint => 'Cosa vuoi sapere?';

  @override
  String get suggestionsByAge =>
      'I suggerimenti compaiono in base all\'età e al calendario.';

  @override
  String get notNow => 'Non ora';

  @override
  String get savedTitle => 'È salvato';

  @override
  String get willBeSaved => 'Verrà salvato';

  @override
  String get sendMemoryError => 'Invia ricordo';

  @override
  String get dateFromFile => 'Data letta dal file stesso. Tocca per cambiarla.';

  @override
  String get deletedOn => 'Eliminato il ';

  @override
  String get itemDeleted => 'Elemento eliminato.';

  @override
  String get documentNameSuggestion => 'Certificato di nascita';

  @override
  String get saveInfo => 'Salva informazioni';

  @override
  String get editInfo => 'Modifica informazioni';

  @override
  String get notProvided => 'Non indicata';

  @override
  String get automatic => 'Automatica';

  @override
  String get reviewIntro => 'Rivedi la presentazione';

  @override
  String get lastUpdatedLabel => 'Ultimo aggiornamento';

  @override
  String get optimization => 'Ottimizzazione';

  @override
  String get photoMaxSide => 'Fino a 960 px sul lato maggiore';

  @override
  String get optimizationNote =>
      'L\'ottimizzazione è automatica e non può essere disattivata: è '
      'quello che mantiene la raccolta leggera per molti anni.';

  @override
  String get languageSection => 'Lingua';

  @override
  String get clearCacheBody =>
      'Cancella miniature, file temporanei e i documenti già scaricati. '
      'Nulla va perso: tutto resta su Google Drive.';

  @override
  String get cacheCleared => 'Cache svuotata.';

  @override
  String get clearCache => 'Svuota cache';

  @override
  String get storageOnDevice => 'Spazio sul dispositivo';

  @override
  String get remindersSection => 'Promemoria';

  @override
  String get remindersOff => 'Disattivati';

  @override
  String get startupFailedTitle => 'L\'app non è riuscita ad avviarsi';

  @override
  String get technicalDetail => 'Dettaglio tecnico';

  @override
  String get premiumInviteAction => 'Capito';

  @override
  String get introTitle1 => 'L\'infanzia passa in fretta.';

  @override
  String get introTitle2 => 'Ogni ricordo ha il suo posto.';

  @override
  String get introBody2 =>
      'Foto, video, lettere, disegni, documenti e registrazioni di '
      'crescita. Tutto riunito in un unico posto.';

  @override
  String get introTitle3 => 'Ogni ricordo al suo momento.';

  @override
  String get introTitle4 => 'Creiamo questa capsula?';

  @override
  String get sealBody =>
      'Questo resta chiuso fino alla data che sceglierai. Il contenuto '
      'resta nel tuo Drive, e puoi aprirlo prima se vuoi: è un sigillo, '
      'come quello di una capsula sepolta in giardino, non una '
      'cassaforte.';

  @override
  String get aboutPhotos =>
      'Nessuna foto passa da un nostro server: vanno direttamente dal '
      'telefono a Google Drive.';

  @override
  String get aboutScope =>
      'L\'app non vede il resto del tuo Drive. Il permesso che concedi '
      'dà accesso solo ai file che essa stessa crea, tutti dentro la '
      'cartella "Meu Bebê - Cápsula do Tempo". Le tue altre cartelle '
      'sono invisibili per lei.';

  @override
  String get aboutIndex =>
      'Ciò che resta sul nostro server è l\'indice: nome, data di '
      'nascita, peso, altezza, date e il testo delle lettere. È ciò che '
      'fa funzionare la cronologia e la ricerca. Puoi eliminare tutto '
      'questo in qualsiasi momento, nel tuo profilo.';

  @override
  String get aboutLastingTitle => 'Perché la capsula duri';

  @override
  String get deleteDriveNote =>
      'Anche mandati nel cestino, i file sono tuoi e restano nel tuo '
      'Drive: l\'app non ne ha mai avuto una copia.';

  @override
  String get profilePhotoNote =>
      'La foto del profilo proviene dai ricordi già salvati. Aggiungi '
      'una foto per poterne scegliere una.';

  @override
  String get remindersHowTitle => 'Su cosa';

  @override
  String get remindersMarkedTitle => 'Cosa è selezionato';

  @override
  String get remindersFrequency =>
      'Al massimo due a settimana, mai due nello stesso giorno.';

  @override
  String get remindersOffNote =>
      'Disattivato. Non viene inviato nulla. Se il telefono ha negato le '
      'notifiche, abilitale in Impostazioni, App, Meu Bebê.';

  @override
  String get remindersNothingSoon =>
      'Nulla nelle prossime settimane. È normale: i promemoria '
      'compaiono solo quando una data è davvero vicina.';

  @override
  String get remindersPrivacy =>
      'I promemoria vengono calcolati sul tuo telefono, a partire da ciò '
      'che è già qui. Per questo non viene inviato nulla a nessun '
      'server, e nessuna notifica cita ciò che hai salvato.';

  @override
  String get remindersDenied =>
      'Android non ha autorizzato le notifiche. Puoi abilitarle nelle '
      'impostazioni del telefono, in App, Meu Bebê.';

  @override
  String get sealedEmptyBody =>
      'Salvando una lettera o un video, puoi scegliere una data in cui '
      'si aprirà: un compleanno, la maggiore età, o qualsiasi altra '
      'data. Resta qui in attesa fino ad allora.';

  @override
  String get growthChartHint =>
      'A partire da due registrazioni, il grafico inizia a raccontare '
      'la storia.';

  @override
  String get introBody1 =>
      'Conserva i piccoli momenti prima che diventino solo ricordi.';

  @override
  String get introTitle4b => 'Un regalo per il futuro.';

  @override
  String get introBody3 =>
      'Organizziamo tutto in base all\'età in cui è avvenuto, formando '
      'una vera cronologia dell\'infanzia.';

  @override
  String get introBody4 =>
      'Un giorno, questa capsula potrà essere aperta da chi conta di '
      'più: tuo figlio.';

  @override
  String get introBody5 =>
      'Ti consigliamo di usare un account Google dedicato per conservare '
      'tutti questi ricordi per molti anni.';

  @override
  String get premiumInviteLetters => 'Le lettere fanno parte del piano Premium';

  @override
  String get premiumInviteDrawings => 'I disegni fanno parte del piano Premium';

  @override
  String get premiumInviteDocuments =>
      'I documenti fanno parte del piano Premium';

  @override
  String get premiumInviteGrowth => 'La crescita fa parte del piano Premium';

  @override
  String get premiumInviteGeneric => 'Questo fa parte del piano Premium';

  @override
  String get premiumInvitePrice =>
      'È un abbonamento annuale, addebitato e gestito da Google Play, '
      'che mostra il prezzo nella valuta del tuo paese.';

  @override
  String get premiumInviteKeeps =>
      'Senza di esso non sparisce nulla: le foto e i video restano '
      'liberi, e tutto ciò che è già salvato resta accessibile per '
      'sempre.';

  @override
  String get documentNameQuestion => 'Come vuoi chiamare';

  @override
  String get videosLabel => 'Video';

  @override
  String get sendMemory => 'Invia ricordo';

  @override
  String get languageNote =>
      'La scelta viene salvata su questo dispositivo e vale per tutte le '
      'schermate. Le cartelle già create in Google Drive mantengono i nomi '
      'che hanno ricevuto.';

  @override
  String get videoOptimizedShort => '540p con bitrate ottimizzato';

  @override
  String get originalFiles => 'File originali';

  @override
  String get originalFilesNote => 'Restano sul telefono, intatti';

  @override
  String get loginCapsuleHint =>
      'Per creare l\'account della capsula: tocca qui sotto, e nella '
      'schermata Google scegli Aggiungi un altro account.';

  @override
  String get startupFirebaseHint =>
      'Questo è quasi sempre una configurazione di Firebase: il file '
      'google-services.json e il file firebase_options.dart devono '
      'appartenere allo stesso progetto, e Firestore e l\'accesso con '
      'Google devono essere attivati nella console.';

  @override
  String get sentToDrive => 'È salvato';

  @override
  String get dateNotFoundMedia =>
      'Non abbiamo trovato la data all\'interno del file multimediale, '
      'quindi vale quella di oggi. Tocca per cambiarla.';

  @override
  String get dateNotFoundFile =>
      'Non abbiamo trovato la data all\'interno del file, quindi vale '
      'quella di oggi. Tocca per cambiarla.';

  @override
  String inspirationsSubtitle(String nome) =>
      'Idee per la fase che $nome sta vivendo ora.';

  @override
  String suggestionsGrowNote(String nome) =>
      'I suggerimenti tornano mentre $nome cresce e le date si '
      'avvicinano.';

  @override
  String remindersIntroNamed(String nome) =>
      'I promemoria arrivano attivati perché una capsula del tempo '
      'mantiene la promessa solo se qualcuno ci torna. Sono pochi, ed '
      'esistono perché tu non perda il giorno in cui $nome compie un '
      'altro mese.';

  @override
  String remindersHourNote(int hora) =>
      'Sempre tra le 8 e le $hora. L\'app non sveglia nessuno nel cuore '
      'della notte.';

  @override
  String remindersSummary(int marcados, int total, int hora) =>
      '$marcados di $total tipi, alle $hora';

  @override
  String birthdayOrdinal(int anos) => 'Per il ${ordinal(anos)} compleanno';

  @override
  String todayWithDate(String data) => 'È oggi, $data';

  @override
  String tomorrowWithDate(String data) => 'Domani, $data';

  @override
  String searchNoResults(String termo) =>
      'Non abbiamo trovato nessun post con "$termo".';

  @override
  String growthFromBirth(String data) => 'Dalla nascita fino al $data';

  @override
  String savedInDrive(String dono) => 'È salvato $dono.';

  @override
  String lastUpdated(String data) => 'Ultimo aggiornamento: $data';

  @override
  String batchManyDays(int dias) =>
      'Attenzione: quello che hai scelto proviene da $dias giorni '
      'diversi, e tutto verrà salvato con questa data. Per separarli, '
      'invia un giorno alla volta.';

  @override
  String get inspirationsSubtitleGeneric => 'Idee per la fase attuale.';

  @override
  String willBeSavedIn(String dono) => 'Verrà salvato $dono.';

  @override
  String get remindersIntroGeneric =>
      'I promemoria arrivano attivati perché una capsula del tempo '
      'mantiene la promessa solo se qualcuno ci torna. Sono pochi, ed '
      'esistono per le date che passano senza che nessuno se ne accorga.';

  @override
  String get sealedEmptyIntro =>
      'Salvando una lettera o un video, puoi scegliere una data di '
      'apertura: i 15 anni, i 18, o qualsiasi altra data. Resta qui in '
      'attesa fino ad allora.';

  @override
  String get aboutPhotosNote =>
      'Nessuna foto passa da un nostro server: vanno direttamente dal '
      'tuo dispositivo al Google Drive del tuo account.';

  @override
  String get profilePhotoEmpty =>
      'La foto del profilo proviene dai ricordi già salvati. Aggiungi '
      'una foto per poterne scegliere una.';

  @override
  String remindersHourRange(int inicio, int fim) =>
      'Tra le $inicio e le $fim. L\'app non sveglia nessuno nel cuore '
      'della notte.';

  @override
  String get typeOneBirth => 'nascita';

  @override
  String get typeOnePhoto => 'foto';

  @override
  String get typeOneLetter => 'lettera';

  @override
  String get typeOneDrawing => 'disegno';

  @override
  String get typeOneDocument => 'documento';

  @override
  String get typeManyBirths => 'nascite';

  @override
  String get typeManyPhotos => 'foto';

  @override
  String get typeManyVideos => 'video';

  @override
  String get typeManyLetters => 'lettere';

  @override
  String get typeManyDrawings => 'disegni';

  @override
  String get typeManyDocuments => 'documenti';

  @override
  String get typeManyGrowth => 'misurazioni';

  @override
  String get theGrowth => 'la crescita';

  @override
  String get documentNameQuestionFull => 'Come vuoi chiamare';

  @override
  String get loginCreateAccountHint =>
      'Per creare l\'account della capsula: tocca qui sotto, e nella '
      'finestra di Google scegli "Aggiungi un altro account" e poi '
      '"Crea account".';

  @override
  String get aboutInactivity =>
      'Google elimina gli account inutilizzati da due anni, e con essi '
      'tutto ciò che si trova nel loro Drive. Questo vale soprattutto '
      'per chi ha creato un account solo per la capsula.\n\nAprire '
      'questa app di tanto in tanto conta già come utilizzo, quindi non '
      'serve fare altro. Ciò nonostante, se passi quasi un anno senza '
      'accedere, l\'app avvisa una volta, e questo avviso può essere '
      'disattivato in Impostazioni.';

  @override
  String get profilePhotoFromMemories =>
      'La foto del profilo proviene dai ricordi già salvati. Aggiungi '
      'una foto e apparirà qui.';

  @override
  String premiumInviteWhat(String tipos, String deQuem, String outros) =>
      'Salvare $tipos nella capsula$deQuem fa parte del Premium, insieme '
      'a $outros.';

  @override
  String profilePhotoEmptyOf(String deQuem) =>
      'La foto del profilo proviene dai ricordi già salvati. Aggiungi '
      'una foto $deQuem e apparirà qui.';

  @override
  String comArtigo(String plural) => 'i $plural';

  @override
  String get errNoConnection => 'Nessuna connessione a internet. Riprova.';

  @override
  String get errFileRead =>
      'Non è stato possibile leggere il file sul dispositivo.';

  @override
  String get errPermissionDenied =>
      'Il server ha rifiutato il salvataggio. Esci dall\'account e '
      'accedi di nuovo; se continua, è una configurazione dell\'app, non '
      'tua.';

  @override
  String get errSessionExpired =>
      'La tua sessione è scaduta. Accedi di nuovo per continuare.';

  @override
  String get errMissingIndex =>
      'I tuoi ricordi sono salvati, ma il server non riesce ancora a '
      'organizzarli per mostrarli qui. È una configurazione dell\'app, '
      'non tua.';

  @override
  String get errServerQuiet =>
      'Il server non ha risposto. Riprova tra qualche istante.';

  @override
  String get errRecentLogin =>
      'Per sicurezza, accedi di nuovo prima di continuare.';

  @override
  String get errGeneric => 'Non è stato possibile completare. Riprova.';

  @override
  String get errDriveExpired =>
      'L\'accesso a Google Drive è scaduto. Esci dall\'account e accedi '
      'di nuovo per rinnovare il permesso.';

  @override
  String get errDriveNotEnabled =>
      'Google Drive non è ancora abilitato per questa app. È una nostra '
      'configurazione, non tua: nulla di ciò che hai compilato è andato '
      'perso.';

  @override
  String get errDriveFull =>
      'Il tuo Google Drive non ha più spazio. Libera spazio '
      'sull\'account e riprova.';

  @override
  String get errDriveRateLimit =>
      'Google Drive ha chiesto di attendere un momento. Riprova tra '
      'qualche istante.';

  @override
  String get errDriveForbidden =>
      'Google Drive ha rifiutato l\'accesso. Esci dall\'account e '
      'accedi di nuovo per autorizzare la cartella della capsula.';

  @override
  String get errDriveFolderMissing =>
      'La cartella della capsula non è stata trovata nel tuo Google '
      'Drive.';

  @override
  String get errDriveQuiet =>
      'Google Drive non ha risposto. Riprova tra qualche istante; nulla '
      'di ciò che hai compilato è andato perso.';

  @override
  String get errDriveGeneric =>
      'Non è stato possibile contattare Google Drive. Riprova.';

  @override
  String get authSlow =>
      'L\'accesso con Google sta impiegando molto tempo a rispondere. '
      'Controlla la connessione e riprova.';

  @override
  String get authUnsupported =>
      'Questo dispositivo non offre l\'accesso con Google.';

  @override
  String get authNoIdentifier =>
      'Non abbiamo ricevuto l\'identificativo dell\'account. Controlla '
      'la configurazione dell\'accesso con Google e riprova.';

  @override
  String get authOtherAccount =>
      'Il permesso salvato appartiene a un altro account Google. Accedi '
      'di nuovo per continuare a salvare in questa capsula.';

  @override
  String get authRenewDrive =>
      'Dobbiamo rinnovare il permesso di Google Drive.';

  @override
  String get authSignInToContinue =>
      'Accedi con l\'account Google per continuare.';

  @override
  String get authDriveRefused =>
      'Non hai autorizzato l\'accesso a Google Drive. È lì che i '
      'ricordi vengono conservati, sul tuo stesso account.';

  @override
  String get authReloginToDelete =>
      'Per eliminare l\'account, accedi di nuovo e ripeti l\'operazione.';

  @override
  String get authScreenFailed =>
      'Non è stato possibile aprire la schermata di Google. Riprova.';

  @override
  String get authConfigIncomplete =>
      'La configurazione dell\'accesso con Google è incompleta.';

  @override
  String get authServicesUnavailable =>
      'Servizi Google non disponibili su questo dispositivo.';

  @override
  String get authWrongAccount =>
      'L\'account scelto è diverso dall\'account in uso.';

  @override
  String get emptyDocuments => 'Ancora nessun documento';

  @override
  String get emptyDrawings => 'Ancora nessun disegno';

  @override
  String get emptyLetters => 'Ancora nessuna lettera';

  @override
  String get emptyPhotos => 'Ancora nessuna foto';

  @override
  String get emptySealed => 'Ancora niente di sigillato';

  @override
  String get emptyMoments => 'Ancora niente in sospeso qui';

  @override
  String get emptyInspirations => 'Ancora niente qui ora';

  @override
  String get emptySearchTopic => 'Ancora niente su questo';

  @override
  String get firstPhotosHint => 'Tocca il + per aggiungere le prime foto.';

  @override
  String daysLeft(int dias) =>
      dias == 1 ? 'Manca 1 giorno' : 'Mancano $dias giorni';

  @override
  String daysLeftWithDate(int dias, String data) =>
      'Mancano $dias giorni, $data';

  @override
  String remindersSummaryFull(int marcados, int total, int hora) =>
      '$marcados di $total tipi, alle $hora';

  @override
  String contarSemanas(int n) => n == 1 ? '1 settimana' : '$n settimane';

  @override
  String semanaNumero(String n) => 'Settimana $n';

  @override
  String mesNumero(String n) => 'Mese $n';

  @override
  String anoNumero(String n) => 'Anno $n';

  @override
  String uploadWithDate(String oQue, String data) =>
      '$oQue con la data del $data.';

  @override
  String uploadBornThatDay(String nome) => 'Era il giorno in cui $nome è nato.';

  @override
  String uploadBornThatDayGeneric() => 'Era il giorno della nascita.';

  @override
  String uploadAgeThen(String nome, String idade) =>
      'In quella data $nome aveva $idade.';

  @override
  String uploadAgeThenGeneric(String idade) => 'Età in quella data: $idade.';

  @override
  String uploadWhereInDrive(String caminho) => 'Nel Drive, finirà in $caminho.';

  @override
  String get holidayNewYear => 'Capodanno';

  @override
  String get holidayCarnival => 'Carnevale';

  @override
  String get holidayEaster => 'Pasqua';

  @override
  String get holidayMothers => 'Festa della Mamma';

  @override
  String get holidayFathers => 'Festa del Papà';

  @override
  String get holidayChristmas => 'Natale';

  @override
  String get kindLetter => 'Idea per una lettera';

  @override
  String get kindReading => 'Lettura';

  @override
  String get kindPrep => 'Preparativo';

  @override
  String get kindRoutine => 'Routine e organizzazione';

  @override
  String get kindEveryday => 'Vita quotidiana';

  @override
  String get kindPlay => 'Gioco';

  @override
  String get notifChannelName => 'Promemoria della capsula';

  @override
  String get notifChannelDescription =>
      'Date tonde, compleanni e promemoria per salvare un ricordo.';

  @override
  String get errPhotoCompress =>
      'Non è stato possibile comprimere questa foto.';

  @override
  String get errVideoConvert =>
      'Non è stato possibile convertire questo video.';

  @override
  String get errOriginalsMissing =>
      'I file originali non sono su questo dispositivo.';

  @override
  String get errPickPhotoAgain => 'Scegli di nuovo la foto per salvarla.';

  @override
  String get errOriginalsMissingFull =>
      'I file originali non sono su questo dispositivo. Invia di nuovo '
      'dal telefono in cui sono stati scelti.';

  @override
  String get errFileGoneFull =>
      'Il file ha lasciato questo dispositivo prima che l\'invio '
      'terminasse. Scegli di nuovo la foto per salvarla.';

  @override
  String get kindOuting => 'Gita all\'aria aperta';

  @override
  String get kindPhoto => 'Idea per una foto';

  @override
  String get reminderRoundLabel => 'Date tonde';

  @override
  String get reminderRoundDesc => 'Mensiversari e il cambio di ogni anno';

  @override
  String get reminderBirthdayLabel => 'Compleanno';

  @override
  String get reminderBirthdayDesc => 'Una settimana prima, e il giorno stesso';

  @override
  String get reminderSpecialLabel => 'Prime volte dell\'anno';

  @override
  String get reminderSpecialDesc => 'Natale, Pasqua, Festa della Mamma';

  @override
  String get reminderInspirationLabel => 'Idee al momento giusto';

  @override
  String get reminderInspirationDesc => 'Quando un\'idea vale solo ora';

  @override
  String get reminderAbsenceLabel => 'Promemoria gentile';

  @override
  String get reminderAbsenceDesc =>
      'Quando è passato molto tempo senza registrare nulla';

  @override
  String get reminderInactiveLabel => 'L\'account Google';

  @override
  String get reminderInactiveDesc =>
      'Un avviso all\'anno, perché la capsula non vada perduta';

  @override
  String get notifWeekLeftTitle => 'Manca una settimana';

  @override
  String get notifBirthdayTodayGeneric =>
      'È oggi. Salva qualcosa di questo giorno.';

  @override
  String get notifMomentTitle => 'Un attimo di oggi';

  @override
  String get notifInactiveTitle => 'La capsula ha bisogno di te per un minuto';

  @override
  String get notifPhotoWorthIt =>
      'Una foto di oggi varrà molto tra vent\'anni.';

  @override
  String get notifAbsenceGeneric =>
      'È passato un po\' di tempo dall\'ultimo ricordo. Una foto '
      'qualsiasi, comunque sia la giornata, basta già.';

  @override
  String get notifInactiveGeneric =>
      'È passato quasi un anno da quando non apri l\'app. Google elimina '
      'gli account inutilizzati dopo due anni, ed è in uno di essi che '
      'vivono i ricordi. Aprire ogni tanto basta già.';

  @override
  String get theChild => 'il bambino o la bambina';

  @override
  String notifFirstBirthdaySoon(String quem) =>
      'Il primo compleanno $quem è tra sette giorni. Buon momento per '
      'scegliere le foto del primo anno.';

  @override
  String notifBirthdaySoon(String quem, int anos) =>
      '$quem compie $anos anni tra sette giorni.';

  @override
  String notifBirthdayTitle(int anos) =>
      anos == 1 ? 'Un anno oggi' : '$anos anni oggi';

  @override
  String notifBirthdayToday(String deQuem) =>
      'Oggi è il giorno $deQuem. Salva qualcosa di questo giorno.';

  @override
  String notifMonthsTitle(int meses) =>
      meses == 1 ? '1 mese oggi' : '$meses mesi oggi';

  @override
  String notifMonthsBody(String nome, int meses) =>
      '$nome compie ${contarMeses(meses)} oggi. Una foto di oggi varrà '
      'molto tra vent\'anni.';

  @override
  String notifFirstHolidayTitle(String data) => 'Il primo $data';

  @override
  String notifFirstHolidayBody(String data, String deQuem) =>
      'Tra tre giorni è il primo $data $deQuem. Vale una foto.';

  @override
  String notifFirstHolidayBodyGeneric(String data) =>
      'Tra tre giorni è il primo $data. Vale una foto.';

  @override
  String notifAbsenceBody(String deQuem) =>
      'È passato un po\' di tempo dall\'ultimo ricordo $deQuem. Una foto '
      'qualsiasi, comunque sia la giornata, basta già.';

  @override
  String notifInactiveBody(String deQuem) =>
      'È passato quasi un anno da quando non apri l\'app. Google elimina '
      'gli account inutilizzati dopo due anni, ed è in uno di essi che '
      'vivono i ricordi $deQuem. Aprire ogni tanto basta già.';

  @override
  String tituloDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'Il primo Natale',
    'primeiro-ano-novo' => 'Il primo Capodanno',
    'primeiro-carnaval' => 'Il primo Carnevale',
    'primeira-pascoa' => 'La prima Pasqua',
    'primeiro-dia-das-maes' => 'La prima Festa della Mamma',
    'primeiro-dia-dos-pais' => 'La prima Festa del Papà',
    'primeiro-aniversario' => 'Preparare il primo compleanno',
    'primeiro-sorriso' => 'Il primo sorriso',
    'primeiro-dentinho' => 'Il primo dentino',
    'primeira-palavra' => 'La prima parola',
    'primeiros-passos' => 'I primi passi',
    'primeiro-corte-cabelo' => 'Il primo taglio di capelli',
    'primeira-viagem' => 'Il primo viaggio',
    'primeira-praia' => 'La prima spiaggia',
    'primeira-escola' => 'Il primo giorno di scuola',
    'primeira-bicicleta' => 'La prima bicicletta',
    _ => id,
  };

  @override
  String? notaDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'Il primo Natale {nome} si avvicina.',
    'primeiro-ano-novo' => 'Il primo cambio d\'anno {nome}.',
    'primeiro-carnaval' => 'Un costume, una foto, e basta.',
    'primeiro-dia-das-maes' =>
      'Che ne dici di una lettera che {nome} leggerà tra molti anni?',
    'primeiro-aniversario' => 'Il primo anno {nome} si avvicina.',
    'primeiro-sorriso' => 'Di solito compare intorno alle sei settimane.',
    'primeira-palavra' =>
      'Registra la voce {nome}. Tra vent\'anni, non avrà prezzo.',
    'primeiros-passos' => 'Vale di più in video che in foto.',
    'primeiro-corte-cabelo' => 'Prima e dopo, se possibile.',
    _ => null,
  };

  @override
  List<String> checklistDoAniversario() => <String>[
    'Scegliere il tema',
    'Definire gli invitati',
    'Scegliere la torta',
    'Comprare il vestito',
    'Registrare un video',
    'Scrivere una lettera per il futuro',
  ];

  @override
  String get languageStepTitle => 'In quale lingua?';

  @override
  String get languageStepNote =>
      'Vale per tutta l\'app e per i nomi delle cartelle su Google '
      'Drive. Le cartelle mantengono per sempre la lingua di adesso, '
      'anche se cambi quella dell\'app in seguito.';

  @override
  String get closeLabel => 'Chiudi';

  @override
  String get skip => 'Salta';

  @override
  String get createRecommendedAccount => 'Crea l\'account consigliato';

  @override
  String get useCurrentAccount => 'Usa il mio account attuale';

  @override
  String get exactlyToday => 'Oggi sono esattamente';

  @override
  String get beenAWhile => 'È passato un po\'';

  @override
  String get toLiveNow => 'Da vivere adesso';

  @override
  String forNameNow(String nome) => 'Per $nome, adesso';

  @override
  String get readThePost => 'Leggi il post';

  @override
  String get inspirationsChangeNote =>
      'Le idee cambiano con l\'età. Torna presto.';

  @override
  String get savingEllipsis => 'Salvataggio...';

  @override
  String get viewFolder => 'Vedi la cartella';

  @override
  String get viewDrawing => 'Vedi il disegno';

  @override
  String get documentName => 'Nome del documento';

  @override
  String documentNameOf(int atual, int total) =>
      'Nome del documento $atual di $total';

  @override
  String get keep => 'Conserva';

  @override
  String get keepForFuture => 'Conserva per il futuro';

  @override
  String get savedForFuture => 'Conservato per il futuro';

  @override
  String get opensToday => 'Si apre oggi';

  @override
  String opensOn(String data) => 'Si apre il $data';

  @override
  String sealedUntilNotice(String data) =>
      'Conservato per essere aperto il $data.';

  @override
  String whenTurns(int anos) => 'Quando compie $anos anni';

  @override
  String opensInYearsAtAge(int anos, int idade) =>
      'Tra ${contarAnos(anos)}, a $idade anni';

  @override
  String get writeSomethingFirst => 'Scrivi qualcosa prima di salvare.';

  @override
  String get noAppForFile => 'Nessuna app può aprire questo file.';

  @override
  String get drawingsEmptyBody =>
      'Fotografa un disegno e resterà conservato per sempre.';

  @override
  String birthdayAgeOf(int anos, String deQuem) =>
      '${contarAnos(anos)} $deQuem';

  @override
  String get atBirth => 'Alla nascita';

  @override
  String get conjuncaoE => 'e';

  @override
  String savedInFolder(String pasta, String conta) =>
      'È salvato in $pasta, $conta.';

  @override
  String willBeSavedInFolder(String pasta) => 'Verrà salvato in $pasta.';

  @override
  String get renameDocument => 'Rinomina documento';

  @override
  String get rename => 'Rinomina';

  @override
  String get addedOn => 'Aggiunto il';

  @override
  String get sizeLabel => 'Dimensione';

  @override
  String get fewRecords => 'Pochi dati';

  @override
  String get recentPhotos => 'Foto recenti';

  @override
  String get seeAll => 'Vedi tutte';

  @override
  String get record => 'Registra';

  @override
  String get searchPosts => 'Cerca nei post';

  @override
  String get searchPostsHint => 'Cerca nei post...';

  @override
  String get clearLabel => 'Cancella';

  @override
  String get tryAgainShortly => 'Riprova ad aprirlo tra poco.';

  @override
  String get write => 'Scrivi';

  @override
  String get importantMoments => 'Momenti importanti';

  @override
  String get hospital => 'Ospedale';

  @override
  String get girl => 'Bambina';

  @override
  String get boy => 'Bambino';

  @override
  String get profilePhoto => 'Foto del profilo';

  @override
  String get changeProfilePhoto => 'Cambia la foto del profilo';

  @override
  String get receiveReminders => 'Ricevere promemoria';

  @override
  String get atWhatTime => 'A che ora';

  @override
  String get chooseAnotherDate => 'Scegli un\'altra data';

  @override
  String get removeSeal => 'Togli il sigillo';

  @override
  String get checkTheDate => 'La data è giusta?';

  @override
  String get savingDrawing => 'Salvataggio del disegno...';

  @override
  String get convertingAndSending => 'Conversione in 540p e invio...';

  @override
  String get viewDocument => 'Vedi il documento';

  @override
  String get viewDocuments => 'Vedi i documenti';

  @override
  String get groupBy => 'Raggruppa per';

  @override
  String umDoTipo(String tipo) => 'Un $tipo';
  @override
  String get titleHintExample => 'Primo sorriso';
}
