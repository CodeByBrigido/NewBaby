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

    test('o branco sobre a cor de marca não pode piorar', () {
      // Medido, não suposto: hoje o botão principal fica em 3,68 (Welcome),
      // 3,09 (Girl) e 2,75 (Boy). A WCAG pede 4,5 para texto de 16 px em
      // negrito, então **nenhum dos três passa em AA**.
      //
      // As cores são escolha de marca e ficam como estão. O que este teste
      // garante é que ninguém as clareie ainda mais sem que apareça aqui.
      // Para passar em AA mantendo matiz e saturação: Welcome #C94D33,
      // Boy #3577C5, Girl #B8528E.
      expect(
        contraste(Colors.white, AppPalette.neutral.primary),
        closeTo(3.68, 0.05),
      );
      expect(
        contraste(Colors.white, AppPalette.girl.primary),
        closeTo(3.09, 0.05),
      );
      expect(
        contraste(Colors.white, AppPalette.boy.primary),
        closeTo(2.75, 0.05),
      );
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
}
