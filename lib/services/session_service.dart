import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/baby_profile.dart';
import 'auth_service.dart';
import 'drive_service.dart';
import 'firestore_service.dart';
import 'media_optimizer.dart';
import 'memory_repository.dart';
import 'notification_service.dart';
import 'thumbnail_service.dart';

/// O que fazer com a pasta da cápsula no Drive ao apagar a conta.
enum DriveDisposal {
  /// O acervo continua onde está, sob controle exclusivo da família.
  keep,

  /// A pasta vai para a lixeira do Drive, reversível por 30 dias.
  trash,
}

/// Encerrar a sessão e apagar a conta.
///
/// Existe separado do [AuthService] porque sair não é só derrubar o login: é
/// também não deixar no aparelho o que a próxima pessoa a pegá-lo não deveria
/// ver.
class SessionService {
  SessionService({
    required this.auth,
    required this.firestore,
    required this.drive,
    required this.memories,
    required this.optimizer,
    required this.thumbnails,
    required this.reminders,
  });

  final AuthService auth;
  final FirestoreService firestore;
  final DriveService drive;
  final MemoryRepository memories;
  final MediaOptimizer optimizer;
  final ThumbnailStore thumbnails;
  final ReminderScheduler reminders;

  /// Marca que o cache do Firestore deve ser descartado na próxima abertura.
  ///
  /// O `clearPersistence` do Firestore só pode rodar com o cliente parado -
  /// depois de `terminate()`, qualquer outra chamada na mesma instância lança
  /// exceção. Fazer isso no meio da sessão deixaria o aplicativo inutilizável
  /// até o próximo início. Então a limpeza fica agendada e acontece em
  /// [clearPendingCache], antes de o Firestore ser tocado.
  static const String _pendingCacheKey = 'limpar_cache_firestore';

  /// Chave das buscas recentes, que também some ao sair.
  static const String _recentSearchesKey = 'buscas_recentes';

  /// Chave da limpeza única do áudio, no aparelho.
  static const String _audioLimpoKey = 'limpeza.audio';

  /// Apaga o que sobrou da gravação de voz, uma vez por aparelho.
  ///
  /// O áudio saiu do produto, mas quem usou a versão de teste tem entradas
  /// gravadas. Elas precisam sair do índice, e não só deixar de ser criadas:
  /// `EntryType.fromId` cai em `photo` no que não reconhece, então uma
  /// gravação antiga viraria um cartão de foto com um `.m4a` dentro.
  ///
  /// A marca fica no aparelho e não na conta porque o custo de repetir é uma
  /// consulta que não acha nada, e o custo de não rodar é um cartão quebrado.
  /// Errar para o lado de rodar de novo é o barato aqui.
  Future<void> limparRestosDeAudio(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_audioLimpoKey) ?? false) return;

    try {
      final int quantas = await firestore.deleteEntriesOfType(uid, 'audio');
      if (quantas > 0) {
        debugPrint('Entradas de áudio removidas: $quantas');
      }

      // A pasta vai para a lixeira, e não para o nada: os arquivos são da
      // família e a lixeira do Drive dá trinta dias para alguém mudar de
      // ideia. Se ela falhar, o índice já está limpo e é isso que importa.
      final String? pasta = await firestore.folderId(uid, 'Áudios');
      if (pasta != null && pasta.isNotEmpty) {
        try {
          await drive.setTrashed(pasta, trashed: true);
        } on Object catch (e) {
          debugPrint('Pasta de áudio não foi para a lixeira: $e');
        }
      }
      await firestore.forgetFolderTree(uid, 'Áudios');

      await prefs.setBool(_audioLimpoKey, true);
    } on Object catch (e) {
      // Sem marca: a próxima abertura tenta de novo. Uma falha de rede aqui
      // não pode deixar a marca posta e o índice sujo para sempre.
      debugPrint('Limpeza do áudio adiada: $e');
    }
  }

  /// Encerra a sessão e apaga o que ficou no aparelho.
  Future<void> signOut() async {
    await _wipeLocalData();
    await auth.signOut();
  }

  /// Apaga a conta e todos os dados, dos dois lados.
  ///
  /// A ordem importa: o Firestore e o Drive precisam do login ainda válido,
  /// então a revogação e a exclusão da conta ficam por último.
  Future<void> deleteEverything({
    required String uid,
    required BabyProfile? profile,
    required DriveDisposal disposal,
  }) async {
    await firestore.deleteAllUserData(uid);

    final String? rootId = profile?.rootFolderId;
    if (disposal == DriveDisposal.trash &&
        rootId != null &&
        rootId.isNotEmpty) {
      try {
        await drive.setTrashed(rootId, trashed: true);
      } on Exception catch (e) {
        // O acervo é da família e está fora do nosso alcance por desenho: se
        // a lixeira falhar, a exclusão da conta segue mesmo assim.
        debugPrint('Não foi possível mandar a pasta para a lixeira: $e');
      }
    }

    await _wipeLocalData();
    await auth.disconnect();
    await auth.deleteAccount();
    await auth.signOut();
  }

  /// Tudo o que o aplicativo deixou gravado no aparelho.
  Future<void> _wipeLocalData() async {
    await thumbnails.clear();
    await optimizer.clearCaches();
    await memories.clearDownloads();

    // Os lembretes vão junto. Um aviso do aniversário de uma criança
    // chegando depois de a conta ter saído do aparelho seria, no melhor
    // caso, estranho - e no pior, doloroso para quem emprestou o celular.
    try {
      await reminders.cancelAll();
    } on Object catch (e) {
      debugPrint('Não deu para cancelar os lembretes: $e');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await ReminderPreferences(prefs).clear();
    await prefs.remove(_recentSearchesKey);
    await prefs.setBool(_pendingCacheKey, true);
  }

  /// Descarta o cache do Firestore quando há uma limpeza pendente.
  ///
  /// Chamado no início do aplicativo, antes da primeira consulta. É o único
  /// momento em que o `clearPersistence` é seguro - o cliente ainda não
  /// começou.
  ///
  /// O que está sendo apagado aqui não é pouco: o cache do Firestore guarda,
  /// em texto puro, o nome da criança, a data de nascimento, os registros de
  /// crescimento e o texto integral das cartas.
  ///
  /// [signedIn] evita um caso estreito de perda de dado: se alguém saiu e
  /// outra pessoa entrou sem fechar o aplicativo, a marca continua posta, e
  /// no próximo início o `clearPersistence` levaria junto as escritas que a
  /// segunda pessoa fez sem internet e que ainda estavam na fila. Com sessão
  /// ativa a limpeza é adiada - o próximo "Sair" volta a marcá-la.
  static Future<void> clearPendingCache({required bool signedIn}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_pendingCacheKey) != true) return;
      if (signedIn) return;

      await FirebaseFirestore.instance.clearPersistence();
      await prefs.remove(_pendingCacheKey);
    } on Exception catch (e) {
      // Uma limpeza que falha não pode impedir o aplicativo de abrir; a
      // marca continua e a próxima abertura tenta de novo.
      debugPrint('Cache do Firestore não pôde ser limpo agora: $e');
    }
  }
}
