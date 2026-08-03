import 'package:flutter/material.dart';

import '../../models/baby_gender.dart';

/// As cores do aplicativo, escolhidas conforme a criança.
///
/// Antes isto era um punhado de `static const`. Constante não muda em tempo
/// de execução, e o aplicativo precisa mudar: quem cadastra um menino não
/// deve receber um aplicativo cor de rosa.
///
/// Vive como [ThemeExtension] em vez de global mutável porque assim o
/// Flutter cuida da transição entre as paletas, o teste consegue montar uma
/// tela com a paleta que quiser, e nada depende de a ordem de inicialização
/// estar certa.
///
/// Leia com `context.cores`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.accent,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.photo,
    required this.photoSoft,
    required this.video,
    required this.videoSoft,
    required this.letter,
    required this.letterSoft,
    required this.drawing,
    required this.drawingSoft,
    required this.document,
    required this.documentSoft,
    required this.growth,
    required this.growthSoft,
  });

  /// Cor de marca: botões, destaques, trilho da linha do tempo.
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;

  /// Segunda cor, para detalhes decorativos que não podem competir com a
  /// principal.
  final Color accent;
  final Color accentSoft;

  final Color background;
  final Color surface;
  final Color surfaceMuted;

  final Color textPrimary;
  final Color textSecondary;
  final Color divider;

  /// Acento de cada categoria, e o pastel correspondente para os cartões.
  ///
  /// Foto, vídeo e desenho não mudam entre as paletas: são identificadores,
  /// e trocar o verde da foto por paleta só faria a pessoa reaprender. O que
  /// varia é o que encostaria na cor de marca.
  final Color photo;
  final Color photoSoft;
  final Color video;
  final Color videoSoft;
  final Color letter;
  final Color letterSoft;
  final Color drawing;
  final Color drawingSoft;
  final Color document;
  final Color documentSoft;
  final Color growth;
  final Color growthSoft;

  /// Vermelho de erro e verde de sucesso não mudam por paleta: significam a
  /// mesma coisa em qualquer aplicativo, e reaprender isso custa caro.
  static const Color danger = Color(0xFFD1585B);
  static const Color success = Color(0xFF5E9E7E);

  /// Menina: rosa-malva, lilás e pêssego sobre creme.
  static const AppPalette girl = AppPalette(
    primary: Color(0xFFC77DA8),
    primaryDark: Color(0xFFA85C88),
    primarySoft: Color(0xFFF3DCE8),
    accent: Color(0xFF9B7BC4),
    accentSoft: Color(0xFFEDE4F5),
    background: Color(0xFFFDF8F5),
    surface: Colors.white,
    surfaceMuted: Color(0xFFF6EFEA),
    textPrimary: Color(0xFF3D3436),
    textSecondary: Color(0xFF8A7C81),
    divider: Color(0xFFEDE2DC),
    photo: Color(0xFF7FB08A),
    photoSoft: Color(0xFFE6F0E4),
    video: Color(0xFFD9A441),
    videoSoft: Color(0xFFFAF0DA),
    letter: Color(0xFFC77DA8),
    letterSoft: Color(0xFFF7E3EE),
    drawing: Color(0xFFDE8B5C),
    drawingSoft: Color(0xFFFBE7DA),
    document: Color(0xFF6E93C4),
    documentSoft: Color(0xFFE3EBF7),
    growth: Color(0xFFD97A7A),
    growthSoft: Color(0xFFFAE2E2),
  );

  /// Menino: azul suave, verde água e cinza sobre um branco levemente frio.
  static const AppPalette boy = AppPalette(
    primary: Color(0xFF5589B5),
    primaryDark: Color(0xFF3B6890),
    primarySoft: Color(0xFFDCE8F2),
    accent: Color(0xFF6FB0A6),
    accentSoft: Color(0xFFDFEFEC),
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    surfaceMuted: Color(0xFFEEF3F7),
    textPrimary: Color(0xFF333A40),
    textSecondary: Color(0xFF7C8891),
    divider: Color(0xFFDFE7ED),
    photo: Color(0xFF7FB08A),
    photoSoft: Color(0xFFE6F0E4),
    video: Color(0xFFD9A441),
    videoSoft: Color(0xFFFAF0DA),
    letter: Color(0xFF5589B5),
    letterSoft: Color(0xFFDCE8F2),
    drawing: Color(0xFFDE8B5C),
    drawingSoft: Color(0xFFFBE7DA),
    // Azul-lavanda: o documento era azul, e azul agora é a cor de marca.
    document: Color(0xFF8085B8),
    documentSoft: Color(0xFFE6E7F4),
    growth: Color(0xFFCF7B6B),
    growthSoft: Color(0xFFF7E3DE),
  );

  /// Antes de saber quem é a criança: login e início do cadastro.
  ///
  /// Lavanda acinzentada, de propósito. É a primeira tela que alguém vê, e
  /// ela não deve parecer escolhida para menina nem para menino.
  static const AppPalette neutral = AppPalette(
    primary: Color(0xFF8F84A8),
    primaryDark: Color(0xFF6E6486),
    primarySoft: Color(0xFFE9E5F0),
    accent: Color(0xFF9B9BAF),
    accentSoft: Color(0xFFEDEDF2),
    background: Color(0xFFFAF9FB),
    surface: Colors.white,
    surfaceMuted: Color(0xFFF1EFF4),
    textPrimary: Color(0xFF383540),
    textSecondary: Color(0xFF837E8D),
    divider: Color(0xFFE6E3EB),
    photo: Color(0xFF7FB08A),
    photoSoft: Color(0xFFE6F0E4),
    video: Color(0xFFD9A441),
    videoSoft: Color(0xFFFAF0DA),
    letter: Color(0xFF8F84A8),
    letterSoft: Color(0xFFE9E5F0),
    drawing: Color(0xFFDE8B5C),
    drawingSoft: Color(0xFFFBE7DA),
    document: Color(0xFF6E93C4),
    documentSoft: Color(0xFFE3EBF7),
    growth: Color(0xFFD97A7A),
    growthSoft: Color(0xFFFAE2E2),
  );

  /// A paleta de uma criança. `null` cai no neutro, e é assim que cadastros
  /// antigos, sem sexo informado, continuam funcionando.
  static AppPalette of(BabyGender? gender) => switch (gender) {
    BabyGender.girl => girl,
    BabyGender.boy => boy,
    null => neutral,
  };

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? accent,
    Color? accentSoft,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? photo,
    Color? photoSoft,
    Color? video,
    Color? videoSoft,
    Color? letter,
    Color? letterSoft,
    Color? drawing,
    Color? drawingSoft,
    Color? document,
    Color? documentSoft,
    Color? growth,
    Color? growthSoft,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      photo: photo ?? this.photo,
      photoSoft: photoSoft ?? this.photoSoft,
      video: video ?? this.video,
      videoSoft: videoSoft ?? this.videoSoft,
      letter: letter ?? this.letter,
      letterSoft: letterSoft ?? this.letterSoft,
      drawing: drawing ?? this.drawing,
      drawingSoft: drawingSoft ?? this.drawingSoft,
      document: document ?? this.document,
      documentSoft: documentSoft ?? this.documentSoft,
      growth: growth ?? this.growth,
      growthSoft: growthSoft ?? this.growthSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      primary: mix(primary, other.primary),
      primaryDark: mix(primaryDark, other.primaryDark),
      primarySoft: mix(primarySoft, other.primarySoft),
      accent: mix(accent, other.accent),
      accentSoft: mix(accentSoft, other.accentSoft),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      divider: mix(divider, other.divider),
      photo: mix(photo, other.photo),
      photoSoft: mix(photoSoft, other.photoSoft),
      video: mix(video, other.video),
      videoSoft: mix(videoSoft, other.videoSoft),
      letter: mix(letter, other.letter),
      letterSoft: mix(letterSoft, other.letterSoft),
      drawing: mix(drawing, other.drawing),
      drawingSoft: mix(drawingSoft, other.drawingSoft),
      document: mix(document, other.document),
      documentSoft: mix(documentSoft, other.documentSoft),
      growth: mix(growth, other.growth),
      growthSoft: mix(growthSoft, other.growthSoft),
    );
  }
}

/// Atalho para ler a paleta ativa: `context.cores.primary`.
///
/// A reserva para o neutro existe para que um widget montado fora do tema do
/// aplicativo (um teste, um `showDialog` com tema próprio) apareça com cor
/// errada em vez de derrubar a tela.
extension AppPaletteContext on BuildContext {
  AppPalette get cores =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.neutral;
}
