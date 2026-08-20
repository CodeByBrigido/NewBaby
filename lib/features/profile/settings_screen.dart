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
                  title: S.photos,
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

/// A escolha de idioma, num menu suspenso.
///
/// As seis línguas ficavam abertas, uma abaixo da outra. Custavam meia tela
/// de Configurações para uma escolha que se faz uma vez e quase nunca se
/// muda, e empurravam lembretes, trava e armazenamento para fora da primeira
/// dobra. O menu deixa à vista só a língua que está valendo.
///
/// Quem abre o menu é o **cartão inteiro**, com `showMenu`, e não um
/// `PopupMenuButton` envolvendo o cartão. A diferença aparece no toque: o
/// `PopupMenuButton` põe o próprio `InkWell` por fora, e o respingo dele
/// nasce atrás do cartão, que o cobre. Abrindo daqui, o cartão acende
/// sozinho, e o menu nasce com a largura dele, alinhado às duas bordas,
/// como um campo de formulário.
class _IdiomaTile extends ConsumerWidget {
  const _IdiomaTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Idioma atual = ref.watch(idiomaProvider);
    final TextTheme text = Theme.of(context).textTheme;

    return SoftCard(
      onTap: () => _abrir(context, ref, atual),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              // O nome de cada língua na própria língua: quem procura inglês
              // procura por "English", em qualquer tela.
              atual.nome,
              style: text.titleSmall,
            ),
          ),
          Icon(Icons.expand_more, color: context.cores.textSecondary),
        ],
      ),
    );
  }

  /// Abre a lista sob o cartão, com a largura dele.
  Future<void> _abrir(BuildContext context, WidgetRef ref, Idioma atual) async {
    final RenderBox cartao = context.findRenderObject()! as RenderBox;
    final RenderBox tela =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final Offset canto = cartao.localToGlobal(Offset.zero, ancestor: tela);

    final Idioma? escolhido = await showMenu<Idioma>(
      context: context,
      initialValue: atual,
      // Alinhado às duas bordas do cartão, e logo abaixo dele. O `0` de
      // baixo deixa o menu crescer para cima quando o cartão está perto do
      // rodapé, em vez de ficar espremido contra ele.
      position: RelativeRect.fromLTRB(
        canto.dx,
        canto.dy + cartao.size.height,
        tela.size.width - canto.dx - cartao.size.width,
        0,
      ),
      constraints: BoxConstraints(
        minWidth: cartao.size.width,
        maxWidth: cartao.size.width,
      ),
      items: <PopupMenuEntry<Idioma>>[
        for (final Idioma idioma in Idioma.values)
          PopupMenuItem<Idioma>(
            value: idioma,
            child: Row(
              children: <Widget>[
                // O mesmo par de ícones do menu de período da linha do
                // tempo: num menu, o círculo marcado diz "escolha uma
                // destas", que é o que está acontecendo aqui.
                Icon(
                  idioma == atual
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: idioma == atual
                      ? context.cores.primary
                      : context.cores.muted,
                ),
                const SizedBox(width: Space.x12),
                Text(idioma.nome),
              ],
            ),
          ),
      ],
    );

    // `context.mounted` porque entre abrir e escolher passa o tempo que a
    // pessoa levar: dá para sair da tela com o menu aberto.
    if (escolhido != null && context.mounted) {
      await ref.read(idiomaProvider.notifier).escolher(escolhido);
    }
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
