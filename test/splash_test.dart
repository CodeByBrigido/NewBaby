import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/features/shell/splash_gate.dart';
import 'package:meu_bebe/state/providers.dart';

/// A abertura do aplicativo.
///
/// Ela cobre o aplicativo enquanto a sessão é restaurada. Sem isso, quem
/// abre com sessão salva vê o login piscar antes da linha do tempo, e quem
/// abre sem sessão vê a linha do tempo vazia piscar antes do login.
void main() {
  Widget harness(Stream<User?> sessao) => ProviderScope(
    overrides: [authStateProvider.overrideWith((Ref _) => sessao)],
    child: MaterialApp(
      home: const SplashGate(child: Scaffold(body: Text('o aplicativo'))),
    ),
  );

  testWidgets('cobre o aplicativo no primeiro quadro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(const Stream<User?>.empty()));
    await tester.pump();

    expect(find.byType(AberturaTela), findsOneWidget);
    // O conteúdo existe por baixo desde o começo: é isso que deixa o
    // roteador decidir a rota enquanto ninguém está vendo.
    expect(find.text('o aplicativo'), findsOneWidget);
  });

  testWidgets('não sai antes do tempo mínimo, mesmo com sessão pronta', (
    WidgetTester tester,
  ) async {
    // Sessão resolvida no primeiro quadro. Sem o piso de tempo, a marca
    // apareceria por dois quadros e pareceria falha, não abertura.
    await tester.pumpWidget(harness(Stream<User?>.value(null)));
    await tester.pump();
    await tester.pump(tempoMinimoDaAbertura - const Duration(milliseconds: 50));

    expect(tester.widget<AnimatedOpacity>(_opacidade).opacity, 1);
  });

  testWidgets('sai quando o tempo passa e a sessão responde', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(Stream<User?>.value(null)));
    await tester.pump();
    // `pumpAndSettle` não adianta um `Timer` pendente: o relógio só anda
    // com um `pump` de duração explícita.
    await tester.pump(tempoMinimoDaAbertura);
    await tester.pumpAndSettle();

    expect(tester.widget<AnimatedOpacity>(_opacidade).opacity, 0);
  });

  testWidgets('sai mesmo se a sessão nunca responder', (
    WidgetTester tester,
  ) async {
    // Rede ruim, ou o canal com o lado nativo travado. Sem o teto de tempo
    // isto seria uma tela parada para sempre, que é justamente o que a
    // abertura existe para evitar.
    await tester.pumpWidget(harness(const Stream<User?>.empty()));
    await tester.pump();
    await tester.pump(tempoMinimoDaAbertura);

    expect(tester.widget<AnimatedOpacity>(_opacidade).opacity, 1);

    await tester.pump(tempoMaximoDaAbertura);
    await tester.pumpAndSettle();

    expect(tester.widget<AnimatedOpacity>(_opacidade).opacity, 0);
  });

  testWidgets('depois de sair, não volta', (WidgetTester tester) async {
    // A sessão volta a "carregando" numa reconexão. Cobrir a tela de novo no
    // meio do uso seria pior que o problema que a abertura resolve.
    final StreamController<User?> sessao = StreamController<User?>();
    addTearDown(sessao.close);

    await tester.pumpWidget(harness(sessao.stream));
    sessao.add(null);
    await tester.pump();
    await tester.pump(tempoMinimoDaAbertura);
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(_opacidade).opacity, 0);

    sessao.addError(Exception('caiu a rede'));
    await tester.pumpAndSettle();

    expect(tester.widget<AnimatedOpacity>(_opacidade).opacity, 0);
  });
}

final Finder _opacidade = find.byType(AnimatedOpacity);
