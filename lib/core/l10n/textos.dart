/// Todo o texto visível do aplicativo, em qualquer idioma.
///
/// Cada idioma é uma classe que implementa esta, e a palavra `implements` é o
/// ponto: ela obriga o compilador a cobrar toda linha nova em **todas** as
/// línguas. Um texto acrescentado só em português para de compilar, em vez de
/// aparecer traduzido pela metade no aparelho de alguém.
///
/// Os textos que dependem de quem é a criança não estão aqui: eles moram em
/// `Copy`, porque precisam do nome e do sexo para concordar.
abstract interface class Textos {
  /// Nome curto, para o ícone e as barras de título.
  ///
  /// O Android corta o rótulo embaixo do ícone por volta do 11º caractere.
  /// O nome completo ali viraria "Meu Bebê: C...", então ele fica só onde há
  /// espaço de verdade: a loja, a tela de entrada e a tela Sobre.
  String get appName;

  /// Nome completo, para a loja e para quem ainda não conhece o aplicativo.
  String get appFullName;

  /// A segunda linha da tela de entrada, sob o nome curto.
  String get appSubtitle;

  String get appTagline;

  // Login
  String get signInWithGoogle;

  /// O aviso sob o botão de entrar.
  ///
  /// Diz de quem é a conta, e não de quem é o Drive: é a frase que prepara a
  /// escolha inteira do produto, que é a conta ser da criança desde o
  /// primeiro dia. "filho(a)" porque aqui ainda não existe cadastro, e
  /// portanto não existe nome nem sexo para concordar.
  String get signInNote;

  String get signInError;

  // Onboarding
  String get onboardingGreeting;

  String get fullName;

  String get gender;

  String get birthDate;

  String get birthTime;

  String get birthWeight;

  String get birthHeight;

  /// Os rótulos do cadastro, onde "(opcional)" é informação e não enfeite.
  ///
  /// Separados dos de cima porque aqueles também rotulam o dado **já
  /// salvo**, na tela de informações da criança. Ali "(opcional)" seria
  /// bobagem: o valor está preenchido, na frente de quem lê.
  String get birthTimeOptional;

  String get birthWeightOptional;

  String get birthHeightOptional;

  String get hospitalOptional;

  String get birthPhoto;

  String get continueLabel;

  String get preparingDrive;

  // Navegação
  String get home;

  String get timeline;

  String get search;

  /// O rótulo do botão no alto do perfil.
  ///
  /// No plural de propósito: é a palavra que conta, para quem tem mais de um
  /// filho, que mais de uma conta cabe aqui. Um ícone sozinho não contava.
  String get accountsLabel;

  /// Trocar de conta do Google, que é como se troca de filho: cada criança
  /// tem a própria conta, e é ela que a criança recebe quando crescer.
  String get switchAccount;

  String get profile;

  String get photos;

  String get videos;

  String get letters;

  String get drawings;

  String get documents;

  String get growth;

  String get stats;

  String get trash;

  String get settings;

  String get about;

  String get signOut;

  String get storedWithLove;

  // Adicionar
  String get addQuestion;

  String get addPhoto;

  String get addVideo;

  String get addLetter;

  String get addDrawing;

  String get addDrawingHint;

  String get addDocument;

  String get addDocumentHint;

  String get addGrowth;

  String get addGrowthHint;

  // Linha do tempo
  String get timelineEmptyTitle;

  String get birth;

  String get photosAdded;

  String get photoAdded;

  String get videoAdded;

  String get drawingAdded;

  String get documentAdded;

  String get growthRecord;

  String get letterPrefix;

  String get filterAll;

  String get filterTitle;

  // Marcos sugeridos - atalhos, nunca obrigatórios.
  List<String> get milestoneSuggestions;

  // Cartas - começos sugeridos.
  //
  // A parte difícil de escrever uma carta para um filho não é o tamanho do
  // campo: é a primeira frase. Cada um destes termina no meio de propósito,
  // porque um começo pronto convida a continuar e uma frase fechada convida
  // a concordar e fechar o aplicativo.
  String get letterStartersTitle;

  List<String> get letterStarters;

  // Campos comuns
  String get titleField;

  String get messageField;

  String get descriptionOptional;

  String get milestoneOptional;

  String get weightField;

  String get heightField;

  String get photoOptional;

  // Ações
  String get save;

  String get cancel;

  String get edit;

  String get share;

  String get delete;

  String get restore;

  String get view;

  String get download;

  String get retry;

  // Abas de agrupamento
  String get weeks;

  String get months;

  String get years;

  // Otimização
  String get photosOptimizedNote;

  String get videoOptimizedNote;

  String get allFilesOptimizedNote;

  // Upload
  String get uploadPending;

  String get uploadOptimizing;

  String get uploadSending;

  String get uploadFailed;

  String get uploadingCount;

  // Busca
  String get searchHint;

  String get searchByCategory;

  String get recentSearches;

  String get searchEmpty;

  String get clearHistory;

  // Estatísticas
  String get storageUsed;

  String get storageOf;

  String get capsuleStorage;

  String get driveStorage;

  String get driveStorageNote;

  // Trava do aplicativo
  String get lockSection;

  String get lockTitle;

  String get lockBody;

  String get lockUnavailable;

  String get lockNote;

  String get lockFailed;

  String get lockReason;

  String get lockedTitle;

  String get lockedBody;

  String get unlock;

  // Crescimento
  String get viewChart;

  String get growthChart;

  String get growthEmptyTitle;

  String get growthEmptyBody;

  // Lixeira
  String get trashEmptyTitle;

  String get trashEmptyBody;

  String get trashNote;

  String get deleteForever;

  String get deleteConfirmTitle;

  String get deleteConfirmBody;

  String get deleteForeverConfirmBody;

  // Perfil
  String get currentAge;

  /// "Data de nascimento" encurtado, para o cartão de duas colunas do Perfil.
  ///
  /// Ali os dois dados dividem a largura, e quem estava apertando a coluna
  /// não era a data (77 px) e sim o próprio rótulo (114 px). Encurtá-lo
  /// devolve quase quarenta pixels para a idade, que é o texto que cresce
  /// com o tempo. Nas telas onde há largura sobrando, o nome completo fica.
  String get birthDateShort;

  String get signOutConfirmTitle;

  String get signOutConfirmBody;

  // Documentos
  String get privacyPolicy;

  String get termsOfUse;

  /// O título da leitura, e não da ação: são duas telas, e a diferença
  /// entre elas é a diferença entre entender e apagar.
  String get accountDeletionTitle;

  /// A mesma tela, num rodapé estreito. O nome inteiro quebraria em duas
  /// linhas ao lado de um link de uma linha só, e o par ficaria torto.
  String get accountDeletionShort;

  /// O botão no fim da leitura.
  ///
  /// Diz que leva para a tela de apagar, e não que apaga. Repetir aqui o
  /// rótulo do botão vermelho faria dois controles idênticos com efeitos
  /// diferentes, que é como se aperta o errado.
  String get goToDeleteAccount;

  // Exclusão de conta
  String get deleteAccount;

  String get deleteAccountTitle;

  String get deleteAccountBody;

  String get deleteAccountDriveQuestion;

  String get deleteAccountKeepDrive;

  String get deleteAccountKeepDriveHint;

  String get deleteAccountTrashDrive;

  String get deleteAccountTrashDriveHint;

  String get deleteAccountWorking;

  String get deleteAccountDone;

  // Erros e estados
  String get genericError;

  String get noItemsYet;

  String get requiredField;

  String get invalidNumber;

  // ------------------------------------------------------------- formatação
  //
  // Datas, números e contagens não são só tradução de palavra: `10/04/2027`
  // e `April 10, 2027` são ordens diferentes, e `1 dia` e `1 day` concordam
  // por regras diferentes. O que muda de língua fica aqui; a lógica de qual
  // unidade usar continua em `Fmt`, igual para todo mundo.

  /// O código que o `intl` usa para meses, dias da semana e separadores.
  String get codigoIntl;

  /// `dd/MM/yyyy` / `MM/dd/yyyy`
  String get padraoData;

  /// `dd/MM` / `MM/dd`
  String get padraoDiaMes;

  /// `22 de janeiro de 2027` / `January 22, 2027`
  String get padraoDataLonga;

  /// `janeiro de 2027` / `January 2027`
  String get padraoMesAno;

  /// `14:35` / `2:35 PM`
  String get padraoHora;

  /// A palavra entre as duas pontas de um intervalo: `a` / `to`.
  String get entreDatas;

  String get hoje;
  String get ontem;

  /// `Bom dia` / `Good morning`, pela hora do relógio.
  String saudacao(int hora);

  /// `há 3 dias` / `3 days ago`.
  ///
  /// A frase inteira, e não só o número, porque o português põe a marca antes
  /// e o inglês depois.
  String haTempo(int dias);

  /// `primeiro` / `first`, e o número puro quando a palavra fica pior.
  String ordinal(int n);

  // As contagens que aparecem na interface. Cada uma existe porque o par
  // singular/plural é da língua, e passá-lo escrito no ponto de uso deixaria
  // "1 foto" traduzido em um lugar e esquecido em outro.
  String contarDias(int n);
  String contarMeses(int n);
  String contarAnos(int n);
  String contarItens(int n);
  String contarFotos(int n);
  String contarVideos(int n);

  // ------------------------------------------- recolhidos das telas
  //
  // Estavam escritos direto dentro dos widgets. Enquanto estivessem lá,
  // trocar o idioma deixaria metade de cada tela em português.

  String get lastBirth;

  String get lastPhoto;

  String get lastVideo;

  String get lastLetter;

  String get lastDrawing;

  String get lastDocument;

  String get lastGrowth;

  String get oneVideo;

  String get oneGrowth;

  String get imageOpenFailed;

  String get videoOpenFailed;

  String get documentNotFound;

  String get letterNotFound;

  String get entryNotFound;

  String get driveSpaceFailed;

  String get firstVideoHint;

  String get documentsEmptyBody;

  String get isToday;

  String get isTodayBang;

  String get tomorrow;

  String get nextMilestone;

  String get seeInspiration;

  String get forYou;

  String get notYet;

  String get inspirations;

  String get inspirationsLoadFailed;

  String get inspirationSearchHint;

  String get suggestionsByAge;

  String get notNow;

  String get savedTitle;

  String get sendMemoryError;

  String get dateFromFile;

  String get deletedOn;

  String get itemDeleted;

  String get documentNameSuggestion;

  String get saveInfo;

  String get editInfo;

  String get notProvided;

  String get automatic;

  String get reviewIntro;

  String get lastUpdatedLabel;

  String get optimization;

  String get photoMaxSide;

  String get optimizationNote;

  String get languageSection;

  String get clearCacheBody;

  String get cacheCleared;

  String get clearCache;

  String get storageOnDevice;

  String get remindersSection;

  String get remindersOff;

  String get startupFailedTitle;

  String get technicalDetail;

  String get premiumInviteAction;

  String get introTitle1;

  String get introTitle2;

  String get introBody2;

  String get introTitle3;

  String get introTitle4;

  String get sealBody;

  String get aboutPhotos;

  String get aboutScope;

  String get aboutIndex;

  String get aboutLastingTitle;

  String get deleteDriveNote;

  String get profilePhotoNote;

  String get remindersHowTitle;

  String get remindersMarkedTitle;

  String get remindersFrequency;

  String get remindersOffNote;

  String get remindersNothingSoon;

  String get remindersPrivacy;

  String get remindersDenied;

  String get sealedEmptyBody;

  String get growthChartHint;
}
