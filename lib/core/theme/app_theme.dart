import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';

/// Raio padrão dos cartões - cantos generosos, como no mockup.
const double kCardRadius = 20;
const double kPagePadding = 20;

abstract final class AppTheme {
  /// Monta o tema com a paleta da criança.
  ///
  /// A paleta entra por parâmetro, e não por leitura de um global, para
  /// que trocar de criança seja só reconstruir o tema.
  static ThemeData build(AppPalette cores) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: cores.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: cores.primary,
          onPrimary: Colors.white,
          surface: cores.surface,
          onSurface: cores.textPrimary,
          error: AppPalette.danger,
        );

    final TextTheme text = _textTheme(Typography.material2021().black, cores);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: <ThemeExtension<Object?>>[cores],
      scaffoldBackgroundColor: cores.background,
      canvasColor: cores.background,
      textTheme: text,
      dividerColor: cores.divider,
      dividerTheme: DividerThemeData(
        color: cores.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cores.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cores.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cores.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cores.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cores.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cores.primaryDark),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cores.textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: cores.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: text.labelMedium?.copyWith(color: cores.textSecondary),
        border: _inputBorder(cores.divider),
        enabledBorder: _inputBorder(cores.divider),
        focusedBorder: _inputBorder(cores.primary, width: 1.6),
        errorBorder: _inputBorder(AppPalette.danger),
        focusedErrorBorder: _inputBorder(AppPalette.danger, width: 1.6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cores.surfaceMuted,
        selectedColor: cores.primarySoft,
        side: BorderSide.none,
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cores.background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cores.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 66,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => text.labelSmall!.copyWith(
            fontSize: 11,
            color: states.contains(WidgetState.selected)
                ? cores.primary
                : cores.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? cores.primary
                : cores.textSecondary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cores.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: cores.textSecondary,
        textColor: cores.textPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cores.primary,
        linearTrackColor: cores.primarySoft,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base, AppPalette cores) {
    return base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
          bodySmall: base.bodySmall?.copyWith(
            height: 1.4,
            color: cores.textSecondary,
          ),
          labelMedium: base.labelMedium?.copyWith(color: cores.textSecondary),
        )
        .apply(bodyColor: cores.textPrimary, displayColor: cores.textPrimary);
  }
}
