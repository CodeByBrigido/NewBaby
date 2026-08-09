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
    required this.primaryStrong,
    required this.primaryDark,
    required this.primarySoft,
    required this.accent,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.muted,
    required this.border,
    required this.photo,
    required this.photoSoft,
    required this.video,
    required this.videoSoft,
    required this.audio,
    required this.audioSoft,
    required this.letter,
    required this.letterSoft,
    required this.drawing,
    required this.drawingSoft,
    required this.document,
    required this.documentSoft,
    required this.growth,
    required this.growthSoft,
  });

  /// Cor de marca: ícone sobre fundo claro, trilho da linha do tempo, ponto
  /// ativo, borda de campo em foco, gráfico, ilustração.
  ///
  /// Vale para tudo em que a cor **é** a cor. Nunca para o fundo de um texto
  /// branco: nos três temas ela fica entre 2,75:1 e 3,68:1 contra o branco,
  /// abaixo dos 4,5:1 que a WCAG pede.
  final Color primary;

  /// A mesma cor, escurecida até passar em AA contra o branco.
  ///
  /// Para toda superfície preenchida que leva texto ou ícone branco em cima:
  /// botão principal, FAB, cabeçalho do seletor de data. Mantém matiz e
  /// saturação da [primary], então continua sendo a mesma cor de marca, só
  /// legível.
  final Color primaryStrong;

  /// A cor de marca como **texto**, sobre fundo claro: botão secundário,
  /// link, rótulo de chip ativo.
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

  /// O terceiro nível de texto: placeholder, legenda de apoio, o que está
  /// presente sem pedir atenção. Abaixo dele não existe outro: texto mais
  /// claro que isto deixa de ser legível ao sol.
  final Color muted;

  /// Contorno de 1 px de cartões e campos.
  final Color border;

  /// Nome antigo de [border], mantido porque ele aparece em dezenas de
  /// telas e trocar tudo de uma vez não acrescentaria nada.
  Color get divider => border;

  /// Acento de cada categoria, e o pastel correspondente para os cartões.
  ///
  /// Foto, vídeo e desenho não mudam entre as paletas: são identificadores,
  /// e trocar o verde da foto por paleta só faria a pessoa reaprender. O que
  /// varia é o que encostaria na cor de marca.
  final Color photo;
  final Color photoSoft;
  final Color video;
  final Color videoSoft;
  final Color audio;
  final Color audioSoft;
  final Color letter;
  final Color letterSoft;
  final Color drawing;
  final Color drawingSoft;
  final Color document;
  final Color documentSoft;
  final Color growth;
  final Color growthSoft;

  /// As cores que significam alguma coisa.
  ///
  /// Não mudam entre os temas, por decisão do Design System: verde é sucesso
  /// em qualquer aplicativo, e reaprender isso custa caro. Todas são de
  /// saturação baixa, para que um aviso não grite no meio de uma tela calma.
  static const Color success = Color(0xFF69B67F);
  static const Color info = Color(0xFF7A95C5);
  static const Color warning = Color(0xFFD8A05A);
  static const Color error = Color(0xFFD57A73);

  /// Nome antigo de [error].
  static const Color danger = error;

  // Cor de cada categoria de memória. Também constantes: foto, vídeo e
  // carta são identificadores, e trocá-las por tema faria a pessoa
  // reaprender o aplicativo a cada filho.
  static const Color _foto = Color(0xFF7BAE86);
  static const Color _fotoSoft = Color(0xFFE6F0E4);
  static const Color _video = Color(0xFFD8A05A);
  static const Color _videoSoft = Color(0xFFFAF0DA);
  static const Color _audio = Color(0xFF8E7BB5);
  static const Color _audioSoft = Color(0xFFEBE4F4);
  static const Color _carta = Color(0xFFC87AA8);
  static const Color _cartaSoft = Color(0xFFF1DFEC);
  static const Color _desenho = Color(0xFFDE8B5C);
  static const Color _desenhoSoft = Color(0xFFFBE7DA);
  static const Color _documento = Color(0xFF7A95C5);
  static const Color _documentoSoft = Color(0xFFE3EBF7);
  static const Color _crescimento = Color(0xFFD57A73);
  static const Color _crescimentoSoft = Color(0xFFFAE2E2);

  /// Tema Girl (Lavender): lavanda, flores, aquarela, delicadeza.
  static const AppPalette girl = AppPalette(
    primary: Color(0xFFC87AA8),
    primaryStrong: Color(0xFFB8528E),
    primaryDark: Color(0xFFB56696),
    primarySoft: Color(0xFFF1DFEC),
    accent: Color(0xFF9B87C4),
    accentSoft: Color(0xFFEDE4F5),
    background: Color(0xFFFFFDFE),
    surface: Colors.white,
    surfaceMuted: Color(0xFFF7EDF5),
    textPrimary: Color(0xFF32292E),
    textSecondary: Color(0xFF6D6468),
    muted: Color(0xFF9F9399),
    border: Color(0xFFEADBE5),
    photo: _foto,
    photoSoft: _fotoSoft,
    video: _video,
    videoSoft: _videoSoft,
    audio: _audio,
    audioSoft: _audioSoft,
    letter: _carta,
    letterSoft: _cartaSoft,
    drawing: _desenho,
    drawingSoft: _desenhoSoft,
    document: _documento,
    documentSoft: _documentoSoft,
    growth: _crescimento,
    growthSoft: _crescimentoSoft,
  );

  /// Tema Boy (Sky): céu, manhã, algodão, tranquilidade.
  static const AppPalette boy = AppPalette(
    primary: Color(0xFF6F9FD8),
    primaryStrong: Color(0xFF3577C5),
    primaryDark: Color(0xFF5687C5),
    primarySoft: Color(0xFFDDEAF8),
    accent: Color(0xFF6FB0A6),
    accentSoft: Color(0xFFDFEFEC),
    background: Color(0xFFF8FBFE),
    surface: Colors.white,
    surfaceMuted: Color(0xFFEDF5FC),
    textPrimary: Color(0xFF2A3138),
    textSecondary: Color(0xFF66727D),
    muted: Color(0xFF98A4AE),
    border: Color(0xFFDCE6F1),
    photo: _foto,
    photoSoft: _fotoSoft,
    video: _video,
    videoSoft: _videoSoft,
    audio: _audio,
    audioSoft: _audioSoft,
    letter: _carta,
    letterSoft: _cartaSoft,
    drawing: _desenho,
    drawingSoft: _desenhoSoft,
    document: _documento,
    documentSoft: _documentoSoft,
    growth: _crescimento,
    growthSoft: _crescimentoSoft,
  );

  /// Tema Welcome: abertura, apresentação, login e cadastro.
  ///
  /// É a cor do ícone, e vale enquanto ainda não se sabe quem é a criança.
  /// Assim que o cadastro informa o sexo, o aplicativo troca para Sky ou
  /// Lavender, e só os elementos de destaque mudam: fundo, tipografia,
  /// cartões e espaçamento continuam os mesmos.
  static const AppPalette neutral = AppPalette(
    primary: Color(0xFFD2654E),
    primaryStrong: Color(0xFFC94D33),
    primaryDark: Color(0xFFB8513E),
    primarySoft: Color(0xFFF8E2DC),
    accent: Color(0xFFC98C6B),
    accentSoft: Color(0xFFF6E7DC),
    background: Color(0xFFFBF8F5),
    surface: Colors.white,
    surfaceMuted: Color(0xFFF8F0EB),
    textPrimary: Color(0xFF2F251F),
    textSecondary: Color(0xFF71665E),
    muted: Color(0xFFA39890),
    border: Color(0xFFE9DDD6),
    photo: _foto,
    photoSoft: _fotoSoft,
    video: _video,
    videoSoft: _videoSoft,
    audio: _audio,
    audioSoft: _audioSoft,
    letter: _carta,
    letterSoft: _cartaSoft,
    drawing: _desenho,
    drawingSoft: _desenhoSoft,
    document: _documento,
    documentSoft: _documentoSoft,
    growth: _crescimento,
    growthSoft: _crescimentoSoft,
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
    Color? primaryStrong,
    Color? primaryDark,
    Color? primarySoft,
    Color? accent,
    Color? accentSoft,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? muted,
    Color? border,
    Color? photo,
    Color? photoSoft,
    Color? video,
    Color? videoSoft,
    Color? audio,
    Color? audioSoft,
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
      primaryStrong: primaryStrong ?? this.primaryStrong,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      photo: photo ?? this.photo,
      photoSoft: photoSoft ?? this.photoSoft,
      video: video ?? this.video,
      videoSoft: videoSoft ?? this.videoSoft,
      audio: audio ?? this.audio,
      audioSoft: audioSoft ?? this.audioSoft,
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
      primaryStrong: mix(primaryStrong, other.primaryStrong),
      primaryDark: mix(primaryDark, other.primaryDark),
      primarySoft: mix(primarySoft, other.primarySoft),
      accent: mix(accent, other.accent),
      accentSoft: mix(accentSoft, other.accentSoft),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      muted: mix(muted, other.muted),
      border: mix(border, other.border),
      photo: mix(photo, other.photo),
      photoSoft: mix(photoSoft, other.photoSoft),
      video: mix(video, other.video),
      videoSoft: mix(videoSoft, other.videoSoft),
      audio: mix(audio, other.audio),
      audioSoft: mix(audioSoft, other.audioSoft),
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
