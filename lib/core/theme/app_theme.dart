import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';
import 'tokens.dart';

/// Nomes antigos, mantidos porque aparecem em dezenas de telas.
const double kCardRadius = Radii.card;
const double kPagePadding = Space.x20;

/// A família tipográfica do Design System.
///
/// Os arquivos viajam dentro do aplicativo, e não são baixados em tempo de
/// execução: este aplicativo abre offline e não manda pedido nenhum para
/// servidor de terceiro, nem para buscar uma fonte.
///
/// Só quatro pesos entram no pacote (400, 500, 600 e 700), que são os que a
/// escala usa. Itálico não existe aqui de propósito: o Design System não
/// prevê nenhum, e pedir um faria o Flutter inclinar a fonte por conta, com
/// resultado pior que uma itálica de verdade.
const String appFontFamily = 'PlusJakartaSans';

abstract final class AppTheme {
  /// Monta o tema com a paleta da criança.
  ///
  /// A paleta entra por parâmetro, e não por leitura de um global, para
  /// que trocar de criança seja só reconstruir o tema. O que ela muda é só
  /// o destaque: fundo, tipografia, cartões, espaçamento e sombra são os
  /// mesmos nos três temas, por decisão do Design System.
  static ThemeData build(AppPalette cores) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: cores.primary,
          brightness: Brightness.light,
        ).copyWith(
          // `primaryStrong`, e não `primary`: o `ColorScheme.primary` é o que
          // o Material usa como fundo de qualquer coisa com `onPrimary` em
          // cima, e `onPrimary` aqui é branco.
          primary: cores.primaryStrong,
          onPrimary: Colors.white,
          primaryContainer: cores.primarySoft,
          onPrimaryContainer: cores.primaryDark,
          surface: cores.surface,
          onSurface: cores.textPrimary,
          outline: cores.border,
          outlineVariant: cores.border,
          error: AppPalette.error,
        );

    final TextTheme text = _textTheme(cores);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: <ThemeExtension<Object?>>[cores],
      fontFamily: appFontFamily,
      scaffoldBackgroundColor: cores.background,
      canvasColor: cores.background,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _FadeSlide(),
          TargetPlatform.iOS: _FadeSlide(),
        },
      ),
      dividerColor: cores.border,
      dividerTheme: DividerThemeData(
        color: cores.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(size: Sizes.icon, color: cores.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: cores.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cores.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(size: Sizes.icon, color: cores.textPrimary),
        titleTextStyle: text.titleMedium?.copyWith(color: cores.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cores.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardR,
          side: BorderSide(color: cores.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cores.primaryStrong,
          foregroundColor: Colors.white,
          disabledBackgroundColor: cores.border,
          disabledForegroundColor: cores.muted,
          minimumSize: const Size.fromHeight(Sizes.button),
          textStyle: _botao,
          shape: RoundedRectangleBorder(borderRadius: Radii.buttonR),
        ),
      ),
      // Secundário: fundo branco, contorno fino, texto na cor de marca. Ele
      // divide a linha com o primário em várias telas, então tem a mesma
      // altura: o que separa os dois é o peso da cor, não o tamanho.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: cores.surface,
          foregroundColor: cores.primaryDark,
          disabledForegroundColor: cores.muted,
          minimumSize: const Size.fromHeight(Sizes.button),
          textStyle: _botao,
          side: BorderSide(color: cores.border),
          shape: RoundedRectangleBorder(borderRadius: Radii.buttonR),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cores.primaryDark,
          disabledForegroundColor: cores.muted,
          textStyle: text.labelLarge,
          minimumSize: const Size(Sizes.touch, Sizes.touch),
          shape: RoundedRectangleBorder(borderRadius: Radii.buttonR),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cores.primaryStrong,
        foregroundColor: Colors.white,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 4,
        highlightElevation: 6,
        sizeConstraints: const BoxConstraints.tightFor(
          width: Sizes.fab,
          height: Sizes.fab,
        ),
        shape: RoundedRectangleBorder(borderRadius: Radii.buttonR),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.x16,
          vertical: Space.x16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: text.labelLarge?.copyWith(color: cores.textSecondary),
        // Com o rótulo sempre flutuando, é este estilo que aparece, e não o
        // de cima. Veja `_rotuloNaTela`: o tamanho é calculado para cair em
        // 14 px depois de o Flutter encolher.
        floatingLabelStyle: text.labelLarge?.copyWith(
          color: cores.textSecondary,
          fontSize: _rotuloNaTela / _encolhimentoDoRotulo,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: cores.muted),
        prefixIconColor: cores.textSecondary,
        suffixIconColor: cores.textSecondary,
        border: _campo(cores.border),
        enabledBorder: _campo(cores.border),
        focusedBorder: _campo(cores.primary, width: 1.6),
        disabledBorder: _campo(cores.border),
        errorBorder: _campo(AppPalette.error),
        focusedErrorBorder: _campo(AppPalette.error, width: 1.6),
        errorStyle: text.bodySmall?.copyWith(color: AppPalette.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cores.surface,
        selectedColor: cores.primarySoft,
        disabledColor: cores.surfaceMuted,
        side: BorderSide(color: cores.border),
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge?.copyWith(
          color: cores.primaryDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: Space.x12),
        shape: RoundedRectangleBorder(borderRadius: Radii.pillR),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cores.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheetR),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cores.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cores.primarySoft,
        indicatorShape: RoundedRectangleBorder(borderRadius: Radii.pillR),
        elevation: 0,
        height: Sizes.bottomNav,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => text.labelSmall!.copyWith(
            color: states.contains(WidgetState.selected)
                ? cores.primaryDark
                : cores.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            size: Sizes.icon,
            color: states.contains(WidgetState.selected)
                ? cores.primaryDark
                : cores.textSecondary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: cores.primarySoft,
        insetPadding: const EdgeInsets.all(Space.x16),
        shape: RoundedRectangleBorder(borderRadius: Radii.fieldR),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cores.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sheet),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: cores.textSecondary,
        textColor: cores.textPrimary,
        minVerticalPadding: Space.x12,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: Radii.cardR),
      ),
      // O polegar é branco sobre o trilho, então o trilho ligado usa a cor
      // forte: é o mesmo problema do botão, e a WCAG pede 3:1 até para
      // elemento que não é texto.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? Colors.white : cores.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? cores.primaryStrong
              : cores.border,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? cores.primaryStrong
              : cores.border,
        ),
      ),
      // Marcado é um "v" branco dentro do quadrado preenchido: cor forte.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? cores.primaryStrong
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
        side: BorderSide(color: cores.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? cores.primary : cores.border,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: cores.primary,
        inactiveTrackColor: cores.primarySoft,
        thumbColor: cores.primary,
      ),
      // Fica em `primary`: a barra é a cor sobre fundo claro, e não fundo de
      // texto branco.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cores.primary,
        linearTrackColor: cores.primarySoft,
        circularTrackColor: cores.primarySoft,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cores.textPrimary,
          borderRadius: Radii.fieldR,
        ),
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cores.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: cores.primaryStrong,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sheet),
        ),
      ),
    );
  }

  /// Texto de botão: 16 / 700, o único lugar onde o peso 700 encosta em
  /// corpo de texto.
  /// A fonte precisa estar escrita aqui.
  ///
  /// `ThemeData(fontFamily:)` alcança o `textTheme`, e só ele. Este estilo é
  /// entregue direto ao tema dos botões, então nunca passa por lá: sem esta
  /// linha, o rótulo de todo botão cheio e contornado do aplicativo cai na
  /// fonte padrão do sistema. Não dá tela vermelha nem erro; a identidade
  /// some em silêncio, e num aparelho a diferença passa por descuido de
  /// desenho.
  static const TextStyle _botao = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// O quanto o Flutter encolhe o rótulo do campo quando ele flutua.
  ///
  /// É o `_kFinalLabelScale` do `input_decorator.dart`, e não é um estilo:
  /// é uma transformação aplicada em cima de qualquer tamanho declarado, e
  /// por isso não dá para fugir dela escolhendo outro estilo da escala.
  static const double _encolhimentoDoRotulo = 0.75;

  /// O tamanho que o rótulo do campo tem **na tela**, já contada a redução.
  ///
  /// O aplicativo mantém o rótulo sempre flutuando, então esse encolhimento
  /// vale sempre. Com `labelLarge`, de 13, o rótulo chegava a 9,75 px: menor
  /// que o menor tamanho da escala, que é 12, e pequeno a ponto de "Título"
  /// e "Mensagem" não se lerem com o celular perto do rosto.
  ///
  /// Por isso o número declarado aqui é o que se quer ver, e a divisão
  /// abaixo desfaz a redução do Flutter. Escrever o tamanho da fonte direto
  /// esconderia a conta e o próximo a mexer erraria de novo.
  static const double _rotuloNaTela = 14;

  static OutlineInputBorder _campo(Color cor, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: Radii.fieldR,
      borderSide: BorderSide(color: cor, width: width),
    );
  }

  /// A escala tipográfica, escrita por inteiro.
  ///
  /// Nada aqui é herdado do Material: cada tamanho, peso e altura de linha
  /// vem do Design System. Herdar deixaria metade da escala com os valores
  /// do Google e a outra metade com os nossos, que é o jeito mais rápido de
  /// um aplicativo perder a identidade sem ninguém saber apontar onde.
  static TextTheme _textTheme(AppPalette cores) {
    // A fonte é escrita aqui, e não deixada para o `ThemeData` aplicar. Ele
    // aplica na cópia dele do `textTheme`, e estes mesmos estilos são
    // entregues antes disso ao tema dos botões e da dica: lá chegariam sem
    // fonte, e o rótulo cairia na do sistema sem ninguém ver erro nenhum.
    TextStyle t(double tamanho, FontWeight peso, double linha, Color cor) =>
        TextStyle(
          fontFamily: appFontFamily,
          fontSize: tamanho,
          fontWeight: peso,
          height: linha / tamanho,
          color: cor,
          letterSpacing: tamanho >= 24 ? -0.4 : 0,
        );

    final Color forte = cores.textPrimary;
    final Color fraco = cores.textSecondary;

    return TextTheme(
      // Display e títulos: peso 700, linha curta, para o texto virar bloco.
      displayLarge: t(34, FontWeight.w700, 40, forte),
      displayMedium: t(34, FontWeight.w700, 40, forte),
      displaySmall: t(34, FontWeight.w700, 40, forte),
      headlineLarge: t(28, FontWeight.w700, 34, forte),
      headlineMedium: t(28, FontWeight.w700, 34, forte),
      headlineSmall: t(24, FontWeight.w700, 30, forte),
      titleLarge: t(20, FontWeight.w700, 26, forte),
      titleMedium: t(16, FontWeight.w600, 22, forte),
      titleSmall: t(14, FontWeight.w600, 20, forte),
      // Corpo: peso 400 no texto longo, 500 no curto. É a linha confortável
      // que o Design System pede, e o que separa leitura de rótulo.
      bodyLarge: t(16, FontWeight.w400, 24, forte),
      bodyMedium: t(14, FontWeight.w500, 20, forte),
      bodySmall: t(12, FontWeight.w500, 16, fraco),
      labelLarge: t(13, FontWeight.w600, 16, forte),
      labelMedium: t(13, FontWeight.w600, 16, fraco),
      labelSmall: t(12, FontWeight.w500, 16, fraco),
    );
  }
}

/// Transição de tela: aparecer com um deslize curto, sumir sem deslize.
///
/// O deslize é de 4% da largura, e não de uma tela inteira: a sensação é de
/// camada nova por cima, não de carrossel. Sair é só o inverso, mais rápido,
/// porque voltar já é uma ação conhecida e não precisa ser anunciada.
class _FadeSlide extends PageTransitionsBuilder {
  const _FadeSlide();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Quem desligou animações no Android desligou por um motivo: enxaqueca
    // vestibular é real, e respeitar isso é uma linha de código.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final Animation<double> suave = CurvedAnimation(
      parent: animation,
      curve: Motion.entrada,
      reverseCurve: Motion.saida,
    );

    return FadeTransition(
      opacity: suave,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(suave),
        child: child,
      ),
    );
  }
}
