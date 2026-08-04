import 'package:meta/meta.dart';

/// O que a pessoa fez com uma sugestão.
///
/// Existe um documento por sugestão tocada, e só por essas: quem nunca
/// dispensou nem marcou nada não tem documento nenhum, e a coleção fica
/// vazia em vez de nascer com dezessete registros de "não fiz".
@immutable
class SuggestionProgress {
  const SuggestionProgress({
    this.done = false,
    this.dismissed = false,
    this.checked = const <String>{},
  });

  factory SuggestionProgress.fromMap(Map<String, Object?> map) {
    return SuggestionProgress(
      done: map['feita'] == true,
      dismissed: map['dispensada'] == true,
      checked: <String>{
        ...?(map['marcados'] as List<Object?>?)?.whereType<String>(),
      },
    );
  }

  /// A pessoa registrou a memória que a sugestão convidava a registrar.
  final bool done;

  /// A pessoa disse que não quer mais ver esta sugestão.
  ///
  /// Diferente de [done] só no significado, e o significado importa: um dia
  /// pode fazer sentido oferecer de volta o que foi só dispensado, e nunca o
  /// que já foi feito.
  final bool dismissed;

  /// Itens do checklist marcados, pelo próprio texto.
  final Set<String> checked;

  /// Se a sugestão sai da lista.
  bool get isResolved => done || dismissed;

  SuggestionProgress copyWith({
    bool? done,
    bool? dismissed,
    Set<String>? checked,
  }) => SuggestionProgress(
    done: done ?? this.done,
    dismissed: dismissed ?? this.dismissed,
    checked: checked ?? this.checked,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'feita': done,
    'dispensada': dismissed,
    'marcados': checked.toList(),
  };
}
