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
        title: Text(S.about),
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
          InfoNote(message: S.aboutPhotos, icon: Icons.lock_outline),
          const SizedBox(height: Space.x12),
          InfoNote(message: S.aboutScope, icon: Icons.folder_off_outlined),
          const SizedBox(height: Space.x12),
          // A frase acima é verdadeira e é fácil de ler como se valesse para
          // tudo. Vale para os arquivos - e só. O índice fica num servidor
          // nosso, e quem confia o registro de um filho a um aplicativo tem o
          // direito de saber disso sem precisar procurar.
          InfoNote(message: S.aboutIndex, icon: Icons.storage_outlined),

          const SizedBox(height: Space.x20),
          SoftCard(
            onTap: () => context.push(Routes.privacy),
            child: Row(
              children: <Widget>[
                Icon(Icons.shield_outlined, color: context.cores.textSecondary),
                const SizedBox(width: Space.x16),
                Expanded(child: Text(S.privacyPolicy)),
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
                Expanded(child: Text(S.reviewIntro)),
                Icon(Icons.chevron_right, color: context.cores.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: Space.x32),
          SectionHeader(title: S.aboutLastingTitle),
          // O aviso que quase nenhum aplicativo dá, e que este precisa dar:
          // guardar vinte anos de memórias numa conta que pode ser apagada
          // por desuso é um risco real, e quem corre esse risco tem o direito
          // de saber por quem fez a promessa - não por um email genérico do
          // Google, dois anos depois.
          SoftCard(child: Text(S.aboutInactivity)),
        ],
      ),
    );
  }
}
