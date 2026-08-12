import 'package:meta/meta.dart';

import 'baby_profile.dart';
import 'entry.dart';
import 'special_date.dart';

/// O que uma inspiração convida a fazer.
enum InspirationKind {
  brincadeira('Brincadeira'),
  passeio('Passeio e ar livre'),
  foto('Ideia de foto'),
  carta('Ideia de carta'),
  leitura('Leitura'),
  preparo('Preparativo'),
  rotina('Rotina e organização'),
  cuidado('Do dia a dia');

  const InspirationKind(this.label);
  final String label;

  static InspirationKind fromId(String? id) => values.firstWhere(
    (InspirationKind k) => k.name == id,
    orElse: () => InspirationKind.brincadeira,
  );
}

/// Quando uma inspiração aparece.
///
/// Antes era só faixa de idade, e faixa de idade não dá conta do que o
/// produto pede: "duas semanas antes do primeiro aniversário" não é uma
/// idade, é uma contagem regressiva. Uma criança nascida em março e outra
/// em outubro chegam nesse ponto em dias diferentes do ano, e o Natal se
/// aproxima das duas ao mesmo tempo.
@immutable
sealed class Anchor {
  const Anchor();

  factory Anchor.fromMap(Map<String, Object?> map) {
    final int? diasAntes = (map['diasAntes'] as num?)?.toInt();
    return switch (map['tipo'] as String?) {
      'antesDoAniversario' => BirthdayAnchor(
        years: (map['anos'] as num?)?.toInt() ?? 1,
        daysBefore: diasAntes ?? 21,
      ),
      'dataEspecial' => SpecialDateAnchor(
        date: SpecialDate.values.firstWhere(
          (SpecialDate d) => d.name == map['data'],
          orElse: () => SpecialDate.natal,
        ),
        daysBefore: diasAntes ?? 21,
        firstOnly: map['apenasPrimeira'] != false,
      ),
      _ => AgeAnchor(
        fromDays: (map['deDias'] as num?)?.toInt() ?? 0,
        toDays: (map['ateDias'] as num?)?.toInt() ?? 99999,
      ),
    };
  }
}

/// Uma faixa de idade.
@immutable
class AgeAnchor extends Anchor {
  const AgeAnchor({required this.fromDays, required this.toDays});
  final int fromDays;
  final int toDays;
}

/// Uma contagem regressiva até um aniversário.
///
/// Vale do dia em que faltam [daysBefore] até o próprio aniversário. Depois
/// dele some, porque uma ideia de festa no dia seguinte à festa é piada.
@immutable
class BirthdayAnchor extends Anchor {
  const BirthdayAnchor({required this.years, required this.daysBefore});
  final int years;
  final int daysBefore;
}

/// Uma contagem regressiva até uma data do calendário.
@immutable
class SpecialDateAnchor extends Anchor {
  const SpecialDateAnchor({
    required this.date,
    required this.daysBefore,
    required this.firstOnly,
  });
  final SpecialDate date;
  final int daysBefore;

  /// Só na primeira vez que a criança passa por essa data.
  final bool firstOnly;
}

/// Um bloco do texto longo.
@immutable
class InspirationSection {
  const InspirationSection({
    required this.title,
    this.body = '',
    this.bullets = const <String>[],
  });

  factory InspirationSection.fromMap(Map<String, Object?> map) =>
      InspirationSection(
        title: (map['titulo'] as String?) ?? '',
        body: (map['texto'] as String?) ?? '',
        bullets: <String>[
          ...?(map['itens'] as List<Object?>?)?.whereType<String>(),
        ],
      );

  final String title;
  final String body;
  final List<String> bullets;
}

/// Um conteúdo do feed.
///
/// Nada aqui afirma o que uma criança "deveria" estar fazendo. É proposital:
/// uma tabela de desenvolvimento numa tela de memórias transforma um álbum
/// em avaliação, e quem lê "aos seis meses já senta" com um filho que ainda
/// não senta ganha uma angústia que não pediu. As âncoras servem para
/// escolher a hora de sugerir, nunca para dizer se está atrasado.
@immutable
class Inspiration {
  const Inspiration({
    required this.id,
    required this.title,
    required this.summary,
    required this.kind,
    required this.anchor,
    this.sections = const <InspirationSection>[],
    this.suggests,
    this.highlight = false,
  });

  factory Inspiration.fromMap(Map<String, Object?> map) => Inspiration(
    id: (map['id'] as String?) ?? '',
    title: (map['titulo'] as String?) ?? '',
    summary: (map['resumo'] as String?) ?? '',
    kind: InspirationKind.fromId(map['tipo'] as String?),
    anchor: Anchor.fromMap(
      (map['quando'] as Map<Object?, Object?>?)?.cast<String, Object?>() ??
          const <String, Object?>{},
    ),
    sections: <InspirationSection>[
      ...?(map['secoes'] as List<Object?>?)
          ?.whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> m) =>
                InspirationSection.fromMap(m.cast<String, Object?>()),
          ),
    ],
    suggests: map['registrar'] == null
        ? null
        : EntryType.fromId(map['registrar'] as String?),
    highlight: map['destaque'] == true,
  );

  final String id;
  final String title;

  /// O que aparece no cartão do feed.
  final String summary;

  final InspirationKind kind;
  final Anchor anchor;

  /// O texto longo, aberto ao tocar. Vazio quando o resumo já basta.
  final List<InspirationSection> sections;

  /// O que a pessoa pode registrar depois de fazer, quando cabe.
  final EntryType? suggests;

  /// Se merece ir para o topo do feed e virar um aviso.
  ///
  /// Poucos, de propósito: se tudo é destaque, nada é.
  final bool highlight;

  /// A foto de capa da postagem.
  ///
  /// O caminho vem do id, sem campo no catálogo: acrescentar a arte de uma
  /// postagem é soltar um arquivo com o nome dela na pasta, e trocar a arte
  /// é substituir esse arquivo. Nada de editar JSON nem código para mudar
  /// uma imagem.
  ///
  /// Plano, e não uma pasta por postagem, por um motivo do Flutter: a lista
  /// de assets do `pubspec.yaml` não alcança subpastas, então cada postagem
  /// nova exigiria uma linha nova ali. Assim é uma linha só, para sempre.
  String get coverAsset => 'assets/inspiracoes/$id.webp';

  /// Tudo o que a busca do blog olha, numa string só.
  ///
  /// Inclui o corpo das seções, e não só o título e o resumo: quem procura
  /// "creche" quer achar a postagem que fala de adaptação mesmo que a
  /// palavra não esteja no título. Sem os acentos, porque ninguém digita
  /// "amamentação" com til numa busca apressada.
  String get searchable => semAcento(
    <String>[
      title,
      summary,
      kind.label,
      for (final InspirationSection s in sections) ...<String>[
        s.title,
        s.body,
        ...s.bullets,
      ],
    ].join(' ').toLowerCase(),
  );

  /// Se a postagem tem texto próprio além do resumo.
  ///
  /// Deixou de decidir se o cartão leva a algum lugar: **toda** inspiração
  /// é uma postagem e abre. Serve agora só para ordenar, dando um empurrão
  /// a quem tem mais o que dizer.
  bool get hasArticle => sections.isNotEmpty;
}

/// A inspiração já resolvida contra uma data.
@immutable
class ActiveInspiration {
  const ActiveInspiration({
    required this.inspiration,
    required this.relevance,
    this.deadline,
    this.daysLeft,
  });

  final Inspiration inspiration;

  /// Quão certeira é para hoje, de 0 a 1. Serve só para ordenar.
  final double relevance;

  /// A data para a qual aponta, quando há uma.
  final DateTime? deadline;
  final int? daysLeft;

  bool get hasDeadline => daysLeft != null;
}

/// Tira os acentos, para a busca não depender de teclado nem de pressa.
String semAcento(String texto) {
  const String com = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const String sem = 'aaaaaeeeeiiiiooooouuuucn';
  final StringBuffer saida = StringBuffer();
  for (final int unidade in texto.codeUnits) {
    final String c = String.fromCharCode(unidade);
    final int i = com.indexOf(c);
    saida.write(i == -1 ? c : sem[i]);
  }
  return saida.toString();
}

/// As postagens que respondem a um termo de busca.
///
/// Busca no catálogo inteiro, e não só no que está ativo hoje. É uma
/// diferença de intenção: a lista **sugere**, e sugerir algo de daqui a dois
/// anos seria ruim; a busca **responde**, e quem digitou "creche" quer a
/// postagem sobre creche mesmo que a criança ainda tenha dois meses.
///
/// A ordem põe primeiro quem tem o termo no título, depois no resumo, e por
/// último quem só o tem no corpo. Empate se resolve pelo id, para a lista
/// não dançar entre uma busca e outra.
List<Inspiration> buscarInspiracoes(String termo, List<Inspiration> todas) {
  final String alvo = semAcento(termo.trim().toLowerCase());
  if (alvo.isEmpty) return const <Inspiration>[];

  int nota(Inspiration i) {
    if (semAcento(i.title.toLowerCase()).contains(alvo)) return 3;
    if (semAcento(i.summary.toLowerCase()).contains(alvo)) return 2;
    if (i.searchable.contains(alvo)) return 1;
    return 0;
  }

  final List<Inspiration> achadas = todas
      .where((Inspiration i) => nota(i) > 0)
      .toList();
  achadas.sort((Inspiration a, Inspiration b) {
    final int porNota = nota(b).compareTo(nota(a));
    return porNota != 0 ? porNota : a.id.compareTo(b.id);
  });
  return achadas;
}

/// Resolve o catálogo contra a criança e o dia de hoje.
///
/// Fica fora da tela e fora da fonte do conteúdo: é a única parte com regra
/// de verdade, e é a que precisa de teste.
List<ActiveInspiration> pickFor({
  required List<Inspiration> all,
  required BabyProfile profile,
  DateTime? now,
}) {
  final DateTime hoje = DateTime(
    (now ?? DateTime.now()).year,
    (now ?? DateTime.now()).month,
    (now ?? DateTime.now()).day,
  );
  final int idadeDias = hoje.difference(profile.birthDay).inDays;

  final List<ActiveInspiration> ativas = <ActiveInspiration>[];
  for (final Inspiration i in all) {
    final ActiveInspiration? ativa = _resolve(
      i,
      birth: profile.birthDay,
      hoje: hoje,
      idadeDias: idadeDias,
    );
    if (ativa != null) ativas.add(ativa);
  }

  ativas.sort((ActiveInspiration a, ActiveInspiration b) {
    // Contagem regressiva vem antes de tudo: é o que tem hora para acontecer.
    if (a.hasDeadline != b.hasDeadline) return a.hasDeadline ? -1 : 1;
    if (a.hasDeadline && b.hasDeadline) {
      final int porPrazo = a.daysLeft!.compareTo(b.daysLeft!);
      if (porPrazo != 0) return porPrazo;
    }
    // Depois o destaque, e então o que foi escrito para esta fase.
    if (a.inspiration.highlight != b.inspiration.highlight) {
      return a.inspiration.highlight ? -1 : 1;
    }
    final int porRelevancia = b.relevance.compareTo(a.relevance);
    // Empate desempata pelo id, para a ordem não dançar a cada abertura.
    return porRelevancia != 0
        ? porRelevancia
        : a.inspiration.id.compareTo(b.inspiration.id);
  });
  return ativas;
}

ActiveInspiration? _resolve(
  Inspiration i, {
  required DateTime birth,
  required DateTime hoje,
  required int idadeDias,
}) {
  switch (i.anchor) {
    case AgeAnchor(:final int fromDays, :final int toDays):
      if (idadeDias < fromDays || idadeDias > toDays) return null;
      final int meio = (fromDays + toDays) ~/ 2;
      final int metade = ((toDays - fromDays) ~/ 2).clamp(1, 1 << 30);
      return ActiveInspiration(
        inspiration: i,
        relevance: 1 - ((idadeDias - meio).abs() / metade).clamp(0.0, 1.0),
      );

    case BirthdayAnchor(:final int years, :final int daysBefore):
      final DateTime alvo = _anniversary(birth, birth.year + years);
      final int faltam = alvo.difference(hoje).inDays;
      if (faltam < 0 || faltam > daysBefore) return null;
      return ActiveInspiration(
        inspiration: i,
        relevance: 1,
        deadline: alvo,
        daysLeft: faltam,
      );

    case SpecialDateAnchor(
      :final SpecialDate date,
      :final int daysBefore,
      :final bool firstOnly,
    ):
      final DateTime proxima = date.nextFrom(hoje);
      if (firstOnly && proxima != date.nextFrom(birth)) return null;
      final int faltam = proxima.difference(hoje).inDays;
      if (faltam > daysBefore) return null;
      return ActiveInspiration(
        inspiration: i,
        relevance: 1,
        deadline: proxima,
        daysLeft: faltam,
      );
  }
}

/// O aniversário caindo dentro de [year], com 29 de fevereiro virando 28 nos
/// anos comuns.
DateTime _anniversary(DateTime birth, int year) {
  final int ultimoDia = DateTime(year, birth.month + 1, 0).day;
  return DateTime(
    year,
    birth.month,
    birth.day < ultimoDia ? birth.day : ultimoDia,
  );
}

/// Até [limit] leituras que combinam com [atual].
///
/// A escolha é por proximidade real, não por sorteio: primeiro o mesmo
/// assunto, depois o que tem texto longo (que é o que aguenta ser aberto), e
/// só entre as que valem hoje - mandar alguém ler sobre algo que só faz
/// sentido daqui a dois anos é pior que não sugerir nada.
///
/// Nunca inclui a própria, e a ordem é estável entre uma abertura e outra.
List<ActiveInspiration> relatedTo(
  ActiveInspiration atual,
  List<ActiveInspiration> ativas, {
  int limit = 3,
}) {
  final List<ActiveInspiration> outras = ativas
      .where((ActiveInspiration a) => a.inspiration.id != atual.inspiration.id)
      .toList();
  if (outras.isEmpty || limit <= 0) return const <ActiveInspiration>[];

  int nota(ActiveInspiration a) {
    int n = 0;
    if (a.inspiration.kind == atual.inspiration.kind) n += 4;
    if (a.inspiration.hasArticle) n += 2;
    if (a.hasDeadline) n += 1;
    return n;
  }

  outras.sort((ActiveInspiration a, ActiveInspiration b) {
    final int porNota = nota(b).compareTo(nota(a));
    return porNota != 0
        ? porNota
        : a.inspiration.id.compareTo(b.inspiration.id);
  });

  // A última vaga é uma porta de saída do assunto.
  //
  // Com as três escolhidas por afinidade, quem entrou por uma ideia de foto
  // só encontra ideias de foto, e a leitura vira um corredor sem janela. A
  // vaga reservada oferece outra coisa: é assim que alguém descobre que
  // existe uma seção sobre cartas.
  //
  // A escolha é sorteada, mas presa ao id da postagem: muda entre uma
  // postagem e outra, e não muda a cada vez que a mesma é aberta. Uma lista
  // que se remexe a cada quadro é uma lista em que ninguém consegue voltar
  // ao que acabou de ver.
  final List<ActiveInspiration> escolhidas = outras.take(limit - 1).toList();

  final List<ActiveInspiration> deOutroAssunto = outras
      .where(
        (ActiveInspiration a) =>
            a.inspiration.kind != atual.inspiration.kind &&
            !escolhidas.contains(a),
      )
      .toList();

  if (deOutroAssunto.isEmpty) {
    // Só existe este assunto ativo hoje: melhor uma a mais dele do que uma
    // vaga vazia.
    return outras.take(limit).toList();
  }

  final int sorteio =
      atual.inspiration.id.codeUnits.fold<int>(
        7,
        (int a, int c) => a * 31 + c,
      ) &
      0x7fffffff;
  escolhidas.add(deOutroAssunto[sorteio % deOutroAssunto.length]);
  return escolhidas;
}
