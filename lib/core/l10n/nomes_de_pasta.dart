/// Os nomes das pastas no Google Drive.
///
/// **Isto não é a língua da interface, e a diferença é o ponto inteiro deste
/// arquivo.**
///
/// A interface troca de língua quando a pessoa quiser, e nada acontece. As
/// pastas do Drive não podem trocar: elas já existem, já têm arquivos dentro,
/// e a pessoa já as viu. Renomeá-las porque alguém mexeu num ajuste seria
/// mexer no acervo de alguém sem pedir.
///
/// Então a língua das pastas é escolhida **uma vez**, quando a cápsula nasce,
/// e fica guardada no perfil. Quem criou em inglês continua com pastas em
/// inglês para sempre, mesmo lendo o aplicativo em português, e vice-versa.
///
/// Na prática isso quase nunca importa, porque a pasta é reencontrada pelo
/// **id** guardado no Firestore, e não pelo nome. O nome só é usado em dois
/// momentos: ao criar a pasta pela primeira vez, e na busca de emergência de
/// quando o id se perde. É essa segunda que torna tudo isto necessário:
/// procurar pelo nome errado não acha nada, e não achar nada faz o aplicativo
/// criar uma **segunda cápsula** ao lado da primeira.
class NomesDePasta {
  const NomesDePasta({
    required this.codigo,
    required this.raiz,
    required this.fotos,
    required this.videos,
    required this.cartas,
    required this.desenhos,
    required this.documentos,
    required this.crescimento,
    required this.ano,
    required this.mes,
  });

  /// O código do idioma, como fica gravado no perfil.
  final String codigo;

  final String raiz;
  final String fotos;
  final String videos;
  final String cartas;
  final String desenhos;
  final String documentos;
  final String crescimento;

  /// `Ano` / `Year`, sem o número.
  final String ano;

  /// `Mês` / `Month`, sem o número.
  final String mes;

  static const NomesDePasta pt = NomesDePasta(
    codigo: 'pt',
    raiz: 'Meu Bebê - Cápsula do Tempo',
    fotos: 'Fotos',
    videos: 'Vídeos',
    cartas: 'Cartas',
    desenhos: 'Desenhos',
    documentos: 'Documentos',
    crescimento: 'Crescimento',
    ano: 'Ano',
    mes: 'Mês',
  );

  static const NomesDePasta en = NomesDePasta(
    codigo: 'en',
    raiz: 'My Baby - Time Capsule',
    fotos: 'Photos',
    videos: 'Videos',
    cartas: 'Letters',
    desenhos: 'Drawings',
    documentos: 'Documents',
    crescimento: 'Growth',
    ano: 'Year',
    mes: 'Month',
  );

  /// Todas as convenções que já existiram.
  ///
  /// A busca de emergência percorre esta lista inteira, e é por isso que ela
  /// existe: uma cápsula criada em inglês precisa ser encontrada por um
  /// aplicativo aberto em português. Uma língua nova entra aqui **e nunca
  /// sai**, mesmo que deixe de ser oferecida, porque as pastas criadas com
  /// ela continuam no Drive de alguém.
  static const List<NomesDePasta> todas = <NomesDePasta>[pt, en];

  /// A convenção de um código guardado, com o português como piso.
  ///
  /// Cápsula antiga não tem o campo no perfil, e todas elas foram criadas em
  /// português: era a única língua que existia.
  static NomesDePasta de(String? codigo) => todas.firstWhere(
    (NomesDePasta n) => n.codigo == codigo,
    orElse: () => pt,
  );

  /// `Ano 2`
  String anoNumero(int anos) => '$ano $anos';

  /// `Mês 07`, sempre com dois dígitos, para a pasta ordenar por nome.
  String mesNumero(int meses) => '$mes ${meses.toString().padLeft(2, '0')}';
}
