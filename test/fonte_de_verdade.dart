import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carrega a Plus Jakarta Sans para dentro do teste.
///
/// **Sem isto, toda medida de largura mente.** O `flutter test` desenha com
/// uma fonte substituta em que cada caractere ocupa exatamente um em: `i` e
/// `W` medem o mesmo. Um texto de nove letras a 13 px sai com 117 px de
/// largura no teste e com pouco mais de sessenta no aparelho.
///
/// Isso não é detalhe. Uma tela pode passar num teste que diz que o texto
/// quebra em três linhas e chegar impecável no aparelho, e o contrário
/// também: um limite calibrado na fonte falsa é um limite calibrado no lugar
/// errado. Quem decide layout por medida precisa medir com a fonte que a
/// pessoa vai ver.
///
/// Chame no `setUpAll` de qualquer teste que meça largura ou conte linhas.
Future<void> carregarFonteDeVerdade() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const Map<String, String> arquivos = <String, String>{
    'PlusJakartaSans': 'assets/fonts/PlusJakartaSans-Regular.ttf',
    'PlusJakartaSans-Medium': 'assets/fonts/PlusJakartaSans-Medium.ttf',
    'PlusJakartaSans-SemiBold': 'assets/fonts/PlusJakartaSans-SemiBold.ttf',
    'PlusJakartaSans-Bold': 'assets/fonts/PlusJakartaSans-Bold.ttf',
  };

  for (final MapEntry<String, String> e in arquivos.entries) {
    final File arquivo = File(e.value);
    if (!arquivo.existsSync()) continue;
    final FontLoader carregador = FontLoader(e.key)
      ..addFont(
        Future<ByteData>.value(ByteData.sublistView(arquivo.readAsBytesSync())),
      );
    await carregador.load();
  }
}

/// Carrega a fonte dos ícones do Material.
///
/// Só as imagens de prévia precisam disto. Sem ela todo `Icon` sai como um
/// quadrado vazio, o que não atrapalha teste de medida nenhum mas estraga
/// uma imagem feita justamente para alguém olhar e decidir.
///
/// O arquivo vem do próprio Flutter instalado na máquina, e não do projeto.
/// Quando não estiver lá, sai calada: uma prévia com quadrados no lugar dos
/// ícones ainda serve, e derrubar o teste por causa disso não serviria a
/// ninguém.
Future<void> carregarIconesDoMaterial() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final String? raiz = Platform.environment['FLUTTER_ROOT'] ?? _raizDoFlutter();
  if (raiz == null) return;

  final File arquivo = File(
    '$raiz/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!arquivo.existsSync()) return;

  final FontLoader carregador = FontLoader('MaterialIcons')
    ..addFont(
      Future<ByteData>.value(ByteData.sublistView(arquivo.readAsBytesSync())),
    );
  await carregador.load();
}

/// Onde o Flutter está, deduzido do executável que está rodando o teste.
String? _raizDoFlutter() {
  for (final String caminho in <String>['/opt/flutter', '/usr/local/flutter']) {
    if (Directory(caminho).existsSync()) return caminho;
  }
  return null;
}
