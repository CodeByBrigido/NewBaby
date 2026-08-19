// Escreve o TERMOS-DE-USO.md a partir do texto que o aplicativo mostra, para
// que os dois nunca sejam escritos duas vezes.
//
// Rodar com: dart run tool/gerar_termos.dart
//
// O `termos_test.dart` compara o arquivo no disco com o que esta ferramenta
// geraria, então esquecer de rodar isto quebra a suíte em vez de publicar
// termos diferentes dos que estão no aplicativo.

import 'dart:io';

import 'package:meu_bebe/core/l10n/terms_of_use.dart';

void main() {
  File('TERMOS-DE-USO.md').writeAsStringSync(termosEmMarkdown());
  stdout.writeln('TERMOS-DE-USO.md gerado.');
  stdout.writeln(
    'A página de docs/ sai do mesmo texto: rode também '
    'dart run tool/gerar_site.dart',
  );
}
