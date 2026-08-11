// Escreve o EXCLUSAO-DE-CONTA.md a partir do texto em Dart, para que a
// página pública e o que o código faz nunca sejam escritos duas vezes.
//
// Rodar com: dart run tool/gerar_exclusao.dart
//
// O `exclusao_test.dart` compara o arquivo no disco com o que esta ferramenta
// geraria, então esquecer de rodar isto quebra a suíte em vez de publicar uma
// página que promete o que o aplicativo não faz.

import 'dart:io';

import 'package:meu_bebe/core/l10n/account_deletion.dart';

void main() {
  File('EXCLUSAO-DE-CONTA.md').writeAsStringSync(exclusaoEmMarkdown());
  stdout.writeln('EXCLUSAO-DE-CONTA.md gerado.');
  stdout.writeln(
    'As páginas de docs/ saem do mesmo texto: rode também '
    'dart run tool/gerar_site.dart',
  );
}
