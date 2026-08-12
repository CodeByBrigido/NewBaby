import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../models/inspiration.dart';
import 'inspiration_art.dart';

/// A imagem no alto de uma postagem, no cartão e na leitura.
///
/// A foto vem de `assets/inspiracoes/<id>.webp`, montado a partir do id da
/// postagem. Trocar a arte de uma delas é substituir o arquivo: não há campo
/// no catálogo nem linha de código para mexer.
///
/// Enquanto a foto não existe, entra a ilustração gerada de [InspirationArt].
/// Isso é o que permite escrever o texto de uma postagem hoje e mandar fazer
/// a arte depois, sem deixar a tela quebrada nesse meio-tempo, e sem que a
/// falta de um arquivo derrube a compilação.
class CapaDaPostagem extends StatelessWidget {
  const CapaDaPostagem({
    super.key,
    required this.inspiration,
    required this.height,
  });

  final Inspiration inspiration;
  final double height;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData tela = MediaQuery.of(context);

    return ClipRRect(
      borderRadius: Radii.fieldR,
      child: Image.asset(
        inspiration.coverAsset,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        // Decodificar no tamanho em que a imagem é desenhada. Sem isto, uma
        // capa de 1200 px ocuparia a memória inteira do quadro original para
        // preencher uma faixa de 108 px de altura, e a lista tem dezenas.
        cacheHeight: (height * tela.devicePixelRatio).round(),
        errorBuilder: (BuildContext context, Object _, StackTrace? _) =>
            InspirationArt(
              kind: inspiration.kind,
              seed: inspiration.id,
              height: height,
            ),
      ),
    );
  }
}
