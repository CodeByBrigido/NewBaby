import 'privacy_policy.dart';

/// L'informativa sulla privacy, in italiano.
///
/// Tradotta fedelmente dal portoghese, sezione per sezione e paragrafo per
/// paragrafo, perché nessun impegno risulti detto con minore forza in una
/// lingua rispetto a un'altra.
/// La data mostrata nella pagina pubblica.
const String privacyPolicyDateIt = '18 agosto 2026';

const List<PrivacySection> privacyPolicyIt = <PrivacySection>[
  PrivacySection(
    title: 'In breve',
    body: <String>[
      'Le foto, i video e i documenti non passano mai da un server '
          'nostro: vanno direttamente dal tuo dispositivo al Google Drive '
          'del tuo stesso account.',
      'L\'app conserva su un server solo un indice di testo, che è ciò '
          'che fa funzionare la cronologia e la ricerca.',
      'Non ci sono pubblicità, tracciamento, profilazione né vendita di '
          'dati.',
      'L\'abbonamento Premium viene addebitato da Google Play. Nessun '
          'dato di pagamento passa da noi.',
      'Puoi cancellare tutto questo in qualsiasi momento, dentro l\'app, '
          'senza doverlo chiedere a nessuno.',
    ],
  ),
  PrivacySection(
    title: 'Chi è il responsabile',
    body: <String>[
      'Responsabile del trattamento dei dati personali (titolare del '
          'trattamento, ai sensi dell\'Art. 4(7) del RGPD): '
          '$privacyController, persona fisica, sviluppatore individuale, '
          'stabilito in Irlanda.',
      'Poiché il responsabile dell\'app è stabilito in Irlanda, il RGPD '
          'si applica ai trattamenti rientranti nel suo ambito di '
          'applicazione. Quando è applicabile il meccanismo dello sportello '
          'unico per i trattamenti transfrontalieri, l\'autorità di '
          'controllo capofila sarà determinata ai sensi dell\'Art. 56 del '
          'RGPD. Puoi anche presentare un reclamo all\'autorità di '
          'protezione dei dati del paese in cui risiedi o lavori, o del '
          'luogo in cui si è verificata la presunta violazione.',
      'Contatto: $privacyEmail',
      'Ogni richiesta relativa ai dati personali può essere inviata a '
          'questo indirizzo. Rispondiamo senza ingiustificato ritardo e, di '
          'norma, entro un mese, ai sensi dell\'Art. 12(3) del RGPD. Quando '
          'la legge consente una proroga di questo termine, te lo '
          'comunicheremo entro il primo mese e spiegheremo i motivi.',
    ],
  ),
  PrivacySection(
    title: 'Il tuo ruolo e il nostro',
    body: <String>[
      'Quando una persona utilizza l\'app esclusivamente per registrare '
          'e conservare ricordi della propria famiglia, tale uso può '
          'rientrare nell\'eccezione per attività a carattere '
          'esclusivamente personale o domestico prevista dall\'Art. 2(2)(c) '
          'del RGPD. Questa eccezione riguarda l\'applicazione del RGPD al '
          'trattamento svolto dalla persona stessa e non modifica le '
          'responsabilità che possono spettare all\'app riguardo ai dati '
          'personali che essa stessa tratta.',
      'L\'app è pensata per questo uso: personale e familiare, senza '
          'fine commerciale. Usarla per registrare bambini che non sono '
          'tuoi né sotto la tua responsabilità legale, o per offrire questo '
          'servizio a terzi, esce da ciò che i piani coprono.',
      'Abbiamo responsabilità diverse a seconda del dato e del servizio '
          'coinvolti. Per l\'indice che manteniamo per far funzionare '
          'l\'app, come il profilo, la cronologia e il testo delle '
          'lettere, siamo responsabili di definire le finalità e i mezzi '
          'essenziali di questo trattamento e, quando il RGPD è '
          'applicabile, agiamo come titolari di questi dati. Per i file '
          'inviati direttamente all\'account Google Drive dell\'utente, '
          'l\'app non riceve una copia di questi file né li archivia su '
          'server propri. L\'uso di Google Drive è inoltre soggetto ai '
          'termini e all\'informativa sulla privacy di Google. La nostra '
          'app agisce solo entro i permessi concessi dall\'utente.',
    ],
  ),
  PrivacySection(
    title: 'Cosa resta nel tuo Google Drive',
    body: <String>[
      'Accedendo, autorizzi l\'app a usare il Google Drive del tuo '
          'account con l\'ambito drive.file. Questo ambito dà accesso solo '
          'ai file che l\'app stessa crea. Non consente di leggere, '
          'elencare o modificare nessun altro file del tuo Drive, e questa '
          'limitazione è imposta da Google, non da noi.',
      'Restano nel tuo Drive, dentro la cartella "Meu Bebê - Cápsula do '
          'Tempo": le foto, i video, i disegni e i documenti che invii.',
      'Restano anche due file di testo, scritti dall\'app: uno con il '
          'profilo e le misurazioni di crescita, e uno per ogni lettera '
          'che scrivi. Esistono perché questa raccolta continui ad avere '
          'senso senza l\'app: una foto si spiega da sola in una cartella, '
          'una lettera e una misurazione di peso no.',
      'Questi file sono tuoi. Non ne abbiamo copia, non possiamo vederli '
          'e non abbiamo alcun mezzo tecnico per accedervi al di fuori '
          'dell\'app in uso nella tua sessione.',
      'Le coordinate GPS vengono rimosse da ogni foto prima dell\'invio.',
    ],
  ),
  PrivacySection(
    title: 'Cosa resta nel nostro indice',
    body: <String>[
      'L\'indice si trova su Cloud Firestore, servizio di Google Cloud. '
          'Questo è l\'elenco completo di ciò che conserva:',
      '• Dal profilo: nome del bambino, data di nascita, sesso '
          'indicato, peso e altezza alla nascita, nome dell\'ospedale se '
          'compilato, e l\'identificativo della cartella radice nel tuo '
          'Drive.',
      '• Dal piano: un unico valore, sì o no, che indica se l\'account '
          'ha l\'abbonamento Premium. Nient\'altro sul pagamento passa da '
          'qui.',
      '• Da ogni ricordo: tipo, data, età in giorni, titolo, '
          'descrizione e, nel caso delle lettere, il testo integrale della '
          'lettera; peso e altezza delle misurazioni di crescita; la data '
          'di apertura, quando il ricordo è sigillato; e l\'identificativo, '
          'nome, tipo e dimensione di ogni file nel tuo Drive.',
      '• Di supporto: la cache degli identificativi delle cartelle '
          'create nel Drive e l\'avanzamento dei suggerimenti che hai '
          'selezionato.',
      '• Dall\'autenticazione: Firebase Authentication conserva il tuo '
          'identificativo utente, la tua email, il tuo nome e l\'indirizzo '
          'della tua foto profilo Google.',
      'Ogni indice è isolato per account. Regole di sicurezza sul '
          'server impediscono a qualsiasi account di leggere o scrivere i '
          'dati di un altro, e queste regole vengono verificate con test '
          'automatizzati a ogni modifica dell\'app.',
    ],
  ),
  PrivacySection(
    title: 'Il pagamento dell\'abbonamento',
    body: <String>[
      'A riscuotere l\'abbonamento Premium è Google Play, non noi. La '
          'carta, l\'indirizzo di fatturazione, la ricevuta e lo storico '
          'degli acquisti restano lì, sotto la loro informativa sulla '
          'privacy.',
      'Noi non riceviamo, non vediamo e non conserviamo alcun dato di '
          'pagamento. Da parte nostra resta solo il valore sì o no '
          'descritto sopra, nell\'indice di quell\'account, che dice '
          'all\'app se deve consentire di salvare lettere, disegni, '
          'documenti e registrazioni di crescita.',
      'Poiché l\'abbonamento vale per account, e ogni bambino ha il '
          'proprio account Google, questo valore non viene mai confrontato '
          'tra account né usato per collegare un account a un altro.',
    ],
  ),
  PrivacySection(
    title: 'Ciò che non lascia mai il dispositivo',
    body: <String>[
      'Le impostazioni dei promemoria, il segno che la presentazione '
          'iniziale è già stata vista, le ispirazioni già viste e lette, '
          'la preferenza di blocco biometrico e la cache delle miniature '
          'delle foto.',
      'Nulla di tutto ciò viene inviato da nessuna parte. Lascia il '
          'dispositivo quando esci dall\'account o disinstalli l\'app.',
    ],
  ),
  PrivacySection(
    title: 'Cosa non viene raccolto',
    body: <String>[
      'Questo è un elenco chiuso:',
      '• Nessun dato di utilizzo, statistica o analisi. L\'app non ha '
          'Google Analytics, Firebase Analytics, Crashlytics né alcuno '
          'strumento equivalente.',
      '• Nessuna pubblicità e nessun identificativo pubblicitario.',
      '• Nessuna profilazione e nessuna decisione automatizzata su di '
          'te.',
      '• Nessuna localizzazione, contatti, agenda, microfono in secondo '
          'piano o cronologia di navigazione.',
      '• Nessuna vendita, noleggio o scambio di dati con terzi, in '
          'nessuna circostanza.',
      '• Nessuna notifica proveniente da un server. I promemoria '
          'vengono calcolati e programmati direttamente sul dispositivo.',
      'Se ciò dovesse cambiare in una versione futura, questa '
          'informativa cambierà prima, e l\'avviso apparirà nell\'app.',
    ],
  ),
  PrivacySection(
    title: 'Con chi vengono condivisi i dati',
    body: <String>[
      'I dati vengono condivisi o trattati da servizi Google necessari '
          'per determinate funzioni dell\'app:',
      '• Google Sign-In, per accedere al tuo account.',
      '• Firebase Authentication, per mantenere la sessione.',
      '• Cloud Firestore, per conservare l\'indice.',
      '• Google Drive, per conservare i tuoi file nel tuo stesso '
          'account.',
      '• Google Play, per addebitare l\'abbonamento Premium e indicare '
          'se è attivo, per chi si abbona.',
      'Non c\'è nessun altro destinatario scelto da noi. Non usiamo '
          'reti pubblicitarie, intermediari di dati né servizi di '
          'analisi.',
      'Il rapporto giuridico applicabile a ciascun servizio Google '
          'dipende dal prodotto utilizzato, dalla configurazione '
          'dell\'account e dai relativi termini contrattuali. Quando '
          'Google agisce come responsabile del trattamento (processor) '
          'rispetto al trattamento svolto da noi, tale trattamento sarà '
          'disciplinato dallo strumento contrattuale applicabile, compresi '
          'i termini di protezione dei dati di Google Cloud/Firebase. Nei '
          'servizi in cui Google agisce in nome proprio o direttamente nei '
          'confronti dell\'utente, si applicano anche i termini e '
          'l\'informativa sulla privacy di Google.',
      'Il trattamento svolto da Google è descritto nella sua '
          'informativa sulla privacy: policies.google.com/privacy',
    ],
  ),
  PrivacySection(
    title: 'Base giuridica di ciascun trattamento',
    body: <String>[
      '• Profilo, indice, autenticazione e funzionamento essenziale '
          'dell\'account: esecuzione del contratto, Art. 6(1)(b) del RGPD, '
          'quando tale trattamento è necessario per fornire la funzionalità '
          'richiesta.',
      '• Notifiche di promemoria: consenso, Art. 6(1)(a), revocabile in '
          'qualsiasi momento nelle Impostazioni.',
      '• Registrazione del piano sottoscritto: esecuzione del '
          'contratto, Art. 6(1)(b), nella misura necessaria per gestire '
          'l\'abbonamento e sbloccare le funzionalità corrispondenti.',
      '• Invio e archiviazione di file su Google Drive: operazione '
          'richiesta dall\'utente e realizzata tramite l\'autorizzazione '
          'concessa a Google Drive, senza che l\'app conservi una propria '
          'copia di questi file.',
      'Non utilizziamo il legittimo interesse come base per i '
          'trattamenti descritti in questa informativa. Se un obbligo di '
          'legge richiede la conservazione di determinati dati dopo la '
          'cancellazione dell\'account, tali dati potranno essere '
          'conservati per il periodo richiesto dalla legge.',
    ],
  ),
  PrivacySection(
    title: 'Dati di un bambino',
    body: <String>[
      'L\'app conserva dati su un bambino, ma non è destinata ai '
          'bambini e non viene usata da loro. Chi installa, registra e '
          'invia contenuti è la madre, il padre o il tutore legale, '
          'maggiorenne.',
      'Registrando un bambino, dichiari di esserne il tutore legale e '
          'di avere l\'autorità per fornire questi dati.',
      'Non c\'è registrazione pubblica, profilo visibile, social '
          'network, commenti, messaggi tra utenti né alcuna forma di '
          'esposizione dei contenuti a terzi. La capsula è privata per '
          'progettazione: i file si trovano nel Drive di chi li ha '
          'inviati e l\'indice è isolato per account.',
      'Quando il bambino raggiungerà la maggiore età, potrà esercitare '
          'direttamente i diritti applicabili ai propri dati personali, '
          'conformemente alla legislazione vigente. L\'app è stata '
          'progettata per facilitare questa continuità: i file restano '
          'nell\'account Google usato dalla famiglia e possono essere resi '
          'disponibili alla persona stessa, senza dipendere da un '
          'trasferimento di file archiviati sui nostri server.',
    ],
  ),
  PrivacySection(
    title: 'Per quanto tempo, e come cancellare',
    body: <String>[
      'I dati restano finché l\'account esiste. Non c\'è un termine '
          'automatico di eliminazione finché l\'account rimane attivo, '
          'perché la finalità del prodotto è proprio la conservazione a '
          'lungo termine. Quando esiste un obbligo legale di conservazione '
          'o un\'altra base giuridica che richiede di conservare un dato '
          'determinato, esso potrà essere mantenuto per il periodo '
          'necessario.',
      'In Profilo, "Elimina il mio account e i miei dati", cancelli '
          'tutto l\'indice sul nostro server, percorrendo ogni raccolta, '
          'con conferma sul server e non nella cache locale; il tuo '
          'account di autenticazione; e tutti i dati conservati sul '
          'dispositivo.',
      'Nella stessa schermata scegli cosa fare della cartella di Google '
          'Drive. Per impostazione predefinita viene mantenuta, perché i '
          'file sono archiviati direttamente nel tuo account e l\'app non '
          'ne conserva una copia propria. Se il permesso e le API di '
          'Google disponibili in quel momento lo consentono, puoi '
          'richiedere che l\'app sposti la cartella nel cestino del tuo '
          'Drive. L\'eliminazione definitiva dei file all\'interno di '
          'Google Drive dipende anche dalle regole e dai meccanismi di '
          'eliminazione dello stesso Google.',
      'L\'eliminazione dell\'indice inizia immediatamente e, una volta '
          'completata, non può essere annullata dall\'app. Non manteniamo '
          'backup operativi dell\'indice per ripristinare un account '
          'eliminato. I dati che devono essere conservati per obbligo di '
          'legge potranno rimanere per il periodo richiesto e saranno '
          'protetti da usi incompatibili con tale finalità.',
    ],
  ),
  PrivacySection(
    title: 'I tuoi diritti, ovunque tu viva',
    body: <String>[
      'Il nome della legge cambia da paese a paese. I diritti, in '
          'pratica, sono gli stessi, e li diamo tutti a chiunque, senza '
          'chiedere dove vivi: accesso, rettifica, cancellazione, '
          'portabilità, limitazione, opposizione e revoca del consenso.',
      '• Unione Europea e Spazio Economico Europeo: RGPD, Artt. da 15 a '
          '22.',
      '• Regno Unito: UK GDPR e Data Protection Act 2018, con gli '
          'stessi articoli.',
      '• Brasile: LGPD, Art. 18.',
      '• Argentina: Ley 25.326, con una riforma in corso. L\'Argentina '
          'è uno dei pochi paesi fuori dall\'Europa con una decisione di '
          'adeguatezza dell\'Unione Europea, il che dice molto sul livello '
          'di protezione già richiesto dalla sua legge.',
      '• Uruguay: Ley 18.331, anch\'essa con adeguatezza dell\'Unione '
          'Europea.',
      '• Cile: Ley 19.628, in via di sostituzione con la Ley 21.719, '
          'approvata nel dicembre 2024 e ispirata al RGPD, con entrata in '
          'vigore progressiva.',
      '• Colombia: Ley 1581 del 2012 (Habeas Data), con una regola '
          'propria e più esigente per i dati dei minori: il trattamento '
          'deve rispettare il suo interesse superiore, e non solo il '
          'consenso del tutore. È uno standard più alto di quello che il '
          'nostro design già rispetta, poiché l\'unico scopo qui è la '
          'capsula stessa del bambino, senza alcuna esposizione a terzi.',
      '• Perù: Ley 29733. Ecuador: Legge Organica di Protezione dei '
          'Dati Personali (LOPDP), del 2021.',
      '• Negli altri paesi del Sud America, ancora senza una propria '
          'legge organica: gli stessi diritti, secondo la nostra '
          'informativa.',
      '• Stati Uniti: la California ha la legge più esigente (CCPA e '
          'CPRA, vedi la sezione seguente), e un elenco crescente di altri '
          'stati come Virginia, Colorado, Connecticut e Utah ha leggi '
          'simili, con gli stessi diritti di sapere, cancellare, '
          'correggere, portare e rifiutare la vendita o la condivisione. '
          'Poiché non vendiamo né condividiamo alcun dato in nessuna '
          'circostanza, quest\'ultimo diritto è già esercitato per '
          'impostazione predefinita, in ogni stato, con o senza una legge '
          'specifica.',
      '• Svizzera: nLPD. Canada: PIPEDA. Australia: Privacy Act e gli '
          'Australian Privacy Principles. Sudafrica: POPIA. Giappone: '
          'APPI. India: DPDPA, man mano che entra in vigore ciascuna '
          'disposizione.',
      '• Ovunque altrove: gli stessi diritti, secondo la nostra '
          'informativa, anche dove la legge locale non li richiede ancora.',
      'In pratica, quasi tutti si esercitano senza parlare con noi: i '
          'dati sono visibili nell\'app, modificabili nell\'app e '
          'cancellabili nell\'app. Per tutto ciò che l\'app non risolve, '
          'scrivi a $privacyEmail',
      'Non devi giustificare la richiesta, esercitare un diritto non '
          'costa mai nulla, e non riduciamo mai il servizio a chi ne '
          'esercita uno.',
    ],
  ),
  PrivacySection(
    title: 'Se vivi in California',
    body: <String>[
      'Il CCPA, modificato dal CPRA, richiede che alcune frasi vengano '
          'dette esplicitamente, e sono tutte vere qui:',
      '• **Non vendiamo** informazioni personali, e non le vendiamo '
          'mai.',
      '• **Non condividiamo** informazioni personali per pubblicità '
          'comportamentale tra siti o app. Non c\'è alcuna pubblicità in '
          'questa app.',
      '• Non usiamo né divulghiamo informazioni personali sensibili per '
          'nulla che non sia fornire il servizio che hai richiesto.',
      '• Non offriamo incentivi finanziari in cambio di dati.',
      '• Non discriminiamo chi esercita un diritto: l\'app funziona '
          'allo stesso modo prima e dopo.',
      'Poiché non vendiamo né condividiamo nulla, non esiste alcun '
          'pulsante "Do Not Sell or Share My Personal Information", '
          'perché non ci sarebbe nulla da disattivare.',
      'Le categorie che raccogliamo, perché, e con chi vengono '
          'condivise sono nelle sezioni precedenti, e quell\'elenco è '
          'chiuso.',
      'Se vivi in un altro stato americano con una propria legge sulla '
          'privacy, le stesse sei frasi sopra valgono anche per te: '
          'descrivono come funziona l\'app, non un\'eccezione pensata solo '
          'per chi vive in California.',
    ],
  ),
  PrivacySection(
    title: 'Trasferimento internazionale',
    body: <String>[
      'I tuoi file restano nel Google Drive del tuo stesso account, e '
          'la loro posizione è quella che Google assegna al tuo account, '
          'non una nostra scelta. L\'indice si trova sull\'infrastruttura '
          'di Cloud Firestore, che può trattare dati al di fuori del tuo '
          'paese.',
      'Questi trasferimenti sono coperti dalle Clausole Contrattuali '
          'Tipo approvate dalla Commissione Europea, adottate da Google ai '
          'sensi dell\'Art. 46 del RGPD, e dall\'addendum del Regno Unito a '
          'queste stesse clausole. Google Cloud è inoltre certificato nel '
          'Data Privacy Framework tra Unione Europea e Stati Uniti.',
      'Per chi si trova in Brasile, il trasferimento si basa sull\'Art. '
          '33 della LGPD, mediante le stesse clausole contrattuali.',
      'Non effettuiamo trasferimenti internazionali di nostra iniziativa '
          'oltre al trattamento necessario per far funzionare i servizi di '
          'infrastruttura descritti in questa informativa. L\'indice può '
          'essere trattato sull\'infrastruttura di Google Cloud, anche in '
          'località al di fuori del paese dell\'utente, secondo la '
          'configurazione e i termini dei servizi utilizzati. I file di '
          'Google Drive restano soggetti all\'infrastruttura e alla '
          'configurazione dell\'account Google dello stesso utente.',
    ],
  ),
  PrivacySection(
    title: 'Sicurezza',
    body: <String>[
      'Tutto il traffico è cifrato in transito, e i dati inattivi sono '
          'cifrati dall\'infrastruttura di Google. L\'accesso all\'indice '
          'è controllato da regole di sicurezza sul server che richiedono '
          'l\'autenticazione e limitano ogni account ai propri dati. '
          'L\'app offre il blocco tramite biometria o codice del '
          'dispositivo.',
      'Nessun sistema è completamente sicuro, e non promettiamo il '
          'contrario. Ciò che riduce strutturalmente il rischio qui è la '
          'progettazione: le foto e i video non si trovano su un server '
          'nostro, quindi non esiste una base di dati multimediali nostra '
          'che possa trapelare.',
      'In caso di violazione dei dati che riguardi l\'indice, notifichiamo '
          'la Commissione per la Protezione dei Dati dell\'Irlanda entro '
          '72 ore dalla scoperta, come richiede l\'Art. 33 del RGPD, e ti '
          'avvisiamo direttamente quando il rischio per i tuoi diritti è '
          'elevato, come richiede l\'Art. 34. Dove un\'altra legge del tuo '
          'paese imponga un termine o un destinatario diverso, come la '
          'LGPD (Art. 48) o il CCPA, rispettiamo entrambi.',
    ],
  ),
  PrivacySection(
    title: 'Bambini, e perché questa app è diversa',
    body: <String>[
      'Questa app conserva dati **su** un bambino, e non viene usata '
          '**da** lui. Chi installa, accede e registra è la madre, il '
          'padre o chi ne è legalmente responsabile, e deve essere '
          'maggiorenne.',
      'Per questo l\'app non è rivolta ai bambini e non è stata '
          'concepita perché i minori creino o usino account per conto '
          'proprio. Chi installa, accede e registra informazioni deve '
          'essere un adulto responsabile. Non ci sono pubblicità, profilo '
          'pubblico, interazione tra utenti né funzionalità pensate per '
          'incentivare l\'uso autonomo da parte dei bambini.',
      'I dati sul bambino sono forniti dall\'adulto responsabile allo '
          'scopo di creare e conservare la capsula del tempo. Il '
          'trattamento dei dati di bambini e adolescenti rispetterà la '
          'legislazione applicabile e, ove pertinente, i principi di '
          'protezione integrale e interesse superiore del minore.',
      'Quando il bambino crescerà e assumerà l\'account, diventerà '
          'titolare di questi dati ed eserciterà direttamente tutti i '
          'diritti della sezione precedente, senza bisogno di noi per '
          'nulla.',
      'Diversi paesi stanno creando un codice di protezione specifico '
          'per i prodotti a cui un bambino potrebbe accedere, come il '
          'Children\'s Code del Regno Unito. Non abbiamo alcuna '
          'certificazione formale in tal senso, ma la progettazione '
          'dell\'app segue già gli stessi principi: nessuna pubblicità, '
          'nessuna profilazione, nessuna notifica pensata per catturare '
          'l\'attenzione, nessun gioco, nessuna ricompensa per il '
          'coinvolgimento e nessuna condivisione pubblica per '
          'impostazione predefinita. Un ricordo può persino essere '
          'sigillato, per aprirsi solo a una data futura scelta da chi lo '
          'ha conservato, l\'opposto di una progettazione pensata per '
          'massimizzare l\'uso.',
    ],
  ),
  PrivacySection(
    title: 'Modifiche a questa informativa',
    body: <String>[
      'Le modifiche rilevanti vengono annunciate all\'interno dell\'app '
          'prima di entrare in vigore. La data in alto indica la versione '
          'vigente, e le versioni precedenti restano disponibili nella '
          'cronologia pubblica del repository.',
    ],
  ),
  PrivacySection(
    title: 'Reclamo',
    body: <String>[
      'Se ritieni che il trattamento dei tuoi dati violi la legge, puoi '
          'presentare reclamo all\'autorità del luogo in cui vivi, senza '
          'dover parlare prima con noi.',
      '• Irlanda: Data Protection Commission (DPC), specialmente '
          'quando la DPC è l\'autorità di controllo competente o capofila '
          'ai sensi del RGPD.',
      '• Unione Europea: puoi preferire l\'autorità del tuo stesso '
          'Stato membro, che la inoltrerà. L\'elenco è su edpb.europa.eu',
      '• Brasile: ANPD, gov.br/anpd',
      '• Argentina: Agencia de Acceso a la Información Pública (AAIP).',
      '• Uruguay: Unidad Reguladora y de Control de Datos Personales '
          '(URCDP).',
      '• Cile: la nuova Agencia de Protección de Datos Personales, man '
          'mano che la Ley 21.719 entra in vigore.',
      '• Colombia: Superintendencia de Industria y Comercio (SIC).',
      '• Regno Unito: ICO, ico.org.uk',
      '• Svizzera: IFPDT. Canada: OPC. Australia: OAIC.',
      '• California: California Privacy Protection Agency, cppa.ca.gov, '
          'oppure il Procuratore Generale dello stato.',
      'Se preferisci provare prima con noi, scrivi a $privacyEmail. '
          'Rispondiamo entro un massimo di 30 giorni, e una nostra '
          'risposta non è mai condizione per rivolgerti all\'autorità.',
    ],
  ),
];
