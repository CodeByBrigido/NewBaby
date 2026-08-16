@Tags(<String>['previa'])
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/utils/periodo.dart';
import 'package:meu_bebe/features/timeline/timeline_screen.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/services/thumbnail_service.dart';
import 'package:meu_bebe/state/providers.dart';

import 'fonte_de_verdade.dart';

/// Gera uma imagem da linha do tempo para olhar antes de instalar.
///
/// **O que é real aqui:** a `TimelineList` de verdade, a mesma que a tela
/// monta. O agrupamento por período, o mosaico com as dimensões variadas, o
/// cabeçalho com a contagem à direita, o selo de data redonda, os cartões de
/// carta e crescimento, o trilho, as cores do Design System e a fonte do
/// produto.
///
/// **O que é encenação:** o conteúdo das fotos, que são retângulos pintados
/// aqui mesmo, na proporção que a foto teria. Miniatura de verdade vem do
/// Drive, e teste não tem rede. O enquadramento na tela é fiel mesmo sem a
/// imagem, porque é a proporção que decide o tamanho de cada ladrilho.
///
/// Marcada com a etiqueta `previa`, que o `dart_test.yaml` pula: comparar
/// pixels no CI falharia por diferença de máquina. Roda à mão com
/// `flutter test --run-skipped --update-goldens test/previa_da_linha_do_tempo_test.dart`
void main() {
  late Directory pasta;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    await carregarFonteDeVerdade();
    pasta = await Directory.systemTemp.createTemp('previa-linha');
  });

  tearDownAll(() => pasta.deleteSync(recursive: true));

  for (final Periodo periodo in Periodo.values) {
    testWidgets('previa da linha do tempo, ${periodo.name}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      // `runAsync` porque pintar as fotos é trabalho assíncrono de verdade,
      // e dentro do relógio falso do teste um `Picture.toImage` nunca
      // completa: o teste fica parado esperando um futuro que ninguém vai
      // avançar.
      final List<Entry> entradas = (await tester.runAsync(
        () => _acervo(pasta),
      ))!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            thumbnailServiceProvider.overrideWithValue(_SemMiniaturas()),
          ],
          child: MaterialApp(
            theme: AppTheme.build(AppPalette.of(_perfil.gender)),
            locale: const Locale('pt', 'BR'),
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Linha do tempo'),
                actions: const <Widget>[
                  Icon(Icons.calendar_view_month_outlined),
                  SizedBox(width: 16),
                  Icon(Icons.filter_list),
                  SizedBox(width: 12),
                ],
              ),
              body: TimelineList(
                entries: entradas,
                profile: _perfil,
                periodo: periodo,
                // O cabeçalho do bebê e a faixa de envio dependem de
                // providers com rede.
                showHeader: false,
              ),
            ),
          ),
        ),
      );
      // Decodificar um PNG também é trabalho de verdade, e pelo mesmo motivo
      // precisa de `runAsync`: sem isto os ladrilhos ficam com o tamanho
      // certo e a imagem em branco, e a prévia mostraria um mosaico vazio.
      await tester.runAsync(() async {
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TimelineList),
        matchesGoldenFile('previa/linha-do-tempo-${periodo.name}.png'),
      );
    });
  }
}

final BabyProfile _perfil = BabyProfile(
  name: 'Maria Eduarda',
  birth: DateTime(2027, 1, 22, 14, 35),
  birthWeightGrams: 3250,
  birthHeightCm: 49,
);

/// Um acervo plausível: meses de tamanhos diferentes, fotos de paisagem, de
/// retrato e quadradas como saem de um telefone, e no meio delas uma carta e
/// uma medição, para ver os cartões convivendo com o mosaico.
///
/// Setembro de 2027 traz os oito meses da Maria, para o selo de data redonda
/// aparecer no cabeçalho.
Future<List<Entry>> _acervo(Directory pasta) async {
  const List<(int, int)> dimensoes = <(int, int)>[
    (1600, 1200),
    (1200, 1600),
    (1400, 1400),
    (1920, 1080),
    (1200, 1600),
    (1600, 1200),
    (1400, 1400),
    (1080, 1920),
    (1500, 1000),
  ];

  final List<Entry> entradas = <Entry>[];
  int n = 0;

  Future<Entry> foto(DateTime quando, int quantas) async {
    final List<EntryFile> arquivos = <EntryFile>[];
    for (int i = 0; i < quantas; i++) {
      final (int largura, int altura) = dimensoes[n % dimensoes.length];
      arquivos.add(
        EntryFile(
          driveId: 'foto-$n',
          name: 'foto-$n.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 2048,
          width: largura,
          height: altura,
          localPath: await _pintar(pasta, n, largura, altura),
        ),
      );
      n++;
    }
    return _entrada(EntryType.photo, quando, arquivos: arquivos);
  }

  // Setembro: o mês cheio, com o marco de oito meses.
  entradas.add(await foto(DateTime(2027, 9, 22, 10), 5));
  entradas.add(
    _entrada(
      EntryType.letter,
      DateTime(2027, 9, 18, 21),
      titulo: 'Para quando você tiver 18 anos',
      descricao:
          'Hoje você descobriu que consegue bater palmas, e passou a tarde '
          'inteira batendo. Eu queria que você lembrasse disso.',
    ),
  );
  entradas.add(await foto(DateTime(2027, 9, 9, 16), 4));

  // Agosto: mês médio, com a medição.
  entradas.add(await foto(DateTime(2027, 8, 27, 11), 6));
  entradas.add(
    _entrada(
      EntryType.growth,
      DateTime(2027, 8, 14, 9),
      crescimento: const GrowthData(weightGrams: 7850, heightCm: 68),
    ),
  );
  entradas.add(await foto(DateTime(2027, 8, 3, 15), 3));

  // Julho: mês curto, para ver a última linha do mosaico sobrando.
  entradas.add(await foto(DateTime(2027, 7, 19, 8), 2));

  return entradas;
}

Entry _entrada(
  EntryType tipo,
  DateTime quando, {
  String? titulo,
  String? descricao,
  GrowthData? crescimento,
  List<EntryFile> arquivos = const <EntryFile>[],
}) {
  final int dias = quando.difference(DateTime(2027, 1, 22)).inDays;
  return Entry(
    id: '${tipo.id}-${quando.millisecondsSinceEpoch}',
    type: tipo,
    date: quando,
    createdAt: quando,
    ageDays: dias,
    bucketKey: 'M${(dias / 30).floor()}',
    bucketName: 'Mês ${(dias / 30).floor()}',
    title: titulo,
    description: descricao,
    growth: crescimento,
    files: arquivos,
  );
}

/// Pinta um retângulo do tamanho da foto e o grava em disco.
///
/// `DriveThumbnail` desenha o arquivo local quando ele existe, então o
/// caminho da miniatura é o mesmo do aparelho: nada de widget substituto só
/// para a prévia, que é como uma imagem de teste deixa de valer.
Future<String> _pintar(Directory pasta, int n, int largura, int altura) async {
  // Tons da paleta, só para as peças se distinguirem umas das outras.
  final AppPalette cores = AppPalette.of(_perfil.gender);
  final List<Color> tons = <Color>[
    cores.primarySoft,
    cores.accentSoft,
    cores.surfaceMuted,
    cores.primary,
  ];

  final ui.PictureRecorder gravador = ui.PictureRecorder();
  final Canvas tela = Canvas(gravador);
  tela.drawRect(
    Rect.fromLTWH(0, 0, largura.toDouble(), altura.toDouble()),
    Paint()..color = tons[n % tons.length],
  );

  final ui.Picture desenho = gravador.endRecording();
  final ui.Image imagem = await desenho.toImage(largura, altura);
  final ByteData? bytes = await imagem.toByteData(
    format: ui.ImageByteFormat.png,
  );
  imagem.dispose();
  desenho.dispose();

  final File arquivo = File('${pasta.path}/foto-$n.png');
  arquivo.writeAsBytesSync(bytes!.buffer.asUint8List());
  return arquivo.path;
}

/// Em teste não há Drive nem cache em disco: a miniatura sai do `localPath`.
class _SemMiniaturas implements ThumbnailStore {
  @override
  Future<File?> cached(String driveId) async => null;

  @override
  Future<File?> resolve(String driveId) async => null;

  @override
  Future<void> store(String driveId, File thumbnail) async {}

  @override
  Future<void> clear() async {}
}
