import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/utils/age_calculator.dart';
import 'package:meu_bebe/core/utils/data_do_arquivo.dart';
import 'package:meu_bebe/features/shell/add_sheet.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';
import 'package:meu_bebe/models/entry.dart';

/// Escolher quando a memória aconteceu, e não quando ela foi guardada.
///
/// Quem instala o aplicativo já tem anos de fotos no celular. Sem escolher a
/// data, tudo isso entra como se tivesse acontecido hoje: a idade fica
/// errada na linha do tempo e o arquivo vai parar na pasta errada do Drive.
void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('a hora do relógio acompanha o dia escolhido', () {
    test('o dia vem do seletor e a hora vem de agora', () {
      final DateTime escolhido = DateTime(2027, 4, 10);
      final DateTime agora = DateTime(2028, 9, 2, 14, 35, 7);

      expect(
        comHoraDoRelogio(escolhido, agora),
        DateTime(2027, 4, 10, 14, 35, 7),
      );
    });

    test('dois envios seguidos não geram o mesmo instante', () {
      // O nome do arquivo no Drive começa pela data e hora. Meia-noite fixa
      // faria um lote inteiro colidir e a ordem na pasta virar sorteio.
      final DateTime dia = DateTime(2027, 4, 10);
      final DateTime primeiro = comHoraDoRelogio(
        dia,
        DateTime(2028, 9, 2, 14, 35, 7),
      );
      final DateTime segundo = comHoraDoRelogio(
        dia,
        DateTime(2028, 9, 2, 14, 35, 9),
      );

      expect(primeiro, isNot(segundo));
      expect(segundo.isAfter(primeiro), isTrue);
    });

    test('a data escolhida cai no balde de idade daquele dia', () {
      // É o efeito que justifica a funcionalidade inteira: a pasta do Drive
      // sai da idade na data, não da data do envio.
      final DateTime nascimento = DateTime(2027, 1, 22);
      final DateTime quando = comHoraDoRelogio(
        DateTime(2027, 4, 10),
        DateTime(2028, 9, 2, 14, 35),
      );

      expect(
        AgeCalculator.bucketAt(nascimento, quando).folderName,
        'Semana 12',
      );
      // Sem escolher nada, a mesma foto iria para a pasta de hoje.
      expect(
        AgeCalculator.bucketAt(nascimento, DateTime(2028, 9, 2)).folderName,
        isNot('Semana 12'),
      );
    });
  });

  group('o resumo que a pessoa confirma antes de enviar', () {
    final BabyProfile maria = BabyProfile(
      name: 'Maria Eduarda',
      birth: DateTime(2027, 1, 22),
      gender: BabyGender.girl,
    );
    final Copy g = Copy.of(maria);

    List<String> resumo({
      required EntryType type,
      required int quantidade,
      required DateTime quando,
      Copy? copy,
      BabyProfile? profile,
    }) => resumoDoEnvio(
      g: copy ?? g,
      profile: profile ?? maria,
      type: type,
      quantidade: quantidade,
      quando: quando,
    );

    test('diz o quanto, a data, a idade e onde vai ficar', () {
      expect(
        resumo(
          type: EntryType.photo,
          quantidade: 5,
          quando: DateTime(2027, 4, 10, 14, 35),
        ),
        <String>[
          '5 fotos com a data de 10 de abril de 2027.',
          'Nessa data a Maria tinha 2 meses e 19 dias.',
          'No Drive, vai ficar em Fotos / Ano 0 / Mês 02.',
        ],
      );
    });

    test('um item só não vira "1 fotos"', () {
      expect(quantosItens(EntryType.photo, 1), '1 foto');
      expect(quantosItens(EntryType.video, 3), '3 vídeos');
      expect(quantosItens(EntryType.document, 2), '2 documentos');
    });

    test('o caminho acompanha a idade, ano e mês', () {
      expect(
        resumo(
          type: EntryType.video,
          quantidade: 1,
          quando: DateTime(2028, 4, 10),
        ).last,
        'No Drive, vai ficar em Vídeos / Ano 1 / Mês 02.',
      );
      // A frase diz o caminho do Drive, e não a semana que a galeria usa
      // aqui dentro: é sobre onde o arquivo vai parar lá fora. O mês
      // reinicia a cada ano, então `Ano 1 / Mês 02` se lê "1 ano e 2 meses".
      expect(
        resumo(
          type: EntryType.photo,
          quantidade: 1,
          quando: DateTime(2030, 4, 10),
        ).last,
        'No Drive, vai ficar em Fotos / Ano 3 / Mês 02.',
      );
    });

    test('documento não promete semana nenhuma', () {
      // Documento não é agrupado por idade; citar uma semana seria mentira.
      final List<String> linhas = resumo(
        type: EntryType.document,
        quantidade: 2,
        quando: DateTime(2027, 4, 10),
      );
      expect(linhas, hasLength(2));
      expect(linhas.join(' '), isNot(contains('Semana')));
    });

    test('no dia do nascimento a frase é outra, não um remendo', () {
      // `detailedLabel` devolve "No nascimento", que não encaixa em "tinha".
      final List<String> linhas = resumo(
        type: EntryType.photo,
        quantidade: 1,
        quando: DateTime(2027, 1, 22, 15),
      );
      expect(linhas[1], 'Foi o dia em que a Maria nasceu.');
      expect(linhas.join(' '), isNot(contains('tinha No nascimento')));
    });

    test('sem cadastro com nome, a frase não fica capenga', () {
      final List<String> linhas = resumo(
        type: EntryType.photo,
        quantidade: 1,
        quando: DateTime(2027, 4, 10),
        copy: Copy.generic,
      );
      expect(linhas[1], 'Idade nessa data: 2 meses e 19 dias.');
    });
  });

  group('a confirmação é a última chance de corrigir', () {
    final BabyProfile maria = BabyProfile(
      name: 'Maria Eduarda',
      birth: DateTime(2027, 1, 22),
      gender: BabyGender.girl,
    );

    /// Abre a confirmação e devolve uma caixa que o teste observa depois de
    /// a resposta chegar. `terminou` existe para que "não devolveu data"
    /// signifique de fato isso, e não "ainda não respondeu".
    Future<Map<String, Object?>> abrir(
      WidgetTester tester, {
      int quantidade = 5,
    }) async {
      final Map<String, Object?> saida = <String, Object?>{
        'terminou': false,
        'data': null,
      };
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(AppPalette.of(BabyGender.girl)),
          locale: const Locale('pt', 'BR'),
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    saida['data'] = await confirmarEnvio(
                      context,
                      g: Copy.of(maria),
                      profile: maria,
                      type: EntryType.photo,
                      quantidade: quantidade,
                      lote: DataDoLote(
                        quando: DateTime(2027, 4, 10, 14, 35),
                        lida: true,
                        diasDiferentes: 1,
                      ),
                    );
                    saida['terminou'] = true;
                  },
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return saida;
    }

    testWidgets('mostra o resumo antes de qualquer envio', (
      WidgetTester tester,
    ) async {
      await abrir(tester);

      expect(find.text('Confere a data?'), findsOneWidget);
      expect(
        find.text('5 fotos com a data de 10 de abril de 2027.'),
        findsOneWidget,
      );
      expect(
        find.text('Nessa data a Maria tinha 2 meses e 19 dias.'),
        findsOneWidget,
      );
      expect(
        find.text('No Drive, vai ficar em Fotos / Ano 0 / Mês 02.'),
        findsOneWidget,
      );
    });

    testWidgets('cancelar não devolve data nenhuma', (
      WidgetTester tester,
    ) async {
      // O envio só acontece com uma data de volta. Se cancelar devolvesse a
      // data original, desistir enviaria assim mesmo.
      final Map<String, Object?> saida = await abrir(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(saida['terminou'], isTrue);
      expect(saida['data'], isNull);
    });

    testWidgets('guardar devolve a data confirmada', (
      WidgetTester tester,
    ) async {
      final Map<String, Object?> saida = await abrir(tester, quantidade: 1);
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(saida['terminou'], isTrue);
      expect(saida['data'], DateTime(2027, 4, 10, 14, 35));
    });

    testWidgets('os dois botões dividem uma linha só', (
      WidgetTester tester,
    ) async {
      // Empilhados, o botão cheio esticava na largura inteira e virava a
      // coisa mais pesada da tela. O teste mede a geometria porque é
      // justamente isso que muda sozinho quando o texto de um botão cresce.
      await abrir(tester);

      final Rect cancelar = tester.getRect(find.byType(TextButton));
      final Rect guardar = tester.getRect(find.byType(FilledButton));

      expect(
        cancelar.center.dy,
        moreOrLessEquals(guardar.center.dy, epsilon: 1),
        reason: 'os dois precisam estar na mesma linha',
      );
      expect(cancelar.right, lessThanOrEqualTo(guardar.left));
    });

    testWidgets('guardar ocupa o dobro de cancelar', (
      WidgetTester tester,
    ) async {
      await abrir(tester);

      final double cancelar = tester.getSize(find.byType(TextButton)).width;
      final double guardar = tester.getSize(find.byType(FilledButton)).width;

      expect(guardar / cancelar, moreOrLessEquals(2, epsilon: 0.05));
    });
  });

  group('de onde a data veio', () {
    // A data agora é adivinhada a partir do arquivo. Adivinhar é aceitável;
    // adivinhar sem dizer que adivinhou, não.
    final DataDoLote lida = DataDoLote(
      quando: DateTime(2027, 4, 10),
      lida: true,
      diasDiferentes: 1,
    );

    test('quando saiu do arquivo, a tela diz isso', () {
      expect(
        origemDaData(lida, EntryType.photo),
        contains('do próprio arquivo'),
      );
    });

    test('quando não saiu, a tela diz que hoje é palpite', () {
      final DataDoLote palpite = DataDoLote(
        quando: DateTime(2027, 4, 10),
        lida: false,
        diasDiferentes: 0,
      );
      expect(
        origemDaData(palpite, EntryType.photo),
        contains('vale a de hoje'),
      );
      expect(origemDaData(palpite, EntryType.photo), contains('da mídia'));
      expect(origemDaData(palpite, EntryType.document), contains('do arquivo'));
    });

    test('lote de vários dias avisa, porque uma data só não descreve', () {
      final DataDoLote misturado = DataDoLote(
        quando: DateTime(2027, 4, 10),
        lida: true,
        diasDiferentes: 3,
      );
      final String texto = origemDaData(misturado, EntryType.photo);
      expect(texto, contains('3 dias'));
      expect(texto, contains('um dia de cada vez'));
    });
  });

  group('o cartão da data', () {
    Widget harness(
      DateTime quando, {
      String explicacao = 'Data lida do próprio arquivo. Toque para trocar.',
      bool alerta = false,
      VoidCallback? onTap,
    }) => MaterialApp(
      theme: AppTheme.build(AppPalette.of(BabyGender.girl)),
      locale: const Locale('pt', 'BR'),
      home: Scaffold(
        body: DataDaMemoria(
          quando: quando,
          explicacao: explicacao,
          alerta: alerta,
          onTap: onTap ?? () {},
        ),
      ),
    );

    testWidgets('mostra a data por extenso, e não "hoje"', (
      WidgetTester tester,
    ) async {
      // A tela existe para conferir a data. "Aconteceu hoje" escondia
      // justamente o dado que se está conferindo.
      await tester.pumpWidget(harness(DateTime(2027, 4, 10, 14, 35)));

      expect(find.text('10 de abril de 2027'), findsOneWidget);
      expect(
        find.text('Data lida do próprio arquivo. Toque para trocar.'),
        findsOneWidget,
      );
    });

    testWidgets('sem alerta, o ícone é de calendário', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(harness(DateTime(2027, 4, 10)));

      expect(find.byIcon(Icons.event_outlined), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsNothing);
    });

    testWidgets('com alerta, troca o ícone e o fundo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(DateTime(2027, 4, 10), alerta: true, explicacao: 'Atenção'),
      );

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      expect(find.byIcon(Icons.event_outlined), findsNothing);
    });

    testWidgets('tocar leva para a troca de data', (WidgetTester tester) async {
      // É o único jeito de corrigir uma data adivinhada errado, então precisa
      // funcionar tocando em qualquer lugar do cartão.
      int toques = 0;
      await tester.pumpWidget(
        harness(DateTime(2027, 4, 10), onTap: () => toques++),
      );

      await tester.tap(find.byIcon(Icons.edit_calendar_outlined));
      expect(toques, 1);
    });
  });
}
