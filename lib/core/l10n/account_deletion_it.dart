import 'privacy_policy.dart';

/// La pagina di eliminazione dell'account, in italiano.
const String deletionPageDateIt = '18 agosto 2026';

const List<PrivacySection> accountDeletionPageIt = <PrivacySection>[
  PrivacySection(
    title: 'Cos\'è questa pagina',
    body: <String>[
      'Questa pagina spiega come richiedere l\'eliminazione del tuo '
          'account dell\'app Meu Bebê: Cápsula do Tempo e di tutti i dati '
          'ad esso associati.',
      'Esiste per funzionare anche se hai già disinstallato l\'app. Non '
          'devi installare nulla, registrarti né accedere da nessuna '
          'parte per usare ciò che trovi qui.',
      'Il diritto alla cancellazione esiste con nomi diversi in luoghi '
          'diversi: cancellazione nel RGPD (Art. 17) e nel UK GDPR, '
          'eliminazione nella LGPD (Art. 18), eliminazione nel CCPA della '
          'California, e diritti equivalenti in molte altre giurisdizioni. '
          'Qui il percorso è lo stesso per tutti, e non condizioniamo la '
          'richiesta all\'indicazione del paese in cui vivi.',
      'Responsabile del trattamento: $privacyController. Contatto: '
          '$privacyEmail',
    ],
  ),
  PrivacySection(
    title: 'Se hai ancora l\'app',
    body: <String>[
      'Questo è il percorso più rapido, e l\'unico che elimina tutto '
          'all\'istante, senza aspettare nessuno:',
      '• Apri l\'app e accedi con l\'account che vuoi eliminare',
      '• Tocca Profilo',
      '• Tocca "Eliminazione dell\'account e dei dati"',
      '• Leggi la pagina, che è questa stessa, e tocca "Vai '
          'all\'eliminazione dell\'account", in fondo',
      '• Scegli cosa fare della cartella di Google Drive',
      '• Tocca "Elimina il mio account e i miei dati" e conferma',
      'La lettura viene prima del pulsante di proposito. '
          'L\'eliminazione è immediata e non può essere annullata, e '
          'nessuno dovrebbe arrivare al pulsante senza sapere cosa resta e '
          'cosa scompare.',
      'Riguardo alla cartella del Drive, ci sono due opzioni: '
          'mantenerla, che è l\'impostazione predefinita, perché i file '
          'sono tuoi e non ne abbiamo mai avuto copia; oppure inviarla al '
          'cestino del tuo Drive.',
    ],
  ),
  PrivacySection(
    title: 'Se non hai più l\'app',
    body: <String>[
      'Scrivi a $privacyEmail con oggetto "Eliminare il mio account".',
      'La richiesta deve provenire dall\'indirizzo email dell\'account '
          'Google che hai usato per accedere all\'app. È l\'unico modo per '
          'sapere che la richiesta è tua: senza questo controllo, chiunque '
          'potrebbe eliminare la raccolta di un\'altra persona scrivendo '
          'semplicemente un\'email.',
      'Risponderemo a quello stesso indirizzo confermando '
          'l\'eliminazione. Se la richiesta arriva da un altro indirizzo, '
          'chiederemo che venga rinviata dall\'indirizzo dell\'account, e '
          'non elimineremo nulla finché ciò non accade.',
      'La richiesta sarà elaborata senza ingiustificato ritardo e, '
          'quando soggetta al RGPD, di norma entro un mese. Quando '
          'un\'altra legge applicabile stabilisce un termine diverso, '
          'rispetteremo il termine legale corrispondente. Non devi '
          'giustificare la richiesta, e non addebitiamo nulla per '
          'richiederla.',
    ],
  ),
  PrivacySection(
    title: 'Cosa viene eliminato',
    body: <String>[
      'Tutto ciò che esiste sul nostro server riguardo a te, senza '
          'eccezioni:',
      '• Il profilo del bambino: nome, data e ora di nascita, sesso, '
          'peso, altezza e ospedale',
      '• L\'intera cronologia: la data, l\'età, il titolo, la '
          'descrizione e il tipo di ogni ricordo',
      '• Il testo integrale delle lettere, l\'unico tuo contenuto che '
          'resta nel nostro indice',
      '• Gli identificativi delle cartelle del Drive e l\'avanzamento '
          'dei suggerimenti',
      '• Il tuo account di autenticazione, con l\'email e il nome '
          'provenienti da Google',
      'L\'eliminazione dei dati dell\'indice e dell\'account di '
          'autenticazione inizia immediatamente dopo la conferma e, una '
          'volta completata, non può essere annullata dall\'app. Non '
          'manteniamo backup operativi dell\'indice per ripristinare un '
          'account eliminato. I dati che devono essere conservati per '
          'obbligo di legge o i registri tecnici mantenuti '
          'dall\'infrastruttura di Google potranno rimanere per il periodo '
          'applicabile, senza essere usati per finalità incompatibili.',
    ],
  ),
  PrivacySection(
    title: 'Cosa non viene eliminato, e perché',
    body: <String>[
      'Le tue foto, video, disegni e documenti **non vengono '
          'eliminati**, perché non sono mai stati nostri.',
      'Restano in una cartella chiamata "Meu Bebê - Cápsula do Tempo", '
          'nel Google Drive del tuo stesso account. L\'app non ne ha mai '
          'avuto copia su nessun server: vanno dal tuo dispositivo '
          'direttamente al tuo Drive.',
      'Dopo l\'eliminazione dell\'account, l\'app revoca '
          'l\'autorizzazione usata per accedere ai file che ha creato in '
          'Google Drive. L\'ambito usato è '
          'https://www.googleapis.com/auth/drive.file, che limita '
          'l\'accesso ai file creati o aperti dall\'app entro i permessi '
          'concessi da Google. Dopo la revoca, l\'app non ha più '
          'l\'autorizzazione per gestire questi file. Per questo, i file '
          'restano sotto il controllo del tuo account Google, salvo che '
          'tu scelga di eliminarli direttamente nel Drive o, quando '
          'disponibile, richieda all\'app di inviarli al cestino prima '
          'dell\'eliminazione dell\'account.',
      'Se vuoi eliminare anche i file, fallo direttamente nel Drive, in '
          'due passaggi:',
      '• Apri drive.google.com con lo stesso account',
      '• Trova la cartella "Meu Bebê - Cápsula do Tempo"',
      '• Fai clic destro e scegli "Rimuovi"',
      'Se preferisci richiedere all\'app di inviare la cartella al '
          'cestino del Drive, fallo **prima** di completare '
          'l\'eliminazione dell\'account, nella stessa schermata di '
          'eliminazione. La disponibilità e il risultato definitivo '
          'dell\'operazione dipendono dai permessi concessi e dai '
          'meccanismi di Google Drive.',
    ],
  ),
  PrivacySection(
    title: 'L\'abbonamento Premium non viene cancellato qui',
    body: <String>[
      'Se hai il piano Premium, **eliminare l\'account non cancella '
          'l\'abbonamento**. Sono due cose in luoghi diversi: l\'account è '
          'nostro, l\'abbonamento è di Google Play.',
      'Senza cancellarlo lì, l\'addebito annuale continua anche dopo '
          'l\'eliminazione della capsula. Noi non abbiamo accesso al tuo '
          'metodo di pagamento e non possiamo cancellarlo per te.',
      'Cancellalo prima di eliminare l\'account, in pochi passaggi:',
      '• Apri il Google Play Store',
      '• Tocca la tua foto, in alto a destra',
      '• Vai su "Pagamenti e abbonamenti" e poi su "Abbonamenti"',
      '• Scegli Meu Bebê: Cápsula do Tempo e tocca "Annulla '
          'abbonamento"',
      'Dopo la cancellazione, il Premium normalmente resta valido fino '
          'alla fine del periodo già pagato. Se elimini l\'account prima '
          'di allora, l\'accesso al Premium associato a quell\'account '
          'terminerà con l\'eliminazione dell\'account. Non offriamo '
          'rimborsi proporzionali di nostra iniziativa, salvo quando '
          'richiesto dalla legge applicabile o dalle politiche di '
          'rimborso di Google Play.',
    ],
  ),
  PrivacySection(
    title: 'Eliminare solo una parte',
    body: <String>[
      'Non devi eliminare l\'intero account per eliminare qualcosa.',
      'Dentro l\'app, qualsiasi ricordo può essere spostato nel cestino '
          'ed eliminato definitivamente, uno per uno. Il profilo del '
          'bambino può essere modificato in qualsiasi momento. Nulla di '
          'tutto ciò passa da noi né dipende da una richiesta.',
      'Se vuoi semplicemente smettere di usare l\'app senza eliminare '
          'nulla, basta uscire dall\'account in Profilo: i dati sul '
          'dispositivo vengono eliminati all\'uscita, e la raccolta nel '
          'tuo Drive resta dov\'è.',
    ],
  ),
  PrivacySection(
    title: 'Un account per bambino',
    body: <String>[
      'L\'app usa un account Google per bambino, affinché un giorno '
          'ciascuno riceva la propria capsula completa.',
      'Questo significa che eliminare un account elimina la capsula di '
          'quel bambino, e solo la sua. Se usi più account, la richiesta '
          'va fatta una volta per ciascuno, dall\'email di ogni account.',
      'Anche l\'abbonamento Premium è per account. Eliminare la capsula '
          'di un bambino non tocca l\'abbonamento degli altri, e ognuno '
          'continua a valere, o viene cancellato, per conto proprio.',
    ],
  ),
  PrivacySection(
    title: 'Registri tecnici',
    body: <String>[
      'L\'infrastruttura che ospita l\'indice utilizza servizi di '
          'Firebase e Google Cloud. Come qualsiasi servizio cloud, questi '
          'servizi possono mantenere registri tecnici e operativi '
          'necessari per la sicurezza, il funzionamento, la prevenzione '
          'degli abusi e l\'audit, soggetti alle politiche di conservazione '
          'applicabili di Google.',
      'Questi registri di infrastruttura non fanno parte dell\'indice '
          'che manteniamo per far funzionare la tua capsula e non vengono '
          'usati da noi per ricostruire il contenuto eliminato. Alcuni '
          'registri tecnici possono rimanere per periodi determinati da '
          'Google o da obblighi di legge applicabili. Per questo, non '
          'promettiamo che assolutamente nessun registro tecnico possa '
          'esistere in nessun sistema di infrastruttura dopo '
          'l\'eliminazione.',
    ],
  ),
];
