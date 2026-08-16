import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/timeline/timeline_screen.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/features/timeline/timeline_card.dart';
import 'package:meu_bebe/core/utils/periodo.dart';
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
Widget harness(List<Entry> entries, {Periodo periodo = Periodo.mes}) {
  return ProviderScope(
    overrides: [thumbnailServiceProvider.overrideWithValue(_NoThumbnails())],
    child: MaterialApp(
      theme: AppTheme.build(AppPalette.of(profile.gender)),
      locale: const Locale('pt', 'BR'),
      home: Scaffold(
        body: TimelineList(
          entries: entries,
          profile: profile,
          periodo: periodo,
          // O cabeçalho e a faixa de envio dependem de providers com rede.
          showHeader: false,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('o cabeçalho de um período', () {
    testWidgets('traz o rótulo à esquerda e a contagem à direita', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(<Entry>[
          entry(
            type: EntryType.photo,
            date: DateTime(2027, 4, 22),
            fileCount: 3,
          ),
          entry(
            type: EntryType.letter,
            date: DateTime(2027, 4, 2),
            title: 'Para minha filha',
            description: 'Minha pequena,',
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('Abril de 2027'), findsOneWidget);
      // Três arquivos de foto mais a carta: a contagem é do que se vê, e
      // uma postagem com três fotos são três memórias para quem olha.
      expect(find.text('4 itens'), findsOneWidget);
    });

    testWidgets('períodos diferentes recebem cabeçalhos separados', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(<Entry>[
          entry(
            type: EntryType.photo,
            date: DateTime(2027, 4, 22),
            fileCount: 1,
          ),
          entry(
            type: EntryType.photo,
            date: DateTime(2027, 3, 18),
            fileCount: 1,
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('Abril de 2027'), findsOneWidget);
      expect(find.text('Março de 2027'), findsOneWidget);
    });

    testWidgets('o mesmo acervo se reagrupa quando a lente muda', (
      WidgetTester tester,
    ) async {
      final List<Entry> acervo = <Entry>[
        entry(type: EntryType.photo, date: DateTime(2027, 4, 22), fileCount: 1),
        entry(type: EntryType.photo, date: DateTime(2027, 3, 18), fileCount: 1),
      ];

      await tester.pumpWidget(harness(acervo, periodo: Periodo.ano));
      await tester.pump();
      // Um ano só, com os dois dentro.
      expect(find.text('2027'), findsOneWidget);
      expect(find.text('2 itens'), findsOneWidget);

      await tester.pumpWidget(harness(acervo, periodo: Periodo.mes));
      await tester.pump();
      expect(find.text('Abril de 2027'), findsOneWidget);
      expect(find.text('Março de 2027'), findsOneWidget);
    });

    testWidgets('a data redonda ganha selo no período em que caiu', (
      WidgetTester tester,
    ) async {
      // 22/01 + 70 dias = 02/04, que são dez semanas exatas. Sem a marca, o
      // mês mais importante do acervo tem a mesma cara que um mês qualquer.
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

      expect(find.text('10 semanas'), findsOneWidget);
    });

    testWidgets('um período sem data redonda não inventa selo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(<Entry>[
          entry(
            type: EntryType.letter,
            date: DateTime(2027, 4, 3),
            title: 'Para minha filha',
            description: 'Minha pequena,',
          ),
        ]),
      );
      await tester.pump();

      expect(find.text('10 semanas'), findsNothing);
      expect(find.text('Abril de 2027'), findsOneWidget);
    });
  });

  group('o que não é imagem continua em cartão', () {
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

    testWidgets('foto não vira cartão: ela vai para o mosaico', (
      WidgetTester tester,
    ) async {
      // A separação que o desenho novo faz. Sem ela, uma carta viraria um
      // retângulo cinza no meio das fotos, e uma foto viraria um cartão com
      // título dentro de uma lista que já é visual.
      await tester.pumpWidget(
        harness(<Entry>[
          entry(
            type: EntryType.photo,
            date: DateTime(2027, 4, 22),
            fileCount: 4,
          ),
        ]),
      );
      await tester.pump();

      expect(find.byType(TimelineCard), findsNothing);
      expect(find.text('4 itens'), findsOneWidget);
    });

    testWidgets('imagem e cartão convivem no mesmo período', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(<Entry>[
          entry(
            type: EntryType.photo,
            date: DateTime(2027, 4, 22),
            fileCount: 2,
          ),
          entry(
            type: EntryType.growth,
            date: DateTime(2027, 4, 10),
            growth: const GrowthData(weightGrams: 5800, heightCm: 61),
          ),
        ]),
      );
      await tester.pump();

      expect(find.byType(TimelineCard), findsOneWidget);
      expect(find.text('Registro de crescimento'), findsOneWidget);
      expect(find.text('3 itens'), findsOneWidget);
    });
  });
}
