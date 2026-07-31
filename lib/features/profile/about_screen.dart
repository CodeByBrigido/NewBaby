import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../common/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: <Widget>[
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(S.appName, textAlign: TextAlign.center, style: text.titleLarge),
          const SizedBox(height: 6),
          Text(
            S.appTagline,
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
          const SizedBox(height: 32),
          const SoftCard(
            child: Text(
              'As fotos, os vídeos e os documentos ficam guardados no Google '
              'Drive da própria conta dela, em pastas organizadas por idade. '
              'O aplicativo é só a maneira bonita de folhear tudo isso.\n\n'
              'Mesmo daqui a muitos anos, sem este aplicativo, o acervo '
              'continua lá — legível, organizado e dela.',
            ),
          ),
          const SizedBox(height: 20),
          const InfoNote(
            message:
                'Nenhuma foto passa por servidor nosso: elas vão direto do '
                'celular para o Google Drive.',
            icon: Icons.lock_outline,
          ),
        ],
      ),
    );
  }
}
