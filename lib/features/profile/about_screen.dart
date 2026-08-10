import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final Copy g = Copy.of(ref.watch(profileProvider).value);

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.about),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x24,
          Space.x24,
          Space.x24,
          Space.x32,
        ),
        children: <Widget>[
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.cores.primaryStrong,
                borderRadius: Radii.tileR(72),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: Space.x20),
          Text(
            S.appFullName,
            textAlign: TextAlign.center,
            style: text.titleLarge,
          ),
          const SizedBox(height: Space.x8),
          Text(
            S.appTagline,
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
          const SizedBox(height: Space.x32),
          SoftCard(child: Text(g.aboutStorage)),
          const SizedBox(height: Space.x20),
          const InfoNote(
            message:
                'Nenhuma foto passa por servidor nosso: elas vão direto do '
                'celular para o Google Drive.',
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: Space.x12),
          const InfoNote(
            message:
                'O aplicativo não enxerga o resto do seu Drive. A permissão '
                'que você concede dá acesso apenas aos arquivos que ele '
                'mesmo cria, todos dentro da pasta "Meu Bebê - Cápsula do '
                'Tempo". Suas outras pastas são invisíveis para ele.',
            icon: Icons.folder_off_outlined,
          ),
          const SizedBox(height: Space.x12),
          // A frase acima é verdadeira e é fácil de ler como se valesse para
          // tudo. Vale para os arquivos - e só. O índice fica num servidor
          // nosso, e quem confia o registro de um filho a um aplicativo tem o
          // direito de saber disso sem precisar procurar.
          const InfoNote(
            message:
                'O que fica no nosso servidor é o índice: nome, data de '
                'nascimento, peso, altura, datas e o texto das cartas. É o '
                'que faz a linha do tempo e a busca funcionarem. Você pode '
                'apagar tudo isso a qualquer momento, no seu perfil.',
            icon: Icons.storage_outlined,
          ),

          const SizedBox(height: Space.x20),
          SoftCard(
            onTap: () => context.push(Routes.privacy),
            child: Row(
              children: <Widget>[
                Icon(Icons.shield_outlined, color: context.cores.textSecondary),
                const SizedBox(width: Space.x16),
                const Expanded(child: Text('Política de privacidade')),
                Icon(Icons.chevron_right, color: context.cores.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: Space.x12),
          SoftCard(
            onTap: () => context.push(Routes.intro),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.slideshow_outlined,
                  color: context.cores.textSecondary,
                ),
                const SizedBox(width: Space.x16),
                const Expanded(child: Text('Rever a apresentação')),
                Icon(Icons.chevron_right, color: context.cores.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: Space.x32),
          const SectionHeader(title: 'Para a cápsula durar'),
          // O aviso que quase nenhum aplicativo dá, e que este precisa dar:
          // guardar vinte anos de memórias numa conta que pode ser apagada
          // por desuso é um risco real, e quem corre esse risco tem o direito
          // de saber por quem fez a promessa - não por um email genérico do
          // Google, dois anos depois.
          const SoftCard(
            child: Text(
              'O Google apaga contas que ficam dois anos sem uso, e junto vai '
              'o que estiver no Drive delas. Isso vale principalmente para '
              'quem criou uma conta só para a cápsula.\n\n'
              'Abrir este aplicativo de vez em quando já conta como uso, '
              'então não é preciso fazer nada além disso. Mesmo assim, se '
              'você passar quase um ano sem aparecer, o aplicativo avisa uma '
              'vez, e esse aviso pode ser desligado em Configurações.',
            ),
          ),
        ],
      ),
    );
  }
}
