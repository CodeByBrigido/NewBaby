import 'package:flutter/material.dart';

/// Paleta do aplicativo: tons suaves, fundo creme e foco nas fotos.
abstract final class AppColors {
  /// Rosa-malva usado em botões, destaques e no trilho da linha do tempo.
  static const Color primary = Color(0xFFC77DA8);
  static const Color primaryDark = Color(0xFFA85C88);
  static const Color primarySoft = Color(0xFFF3DCE8);

  /// Fundo creme de todas as telas.
  static const Color background = Color(0xFFFDF8F5);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF6EFEA);

  static const Color textPrimary = Color(0xFF3D3436);
  static const Color textSecondary = Color(0xFF8A7C81);
  static const Color divider = Color(0xFFEDE2DC);

  static const Color danger = Color(0xFFD1585B);
  static const Color success = Color(0xFF5E9E7E);

  /// Cor de acento de cada categoria, seguindo o mockup.
  static const Color photo = Color(0xFF7FB08A);
  static const Color video = Color(0xFFD9A441);
  static const Color letter = Color(0xFFC77DA8);
  static const Color drawing = Color(0xFFDE8B5C);
  static const Color document = Color(0xFF6E93C4);
  static const Color growth = Color(0xFFD97A7A);

  /// Fundo pastel correspondente a cada acento, para os cartões e ícones.
  static const Color photoSoft = Color(0xFFE6F0E4);
  static const Color videoSoft = Color(0xFFFAF0DA);
  static const Color letterSoft = Color(0xFFF7E3EE);
  static const Color drawingSoft = Color(0xFFFBE7DA);
  static const Color documentSoft = Color(0xFFE3EBF7);
  static const Color growthSoft = Color(0xFFFAE2E2);
}
