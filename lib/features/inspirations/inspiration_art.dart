import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../models/inspiration.dart';

/// A capa de uma inspiração, desenhada pelo próprio aplicativo.
///
/// Não são fotos, e isso é uma escolha. Foto de banco de imagens exige
/// licença, engorda o APK em vários megabytes e coloca o bebê de outra
/// pessoa num aplicativo que é sobre uma criança específica. Buscar na
/// internet resolveria o peso e criaria coisa pior: o aplicativo passaria a
/// avisar um servidor toda vez que alguém abre a aba.
///
/// Desenhado em código não custa nada, funciona sem rede, e de quebra
/// acompanha a paleta: a mesma capa sai em rosa para uma menina e em azul
/// para um menino, sem duplicar arquivo nenhum.
class InspirationArt extends StatelessWidget {
  const InspirationArt({
    required this.kind,
    required this.seed,
    super.key,
    this.height = 120,
  });

  final InspirationKind kind;

  /// O id da inspiração. Dá a cada uma um arranjo próprio, sempre igual
  /// entre uma abertura e outra.
  final String seed;

  final double height;

  @override
  Widget build(BuildContext context) {
    final (Color fundo, Color forma) = _cores(context, kind);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _ArtPainter(
            kind: kind,
            background: fundo,
            shape: forma,
            seed: seed.hashCode,
          ),
        ),
      ),
    );
  }

  static (Color, Color) _cores(
    BuildContext context,
    InspirationKind kind,
  ) => switch (kind) {
    InspirationKind.brincadeira => (
      context.cores.photoSoft,
      context.cores.photo,
    ),
    InspirationKind.passeio => (context.cores.accentSoft, context.cores.accent),
    InspirationKind.foto => (context.cores.photoSoft, context.cores.photo),
    InspirationKind.carta => (context.cores.letterSoft, context.cores.letter),
    InspirationKind.leitura => (
      context.cores.documentSoft,
      context.cores.document,
    ),
    InspirationKind.preparo => (
      context.cores.primarySoft,
      context.cores.primary,
    ),
    InspirationKind.rotina => (context.cores.videoSoft, context.cores.video),
    InspirationKind.cuidado => (context.cores.accentSoft, context.cores.accent),
  };
}

class _ArtPainter extends CustomPainter {
  _ArtPainter({
    required this.kind,
    required this.background,
    required this.shape,
    required this.seed,
  });

  final InspirationKind kind;
  final Color background;
  final Color shape;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final math.Random r = math.Random(seed);
    final Paint cheio = Paint()..color = shape.withValues(alpha: 0.55);
    final Paint tenue = Paint()..color = shape.withValues(alpha: 0.22);
    final Paint traco = Paint()
      ..color = shape.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    switch (kind) {
      // Bolas flutuando, de tamanhos diferentes.
      case InspirationKind.brincadeira:
        for (int i = 0; i < 7; i++) {
          canvas.drawCircle(
            Offset(
              size.width * (0.08 + r.nextDouble() * 0.86),
              size.height * (0.15 + r.nextDouble() * 0.7),
            ),
            6 + r.nextDouble() * 18,
            i.isEven ? tenue : cheio,
          );
        }

      // Colinas e um sol.
      case InspirationKind.passeio:
        canvas.drawCircle(
          Offset(size.width * 0.78, size.height * 0.3),
          20,
          cheio,
        );
        for (int i = 0; i < 2; i++) {
          final Path colina = Path()
            ..moveTo(-20, size.height)
            ..quadraticBezierTo(
              size.width * (0.2 + i * 0.35),
              size.height * (0.45 + i * 0.18),
              size.width + 20,
              size.height,
            )
            ..close();
          canvas.drawPath(colina, i == 0 ? tenue : cheio);
        }

      // Uma moldura, com um brilho no canto.
      case InspirationKind.foto:
        final Rect moldura = Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.52),
          width: size.width * 0.42,
          height: size.height * 0.56,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(moldura, const Radius.circular(10)),
          traco,
        );
        canvas.drawCircle(
          Offset(moldura.right - 14, moldura.top + 16),
          5,
          cheio,
        );
        canvas.drawCircle(
          Offset(size.width * 0.16, size.height * 0.3),
          14,
          tenue,
        );

      // Um envelope com linhas de texto saindo.
      case InspirationKind.carta:
        final Rect env = Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.55),
          width: size.width * 0.44,
          height: size.height * 0.46,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(env, const Radius.circular(8)),
          traco,
        );
        canvas.drawLine(env.topLeft, env.center, traco);
        canvas.drawLine(env.topRight, env.center, traco);
        for (int i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(size.width * 0.12, size.height * (0.28 + i * 0.16)),
            Offset(size.width * 0.24, size.height * (0.28 + i * 0.16)),
            traco,
          );
        }

      // Duas páginas abertas.
      case InspirationKind.leitura:
        final double cx = size.width / 2;
        final double topo = size.height * 0.28;
        final double base = size.height * 0.76;
        for (final int lado in <int>[-1, 1]) {
          final Path pagina = Path()
            ..moveTo(cx, topo)
            ..lineTo(cx + lado * size.width * 0.2, topo + 8)
            ..lineTo(cx + lado * size.width * 0.2, base)
            ..lineTo(cx, base - 8)
            ..close();
          canvas.drawPath(pagina, lado == -1 ? tenue : cheio);
        }
        canvas.drawLine(Offset(cx, topo), Offset(cx, base - 8), traco);

      // Bandeirinhas de festa.
      case InspirationKind.preparo:
        final Path corda = Path()
          ..moveTo(0, size.height * 0.22)
          ..quadraticBezierTo(
            size.width / 2,
            size.height * 0.46,
            size.width,
            size.height * 0.22,
          );
        canvas.drawPath(corda, traco);
        for (int i = 1; i < 7; i++) {
          final double t = i / 7;
          final double x = size.width * t;
          final double y =
              size.height * 0.22 + math.sin(t * math.pi) * size.height * 0.12;
          final Path bandeira = Path()
            ..moveTo(x - 9, y)
            ..lineTo(x + 9, y)
            ..lineTo(x, y + 22)
            ..close();
          canvas.drawPath(bandeira, i.isEven ? cheio : tenue);
        }

      // Arcos concêntricos, como um relógio suave.
      case InspirationKind.rotina:
        final Offset centro = Offset(size.width * 0.5, size.height * 0.58);
        for (int i = 3; i >= 1; i--) {
          canvas.drawCircle(
            centro,
            size.height * 0.16 * i,
            i.isOdd ? tenue : cheio,
          );
        }
        canvas.drawLine(
          centro,
          centro.translate(0, -size.height * 0.22),
          traco,
        );
        canvas.drawLine(centro, centro.translate(size.height * 0.14, 0), traco);

      // Um coração com ondas, como som.
      case InspirationKind.cuidado:
        final Offset c = Offset(size.width * 0.5, size.height * 0.5);
        final double s = size.height * 0.16;
        final Path coracao = Path()
          ..moveTo(c.dx, c.dy + s)
          ..cubicTo(
            c.dx - s * 2,
            c.dy - s * 0.4,
            c.dx - s * 0.6,
            c.dy - s * 1.5,
            c.dx,
            c.dy - s * 0.5,
          )
          ..cubicTo(
            c.dx + s * 0.6,
            c.dy - s * 1.5,
            c.dx + s * 2,
            c.dy - s * 0.4,
            c.dx,
            c.dy + s,
          )
          ..close();
        canvas.drawPath(coracao, cheio);
        for (int i = 1; i <= 2; i++) {
          canvas.drawArc(
            Rect.fromCircle(center: c, radius: s * (1.6 + i * 0.7)),
            -math.pi * 0.35,
            math.pi * 0.7,
            false,
            traco,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_ArtPainter old) =>
      old.kind != kind ||
      old.background != background ||
      old.shape != shape ||
      old.seed != seed;
}
