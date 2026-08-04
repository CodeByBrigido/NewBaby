import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/family_access.dart';
import 'package:meu_bebe/state/providers.dart';

/// O interruptor entre "minha cápsula" e "a cápsula da minha neta".
///
/// Um provider de dados que voltar a ler o `uidProvider` direto faz a avó
/// abrir uma cápsula vazia com o nome dela. Não dá erro, não aparece em
/// nenhuma tela de log: só fica vazio. Estes testes existem para isso não
/// passar despercebido.
void main() {
  ProviderContainer container({FamilyLink? vinculo, String? uid = 'avo'}) {
    return ProviderContainer(
      overrides: [
        uidProvider.overrideWithValue(uid),
        familyLinkProvider.overrideWith(
          (Ref ref) => Stream<FamilyLink?>.value(vinculo),
        ),
      ],
    );
  }

  final FamilyLink vinculoComAAna = FamilyLink(
    ownerUid: 'ana',
    folderId: 'pasta-da-ana',
    email: 'avo@gmail.com',
    code: 'AB-CDEF-GHJK',
    createdAt: DateTime(2026, 8, 4),
  );

  test('sem vínculo, a cápsula é a própria', () async {
    final ProviderContainer c = container(uid: 'ana');
    addTearDown(c.dispose);
    // Riverpod 3 descarta o provider assim que ninguém observa, e um
    // `read` solto não conta como observar: sem esta assinatura o fluxo é
    // encerrado antes de emitir.
    c.listen(familyLinkProvider, (_, _) {});
    await c.read(familyLinkProvider.future);

    expect(c.read(capsuleOwnerProvider), 'ana');
    expect(c.read(capsuleRoleProvider), CapsuleRole.owner);
    expect(c.read(isReadOnlyProvider), isFalse);
  });

  test('com vínculo, a cápsula é a de quem convidou', () async {
    final ProviderContainer c = container(vinculo: vinculoComAAna);
    addTearDown(c.dispose);
    // Riverpod 3 descarta o provider assim que ninguém observa, e um
    // `read` solto não conta como observar: sem esta assinatura o fluxo é
    // encerrado antes de emitir.
    c.listen(familyLinkProvider, (_, _) {});
    await c.read(familyLinkProvider.future);

    // O ponto inteiro do compartilhamento: a conta é da avó, a cápsula é da
    // neta.
    expect(c.read(capsuleOwnerProvider), 'ana');
    expect(c.read(uidProvider), 'avo');
  });

  test('com vínculo, o modo é de leitura', () async {
    final ProviderContainer c = container(vinculo: vinculoComAAna);
    addTearDown(c.dispose);
    // Riverpod 3 descarta o provider assim que ninguém observa, e um
    // `read` solto não conta como observar: sem esta assinatura o fluxo é
    // encerrado antes de emitir.
    c.listen(familyLinkProvider, (_, _) {});
    await c.read(familyLinkProvider.future);

    expect(c.read(capsuleRoleProvider), CapsuleRole.family);
    expect(c.read(isReadOnlyProvider), isTrue);
  });

  test('sem ninguém logado, não há cápsula nenhuma', () async {
    final ProviderContainer c = container(uid: null);
    addTearDown(c.dispose);
    // Riverpod 3 descarta o provider assim que ninguém observa, e um
    // `read` solto não conta como observar: sem esta assinatura o fluxo é
    // encerrado antes de emitir.
    c.listen(familyLinkProvider, (_, _) {});
    await c.read(familyLinkProvider.future);

    expect(c.read(capsuleOwnerProvider), isNull);
  });

  test('enquanto o vínculo carrega, ninguém é dado como família', () {
    // Meio segundo de "sou dona" para quem é convidada seria só um instante
    // de tela errada. O contrário - meio segundo de modo leitura para quem é
    // dona - esconderia o botão de registrar bem na hora em que ela abriu o
    // aplicativo para registrar.
    final ProviderContainer c = ProviderContainer(
      overrides: [
        uidProvider.overrideWithValue('ana'),
        familyLinkProvider.overrideWith(
          (Ref ref) => const Stream<FamilyLink?>.empty(),
        ),
      ],
    );
    addTearDown(c.dispose);

    expect(c.read(familyLinkProvider).isLoading, isTrue);
    expect(c.read(isReadOnlyProvider), isFalse);
  });
}
