import 'dart:math' as math;

import 'package:flutter/material.dart';

/// O "G" do Google, desenhado.
///
/// Existe desenhado porque a marca não está no projeto como arquivo, e um
/// botão que fala em conta do Google sem o símbolo dela fica com cara de
/// genérico. As quatro cores são as oficiais.
///
/// **Se a marca oficial entrar no projeto, este arquivo sai.** A diretriz de
/// identidade do Google pede o arquivo dela para botões de entrar, e uma
/// reconstrução geométrica chega perto sem ser igual. Trocar é uma linha:
/// um `Image.asset` no lugar deste widget.
class GoogleG extends StatelessWidget {
  const GoogleG({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const Color _azul = Color(0xFF4285F4);
  static const Color _verde = Color(0xFF34A853);
  static const Color _amarelo = Color(0xFFFBBC05);
  static const Color _vermelho = Color(0xFFEA4335);

  /// Graus em radianos, com 0 apontando para a direita e crescendo no
  /// sentido do relógio, que é como o `drawArc` do Flutter mede.
  static double _rad(double graus) => graus * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final double lado = size.shortestSide;
    final Offset centro = Offset(lado / 2, lado / 2);

    // O anel do G é grosso: cerca de um quarto do lado. O raio usado no arco
    // é o do meio do traço, então ele fica entre o externo e o interno.
    final double traco = lado * 0.26;
    final double raio = (lado - traco) / 2;
    final Rect anel = Rect.fromCircle(center: centro, radius: raio);

    final Paint pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = traco;

    // Os quatro trechos, do vermelho no topo e seguindo o relógio. A soma
    // deixa de fora o pedaço à direita acima da barra: é a abertura do G,
    // e sem ela o desenho vira um "O" colorido.
    void trecho(Color cor, double inicio, double varredura) {
      canvas.drawArc(
        anel,
        _rad(inicio),
        _rad(varredura),
        false,
        pincel..color = cor,
      );
    }

    trecho(_vermelho, -128, 78);
    trecho(_azul, -18, 62);
    trecho(_verde, 44, 90);
    trecho(_amarelo, 134, 96);

    // A barra que fecha o G, saindo do centro para a direita. Ela nasce no
    // miolo e encosta na borda externa do anel, que é o que dá ao símbolo a
    // leitura de letra em vez de anel interrompido.
    final double meio = lado / 2;
    canvas.drawRect(
      Rect.fromLTRB(
        meio - lado * 0.02,
        meio - traco / 2,
        meio + raio + traco / 2,
        meio + traco / 2,
      ),
      Paint()..color = _azul,
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter oldDelegate) => false;
}
