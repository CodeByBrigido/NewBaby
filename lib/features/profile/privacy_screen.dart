import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/privacy_policy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';

/// A política de privacidade, dentro do aplicativo.
///
/// O texto vem de [privacyPolicy], que viaja no pacote: quem está decidindo
/// se confia o registro de um filho a um aplicativo consegue ler os termos
/// sem rede, e lê os termos daquela versão, não os que estiverem no ar hoje.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de privacidade'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            'Última atualização: $privacyPolicyDate',
            style: text.bodySmall?.copyWith(color: context.cores.muted),
          ),
          const SizedBox(height: Space.x32),
          for (final PrivacySection secao in privacyPolicy) ...<Widget>[
            Text(secao.title, style: text.titleMedium),
            const SizedBox(height: Space.x12),
            for (final String paragrafo in secao.body)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.x12),
                child: _Paragrafo(texto: paragrafo),
              ),
            const SizedBox(height: Space.x20),
          ],
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
class _Paragrafo extends StatelessWidget {
  const _Paragrafo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final TextStyle? estilo = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: context.cores.textSecondary);

    if (!texto.startsWith('• ')) return Text(texto, style: estilo);

    return Padding(
      padding: const EdgeInsets.only(left: Space.x8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('•', style: estilo),
          const SizedBox(width: Space.x8),
          Expanded(child: Text(texto.substring(2), style: estilo)),
        ],
      ),
    );
  }
}
