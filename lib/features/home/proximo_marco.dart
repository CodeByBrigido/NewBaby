import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_gender.dart';
import '../../models/capsule_pulse.dart';
import '../common/widgets.dart';

/// O próximo marco de idade, e quanto falta para ele.
///
/// Vem logo abaixo do "Faz um tempo", e os dois se completam: um olha para
/// trás, para o que anda parado, e este olha para a frente. Numa cápsula do
/// tempo, saber que faltam setenta e três dias para os dois anos é o que
/// transforma uma data em algo que dá para preparar.
///
/// Marco aqui é a mesma data redonda que a linha do tempo marca quando
/// alguém rola até o dia: a conta é a mesma, e por isso o cartão nunca
/// anuncia um dia que o histórico depois não celebra.
class CartaoDoProximoMarco extends StatelessWidget {
  const CartaoDoProximoMarco({
    required this.pulse,
    required this.genero,
    super.key,
  });

  final CapsulePulse pulse;

  /// Decide qual bolo aparece.
  final BabyGender? genero;

  @override
  Widget build(BuildContext context) {
    final ProximoMarco? marco = pulse.nextMilestone;
    if (marco == null) return const SizedBox.shrink();

    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(Space.x16),
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: Radii.cardR,
        boxShadow: Shadows.level1,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Sobrancelha('Próximo marco'),
                const SizedBox(height: Space.x12),
                Text(
                  marco.rotulo,
                  style: text.headlineSmall?.copyWith(
                    color: context.cores.textPrimary,
                  ),
                ),
                const SizedBox(height: Space.x8),
                Text(
                  // No próprio dia a contagem não faz sentido, e o que a
                  // pessoa quer ler é que chegou.
                  marco.ehHoje
                      ? 'É hoje!'
                      : 'Daqui a ${Fmt.count(marco.diasAte, "dia", "dias")}',
                  style: text.bodyMedium?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.x12),
          BoloDeAniversario(genero: genero),
        ],
      ),
    );
  }
}

/// O bolo do cartão.
///
/// Prefere a arte que estiver em `assets/marcos/`, e desenha um bolo em
/// código quando ela não estiver lá.
///
/// A ordem é essa, e não o contrário, por um motivo prático: a arte de
/// verdade é feita fora daqui e chega como arquivo, enquanto o desenho em
/// código existe para o cartão nunca ficar com um buraco. Com a reserva no
/// lugar, soltar os dois PNG na pasta passa a ser a única coisa necessária
/// para trocar a arte, sem tocar em código nenhum.
///
/// Cadastro sem sexo informado fica com o desenho: não há um terceiro
/// arquivo, e escolher um dos dois seria atribuir à criança um sexo que
/// ninguém informou.
class BoloDeAniversario extends StatelessWidget {
  const BoloDeAniversario({required this.genero, super.key, this.tamanho = 84});

  final BabyGender? genero;

  final double tamanho;

  /// O arquivo esperado para cada sexo, ou `null` quando não há um.
  static String? arteDe(BabyGender? genero) => switch (genero) {
    BabyGender.girl => 'assets/marcos/bolo-menina.png',
    BabyGender.boy => 'assets/marcos/bolo-menino.png',
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final String? arte = arteDe(genero);
    // O bolo vem sobre um fundo suave, e não solto no cartão branco.
    //
    // Dois andares dele são creme, e creme sobre branco não existe: sem esta
    // base o desenho perdia metade da silhueta e sobravam duas faixas
    // coloridas flutuando. É também o mesmo tratamento que a arte das
    // inspirações recebe, então os dois cartões da tela se parecem.
    return Container(
      width: tamanho,
      height: tamanho,
      padding: const EdgeInsets.all(Space.x8),
      decoration: BoxDecoration(
        color: context.cores.accentSoft,
        borderRadius: Radii.fieldR,
      ),
      child: arte == null
          ? CustomPaint(painter: _Bolo(cores: context.cores))
          : Image.asset(
              arte,
              fit: BoxFit.contain,
              // Sem o arquivo, o desenho entra no lugar. É o que permite
              // declarar a pasta vazia e ainda assim compilar e rodar.
              errorBuilder: (_, _, _) =>
                  CustomPaint(painter: _Bolo(cores: context.cores)),
            ),
    );
  }
}

class _Bolo extends CustomPainter {
  const _Bolo({required this.cores});

  final AppPalette cores;

  @override
  void paint(Canvas canvas, Size size) {
    final double l = size.width;
    final double a = size.height;

    final Paint creme = Paint()..color = cores.surfaceMuted;
    final Paint cor = Paint()..color = cores.primary;
    final Paint corForte = Paint()..color = cores.primaryDark;

    // O pratinho, primeiro, para os andares pousarem sobre ele.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(l * 0.5, a * 0.82),
        width: l * 0.94,
        height: a * 0.09,
      ),
      creme,
    );

    // Três andares, de baixo para cima, cada um mais estreito e mais escuro.
    //
    // A alternância entre creme e cor existe para o bolo se ler de longe: com
    // tudo da mesma cor, a silhueta vira um triângulo e o desenho some no
    // tamanho em que ele de fato aparece, que é o de um ícone.
    _andar(canvas, l, a, topo: 0.62, base: 0.82, largura: 0.78, tinta: creme);
    _faixa(canvas, l, a, topo: 0.68, base: 0.755, largura: 0.78, tinta: cor);
    _andar(canvas, l, a, topo: 0.46, base: 0.62, largura: 0.58, tinta: cor);
    _andar(
      canvas,
      l,
      a,
      topo: 0.32,
      base: 0.46,
      largura: 0.38,
      tinta: corForte,
    );

    // O coração, na faixa colorida do andar de baixo. Branco, e não o tom
    // suave da paleta: sobre a faixa cheia, o suave desaparecia.
    _coracao(
      canvas,
      Offset(l * 0.5, a * 0.718),
      l * 0.075,
      Paint()..color = cores.surface,
    );

    // A vela sai do andar de cima, e a chama fica acima dela.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(l * 0.46, a * 0.16, l * 0.08, a * 0.17),
        Radius.circular(l * 0.04),
      ),
      cor,
    );
    _chama(canvas, Offset(l * 0.5, a * 0.04), l * 0.05);
  }

  /// Um andar do bolo: um retângulo arredondado com o topo abaulado.
  void _andar(
    Canvas canvas,
    double l,
    double a, {
    required double topo,
    required double base,
    required double largura,
    required Paint tinta,
  }) {
    final Rect corpo = Rect.fromLTRB(
      l * (0.5 - largura / 2),
      a * topo,
      l * (0.5 + largura / 2),
      a * base,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(corpo, Radius.circular(l * 0.05)),
        tinta,
      )
      // A elipse do topo dá o volume sem precisar de sombra nem de gradiente.
      ..drawOval(
        Rect.fromCenter(
          center: Offset(l * 0.5, a * topo),
          width: l * largura,
          height: a * 0.07,
        ),
        tinta,
      );
  }

  /// A faixa colorida que atravessa um andar.
  void _faixa(
    Canvas canvas,
    double l,
    double a, {
    required double topo,
    required double base,
    required double largura,
    required Paint tinta,
  }) {
    canvas.drawRect(
      Rect.fromLTRB(
        l * (0.5 - largura / 2),
        a * topo,
        l * (0.5 + largura / 2),
        a * base,
      ),
      tinta,
    );
  }

  void _coracao(Canvas canvas, Offset centro, double r, Paint tinta) {
    final Path p = Path()
      ..moveTo(centro.dx, centro.dy + r * 0.45)
      ..cubicTo(
        centro.dx - r * 1.3,
        centro.dy - r * 0.35,
        centro.dx - r * 0.35,
        centro.dy - r * 1.05,
        centro.dx,
        centro.dy - r * 0.35,
      )
      ..cubicTo(
        centro.dx + r * 0.35,
        centro.dy - r * 1.05,
        centro.dx + r * 1.3,
        centro.dy - r * 0.35,
        centro.dx,
        centro.dy + r * 0.45,
      )
      ..close();
    canvas.drawPath(p, tinta);
  }

  /// A chama: uma gota, com um miolo mais claro.
  void _chama(Canvas canvas, Offset ponta, double r) {
    final Path fora = Path()
      ..moveTo(ponta.dx, ponta.dy)
      ..cubicTo(
        ponta.dx + r * 1.6,
        ponta.dy + r * 1.5,
        ponta.dx + r,
        ponta.dy + r * 3,
        ponta.dx,
        ponta.dy + r * 3,
      )
      ..cubicTo(
        ponta.dx - r,
        ponta.dy + r * 3,
        ponta.dx - r * 1.6,
        ponta.dy + r * 1.5,
        ponta.dx,
        ponta.dy,
      )
      ..close();

    canvas
      ..drawPath(fora, Paint()..color = AppPalette.warning)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(ponta.dx, ponta.dy + r * 2),
          width: r * 0.9,
          height: r * 1.4,
        ),
        Paint()..color = cores.drawing,
      );
  }

  @override
  bool shouldRepaint(_Bolo antigo) => antigo.cores != cores;
}
