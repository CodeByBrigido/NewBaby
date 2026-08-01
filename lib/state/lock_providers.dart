import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/lock_service.dart';

final Provider<LockService> lockServiceProvider = Provider<LockService>(
  (Ref ref) => LockService(),
);

/// Se o aparelho tem como autenticar. `false` desabilita a opção na tela.
final FutureProvider<bool> lockSupportedProvider = FutureProvider<bool>(
  (Ref ref) => ref.watch(lockServiceProvider).isSupported(),
);

/// A preferência da pessoa, guardada no aparelho. Começa desligada.
final AsyncNotifierProvider<LockEnabled, bool> lockEnabledProvider =
    AsyncNotifierProvider<LockEnabled, bool>(LockEnabled.new);

class LockEnabled extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(lockServiceProvider).isEnabled();

  /// Liga ou desliga a trava.
  ///
  /// Para **ligar**, a pessoa confirma a biometria antes: é a prova de que a
  /// trava vai abrir depois. Ligar sem testar seria a maneira mais fácil de
  /// alguém se trancar do lado de fora do próprio acervo.
  ///
  /// Para **desligar** não pedimos nada: quem está aqui dentro já passou pela
  /// trava para chegar até esta tela.
  Future<bool> set({required bool value}) async {
    final LockService service = ref.read(lockServiceProvider);

    if (value) {
      final bool ok = await service.authenticate(
        reason: 'Confirme para ligar a trava do aplicativo.',
      );
      if (!ok) return false;
    }

    await service.setEnabled(value: value);
    state = AsyncData<bool>(value);
    return true;
  }
}
