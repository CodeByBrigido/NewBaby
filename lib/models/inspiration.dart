import 'package:meta/meta.dart';

import 'entry.dart';

/// O que uma inspiração convida a fazer.
///
/// Serve para o ícone e a cor do cartão, e para a pessoa reconhecer de longe
/// o tipo de coisa que vai ler.
enum InspirationKind {
  brincadeira('Brincadeira'),
  passeio('Passeio'),
  foto('Ideia de foto'),
  carta('Ideia de carta'),
  leitura('Leitura'),
  preparo('Preparativo'),
  cuidado('Do dia a dia');

  const InspirationKind(this.label);
  final String label;

  static InspirationKind fromId(String? id) => values.firstWhere(
    (InspirationKind k) => k.name == id,
    orElse: () => InspirationKind.brincadeira,
  );
}

/// Um conteúdo do feed de inspirações.
///
/// Nada aqui afirma o que uma criança "deveria" estar fazendo. É proposital:
/// uma tabela de desenvolvimento numa tela de memórias transforma um álbum
/// em avaliação, e a mãe que lê "aos seis meses já senta" com um filho que
/// ainda não senta ganha uma angústia que não pediu. As faixas de idade aqui
/// servem só para escolher a hora de sugerir, nunca para dizer se está
/// atrasado.
@immutable
class Inspiration {
  const Inspiration({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.fromDays,
    required this.toDays,
    this.suggests,
  });

  factory Inspiration.fromMap(Map<String, Object?> map) => Inspiration(
    id: (map['id'] as String?) ?? '',
    title: (map['titulo'] as String?) ?? '',
    body: (map['texto'] as String?) ?? '',
    kind: InspirationKind.fromId(map['tipo'] as String?),
    fromDays: (map['deDias'] as num?)?.toInt() ?? 0,
    toDays: (map['ateDias'] as num?)?.toInt() ?? 99999,
    suggests: map['registrar'] == null
        ? null
        : EntryType.fromId(map['registrar'] as String?),
  );

  final String id;
  final String title;
  final String body;
  final InspirationKind kind;

  /// A faixa de idade em que faz sentido sugerir isto.
  final int fromDays;
  final int toDays;

  /// O que a pessoa pode registrar depois de fazer, quando cabe.
  final EntryType? suggests;

  bool appliesAt(int ageDays) => ageDays >= fromDays && ageDays <= toDays;

  /// Quão certeira a sugestão é para esta idade, de 0 a 1.
  ///
  /// Serve para ordenar: o que foi escrito pensando exatamente nesta fase
  /// aparece antes do que só por acaso ainda cabe.
  double relevanceAt(int ageDays) {
    if (!appliesAt(ageDays)) return 0;
    final int meio = (fromDays + toDays) ~/ 2;
    final int metade = ((toDays - fromDays) ~/ 2).clamp(1, 1 << 30);
    return 1 - ((ageDays - meio).abs() / metade).clamp(0.0, 1.0);
  }
}
