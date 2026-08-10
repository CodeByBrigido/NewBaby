/// Os tokens do Design System que não são cor.
///
/// Cor muda com a criança e por isso vive em [AppPalette], que é uma
/// `ThemeExtension`. Espaço, raio, sombra e tempo **não** mudam: são os
/// mesmos nos três temas, por decisão do Design System. Constante é a forma
/// certa para eles, e deixa o analisador apontar cada uso.
///
/// A regra prática: nenhum número solto de layout em tela nenhuma. Se um
/// valor não estiver aqui, ou ele é conteúdo (o tamanho de uma foto) ou está
/// faltando neste arquivo.
library;

import 'package:flutter/material.dart';

/// Espaçamento, em grade de 8.
///
/// Os dois primeiros (4 e 12) quebram a grade de propósito: 4 para ajuste
/// óptico entre texto e ícone, 12 para o respiro entre cartões, que em 8
/// fica apertado e em 16 desmancha o agrupamento.
abstract final class Space {
  static const double x4 = 4;
  static const double x8 = 8;
  static const double x12 = 12;
  static const double x16 = 16;
  static const double x20 = 20;
  static const double x24 = 24;
  static const double x32 = 32;
  static const double x40 = 40;
  static const double x48 = 48;
  static const double x64 = 64;

  /// Margem lateral de qualquer tela.
  static const double page = x16;

  /// Entre blocos de assunto diferente.
  static const double block = x24;

  /// Entre um cartão e o seguinte, dentro da mesma lista.
  static const double card = x12;

  /// Entre um título e o subtítulo dele.
  static const double title = x8;

  /// Folga no fim de uma lista rolável.
  ///
  /// Sem ela o último cartão para debaixo da barra de baixo ou do botão
  /// flutuante, e a pessoa acha que a lista acabou antes. A soma está
  /// escrita à vista de propósito: se a barra mudar de altura, dá para ver
  /// daqui de onde este número veio.
  static const double scrollEnd = x64 + x32;
}

/// Raio de canto por tipo de superfície.
abstract final class Radii {
  static const double button = 18;
  static const double card = 20;
  static const double field = 14;
  static const double sheet = 28;
  static const double media = 16;

  /// Pílula: chips, badges e qualquer coisa que deva parecer redonda.
  static const double pill = 999;

  /// Ladrilho de ícone: a marca na abertura, o símbolo das telas de
  /// apresentação, o coração da tela Sobre.
  ///
  /// O raio acompanha o lado em vez de ser fixo, e é isso que mantém o mesmo
  /// desenho em 72 e em 132: um raio fixo faz o ladrilho pequeno parecer
  /// redondo e o grande parecer quadrado.
  static BorderRadius tileR(double lado) => BorderRadius.circular(lado / 3);

  static BorderRadius get buttonR => BorderRadius.circular(button);
  static BorderRadius get cardR => BorderRadius.circular(card);
  static BorderRadius get fieldR => BorderRadius.circular(field);
  static BorderRadius get mediaR => BorderRadius.circular(media);
  static BorderRadius get pillR => BorderRadius.circular(pill);

  /// Folhas e diálogos sobem da base: só os cantos de cima são arredondados.
  static const BorderRadius sheetR = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Elevação.
///
/// Três níveis, todos quase imperceptíveis. A hierarquia neste aplicativo é
/// feita por cor e espaço; a sombra só separa o que flutua do que está
/// parado. Sombra forte aqui envelhece mal e parece barata.
abstract final class Shadows {
  static const Color _tinta = Color(0xFF2F251F);

  /// Cartão em repouso.
  static const List<BoxShadow> level1 = <BoxShadow>[
    BoxShadow(color: Color(0x0F2F251F), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Coisas que flutuam: FAB, cartão destacado.
  static const List<BoxShadow> level2 = <BoxShadow>[
    BoxShadow(color: Color(0x142F251F), blurRadius: 18, offset: Offset(0, 6)),
  ];

  /// O que cobre a tela: folhas e diálogos.
  static const List<BoxShadow> level3 = <BoxShadow>[
    BoxShadow(color: Color(0x1A2F251F), blurRadius: 30, offset: Offset(0, 12)),
  ];

  /// Para quando só a cor da sombra é necessária.
  static Color tintaCom(double opacidade) =>
      _tinta.withValues(alpha: opacidade);
}

/// Tempo e curva de qualquer animação.
///
/// Um sistema, não efeitos soltos: quem for animar algo novo escolhe entre
/// estes, e não inventa um número. É o que faz o aplicativo inteiro parecer
/// ter sido feito pela mesma pessoa.
abstract final class Motion {
  static const Duration fade = Duration(milliseconds: 200);
  static const Duration slide = Duration(milliseconds: 250);
  static const Duration screen = Duration(milliseconds: 300);
  static const Duration sheet = Duration(milliseconds: 280);

  /// Miniatura crescendo até virar a foto em tela cheia.
  static const Duration hero = Duration(milliseconds: 350);

  /// Toque, seleção, troca de estado: quase instantâneo.
  static const Duration micro = Duration(milliseconds: 140);

  /// Entrar na tela desacelera; sair acelera. É o que dá a impressão de
  /// peso sem precisar de mais tempo.
  static const Curve entrada = Curves.easeOutCubic;
  static const Curve saida = Curves.easeInCubic;
  static const Curve padrao = Curves.easeOut;
}

/// Tamanhos de componente que o Design System fixa.
abstract final class Sizes {
  /// Altura de botão principal e secundário.
  static const double button = 56;

  /// Altura de campo de texto.
  static const double field = 56;
  static const double fieldCompact = 52;

  static const double chip = 36;
  static const double chipCompact = 32;

  static const double fab = 56;

  /// O Design System pede 56 para a barra de baixo. O `NavigationBar` do
  /// Material mede ícone mais rótulo, e em 56 o rótulo é cortado no
  /// tamanho de fonte padrão. 64 é o menor valor que não corta.
  static const double bottomNav = 64;

  /// Altura mínima de um item de lista.
  static const double listItem = 56;

  /// Container do ícone dentro de um item de lista.
  static const double listIcon = 40;

  static const double icon = 24;
  static const double iconSmall = 18;
  static const double iconLarge = 32;

  /// Área mínima de toque, em qualquer lugar.
  ///
  /// Não é enfeite de acessibilidade: é o tamanho abaixo do qual o dedo de
  /// quem está com uma criança no colo erra o alvo.
  static const double touch = 48;

  /// Avatar, nos três tamanhos que o aplicativo usa.
  static const double avatarSmall = 32;
  static const double avatar = 44;
  static const double avatarLarge = 96;
}
