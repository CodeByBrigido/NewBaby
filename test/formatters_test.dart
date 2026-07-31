import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_bebe/core/utils/formatters.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('datas', () {
    test('formato brasileiro de dia/mês/ano', () {
      expect(Fmt.date(DateTime(2027, 1, 22)), '22/01/2027');
      expect(Fmt.dayMonth(DateTime(2027, 1, 22)), '22/01');
    });

    test('data por extenso em português', () {
      expect(Fmt.longDate(DateTime(2027, 1, 22)), '22 de janeiro de 2027');
    });

    test('mês e ano com inicial maiúscula', () {
      expect(Fmt.monthYear(DateTime(2027, 3, 1)), 'Março de 2027');
    });

    test('intervalo do balde de idade', () {
      expect(
        Fmt.dateRange(DateTime(2027, 1, 22), DateTime(2027, 1, 28)),
        '22/01 a 28/01',
      );
    });

    test('nome de arquivo ordenável', () {
      expect(
        Fmt.fileStamp(DateTime(2027, 1, 22, 14, 35, 0)),
        '2027-01-22_143500',
      );
    });

    test('cabeçalho da linha do tempo usa Hoje e Ontem', () {
      final DateTime now = DateTime(2027, 4, 22, 10);
      expect(Fmt.timelineDay(DateTime(2027, 4, 22), now: now), 'Hoje');
      expect(Fmt.timelineDay(DateTime(2027, 4, 21), now: now), 'Ontem');
      expect(Fmt.timelineDay(DateTime(2027, 4, 20), now: now), '20/04/2027');
    });

    test('hora com dois dígitos', () {
      expect(Fmt.time(DateTime(2027, 1, 22, 14, 35)), '14:35');
      expect(Fmt.time(DateTime(2027, 1, 22, 9, 5)), '09:05');
    });
  });

  group('medidas', () {
    test('peso em quilos com três casas, como na caderneta', () {
      expect(Fmt.weight(3250), '3,250 kg');
      expect(Fmt.weight(4200), '4,200 kg');
      expect(Fmt.weight(12500), '12,500 kg');
    });

    test('altura sem casas decimais quando é número redondo', () {
      expect(Fmt.height(49), '49 cm');
      expect(Fmt.height(52.5), '52,5 cm');
    });
  });

  group('tamanhos de arquivo', () {
    test('escala de bytes até gigabytes', () {
      expect(Fmt.bytes(512), '512 B');
      expect(Fmt.bytes(1024), '1 KB');
      expect(Fmt.bytes(1258291), '1,2 MB');
      expect(Fmt.bytes(13314398617), '12,4 GB');
    });
  });

  group('duração e contagem', () {
    test('duração de vídeo', () {
      expect(Fmt.duration(const Duration(seconds: 24)), '0:24');
      expect(Fmt.duration(const Duration(minutes: 2, seconds: 5)), '2:05');
      expect(
        Fmt.duration(const Duration(hours: 1, minutes: 2, seconds: 5)),
        '1:02:05',
      );
    });

    test('plural correto na contagem', () {
      expect(Fmt.count(1, 'foto', 'fotos'), '1 foto');
      expect(Fmt.count(15, 'foto', 'fotos'), '15 fotos');
      expect(Fmt.count(0, 'vídeo', 'vídeos'), '0 vídeos');
    });
  });
}
