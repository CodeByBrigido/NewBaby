import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/age_calculator.dart';
import '../../models/baby_gender.dart';
import '../../models/baby_profile.dart';
import '../common/widgets.dart';

/// O painel do topo da tela inicial: a foto, o nome e a idade.
///
/// Substitui um cartão que trazia saudação, uma frase de ligação e a idade em
/// três blocos de texto, com a foto pequena de lado. Era muita palavra para a
/// primeira coisa que se vê ao abrir o aplicativo, e a foto, que é o que
/// importa ali, ficava do tamanho de um ícone.
///
/// Aqui a ordem se inverte: a criança vem primeiro e grande, e o texto é só o
/// que não dá para ver na foto, que é o nome e a idade de hoje.
///
/// A saudação saiu inteira. "Boa tarde" não diz nada sobre a criança, muda
/// três vezes por dia sem que nada tenha acontecido, e ocupava a linha mais
/// visível da tela.
class PainelDoBebe extends StatelessWidget {
  const PainelDoBebe({required this.profile, required this.idade, super.key});

  final BabyProfile profile;
  final Age idade;

  /// Metade da foto, e o que decide onde a onda cruza o painel.
  static const double _raio = 54;

  /// Folga acima da foto, dentro da faixa colorida.
  static const double _acima = Space.x24;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final AppPalette cores = context.cores;

    // A onda passa por trás da foto, e não acima nem abaixo dela: é o que faz
    // a foto pertencer aos dois lados do painel em vez de estar pousada sobre
    // um deles.
    const double divisa = _acima + _raio * 1.1;

    return ClipRRect(
      borderRadius: Radii.cardR,
      child: CustomPaint(
        painter: _FundoDoPainel(
          cores: cores,
          divisa: divisa,
          genero: profile.gender,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.x20,
            _acima,
            Space.x20,
            Space.x24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // O anel branco separa a foto do fundo colorido. Sem ele, uma
              // foto de fundo claro se dissolve na faixa e o recorte redondo
              // some.
              Container(
                padding: const EdgeInsets.all(Space.x4),
                decoration: BoxDecoration(
                  color: cores.surface,
                  shape: BoxShape.circle,
                  boxShadow: Shadows.level1,
                ),
                child: BabyAvatar(profile: profile, radius: _raio),
              ),
              const SizedBox(height: Space.x16),
              Text(
                profile.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.headlineSmall?.copyWith(color: cores.textPrimary),
              ),
              const SizedBox(height: Space.x4),
              Text(
                idade.detailedLabel(alwaysShowDays: true),
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: cores.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A faixa colorida, a onda e os enfeites atrás da foto.
///
/// Desenhado em código, e não uma imagem, por dois motivos. O aplicativo se
/// pinta conforme o sexo da criança, e uma arte fixa obrigaria a manter três
/// arquivos que sairiam de sincronia com a paleta na primeira vez que uma cor
/// mudasse. E o painel muda de largura entre um telefone e outro: um desenho
/// esticado perde a proporção dos enfeites, enquanto este se refaz na medida.
///
/// Todos os tons saem da paleta, com transparência. Nenhuma cor nova entra
/// aqui, que é o que mantém o painel dentro do Design System em vez de virar
/// uma ilha com regras próprias.
class _FundoDoPainel extends CustomPainter {
  const _FundoDoPainel({
    required this.cores,
    required this.divisa,
    required this.genero,
  });

  final AppPalette cores;

  /// Altura em que a faixa colorida termina, nas bordas do painel.
  final double divisa;

  final BabyGender? genero;

  @override
  void paint(Canvas canvas, Size size) {
    // A metade de baixo usa o tom suave da própria cor primária, e não o
    // `surfaceMuted`. Este último é papel, e é mentolado no tema do menino e
    // quente no da menina: sob a faixa colorida ele brigava com o topo em vez
    // de continuá-lo. O `primarySoft` é da mesma família da faixa nos três
    // temas, então o painel inteiro se lê como uma peça só.
    canvas.drawRect(Offset.zero & size, Paint()..color = cores.primarySoft);

    // A faixa sobe no meio e desce nas pontas, e é essa a direção que faz o
    // desenho funcionar: a parte de baixo forma uma colina, e a foto fica
    // pousada nela. Curvada ao contrário, a faixa engole a foto e o painel
    // volta a parecer um cabeçalho de formulário.
    final Path faixa = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, divisa)
      ..cubicTo(
        size.width * 0.72,
        divisa - 30,
        size.width * 0.28,
        divisa - 30,
        0,
        divisa,
      )
      ..close();
    canvas.drawPath(faixa, Paint()..color = cores.heroFill);

    canvas.save();
    canvas.clipPath(faixa);
    _enfeites(canvas, size);
    canvas.restore();
  }

  /// Estrelas, brilhos e bolinhas, sempre nos mesmos lugares.
  ///
  /// As posições são fracções da largura, e não pixels: assim o enfeite fica
  /// no mesmo lugar da composição em qualquer telefone. E são fixas, e não
  /// sorteadas, porque um fundo que muda a cada abertura chama atenção para
  /// si, e o que precisa ser olhado aqui é a foto.
  void _enfeites(Canvas canvas, Size size) {
    final Paint claro = Paint()..color = cores.surface.withValues(alpha: 0.42);
    final Paint suave = Paint()..color = cores.surface.withValues(alpha: 0.26);
    final double w = size.width;

    for (final (double x, double y, double r) in <(double, double, double)>[
      (0.10, 0.22, 11),
      (0.17, 0.52, 7),
      (0.88, 0.20, 12),
      (0.80, 0.55, 8),
    ]) {
      canvas.drawPath(_brilho(Offset(w * x, divisa * y), r), claro);
    }

    for (final (double x, double y, double r) in <(double, double, double)>[
      (0.24, 0.30, 5),
      (0.075, 0.72, 4),
      (0.93, 0.62, 4.5),
      (0.72, 0.24, 3.5),
    ]) {
      canvas.drawCircle(Offset(w * x, divisa * y), r, suave);
    }

    // Menino ganha nuvens na barra da faixa, menina ganha estrelas de cinco
    // pontas. É a diferença que as duas artes de referência tinham, e a única
    // coisa aqui que não vem só da paleta.
    if (genero == BabyGender.boy) {
      _nuvem(canvas, Offset(w * 0.09, divisa * 0.92), 26, suave);
      _nuvem(canvas, Offset(w * 0.90, divisa * 0.86), 21, suave);
    } else {
      canvas.drawPath(_estrela(Offset(w * 0.14, divisa * 0.86), 9), suave);
      canvas.drawPath(_estrela(Offset(w * 0.86, divisa * 0.92), 7), suave);
    }
  }

  /// Brilho de quatro pontas, com os lados côncavos.
  Path _brilho(Offset centro, double r) {
    final double c = r * 0.16;
    return Path()
      ..moveTo(centro.dx, centro.dy - r)
      ..quadraticBezierTo(
        centro.dx + c,
        centro.dy - c,
        centro.dx + r,
        centro.dy,
      )
      ..quadraticBezierTo(
        centro.dx + c,
        centro.dy + c,
        centro.dx,
        centro.dy + r,
      )
      ..quadraticBezierTo(
        centro.dx - c,
        centro.dy + c,
        centro.dx - r,
        centro.dy,
      )
      ..quadraticBezierTo(
        centro.dx - c,
        centro.dy - c,
        centro.dx,
        centro.dy - r,
      )
      ..close();
  }

  Path _estrela(Offset centro, double r) {
    final Path p = Path();
    for (int i = 0; i < 10; i++) {
      final double raio = i.isEven ? r : r * 0.44;
      final double a = -math.pi / 2 + i * math.pi / 5;
      final Offset ponto = Offset(
        centro.dx + raio * math.cos(a),
        centro.dy + raio * math.sin(a),
      );
      i == 0 ? p.moveTo(ponto.dx, ponto.dy) : p.lineTo(ponto.dx, ponto.dy);
    }
    return p..close();
  }

  void _nuvem(Canvas canvas, Offset base, double r, Paint tinta) {
    canvas
      ..drawCircle(base, r * 0.62, tinta)
      ..drawCircle(base.translate(r * 0.62, r * 0.12), r * 0.46, tinta)
      ..drawCircle(base.translate(-r * 0.60, r * 0.16), r * 0.40, tinta);
  }

  @override
  bool shouldRepaint(_FundoDoPainel antigo) =>
      antigo.cores != cores ||
      antigo.divisa != divisa ||
      antigo.genero != genero;
}
