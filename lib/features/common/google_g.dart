import 'package:flutter/material.dart';

/// O "G" do Google, com a geometria oficial.
///
/// Os quatro caminhos abaixo são **copiados sem alteração** do botão que o
/// Google publica na diretriz de identidade dele. Ficam como texto de
/// propósito, e não convertidos em chamadas de `Path`: assim dá para abrir a
/// página do Google e comparar caractere a caractere. Uma versão traduzida
/// à mão seria impossível de conferir, e a diretriz proíbe redesenhar a
/// marca.
///
/// O botão em volta é nosso, e isso é intencional: o aplicativo vai falar
/// mais de uma língua, e a peça que o Google entrega pronta traz o texto
/// dele em inglês. O que a diretriz exige que seja dele é o símbolo, e é
/// exatamente ele que está aqui.
class GoogleG extends StatelessWidget {
  const GoogleG({this.size = 20, super.key});

  final double size;

  /// O quadro em que os caminhos foram desenhados (`viewBox="0 0 48 48"`).
  static const double _quadro = 48;

  /// Aberto para o teste conferir que as quatro partes continuam lá e que
  /// nenhuma estoura o quadro. Sem isso, uma cópia truncada apareceria como
  /// marca cortada, sem erro nenhum.
  static List<(String, Color)> get partesParaTeste => _partes;

  /// Vermelho, azul, amarelo e verde, na ordem em que o Google os declara.
  static const List<(String, Color)> _partes = <(String, Color)>[
    (
      'M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z',
      Color(0xFFEA4335),
    ),
    (
      'M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z',
      Color(0xFF4285F4),
    ),
    (
      'M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z',
      Color(0xFFFBBC05),
    ),
    (
      'M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z',
      Color(0xFF34A853),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: const _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double lado = size.shortestSide;
    final double escala = lado / GoogleG._quadro;

    canvas.save();
    canvas.scale(escala);
    for (final (String dados, Color cor) in GoogleG._partes) {
      canvas.drawPath(
        interpretarCaminhoSvg(dados),
        Paint()
          ..color = cor
          ..isAntiAlias = true,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GoogleGPainter oldDelegate) => false;
}

/// Lê o atributo `d` de um `<path>` de SVG e devolve um [Path] do Flutter.
///
/// Cobre só o que os caminhos do Google usam: `M`, `L`, `H`, `V`, `C`, `S`,
/// `Z`, cada um na forma maiúscula (absoluta) e minúscula (relativa). Não é
/// um interpretador de SVG completo, e nem deveria ser: um que aceitasse
/// arcos e curvas quadráticas seria código que ninguém exercita.
///
/// Público para o teste poder verificar, contra valores calculados à mão,
/// que a leitura está certa. Um erro aqui não daria exceção: daria uma marca
/// torta, que é o tipo de coisa que passa por revisão de código.
Path interpretarCaminhoSvg(String dados) {
  final Path caminho = Path();
  final RegExp comandos = RegExp(r'([MmLlHhVvCcSsZz])([^MmLlHhVvCcSsZz]*)');
  final RegExp numeros = RegExp(r'-?\d*\.?\d+(?:[eE][-+]?\d+)?');

  double x = 0;
  double y = 0;
  // Último ponto de controle da curva anterior, que é o que o comando `S`
  // reflete para continuar suave.
  double controleX = 0;
  double controleY = 0;
  bool veioDeCurva = false;

  for (final RegExpMatch m in comandos.allMatches(dados)) {
    final String letra = m.group(1)!;
    final bool relativo = letra == letra.toLowerCase();
    final List<double> n = numeros
        .allMatches(m.group(2)!)
        .map((RegExpMatch v) => double.parse(v.group(0)!))
        .toList();

    switch (letra.toUpperCase()) {
      case 'M':
        // Pares depois do primeiro são linhas, como manda a especificação.
        for (int i = 0; i + 1 < n.length; i += 2) {
          final double px = relativo ? x + n[i] : n[i];
          final double py = relativo ? y + n[i + 1] : n[i + 1];
          if (i == 0) {
            caminho.moveTo(px, py);
          } else {
            caminho.lineTo(px, py);
          }
          x = px;
          y = py;
        }
        veioDeCurva = false;

      case 'L':
        for (int i = 0; i + 1 < n.length; i += 2) {
          x = relativo ? x + n[i] : n[i];
          y = relativo ? y + n[i + 1] : n[i + 1];
          caminho.lineTo(x, y);
        }
        veioDeCurva = false;

      case 'H':
        for (final double v in n) {
          x = relativo ? x + v : v;
          caminho.lineTo(x, y);
        }
        veioDeCurva = false;

      case 'V':
        for (final double v in n) {
          y = relativo ? y + v : v;
          caminho.lineTo(x, y);
        }
        veioDeCurva = false;

      case 'C':
        for (int i = 0; i + 5 < n.length; i += 6) {
          final double x1 = relativo ? x + n[i] : n[i];
          final double y1 = relativo ? y + n[i + 1] : n[i + 1];
          final double x2 = relativo ? x + n[i + 2] : n[i + 2];
          final double y2 = relativo ? y + n[i + 3] : n[i + 3];
          final double fx = relativo ? x + n[i + 4] : n[i + 4];
          final double fy = relativo ? y + n[i + 5] : n[i + 5];
          caminho.cubicTo(x1, y1, x2, y2, fx, fy);
          controleX = x2;
          controleY = y2;
          x = fx;
          y = fy;
        }
        veioDeCurva = true;

      case 'S':
        for (int i = 0; i + 3 < n.length; i += 4) {
          // Sem curva antes, o primeiro controle é o próprio ponto atual.
          final double x1 = veioDeCurva ? 2 * x - controleX : x;
          final double y1 = veioDeCurva ? 2 * y - controleY : y;
          final double x2 = relativo ? x + n[i] : n[i];
          final double y2 = relativo ? y + n[i + 1] : n[i + 1];
          final double fx = relativo ? x + n[i + 2] : n[i + 2];
          final double fy = relativo ? y + n[i + 3] : n[i + 3];
          caminho.cubicTo(x1, y1, x2, y2, fx, fy);
          controleX = x2;
          controleY = y2;
          x = fx;
          y = fy;
          veioDeCurva = true;
        }

      case 'Z':
        caminho.close();
        veioDeCurva = false;
    }
  }

  return caminho;
}
