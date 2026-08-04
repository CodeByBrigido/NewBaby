import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_bebe/models/entry.dart';
import 'package:meu_bebe/models/family_access.dart';

/// O compartilhamento familiar.
///
/// A parte que decide quem vê o quê mora no servidor, e é testada contra o
/// emulador em `firebase/teste`. O que sobra para cá são as regras que o
/// aplicativo aplica sozinho: o código que vai ser ditado por telefone, a
/// validade do convite, e a lista de tipos que **precisa** bater com a das
/// regras.
void main() {
  group('o código de convite', () {
    test('tem o formato de três pedaços', () {
      for (int i = 0; i < 200; i++) {
        expect(
          generateInviteCode(),
          matches(RegExp(r'^[A-Z0-9]{2}-[A-Z0-9]{4}-[A-Z0-9]{4}$')),
        );
      }
    });

    test('não usa nenhum caractere que se confunde ao ditar', () {
      // Uma avó de setenta anos vai ouvir este código por telefone. `0` e
      // `O`, `1` e `I` e `L` são a diferença entre entrar e desistir.
      const String proibidos = '01ILO';
      for (int i = 0; i < 500; i++) {
        final String codigo = generateInviteCode().replaceAll('-', '');
        for (final String c in proibidos.split('')) {
          expect(
            codigo.contains(c),
            isFalse,
            reason: '"$codigo" tem "$c", que se confunde ao ser ditado.',
          );
        }
      }
    });

    test('não repete na prática', () {
      final Set<String> vistos = <String>{
        for (int i = 0; i < 2000; i++) generateInviteCode(),
      };
      expect(vistos.length, 2000);
    });

    test('usa o gerador que lhe derem, para o teste ser determinístico', () {
      expect(generateInviteCode(Random(7)), generateInviteCode(Random(7)));
    });
  });

  group('a validade do convite', () {
    final DateTime agora = DateTime(2026, 8, 4, 10);

    FamilyInvite convite({
      required DateTime expiraEm,
      InviteStatus status = InviteStatus.pending,
    }) => FamilyInvite(
      code: 'AB-CDEF-GHJK',
      ownerUid: 'ana',
      folderId: 'pasta',
      email: 'avo@gmail.com',
      name: 'Vó Maria',
      createdAt: agora,
      expiresAt: expiraEm,
      status: status,
    );

    test('um convite novo serve', () {
      expect(
        convite(expiraEm: agora.add(const Duration(days: 3))).usableAt(agora),
        isTrue,
      );
    });

    test('um convite vencido não serve', () {
      expect(
        convite(
          expiraEm: agora.subtract(const Duration(minutes: 1)),
        ).usableAt(agora),
        isFalse,
      );
    });

    test('um convite já usado não serve de novo', () {
      expect(
        convite(
          expiraEm: agora.add(const Duration(days: 3)),
          status: InviteStatus.used,
        ).usableAt(agora),
        isFalse,
      );
    });

    test('um convite cancelado não serve', () {
      expect(
        convite(
          expiraEm: agora.add(const Duration(days: 3)),
          status: InviteStatus.revoked,
        ).usableAt(agora),
        isFalse,
      );
    });

    test('a validade é curta', () {
      // Um código que vale para sempre é um código que alguém acha numa
      // conversa antiga daqui a três anos.
      expect(inviteLifetime.inDays, lessThanOrEqualTo(14));
    });
  });

  group('o vínculo', () {
    test('grava sempre o papel de leitura, e nunca outro', () {
      final Map<String, Object?> mapa = FamilyLink(
        ownerUid: 'ana',
        folderId: 'pasta',
        email: 'avo@gmail.com',
        code: 'AB-CDEF-GHJK',
        createdAt: DateTime(2026, 8, 4),
      ).toMap();
      expect(mapa['role'], 'viewer');
    });

    test('um mapa sem dono não vira vínculo', () {
      // Vale como defesa: um documento pela metade não pode virar acesso a
      // uma cápsula qualquer.
      expect(FamilyLink.fromMap(null), isNull);
      expect(FamilyLink.fromMap(<String, Object?>{}), isNull);
      expect(FamilyLink.fromMap(<String, Object?>{'ownerUid': ''}), isNull);
    });
  });

  group('o que a família enxerga', () {
    test('cartas nunca', () {
      // Quem escreve para a filha ler aos dezoito anos não está escrevendo
      // para a família inteira.
      expect(EntryType.letter.isFamilyVisible, isFalse);
    });

    test('desenhos e áudios também não', () {
      expect(EntryType.drawing.isFamilyVisible, isFalse);
      expect(EntryType.audio.isFamilyVisible, isFalse);
    });

    test('fotos, vídeos, documentos, crescimento e nascimento sim', () {
      for (final EntryType t in <EntryType>[
        EntryType.birth,
        EntryType.photo,
        EntryType.video,
        EntryType.document,
        EntryType.growth,
      ]) {
        expect(t.isFamilyVisible, isTrue, reason: t.id);
      }
    });

    test('a lista bate exatamente com a das regras do servidor', () {
      // Se divergir, a consulta do familiar é recusada inteira pelo Firestore
      // e a linha do tempo dele fica vazia. Este teste é o que transforma um
      // erro silencioso em CI vermelho.
      expect(
        EntryType.familyVisible.map((EntryType t) => t.id).toSet(),
        <String>{'nascimento', 'foto', 'video', 'documento', 'crescimento'},
      );
    });
  });

  group('o lacre viaja sempre', () {
    test('uma entrada sem lacre grava o campo mesmo assim, valendo nulo', () {
      // No Firestore, campo ausente não é alcançado por filtro nenhum. Se
      // este campo sumir do documento, a memória some da linha do tempo da
      // família sem ninguém perceber.
      final Map<String, Object?> mapa = Entry(
        id: 'x',
        type: EntryType.photo,
        date: DateTime(2026, 8, 4),
        createdAt: DateTime(2026, 8, 4),
        ageDays: 10,
        bucketKey: 'S02',
        bucketName: 'Semana 02',
      ).toMap();
      expect(mapa.containsKey('lacradoAte'), isTrue);
      expect(mapa['lacradoAte'], isNull);
    });
  });
}
