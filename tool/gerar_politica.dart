// Escreve o POLITICA-DE-PRIVACIDADE.md a partir do texto que o aplicativo
// mostra, para que os dois nunca sejam escritos duas vezes.
//
// Rodar com: dart run tool/gerar_politica.dart
//
// O `politica_test.dart` compara o arquivo no disco com o que esta ferramenta
// geraria, então esquecer de rodar isto quebra a suíte em vez de publicar uma
// política diferente da que está no aplicativo.

import 'dart:io';

import 'package:meu_bebe/core/l10n/privacy_policy.dart';

void main() {
  File('POLITICA-DE-PRIVACIDADE.md').writeAsStringSync(politicaEmMarkdown());
  stdout.writeln('POLITICA-DE-PRIVACIDADE.md gerado.');
  stdout.writeln(
    'As páginas de docs/ saem do mesmo texto: rode também '
    'dart run tool/gerar_site.dart',
  );
}
