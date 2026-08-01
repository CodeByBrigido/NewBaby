import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/features/shell/app_lock_gate.dart';
import 'package:meu_bebe/services/lock_service.dart';
import 'package:meu_bebe/state/lock_providers.dart';

/// Trava dublê: o aparelho de verdade não existe no teste.
class _FakeLock extends LockService {
  _FakeLock({required this.enabled, this.authOk = true});

  final bool enabled;
  final bool authOk;
  int prompts = 0;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled({required bool value}) async {}

  @override
  Future<bool> authenticate({required String reason}) async {
    prompts++;
    return authOk;
  }
}

void main() {
  Future<void> pumpGate(WidgetTester tester, LockService lock) async {
    await tester.pumpWidget(
      ProviderScope(
        // Sem o tipo explícito: o `flutter_riverpod` 3 não exporta `Override`.
        overrides: [lockServiceProvider.overrideWithValue(lock)],
        child: MaterialApp(
          home: AppLockGate(child: Scaffold(body: const Text('as memórias'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('a trava vem desligada', () {
    testWidgets('sem ela, o conteúdo aparece direto', (
      WidgetTester tester,
    ) async {
      final _FakeLock lock = _FakeLock(enabled: false);
      await pumpGate(tester, lock);

      expect(find.text('as memórias'), findsOneWidget);
      expect(find.text(S.lockedTitle), findsNothing);
      expect(
        lock.prompts,
        0,
        reason: 'Com a trava desligada, ninguém deveria ser incomodado.',
      );
    });
  });

  group('com a trava ligada', () {
    testWidgets('a tela trancada cobre o conteúdo quando não se confirma', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester, _FakeLock(enabled: true, authOk: false));

      expect(find.text(S.lockedTitle), findsOneWidget);
      expect(find.text(S.unlock), findsOneWidget);
    });

    testWidgets('confirmando, o conteúdo aparece', (WidgetTester tester) async {
      await pumpGate(tester, _FakeLock(enabled: true));

      expect(find.text(S.lockedTitle), findsNothing);
      expect(find.text('as memórias'), findsOneWidget);
    });

    testWidgets('o botão tenta de novo depois de uma recusa', (
      WidgetTester tester,
    ) async {
      final _FakeLock lock = _FakeLock(enabled: true, authOk: false);
      await pumpGate(tester, lock);

      expect(lock.prompts, 1);
      await tester.tap(find.text(S.unlock));
      await tester.pumpAndSettle();
      expect(lock.prompts, 2);
    });
  });

  group('escolher uma foto não pede a digital', () {
    // O seletor de fotos leva o aplicativo para segundo plano sem que a
    // pessoa tenha saído dele. Sem esta guarda, a trava dispararia no meio
    // da tarefa - e não protegeria nada, porque o aparelho está na mão.

    test(
      'a guarda fica de pé enquanto a tela do sistema está aberta',
      () async {
        expect(ExternalActivity.isOpen, isFalse);

        final Future<void> escolha = ExternalActivity.run(() async {
          expect(ExternalActivity.isOpen, isTrue);
          await Future<void>.delayed(Duration.zero);
          expect(ExternalActivity.isOpen, isTrue);
        });

        expect(ExternalActivity.isOpen, isTrue);
        await escolha;
        expect(ExternalActivity.isOpen, isFalse);
      },
    );

    test('uma falha no seletor não deixa a guarda presa', () async {
      await expectLater(
        ExternalActivity.run(() async => throw StateError('cancelou')),
        throwsStateError,
      );
      expect(
        ExternalActivity.isOpen,
        isFalse,
        reason: 'Presa, a trava nunca mais voltaria a funcionar na sessão.',
      );
    });

    test('duas telas aninhadas contam certo', () async {
      await ExternalActivity.run(() async {
        await ExternalActivity.run(() async {
          expect(ExternalActivity.isOpen, isTrue);
        });
        expect(
          ExternalActivity.isOpen,
          isTrue,
          reason: 'A externa ainda estava aberta.',
        );
      });
      expect(ExternalActivity.isOpen, isFalse);
    });
  });

  test('a folga de segundo plano é curta o bastante para proteger', () {
    // Trocar de app e voltar não deve pedir a digital; deixar o celular na
    // mesa e sair, sim.
    expect(LockService.grace, lessThanOrEqualTo(const Duration(minutes: 1)));
    expect(LockService.grace, greaterThan(Duration.zero));
  });
}
