import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../audio/audio_recorder_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../services/memory_repository.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';
import '../growth/growth_editor_sheet.dart';
import '../timeline/details_editor_sheet.dart';

/// Folha "O que você deseja adicionar?".
///
/// Cada opção leva ao envio em dois ou três toques - sem formulário
/// obrigatório em nenhum caminho.
Future<void> showAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => const _AddSheet(),
  );
}

class _AddSheet extends ConsumerStatefulWidget {
  const _AddSheet();

  @override
  ConsumerState<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<_AddSheet> {
  /// Quando a memória aconteceu, e não quando ela está sendo guardada.
  ///
  /// Começa em hoje, que é o caso de quase todo envio, então o caminho rápido
  /// continua com o mesmo número de toques. Quem está trazendo o acervo
  /// antigo para dentro do aplicativo toca uma vez aqui e o lote inteiro
  /// entra na idade certa.
  DateTime _quando = DateTime.now();

  Future<void> _escolherData() async {
    final BabyProfile? profile = ref.read(profileProvider).value;
    final DateTime agora = DateTime.now();
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _quando,
      firstDate: profile?.birthDay ?? DateTime(agora.year - 20),
      lastDate: agora,
      helpText: 'Quando isso aconteceu?',
    );
    if (escolhida == null) return;
    setState(() => _quando = comHoraDoRelogio(escolhida, agora));
  }

  @override
  Widget build(BuildContext context) {
    final Copy g = Copy.of(ref.watch(profileProvider).value);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.cores.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(S.addQuestion, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            DataDaMemoria(
              quando: _quando,
              onTap: _escolherData,
              onReset: () => setState(() => _quando = DateTime.now()),
            ),
            const SizedBox(height: 16),
            _Option(
              type: EntryType.photo,
              title: S.addPhoto,
              subtitle: g.addPhotoHint,
              onTap: () => _addPhotos(context, ref, _quando),
            ),
            _Option(
              type: EntryType.video,
              title: S.addVideo,
              subtitle: g.addVideoHint,
              onTap: () => _addVideos(context, ref, _quando),
            ),
            _Option(
              type: EntryType.audio,
              title: 'Gravar áudio',
              subtitle: 'A voz é o que mais se perde com o tempo',
              onTap: () => _addAudio(context, ref, _quando),
            ),
            _Option(
              type: EntryType.letter,
              title: S.addLetter,
              subtitle: g.addLetterHint,
              onTap: () {
                Navigator.of(context).pop();
                context.push(Routes.newLetter, extra: _quando);
              },
            ),
            _Option(
              type: EntryType.drawing,
              title: S.addDrawing,
              subtitle: S.addDrawingHint,
              onTap: () => _addDrawings(context, ref, _quando),
            ),
            _Option(
              type: EntryType.document,
              title: S.addDocument,
              subtitle: S.addDocumentHint,
              onTap: () => _addDocuments(context, ref, _quando),
            ),
            _Option(
              type: EntryType.growth,
              title: S.addGrowth,
              subtitle: S.addGrowthHint,
              onTap: () {
                Navigator.of(context).pop();
                showGrowthEditor(context, quando: _quando);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// O dia escolhido, carregando a hora de agora.
///
/// O seletor de data devolve meia-noite. Se essa hora fosse guardada como
/// está, um lote inteiro marcado para o mesmo dia antigo geraria nomes de
/// arquivo iguais no Drive, porque o nome começa pela data e hora, e a ordem
/// dentro da pasta ficaria indefinida. A hora do relógio resolve isso e ainda
/// mantém na linha do tempo a ordem em que as coisas foram guardadas.
DateTime comHoraDoRelogio(DateTime dia, DateTime agora) => DateTime(
  dia.year,
  dia.month,
  dia.day,
  agora.hour,
  agora.minute,
  agora.second,
);

/// A data que vale para o que for adicionado a seguir.
///
/// Fica acima das opções, e não depois de escolher os arquivos, porque assim
/// ela vale para o lote inteiro e é decidida antes de o envio começar: a
/// pasta do Drive é escolhida pela idade na data, e mudar isso depois
/// significaria mover arquivo de pasta.
class DataDaMemoria extends StatelessWidget {
  const DataDaMemoria({
    required this.quando,
    required this.onTap,
    required this.onReset,
    super.key,
  });

  final DateTime quando;
  final VoidCallback onTap;
  final VoidCallback onReset;

  static bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool hoje = _mesmoDia(quando, DateTime.now());

    return Material(
      color: hoje ? context.cores.surfaceMuted : context.cores.primarySoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.event_outlined,
                size: 20,
                color: hoje
                    ? context.cores.textSecondary
                    : context.cores.primaryDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      hoje ? 'Aconteceu hoje' : Fmt.longDate(quando),
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hoje ? null : context.cores.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hoje
                          ? 'Toque para guardar algo de outro dia'
                          : 'Vale para tudo que você adicionar agora',
                      style: text.bodySmall?.copyWith(
                        color: context.cores.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hoje)
                IconButton(
                  onPressed: onReset,
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Voltar para hoje',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contexto necessário para qualquer envio.
({String uid, BabyProfile profile})? _context(WidgetRef ref) {
  final String? uid = ref.read(uidProvider);
  final BabyProfile? profile = ref.read(profileProvider).value;
  if (uid == null || profile == null) return null;
  return (uid: uid, profile: profile);
}

Future<void> _addPhotos(
  BuildContext context,
  WidgetRef ref,
  DateTime quando,
) async {
  final List<XFile> picked = await ExternalActivity.run(
    () => ImagePicker().pickMultiImage(
      // Sem metadados completos a seleção é bem mais rápida; a orientação é
      // preservada na compressão.
      requestFullMetadata: false,
    ),
  );
  if (picked.isEmpty) return;
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    quando: quando,
    type: EntryType.photo,
    files: picked
        .map((XFile f) => PendingFile(path: f.path, kind: EntryType.photo))
        .toList(),
    message:
        'Enviando ${picked.length == 1 ? 'a foto' : '${picked.length} fotos'}...',
  );
}

Future<void> _addDrawings(
  BuildContext context,
  WidgetRef ref,
  DateTime quando,
) async {
  final List<XFile> picked = await ExternalActivity.run(
    () => ImagePicker().pickMultiImage(requestFullMetadata: false),
  );
  if (picked.isEmpty) return;
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    quando: quando,
    type: EntryType.drawing,
    files: picked
        .map((XFile f) => PendingFile(path: f.path, kind: EntryType.drawing))
        .toList(),
    message: 'Guardando o desenho...',
  );
}

Future<void> _addVideos(
  BuildContext context,
  WidgetRef ref,
  DateTime quando,
) async {
  // `image_picker` só escolhe um vídeo por vez; o `file_picker` permite
  // vários de uma vez, que é o que a especificação pede.
  final FilePickerResult? result = await ExternalActivity.run(
    () => FilePicker.pickFiles(type: FileType.video, allowMultiple: true),
  );
  final List<PlatformFile> files = result?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return;
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    quando: quando,
    type: EntryType.video,
    files: files
        .where((PlatformFile f) => f.path != null)
        .map(
          (PlatformFile f) =>
              PendingFile(path: f.path!, kind: EntryType.video, name: f.name),
        )
        .toList(),
    message: 'Convertendo para 720p e enviando...',
  );
}

Future<void> _addAudio(
  BuildContext context,
  WidgetRef ref,
  DateTime quando,
) async {
  // O gravador é do próprio aplicativo, mas a caixa de permissão do
  // microfone é do sistema e tira o app do primeiro plano; a guarda de
  // atividade externa fica dentro do gravador, junto de onde ela é pedida.
  final String? caminho = await showAudioRecorder(context);
  if (caminho == null || !context.mounted) return;

  await _send(
    context,
    ref,
    quando: quando,
    type: EntryType.audio,
    files: <PendingFile>[
      PendingFile(
        path: caminho,
        kind: EntryType.audio,
        name: p.basename(caminho),
      ),
    ],
    message: 'Guardando a gravação...',
  );
}

Future<void> _addDocuments(
  BuildContext context,
  WidgetRef ref,
  DateTime quando,
) async {
  final FilePickerResult? result = await ExternalActivity.run(
    () => FilePicker.pickFiles(allowMultiple: true),
  );
  final List<PlatformFile> files = result?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return;
  if (!context.mounted) return;

  for (final PlatformFile file in files) {
    if (file.path == null) continue;
    if (!context.mounted) return;
    await _send(
      context,
      ref,
      quando: quando,
      type: EntryType.document,
      files: <PendingFile>[
        PendingFile(
          path: file.path!,
          kind: EntryType.document,
          name: file.name,
        ),
      ],
      title: _titleFromFileName(file.name),
      message: 'Enviando ${file.name}...',
      keepSheetOpen: true,
    );
  }
  if (context.mounted) Navigator.of(context).maybePop();
}

/// `Certidão de Nascimento.pdf` vira `Certidão de Nascimento`.
String _titleFromFileName(String name) {
  final int dot = name.lastIndexOf('.');
  return dot <= 0 ? name : name.substring(0, dot);
}

Future<void> _send(
  BuildContext context,
  WidgetRef ref, {
  required DateTime quando,
  required EntryType type,
  required List<PendingFile> files,
  required String message,
  String? title,
  bool keepSheetOpen = false,
}) async {
  final ({String uid, BabyProfile profile})? ctx = _context(ref);
  if (ctx == null) {
    showMessage(context, S.genericError);
    return;
  }
  if (files.isEmpty) return;

  if (!keepSheetOpen) Navigator.of(context).pop();

  try {
    final Entry entry = await ref
        .read(memoryRepositoryProvider)
        .addFiles(
          uid: ctx.uid,
          profile: ctx.profile,
          type: type,
          files: files,
          date: quando,
          title: title,
        );
    if (!context.mounted) return;

    // Documentos já vêm com o nome do arquivo como título; para foto, vídeo
    // e desenho o aviso é a chance de dizer que aquilo foi o "Primeiro
    // sorriso" - opcional, e sem segurar o envio.
    if (type == EntryType.document) {
      showMessage(context, message);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Marcar',
            onPressed: () => showDetailsEditor(context, entry),
          ),
        ),
      );
  } on Exception catch (e) {
    if (context.mounted) {
      showMessage(context, userMessage(e, context: 'Enviar memória'));
    }
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final EntryType type;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: type.soft(context),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Icon(type.icon, color: type.accent(context), size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: text.bodySmall?.copyWith(
                          color: context.cores.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
