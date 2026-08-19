import 'textos.dart';

/// O aplicativo em português do Brasil.
///
/// É o texto original do produto: foi escrito em português primeiro, e as
/// outras línguas saem daqui. Quando uma frase soar estranha em inglês, é
/// aqui que vale conferir o que ela queria dizer.
class TextosPt implements Textos {
  const TextosPt();

  @override
  String get codigo => 'pt';

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
  String faltamDias(int dias) => 'Daqui a ${contarDias(dias)}';

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
  String get willBeSaved => 'Vai ficar guardado';

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
      'Nenhuma foto passa por servidor nosso: elas vão direto do celular para '
      'o Google Drive.';

  @override
  String get aboutScope =>
      'O aplicativo não enxerga o resto do seu Drive. A permissão que você concede dá acesso apenas aos arquivos que ele mesmo cria, todos dentro da pasta "Meu Bebê - Cápsula do Tempo". Suas outras pastas são invisíveis para ele.';

  @override
  String get aboutIndex =>
      'O que fica no nosso servidor é o índice: nome, data de nascimento, '
      'peso, altura, datas e o texto das cartas. É o que faz a linha do tempo '
      'e a busca funcionarem. Você pode apagar tudo isso a qualquer momento, '
      'no seu perfil.';

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

  @override
  String get introBody1 =>
      'Guarde os pequenos momentos antes que eles se tornem apenas lembranças.';

  @override
  String get introTitle4b => 'Um presente para o futuro.';

  @override
  String get introBody3 =>
      'Organizamos tudo pela idade em que aconteceu, formando uma verdadeira linha do tempo da infância.';

  @override
  String get introBody4 =>
      'Um dia, essa cápsula poderá ser aberta por quem mais importa: seu filho.';

  @override
  String get introBody5 =>
      'Recomendamos usar uma conta Google exclusiva para guardar todas essas lembranças por muitos anos.';

  @override
  String get premiumInviteLetters => 'As cartas são do plano Premium';

  @override
  String get premiumInviteDrawings => 'Os desenhos são do plano Premium';

  @override
  String get premiumInviteDocuments => 'Os documentos são do plano Premium';

  @override
  String get premiumInviteGrowth => 'O crescimento é do plano Premium';

  @override
  String get premiumInviteGeneric => 'Isto é do plano Premium';

  @override
  String get premiumInvitePrice =>
      'É uma assinatura anual, cobrada e gerenciada pelo Google Play, que mostra o preço na moeda do seu país.';

  @override
  String get premiumInviteKeeps =>
      'Sem ela nada some: as fotos e os vídeos continuam livres, e tudo o que já está guardado continua aberto para sempre.';

  @override
  String get documentNameQuestion => 'Como você quer chamar';

  @override
  String get videosLabel => 'Vídeos';

  @override
  String get sendMemory => 'Enviar memória';

  @override
  String get languageNote =>
      'A escolha já fica guardada, mas a tradução ainda está sendo feita: por enquanto o aplicativo continua em português.';

  @override
  String get videoOptimizedShort => '540p com bitrate otimizado';

  @override
  String get originalFiles => 'Arquivos originais';

  @override
  String get originalFilesNote => 'Continuam no celular, intactos';

  @override
  String get loginCapsuleHint =>
      'Para criar a conta da cápsula: toque abaixo, e na tela do Google escolha Adicionar outra conta.';

  @override
  String get startupFirebaseHint =>
      'Isso quase sempre é configuração do Firebase: o google-services.json e '
      'o firebase_options.dart precisam ser do mesmo projeto, e o Firestore e '
      'o login com Google precisam estar ativados no console.';

  @override
  String get sentToDrive => 'Está guardado';

  @override
  String get dateNotFoundMedia =>
      'Não achamos a data dentro da mídia, então vale a de hoje. Toque para trocar.';

  @override
  String get dateNotFoundFile =>
      'Não achamos a data dentro do arquivo, então vale a de hoje. Toque para trocar.';

  @override
  String inspirationsSubtitle(String nome) =>
      'Ideias para a fase que $nome está vivendo agora.';

  @override
  String suggestionsGrowNote(String nome) =>
      'As sugestões voltam conforme $nome cresce e as datas se aproximam.';

  @override
  String remindersIntroNamed(String nome) =>
      'Os lembretes vêm ligados porque uma cápsula do tempo só cumpre a '
      'promessa se alguém voltar a ela. São poucos, e existem para você '
      'não perder o dia em que $nome completa mais um mês.';

  @override
  String remindersHourNote(int hora) =>
      'Sempre entre as 8h e as ${hora}h. O aplicativo não acorda ninguém de '
      'madrugada.';

  @override
  String remindersSummary(int marcados, int total, int hora) =>
      '$marcados de $total tipos, às ${hora}h';

  @override
  String birthdayOrdinal(int anos) => 'Para o ${ordinal(anos)} aniversário';

  @override
  String todayWithDate(String data) => 'É hoje, $data';

  @override
  String tomorrowWithDate(String data) => 'Amanhã, $data';

  @override
  String searchNoResults(String termo) =>
      'Não achamos nenhuma postagem com "$termo".';

  @override
  String growthFromBirth(String data) => 'Do nascimento até $data';

  @override
  String savedInDrive(String dono) => 'Está guardado $dono.';

  @override
  String lastUpdated(String data) => 'Última atualização: $data';

  @override
  String batchManyDays(int dias) =>
      'Atenção: o que você escolheu é de $dias dias diferentes, e tudo vai '
      'ser guardado com esta data. Para separar, envie um dia de cada vez.';

  @override
  String get inspirationsSubtitleGeneric => 'Ideias para a fase de agora.';

  @override
  String willBeSavedIn(String dono) => 'Vai ser guardado $dono.';

  @override
  String get remindersIntroGeneric =>
      'Os lembretes vêm ligados porque uma cápsula do tempo só cumpre a promessa se alguém voltar a ela. São poucos, e existem para datas que passam sem ninguém perceber.';

  @override
  String get sealedEmptyIntro =>
      'Ao guardar uma carta ou um vídeo, você pode escolher uma data de '
      'abertura: os 15 anos, os 18, ou qualquer outra. Fica esperando aqui '
      'até lá.';

  @override
  String get aboutPhotosNote =>
      'Nenhuma foto passa por servidor nosso: elas vão direto do seu aparelho para o Google Drive da sua conta.';

  @override
  String get profilePhotoEmpty =>
      'A foto de perfil sai das memórias já guardadas. Acrescente uma foto para poder escolher.';

  @override
  String remindersHourRange(int inicio, int fim) =>
      'Entre ${inicio}h e ${fim}h. O aplicativo não acorda ninguém de '
      'madrugada.';

  @override
  String get typeOneBirth => 'nascimento';

  @override
  String get typeOnePhoto => 'foto';

  @override
  String get typeOneLetter => 'carta';

  @override
  String get typeOneDrawing => 'desenho';

  @override
  String get typeOneDocument => 'documento';

  @override
  String get typeManyBirths => 'nascimentos';

  @override
  String get typeManyPhotos => 'fotos';

  @override
  String get typeManyVideos => 'vídeos';

  @override
  String get typeManyLetters => 'cartas';

  @override
  String get typeManyDrawings => 'desenhos';

  @override
  String get typeManyDocuments => 'documentos';

  @override
  String get typeManyGrowth => 'medições';

  @override
  String get theGrowth => 'o crescimento';

  @override
  String get documentNameQuestionFull => 'Como você quer chamar';

  @override
  String get loginCreateAccountHint =>
      'Para criar a conta da cápsula: toque abaixo, e na caixa do Google escolha "Adicionar outra conta" e depois "Criar conta".';

  @override
  String get aboutInactivity =>
      'O Google apaga contas que ficam dois anos sem uso, e junto vai o que estiver no Drive delas. Isso vale principalmente para quem criou uma conta só para a cápsula.\n\nAbrir este aplicativo de vez em quando já conta como uso, então não é preciso fazer nada além disso. Mesmo assim, se você passar quase um ano sem aparecer, o aplicativo avisa uma vez, e esse aviso pode ser desligado em Configurações.';

  @override
  String get profilePhotoFromMemories =>
      'A foto de perfil sai das memórias já guardadas. Acrescente uma foto e ela aparece aqui.';

  @override
  String premiumInviteWhat(String tipos, String deQuem, String outros) =>
      'Guardar $tipos na cápsula$deQuem faz parte do Premium, junto com '
      '$outros.';

  @override
  String profilePhotoEmptyOf(String deQuem) =>
      'A foto de perfil sai das memórias já guardadas. Acrescente uma foto '
      '$deQuem e ela aparece aqui.';

  @override
  String comArtigo(String plural) => 'os $plural';

  @override
  String get errNoConnection => 'Sem conexão com a internet. Tente de novo.';

  @override
  String get errFileRead => 'Não foi possível ler o arquivo no aparelho.';

  @override
  String get errPermissionDenied =>
      'O servidor recusou a gravação. Saia da conta e entre de novo; se continuar, é uma configuração do aplicativo, e não sua.';

  @override
  String get errSessionExpired =>
      'Sua sessão expirou. Entre de novo para continuar.';

  @override
  String get errMissingIndex =>
      'As suas memórias estão salvas, mas o servidor ainda não consegue organizá-las para mostrar aqui. É uma configuração do aplicativo, e não sua.';

  @override
  String get errServerQuiet =>
      'O servidor não respondeu. Tente de novo em instantes.';

  @override
  String get errRecentLogin =>
      'Por segurança, entre de novo antes de continuar.';

  @override
  String get errGeneric => 'Não foi possível concluir. Tente de novo.';

  @override
  String get errDriveExpired =>
      'O acesso ao Google Drive expirou. Saia da conta e entre de novo para renovar a permissão.';

  @override
  String get errDriveNotEnabled =>
      'O Google Drive ainda não está liberado para este aplicativo. É uma configuração nossa, não sua: nada do que você preencheu se perdeu.';

  @override
  String get errDriveFull =>
      'O seu Google Drive está sem espaço. Libere espaço na conta e tente de novo.';

  @override
  String get errDriveRateLimit =>
      'O Google Drive pediu para esperar um pouco. Tente de novo em instantes.';

  @override
  String get errDriveForbidden =>
      'O Google Drive recusou o acesso. Saia da conta e entre de novo para autorizar a pasta da cápsula.';

  @override
  String get errDriveFolderMissing =>
      'A pasta da cápsula não foi encontrada no seu Google Drive.';

  @override
  String get errDriveQuiet =>
      'O Google Drive não respondeu. Tente de novo em instantes; nada do que você preencheu se perdeu.';

  @override
  String get errDriveGeneric =>
      'Não foi possível falar com o Google Drive. Tente de novo.';

  @override
  String get authSlow =>
      'O login com Google está demorando para responder. Confira a conexão e tente de novo.';

  @override
  String get authUnsupported =>
      'Este dispositivo não oferece o login com Google.';

  @override
  String get authNoIdentifier =>
      'Não recebemos o identificador da conta. Confira a configuração do login com Google e tente de novo.';

  @override
  String get authOtherAccount =>
      'A permissão guardada é de outra conta do Google. Entre de novo para continuar guardando nesta cápsula.';

  @override
  String get authRenewDrive =>
      'Precisamos renovar a permissão do Google Drive.';

  @override
  String get authSignInToContinue => 'Entre com a conta Google para continuar.';

  @override
  String get authDriveRefused =>
      'Você não autorizou o acesso ao Google Drive. É lá que as memórias ficam guardadas, na sua própria conta.';

  @override
  String get authReloginToDelete =>
      'Para apagar a conta, entre de novo e repita a operação.';

  @override
  String get authScreenFailed =>
      'Não foi possível abrir a tela do Google. Tente de novo.';

  @override
  String get authConfigIncomplete =>
      'A configuração do login com Google está incompleta.';

  @override
  String get authServicesUnavailable =>
      'Serviços do Google indisponíveis neste dispositivo.';

  @override
  String get authWrongAccount =>
      'A conta escolhida é diferente da conta em uso.';

  @override
  String get emptyDocuments => 'Nenhum documento ainda';

  @override
  String get emptyDrawings => 'Nenhum desenho ainda';

  @override
  String get emptyLetters => 'Nenhuma carta ainda';

  @override
  String get emptyPhotos => 'Nenhuma foto ainda';

  @override
  String get emptySealed => 'Nada lacrado ainda';

  @override
  String get emptyMoments => 'Nada pendente por aqui';

  @override
  String get emptyInspirations => 'Nada por aqui agora';

  @override
  String get emptySearchTopic => 'Nada sobre isso ainda';

  @override
  String get firstPhotosHint => 'Toque no + para adicionar as primeiras fotos.';

  @override
  String daysLeft(int dias) => dias == 1 ? 'Falta 1 dia' : 'Faltam $dias dias';

  @override
  String daysLeftWithDate(int dias, String data) => 'Faltam $dias dias, $data';

  @override
  String remindersSummaryFull(int marcados, int total, int hora) =>
      '$marcados de $total tipos, às ${hora}h';

  @override
  String contarSemanas(int n) => n == 1 ? '1 semana' : '$n semanas';

  @override
  String semanaNumero(String n) => 'Semana $n';

  @override
  String mesNumero(String n) => 'Mês $n';

  @override
  String anoNumero(String n) => 'Ano $n';

  @override
  String uploadWithDate(String oQue, String data) =>
      '$oQue com a data de $data.';

  @override
  String uploadBornThatDay(String nome) => 'Foi o dia em que $nome nasceu.';

  @override
  String uploadBornThatDayGeneric() => 'Foi o dia do nascimento.';

  @override
  String uploadAgeThen(String nome, String idade) =>
      'Nessa data $nome tinha $idade.';

  @override
  String uploadAgeThenGeneric(String idade) => 'Idade nessa data: $idade.';

  @override
  String uploadWhereInDrive(String caminho) =>
      'No Drive, vai ficar em $caminho.';

  @override
  String get holidayNewYear => 'Ano Novo';

  @override
  String get holidayCarnival => 'Carnaval';

  @override
  String get holidayEaster => 'Páscoa';

  @override
  String get holidayMothers => 'Dia das Mães';

  @override
  String get holidayFathers => 'Dia dos Pais';

  @override
  String get holidayChristmas => 'Natal';

  @override
  String get kindLetter => 'Ideia de carta';

  @override
  String get kindReading => 'Leitura';

  @override
  String get kindPrep => 'Preparativo';

  @override
  String get kindRoutine => 'Rotina e organização';

  @override
  String get kindEveryday => 'Do dia a dia';

  @override
  String get kindPlay => 'Brincadeira';

  @override
  String get notifChannelName => 'Lembretes da cápsula';

  @override
  String get notifChannelDescription =>
      'Datas redondas, aniversários e lembretes de guardar uma memória.';

  @override
  String get errPhotoCompress => 'Não foi possível comprimir esta foto.';

  @override
  String get errVideoConvert => 'Não foi possível converter este vídeo.';

  @override
  String get errOriginalsMissing =>
      'Os arquivos originais não estão neste aparelho.';

  @override
  String get errPickPhotoAgain => 'Escolha a foto de novo para guardá-la.';

  @override
  String get errOriginalsMissingFull =>
      'Os arquivos originais não estão neste aparelho. Reenvie a partir do celular onde eles foram escolhidos.';

  @override
  String get errFileGoneFull =>
      'O arquivo saiu deste aparelho antes de o envio terminar. Escolha a foto de novo para guardá-la.';

  @override
  String get kindOuting => 'Passeio e ar livre';

  @override
  String get kindPhoto => 'Ideia de foto';

  @override
  String get reminderRoundLabel => 'Datas redondas';

  @override
  String get reminderRoundDesc => 'Mensiversários e a virada de cada ano';

  @override
  String get reminderBirthdayLabel => 'Aniversário';

  @override
  String get reminderBirthdayDesc => 'Uma semana antes, e no dia';

  @override
  String get reminderSpecialLabel => 'Primeiras vezes do ano';

  @override
  String get reminderSpecialDesc => 'Natal, Páscoa, Dia das Mães';

  @override
  String get reminderInspirationLabel => 'Ideias na hora certa';

  @override
  String get reminderInspirationDesc => 'Quando uma ideia só serve agora';

  @override
  String get reminderAbsenceLabel => 'Lembrete gentil';

  @override
  String get reminderAbsenceDesc => 'Quando faz muito tempo sem registrar nada';

  @override
  String get reminderInactiveLabel => 'A conta do Google';

  @override
  String get reminderInactiveDesc =>
      'Um aviso por ano, para a cápsula não se perder';

  @override
  String get notifWeekLeftTitle => 'Falta uma semana';

  @override
  String get notifBirthdayTodayGeneric =>
      'É hoje. Guarde alguma coisa deste dia.';

  @override
  String get notifMomentTitle => 'Um instante de hoje';

  @override
  String get notifInactiveTitle => 'A cápsula precisa de você por um minuto';

  @override
  String get notifPhotoWorthIt =>
      'Uma foto de hoje vai valer muito daqui a vinte anos.';

  @override
  String get notifAbsenceGeneric =>
      'Faz um tempo desde a última memória. Uma foto qualquer, do jeito que o dia estiver, já basta.';

  @override
  String get notifInactiveGeneric =>
      'Faz quase um ano que você não abre. O Google apaga contas sem uso por dois anos, e é numa delas que as memórias moram. Abrir de vez em quando já basta.';

  @override
  String get theChild => 'a criança';

  @override
  String notifFirstBirthdaySoon(String quem) =>
      'O primeiro aniversário $quem é daqui a sete dias. Boa hora para '
      'escolher as fotos do primeiro ano.';

  @override
  String notifBirthdaySoon(String quem, int anos) =>
      '$quem faz $anos anos daqui a sete dias.';

  @override
  String notifBirthdayTitle(int anos) =>
      anos == 1 ? 'Um ano hoje' : '$anos anos hoje';

  @override
  String notifBirthdayToday(String deQuem) =>
      'Hoje é o dia $deQuem. Guarde alguma coisa deste dia.';

  @override
  String notifMonthsTitle(int meses) =>
      meses == 1 ? 'Hoje é 1 mês' : 'Hoje são $meses meses';

  @override
  String notifMonthsBody(String nome, int meses) =>
      '$nome completa ${contarMeses(meses)} hoje. Uma foto de hoje vai '
      'valer muito daqui a vinte anos.';

  @override
  String notifFirstHolidayTitle(String data) => 'O primeiro $data';

  @override
  String notifFirstHolidayBody(String data, String deQuem) =>
      'Daqui a três dias é o primeiro $data $deQuem. Vale uma foto.';

  @override
  String notifFirstHolidayBodyGeneric(String data) =>
      'Daqui a três dias é o primeiro $data. Vale uma foto.';

  @override
  String notifAbsenceBody(String deQuem) =>
      'Faz um tempo desde a última memória $deQuem. Uma foto qualquer, do '
      'jeito que o dia estiver, já basta.';

  @override
  String notifInactiveBody(String deQuem) =>
      'Faz quase um ano que você não abre. O Google apaga contas sem uso por '
      'dois anos, e é numa delas que as memórias $deQuem moram. Abrir de vez '
      'em quando já basta.';

  @override
  String tituloDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'O primeiro Natal',
    'primeiro-ano-novo' => 'O primeiro Ano Novo',
    'primeiro-carnaval' => 'O primeiro Carnaval',
    'primeira-pascoa' => 'A primeira Páscoa',
    'primeiro-dia-das-maes' => 'O primeiro Dia das Mães',
    'primeiro-dia-dos-pais' => 'O primeiro Dia dos Pais',
    'primeiro-aniversario' => 'Preparando o primeiro aniversário',
    'primeiro-sorriso' => 'O primeiro sorriso',
    'primeiro-dentinho' => 'O primeiro dentinho',
    'primeira-palavra' => 'A primeira palavra',
    'primeiros-passos' => 'Os primeiros passos',
    'primeiro-corte-cabelo' => 'O primeiro corte de cabelo',
    'primeira-viagem' => 'A primeira viagem',
    'primeira-praia' => 'A primeira praia',
    'primeira-escola' => 'O primeiro dia de escola',
    'primeira-bicicleta' => 'A primeira bicicleta',
    _ => id,
  };

  @override
  String? notaDaSugestao(String id) => switch (id) {
    'primeiro-natal' => 'O primeiro Natal {nome} está chegando.',
    'primeiro-ano-novo' => 'A primeira virada de ano {nome}.',
    'primeiro-carnaval' => 'Uma fantasia, uma foto, e pronto.',
    'primeiro-dia-das-maes' =>
      'Que tal uma carta para {nome} ler daqui a muitos anos?',
    'primeiro-aniversario' => 'O primeiro ano {nome} está chegando.',
    'primeiro-sorriso' => 'Costuma aparecer por volta das seis semanas.',
    'primeira-palavra' =>
      'Grave a voz {nome}. Daqui a vinte anos, isso não tem preço.',
    'primeiros-passos' => 'Vale mais em vídeo que em foto.',
    'primeiro-corte-cabelo' => 'Antes e depois, se der.',
    _ => null,
  };

  @override
  List<String> checklistDoAniversario() => <String>[
    'Escolher o tema',
    'Definir os convidados',
    'Escolher o bolo',
    'Comprar a roupa',
    'Gravar um vídeo',
    'Escrever uma carta para o futuro',
  ];

  @override
  String get languageStepTitle => 'Em que idioma?';

  @override
  String get languageStepNote =>
      'Vale para o aplicativo inteiro e para os nomes das pastas no Google Drive. As pastas ficam com o idioma de agora para sempre, mesmo que você troque o do aplicativo depois.';

  @override
  String get closeLabel => 'Fechar';

  @override
  String get skip => 'Pular';

  @override
  String get createRecommendedAccount => 'Criar conta recomendada';

  @override
  String get useCurrentAccount => 'Usar minha conta atual';

  @override
  String get exactlyToday => 'Hoje faz exatamente';

  @override
  String get beenAWhile => 'Faz um tempo';

  @override
  String get toLiveNow => 'Para viver agora';

  @override
  String forNameNow(String nome) => 'Para $nome, agora';

  @override
  String get readThePost => 'Ler a postagem';

  @override
  String get inspirationsChangeNote =>
      'As ideias mudam conforme a idade. Volte em breve.';

  @override
  String get savingEllipsis => 'Guardando...';

  @override
  String get viewFolder => 'Ver a pasta';

  @override
  String get viewDrawing => 'Ver o desenho';

  @override
  String get documentName => 'Nome do documento';

  @override
  String documentNameOf(int atual, int total) =>
      'Nome do documento $atual de $total';

  @override
  String get keep => 'Guardar';

  @override
  String get keepForFuture => 'Guardar para o futuro';

  @override
  String get savedForFuture => 'Guardado para o futuro';

  @override
  String get opensToday => 'Abre hoje';

  @override
  String opensOn(String data) => 'Abre em $data';

  @override
  String sealedUntilNotice(String data) => 'Guardado para abrir em $data.';

  @override
  String whenTurns(int anos) => 'Quando fizer $anos anos';

  @override
  String opensInYearsAtAge(int anos, int idade) =>
      'Daqui a ${contarAnos(anos)}, quando tiver $idade';

  @override
  String get writeSomethingFirst => 'Escreva alguma coisa antes de salvar.';

  @override
  String get noAppForFile => 'Nenhum aplicativo consegue abrir este arquivo.';

  @override
  String get drawingsEmptyBody =>
      'Fotografe um desenho e ele fica guardado para sempre.';

  @override
  String birthdayAgeOf(int anos, String deQuem) =>
      '${contarAnos(anos)} $deQuem';

  @override
  String get atBirth => 'No nascimento';

  @override
  String get conjuncaoE => 'e';

  @override
  String savedInFolder(String pasta, String conta) =>
      'Está guardado em $pasta, $conta.';

  @override
  String willBeSavedInFolder(String pasta) => 'Vai ficar guardado em $pasta.';

  @override
  String get renameDocument => 'Renomear documento';

  @override
  String get rename => 'Renomear';

  @override
  String get addedOn => 'Adicionado em';

  @override
  String get sizeLabel => 'Tamanho';

  @override
  String get fewRecords => 'Poucos registros';

  @override
  String get recentPhotos => 'Fotos recentes';

  @override
  String get seeAll => 'Ver todas';

  @override
  String get record => 'Registrar';

  @override
  String get searchPosts => 'Buscar nas postagens';

  @override
  String get searchPostsHint => 'Buscar nas postagens...';

  @override
  String get clearLabel => 'Limpar';

  @override
  String get tryAgainShortly => 'Tente abrir de novo daqui a pouco.';

  @override
  String get write => 'Escrever';

  @override
  String get importantMoments => 'Momentos importantes';

  @override
  String get hospital => 'Hospital';

  @override
  String get girl => 'Menina';

  @override
  String get boy => 'Menino';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get changeProfilePhoto => 'Trocar a foto de perfil';

  @override
  String get receiveReminders => 'Receber lembretes';

  @override
  String get atWhatTime => 'A que horas';

  @override
  String get chooseAnotherDate => 'Escolher outra data';

  @override
  String get removeSeal => 'Tirar o lacre';

  @override
  String get checkTheDate => 'Confere a data?';

  @override
  String get savingDrawing => 'Guardando o desenho...';

  @override
  String get convertingAndSending => 'Convertendo para 540p e enviando...';

  @override
  String get viewDocument => 'Ver o documento';

  @override
  String get viewDocuments => 'Ver os documentos';

  @override
  String get groupBy => 'Agrupar por';

  @override
  String umDoTipo(String tipo) => 'Um $tipo';
  @override
  String get titleHintExample => 'Primeiro sorriso';
}
