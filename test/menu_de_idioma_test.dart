import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/core/theme/app_theme.dart';
import 'package:meu_bebe/features/profile/settings_screen.dart';
import 'package:meu_bebe/state/idioma_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fonte_de_verdade.dart';

/// O menu suspenso de idioma, nas Configurações.
///
/// Antes as seis línguas ficavam abertas na tela, e o teste de que a escolha
/// funcionava era olhar. Agora cinco delas só existem depois de um toque, e
/// "depois de um toque" é justamente o tipo de coisa que quebra em silêncio:
/// um menu que não abre parece um cartão inerte, e quem estiver com o
/// aplicativo na língua errada não tem por onde sair.
void main() {
  setUpAll(carregarFonteDeVerdade);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // `S` é global, e um teste que troca a língua a deixa trocada para o
    // seguinte. Voltar ao português aqui é o que mantém os quatro
    // independentes entre si.
    definirTextos(textosPt);
  });

  Future<void> abrirConfiguracoes(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: _Raiz()));
    await tester.pump();
  }

  testWidgets('fechado, mostra só a língua que está valendo', (
    WidgetTester tester,
  ) async {
    await abrirConfiguracoes(tester);

    // Sem escolha guardada, vale a língua do aparelho, e o teste não tem
    // como fixá-la: `doAparelho` lê o `PlatformDispatcher` de verdade, e não
    // o do binding. Perguntar a ela qual é evita um teste que depende da
    // locale que a máquina por acaso usar.
    final Idioma inicial = IdiomaNotifier.doAparelho();
    expect(find.text(inicial.nome), findsOneWidget);

    // As outras cinco não ocupam a tela enquanto ninguém pediu por elas.
    // É este o ponto do menu: a seção de idioma passou a caber numa linha.
    for (final Idioma outro in Idioma.values.where(
      (Idioma i) => i != inicial,
    )) {
      expect(find.text(outro.nome), findsNothing, reason: outro.nome);
    }

    // E a seta que conta que aquele cartão abre alguma coisa.
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('tocar no cartão abre as seis, na ordem do seletor', (
    WidgetTester tester,
  ) async {
    await abrirConfiguracoes(tester);

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    for (final Idioma idioma in Idioma.values) {
      expect(find.text(idioma.nome), findsWidgets, reason: idioma.nome);
    }

    // A ordem é a do enum, e é a que foi pedida: inglês primeiro.
    final List<String> naTela = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text t) => t.data ?? '')
        .where((String s) => Idioma.values.any((Idioma i) => i.nome == s))
        .toList();
    expect(naTela.first, Idioma.ingles.nome);
  });

  testWidgets('escolher no menu troca a língua do aplicativo', (
    WidgetTester tester,
  ) async {
    await abrirConfiguracoes(tester);

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    // `.last` porque o nome da língua ativa aparece duas vezes enquanto o
    // menu está aberto: no cartão, atrás, e no item do menu.
    await tester.tap(find.text(Idioma.alemao.nome).last);
    await tester.pumpAndSettle();

    // A tabela de idioma virou de fato, e não só o rótulo do cartão.
    expect(S.codigo, 'de');

    // O menu fechou, e o cartão agora conta a escolha nova.
    expect(find.text(Idioma.alemao.nome), findsOneWidget);
    expect(find.text(Idioma.portugues.nome), findsNothing);
  });

  testWidgets('a escolha sobrevive ao aplicativo fechar', (
    WidgetTester tester,
  ) async {
    await abrirConfiguracoes(tester);

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Idioma.italiano.nome).last);
    await tester.pumpAndSettle();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(IdiomaNotifier.chave), 'it');
  });
}

/// A mesma ligação que `app.dart` faz na raiz de verdade.
///
/// Sem ela o provedor troca e `S` não fica sabendo, porque quem aplica a
/// escolha à tabela global é a raiz que observa o idioma. Repetir as duas
/// linhas aqui é o que faz o teste cobrir a corrente inteira, do toque no
/// menu até o texto que a próxima tela vai ler.
class _Raiz extends ConsumerWidget {
  const _Raiz();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Idioma idioma = ref.watch(idiomaProvider);
    definirTextos(textosPara(idioma.codigo));

    return MaterialApp(
      theme: AppTheme.build(AppPalette.girl),
      home: const SettingsScreen(),
    );
  }
}
