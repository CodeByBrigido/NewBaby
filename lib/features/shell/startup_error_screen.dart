import '../../core/l10n/strings.dart';
import '../../core/theme/tokens.dart';
import 'package:flutter/material.dart';

/// A tela que aparece quando o aplicativo não conseguiu nem começar.
///
/// Existe porque a alternativa é pior: uma falha antes do `runApp` deixa o
/// Android com a tela **em branco**, sem mensagem, sem erro, sem nada. Quem
/// instalou não tem como saber se o aplicativo travou, se ainda está
/// carregando ou se veio quebrado.
///
/// Não depende de nada do resto do aplicativo - nem tema, nem textos, nem
/// providers - justamente porque é o que sobra quando o resto falhou.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFDF8F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.block),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: 44,
                  color: Color(0xFFD1585B),
                ),
                const SizedBox(height: Space.x20),
                Text(
                  S.startupFailedTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D3436),
                  ),
                ),
                const SizedBox(height: Space.x12),
                Text(
                  S.startupFirebaseHint,
                  style: TextStyle(fontSize: 14, color: Color(0xFF8A7C81)),
                ),
                const SizedBox(height: Space.x24),
                Text(
                  S.technicalDetail,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A7C81),
                  ),
                ),
                const SizedBox(height: Space.x8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Space.x16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6EFEA),
                      borderRadius: Radii.fieldR,
                    ),
                    child: SingleChildScrollView(
                      // Selecionável de propósito: é o texto que a pessoa
                      // precisa conseguir copiar para pedir ajuda.
                      child: SelectableText(
                        '$error',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFF3D3436),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Space.x12),
                const Text(
                  'Toque e segure no texto acima para copiar.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A7C81)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
