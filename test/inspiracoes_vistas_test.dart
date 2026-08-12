import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/inspiration.dart';
import 'package:meu_bebe/services/inspiration_source.dart';
import 'package:meu_bebe/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O selo "Novo" das inspirações.
///
/// Ele dizia "você ainda não abriu isto". Quem nunca abria nenhuma via
/// "Novo" em **todas** as sugestões, para sempre, mesmo depois de fechar e
/// abrir o aplicativo várias vezes. Um selo que marca a lista inteira não
/// informa nada: é ruído com cara de aviso.
///
/// Agora ele responde outra pergunta, que é a que a pessoa faz ao olhar:
/// isto já estava aqui da última vez? Ler o título e decidir que aquilo não
/// era para hoje é uma resposta legítima, e não pode deixar a etiqueta
/// acesa até o fim dos tempos.
void main() {
  ActiveInspiration ativa(String id) => ActiveInspiration(
    inspiration: Inspiration(
      id: id,
      title: id,
      summary: id,
      kind: InspirationKind.brincadeira,
      anchor: const AgeAnchor(fromDays: 0, toDays: 99999),
    ),
    relevance: 1,
  );

  ProviderContainer comAtivas(List<String> ids) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        inspirationsProvider.overrideWith(
          (Ref _) async => ids.map(ativa).toList(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('o que já foi visto fica guardado no aparelho', () {
    test('começa vazio, e marcar acrescenta', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final InspiracoesVistas vistas = InspiracoesVistas(prefs);

      expect(vistas.ids, isEmpty);
      await vistas.marcar(<String>['a', 'b']);
      expect(vistas.ids, <String>{'a', 'b'});
    });

    test('marcar de novo não duplica, e o que existia continua', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final InspiracoesVistas vistas = InspiracoesVistas(prefs);

      await vistas.marcar(<String>['a']);
      await vistas.marcar(<String>['a', 'c']);
      expect(vistas.ids, <String>{'a', 'c'});
    });

    test('sobrevive ao fechar e abrir o aplicativo', () async {
      // É o cerne da queixa: fechar e abrir várias vezes e continuar vendo
      // "Novo" em tudo. O que dura entre aberturas é o disco, e é ele que
      // este teste exercita.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await InspiracoesVistas(prefs).marcar(<String>['a']);

      final SharedPreferences outraSessao =
          await SharedPreferences.getInstance();
      expect(InspiracoesVistas(outraSessao).ids, <String>{'a'});
    });

    test('é uma chave própria, e não a das lidas', () {
      // "Lida" alimenta os lembretes e significa consumir o conteúdo.
      // "Vista" é só o selo. Compartilhar a chave faria abrir um artigo
      // apagar o selo de outro, ou pior, um lembrete deixar de existir
      // porque a pessoa passou os olhos na lista.
      expect(InspiracoesVistas.chave, isNot(ReadInspirations.chave));
    });
  });

  group('o contador da aba conta o que chegou depois', () {
    test('na primeira vez, conta tudo', () async {
      final ProviderContainer c = comAtivas(<String>['a', 'b']);
      await c.read(inspirationsProvider.future);

      expect(c.read(unreadInspirationsProvider), 2);
    });

    test('depois de vistas, o contador zera', () async {
      // Sem isto, o número no rodapé era o mesmo para sempre, e um aviso
      // que nunca muda deixa de ser aviso.
      final ProviderContainer c = comAtivas(<String>['a', 'b']);
      await c.read(inspirationsProvider.future);

      await c.read(inspiracoesVistasProvider.notifier).marcar(<String>[
        'a',
        'b',
      ]);
      expect(c.read(unreadInspirationsProvider), 0);
    });

    test('uma ideia nova reacende o contador, e só ela', () async {
      final ProviderContainer c = comAtivas(<String>['a', 'b', 'c']);
      await c.read(inspirationsProvider.future);

      await c.read(inspiracoesVistasProvider.notifier).marcar(<String>[
        'a',
        'b',
      ]);
      expect(
        c.read(unreadInspirationsProvider),
        1,
        reason:
            'A criança fez três meses e uma ideia entrou: é essa, e só '
            'essa, que merece o aviso',
      );
    });
  });
}
