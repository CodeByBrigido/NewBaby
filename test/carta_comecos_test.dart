import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/core/l10n/copy.dart';
import 'package:meu_bebe/core/l10n/strings.dart';
import 'package:meu_bebe/features/letters/letter_editor_screen.dart';
import 'package:meu_bebe/models/baby_gender.dart';
import 'package:meu_bebe/models/baby_profile.dart';

/// Os começos prontos da carta.
///
/// A parte difícil de escrever para um filho não é o tamanho do campo, é a
/// primeira frase. Estes testes cobrem as duas coisas que fariam a ajuda
/// virar estorvo: um começo que apaga o que já estava escrito e um começo
/// que gruda no fim da frase anterior.
void main() {
  group('os começos sugeridos', () {
    test('todos terminam em aberto, convidando a continuar', () {
      // Uma frase fechada convida a concordar e fechar o aplicativo; uma
      // frase pela metade convida a terminar.
      for (final String c in S.letterStarters) {
        expect(
          c.endsWith(' '),
          isTrue,
          reason: '"$c" precisa terminar com espaço, para emendar no que vem',
        );
        expect(
          c.trimRight().endsWith('.'),
          isFalse,
          reason: '"$c" não pode ser uma frase fechada',
        );
      }
    });

    test('não se repetem', () {
      expect(S.letterStarters.toSet(), hasLength(S.letterStarters.length));
    });

    test('nenhum usa travessão', () {
      // A mesma regra do resto do projeto.
      for (final String c in S.letterStarters) {
        expect(c, isNot(contains('—')));
      }
    });
  });

  group('a promessa embaixo do campo', () {
    test('fala do nome e do gênero da criança', () {
      final Copy g = Copy.of(
        BabyProfile(
          name: 'Maria Eduarda',
          birth: DateTime(2027, 1, 22),
          gender: BabyGender.girl,
        ),
      );
      expect(g.letterKeepsafe, contains('Maria'));
      expect(g.letterKeepsafe, contains('dela'));
    });

    test('sem cadastro, a frase não fica capenga', () {
      expect(Copy.generic.letterKeepsafe, isNot(contains('  ')));
      expect(Copy.generic.letterKeepsafe, contains('da criança'));
    });
  });

  group('pôr um começo no campo', () {
    test('no campo vazio, entra sem espaço nenhum na frente', () {
      final TextEditingValue r = comComeco(
        TextEditingValue.empty,
        'Quando você ler isto, ',
      );
      expect(r.text, 'Quando você ler isto, ');
      expect(r.selection.baseOffset, r.text.length);
    });

    test('não apaga o que já estava escrito', () {
      // O erro fácil aqui é trocar o texto inteiro, e quem tocasse por
      // curiosidade depois de escrever perderia a carta.
      const String jaEscrito = 'Você nasceu numa terça de chuva.';
      final TextEditingValue r = comComeco(
        const TextEditingValue(
          text: jaEscrito,
          selection: TextSelection.collapsed(offset: jaEscrito.length),
        ),
        'Hoje eu quero te contar sobre ',
      );
      expect(r.text, startsWith(jaEscrito));
      expect(r.text, contains('Hoje eu quero te contar sobre '));
    });

    test('separa por parágrafo em vez de grudar na frase anterior', () {
      const String jaEscrito = 'Você nasceu numa terça de chuva.';
      final TextEditingValue r = comComeco(
        const TextEditingValue(
          text: jaEscrito,
          selection: TextSelection.collapsed(offset: jaEscrito.length),
        ),
        'Hoje eu quero te contar sobre ',
      );
      expect(r.text, '$jaEscrito\n\nHoje eu quero te contar sobre ');
    });

    test('já em linha nova, não abre outro parágrafo', () {
      final TextEditingValue r = comComeco(
        const TextEditingValue(
          text: 'Primeira linha.\n\n',
          selection: TextSelection.collapsed(offset: 17),
        ),
        'Você ainda não sabe, mas ',
      );
      expect(r.text, 'Primeira linha.\n\nVocê ainda não sabe, mas ');
    });

    test('entra onde o cursor está, e não no fim', () {
      final TextEditingValue r = comComeco(
        const TextEditingValue(
          text: 'A\nB',
          selection: TextSelection.collapsed(offset: 2),
        ),
        'meio ',
      );
      expect(r.text, 'A\nmeio B');
    });

    test('substitui o trecho selecionado, como qualquer digitação', () {
      final TextEditingValue r = comComeco(
        const TextEditingValue(
          text: 'apagar isto',
          selection: TextSelection(baseOffset: 0, extentOffset: 11),
        ),
        'Quando você ler isto, ',
      );
      expect(r.text, 'Quando você ler isto, ');
    });

    test('o cursor para no fim do começo, pronto para continuar', () {
      const String comeco = 'Se eu pudesse te dizer uma só coisa, seria ';
      final TextEditingValue r = comComeco(TextEditingValue.empty, comeco);
      expect(r.selection.isCollapsed, isTrue);
      expect(r.selection.baseOffset, comeco.length);
    });
  });
}
