/// Todo o texto visível do aplicativo, em português do Brasil.
///
/// O app é de idioma único por decisão de produto; centralizar aqui mantém a
/// escrita consistente e facilita revisar o tom de voz num lugar só.
abstract final class S {
  /// Nome curto, para o ícone e as barras de título.
  ///
  /// O Android corta o rótulo embaixo do ícone por volta do 11º caractere.
  /// O nome completo ali viraria "Meu Bebê: C...", então ele fica só onde há
  /// espaço de verdade: a loja, a tela de entrada e a tela Sobre.
  static const String appName = 'Meu Bebê';

  /// Nome completo, para a loja e para quem ainda não conhece o aplicativo.
  static const String appFullName = 'Meu Bebê: Cápsula do Tempo';

  /// A segunda linha da tela de entrada, sob o nome curto.
  static const String appSubtitle = 'Cápsula do Tempo';

  static const String appTagline =
      'Cada momento, uma lembrança para a vida toda.';

  // Login
  static const String signInWithGoogle = 'Entrar com Google';

  /// O aviso sob o botão de entrar.
  ///
  /// Diz de quem é a conta, e não de quem é o Drive: é a frase que prepara a
  /// escolha inteira do produto, que é a conta ser da criança desde o
  /// primeiro dia. "filho(a)" porque aqui ainda não existe cadastro, e
  /// portanto não existe nome nem sexo para concordar.
  static const String signInNote =
      'Todas as memórias serão salvas na conta Google Drive do seu filho(a).';
  static const String signInError =
      'Não foi possível entrar. Verifique a conexão e tente de novo.';

  // Onboarding
  static const String onboardingGreeting = 'Olá!';
  static const String fullName = 'Nome completo';
  static const String gender = 'Menino ou menina?';
  static const String birthDate = 'Data de nascimento';
  static const String birthTime = 'Hora de nascimento';
  static const String birthWeight = 'Peso ao nascer';
  static const String birthHeight = 'Altura ao nascer';

  /// Os rótulos do cadastro, onde "(opcional)" é informação e não enfeite.
  ///
  /// Separados dos de cima porque aqueles também rotulam o dado **já
  /// salvo**, na tela de informações da criança. Ali "(opcional)" seria
  /// bobagem: o valor está preenchido, na frente de quem lê.
  static const String birthTimeOptional = 'Hora de nascimento (opcional)';
  static const String birthWeightOptional = 'Peso ao nascer (opcional)';
  static const String birthHeightOptional = 'Altura ao nascer (opcional)';
  static const String hospitalOptional = 'Hospital (opcional)';
  static const String birthPhoto = 'Foto do nascimento';
  static const String continueLabel = 'Continuar';
  static const String preparingDrive =
      'Preparando as pastas no Google Drive...';

  // Navegação
  static const String home = 'Início';
  static const String timeline = 'Linha do Tempo';
  static const String search = 'Busca';

  /// O rótulo do botão no alto do perfil.
  ///
  /// No plural de propósito: é a palavra que conta, para quem tem mais de um
  /// filho, que mais de uma conta cabe aqui. Um ícone sozinho não contava.
  static const String accountsLabel = 'CONTAS';

  /// Trocar de conta do Google, que é como se troca de filho: cada criança
  /// tem a própria conta, e é ela que a criança recebe quando crescer.
  static const String switchAccount = 'Trocar de conta';
  static const String switchAccountAction = 'Trocar';
  static const String switchAccountHint =
      'Cada criança tem a própria conta do Google. Você vai escolher a conta '
      'na tela do Google, e a cápsula dela aparece no lugar desta.\n\n'
      'Para começar a cápsula de outro filho, escolha "Adicionar outra '
      'conta" nessa mesma tela.\n\n'
      'O que está guardado neste aparelho é apagado, então a linha do tempo '
      'leva um instante para carregar de novo.';

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
  static const String storedWithLove = 'Guardado com amor no Drive de';

  // Adicionar
  static const String addQuestion = 'O que você deseja adicionar?';
  static const String addPhoto = 'Foto';
  static const String addVideo = 'Vídeo';
  static const String addLetter = 'Carta';
  static const String addDrawing = 'Desenho';
  static const String addDrawingHint = 'Adicionar um desenho';
  static const String addDocument = 'Documento';
  static const String addDocumentHint = 'Adicionar documentos importantes';
  static const String addGrowth = 'Crescimento';
  static const String addGrowthHint = 'Registrar peso e altura';

  // Linha do tempo
  static const String timelineEmptyTitle = 'A história começa aqui';
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

  // Marcos sugeridos - atalhos, nunca obrigatórios.
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

  // Cartas - começos sugeridos.
  //
  // A parte difícil de escrever uma carta para um filho não é o tamanho do
  // campo: é a primeira frase. Cada um destes termina no meio de propósito,
  // porque um começo pronto convida a continuar e uma frase fechada convida
  // a concordar e fechar o aplicativo.
  static const String letterStartersTitle = 'Não sabe como começar?';
  static const List<String> letterStarters = <String>[
    'Hoje eu quero te contar sobre ',
    'Quando você ler isto, ',
    'Você ainda não sabe, mas ',
    'Uma coisa que eu nunca quero esquecer: ',
    'Se eu pudesse te dizer uma só coisa, seria ',
    'O dia em que você ',
    'Do jeito que você é hoje, o que eu mais amo é ',
  ];

  // Campos comuns
  static const String titleField = 'Título';
  static const String messageField = 'Mensagem';
  static const String descriptionOptional = 'Descrição (opcional)';
  static const String milestoneOptional = 'Marco (opcional)';
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

  // Abas de agrupamento
  static const String weeks = 'Semanas';
  static const String months = 'Meses';
  static const String years = 'Anos';

  // Otimização
  static const String photosOptimizedNote =
      'As fotos são comprimidas automaticamente para otimizar espaço.';
  static const String videoOptimizedNote =
      'Este vídeo foi salvo em 540p para otimizar espaço.';
  static const String allFilesOptimizedNote =
      'Todos os arquivos são otimizados para economizar espaço.';

  // Upload
  static const String uploadPending = 'Aguardando envio';
  static const String uploadOptimizing = 'Otimizando...';
  static const String uploadSending = 'Enviando...';
  static const String uploadFailed = 'Falha no envio';
  static const String uploadingCount = 'Enviando';

  // Busca
  static const String searchHint = 'Buscar memórias...';
  static const String searchByCategory = 'Buscar por categoria';
  static const String recentSearches = 'Buscas recentes';
  static const String searchEmpty = 'Nada encontrado por aqui.';
  static const String clearHistory = 'Limpar histórico';

  // Estatísticas
  static const String storageUsed = 'Armazenamento usado';
  static const String storageOf = 'de';
  static const String capsuleStorage = 'Cápsula do Tempo';
  static const String driveStorage = 'Seu Google Drive';
  static const String driveStorageNote =
      'O total acima é da sua conta Google inteira. O aplicativo enxerga '
      'apenas os arquivos que ele mesmo criou, dentro da pasta da cápsula. '
      'O conteúdo do resto do seu Drive ele não alcança.';

  // Trava do aplicativo
  static const String lockSection = 'Privacidade';
  static const String lockTitle = 'Trava do aplicativo';
  static const String lockBody =
      'Pede sua digital, o rosto ou o PIN do aparelho para abrir o '
      'aplicativo. Vem desligada.';
  static const String lockUnavailable =
      'Este aparelho não tem digital, rosto nem PIN configurado. Configure '
      'uma trava nas configurações do Android para poder usar esta opção.';
  static const String lockNote =
      'A trava protege quem pega o seu celular já destravado. Ela não '
      'criptografa nada: é uma porta a mais, não um cofre.';
  static const String lockFailed =
      'Não foi possível confirmar. A trava continua desligada.';
  static const String lockReason =
      'Confirme que é você para abrir as memórias.';
  static const String lockedTitle = 'Aplicativo trancado';
  static const String lockedBody =
      'Confirme sua identidade para ver as memórias.';
  static const String unlock = 'Desbloquear';

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
  static const String currentAge = 'Idade atual';
  static const String signOutConfirmTitle = 'Sair da conta?';
  static const String signOutConfirmBody =
      'Suas memórias continuam guardadas no seu Google Drive. As miniaturas '
      'e os arquivos baixados são apagados deste aparelho.';

  // Documentos
  static const String privacyPolicy = 'Política de privacidade';

  /// O título da leitura, e não da ação: são duas telas, e a diferença
  /// entre elas é a diferença entre entender e apagar.
  static const String accountDeletionTitle = 'Exclusão de conta e de dados';

  /// A mesma tela, num rodapé estreito. O nome inteiro quebraria em duas
  /// linhas ao lado de um link de uma linha só, e o par ficaria torto.
  static const String accountDeletionShort = 'Exclusão de conta';

  /// O botão no fim da leitura.
  ///
  /// Diz que leva para a tela de apagar, e não que apaga. Repetir aqui o
  /// rótulo do botão vermelho faria dois controles idênticos com efeitos
  /// diferentes, que é como se aperta o errado.
  static const String goToDeleteAccount = 'Ir para a exclusão da conta';

  // Exclusão de conta
  static const String deleteAccount = 'Apagar minha conta e meus dados';
  static const String deleteAccountTitle = 'Apagar a conta?';
  static const String deleteAccountBody =
      'Apagamos do nosso servidor tudo o que guardamos sobre você: o cadastro, '
      'a linha do tempo, os registros de crescimento e o texto das cartas. '
      'Também retiramos a permissão de acesso ao seu Google Drive.\n\n'
      'Esta ação não pode ser desfeita.';
  static const String deleteAccountDriveQuestion =
      'E a pasta "Meu Bebê - Cápsula do Tempo" no seu Drive?';
  static const String deleteAccountKeepDrive = 'Manter os arquivos';
  static const String deleteAccountKeepDriveHint =
      'As fotos, os vídeos e os documentos continuam no seu Drive, '
      'organizados por idade. Recomendado.';
  static const String deleteAccountTrashDrive = 'Mandar para a lixeira';
  static const String deleteAccountTrashDriveHint =
      'A pasta vai para a lixeira do Google Drive e pode ser recuperada por '
      '30 dias.';
  static const String deleteAccountWorking = 'Apagando...';
  static const String deleteAccountDone = 'Conta apagada.';

  // Erros e estados
  static const String genericError = 'Algo deu errado. Tente de novo.';
  static const String noItemsYet = 'Nada por aqui ainda.';
  static const String requiredField = 'Preencha este campo';
  static const String invalidNumber = 'Informe um número válido';
}
