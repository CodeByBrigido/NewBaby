/// Todo o texto visível do aplicativo, em português do Brasil.
///
/// O app é de idioma único por decisão de produto; centralizar aqui mantém a
/// escrita consistente e facilita revisar o tom de voz num lugar só.
abstract final class S {
  static const String appName = 'Meu Bebê';
  static const String appTagline = 'Cada momento, uma lembrança para a vida toda.';

  // Login
  static const String signInWithGoogle = 'Entrar com Google';
  static const String signInNote =
      'Todas as memórias serão salvas na conta Google da sua filha.';
  static const String signInError =
      'Não foi possível entrar. Verifique a conexão e tente de novo.';
  static const String signInPermissionNeeded =
      'Precisamos da sua permissão para guardar os arquivos no Google Drive.';

  // Onboarding
  static const String onboardingGreeting = 'Olá!';
  static const String onboardingSubtitle =
      'Vamos configurar o app para guardar todas as memórias da sua bebê.';
  static const String fullName = 'Nome completo';
  static const String birthDate = 'Data de nascimento';
  static const String birthTime = 'Hora de nascimento';
  static const String birthWeight = 'Peso ao nascer';
  static const String birthHeight = 'Altura ao nascer';
  static const String hospitalOptional = 'Hospital (opcional)';
  static const String birthPhoto = 'Foto do nascimento';
  static const String continueLabel = 'Continuar';
  static const String preparingDrive =
      'Preparando as pastas no Google Drive...';

  // Navegação
  static const String home = 'Início';
  static const String timeline = 'Linha do Tempo';
  static const String search = 'Busca';
  static const String profile = 'Perfil';
  static const String photos = 'Fotos';
  static const String videos = 'Vídeos';
  static const String letters = 'Cartas';
  static const String drawings = 'Desenhos';
  static const String documents = 'Documentos';
  static const String growth = 'Crescimento';
  static const String stats = 'Estatísticas';
  static const String trash = 'Lixeira';
  static const String settings = 'Configurações';
  static const String about = 'Sobre o aplicativo';
  static const String signOut = 'Sair';
  static const String storedWithLove =
      'Armazenado com amor na conta Google de';

  // Adicionar
  static const String add = 'Adicionar';
  static const String addQuestion = 'O que você deseja adicionar?';
  static const String addPhoto = 'Foto';
  static const String addPhotoHint = 'Adicionar fotos da sua bebê';
  static const String addVideo = 'Vídeo';
  static const String addVideoHint = 'Adicionar vídeos da sua bebê';
  static const String addLetter = 'Carta';
  static const String addLetterHint = 'Escrever uma carta para ela';
  static const String addDrawing = 'Desenho';
  static const String addDrawingHint = 'Adicionar um desenho';
  static const String addDocument = 'Documento';
  static const String addDocumentHint = 'Adicionar documentos importantes';
  static const String addGrowth = 'Crescimento';
  static const String addGrowthHint = 'Registrar peso e altura';

  // Linha do tempo
  static const String timelineEmptyTitle = 'A história começa aqui';
  static const String timelineEmptyBody =
      'Toque no + para guardar a primeira memória da sua bebê.';
  static const String birth = 'Nascimento';
  static const String photosAdded = 'Fotos adicionadas';
  static const String photoAdded = 'Foto adicionada';
  static const String videoAdded = 'Vídeo adicionado';
  static const String drawingAdded = 'Desenho adicionado';
  static const String documentAdded = 'Documento adicionado';
  static const String growthRecord = 'Registro de crescimento';
  static const String letterPrefix = 'Carta:';
  static const String filterAll = 'Tudo';
  static const String filterTitle = 'Filtrar por tipo';

  // Marcos sugeridos — atalhos, nunca obrigatórios.
  static const List<String> milestoneSuggestions = <String>[
    'Primeira foto',
    'Primeiro banho',
    'Primeiro passeio',
    'Primeira viagem',
    'Primeiro sorriso',
    'Primeiro dente',
    'Primeiros passos',
    'Primeira palavra',
    'Primeiro aniversário',
  ];

  // Campos comuns
  static const String titleField = 'Título';
  static const String messageField = 'Mensagem';
  static const String descriptionOptional = 'Descrição (opcional)';
  static const String milestoneOptional = 'Marco (opcional)';
  static const String dateField = 'Data';
  static const String weightField = 'Peso';
  static const String heightField = 'Altura';
  static const String photoOptional = 'Foto (opcional)';

  // Ações
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String edit = 'Editar';
  static const String share = 'Compartilhar';
  static const String delete = 'Excluir';
  static const String restore = 'Restaurar';
  static const String view = 'Visualizar';
  static const String download = 'Baixar';
  static const String retry = 'Tentar de novo';
  static const String close = 'Fechar';
  static const String remove = 'Remover';
  static const String chooseFromGallery = 'Escolher da galeria';
  static const String takePhoto = 'Tirar foto';

  // Abas de agrupamento
  static const String weeks = 'Semanas';
  static const String months = 'Meses';
  static const String years = 'Anos';

  // Otimização
  static const String photosOptimizedNote =
      'As fotos são comprimidas automaticamente para otimizar espaço.';
  static const String videoOptimizedNote =
      'Este vídeo foi salvo em 720p para otimizar espaço.';
  static const String allFilesOptimizedNote =
      'Todos os arquivos são otimizados para economizar espaço.';

  // Upload
  static const String uploadPending = 'Aguardando envio';
  static const String uploadOptimizing = 'Otimizando...';
  static const String uploadSending = 'Enviando...';
  static const String uploadFailed = 'Falha no envio';
  static const String uploadingCount = 'Enviando';
  static const String uploadRetryAll = 'Reenviar tudo';

  // Busca
  static const String searchHint = 'Buscar memórias...';
  static const String searchByCategory = 'Buscar por categoria';
  static const String recentSearches = 'Buscas recentes';
  static const String searchEmpty = 'Nada encontrado por aqui.';
  static const String clearHistory = 'Limpar histórico';

  // Estatísticas
  static const String storageUsed = 'Armazenamento usado';
  static const String storageOf = 'de';

  // Crescimento
  static const String viewChart = 'Ver gráfico';
  static const String growthChart = 'Gráfico de crescimento';
  static const String growthEmptyTitle = 'Nenhum registro ainda';
  static const String growthEmptyBody =
      'Registre o peso e a altura para acompanhar o crescimento.';

  // Lixeira
  static const String trashEmptyTitle = 'A lixeira está vazia';
  static const String trashEmptyBody =
      'Itens excluídos ficam aqui até você removê-los de vez.';
  static const String trashNote =
      'Os arquivos também vão para a lixeira do Google Drive.';
  static const String deleteForever = 'Excluir definitivamente';
  static const String deleteConfirmTitle = 'Excluir este item?';
  static const String deleteConfirmBody =
      'Ele vai para a lixeira e pode ser restaurado depois.';
  static const String deleteForeverConfirmBody =
      'Esta ação não pode ser desfeita.';

  // Perfil
  static const String babyInfo = 'Informações da bebê';
  static const String googleAccount = 'Conta Google';
  static const String currentAge = 'Idade atual';
  static const String signOutConfirmTitle = 'Sair da conta?';
  static const String signOutConfirmBody =
      'Suas memórias continuam guardadas no Google Drive.';

  // Erros e estados
  static const String genericError = 'Algo deu errado. Tente de novo.';
  static const String offlineNote =
      'Sem conexão. O envio continua assim que a internet voltar.';
  static const String noItemsYet = 'Nada por aqui ainda.';
  static const String requiredField = 'Preencha este campo';
  static const String invalidNumber = 'Informe um número válido';
  static const String loading = 'Carregando...';
}
