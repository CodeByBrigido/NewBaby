import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../services/lock_service.dart';
import '../../state/lock_providers.dart';

/// Cobre o aplicativo inteiro enquanto a trava opcional estiver fechada.
///
/// Quando a trava está desligada - que é o padrão - este widget não faz nada
/// além de devolver o filho.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _locked = false;
  bool _prompting = false;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockIfEnabled();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // `inactive` fica de fora: ele dispara com a barra de notificações
        // puxada e com a própria caixa da biometria aberta.
        //
        // A decisão é tomada aqui, e não na volta: neste instante a guarda de
        // atividade externa comprovadamente está de pé, enquanto na retomada
        // a ordem entre o evento e o resultado do seletor não é garantida.
        if (!ExternalActivity.isOpen) _pausedAt = DateTime.now();
      case AppLifecycleState.resumed:
        final DateTime? paused = _pausedAt;
        _pausedAt = null;
        if (paused == null) return;
        if (DateTime.now().difference(paused) < LockService.grace) return;
        _lockIfEnabled();
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _lockIfEnabled() async {
    if (_locked) return;
    if (!await ref.read(lockServiceProvider).isEnabled()) return;
    if (!mounted) return;
    setState(() => _locked = true);
    await _unlock();
  }

  Future<void> _unlock() async {
    if (_prompting) return;
    _prompting = true;
    try {
      final bool ok = await ref
          .read(lockServiceProvider)
          .authenticate(reason: S.lockReason);
      if (ok && mounted) setState(() => _locked = false);
    } finally {
      _prompting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        if (_locked)
          // Por cima de tudo, e opaco: sem isto o conteúdo apareceria por
          // baixo e na pré-visualização de aplicativos recentes.
          Positioned.fill(child: _LockScreen(onUnlock: _unlock)),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});

  final Future<void> Function() onUnlock;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: context.cores.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: context.cores.primarySoft,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: context.cores.primaryDark,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  S.lockedTitle,
                  style: text.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  S.lockedBody,
                  style: text.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onUnlock,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text(S.unlock),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
