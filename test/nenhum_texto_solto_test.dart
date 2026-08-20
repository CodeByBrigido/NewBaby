import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Nenhum texto visível escrito direto dentro de um widget.
///
/// Este arquivo existe porque a varredura à mão falhou. A tradução para o
/// inglês passou por todas as telas e ainda assim deixou "Pular",
/// "Continuar", "Faz um tempo", "Ler a postagem" e a idade inteira
/// (`1 ano, 9 meses e 17 dias`) em português, e isso só apareceu quando
/// alguém abriu o aplicativo em inglês e leu.
///
/// A guarda não usa lista de palavras portuguesas: essa foi justamente a
/// abordagem que deixou passar `'foto'`, `'carta'` e `'desenho'` no
/// singular. Ela olha para a **posição** do literal: se uma string está
/// sendo entregue a um widget que a desenha na tela, ela tem de vir de `S`
/// ou de `Copy`, seja lá em que língua estiver escrita.
void main() {
  /// Onde texto visível nunca deveria estar escrito à mão.
  ///
  /// `l10n/` fica de fora porque é lá que o texto mora, e os `_test` porque
  /// teste escreve o valor esperado à mão de propósito.
  final List<File> arquivos =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))
          .where((File f) => !f.path.contains('/l10n/'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

  /// Um literal entregue a um widget que o desenha.
  ///
  /// Pega `Text('x')`, `Text(\n  'x'`, e os parâmetros nomeados que viram
  /// texto na tela. Não pega `Routes.bucket('fotos', ...)` nem
  /// `map['nome']`, que são identificador e chave, não frase.
  final RegExp visivel = RegExp(
    r"(?:"
    r"\bText\(\s*'([^'\\]{2,})'"
    r"|\b(?:title|label|message|rotulo|titulo|botao|hint|helperText|"
    r"labelText|hintText|semanticLabel|tooltip|subtitle)\s*:\s*'([^'\\]{2,})'"
    r")",
  );

  /// As exceções, cada uma com o motivo escrito.
  ///
  /// Curta de propósito: cada linha aqui é uma promessa de que aquele texto
  /// nunca chega aos olhos de quem usa o aplicativo em outra língua.
  ///
  /// Está vazia, e é bom que continue: toda vez que ela cresce, alguém
  /// prometeu que um texto não chega à tela, e essa promessa é justamente o
  /// tipo de coisa que envelhece sem ninguém perceber.
  const Map<String, String> permitido = <String, String>{};

  test('nenhum literal visível fora da tabela de idioma', () {
    final List<String> achados = <String>[];

    for (final File arquivo in arquivos) {
      final List<String> linhas = arquivo.readAsLinesSync();
      for (int i = 0; i < linhas.length; i++) {
        final String linha = linhas[i];
        final String nua = linha.trimLeft();
        if (nua.startsWith('//') || nua.startsWith('*')) continue;

        for (final RegExpMatch m in visivel.allMatches(linha)) {
          final String texto = m.group(1) ?? m.group(2)!;
          if (permitido.containsKey(texto)) continue;
          // Sem palavra própria não há o que traduzir: sobra interpolação,
          // pontuação e número. `'$count'`, `'$title ($unit)'` e o `'3,250'`
          // que exemplifica o formato do peso não são frases.
          if (!_temPalavra(texto)) continue;
          achados.add('${arquivo.path}:${i + 1}  $texto');
        }
      }
    }

    expect(
      achados,
      isEmpty,
      reason:
          'Texto escrito direto no widget. Mova para `Textos` e chame por '
          '`S`, ou, se ele nunca aparece na tela, acrescente-o ao mapa '
          '`permitido` acima com o motivo:\n${achados.join('\n')}',
    );
  });

  test('a idade não é montada com palavra portuguesa fixa', () {
    // `1 ano, 9 meses e 17 dias` saía daqui, e era o texto português mais
    // visível do aplicativo inteiro: aparecia no topo do início, no perfil,
    // no menu lateral e em toda caixa de envio.
    final String fonte = File(
      'lib/core/utils/age_calculator.dart',
    ).readAsStringSync();

    for (final String palavra in <String>[
      "'dia'",
      "'dias'",
      "'mês'",
      "'meses'",
      "'ano'",
      "'anos'",
      "'semana'",
      "'semanas'",
      "'No nascimento'",
      "' e '",
    ]) {
      expect(
        fonte,
        isNot(contains(palavra)),
        reason: 'A idade voltou a ser montada em português: $palavra',
      );
    }
  });

  test('o enum do agrupamento não guarda o rótulo como campo', () {
    // Campo de enum precisa de valor constante, e constante congela a
    // língua na primeira leitura. `Periodo` já teve os nomes assim.
    final String fonte = File('lib/core/utils/periodo.dart').readAsStringSync();
    expect(fonte, isNot(contains("ano('")));
    expect(fonte, contains('String get plural'));
  });
}

/// Se sobra alguma palavra depois de tirar as interpolações.
///
/// `'$count'` vira vazio; `'Ver todas'` continua com duas palavras. É o que
/// separa um rótulo de um molde de número.
bool _temPalavra(String texto) {
  final String semInterpolacao = texto
      .replaceAll(RegExp(r'\$\{[^}]*\}'), ' ')
      .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), ' ');
  return RegExp('[A-Za-zÀ-ÿ]{2,}').hasMatch(semInterpolacao);
}
