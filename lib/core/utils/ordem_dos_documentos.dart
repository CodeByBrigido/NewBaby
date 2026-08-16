import '../../models/entry.dart';

/// A ordem em que os documentos aparecem na lista.
///
/// Duas regras, nesta ordem: quem foi arrastado à mão vem primeiro, na
/// posição escolhida; quem nunca foi arrastado vem depois, do mais recente
/// para o mais antigo.
///
/// A mistura é de propósito. Exigir que a pessoa organize a lista inteira
/// antes de a ordem valer para alguma coisa seria cobrar trabalho adiantado;
/// e jogar os não arrastados para o topo faria a certidão que alguém acabou
/// de colocar em primeiro lugar ser empurrada por um documento novo, que é
/// exatamente o que ela tentou evitar.
///
/// Função pura, e por isso testável sem Firestore, sem Drive e sem tela.
List<Entry> ordemDosDocumentos(List<Entry> documentos) {
  final List<Entry> comOrdem = <Entry>[];
  final List<Entry> semOrdem = <Entry>[];
  for (final Entry e in documentos) {
    (e.ordem == null ? semOrdem : comOrdem).add(e);
  }

  comOrdem.sort((Entry a, Entry b) {
    final int porOrdem = a.ordem!.compareTo(b.ordem!);
    // Duas posições iguais acontecem: dois aparelhos podem arrastar a lista
    // sem se falar. O desempate pelo id não é bonito, é estável, e estável é
    // o que impede a lista de dançar entre duas aberturas.
    return porOrdem != 0 ? porOrdem : a.id.compareTo(b.id);
  });
  semOrdem.sort((Entry a, Entry b) {
    final int porData = b.date.compareTo(a.date);
    return porData != 0 ? porData : a.id.compareTo(b.id);
  });

  return <Entry>[...comOrdem, ...semOrdem];
}
