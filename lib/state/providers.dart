import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/baby_gender.dart';
import '../models/baby_profile.dart';
import '../models/capsule_pulse.dart';
import '../models/entry.dart';
import '../models/reminder.dart';
import '../services/inspiration_source.dart';
import '../models/inspiration.dart';
import '../models/suggestion_progress.dart';
import '../models/suggestion.dart';
import '../services/auth_service.dart';
import '../services/cartas_atrasadas.dart';
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

/// A gravação das cartas que existiam antes de a carta virar arquivo.
///
/// A dependência é uma função, e não o repositório inteiro, porque assim a
/// regra (quais cartas, em que ordem, quantas por vez, e nunca duas rodadas
/// ao mesmo tempo) fica testável sem Firebase nem Drive.
final Provider<CartasAtrasadas> cartasAtrasadasProvider =
    Provider<CartasAtrasadas>((Ref ref) {
      return CartasAtrasadas((Entry carta) async {
        final String? uid = ref.read(uidProvider);
        final BabyProfile? profile = ref.read(profileProvider).value;
        if (uid == null || profile == null) return carta;
        return ref
            .read(memoryRepositoryProvider)
            .escreverCarta(uid, profile, carta);
      });
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
final Provider<String?> uidProvider = Provider<String?>((Ref ref) {
  return ref.watch(authStateProvider).value?.uid;
});

/// O sexo que a pessoa acabou de tocar no cadastro, antes de salvar.
///
/// Existe por um motivo só: a paleta do aplicativo vem do cadastro, e no
/// cadastro ainda não há cadastro. Sem isto, quem escolhe "menina" continua
/// vendo a cor neutra até terminar de preencher o formulário inteiro, e a
/// escolha parece não ter surtido efeito.
///
/// Some sozinho quando o perfil chega: o tema prefere o que está salvo, e
/// este valor passa a ser ignorado.
final NotifierProvider<GeneroEscolhidoNotifier, BabyGender?>
generoEscolhidoProvider =
    NotifierProvider<GeneroEscolhidoNotifier, BabyGender?>(
      GeneroEscolhidoNotifier.new,
    );

class GeneroEscolhidoNotifier extends Notifier<BabyGender?> {
  @override
  BabyGender? build() => null;

  void escolher(BabyGender? genero) => state = genero;
}

// --------------------------------------------------------------- perfil

/// Cadastro da criança. `null` significa "ainda não passou pelo onboarding".
final StreamProvider<BabyProfile?> profileProvider =
    StreamProvider<BabyProfile?>((Ref ref) {
      final String? uid = ref.watch(uidProvider);
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

/// Se a apresentação de três telas já foi vista neste aparelho.
///
/// Guardado no aparelho, e não na conta, porque ela acontece antes de haver
/// conta nenhuma: é a primeira coisa que aparece quando o aplicativo abre.
final NotifierProvider<IntroSeenNotifier, bool> introSeenProvider =
    NotifierProvider<IntroSeenNotifier, bool>(IntroSeenNotifier.new);

class IntroSeenNotifier extends Notifier<bool> {
  static const String _chave = 'apresentacao.vista';

  /// Começa em `true` para que a apresentação **não** pisque na frente de
  /// quem já a viu. O disco responde em milissegundos, e nesse intervalo o
  /// roteador prefere não mandar ninguém para lá: mostrar de novo a quem já
  /// passou é pior que mostrar meio segundo depois a quem nunca viu.
  @override
  bool build() {
    unawaited(_carregar());
    return true;
  }

  Future<void> _carregar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_chave) ?? false;
  }

  Future<void> markSeen() async {
    state = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, true);
  }

  /// Só para conferir na tela Sobre que rever não apaga a marca.
  Future<void> reset() async {
    state = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
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
  /// O disco, quando responder.
  ///
  /// Guardado como Future, e não como campo que pode estar nulo, porque o
  /// mais importante deste arquivo acontece cedo: a tela inicial pede a
  /// permissão no primeiro quadro depois de aparecer, e o `SharedPreferences`
  /// costuma chegar depois disso. Com um campo nulo, aquele pedido virava um
  /// retorno silencioso e a permissão nunca era pedida - o aplicativo ficaria
  /// com os lembretes ligados e mudo.
  late final Future<ReminderPreferences> _pronto;

  /// Se alguém já escolheu algo nesta sessão, antes de o disco responder.
  bool _mexido = false;

  @override
  ReminderSettings build() {
    _pronto = _carregar();
    return const ReminderSettings();
  }

  Future<ReminderPreferences> _carregar() async {
    final ReminderPreferences store = ReminderPreferences(
      await SharedPreferences.getInstance(),
    );
    // O que a pessoa acabou de escolher vale mais que o que estava gravado.
    if (!_mexido) state = store.load();
    return store;
  }

  Future<void> save(ReminderSettings novo) async {
    _mexido = true;
    state = novo;
    await (await _pronto).save(novo);
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
    // Desligar explicitamente na recusa, e não apenas deixar de ligar: como
    // o padrão é ligado, "não fazer nada" deixaria a chave em pé enquanto o
    // sistema diz não. A chave tem que contar a verdade.
    await save(state.copyWith(enabled: permitido));
    return permitido;
  }

  Future<void> disable() async {
    await save(state.copyWith(enabled: false));
    await ref.read(reminderSchedulerProvider).cancelAll();
  }

  /// Pede a permissão do sistema uma vez, na primeira vez que faz sentido.
  ///
  /// Chamado quando a cápsula já existe, e não na abertura do aplicativo:
  /// a caixa de diálogo do Android é mais bem recebida logo depois de a
  /// pessoa ter cadastrado a criança, quando ela acabou de dizer o que
  /// está guardando, do que na primeira tela de um aplicativo que ela ainda
  /// não sabe o que é.
  ///
  /// Uma vez só, para sempre. Se a resposta for não, a chave acompanha: um
  /// interruptor ligado que nunca toca é pior que um desligado.
  Future<void> ensureAsked() async {
    final ReminderPreferences store = await _pronto;
    if (store.alreadyAsked) return;
    if (!state.enabled) return;

    await store.markAsked();
    final bool permitido = await ref
        .read(reminderSchedulerProvider)
        .requestPermission();
    if (!permitido) await save(state.copyWith(enabled: false));
  }
}

/// A agenda que vale agora, recalculada a cada mudança relevante.
///
/// Depende do cadastro, das entradas e das inspirações porque todas as três
/// mudam o que faz sentido lembrar.
final Provider<List<ScheduledReminder>> plannedRemindersProvider =
    Provider<List<ScheduledReminder>>((Ref ref) {
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

final FutureProvider<DriveQuota> driveQuotaProvider =
    FutureProvider<DriveQuota>(
      (Ref ref) => ref.watch(driveServiceProvider).quota(),
    );
