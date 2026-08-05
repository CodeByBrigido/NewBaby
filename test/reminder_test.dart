import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/capsule_pulse.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/models/inspiration.dart';
import 'package:meu_bebe/models/reminder.dart';

/// As notificações.
///
/// O motor é uma função pura, e é por isso que dá para testar em segundos o
/// que levaria dois anos para observar num aparelho. O que está sendo
/// verificado aqui não é só se a conta bate: é o **limite**. Um aplicativo de
/// memórias que avisa demais vira um aplicativo desligado, e um aplicativo
/// desligado não lembra de nada.
void main() {
  final DateTime nascimento = DateTime(2026, 3, 10);
  final BabyProfile maria = BabyProfile(
    name: 'Maria Eduarda',
    birth: nascimento,
  );

  Entry foto(DateTime quando) => Entry(
    id: 'e-${quando.millisecondsSinceEpoch}',
    type: EntryType.photo,
    date: quando,
    createdAt: quando,
    ageDays: quando.difference(nascimento).inDays,
    bucketKey: 'S01',
    bucketName: 'Semana 01',
  );

  List<ScheduledReminder> planoEm(
    DateTime hoje, {
    ReminderSettings settings = const ReminderSettings(enabled: true),
    List<Entry> entradas = const <Entry>[],
    List<ActiveInspiration> inspiracoes = const <ActiveInspiration>[],
    Set<String> lidas = const <String>{},
  }) => planReminders(
    profile: maria,
    pulse: CapsulePulse.from(profile: maria, entries: entradas, now: hoje),
    settings: settings,
    inspirations: inspiracoes,
    readInspirations: lidas,
    now: hoje,
  );

  Set<ReminderKind> tiposEm(DateTime hoje, {List<Entry> entradas = const []}) =>
      planoEm(
        hoje,
        entradas: entradas,
      ).map((ScheduledReminder r) => r.kind).toSet();

  group('ligado por padrão, e desligável', () {
    test('o padrão é ligado, porque quem não volta não revisita', () {
      // Decisão de produto: uma cápsula do tempo só cumpre a promessa se
      // alguém voltar a ela, e quem tem bebê pequeno não volta por conta
      // própria. Isto **não** é permissão: o Android continua perguntando,
      // e a recusa dele desliga a chave.
      expect(const ReminderSettings().enabled, isTrue);
    });

    test('desligado, a agenda é vazia', () {
      expect(
        planoEm(
          DateTime(2027, 2, 20),
          settings: const ReminderSettings(enabled: false),
          entradas: <Entry>[foto(DateTime(2027, 2, 1))],
        ),
        isEmpty,
      );
    });

    test('cada tipo pode ser desligado sozinho', () {
      final ReminderSettings soAniversario = const ReminderSettings(
        enabled: true,
      ).copyWith(kinds: <ReminderKind>{ReminderKind.aniversario});

      final Set<ReminderKind> tipos = planoEm(
        DateTime(2027, 2, 20),
        settings: soAniversario,
        entradas: <Entry>[foto(DateTime(2026, 12, 1))],
      ).map((ScheduledReminder r) => r.kind).toSet();

      expect(tipos, <ReminderKind>{ReminderKind.aniversario});
    });
  });

  group('o teto vale acima de qualquer regra', () {
    test('nunca dois no mesmo dia', () {
      for (final DateTime hoje in <DateTime>[
        DateTime(2026, 12, 5),
        DateTime(2027, 2, 20),
        DateTime(2027, 3, 1),
        DateTime(2028, 2, 10),
      ]) {
        final List<ScheduledReminder> plano = planoEm(
          hoje,
          entradas: <Entry>[foto(hoje.subtract(const Duration(days: 20)))],
        );
        final List<DateTime> dias = plano
            .map((ScheduledReminder r) => r.day)
            .toList();
        expect(dias.toSet().length, dias.length, reason: 'em $hoje');
      }
    });

    test('nunca mais de dois em sete dias', () {
      for (final DateTime hoje in <DateTime>[
        DateTime(2026, 11, 20),
        DateTime(2027, 2, 15),
        DateTime(2027, 4, 1),
      ]) {
        final List<ScheduledReminder> plano = planoEm(
          hoje,
          entradas: <Entry>[foto(hoje.subtract(const Duration(days: 25)))],
        );
        for (final ScheduledReminder r in plano) {
          final DateTime fim = r.day.add(const Duration(days: 6));
          final int janela = plano
              .where(
                (ScheduledReminder o) =>
                    !o.day.isBefore(r.day) && !o.day.isAfter(fim),
              )
              .length;
          expect(
            janela,
            lessThanOrEqualTo(maxRemindersPerWeek),
            reason: 'a semana que começa em ${r.day} tem $janela avisos',
          );
        }
      }
    });

    test('nada é agendado para o passado nem para longe demais', () {
      final DateTime hoje = DateTime(2027, 2, 20);
      for (final ScheduledReminder r in planoEm(
        hoje,
        entradas: <Entry>[foto(DateTime(2027, 2, 1))],
      )) {
        expect(r.when.isAfter(hoje), isTrue, reason: r.title);
        // O aviso da conta é o único que passa da janela, e passa de
        // propósito: ele existe para quem parou de abrir o aplicativo, então
        // não pode depender de uma abertura futura para ser reagendado.
        if (r.kind.livesBeyondHorizon) continue;
        expect(
          r.day.difference(hoje).inDays,
          lessThanOrEqualTo(reminderHorizonDays),
          reason: r.title,
        );
      }
    });
  });

  group('a hora do dia', () {
    test('respeita a escolha da pessoa', () {
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2027, 2, 20),
        settings: const ReminderSettings(enabled: true, hour: 19),
      );
      expect(plano, isNotEmpty);
      for (final ScheduledReminder r in plano) {
        expect(r.when.hour, 19);
      }
    });

    test('nunca de madrugada, nem que peçam', () {
      // Um aplicativo de bebê acordando a casa às três da manhã é uma piada
      // de mau gosto.
      for (final int hora in <int>[0, 3, 5, 23]) {
        final List<ScheduledReminder> plano = planoEm(
          DateTime(2027, 2, 20),
          settings: ReminderSettings(enabled: true, hour: hora),
        );
        for (final ScheduledReminder r in plano) {
          expect(
            r.when.hour,
            greaterThanOrEqualTo(ReminderSettings.earliestHour),
          );
          expect(r.when.hour, lessThanOrEqualTo(ReminderSettings.latestHour));
        }
      }
    });
  });

  group('o aniversário', () {
    test('avisa uma semana antes e no dia', () {
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2027, 2, 20),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.aniversario},
        ),
      );
      expect(plano.length, 2);
      expect(plano.first.day, DateTime(2027, 3, 3));
      expect(plano.last.day, DateTime(2027, 3, 10));
    });

    test('o primeiro tem texto próprio', () {
      final ScheduledReminder umAno = planoEm(
        DateTime(2027, 3, 5),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.aniversario},
        ),
      ).last;
      expect(umAno.title, 'Um ano hoje');
    });

    test('ganha o dia de qualquer outro aviso', () {
      // 10 de março de 2027 é o aniversário e também um mensiversário de 12
      // meses. Quem fica com o dia é o aniversário.
      final List<ScheduledReminder> plano = planoEm(DateTime(2027, 3, 5));
      final ScheduledReminder noDia = plano.firstWhere(
        (ScheduledReminder r) => r.day == DateTime(2027, 3, 10),
      );
      expect(noDia.kind, ReminderKind.aniversario);
    });
  });

  group('as datas redondas', () {
    test('o mensiversário chega no dia certo', () {
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2026, 8, 20),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.dataRedonda},
        ),
      );
      expect(plano.first.day, DateTime(2026, 9, 10));
      expect(plano.first.title, 'Hoje são 6 meses');
    });

    test('param aos dois anos, porque "27 meses" ninguém diz', () {
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2028, 4, 1),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.dataRedonda},
        ),
      );
      expect(plano, isEmpty);
    });

    test('o mês 12 não vira mensiversário, para não repetir o aniversário', () {
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2027, 3, 1),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.dataRedonda},
        ),
      );
      expect(
        plano.where((ScheduledReminder r) => r.day == DateTime(2027, 3, 10)),
        isEmpty,
      );
    });
  });

  group('as primeiras vezes do ano', () {
    test('o primeiro Natal avisa três dias antes', () {
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2026, 12, 15),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.dataEspecial},
        ),
      );
      final ScheduledReminder natal = plano.firstWhere(
        (ScheduledReminder r) => r.title.contains('Natal'),
      );
      expect(natal.day, DateTime(2026, 12, 22));
    });

    test('o segundo Natal não avisa', () {
      // O primeiro Natal é um acontecimento; o quarto é um Natal.
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2027, 12, 15),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.dataEspecial},
        ),
      );
      expect(
        plano.where((ScheduledReminder r) => r.title.contains('Natal')),
        isEmpty,
      );
    });
  });

  group('o lembrete gentil', () {
    test('não existe numa cápsula ainda vazia', () {
      // Silêncio no primeiro dia não é esquecimento, é o começo. Cobrar
      // alguém que acabou de instalar o aplicativo seria atropelo.
      expect(
        tiposEm(DateTime(2026, 3, 12)),
        isNot(contains(ReminderKind.ausencia)),
      );
    });

    test('conta a partir do último registro, seja de que tipo for', () {
      final DateTime hoje = DateTime(2026, 6, 1);
      final List<ScheduledReminder> plano = planoEm(
        hoje,
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.ausencia},
        ),
        entradas: <Entry>[foto(DateTime(2026, 5, 30))],
      );
      // Registrou há 2 dias, o limite é 14: faltam 12.
      expect(plano.single.day, hoje.add(const Duration(days: 12)));
    });

    test('quem já passou do prazo é avisado amanhã, não hoje', () {
      final DateTime hoje = DateTime(2026, 6, 1);
      final List<ScheduledReminder> plano = planoEm(
        hoje,
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.ausencia},
        ),
        entradas: <Entry>[foto(DateTime(2026, 4, 1))],
      );
      expect(plano.single.day, hoje.add(const Duration(days: 1)));
    });

    test('não diz há quantos dias', () {
      // "Faz 43 dias" é uma cobrança com número. Quem passou seis semanas
      // num hospital não precisa de um aplicativo contando.
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2026, 6, 1),
        settings: const ReminderSettings(
          enabled: true,
          kinds: <ReminderKind>{ReminderKind.ausencia},
        ),
        entradas: <Entry>[foto(DateTime(2026, 4, 1))],
      );
      expect(plano.single.body, isNot(matches(RegExp(r'\d'))));
    });

    test('perde o dia para qualquer outro aviso', () {
      final DateTime hoje = DateTime(2027, 3, 3);
      final List<ScheduledReminder> plano = planoEm(
        hoje,
        entradas: <Entry>[foto(hoje.subtract(const Duration(days: 13)))],
      );
      // No dia 10 há aniversário e ausência ao mesmo tempo.
      final Iterable<ScheduledReminder> noDia = plano.where(
        (ScheduledReminder r) => r.day == DateTime(2027, 3, 10),
      );
      expect(noDia.single.kind, ReminderKind.aniversario);
    });
  });

  group('o aviso da conta esquecida', () {
    const ReminderSettings soConta = ReminderSettings(
      enabled: true,
      kinds: <ReminderKind>{ReminderKind.contaInativa},
    );

    test('vem ligado por padrão, como os outros', () {
      expect(
        const ReminderSettings().kinds,
        contains(ReminderKind.contaInativa),
      );
    });

    test('é marcado para daqui a onze meses', () {
      final DateTime hoje = DateTime(2026, 8, 4);
      final ScheduledReminder aviso = planoEm(hoje, settings: soConta).single;
      expect(aviso.day, hoje.add(const Duration(days: inactivityWarningDays)));
    });

    test('vive fora da janela dos outros, e é o único que vive', () {
      // O motor só marca 45 dias à frente porque reagenda a cada abertura.
      // Este aviso não pode contar com abertura nenhuma: a ausência de
      // abertura é exatamente o que ele avisa. Sem esta exceção, ele seria
      // descartado pela peneira e nunca dispararia.
      expect(inactivityWarningDays, greaterThan(reminderHorizonDays));
      expect(planoEm(DateTime(2026, 8, 4), settings: soConta), hasLength(1));

      for (final ReminderKind k in ReminderKind.values) {
        expect(
          k.livesBeyondHorizon,
          k == ReminderKind.contaInativa,
          reason: k.name,
        );
      }
    });

    test('foge para a frente a cada abertura', () {
      // É o comportamento inteiro do aviso: quem continua aparecendo nunca o
      // recebe, porque cada abertura reagenda tudo e empurra a data.
      final DateTime hoje = DateTime(2026, 8, 4);
      final DateTime umMesDepois = DateTime(2026, 9, 4);

      final DateTime primeira = planoEm(hoje, settings: soConta).single.day;
      final DateTime segunda = planoEm(
        umMesDepois,
        settings: soConta,
      ).single.day;

      expect(segunda.isAfter(primeira), isTrue);
      expect(segunda.difference(primeira).inDays, 31);
    });

    test('chega com folga antes dos dois anos do Google', () {
      // Um aviso que chega no último dia é um aviso que chega tarde.
      expect(inactivityWarningDays, lessThan(365));
    });

    test('pode ser desligado sozinho, sem levar os outros junto', () {
      final ReminderSettings semConta = const ReminderSettings(enabled: true)
          .copyWith(
            kinds: <ReminderKind>{
              for (final ReminderKind k in ReminderKind.values)
                if (k != ReminderKind.contaInativa) k,
            },
          );
      final Set<ReminderKind> tipos = planoEm(
        DateTime(2026, 8, 4),
        settings: semConta,
        entradas: <Entry>[foto(DateTime(2026, 7, 20))],
      ).map((ScheduledReminder r) => r.kind).toSet();

      expect(tipos, isNot(contains(ReminderKind.contaInativa)));
      expect(tipos, isNotEmpty);
    });

    test('não fala em apagar conta com palavra de susto', () {
      // O texto precisa informar sem assustar: quem lê está com um bebê no
      // colo, não numa reunião de segurança.
      final String corpo = planoEm(
        DateTime(2026, 8, 4),
        settings: soConta,
      ).single.body.toLowerCase();
      for (final String p in <String>['urgente', 'atenção', 'perigo', '!']) {
        expect(corpo, isNot(contains(p)));
      }
      expect(corpo, contains('abrir de vez em quando'));
    });
  });

  group('as ideias com prazo', () {
    ActiveInspiration ideia({
      required String id,
      bool destaque = true,
      bool comPrazo = true,
    }) => ActiveInspiration(
      inspiration: Inspiration(
        id: id,
        title: 'Ideias para a festa',
        summary: 'Um resumo curto.',
        kind: InspirationKind.preparo,
        anchor: const AgeAnchor(fromDays: 0, toDays: 9999),
        highlight: destaque,
      ),
      relevance: 1,
      deadline: comPrazo ? DateTime(2027, 3, 10) : null,
      daysLeft: comPrazo ? 18 : null,
    );

    const ReminderSettings soIdeias = ReminderSettings(
      enabled: true,
      kinds: <ReminderKind>{ReminderKind.inspiracao},
    );

    test('avisa sobre um destaque com prazo ainda não lido', () {
      final List<ScheduledReminder> plano = planoEm(
        DateTime(2027, 2, 20),
        settings: soIdeias,
        inspiracoes: <ActiveInspiration>[ideia(id: 'festa')],
      );
      expect(plano.single.title, 'Ideias para a festa');
      expect(plano.single.day, DateTime(2027, 2, 21));
    });

    test('não avisa sobre o que já foi lido', () {
      expect(
        planoEm(
          DateTime(2027, 2, 20),
          settings: soIdeias,
          inspiracoes: <ActiveInspiration>[ideia(id: 'festa')],
          lidas: <String>{'festa'},
        ),
        isEmpty,
      );
    });

    test('não avisa sobre leitura sem prazo nem sem destaque', () {
      expect(
        planoEm(
          DateTime(2027, 2, 20),
          settings: soIdeias,
          inspiracoes: <ActiveInspiration>[
            ideia(id: 'a', comPrazo: false),
            ideia(id: 'b', destaque: false),
          ],
        ),
        isEmpty,
      );
    });
  });

  group('reagendar não duplica', () {
    test('o mesmo dia e o mesmo tipo dão o mesmo id', () {
      final List<ScheduledReminder> um = planoEm(DateTime(2027, 2, 20));
      final List<ScheduledReminder> dois = planoEm(DateTime(2027, 2, 20));
      expect(
        um.map((ScheduledReminder r) => r.id),
        dois.map((ScheduledReminder r) => r.id),
      );
    });

    test('ids não colidem entre tipos no mesmo dia', () {
      final Set<int> ids = <int>{
        for (final ReminderKind k in ReminderKind.values)
          ...planoEm(
            DateTime(2027, 2, 20),
            settings: ReminderSettings(enabled: true, kinds: <ReminderKind>{k}),
            entradas: <Entry>[foto(DateTime(2027, 2, 1))],
          ).map((ScheduledReminder r) => r.id),
      };
      final int total = <int>[
        for (final ReminderKind k in ReminderKind.values)
          ...planoEm(
            DateTime(2027, 2, 20),
            settings: ReminderSettings(enabled: true, kinds: <ReminderKind>{k}),
            entradas: <Entry>[foto(DateTime(2027, 2, 1))],
          ).map((ScheduledReminder r) => r.id),
      ].length;
      expect(ids.length, total);
    });
  });

  group('o ajuste sobrevive ao aparelho', () {
    test('vai e volta inteiro', () {
      const ReminderSettings original = ReminderSettings(
        enabled: true,
        kinds: <ReminderKind>{ReminderKind.aniversario, ReminderKind.ausencia},
        hour: 19,
        absenceDays: 21,
      );
      final ReminderSettings devolta = ReminderSettings.fromMap(
        original.toMap(),
      );
      expect(devolta.enabled, isTrue);
      expect(devolta.kinds, original.kinds);
      expect(devolta.hour, 19);
      expect(devolta.absenceDays, 21);
    });

    test('sem nada guardado, vale o padrão ligado', () {
      expect(ReminderSettings.fromMap(null).enabled, isTrue);
    });

    test('um "não" guardado continua valendo na próxima abertura', () {
      // Se a pessoa desligou, o padrão não pode religar sozinho na abertura
      // seguinte. Seria o pior comportamento possível deste arquivo.
      final ReminderSettings guardado = ReminderSettings.fromMap(
        const ReminderSettings(enabled: false).toMap(),
      );
      expect(guardado.enabled, isFalse);
    });
  });

  group('nenhum texto entrega o que é íntimo', () {
    test('nada cita carta, desenho ou o que está lacrado', () {
      // Uma notificação aparece na tela bloqueada, e quem está do lado vê.
      const List<String> proibidos = <String>[
        'carta',
        'lacrad',
        'guardado para',
      ];
      for (final DateTime hoje in <DateTime>[
        DateTime(2026, 8, 20),
        DateTime(2026, 12, 15),
        DateTime(2027, 2, 20),
      ]) {
        for (final ScheduledReminder r in planoEm(
          hoje,
          entradas: <Entry>[foto(hoje.subtract(const Duration(days: 20)))],
        )) {
          final String texto = '${r.title} ${r.body}'.toLowerCase();
          for (final String p in proibidos) {
            expect(texto, isNot(contains(p)), reason: r.title);
          }
        }
      }
    });
  });
}
