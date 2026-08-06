import 'entry.dart';

/// O que aconteceu num dia, em uma frase.
///
/// "5 fotos, 1 vídeo e 1 carta" é o que a linha do tempo mostra antes de
/// abrir o dia. Existe porque um dia cheio, todo aberto, empurra os outros
/// para fora da tela: quem está folheando a infância inteira precisa
/// enxergar o mês, não rolar cento e vinte cartões.
///
/// A ordem segue a do enum, e não a contagem, para que dois dias parecidos
/// se pareçam na tela em vez de embaralhar conforme o que teve mais.
String summarizeDay(List<Entry> entries) {
  final Map<EntryType, int> contagem = <EntryType, int>{};
  for (final Entry entry in entries) {
    contagem[entry.type] = (contagem[entry.type] ?? 0) + 1;
  }

  final List<String> partes = <String>[
    for (final EntryType type in EntryType.values)
      if (contagem[type] case final int n when n > 0)
        '$n ${n == 1 ? type.one : type.many}',
  ];

  return _joinPtBr(partes);
}

/// Junta com vírgula e um "e" antes do último, como se escreve em português.
String _joinPtBr(List<String> partes) => switch (partes.length) {
  0 => '',
  1 => partes.first,
  _ => '${partes.sublist(0, partes.length - 1).join(', ')} e ${partes.last}',
};
