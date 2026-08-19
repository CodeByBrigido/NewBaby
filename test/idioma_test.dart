import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/state/idioma_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fonte_de_verdade.dart';

/// A escolha de idioma.
///
/// Hoje ela só guarda a preferência: a interface continua em português, e a
/// tela diz isso. Guardar desde já é o que faz a tradução, quando chegar,
/// encontrar a resposta de cada pessoa em vez de perguntar de novo.
void main() {
  setUpAll(carregarFonteDeVerdade);

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('os idiomas oferecidos', () {
    test('são dois, e o código é o que o Flutter usa em Locale', () {
      expect(Idioma.values, hasLength(2));
      expect(Idioma.portugues.codigo, 'pt');
      expect(Idioma.ingles.codigo, 'en');
    });

    test('cada nome está escrito na própria língua', () {
      // Traduzir o nome do idioma esconde a opção de quem precisa dela: quem
      // não lê português procura por "English", não por "Inglês".
      expect(Idioma.portugues.nome, 'Português');
      expect(Idioma.ingles.nome, 'English');
    });

    test('código desconhecido cai no português, e não quebra', () {
      // Preferência gravada por uma versão futura, lida por uma antiga.
      expect(Idioma.deCodigo('de'), Idioma.portugues);
      expect(Idioma.deCodigo(null), Idioma.portugues);
      expect(Idioma.deCodigo(''), Idioma.portugues);
    });
  });

  group('a escolha', () {
    test('sem escolha guardada, segue o aparelho', () async {
      // Quem tem o celular em inglês via a apresentação e a tela de entrada
      // em português, e só conseguia trocar depois de já ter criado a conta.
      expect(IdiomaNotifier.doAparelho(const Locale('en')), Idioma.ingles);
      expect(
        IdiomaNotifier.doAparelho(const Locale('pt', 'BR')),
        Idioma.portugues,
      );
    });

    test('língua que não oferecemos cai no português', () {
      // O português é o texto original do produto, e é dele que as outras
      // línguas saem.
      expect(IdiomaNotifier.doAparelho(const Locale('de')), Idioma.portugues);
      expect(IdiomaNotifier.doAparelho(const Locale('ja')), Idioma.portugues);
    });

    test('a escolha guardada manda mais que o aparelho', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        IdiomaNotifier.chave: 'pt',
      });
      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(idiomaProvider);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(idiomaProvider), Idioma.portugues);
    });

    test('é lida do aparelho quando já existe', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        IdiomaNotifier.chave: 'en',
      });

      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(idiomaProvider);
      // O disco responde num microtask, e o provedor começa em português
      // para não piscar a tela de quem já escolheu.
      await Future<void>.delayed(Duration.zero);
      expect(c.read(idiomaProvider), Idioma.ingles);
    });

    test('sobrevive a fechar o aplicativo', () async {
      final ProviderContainer c = ProviderContainer();
      await c.read(idiomaProvider.notifier).escolher(Idioma.ingles);
      c.dispose();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(IdiomaNotifier.chave), 'en');

      // Uma sessão nova lê o que a anterior gravou.
      final ProviderContainer outra = ProviderContainer();
      addTearDown(outra.dispose);
      outra.read(idiomaProvider);
      await Future<void>.delayed(Duration.zero);
      expect(outra.read(idiomaProvider), Idioma.ingles);
    });

    test('preferência ilegível não derruba nada', () async {
      // A leitura roda solta, sem ninguém esperando por ela. Uma exceção aqui
      // não teria quem a pegasse, e derrubaria o quadro inteiro por causa de
      // uma preferência de idioma. Sem escolha legível, fica o que o aparelho
      // sugeriu.
      SharedPreferences.setMockInitialValues(<String, Object>{
        IdiomaNotifier.chave: 42,
      });

      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);
      final Idioma doAparelho = IdiomaNotifier.doAparelho();
      expect(c.read(idiomaProvider), doAparelho);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(idiomaProvider), doAparelho);
    });

    test('trocar de volta também é guardado', () async {
      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);

      await c.read(idiomaProvider.notifier).escolher(Idioma.ingles);
      await c.read(idiomaProvider.notifier).escolher(Idioma.portugues);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(IdiomaNotifier.chave), 'pt');
    });
  });
}
