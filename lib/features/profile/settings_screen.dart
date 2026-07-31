import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _clearing = false;

  Future<void> _clearCaches() async {
    setState(() => _clearing = true);
    try {
      await ref.read(mediaOptimizerProvider).clearCaches();
      await ref.read(thumbnailServiceProvider).clear();
      if (mounted) showMessage(context, 'Cache limpo.');
    } on Exception catch (e) {
      if (mounted) showMessage(context, 'Não foi possível limpar: $e');
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          const SectionHeader(title: 'Otimização'),
          const SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Fixed(
                  icon: Icons.photo_outlined,
                  title: 'Fotos',
                  value: 'Metade da resolução original',
                ),
                Divider(height: 24),
                _Fixed(
                  icon: Icons.videocam_outlined,
                  title: 'Vídeos',
                  value: '720p com bitrate otimizado',
                ),
                Divider(height: 24),
                _Fixed(
                  icon: Icons.phone_iphone,
                  title: 'Arquivos originais',
                  value: 'Continuam no celular, intactos',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const InfoNote(
            message:
                'A otimização é automática e não pode ser desligada — é o '
                'que mantém o acervo leve por muitos anos.',
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Armazenamento no aparelho'),
          SoftCard(
            onTap: _clearing ? null : _clearCaches,
            child: Row(
              children: <Widget>[
                const Icon(Icons.cleaning_services_outlined),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Limpar cache',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Apaga miniaturas e arquivos temporários. Nada é '
                        'perdido: tudo continua no Google Drive.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (_clearing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fixed extends StatelessWidget {
  const _Fixed({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Icon(icon, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: text.titleSmall),
              const SizedBox(height: 2),
              Text(value, style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
