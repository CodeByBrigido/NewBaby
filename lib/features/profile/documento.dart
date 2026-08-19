import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/privacy_policy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';

/// Os documentos longos do aplicativo: a política de privacidade e a
/// exclusão de conta.
///
/// Os dois são a mesma tela porque são a mesma coisa: uma lista de seções
/// escrita em Dart, que viaja dentro do pacote. Ler os termos não pode
/// depender de ter rede, e o que a pessoa lê é o texto daquela versão do
/// aplicativo, não o que estiver no ar hoje.
///
/// A versão pública em HTML, para quem já desinstalou, sai do mesmo texto
/// (`tool/gerar_site.dart`). Nunca há dois textos para manter de acordo.
class TelaDeDocumento extends StatelessWidget {
  const TelaDeDocumento({
    super.key,
    required this.titulo,
    required this.data,
    required this.secoes,
    this.abaixoDoTexto,
  });

  final String titulo;

  /// Data da última revisão, como a política e a página públicas mostram.
  final String data;

  final List<PrivacySection> secoes;

  /// O que vem depois da última seção, quando a tela oferece uma ação.
  final Widget? abaixoDoTexto;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Sem para onde voltar, vai para o Perfil. Quem chegou aqui pela
          // tela de entrada, sem conta, é levado de volta ao login pelo
          // próprio roteador, que é onde essa pessoa estava.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x24,
          Space.x8,
          Space.x24,
          Space.x40,
        ),
        children: <Widget>[
          Text('Meu Bebê: Cápsula do Tempo', style: text.headlineSmall),
          const SizedBox(height: Space.x4),
          Text(
            S.lastUpdated(data),
            style: text.bodySmall?.copyWith(color: context.cores.muted),
          ),
          const SizedBox(height: Space.x32),
          for (final PrivacySection secao in secoes) ...<Widget>[
            Text(secao.title, style: text.titleMedium),
            const SizedBox(height: Space.x12),
            for (final String paragrafo in secao.body)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.x12),
                child: ParagrafoDoDocumento(texto: paragrafo),
              ),
            const SizedBox(height: Space.x20),
          ],
          ?abaixoDoTexto,
        ],
      ),
    );
  }
}

/// Um parágrafo, ou um item de lista quando começa com marcador.
///
/// O item recuado à esquerda em vez de indentado com espaço: assim a segunda
/// linha alinha com a primeira e a lista continua legível quando o texto do
/// sistema está aumentado.
class ParagrafoDoDocumento extends StatelessWidget {
  const ParagrafoDoDocumento({super.key, required this.texto});

  final String texto;

  /// O pouco de marcação que os textos usam.
  ///
  /// Os documentos são escritos uma vez e saem em três lugares: aqui, no
  /// Markdown do repositório e na página HTML. O `**negrito**` é a notação
  /// dos outros dois; sem esta conversão, o aplicativo mostraria os
  /// asteriscos à vista.
  static final RegExp _negrito = RegExp(r'\*\*(.+?)\*\*');

  /// Quebra o parágrafo em trechos normais e trechos em negrito.
  static List<InlineSpan> pedacos(String texto, TextStyle? forte) {
    final List<InlineSpan> saida = <InlineSpan>[];
    int cursor = 0;
    for (final RegExpMatch m in _negrito.allMatches(texto)) {
      if (m.start > cursor) {
        saida.add(TextSpan(text: texto.substring(cursor, m.start)));
      }
      saida.add(TextSpan(text: m[1], style: forte));
      cursor = m.end;
    }
    if (cursor < texto.length) {
      saida.add(TextSpan(text: texto.substring(cursor)));
    }
    return saida;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? estilo = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: context.cores.textSecondary);
    final TextStyle forte = TextStyle(
      fontWeight: FontWeight.w600,
      color: context.cores.textPrimary,
    );

    final bool item = texto.startsWith('• ');
    final Widget corpo = Text.rich(
      TextSpan(children: pedacos(item ? texto.substring(2) : texto, forte)),
      style: estilo,
    );

    if (!item) return corpo;

    return Padding(
      padding: const EdgeInsets.only(left: Space.x8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('•', style: estilo),
          const SizedBox(width: Space.x8),
          Expanded(child: corpo),
        ],
      ),
    );
  }
}
