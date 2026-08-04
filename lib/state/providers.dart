import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/baby_profile.dart';
import '../models/capsule_pulse.dart';
import '../models/entry.dart';
import '../models/family_access.dart';
import '../models/reminder.dart';
import '../services/inspiration_source.dart';
import '../models/inspiration.dart';
import '../models/suggestion_progress.dart';
import '../models/suggestion.dart';
import '../services/auth_service.dart';
import '../services/drive_service.dart';
import '../services/firestore_service.dart';
import '../services/media_optimizer.dart';
import '../services/notification_service.dart';
import '../services/memory_repository.dart';
import '../services/session_service.dart';
import '../services/thumbnail_service.dart';

/// Chave do Scaffold da casca do aplicativo.
///
/// As telas internas (Início, Linha do Tempo) têm o próprio Scaffold, então
/// `Scaffold.of(context)` acharia o Scaffold errado - o de dentro, que não
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

/// Sair e apagar a conta - os dois caminhos que precisam falar com todos os
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
        reminders: ref.watch(reminderSchedulerProvider),
      ),
    );

// ------------------------------------------------------------------ auth

final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (Ref ref) => ref.watch(authServiceProvider).authStateChanges,
);

/// Uid da conta em uso, ou `null` quando ninguém entrou.
///
/// **Não é** o dono da cápsula que está na tela. Para isso existe
/// [capsuleOwnerProvider], e a diferença entre os dois é o compartilhamento
/// familiar inteiro: a avó entra com a conta dela e vê a cápsula da neta.
final Provider<String?> uidProvider = Provider<String?>((Ref ref) {
  return ref.watch(authStateProvider).value?.uid;
});

/// O email da conta em uso. O convite é amarrado a ele.
final Provider<String?> emailProvider = Provider<String?>((Ref ref) {
  return ref.watch(authStateProvider).value?.email;
});

// ------------------------------------------------------ de quem é a cápsula

/// O vínculo desta conta com a cápsula de outra pessoa, se houver.
///
/// Enquanto está carregando ninguém sabe ainda de quem é a cápsula, e é por
/// isso que este provider é observado antes de qualquer tela de dados: abrir
/// a cápsula errada por um instante seria pior que esperar meio segundo.
final StreamProvider<FamilyLink?> familyLinkProvider =
    StreamProvider<FamilyLink?>((Ref ref) {
      final String? uid = ref.watch(uidProvider);
      if (uid == null) return Stream<FamilyLink?>.value(null);
      return ref.watch(firestoreServiceProvider).watchFamilyLink(uid);
    });

/// De quem é a cápsula aberta agora.
///
/// Este é o ponto único de troca entre "minha cápsula" e "a cápsula da minha
/// neta". Todo provider de dados passa por aqui, e nenhum usa mais o
/// [uidProvider] direto - se algum voltar a usar, a avó vai abrir uma cápsula
/// vazia com o nome dela.
final Provider<String?> capsuleOwnerProvider = Provider<String?>((Ref ref) {
  final FamilyLink? link = ref.watch(familyLinkProvider).value;
  return link?.ownerUid ?? ref.watch(uidProvider);
});

/// Se quem está olhando é dono ou família.
final Provider<CapsuleRole> capsuleRoleProvider = Provider<CapsuleRole>((
  Ref ref,
) {
  return ref.watch(familyLinkProvider).value == null
      ? CapsuleRole.owner
      : CapsuleRole.family;
});

/// Modo leitura: sem botão de adicionar, sem editar, sem apagar.
///
/// A interface inteira pergunta isto em vez de perguntar o papel, porque é
/// isso que ela precisa saber. Se um dia houver um terceiro papel, muda aqui
/// e mais nada.
final Provider<bool> isReadOnlyProvider = Provider<bool>(
  (Ref ref) => ref.watch(capsuleRoleProvider) == CapsuleRole.family,
);

// --------------------------------------------------------------- perfil

/// Cadastro da criança. `null` significa "ainda não passou pelo onboarding".
///
/// Para o familiar, é o cadastro da criança dele: o nome e a data de
/// nascimento são o que fazem a linha do tempo dizer alguma coisa. É o único
/// documento do perfil que ele lê.
final StreamProvider<BabyProfile?> profileProvider =
    StreamProvider<BabyProfile?>((Ref ref) {
      final String? uid = ref.watch(capsuleOwnerProvider);
      if (uid == null) return Stream<BabyProfile?>.value(null);
      return ref.watch(firestoreServiceProvider).watchProfile(uid);
    });

// -------------------------------------------------------------- entradas

/// Todas as memórias ativas, já ordenadas da mais recente para a mais antiga.
/// De onde vem o conteúdo das inspirações.
///
/// Sobrescreva este provider para trocar o arquivo local por uma chamada de
/// rede: nem a tela nem o filtro por idade mudam.
final Provider<InspirationSource> inspirationSourceProvider =
    Provider<InspirationSource>((Ref ref) => const AssetInspirationSource());

/// As inspirações que valem hoje, resolvidas contra a idade e o calendário.
final FutureProvider<List<ActiveInspiration>> inspirationsProvider =
    FutureProvider<List<ActiveInspiration>>((Ref ref) async {
      final BabyProfile? profile = ref.watch(profileProvider).value;
      if (profile == null) return const <ActiveInspiration>[];
      final List<Inspiration> todas = await ref
          .watch(inspirationSourceProvider)
          .load();
      return pickFor(all: todas, profile: profile);
    });

/// O que já foi lido, guardado no aparelho.
final NotifierProvider<ReadInspirationsNotifier, Set<String>>
readInspirationsProvider =
    NotifierProvider<ReadInspirationsNotifier, Set<String>>(
      ReadInspirationsNotifier.new,
    );

class ReadInspirationsNotifier extends Notifier<Set<String>> {
  ReadInspirations? _store;

  @override
  Set<String> build() {
    unawaited(_carregar());
    return const <String>{};
  }

  Future<void> _carregar() async {
    final ReadInspirations store = ReadInspirations(
      await SharedPreferences.getInstance(),
    );
    _store = store;
    state = store.ids;
  }

  Future<void> markRead(String id) async {
    if (state.contains(id)) return;
    state = <String>{...state, id};
    await _store?.markRead(id);
  }
}

/// Quantas inspirações ativas ainda não foram abertas.
///
/// É o que põe o pontinho na aba. Zero quando não há nada novo: selo
/// permanente vira decoração e some da percepção.
final Provider<int> unreadInspirationsProvider = Provider<int>((Ref ref) {
  final List<ActiveInspiration> ativas =
      ref.watch(inspirationsProvider).value ?? const <ActiveInspiration>[];
  final Set<String> lidas = ref.watch(readInspirationsProvider);
  return ativas
      .where((ActiveInspiration a) => !lidas.contains(a.inspiration.id))
      .length;
});

/// O que a pessoa já resolveu no catálogo de sugestões.
final StreamProvider<Map<String, SuggestionProgress>>
suggestionProgressProvider = StreamProvider<Map<String, SuggestionProgress>>((
  Ref ref,
) {
  final String? uid = ref.watch(uidProvider);
  if (uid == null) {
    return Stream<Map<String, SuggestionProgress>>.value(
      const <String, SuggestionProgress>{},
    );
  }
  return ref.watch(firestoreServiceProvider).watchSuggestions(uid);
});

/// As sugestões que valem hoje.
///
/// Recalculadas a cada abertura porque dependem da data: uma sugestão de
/// Natal não pode continuar de pé em fevereiro só porque o aplicativo não
/// foi reaberto.
final Provider<List<ActiveSuggestion>>
activeSuggestionsProvider = Provider<List<ActiveSuggestion>>((Ref ref) {
  final BabyProfile? profile = ref.watch(profileProvider).value;
  if (profile == null) return const <ActiveSuggestion>[];

  final Map<String, SuggestionProgress> progresso =
      ref.watch(suggestionProgressProvider).value ??
      const <String, SuggestionProgress>{};

  return Suggestions.activeFor(
    profile: profile,
    resolved: <String>{
      for (final MapEntry<String, SuggestionProgress> e in progresso.entries)
        if (e.value.isResolved) e.key,
    },
    checked: <String, Set<String>>{
      for (final MapEntry<String, SuggestionProgress> e in progresso.entries)
        e.key: e.value.checked,
    },
  );
});

/// A foto que representa a criança no aplicativo.
///
/// Deriva das entradas em vez de guardar um id à parte, e isso é de
/// propósito. O caminho antigo tentava gravar o id no cadastro logo depois
/// de escolher a foto, mas o envio ao Drive é assíncrono: naquele instante
/// o id ainda é vazio, e a foto nunca chegava ao perfil.
///
/// Derivada, ela aparece sozinha assim que o envio termina, sobrevive à
/// exclusão da foto escolhida (cai para a próxima) e dispensa uma segunda
/// fonte de verdade que pode divergir.
///
/// A ordem é: a escolha explícita de quem cadastrou, depois a foto do
/// nascimento, depois a mais recente.
final Provider<EntryFile?> avatarPhotoProvider = Provider<EntryFile?>((
  Ref ref,
) {
  final BabyProfile? profile = ref.watch(profileProvider).value;
  if (profile == null) return null;
  final List<Entry> all = ref.watch(entriesProvider).value ?? const <Entry>[];

  bool pronta(EntryFile f) => f.driveId.isNotEmpty && f.isImage;

  final String? escolhida = profile.photoDriveId;
  if (escolhida != null && escolhida.isNotEmpty) {
    for (final Entry entry in all) {
      for (final EntryFile file in entry.files) {
        if (file.driveId == escolhida) return file;
      }
    }
  }

  for (final Entry entry in all) {
    if (entry.type != EntryType.birth) continue;
    final EntryFile? file = entry.files.where(pronta).firstOrNull;
    if (file != null) return file;
  }

  for (final Entry entry in all) {
    if (entry.type != EntryType.photo) continue;
    final EntryFile? file = entry.files.where(pronta).firstOrNull;
    if (file != null) return file;
  }

  return null;
});

final StreamProvider<List<Entry>> entriesProvider = StreamProvider<List<Entry>>(
  (Ref ref) {
    final String? uid = ref.watch(capsuleOwnerProvider);
    if (uid == null) return Stream<List<Entry>>.value(const <Entry>[]);
    final FirestoreService firestore = ref.watch(firestoreServiceProvider);
    // Duas consultas diferentes, e não um filtro depois de ler: o que a
    // família não pode ver não chega nem a sair do servidor.
    return ref.watch(isReadOnlyProvider)
        ? firestore.watchFamilyEntries(uid)
        : firestore.watchEntries(uid);
  },
);

final StreamProvider<List<Entry>> trashProvider = StreamProvider<List<Entry>>((
  Ref ref,
) {
  final String? uid = ref.watch(uidProvider);
  if (uid == null) return Stream<List<Entry>>.value(const <Entry>[]);
  return ref.watch(firestoreServiceProvider).watchTrash(uid);
});

/// Entradas de um tipo só - usado pelas telas de Fotos, Vídeos, Cartas...
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

// ------------------------------------------------------------- lembretes

final Provider<ReminderScheduler> reminderSchedulerProvider =
    Provider<ReminderScheduler>((Ref ref) => NotificationService());

/// O ajuste de lembretes, guardado neste aparelho.
final NotifierProvider<ReminderSettingsNotifier, ReminderSettings>
reminderSettingsProvider =
    NotifierProvider<ReminderSettingsNotifier, ReminderSettings>(
      ReminderSettingsNotifier.new,
    );

class ReminderSettingsNotifier extends Notifier<ReminderSettings> {
  ReminderPreferences? _store;

  @override
  ReminderSettings build() {
    unawaited(_carregar());
    return const ReminderSettings();
  }

  Future<void> _carregar() async {
    final ReminderPreferences store = ReminderPreferences(
      await SharedPreferences.getInstance(),
    );
    _store = store;
    state = store.load();
  }

  Future<void> save(ReminderSettings novo) async {
    state = novo;
    await _store?.save(novo);
  }

  /// Liga os lembretes, pedindo a permissão do sistema primeiro.
  ///
  /// Se a pessoa recusar, nada é ligado: a chave não pode ficar em "sim"
  /// enquanto o sistema diz não. Uma chave ligada que não toca é pior que
  /// uma desligada, porque ninguém vai procurar o defeito.
  Future<bool> enable() async {
    final bool permitido = await ref
        .read(reminderSchedulerProvider)
        .requestPermission();
    if (!permitido) return false;
    await save(state.copyWith(enabled: true));
    return true;
  }

  Future<void> disable() async {
    await save(state.copyWith(enabled: false));
    await ref.read(reminderSchedulerProvider).cancelAll();
  }
}

/// A agenda que vale agora, recalculada a cada mudança relevante.
///
/// Depende do cadastro, das entradas e das inspirações porque todas as três
/// mudam o que faz sentido lembrar. Só o dono da cápsula recebe lembretes:
/// avisar a avó de que faz duas semanas sem foto seria cobrar dela uma
/// coisa que ela não pode fazer.
final Provider<List<ScheduledReminder>> plannedRemindersProvider =
    Provider<List<ScheduledReminder>>((Ref ref) {
      if (ref.watch(isReadOnlyProvider)) return const <ScheduledReminder>[];

      final BabyProfile? profile = ref.watch(profileProvider).value;
      if (profile == null) return const <ScheduledReminder>[];

      final List<Entry> entradas =
          ref.watch(entriesProvider).value ?? const <Entry>[];

      return planReminders(
        profile: profile,
        pulse: CapsulePulse.from(profile: profile, entries: entradas),
        settings: ref.watch(reminderSettingsProvider),
        inspirations:
            ref.watch(inspirationsProvider).value ??
            const <ActiveInspiration>[],
        readInspirations: ref.watch(readInspirationsProvider),
      );
    });

// ------------------------------------------------------ família e convites

/// Quem tem acesso à cápsula, para a tela de compartilhamento.
final StreamProvider<List<FamilyMember>> familyMembersProvider =
    StreamProvider<List<FamilyMember>>((Ref ref) {
      final String? uid = ref.watch(uidProvider);
      if (uid == null) {
        return Stream<List<FamilyMember>>.value(<FamilyMember>[]);
      }
      return ref.watch(firestoreServiceProvider).watchFamilyMembers(uid);
    });

/// Os convites criados por esta pessoa, usados ou não.
final StreamProvider<List<FamilyInvite>> myInvitesProvider =
    StreamProvider<List<FamilyInvite>>((Ref ref) {
      final String? uid = ref.watch(uidProvider);
      if (uid == null) {
        return Stream<List<FamilyInvite>>.value(<FamilyInvite>[]);
      }
      return ref.watch(firestoreServiceProvider).watchInvitesOf(uid);
    });

final FutureProvider<DriveQuota> driveQuotaProvider =
    FutureProvider<DriveQuota>(
      (Ref ref) => ref.watch(driveServiceProvider).quota(),
    );
