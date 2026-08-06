import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/timeline/timeline_screen.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/features/timeline/timeline_card.dart';
import 'package:meu_bebe/models/day_summary.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/thumbnail_service.dart';
import 'package:meu_bebe/state/providers.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';

/// Substitui o cache de miniaturas: em teste não há Drive nem disco.
/// Devolver `null` também exercita o caminho real de um arquivo cuja
/// miniatura ainda não chegou - que é o que o aparelho vê ao abrir o app
/// depois de reinstalar.
class _NoThumbnails implements ThumbnailStore {
  @override
  Future<File?> cached(String driveId) async => null;

  @override
  Future<File?> resolve(String driveId) async => null;

  @override
  Future<void> store(String driveId, File thumbnail) async {}

  @override
  Future<void> clear() async {}
}

final BabyProfile profile = BabyProfile(
  name: 'Maria Eduarda Brigido',
  birth: DateTime(2027, 1, 22, 14, 35),
  birthWeightGrams: 3250,
  birthHeightCm: 49,
  hospital: 'Hospital Santa Joana',
);

Entry entry({
  required EntryType type,
  required DateTime date,
  String? title,
  String? description,
  GrowthData? growth,
  int fileCount = 0,
}) {
  return Entry(
    id: '${type.id}-${date.millisecondsSinceEpoch}',
    type: type,
    date: date,
    createdAt: date,
    ageDays: date.difference(DateTime(2027, 1, 22)).inDays,
    bucketKey: 'S01',
    bucketName: 'Semana 01',
    title: title,
    description: description,
    growth: growth,
    files: <EntryFile>[
      for (int i = 0; i < fileCount; i++)
        EntryFile(
          driveId: 'drive-$i',
          name: 'arquivo-$i.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1024,
        ),
    ],
  );
}

/// Monta só a lista da linha do tempo, sem Firebase nem Google Drive.
Widget harness(List<Entry> entries) {
  return ProviderScope(
    overrides: [thumbnailServiceProvider.overrideWithValue(_NoThumbnails())],
    child: MaterialApp(
      theme: AppTheme.build(AppPalette.of(profile.gender)),
      locale: const Locale('pt', 'BR'),
      home: Scaffold(
        body: TimelineList(
          entries: entries,
          profile: profile,
          // O cabeçalho e a faixa de envio dependem de providers com rede.
          showHeader: false,
        ),
      ),
    ),
  );
}

void main() {
  agrupamentoPorDia();
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('mostra a idade calculada ao lado de cada dia', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(<Entry>[
        entry(
          type: EntryType.letter,
          date: DateTime(2027, 4, 2),
          title: 'Para minha filha',
          description: 'Minha pequena,',
        ),
      ]),
    );
    await tester.pump();

    // 22/01 + 2 meses = 22/03; até 02/04 são mais 11 dias.
    expect(find.text('2 meses e 11 dias'), findsOneWidget);
    expect(find.text('02/04/2027'), findsOneWidget);
  });

  testWidgets('cartas aparecem com o prefixo "Carta:"', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(<Entry>[
        entry(
          type: EntryType.letter,
          date: DateTime(2027, 4, 2),
          title: 'Para minha filha',
          description: 'Minha pequena,',
        ),
      ]),
    );
    await tester.pump();

    expect(find.text('Carta: Para minha filha'), findsOneWidget);
    expect(find.text('Minha pequena,'), findsOneWidget);
  });

  testWidgets('registro de crescimento mostra peso e altura', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(<Entry>[
        entry(
          type: EntryType.growth,
          date: DateTime(2027, 3, 22),
          growth: const GrowthData(weightGrams: 4200, heightCm: 55),
        ),
      ]),
    );
    await tester.pump();

    expect(find.text('Registro de crescimento'), findsOneWidget);
    expect(find.text('4,200 kg'), findsOneWidget);
    expect(find.text('55 cm'), findsOneWidget);
  });

  testWidgets('um lote de fotos vira "Fotos adicionadas" com contador', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(<Entry>[
        entry(
          type: EntryType.photo,
          date: DateTime(2027, 4, 22),
          fileCount: 14,
        ),
      ]),
    );
    await tester.pump();

    expect(find.text('Fotos adicionadas'), findsOneWidget);
    // Três miniaturas visíveis e o resto somado na última.
    expect(find.text('+12'), findsOneWidget);
  });

  testWidgets('itens do mesmo dia ficam sob um único cabeçalho', (
    WidgetTester tester,
  ) async {
    final DateTime day = DateTime(2027, 4, 22);
    await tester.pumpWidget(
      harness(<Entry>[
        entry(type: EntryType.photo, date: day, fileCount: 1),
        entry(
          type: EntryType.growth,
          date: day,
          growth: const GrowthData(weightGrams: 5800, heightCm: 61),
        ),
      ]),
    );
    await tester.pump();

    expect(find.text('22/04/2027'), findsOneWidget);
    expect(find.text('3 meses'), findsOneWidget);
    expect(find.text('Foto adicionada'), findsOneWidget);
    expect(find.text('Registro de crescimento'), findsOneWidget);
  });

  testWidgets('dias diferentes recebem cabeçalhos separados', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(<Entry>[
        entry(type: EntryType.photo, date: DateTime(2027, 4, 22), fileCount: 1),
        entry(type: EntryType.photo, date: DateTime(2027, 4, 18), fileCount: 1),
      ]),
    );
    await tester.pump();

    expect(find.text('22/04/2027'), findsOneWidget);
    expect(find.text('18/04/2027'), findsOneWidget);
    expect(find.text('3 meses'), findsOneWidget);
    expect(find.text('2 meses e 27 dias'), findsOneWidget);
  });
}

/// Um dia cheio recolhe; um dia curto, não.
///
/// A regra existe porque um aniversário com trinta fotos, todo aberto,
/// empurra o resto do mês para fora da tela. Mas esconder duas fotos atrás
/// de um toque seria trocar a memória por um menu.
void agrupamentoPorDia() {
  group('o resumo de um dia', () {
    test('conta cada tipo e junta como se escreve em português', () {
      final DateTime dia = DateTime(2027, 4, 10);
      expect(
        summarizeDay(<Entry>[
          entry(type: EntryType.photo, date: dia),
          entry(type: EntryType.photo, date: dia.add(const Duration(hours: 1))),
          entry(type: EntryType.video, date: dia.add(const Duration(hours: 2))),
          entry(
            type: EntryType.letter,
            date: dia.add(const Duration(hours: 3)),
          ),
        ]),
        '2 fotos, 1 vídeo e 1 carta',
      );
    });

    test('um tipo só dispensa a conjunção', () {
      expect(
        summarizeDay(<Entry>[
          entry(type: EntryType.photo, date: DateTime(2027, 4, 10)),
        ]),
        '1 foto',
      );
    });

    test('a ordem é sempre a mesma, não a da contagem', () {
      // Dois dias parecidos precisam se parecer na tela.
      final DateTime dia = DateTime(2027, 4, 10);
      expect(
        summarizeDay(<Entry>[
          entry(type: EntryType.letter, date: dia),
          entry(type: EntryType.photo, date: dia.add(const Duration(hours: 1))),
          entry(type: EntryType.photo, date: dia.add(const Duration(hours: 2))),
          entry(type: EntryType.photo, date: dia.add(const Duration(hours: 3))),
        ]),
        '3 fotos e 1 carta',
      );
    });
  });

  group('a linha do tempo agrupa o que é grande', () {
    List<Entry> noMesmoDia(int quantidade) {
      final DateTime dia = DateTime(2027, 4, 10, 9);
      return <Entry>[
        for (int i = 0; i < quantidade; i++)
          entry(
            type: EntryType.photo,
            date: dia.add(Duration(minutes: i)),
          ),
      ];
    }

    testWidgets('poucos itens aparecem direto, sem resumo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness(noMesmoDia(3)));
      await tester.pump();

      expect(
        find.textContaining('3 fotos'),
        findsNothing,
        reason: 'Esconder três fotos atrás de um toque não ajuda ninguém.',
      );
      expect(find.byType(TimelineCard), findsNWidgets(3));
    });

    testWidgets('muitos itens começam recolhidos, mostrando o resumo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness(noMesmoDia(12)));
      await tester.pump();

      expect(find.text('12 fotos'), findsOneWidget);
      expect(
        find.byType(TimelineCard),
        findsNothing,
        reason: 'Recolhido é recolhido.',
      );
    });

    testWidgets('tocar no resumo abre e fecha', (WidgetTester tester) async {
      await tester.pumpWidget(harness(noMesmoDia(12)));
      await tester.pump();

      await tester.tap(find.text('12 fotos'));
      await tester.pumpAndSettle();
      expect(find.byType(TimelineCard), findsWidgets);

      await tester.tap(find.text('12 fotos'));
      await tester.pumpAndSettle();
      expect(find.byType(TimelineCard), findsNothing);
    });
  });
}
