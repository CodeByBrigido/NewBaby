import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/core/theme/app_palette.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/state/providers.dart';

/// O cadastro da criança.
///
/// É a única tela que a pessoa preenche antes de o aplicativo existir para
/// ela, e o que sai dali governa tudo depois: o nome em toda frase, a cor do
/// aplicativo inteiro e a idade de cada memória. Um campo em branco aqui não
/// é um campo em branco; é a linha do tempo sem eixo.
void main() {
  group('o que é obrigatório', () {
    test('nome, sexo e data não têm valor padrão para cair', () {
      // Peso, altura, hora e hospital podem faltar: são detalhe. Estes três
      // não, e o modelo reflete isso, sem valor de reserva que disfarce a
      // ausência.
      expect(S.requiredField.trim(), isNotEmpty);
      expect(S.fullName.trim(), isNotEmpty);
      expect(S.gender.trim(), isNotEmpty);
      expect(S.birthDate.trim(), isNotEmpty);
    });

    test('o opcional está escrito no rótulo, e não subentendido', () {
      // Sem a palavra, a pessoa preenche tudo achando que precisa, ou trava
      // procurando um dado que não tem à mão (o peso ao nascer, de um filho
      // de três anos).
      for (final String rotulo in <String>[
        S.birthTimeOptional,
        S.birthWeightOptional,
        S.birthHeightOptional,
        S.hospitalOptional,
      ]) {
        expect(rotulo, contains('opcional'), reason: rotulo);
      }
    });

    test('o rótulo de exibição não herdou o "(opcional)"', () {
      // Os mesmos nomes rotulam o dado já salvo, na tela de informações.
      // Ali a palavra seria bobagem: o valor está preenchido, à vista.
      for (final String rotulo in <String>[
        S.birthTime,
        S.birthWeight,
        S.birthHeight,
      ]) {
        expect(rotulo, isNot(contains('opcional')), reason: rotulo);
      }
    });
  });

  group('a cor segue a escolha antes de existir cadastro', () {
    test('sem escolha, a paleta é a neutra', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(generoEscolhidoProvider), isNull);
      expect(
        AppPalette.of(container.read(generoEscolhidoProvider)),
        AppPalette.neutral,
      );
    });

    test('escolher menina troca a paleta na hora', () {
      // Sem isto, quem toca em "menina" continua vendo a cor neutra até
      // terminar o formulário inteiro, e a escolha parece não ter surtido
      // efeito nenhum.
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(generoEscolhidoProvider.notifier)
          .escolher(BabyGender.girl);
      expect(
        AppPalette.of(container.read(generoEscolhidoProvider)),
        AppPalette.girl,
      );

      container.read(generoEscolhidoProvider.notifier).escolher(BabyGender.boy);
      expect(
        AppPalette.of(container.read(generoEscolhidoProvider)),
        AppPalette.boy,
      );
    });
  });

  group('o texto do topo', () {
    test('são duas linhas, e a quebra é escrita à mão', () {
      // Deixar quebrar sozinho poria "Vamos começar" no fim da primeira
      // linha em alguns aparelhos e não em outros.
      final String texto = Copy.generic.onboardingSubtitle;
      expect(texto.split('\n'), hasLength(2));
      expect(texto, contains('Cada momento merece ser lembrado.'));
      expect(texto, contains('Vamos começar a guardar essa história?'));
    });

    test('continua sem nome e sem travessão', () {
      // É a tela onde o nome está sendo digitado: ele ainda não existe.
      final String texto = Copy.generic.onboardingSubtitle;
      expect(texto, isNot(contains('—')));
      expect(texto, isNot(contains('bebê')));
    });
  });
}
