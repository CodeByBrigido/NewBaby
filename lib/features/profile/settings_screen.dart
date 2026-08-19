import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/reminder.dart';
import '../../state/idioma_providers.dart';
import '../../state/lock_providers.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

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
      await ref.read(memoryRepositoryProvider).clearDownloads();
      if (mounted) showMessage(context, S.cacheCleared);
    } on Exception catch (e) {
      if (mounted) {
        showMessage(context, userMessage(e, context: S.clearCache));
      }
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.timeline),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x16,
          Space.x8,
          Space.x16,
          Space.x32,
        ),
        children: <Widget>[
          SectionHeader(title: S.optimization),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Fixed(
                  icon: Icons.photo_outlined,
                  title: 'Fotos',
                  value: S.photoMaxSide,
                ),
                Divider(height: 24),
                _Fixed(
                  icon: Icons.videocam_outlined,
                  title: S.videosLabel,
                  value: S.videoOptimizedShort,
                ),
                Divider(height: 24),
                _Fixed(
                  icon: Icons.phone_iphone,
                  title: S.originalFiles,
                  value: S.originalFilesNote,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.x12),
          InfoNote(message: S.optimizationNote),
          const SizedBox(height: Space.block),
          SectionHeader(title: S.languageSection),
          const _IdiomaTile(),
          const SizedBox(height: Space.x12),
          InfoNote(message: S.languageNote, icon: Icons.translate),
          const SizedBox(height: Space.block),
          SectionHeader(title: S.remindersSection),
          const _RemindersTile(),
          const SizedBox(height: Space.block),
          SectionHeader(title: S.lockSection),
          const _LockTile(),
          const SizedBox(height: Space.x12),
          InfoNote(message: S.lockNote, icon: Icons.lock_outline),
          const SizedBox(height: Space.block),
          SectionHeader(title: S.storageOnDevice),
          SoftCard(
            onTap: _clearing ? null : _clearCaches,
            child: Row(
              children: <Widget>[
                const Icon(Icons.cleaning_services_outlined),
                const SizedBox(width: Space.x16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.clearCache,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: Space.x4),
                      Text(
                        S.clearCacheBody,
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

/// As duas línguas, lado a lado.
///
/// Escolha visível em vez de uma linha que abre outra tela: são só duas
/// opções, e esconder duas opções atrás de um toque é um toque a mais para
/// nada.
class _IdiomaTile extends ConsumerWidget {
  const _IdiomaTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Idioma atual = ref.watch(idiomaProvider);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final Idioma idioma in Idioma.values) ...<Widget>[
            if (idioma != Idioma.values.first) const Divider(height: 24),
            _OpcaoDeIdioma(
              idioma: idioma,
              escolhido: idioma == atual,
              onTap: () => ref.read(idiomaProvider.notifier).escolher(idioma),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpcaoDeIdioma extends StatelessWidget {
  const _OpcaoDeIdioma({
    required this.idioma,
    required this.escolhido,
    required this.onTap,
  });

  final Idioma idioma;
  final bool escolhido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              // O nome de cada língua na própria língua: quem procura inglês
              // procura por "English", em qualquer tela.
              idioma.nome,
              style: text.titleSmall,
            ),
          ),
          if (escolhido)
            Icon(Icons.check, size: 20, color: context.cores.primaryDark),
        ],
      ),
    );
  }
}

/// A porta para a tela de lembretes, com o estado atual na própria linha.
///
/// O resumo aparece aqui para a resposta a "isso me manda notificação?" não
/// exigir entrar em lugar nenhum.
class _RemindersTile extends ConsumerWidget {
  const _RemindersTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReminderSettings ajuste = ref.watch(reminderSettingsProvider);

    return SoftCard(
      onTap: () => context.push(Routes.reminders),
      child: Row(
        children: <Widget>[
          Icon(
            ajuste.enabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
          ),
          const SizedBox(width: Space.x16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.remindersSection,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: Space.x4),
                Text(
                  ajuste.enabled
                      ? S.remindersSummaryFull(
                          ajuste.kinds.length,
                          ReminderKind.values.length,
                          ajuste.safeHour,
                        )
                      : S.remindersOff,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.cores.textSecondary),
        ],
      ),
    );
  }
}

/// A trava opcional, com o estado do aparelho levado em conta.
///
/// Num aparelho sem digital, rosto ou PIN configurado, a opção aparece
/// desabilitada com a explicação. Ligar uma trava que não abre seria trancar
/// a pessoa do lado de fora do próprio acervo.
class _LockTile extends ConsumerWidget {
  const _LockTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool supported = ref.watch(lockSupportedProvider).value ?? false;
    final AsyncValue<bool> enabled = ref.watch(lockEnabledProvider);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.fingerprint),
              const SizedBox(width: Space.x16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.lockTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: Space.x4),
                    Text(
                      supported ? S.lockBody : S.lockUnavailable,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.x8),
              Switch(
                value: enabled.value ?? false,
                onChanged: supported && !enabled.isLoading
                    ? (bool value) => _toggle(context, ref, value: value)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref, {
    required bool value,
  }) async {
    final bool ok = await ref
        .read(lockEnabledProvider.notifier)
        .set(value: value);
    if (!ok && context.mounted) showMessage(context, S.lockFailed);
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
        const SizedBox(width: Space.x16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: text.titleSmall),
              const SizedBox(height: Space.x4),
              Text(value, style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
