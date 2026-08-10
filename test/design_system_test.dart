import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/core/theme/tokens.dart';
import 'package:meu_bebe/models/baby_gender.dart';

/// O Design System, preso por teste.
///
/// Um sistema de design não é o documento: é o que o código faz. Sem estas
/// verificações, a primeira tela com pressa reintroduz um raio de 12, uma
/// sombra forte ou um cinza ilegível, e a partir daí o documento vira
/// ficção.
void main() {
  /// Luminância relativa, na definição da WCAG.
  double luminancia(Color c) {
    double canal(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * canal(c.r) + 0.7152 * canal(c.g) + 0.0722 * canal(c.b);
  }

  double contraste(Color a, Color b) {
    final double la = luminancia(a);
    final double lb = luminancia(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  const Map<String, AppPalette> temas = <String, AppPalette>{
    'Welcome': AppPalette.neutral,
    'Boy': AppPalette.boy,
    'Girl': AppPalette.girl,
  };

  group('as três paletas', () {
    test('cada tema tem a cor de marca do Design System', () {
      expect(AppPalette.neutral.primary, const Color(0xFFD2654E));
      expect(AppPalette.boy.primary, const Color(0xFF6F9FD8));
      expect(AppPalette.girl.primary, const Color(0xFFC87AA8));
    });

    test('o cadastro escolhe o tema, e sem sexo informado fica o Welcome', () {
      expect(AppPalette.of(BabyGender.girl), AppPalette.girl);
      expect(AppPalette.of(BabyGender.boy), AppPalette.boy);
      expect(AppPalette.of(null), AppPalette.neutral);
    });

    test('trocar de tema não mexe no que não é destaque', () {
      // A regra do Design System: a criança muda o destaque, não a
      // estrutura. Cartão branco, superfície e cor de categoria são os
      // mesmos nos três, senão o aplicativo parece outro a cada filho.
      for (final AppPalette t in temas.values) {
        expect(t.surface, Colors.white);
        expect(t.photo, AppPalette.girl.photo);
        expect(t.video, AppPalette.girl.video);
        expect(t.letter, AppPalette.girl.letter);
        expect(t.document, AppPalette.girl.document);
      }
    });

    test('o fundo varia pouco entre os temas', () {
      // "Variação muito sutil apenas". Todos os fundos são quase brancos:
      // um deles escuro faria a troca de tema parecer troca de aplicativo.
      for (final MapEntry<String, AppPalette> t in temas.entries) {
        expect(
          contraste(t.value.background, Colors.white),
          lessThan(1.1),
          reason: t.key,
        );
      }
    });
  });

  group('contraste', () {
    test('todo texto sobre o fundo passa em AA', () {
      for (final MapEntry<String, AppPalette> t in temas.entries) {
        expect(
          contraste(t.value.textPrimary, t.value.background),
          greaterThanOrEqualTo(4.5),
          reason: '${t.key}: texto principal',
        );
        expect(
          contraste(t.value.textSecondary, t.value.background),
          greaterThanOrEqualTo(4.5),
          reason: '${t.key}: texto secundário',
        );
      }
    });

    test('o terceiro nível de texto não é usado para ler', () {
      // `muted` fica entre 2,5 e 3: serve para placeholder e legenda de
      // apoio, e não passa em AA. Este teste existe para que ninguém o
      // promova a texto de leitura sem perceber.
      for (final MapEntry<String, AppPalette> t in temas.entries) {
        expect(
          contraste(t.value.muted, t.value.surface),
          lessThan(4.5),
          reason: '${t.key}: se muted passar a ser legível, use textSecondary',
        );
      }
    });

    test('a cor forte passa em AA nos três temas', () {
      // A regra: toda superfície preenchida que leva texto ou ícone branco
      // usa `primaryStrong`. 4,5:1 porque o texto de botão é 16 px em
      // negrito, e a WCAG só dispensa esse limite a partir de 18,66 px.
      for (final MapEntry<String, AppPalette> t in temas.entries) {
        expect(
          contraste(Colors.white, t.value.primaryStrong),
          greaterThanOrEqualTo(4.5),
          reason: '${t.key}: branco sobre a cor forte',
        );
      }
    });

    test('a cor forte é a mesma cor, só mais escura', () {
      // Se alguém trocar `primaryStrong` por um cinza qualquer o teste de
      // cima continua passando e a identidade visual vai embora. Matiz é o
      // que faz "a mesma cor de marca, legível" ser verdade.
      for (final MapEntry<String, AppPalette> t in temas.entries) {
        final HSLColor marca = HSLColor.fromColor(t.value.primary);
        final HSLColor forte = HSLColor.fromColor(t.value.primaryStrong);
        expect(
          (forte.hue - marca.hue).abs(),
          lessThan(6),
          reason: '${t.key}: a matiz mudou',
        );
        expect(
          forte.lightness,
          lessThan(marca.lightness),
          reason: '${t.key}: a cor forte precisa ser mais escura',
        );
      }
    });

    test('a cor de marca continua reprovando, e por isso não vai atrás de '
        'texto branco', () {
      // Medido: 3,68 (Welcome), 3,09 (Girl) e 2,75 (Boy). Ela fica assim de
      // propósito, porque é a identidade visual. Este teste existe para que
      // a diferença entre as duas cores nunca seja lida como redundância.
      for (final MapEntry<String, AppPalette> t in temas.entries) {
        expect(
          contraste(Colors.white, t.value.primary),
          lessThan(4.5),
          reason:
              '${t.key}: se a marca passar a ser legível em branco, '
              'primaryStrong perde a razão de existir',
        );
      }
    });
  });

  group('os tokens que não são cor', () {
    test('a grade de espaçamento é de 8, com duas exceções conscientes', () {
      const List<double> grade = <double>[
        Space.x8,
        Space.x16,
        Space.x24,
        Space.x32,
        Space.x40,
        Space.x48,
        Space.x64,
      ];
      for (final double e in grade) {
        expect(e % 8, 0, reason: '$e deveria estar na grade de 8');
      }
      expect(Space.x4, 4);
      expect(Space.x12, 12);
    });

    test('cada superfície tem o seu raio, e eles são diferentes', () {
      expect(Radii.button, 18);
      expect(Radii.card, 20);
      expect(Radii.field, 14);
      expect(Radii.sheet, 28);
      expect(Radii.media, 16);
      // Um raio grande o bastante para virar pílula em qualquer altura.
      expect(Radii.pill, greaterThan(Sizes.button));
    });

    test('a área mínima de toque respeita o mínimo do Android', () {
      expect(Sizes.touch, greaterThanOrEqualTo(48));
    });

    test('as sombras são sutis nos três níveis', () {
      // Alfa acima de 0,15 já é sombra que se vê, e este aplicativo faz
      // hierarquia com cor e espaço, não com sombra.
      for (final List<BoxShadow> nivel in <List<BoxShadow>>[
        Shadows.level1,
        Shadows.level2,
        Shadows.level3,
      ]) {
        for (final BoxShadow s in nivel) {
          expect(s.color.a, lessThanOrEqualTo(0.15));
        }
      }
    });

    test('o movimento cresce junto com o tamanho do que se move', () {
      // Um fade é menor que um deslize, que é menor que uma tela inteira,
      // que é menor que uma miniatura virando foto.
      expect(Motion.micro, lessThan(Motion.fade));
      expect(Motion.fade, lessThan(Motion.slide));
      expect(Motion.slide, lessThan(Motion.sheet));
      expect(Motion.sheet, lessThan(Motion.screen));
      expect(Motion.screen, lessThan(Motion.hero));
      // Nada passa de meio segundo: acima disso a animação vira espera.
      expect(Motion.hero.inMilliseconds, lessThanOrEqualTo(400));
    });
  });

  group('o tema montado usa os tokens, e não números soltos', () {
    final ThemeData tema = AppTheme.build(AppPalette.girl);

    double? alturaDe(ButtonStyle? estilo) =>
        estilo?.minimumSize?.resolve(<WidgetState>{})?.height;

    double? raioDe(ButtonStyle? estilo) {
      final OutlinedBorder? forma = estilo?.shape?.resolve(<WidgetState>{});
      final BorderRadius? raio = forma is RoundedRectangleBorder
          ? forma.borderRadius as BorderRadius?
          : null;
      return raio?.topLeft.x;
    }

    test('os dois botões têm a mesma altura e o mesmo raio', () {
      // Primário e secundário dividem a linha em várias telas. Alturas
      // diferentes ali é o tipo de coisa que ninguém sabe nomear e todo
      // mundo percebe.
      expect(alturaDe(tema.filledButtonTheme.style), Sizes.button);
      expect(alturaDe(tema.outlinedButtonTheme.style), Sizes.button);
      expect(raioDe(tema.filledButtonTheme.style), Radii.button);
      expect(raioDe(tema.outlinedButtonTheme.style), Radii.button);
    });

    test('o botão primário e o FAB usam a cor forte, não a de marca', () {
      // É aqui que a regra vira código. Sem este teste, a próxima tela
      // aponta o botão para `primary` de novo e ninguém percebe até alguém
      // reclamar que não consegue ler.
      final Color? fundoBotao = tema.filledButtonTheme.style?.backgroundColor
          ?.resolve(<WidgetState>{});
      expect(fundoBotao, AppPalette.girl.primaryStrong);
      expect(
        tema.floatingActionButtonTheme.backgroundColor,
        AppPalette.girl.primaryStrong,
      );
      expect(tema.colorScheme.primary, AppPalette.girl.primaryStrong);
    });

    test('nenhuma tela põe branco sobre a cor de marca', () {
      // Varre as telas atrás do par proibido. Cinco faziam isso antes de
      // `primaryStrong` existir, e todas eram invisíveis em revisão de
      // código: o fundo está numa linha e o branco, dez linhas abaixo.
      //
      // Só `lib/features`, e não `lib/core/theme`: no tema os dois valores
      // ficam perto sem terem relação (um `progressIndicator` seguido de um
      // `tooltip`), e lá o acerto já é conferido campo a campo no teste
      // acima, que é uma checagem melhor que varrer texto.
      final List<String> ofensores = <String>[];
      for (final FileSystemEntity f in Directory(
        'lib/features',
      ).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final List<String> linhas = f.readAsLinesSync();
        for (int i = 0; i < linhas.length; i++) {
          final bool fundoDeMarca = RegExp(
            r'(color|backgroundColor):\s*(context\.)?cores\.primary,',
          ).hasMatch(linhas[i]);
          if (!fundoDeMarca) continue;
          final String adiante = linhas
              .sublist(i, math.min(i + 12, linhas.length))
              .join(' ');
          if (adiante.contains('Colors.white')) {
            ofensores.add('${f.path}:${i + 1}');
          }
        }
      }
      expect(
        ofensores,
        isEmpty,
        reason:
            'Use cores.primaryStrong quando houver branco em cima: '
            '${ofensores.join(", ")}',
      );
    });

    test('botão de texto tem área de toque suficiente', () {
      final Size? minimo = tema.textButtonTheme.style?.minimumSize?.resolve(
        <WidgetState>{},
      );
      expect(minimo?.height, greaterThanOrEqualTo(Sizes.touch));
      expect(minimo?.width, greaterThanOrEqualTo(Sizes.touch));
    });

    test('campo, cartão e folha usam o raio de cada um', () {
      final OutlineInputBorder? campo =
          tema.inputDecorationTheme.enabledBorder as OutlineInputBorder?;
      expect(campo?.borderRadius.topLeft.x, Radii.field);

      final RoundedRectangleBorder? cartao =
          tema.cardTheme.shape as RoundedRectangleBorder?;
      expect((cartao?.borderRadius as BorderRadius?)?.topLeft.x, Radii.card);

      final RoundedRectangleBorder? folha =
          tema.bottomSheetTheme.shape as RoundedRectangleBorder?;
      expect((folha?.borderRadius as BorderRadius?)?.topLeft.x, Radii.sheet);
    });

    test('o FAB tem o tamanho do sistema', () {
      final BoxConstraints? tamanho =
          tema.floatingActionButtonTheme.sizeConstraints;
      expect(tamanho?.maxWidth, Sizes.fab);
      expect(tamanho?.maxHeight, Sizes.fab);
    });

    test('todo texto do tema traz a fonte do projeto', () {
      // `ThemeData(fontFamily:)` alcança o `textTheme`, e só ele. Um estilo
      // entregue direto ao tema de um componente não passa por lá e cai na
      // fonte do sistema, sem erro nenhum. Foi o que aconteceu com o rótulo
      // dos botões, e só apareceu quando as telas foram desenhadas de fato.
      final List<String> semFonte = <String>[];
      void confere(String onde, TextStyle? estilo) {
        if (estilo == null) return;
        if (estilo.fontFamily != appFontFamily) {
          semFonte.add('$onde: ${estilo.fontFamily ?? "nenhuma"}');
        }
      }

      const Set<WidgetState> parado = <WidgetState>{};
      confere(
        'FilledButton',
        tema.filledButtonTheme.style?.textStyle?.resolve(parado),
      );
      confere(
        'OutlinedButton',
        tema.outlinedButtonTheme.style?.textStyle?.resolve(parado),
      );
      confere(
        'TextButton',
        tema.textButtonTheme.style?.textStyle?.resolve(parado),
      );
      confere('bodyLarge', tema.textTheme.bodyLarge);
      confere('headlineMedium', tema.textTheme.headlineMedium);
      confere('labelLarge', tema.textTheme.labelLarge);

      expect(
        semFonte,
        isEmpty,
        reason:
            'Escreva `fontFamily: appFontFamily` no estilo: '
            '${semFonte.join(", ")}',
      );
    });

    test('a escala tipográfica é a do Design System', () {
      final TextTheme t = tema.textTheme;
      expect(t.displaySmall?.fontSize, 34);
      expect(t.headlineMedium?.fontSize, 28);
      expect(t.headlineSmall?.fontSize, 24);
      expect(t.titleLarge?.fontSize, 20);
      expect(t.bodyLarge?.fontSize, 16);
      expect(t.bodyMedium?.fontSize, 14);
      expect(t.bodySmall?.fontSize, 12);
      expect(t.labelLarge?.fontSize, 13);
    });

    test('nenhum peso extremo, e no máximo três em uso', () {
      final Set<FontWeight?> pesos = <FontWeight?>{
        tema.textTheme.displaySmall?.fontWeight,
        tema.textTheme.titleLarge?.fontWeight,
        tema.textTheme.titleMedium?.fontWeight,
        tema.textTheme.bodyLarge?.fontWeight,
        tema.textTheme.bodyMedium?.fontWeight,
        tema.textTheme.bodySmall?.fontWeight,
        tema.textTheme.labelLarge?.fontWeight,
      };
      expect(pesos, <FontWeight>{
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
      });
    });

    test('a altura de linha segue a escala, e não o padrão do Material', () {
      // Herdar do Material deixaria metade da escala com os valores do
      // Google. `height` é razão, então 24/16 = 1,5 no corpo de texto.
      expect(tema.textTheme.bodyLarge?.height, closeTo(1.5, 0.001));
      expect(tema.textTheme.displaySmall?.height, closeTo(40 / 34, 0.001));
    });
  });

  group('as telas não têm número solto de layout', () {
    // A regra está escrita em `tokens.dart`: "nenhum número solto de layout
    // em tela nenhuma". Sem uma varredura ela dura até a primeira pressa, e
    // o desvio nunca é gritante: é um 14 onde deveria haver 16, e depois
    // outro, até a grade não existir mais.
    //
    // O que fica de fora, de propósito, é **tamanho de conteúdo**: a altura
    // de uma foto, o lado de um ladrilho, o diâmetro do botão de play. Esses
    // números descrevem a coisa desenhada, não o espaço em volta dela, e
    // engessá-los não deixaria o aplicativo mais coerente.
    List<String> varre(RegExp alvo, bool Function(String) proibido) {
      final List<String> achados = <String>[];
      for (final FileSystemEntity f in Directory(
        'lib/features',
      ).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final List<String> linhas = f.readAsLinesSync();
        for (int i = 0; i < linhas.length; i++) {
          for (final RegExpMatch m in alvo.allMatches(linhas[i])) {
            if (proibido(m.group(0)!)) {
              achados.add('${f.path}:${i + 1}  ${m.group(0)}');
            }
          }
        }
      }
      return achados;
    }

    /// Um número que não seja `0`. O zero fica: escrever `Space.zero` para
    /// dizer "sem espaço" é pior de ler que o próprio zero.
    final RegExp numero = RegExp(r'(?<![\w.])(?!0(?![\d.]))\d+(?![\w.\d])');

    test('espaçamento vem de Space, e não de um número escolhido na hora', () {
      final List<String> achados = varre(
        RegExp(r'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^()]*\)'),
        (String trecho) => numero.hasMatch(trecho),
      );
      expect(
        achados,
        isEmpty,
        reason:
            'Troque pelo degrau da grade em Space (4, 8, 12, 16, 20, 24, 32, '
            '40, 48, 64):\n${achados.join("\n")}',
      );
    });

    test('respiro entre widgets também', () {
      // Só o `SizedBox` que existe para separar duas coisas, quer dizer, o
      // que não tem `child`. Um `SizedBox` com filho está dimensionando
      // conteúdo, e aí o número é a medida da coisa.
      final List<String> achados = varre(
        RegExp(r'SizedBox\((?:height|width): \d+(?:\.\d+)?\)'),
        (String trecho) => numero.hasMatch(trecho),
      );
      expect(
        achados,
        isEmpty,
        reason: 'Use um degrau de Space:\n${achados.join("\n")}',
      );
    });

    test('nenhuma tela escolhe peso de fonte fora da escala', () {
      // O Design System usa quatro pesos, e o `pubspec` empacota só esses
      // quatro. Um `w300` numa tela não dá erro nem aviso: o arquivo não
      // existe, o Flutter cai no peso mais próximo, e o resultado é um texto
      // que nunca teve a aparência que alguém escreveu. Foi o que estava na
      // tela de entrada.
      final List<String> achados = varre(
        RegExp(r'FontWeight\.(w\d00|bold|normal|light|black)'),
        (String trecho) => !<String>[
          'FontWeight.w400',
          'FontWeight.w500',
          'FontWeight.w600',
          'FontWeight.w700',
        ].contains(trecho),
      );
      expect(
        achados,
        isEmpty,
        reason:
            'A escala tem quatro pesos, e são os únicos empacotados: '
            'w400, w500, w600, w700.\n${achados.join("\n")}',
      );
    });

    test('raio de canto vem de Radii', () {
      // Aqui não há degrau para arredondar: o raio diz que tipo de superfície
      // é aquilo. Botão, campo, cartão, mídia e pílula têm raios diferentes
      // de propósito, e escolher o número solto é escolher errado por acaso.
      final List<String> achados = varre(
        RegExp(r'BorderRadius\.circular\(\d+(?:\.\d+)?\)'),
        (String _) => true,
      );
      expect(
        achados,
        isEmpty,
        reason:
            'Use Radii.buttonR, fieldR, cardR, mediaR, pillR ou tileR:\n'
            '${achados.join("\n")}',
      );
    });
  });
}
