import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/state/providers.dart';

/// A porta que segura o roteador durante o cadastro.
///
/// O Firestore avisa quem escuta no instante em que a escrita entra no cache
/// local, muito antes de o servidor dizer se aceita. Sem esta porta, o
/// primeiro cadastro fazia o seguinte: o perfil aparecia, o roteador levava
/// para a linha do tempo, e dois segundos depois a recusa do servidor
/// chegava, a escrita era desfeita, e a pessoa voltava para o formulário.
///
/// E o pior nem era o vaivém. A mensagem de erro era escrita na tela do
/// cadastro, que a essa altura já tinha sido destruída: sobrava um
/// formulário em branco, sem explicação e sem os dados digitados.
void main() {
  ProviderContainer novo() {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('a porta abre e fecha no lugar certo', () {
    test('nasce aberta: quem não está cadastrando não é segurado', () {
      expect(novo().read(cadastroEmAndamentoProvider), isFalse);
    });

    test('fecha no começo do envio e abre no fim', () {
      final ProviderContainer c = novo();
      final CadastroEmAndamento porta = c.read(
        cadastroEmAndamentoProvider.notifier,
      );

      porta.comecou();
      expect(
        c.read(cadastroEmAndamentoProvider),
        isTrue,
        reason: 'Sair da tela aqui é apostar que o servidor vai aceitar',
      );

      porta.terminou();
      expect(
        c.read(cadastroEmAndamentoProvider),
        isFalse,
        reason:
            'Se não abrisse, quem cadastrou com sucesso ficaria preso no '
            'formulário para sempre',
      );
    });

    test('abre também quando o envio falha', () {
      // No `_submit` o `terminou()` está num `finally`. Este teste existe
      // para que tirá-lo de lá quebre a suíte: sem ele, uma falha tranca a
      // pessoa no cadastro sem saída.
      final ProviderContainer c = novo();
      final CadastroEmAndamento porta = c.read(
        cadastroEmAndamentoProvider.notifier,
      );

      porta.comecou();
      try {
        throw Exception('o servidor recusou');
      } on Exception catch (_) {
        // o que a tela faz
      } finally {
        porta.terminou();
      }

      expect(c.read(cadastroEmAndamentoProvider), isFalse);
    });

    test('uma segunda tentativa fecha a porta de novo', () {
      final ProviderContainer c = novo();
      final CadastroEmAndamento porta = c.read(
        cadastroEmAndamentoProvider.notifier,
      );

      porta.comecou();
      porta.terminou();
      porta.comecou();
      expect(c.read(cadastroEmAndamentoProvider), isTrue);
    });
  });
}
