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
    required this.heroFill,
    required this.onHero,
    required this.onHeroSoft,
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

  /// O painel cheio do topo da Home.
  ///
  /// Antes ali havia um gradiente entre `primarySoft` e `accentSoft`, e o
  /// resultado era um tom pálido que não existia como token nenhum: quem
  /// tirasse a cor com conta-gotas pegaria um valor do meio do caminho, sem
  /// nome e sem lugar no Design System. Agora é uma cor só, com nome.
  ///
  /// Ela é escura o bastante para exigir os pares abaixo: os tons de texto
  /// do resto do aplicativo não passam no contraste em cima dela.
  final Color heroFill;

  /// O texto principal sobre [heroFill].
  final Color onHero;

  /// O texto secundário sobre [heroFill], ainda acima de 4.5:1.
  final Color onHeroSoft;
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
    background: Color(0xFFFCF3EE),
    // O tom pedido para o painel do topo.
    heroFill: Color(0xFFC893AC),
    onHero: Color(0xFF32292E),
    onHeroSoft: Color(0xFF3E3138),
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
    // Papel frio, e não o creme da Lavender.
    //
    // O creme é um papel quente (matiz 21°) e não sai da paleta de ninguém:
    // ele existe para ser o fundo neutro que harmoniza com o rosa. Sobre a
    // Sky ele briga, porque a Sky é fria inteira.
    //
    // Este tom sai da própria Sky: matiz 216° e saturação 56%, contra 213° e
    // 57% do `primary`, clareado até dar exatamente a mesma presença do creme
    // contra um cartão branco (1,0941:1 nos dois). Assim os dois temas têm o
    // mesmo peso de papel, e só a temperatura muda.
    background: Color(0xFFF1F5FB),
    // O equivalente da família Sky, com a mesma clareza do tom pedido para
    // a Lavender, para o painel ter o mesmo peso nos dois temas.
    heroFill: Color(0xFF93AEC8),
    onHero: Color(0xFF23292F),
    onHeroSoft: Color(0xFF2F3941),
    surface: Colors.white,
    // O preenchimento teve de mudar junto com o fundo, e não por gosto.
    //
    // O que separa o preenchimento do papel na Lavender é a temperatura: o
    // fundo tem b* +3,5 e este tom tem b* -2,7, e essa virada de quente para
    // frio responde por quase todo o ΔE 6,87 entre os dois. Com o fundo agora
    // frio, o azul de antes (`#EDF5FC`) caía para ΔE 1,48, abaixo do limiar
    // em que o olho separa duas cores: esqueleto, miniatura e cartão sumiriam
    // dentro da tela.
    //
    // A saída estava na própria paleta, no verde-água do `accent`. Sobre o
    // papel azul ele volta a ΔE 5,71, com a mesma presença do preenchimento
    // da Lavender (1,141:1 contra 1,142:1). O eixo mudou de temperatura para
    // matiz, o resultado é o mesmo.
    surfaceMuted: Color(0xFFE9F2EE),
    textPrimary: Color(0xFF2A3138),
    // Um passo mais escuro que o tom original da Sky, que dava 4.497:1 e
    // reprovava em AA por três milésimos. Sobre o papel novo dá 4,685:1.
    textSecondary: Color(0xFF646F7A),
    muted: Color(0xFF98A4AE),
    border: Color(0xFFDCE6F1),
    photo: _foto,
    photoSoft: _fotoSoft,
    video: _video,
    videoSoft: _videoSoft,
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
    background: Color(0xFFFCF3EE),
    heroFill: Color(0xFFC89B8B),
    onHero: Color(0xFF2F251F),
    onHeroSoft: Color(0xFF3B2F28),
    surface: Colors.white,
    // Areia, e não o quase-branco de antes.
    //
    // O tom anterior (`#F8F0EB`) ficava a ΔE 1,18 do fundo, abaixo do limiar
    // do olho: esqueleto e cartão eram desenhados e não apareciam, justamente
    // nas telas de apresentação e de login, que são as primeiras que alguém vê.
    // Ninguém tinha reclamado porque nada dá erro quando uma cor some.
    //
    // Aqui a separação tem de vir de claridade, e não de temperatura como na
    // Lavender: o tema Welcome é quente inteiro, do terracota ao fundo, e não
    // há para onde ir no matiz sem sair da família.
    surfaceMuted: Color(0xFFF5E9E0),
    textPrimary: Color(0xFF2F251F),
    textSecondary: Color(0xFF71665E),
    muted: Color(0xFFA39890),
    border: Color(0xFFE9DDD6),
    photo: _foto,
    photoSoft: _fotoSoft,
    video: _video,
    videoSoft: _videoSoft,
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
    Color? heroFill,
    Color? onHero,
    Color? onHeroSoft,
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
      heroFill: heroFill ?? this.heroFill,
      onHero: onHero ?? this.onHero,
      onHeroSoft: onHeroSoft ?? this.onHeroSoft,
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
      heroFill: mix(heroFill, other.heroFill),
      onHero: mix(onHero, other.onHero),
      onHeroSoft: mix(onHeroSoft, other.onHeroSoft),
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
