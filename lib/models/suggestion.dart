import 'package:meta/meta.dart';

import '../core/utils/age_calculator.dart';
import 'baby_profile.dart';
import 'entry.dart';
import 'special_date.dart';

/// O que faz uma sugestão aparecer.
///
/// Separado do texto de propósito: acrescentar uma sugestão nova passa a ser
/// acrescentar uma linha ao catálogo, sem tocar em lógica nenhuma. Era o
/// pedido explícito para os checklists, e vale igual para os momentos e as
/// datas especiais, que no fundo são o mesmo problema.
@immutable
sealed class Trigger {
  const Trigger();
}

/// Uma faixa de idade: "por volta dos quatro meses".
///
/// As faixas são largas de propósito. Criança não segue tabela, e uma
/// sugestão que aparece cedo demais e some antes da hora é pior que
/// nenhuma.
@immutable
class AgeWindow extends Trigger {
  const AgeWindow(this.fromDays, this.toDays);
  final int fromDays;
  final int toDays;
}

/// Perto de uma data do calendário, e só na primeira vez que ela acontece.
@immutable
class FirstSpecialDate extends Trigger {
  const FirstSpecialDate(this.date, {this.daysBefore = 14});
  final SpecialDate date;
  final int daysBefore;
}

/// Perto de um aniversário específico.
@immutable
class BeforeBirthday extends Trigger {
  const BeforeBirthday(this.years, {this.daysBefore = 30});
  final int years;
  final int daysBefore;
}

/// Uma sugestão do catálogo.
///
/// Sugestão, e nunca registro. O aplicativo não sabe se a criança já sorriu,
/// e fingir que sabe seria inventar a memória de alguém. Ele pergunta.
@immutable
class Suggestion {
  const Suggestion({
    required this.id,
    required this.title,
    required this.trigger,
    this.note,
    this.suggests,
    this.checklist = const <String>[],
  });

  /// Estável para sempre: é a chave gravada quando a pessoa marca como feita
  /// ou dispensa. Mudar um id aqui ressuscita sugestões já resolvidas.
  final String id;

  final String title;

  /// Uma frase curta. `{nome}` vira o nome da criança.
  final String? note;

  final Trigger trigger;

  /// O tipo de memória que a sugestão convida a registrar.
  final EntryType? suggests;

  final List<String> checklist;

  bool get hasChecklist => checklist.isNotEmpty;

  String noteFor(String name) => note?.replaceAll('{nome}', name) ?? '';
}

/// Uma sugestão que vale hoje, já com o prazo resolvido.
@immutable
class ActiveSuggestion {
  const ActiveSuggestion({
    required this.suggestion,
    required this.checked,
    this.deadline,
    this.daysLeft,
  });

  final Suggestion suggestion;

  /// Itens do checklist já marcados.
  final Set<String> checked;

  /// A data para a qual a sugestão aponta, quando existe uma.
  final DateTime? deadline;
  final int? daysLeft;

  /// Sugestões com prazo vêm primeiro, e entre elas a mais urgente.
  /// As sem prazo (os momentos) ficam por último, na ordem do catálogo.
  int get urgency => daysLeft ?? 9999;
}

/// O catálogo.
///
/// É só dado. Para acrescentar uma sugestão, acrescente uma entrada aqui.
abstract final class Suggestions {
  static const List<Suggestion> all = <Suggestion>[
    // ------------------------------------------------- datas do calendário
    Suggestion(
      id: 'primeiro-natal',
      title: 'O primeiro Natal',
      note: 'O primeiro Natal {nome} está chegando.',
      trigger: FirstSpecialDate(SpecialDate.natal),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeiro-ano-novo',
      title: 'O primeiro Ano Novo',
      note: 'A primeira virada de ano {nome}.',
      trigger: FirstSpecialDate(SpecialDate.anoNovo),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeiro-carnaval',
      title: 'O primeiro Carnaval',
      note: 'Uma fantasia, uma foto, e pronto.',
      trigger: FirstSpecialDate(SpecialDate.carnaval),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeira-pascoa',
      title: 'A primeira Páscoa',
      trigger: FirstSpecialDate(SpecialDate.pascoa),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeiro-dia-das-maes',
      title: 'O primeiro Dia das Mães',
      note: 'Que tal uma carta para {nome} ler daqui a muitos anos?',
      trigger: FirstSpecialDate(SpecialDate.diaDasMaes),
      suggests: EntryType.letter,
    ),
    Suggestion(
      id: 'primeiro-dia-dos-pais',
      title: 'O primeiro Dia dos Pais',
      trigger: FirstSpecialDate(SpecialDate.diaDosPais),
      suggests: EntryType.letter,
    ),

    // ---------------------------------------------------------- checklists
    Suggestion(
      id: 'primeiro-aniversario',
      title: 'Preparando o primeiro aniversário',
      note: 'O primeiro ano {nome} está chegando.',
      trigger: BeforeBirthday(1, daysBefore: 45),
      suggests: EntryType.photo,
      checklist: <String>[
        'Escolher o tema',
        'Definir os convidados',
        'Escolher o bolo',
        'Comprar a roupa',
        'Gravar um vídeo',
        'Escrever uma carta para o futuro',
      ],
    ),

    // ------------------------------------------------ momentos importantes
    //
    // Nenhum destes é assumido. O aplicativo não tem como saber se já
    // aconteceu, e inventar a memória de alguém seria pior que não sugerir.
    Suggestion(
      id: 'primeiro-sorriso',
      title: 'O primeiro sorriso',
      note: 'Costuma aparecer por volta das seis semanas.',
      trigger: AgeWindow(21, 150),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeiro-dentinho',
      title: 'O primeiro dentinho',
      trigger: AgeWindow(100, 400),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeira-palavra',
      title: 'A primeira palavra',
      note: 'Grave a voz {nome}. Daqui a vinte anos, isso não tem preço.',
      trigger: AgeWindow(210, 540),
      suggests: EntryType.video,
    ),
    Suggestion(
      id: 'primeiros-passos',
      title: 'Os primeiros passos',
      note: 'Vale mais em vídeo que em foto.',
      trigger: AgeWindow(240, 550),
      suggests: EntryType.video,
    ),
    Suggestion(
      id: 'primeiro-corte-cabelo',
      title: 'O primeiro corte de cabelo',
      note: 'Antes e depois, se der.',
      trigger: AgeWindow(150, 730),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeira-viagem',
      title: 'A primeira viagem',
      trigger: AgeWindow(60, 2000),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeira-praia',
      title: 'A primeira praia',
      trigger: AgeWindow(90, 2000),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeira-escola',
      title: 'O primeiro dia de escola',
      trigger: AgeWindow(540, 1825),
      suggests: EntryType.photo,
    ),
    Suggestion(
      id: 'primeira-bicicleta',
      title: 'A primeira bicicleta',
      trigger: AgeWindow(730, 2200),
      suggests: EntryType.video,
    ),
  ];

  /// As sugestões que valem hoje, da mais urgente para a menos.
  ///
  /// [resolved] traz os ids que a pessoa já marcou como feitos ou dispensou.
  /// Eles não voltam: nada é mais irritante que um aplicativo insistindo em
  /// algo que já foi resolvido.
  static List<ActiveSuggestion> activeFor({
    required BabyProfile profile,
    required Set<String> resolved,
    Map<String, Set<String>> checked = const <String, Set<String>>{},
    DateTime? now,
  }) {
    final DateTime today = AgeCalculator.dayOf(now ?? DateTime.now());
    final DateTime birth = profile.birthDay;
    final int ageDays = today.difference(birth).inDays;

    final List<ActiveSuggestion> ativas = <ActiveSuggestion>[];
    for (final Suggestion s in all) {
      if (resolved.contains(s.id)) continue;

      final ActiveSuggestion? ativa = _resolve(
        s,
        birth: birth,
        today: today,
        ageDays: ageDays,
        checked: checked[s.id] ?? const <String>{},
      );
      if (ativa != null) ativas.add(ativa);
    }

    ativas.sort(
      (ActiveSuggestion a, ActiveSuggestion b) =>
          a.urgency.compareTo(b.urgency),
    );
    return ativas;
  }

  static ActiveSuggestion? _resolve(
    Suggestion s, {
    required DateTime birth,
    required DateTime today,
    required int ageDays,
    required Set<String> checked,
  }) {
    switch (s.trigger) {
      case AgeWindow(:final int fromDays, :final int toDays):
        if (ageDays < fromDays || ageDays > toDays) return null;
        return ActiveSuggestion(suggestion: s, checked: checked);

      case FirstSpecialDate(:final SpecialDate date, :final int daysBefore):
        // A primeira ocorrência é a primeira depois do nascimento. Se a
        // próxima a partir de hoje não é aquela, esta criança já passou por
        // ela e a sugestão não vale mais.
        final DateTime primeira = date.nextFrom(birth);
        final DateTime proxima = date.nextFrom(today);
        if (proxima != primeira) return null;

        final int faltam = primeira.difference(today).inDays;
        if (faltam > daysBefore) return null;
        return ActiveSuggestion(
          suggestion: s,
          checked: checked,
          deadline: primeira,
          daysLeft: faltam,
        );

      case BeforeBirthday(:final int years, :final int daysBefore):
        final DateTime alvo = _anniversary(birth, birth.year + years);
        final int faltam = alvo.difference(today).inDays;
        if (faltam < 0 || faltam > daysBefore) return null;
        return ActiveSuggestion(
          suggestion: s,
          checked: checked,
          deadline: alvo,
          daysLeft: faltam,
        );
    }
  }

  /// O aniversário caindo dentro de [year], com 29 de fevereiro virando 28
  /// nos anos comuns.
  static DateTime _anniversary(DateTime birth, int year) {
    final int ultimoDia = DateTime(year, birth.month + 1, 0).day;
    return DateTime(
      year,
      birth.month,
      birth.day < ultimoDia ? birth.day : ultimoDia,
    );
  }
}
