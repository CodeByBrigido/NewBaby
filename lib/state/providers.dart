import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/baby_profile.dart';
import '../models/entry.dart';
import '../services/auth_service.dart';
import '../services/drive_service.dart';
import '../services/firestore_service.dart';
import '../services/media_optimizer.dart';
import '../services/memory_repository.dart';
import '../services/session_service.dart';
import '../services/thumbnail_service.dart';

/// Chave do Scaffold da casca do aplicativo.
///
/// As telas internas (Início, Linha do Tempo) têm o próprio Scaffold, então
/// `Scaffold.of(context)` acharia o Scaffold errado — o de dentro, que não
/// tem menu lateral. A chave dá acesso direto ao Scaffold externo, que é o
/// dono do menu.
final Provider<GlobalKey<ScaffoldState>> shellScaffoldKeyProvider =
    Provider<GlobalKey<ScaffoldState>>(
      (Ref ref) => GlobalKey<ScaffoldState>(debugLabel: 'casca'),
    );

// ------------------------------------------------------------- serviços

final Provider<AuthService> authServiceProvider = Provider<AuthService>(
  (Ref ref) => AuthService(),
);

final Provider<DriveService> driveServiceProvider = Provider<DriveService>(
  (Ref ref) => DriveService(ref.watch(authServiceProvider)),
);

final Provider<FirestoreService> firestoreServiceProvider =
    Provider<FirestoreService>(
      (Ref ref) => FirestoreService(FirebaseFirestore.instance),
    );

final Provider<MediaOptimizer> mediaOptimizerProvider =
    Provider<MediaOptimizer>((Ref ref) => MediaOptimizer());

final Provider<ThumbnailStore> thumbnailServiceProvider =
    Provider<ThumbnailStore>(
      (Ref ref) => ThumbnailService(ref.watch(driveServiceProvider)),
    );

final Provider<MemoryRepository> memoryRepositoryProvider =
    Provider<MemoryRepository>((Ref ref) {
      final MemoryRepository repository = MemoryRepository(
        firestore: ref.watch(firestoreServiceProvider),
        drive: ref.watch(driveServiceProvider),
        optimizer: ref.watch(mediaOptimizerProvider),
        thumbnails: ref.watch(thumbnailServiceProvider),
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

/// Sair e apagar a conta — os dois caminhos que precisam falar com todos os
/// serviços ao mesmo tempo.
final Provider<SessionService> sessionServiceProvider =
    Provider<SessionService>(
      (Ref ref) => SessionService(
        auth: ref.watch(authServiceProvider),
        firestore: ref.watch(firestoreServiceProvider),
        drive: ref.watch(driveServiceProvider),
        memories: ref.watch(memoryRepositoryProvider),
        optimizer: ref.watch(mediaOptimizerProvider),
        thumbnails: ref.watch(thumbnailServiceProvider),
      ),
    );

// ------------------------------------------------------------------ auth

final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (Ref ref) => ref.watch(authServiceProvider).authStateChanges,
);

/// Uid da conta em uso, ou `null` quando ninguém entrou.
final Provider<String?> uidProvider = Provider<String?>((Ref ref) {
  return ref.watch(authStateProvider).value?.uid;
});

// --------------------------------------------------------------- perfil

/// Cadastro da bebê. `null` significa "ainda não passou pelo onboarding".
final StreamProvider<BabyProfile?> profileProvider =
    StreamProvider<BabyProfile?>((Ref ref) {
      final String? uid = ref.watch(uidProvider);
      if (uid == null) return Stream<BabyProfile?>.value(null);
      return ref.watch(firestoreServiceProvider).watchProfile(uid);
    });

// -------------------------------------------------------------- entradas

/// Todas as memórias ativas, já ordenadas da mais recente para a mais antiga.
final StreamProvider<List<Entry>> entriesProvider = StreamProvider<List<Entry>>(
  (Ref ref) {
    final String? uid = ref.watch(uidProvider);
    if (uid == null) return Stream<List<Entry>>.value(const <Entry>[]);
    return ref.watch(firestoreServiceProvider).watchEntries(uid);
  },
);

final StreamProvider<List<Entry>> trashProvider = StreamProvider<List<Entry>>((
  Ref ref,
) {
  final String? uid = ref.watch(uidProvider);
  if (uid == null) return Stream<List<Entry>>.value(const <Entry>[]);
  return ref.watch(firestoreServiceProvider).watchTrash(uid);
});

/// Entradas de um tipo só — usado pelas telas de Fotos, Vídeos, Cartas...
final entriesOfTypeProvider = Provider.family<List<Entry>, EntryType>((
  Ref ref,
  EntryType type,
) {
  final List<Entry> all = ref.watch(entriesProvider).value ?? const <Entry>[];
  return all.where((Entry e) => e.type == type).toList();
});

/// Registros de crescimento em ordem cronológica, incluindo o nascimento.
final Provider<List<Entry>> growthRecordsProvider = Provider<List<Entry>>((
  Ref ref,
) {
  final List<Entry> all = ref.watch(entriesProvider).value ?? const <Entry>[];
  final List<Entry> records = all.where((Entry e) => e.growth != null).toList()
    ..sort((Entry a, Entry b) => b.date.compareTo(a.date));
  return records;
});

/// Envios em andamento, para a faixa de status na linha do tempo.
final StreamProvider<UploadProgress> uploadProgressProvider =
    StreamProvider<UploadProgress>(
      (Ref ref) => ref.watch(memoryRepositoryProvider).progress,
    );

/// Entradas que falharam e podem ser reenviadas.
final Provider<List<Entry>> failedUploadsProvider = Provider<List<Entry>>((
  Ref ref,
) {
  final List<Entry> all = ref.watch(entriesProvider).value ?? const <Entry>[];
  return all.where((Entry e) => e.uploadStatus == UploadStatus.failed).toList();
});

/// Envios ainda em curso.
final Provider<List<Entry>> activeUploadsProvider = Provider<List<Entry>>((
  Ref ref,
) {
  // Reconstrói a cada evento de progresso, para a faixa acompanhar o envio.
  ref.watch(uploadProgressProvider);
  final List<Entry> all = ref.watch(entriesProvider).value ?? const <Entry>[];
  return all.where((Entry e) => e.uploadStatus.isBusy).toList();
});

// ---------------------------------------------------------- estatísticas

/// Contadores da tela de Estatísticas.
class MemoryStats {
  const MemoryStats({required this.byType, required this.totalBytes});

  final Map<EntryType, int> byType;
  final int totalBytes;

  int count(EntryType type) => byType[type] ?? 0;
}

final Provider<MemoryStats> statsProvider = Provider<MemoryStats>((Ref ref) {
  final List<Entry> all = ref.watch(entriesProvider).value ?? const <Entry>[];
  final Map<EntryType, int> byType = <EntryType, int>{};
  int bytes = 0;

  for (final Entry entry in all) {
    // Fotos e vídeos contam por arquivo; o resto conta por registro.
    final int increment = entry.type.bucketsByAge && entry.hasFiles
        ? entry.files.length
        : 1;
    byType.update(
      entry.type,
      (int value) => value + increment,
      ifAbsent: () => increment,
    );
    bytes += entry.totalBytes;
  }

  return MemoryStats(byType: byType, totalBytes: bytes);
});

final FutureProvider<DriveQuota> driveQuotaProvider =
    FutureProvider<DriveQuota>(
      (Ref ref) => ref.watch(driveServiceProvider).quota(),
    );
