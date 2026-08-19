import 'textos.dart';

/// O aplicativo em português do Brasil.
///
/// É o texto original do produto: foi escrito em português primeiro, e as
/// outras línguas saem daqui. Quando uma frase soar estranha em inglês, é
/// aqui que vale conferir o que ela queria dizer.
class TextosPt implements Textos {
  const TextosPt();

  @override
  String get appName => 'Meu Bebê';

  @override
  String get appFullName => 'Meu Bebê: Cápsula do Tempo';

  @override
  String get appSubtitle => 'Cápsula do Tempo';

  @override
  String get appTagline => 'Cada momento, uma lembrança para a vida toda.';

  @override
  String get signInWithGoogle => 'Entrar com Google';

  @override
  String get signInNote =>
      'Todas as memórias serão salvas na conta Google Drive do seu filho(a).';

  @override
  String get signInError =>
      'Não foi possível entrar. Verifique a conexão e tente de novo.';

  @override
  String get onboardingGreeting => 'Olá!';

  @override
  String get fullName => 'Nome completo';

  @override
  String get gender => 'Menino ou menina?';

  @override
  String get birthDate => 'Data de nascimento';

  @override
  String get birthTime => 'Hora de nascimento';

  @override
  String get birthWeight => 'Peso ao nascer';

  @override
  String get birthHeight => 'Altura ao nascer';

  @override
  String get birthTimeOptional => 'Hora de nascimento (opcional)';

  @override
  String get birthWeightOptional => 'Peso ao nascer (opcional)';

  @override
  String get birthHeightOptional => 'Altura ao nascer (opcional)';

  @override
  String get hospitalOptional => 'Hospital (opcional)';

  @override
  String get birthPhoto => 'Foto do nascimento';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get preparingDrive => 'Preparando as pastas no Google Drive...';

  @override
  String get home => 'Início';

  @override
  String get timeline => 'Linha do Tempo';

  @override
  String get search => 'Busca';

  @override
  String get accountsLabel => 'CONTAS';

  @override
  String get switchAccount => 'Trocar de conta';

  @override
  String get profile => 'Perfil';

  @override
  String get photos => 'Fotos';

  @override
  String get videos => 'Vídeos';

  @override
  String get letters => 'Cartas';

  @override
  String get drawings => 'Desenhos';

  @override
  String get documents => 'Documentos';

  @override
  String get growth => 'Crescimento';

  @override
  String get stats => 'Estatísticas';

  @override
  String get trash => 'Lixeira';

  @override
  String get settings => 'Configurações';

  @override
  String get about => 'Sobre o aplicativo';

  @override
  String get signOut => 'Sair';

  @override
  String get storedWithLove => 'Guardado com amor no Drive de';

  @override
  String get addQuestion => 'O que você deseja adicionar?';

  @override
  String get addPhoto => 'Foto';

  @override
  String get addVideo => 'Vídeo';

  @override
  String get addLetter => 'Carta';

  @override
  String get addDrawing => 'Desenho';

  @override
  String get addDrawingHint => 'Adicionar um desenho';

  @override
  String get addDocument => 'Documento';

  @override
  String get addDocumentHint => 'Adicionar documentos importantes';

  @override
  String get addGrowth => 'Crescimento';

  @override
  String get addGrowthHint => 'Registrar peso e altura';

  @override
  String get timelineEmptyTitle => 'A história começa aqui';

  @override
  String get birth => 'Nascimento';

  @override
  String get photosAdded => 'Fotos adicionadas';

  @override
  String get photoAdded => 'Foto adicionada';

  @override
  String get videoAdded => 'Vídeo adicionado';

  @override
  String get drawingAdded => 'Desenho adicionado';

  @override
  String get documentAdded => 'Documento adicionado';

  @override
  String get growthRecord => 'Registro de crescimento';

  @override
  String get letterPrefix => 'Carta:';

  @override
  String get filterAll => 'Tudo';

  @override
  String get filterTitle => 'Filtrar por tipo';

  @override
  List<String> get milestoneSuggestions => <String>[
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

  @override
  String get letterStartersTitle => 'Não sabe como começar?';

  @override
  List<String> get letterStarters => <String>[
    'Hoje eu quero te contar sobre ',
    'Quando você ler isto, ',
    'Você ainda não sabe, mas ',
    'Uma coisa que eu nunca quero esquecer: ',
    'Se eu pudesse te dizer uma só coisa, seria ',
    'O dia em que você ',
    'Do jeito que você é hoje, o que eu mais amo é ',
  ];

  @override
  String get titleField => 'Título';

  @override
  String get messageField => 'Mensagem';

  @override
  String get descriptionOptional => 'Descrição (opcional)';

  @override
  String get milestoneOptional => 'Marco (opcional)';

  @override
  String get weightField => 'Peso';

  @override
  String get heightField => 'Altura';

  @override
  String get photoOptional => 'Foto (opcional)';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get edit => 'Editar';

  @override
  String get share => 'Compartilhar';

  @override
  String get delete => 'Excluir';

  @override
  String get restore => 'Restaurar';

  @override
  String get view => 'Visualizar';

  @override
  String get download => 'Baixar';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get weeks => 'Semanas';

  @override
  String get months => 'Meses';

  @override
  String get years => 'Anos';

  @override
  String get photosOptimizedNote =>
      'As fotos são comprimidas automaticamente para otimizar espaço.';

  @override
  String get videoOptimizedNote =>
      'Este vídeo foi salvo em 540p para otimizar espaço.';

  @override
  String get allFilesOptimizedNote =>
      'Todos os arquivos são otimizados para economizar espaço.';

  @override
  String get uploadPending => 'Aguardando envio';

  @override
  String get uploadOptimizing => 'Otimizando...';

  @override
  String get uploadSending => 'Enviando...';

  @override
  String get uploadFailed => 'Falha no envio';

  @override
  String get uploadingCount => 'Enviando';

  @override
  String get searchHint => 'Buscar memórias...';

  @override
  String get searchByCategory => 'Buscar por categoria';

  @override
  String get recentSearches => 'Buscas recentes';

  @override
  String get searchEmpty => 'Nada encontrado por aqui.';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get storageUsed => 'Armazenamento usado';

  @override
  String get storageOf => 'de';

  @override
  String get capsuleStorage => 'Cápsula do Tempo';

  @override
  String get driveStorage => 'Seu Google Drive';

  @override
  String get driveStorageNote =>
      'O total acima é da sua conta Google inteira. O aplicativo enxerga '
      'apenas os arquivos que ele mesmo criou, dentro da pasta da cápsula. '
      'O conteúdo do resto do seu Drive ele não alcança.';

  @override
  String get lockSection => 'Privacidade';

  @override
  String get lockTitle => 'Trava do aplicativo';

  @override
  String get lockBody =>
      'Pede sua digital, o rosto ou o PIN do aparelho para abrir o '
      'aplicativo. Vem desligada.';

  @override
  String get lockUnavailable =>
      'Este aparelho não tem digital, rosto nem PIN configurado. Configure '
      'uma trava nas configurações do Android para poder usar esta opção.';

  @override
  String get lockNote =>
      'A trava protege quem pega o seu celular já destravado. Ela não '
      'criptografa nada: é uma porta a mais, não um cofre.';

  @override
  String get lockFailed =>
      'Não foi possível confirmar. A trava continua desligada.';

  @override
  String get lockReason => 'Confirme que é você para abrir as memórias.';

  @override
  String get lockedTitle => 'Aplicativo trancado';

  @override
  String get lockedBody => 'Confirme sua identidade para ver as memórias.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get viewChart => 'Ver gráfico';

  @override
  String get growthChart => 'Gráfico de crescimento';

  @override
  String get growthEmptyTitle => 'Nenhum registro ainda';

  @override
  String get growthEmptyBody =>
      'Registre o peso e a altura para acompanhar o crescimento.';

  @override
  String get trashEmptyTitle => 'A lixeira está vazia';

  @override
  String get trashEmptyBody =>
      'Itens excluídos ficam aqui até você removê-los de vez.';

  @override
  String get trashNote =>
      'Os arquivos também vão para a lixeira do Google Drive.';

  @override
  String get deleteForever => 'Excluir definitivamente';

  @override
  String get deleteConfirmTitle => 'Excluir este item?';

  @override
  String get deleteConfirmBody =>
      'Ele vai para a lixeira e pode ser restaurado depois.';

  @override
  String get deleteForeverConfirmBody => 'Esta ação não pode ser desfeita.';

  @override
  String get currentAge => 'Idade atual';

  @override
  String get birthDateShort => 'Nascimento';

  @override
  String get signOutConfirmTitle => 'Sair da conta?';

  @override
  String get signOutConfirmBody =>
      'Suas memórias continuam guardadas no seu Google Drive. As miniaturas '
      'e os arquivos baixados são apagados deste aparelho.';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get accountDeletionTitle => 'Exclusão de conta e de dados';

  @override
  String get accountDeletionShort => 'Exclusão de conta';

  @override
  String get goToDeleteAccount => 'Ir para a exclusão da conta';

  @override
  String get deleteAccount => 'Apagar minha conta e meus dados';

  @override
  String get deleteAccountTitle => 'Apagar a conta?';

  @override
  String get deleteAccountBody =>
      'Apagamos do nosso servidor tudo o que guardamos sobre você: o cadastro, '
      'a linha do tempo, os registros de crescimento e o texto das cartas. '
      'Também retiramos a permissão de acesso ao seu Google Drive.\n\n'
      'Esta ação não pode ser desfeita.';

  @override
  String get deleteAccountDriveQuestion =>
      'E a pasta "Meu Bebê - Cápsula do Tempo" no seu Drive?';

  @override
  String get deleteAccountKeepDrive => 'Manter os arquivos';

  @override
  String get deleteAccountKeepDriveHint =>
      'As fotos, os vídeos e os documentos continuam no seu Drive, '
      'organizados por idade. Recomendado.';

  @override
  String get deleteAccountTrashDrive => 'Mandar para a lixeira';

  @override
  String get deleteAccountTrashDriveHint =>
      'A pasta vai para a lixeira do Google Drive e pode ser recuperada por '
      '30 dias.';

  @override
  String get deleteAccountWorking => 'Apagando...';

  @override
  String get deleteAccountDone => 'Conta apagada.';

  @override
  String get genericError => 'Algo deu errado. Tente de novo.';

  @override
  String get noItemsYet => 'Nada por aqui ainda.';

  @override
  String get requiredField => 'Preencha este campo';

  @override
  String get invalidNumber => 'Informe um número válido';

  @override
  String get codigoIntl => 'pt_BR';

  @override
  String get padraoData => 'dd/MM/yyyy';

  @override
  String get padraoDiaMes => 'dd/MM';

  @override
  String get padraoDataLonga => "dd 'de' MMMM 'de' yyyy";

  @override
  String get padraoMesAno => "MMMM 'de' yyyy";

  @override
  String get padraoHora => 'HH:mm';

  @override
  String get entreDatas => 'a';

  @override
  String get hoje => 'Hoje';

  @override
  String get ontem => 'Ontem';

  @override
  String saudacao(int hora) {
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  String haTempo(int dias) {
    if (dias <= 0) return 'hoje';
    if (dias == 1) return 'ontem';
    if (dias < 14) return 'há $dias dias';
    if (dias < 60) {
      final int semanas = dias ~/ 7;
      return semanas == 1 ? 'há 1 semana' : 'há $semanas semanas';
    }
    if (dias < 365) {
      final int meses = dias ~/ 30;
      return meses == 1 ? 'há 1 mês' : 'há $meses meses';
    }
    final int anos = dias ~/ 365;
    return anos == 1 ? 'há 1 ano' : 'há $anos anos';
  }

  @override
  String ordinal(int n) => switch (n) {
    1 => 'primeiro',
    2 => 'segundo',
    3 => 'terceiro',
    4 => 'quarto',
    5 => 'quinto',
    6 => 'sexto',
    7 => 'sétimo',
    8 => 'oitavo',
    9 => 'nono',
    10 => 'décimo',
    _ => '$n\u00ba',
  };

  @override
  String contarDias(int n) => n == 1 ? '1 dia' : '$n dias';

  @override
  String contarMeses(int n) => n == 1 ? '1 mês' : '$n meses';

  @override
  String contarAnos(int n) => n == 1 ? '1 ano' : '$n anos';

  @override
  String contarItens(int n) => n == 1 ? '1 item' : '$n itens';

  @override
  String contarFotos(int n) => n == 1 ? '1 foto' : '$n fotos';

  @override
  String contarVideos(int n) => n == 1 ? '1 vídeo' : '$n vídeos';

  @override
  String get lastBirth => 'Último nascimento';

  @override
  String get lastPhoto => 'Última foto';

  @override
  String get lastVideo => 'Último vídeo';

  @override
  String get lastLetter => 'Última carta';

  @override
  String get lastDrawing => 'Último desenho';

  @override
  String get lastDocument => 'Último documento';

  @override
  String get lastGrowth => 'Última medição';

  @override
  String get oneVideo => 'vídeo';

  @override
  String get oneGrowth => 'medição';

  @override
  String get imageOpenFailed => 'Não foi possível abrir esta imagem.';

  @override
  String get videoOpenFailed => 'Não foi possível abrir este vídeo.';

  @override
  String get documentNotFound => 'Documento não encontrado';

  @override
  String get letterNotFound => 'Carta não encontrada';

  @override
  String get entryNotFound => 'Memória não encontrada';

  @override
  String get driveSpaceFailed =>
      'Não foi possível ler o espaço do Google Drive.';

  @override
  String get firstVideoHint => 'Toque no + para adicionar o primeiro vídeo.';

  @override
  String get documentsEmptyBody =>
      'Certidão, carteira de vacinação, passaporte - tudo em um lugar só.';

  @override
  String get isToday => 'É hoje';

  @override
  String get isTodayBang => 'É hoje!';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get nextMilestone => 'Próximo marco';

  @override
  String get seeInspiration => 'Ver inspiração';

  @override
  String get forYou => 'Para você';

  @override
  String get notYet => 'ainda não';

  @override
  String get inspirations => 'Inspirações';

  @override
  String get inspirationsLoadFailed => 'Não deu para carregar as ideias';

  @override
  String get inspirationSearchHint => 'O que você quer saber?';

  @override
  String get suggestionsByAge =>
      'As sugestões aparecem conforme a idade e o calendário.';

  @override
  String get notNow => 'Agora não';

  @override
  String get savedTitle => 'Está guardado';

  @override
  String get sendMemoryError => 'Enviar memória';

  @override
  String get dateFromFile => 'Data lida do próprio arquivo. Toque para trocar.';

  @override
  String get deletedOn => 'Excluído em ';

  @override
  String get itemDeleted => 'Item excluído.';

  @override
  String get documentNameSuggestion => 'Certidão de nascimento';

  @override
  String get saveInfo => 'Salvar informações';

  @override
  String get editInfo => 'Editar informações';

  @override
  String get notProvided => 'Não informada';

  @override
  String get automatic => 'Automática';

  @override
  String get reviewIntro => 'Rever a apresentação';

  @override
  String get lastUpdatedLabel => 'Última atualização';

  @override
  String get optimization => 'Otimização';

  @override
  String get photoMaxSide => 'Até 960 px no lado maior';

  @override
  String get optimizationNote =>
      'A otimização é automática e não pode ser desligada - é o que mantém o acervo leve por muitos anos.';

  @override
  String get languageSection => 'Idioma';

  @override
  String get clearCacheBody =>
      'Apaga miniaturas, arquivos temporários e os documentos já baixados. Nada é perdido: tudo continua no Google Drive.';

  @override
  String get cacheCleared => 'Cache limpo.';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get storageOnDevice => 'Armazenamento no aparelho';

  @override
  String get remindersSection => 'Lembretes';

  @override
  String get remindersOff => 'Desligados';

  @override
  String get startupFailedTitle => 'O aplicativo não conseguiu iniciar';

  @override
  String get technicalDetail => 'Detalhe técnico';

  @override
  String get premiumInviteAction => 'Entendi';

  @override
  String get introTitle1 => 'A infância passa depressa.';

  @override
  String get introTitle2 => 'Toda lembrança tem seu lugar.';

  @override
  String get introBody2 =>
      'Fotos, vídeos, cartas, desenhos, documentos e registros de crescimento. Tudo reunido em um único lugar.';

  @override
  String get introTitle3 => 'Cada memória no seu tempo.';

  @override
  String get introTitle4 => 'Vamos criar essa cápsula?';

  @override
  String get sealBody =>
      'Isto fica fechado até a data que você escolher. O conteúdo continua no seu Drive, e você pode abrir antes se quiser: é um lacre, como o da cápsula enterrada no quintal, não um cofre.';

  @override
  String get aboutPhotos =>
      'Nenhuma foto passa por servidor nosso: elas vão direto do seu aparelho para o Google Drive da sua conta.';

  @override
  String get aboutScope =>
      'O aplicativo não enxerga o resto do seu Drive. A permissão que você concede dá acesso apenas aos arquivos que ele mesmo cria, todos dentro da pasta "Meu Bebê - Cápsula do Tempo". Suas outras pastas são invisíveis para ele.';

  @override
  String get aboutIndex =>
      'O que fica no nosso servidor é o índice: nome, data de nascimento, peso, altura, datas e o texto das cartas. É o que faz a linha do tempo e a busca funcionarem. Você pode apagar tudo isso quando quiser.';

  @override
  String get aboutLastingTitle => 'Para a cápsula durar';

  @override
  String get deleteDriveNote =>
      'Mesmo mandando para a lixeira, os arquivos são seus e estão no seu Drive: o aplicativo nunca teve uma cópia deles.';

  @override
  String get profilePhotoNote =>
      'A foto de perfil sai das memórias já guardadas. Acrescente uma foto para poder escolher.';

  @override
  String get remindersHowTitle => 'Sobre o quê';

  @override
  String get remindersMarkedTitle => 'O que está marcado';

  @override
  String get remindersFrequency =>
      'No máximo dois por semana, nunca dois no mesmo dia.';

  @override
  String get remindersOffNote =>
      'Desligado. Nada é enviado. Se o celular tiver negado as notificações, libere em Ajustes, Aplicativos, Meu Bebê.';

  @override
  String get remindersNothingSoon =>
      'Nada nas próximas semanas. Isso é normal: os lembretes aparecem quando há de fato uma data por perto.';

  @override
  String get remindersPrivacy =>
      'Os lembretes são calculados dentro do seu celular, a partir do que já está aqui. Nada é enviado para nenhum servidor para isso acontecer, e nenhum aviso cita o que você guardou.';

  @override
  String get remindersDenied =>
      'O Android não autorizou as notificações. Você pode liberar nos ajustes do celular, em Aplicativos, Meu Bebê.';

  @override
  String get sealedEmptyBody =>
      'Ao guardar uma carta ou um vídeo, você pode escolher uma data para ele abrir: um aniversário, a maioridade, ou qualquer outra. Fica esperando aqui até lá.';

  @override
  String get growthChartHint =>
      'A partir de dois registros o gráfico começa a contar a história.';
}
