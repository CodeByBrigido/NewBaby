import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/strings.dart';
import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/utils/data_do_arquivo.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../services/memory_repository.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';
import '../growth/growth_editor_sheet.dart';
import 'envio_em_andamento.dart';

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
  @override
  Widget build(BuildContext context) {
    final Copy g = Copy.of(ref.watch(profileProvider).value);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.x20,
          Space.x12,
          Space.x20,
          Space.x20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.cores.divider,
                borderRadius: Radii.pillR,
              ),
            ),
            const SizedBox(height: Space.x20),
            Text(S.addQuestion, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Space.x16),
            _Option(
              type: EntryType.photo,
              title: S.addPhoto,
              subtitle: g.addPhotoHint,
              onTap: () => _addPhotos(context, ref),
            ),
            _Option(
              type: EntryType.video,
              title: S.addVideo,
              subtitle: g.addVideoHint,
              onTap: () => _addVideos(context, ref),
            ),
            _Option(
              type: EntryType.letter,
              title: S.addLetter,
              subtitle: g.addLetterHint,
              onTap: () {
                Navigator.of(context).pop();
                context.push(Routes.newLetter);
              },
            ),
            _Option(
              type: EntryType.drawing,
              title: S.addDrawing,
              subtitle: S.addDrawingHint,
              onTap: () => _addDrawings(context, ref),
            ),
            _Option(
              type: EntryType.document,
              title: S.addDocument,
              subtitle: S.addDocumentHint,
              onTap: () => _addDocuments(context, ref),
            ),
            _Option(
              type: EntryType.growth,
              title: S.addGrowth,
              subtitle: S.addGrowthHint,
              onTap: () {
                Navigator.of(context).pop();
                showGrowthEditor(context);
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

/// `1 foto`, `5 fotos`, `3 vídeos`.
String quantosItens(EntryType type, int quantidade) =>
    quantidade == 1 ? '1 ${type.one}' : '$quantidade ${type.one}s';

/// O que a confirmação diz antes de o envio começar.
///
/// A data sozinha não evita engano: `10 de abril de 2027` não diz nada a
/// quem está trazendo o acervo antigo. A idade naquele dia diz, e é ela que
/// decide onde a memória vai ficar guardada. Por isso as duas aparecem
/// juntas, e a idade vem calculada, não digitada.
List<String> resumoDoEnvio({
  required Copy g,
  required BabyProfile profile,
  required EntryType type,
  required int quantidade,
  required DateTime quando,
}) {
  final Age idade = profile.ageAt(quando);
  final AgeBucket balde = AgeCalculator.bucketAt(profile.birth, quando);

  final String oQue = quantosItens(type, quantidade);
  final String comData = '$oQue com a data de ${Fmt.longDate(quando)}.';

  // No dia zero `detailedLabel` devolve "No nascimento", que não encaixa em
  // "tinha ...". A frase muda inteira, em vez de virar remendo.
  final String comIdade = idade.totalDays == 0
      ? (g.hasName
            ? 'Foi o dia em que ${g.theName} nasceu.'
            : 'Foi o dia do nascimento.')
      : (g.hasName
            ? 'Nessa data ${g.theName} tinha ${idade.detailedLabel()}.'
            : 'Idade nessa data: ${idade.detailedLabel()}.');

  return <String>[
    comData,
    comIdade,
    // Só os tipos agrupados por idade têm um lugar por idade para citar.
    // Documento e carta não entram em semana nenhuma.
    if (type.bucketsByAge)
      'Vai ficar guardado ${_artigoDoBalde(balde)} ${balde.folderName}.',
  ];
}

String _artigoDoBalde(AgeBucket balde) =>
    balde.unit == AgeBucketUnit.week ? 'na' : 'no';

/// O que a tela diz sobre a origem da data, antes de a pessoa confirmar.
///
/// Assumir a data do arquivo só é aceitável se estiver escrito de onde ela
/// veio. Uma data que aparece sozinha, sem explicação, é uma data que
/// ninguém confere, e conferir é justamente o ponto desta tela.
@visibleForTesting
String origemDaData(DataDoLote lote, EntryType type) {
  if (!lote.lida) {
    return 'Não achamos a data dentro ${type == EntryType.document ? 'do arquivo' : 'da mídia'}, '
        'então vale a de hoje. Toque para trocar.';
  }
  if (lote.variosDias) {
    return 'Atenção: o que você escolheu é de ${lote.diasDiferentes} dias '
        'diferentes, e tudo vai ser guardado com esta data. Para separar, '
        'envie um dia de cada vez.';
  }
  return 'Data lida do próprio arquivo. Toque para trocar.';
}

/// Confirmação depois de escolher os arquivos, antes de qualquer envio.
///
/// Devolve a data confirmada, ou `null` se a pessoa desistiu. A data pode ser
/// corrigida aqui mesmo: é o último ponto em que corrigir é barato, porque
/// depois disso o arquivo já subiu para o lugar daquela idade.
Future<DateTime?> confirmarEnvio(
  BuildContext context, {
  required Copy g,
  required BabyProfile profile,
  required EntryType type,
  required int quantidade,
  required DataDoLote lote,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext dialogContext) {
      DateTime escolhida = lote.quando;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          Future<void> mudar() async {
            final DateTime agora = DateTime.now();
            final DateTime? nova = await showDatePicker(
              context: context,
              initialDate: escolhida,
              firstDate: profile.birthDay,
              lastDate: agora,
              helpText: 'Quando isso aconteceu?',
            );
            if (nova == null) return;
            setState(() => escolhida = comHoraDoRelogio(nova, agora));
          }

          return AlertDialog(
            title: const Text('Confere a data?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final String linha in resumoDoEnvio(
                  g: g,
                  profile: profile,
                  type: type,
                  quantidade: quantidade,
                  quando: escolhida,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.x8),
                    child: Text(linha),
                  ),
                const SizedBox(height: Space.x8),
                DataDaMemoria(
                  quando: escolhida,
                  explicacao: origemDaData(lote, type),
                  alerta: lote.variosDias,
                  onTap: mudar,
                ),
              ],
            ),
            // Os dois numa linha só, e não empilhados. Guardar ocupa dois
            // terços porque é o que a pessoa veio fazer; cancelar fica com o
            // terço restante, alcançável sem virar o caminho mais largo da
            // tela.
            //
            // A linha vem numa `Row` própria em vez de dois itens soltos em
            // `actions`, que é o que deixava o botão cheio esticado sozinho.
            actionsPadding: const EdgeInsets.fromLTRB(
              Space.x24,
              Space.x8,
              Space.x24,
              Space.x20,
            ),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(S.cancel),
                    ),
                  ),
                  const SizedBox(width: Space.x12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(dialogContext).pop(escolhida),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

/// A data da memória, com de onde ela veio escrito embaixo.
///
/// Aparece depois de escolher os arquivos, e não antes: agora a data sai do
/// próprio arquivo, e antes de escolher não há o que ler. É também o último
/// ponto em que corrigir é barato, porque a pasta do Drive vem da idade na
/// data e mudar depois significaria mover arquivo de pasta.
///
/// A explicação embaixo não é enfeite. O aplicativo está adivinhando a data,
/// e uma adivinhação sem etiqueta é uma adivinhação que ninguém confere.
class DataDaMemoria extends StatelessWidget {
  const DataDaMemoria({
    required this.quando,
    required this.explicacao,
    required this.onTap,
    this.alerta = false,
    super.key,
  });

  final DateTime quando;
  final String explicacao;
  final VoidCallback onTap;

  /// Pinta o cartão de aviso. Só para o caso em que uma data não descreve o
  /// lote inteiro, que é quando a pessoa precisa parar e reler.
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color realce = alerta
        ? context.cores.primaryDark
        : context.cores.textSecondary;

    return Material(
      color: alerta ? context.cores.primarySoft : context.cores.surfaceMuted,
      borderRadius: Radii.fieldR,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.fieldR,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.x16,
            vertical: Space.x12,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                alerta ? Icons.warning_amber_outlined : Icons.event_outlined,
                size: 20,
                color: realce,
              ),
              const SizedBox(width: Space.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Fmt.longDate(quando),
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Space.x4),
                    Text(
                      explicacao,
                      style: text.bodySmall?.copyWith(color: realce),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_calendar_outlined, size: 18, color: realce),
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

/// A data que os arquivos escolhidos sugerem, dentro do que o cadastro
/// permite.
///
/// O piso é o nascimento porque é o piso do seletor de data também: uma
/// memória anterior a ele não cabe em pasta de idade nenhuma.
Future<DataDoLote> _dataDosArquivos(
  WidgetRef ref,
  List<String> caminhos,
) async {
  final BabyProfile? profile = ref.read(profileProvider).value;
  return dataDoLote(
    caminhos,
    naoAntesDe: profile?.birthDay ?? DateTime(DateTime.now().year - 20),
  );
}

Future<void> _addPhotos(BuildContext context, WidgetRef ref) async {
  final List<XFile> picked = await ExternalActivity.run(
    () => ImagePicker().pickMultiImage(
      // Só vale no iOS, onde pedir metadado completo abre outra permissão e
      // deixa a seleção lenta. No Android este parâmetro nem chega ao
      // plugin, e o EXIF do arquivo escolhido continua inteiro - que é de
      // onde sai a data da foto.
      requestFullMetadata: false,
    ),
  );
  if (picked.isEmpty) return;

  final DataDoLote lote = await _dataDosArquivos(
    ref,
    picked.map((XFile f) => f.path).toList(),
  );
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    lote: lote,
    type: EntryType.photo,
    files: picked
        .map((XFile f) => PendingFile(path: f.path, kind: EntryType.photo))
        .toList(),
    message:
        'Enviando ${picked.length == 1 ? 'a foto' : '${picked.length} fotos'}...',
  );
}

Future<void> _addDrawings(BuildContext context, WidgetRef ref) async {
  final List<XFile> picked = await ExternalActivity.run(
    () => ImagePicker().pickMultiImage(requestFullMetadata: false),
  );
  if (picked.isEmpty) return;

  final DataDoLote lote = await _dataDosArquivos(
    ref,
    picked.map((XFile f) => f.path).toList(),
  );
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    lote: lote,
    type: EntryType.drawing,
    files: picked
        .map((XFile f) => PendingFile(path: f.path, kind: EntryType.drawing))
        .toList(),
    message: 'Guardando o desenho...',
  );
}

Future<void> _addVideos(BuildContext context, WidgetRef ref) async {
  // `image_picker` só escolhe um vídeo por vez; o `file_picker` permite
  // vários de uma vez, que é o que a especificação pede.
  final FilePickerResult? result = await ExternalActivity.run(
    () => FilePicker.pickFiles(type: FileType.video, allowMultiple: true),
  );
  final List<PlatformFile> files = result?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return;

  final DataDoLote lote = await _dataDosArquivos(ref, <String>[
    for (final PlatformFile f in files)
      if (f.path != null) f.path!,
  ]);
  if (!context.mounted) return;

  await _send(
    context,
    ref,
    lote: lote,
    type: EntryType.video,
    files: files
        .where((PlatformFile f) => f.path != null)
        .map(
          (PlatformFile f) =>
              PendingFile(path: f.path!, kind: EntryType.video, name: f.name),
        )
        .toList(),
    message: 'Convertendo para 540p e enviando...',
  );
}

Future<void> _addDocuments(BuildContext context, WidgetRef ref) async {
  final FilePickerResult? result = await ExternalActivity.run(
    () => FilePicker.pickFiles(allowMultiple: true),
  );
  final List<PlatformFile> files = result?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return;

  final DataDoLote lote = await _dataDosArquivos(ref, <String>[
    for (final PlatformFile f in files)
      if (f.path != null) f.path!,
  ]);
  if (!context.mounted) return;

  final ({String uid, BabyProfile profile})? ctx = _context(ref);
  if (ctx == null) {
    showMessage(context, S.genericError);
    return;
  }

  // Cada documento vira uma entrada com o nome do próprio arquivo, então o
  // envio é um por vez. A pergunta, não: confirmar cinco vezes seguidas é o
  // jeito mais rápido de a pessoa parar de ler o que está confirmando.
  final DateTime? confirmada = await confirmarEnvio(
    context,
    g: Copy.of(ctx.profile),
    profile: ctx.profile,
    type: EntryType.document,
    quantidade: files.length,
    lote: lote,
  );
  if (confirmada == null || !context.mounted) return;

  for (final PlatformFile file in files) {
    if (file.path == null) continue;
    if (!context.mounted) return;
    await _send(
      context,
      ref,
      lote: DataDoLote(quando: confirmada, lida: false, diasDiferentes: 1),
      confirmar: false,
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
  required DataDoLote lote,
  required EntryType type,
  required List<PendingFile> files,
  required String message,
  String? title,
  bool keepSheetOpen = false,
  bool confirmar = true,
}) async {
  final ({String uid, BabyProfile profile})? ctx = _context(ref);
  if (ctx == null) {
    showMessage(context, S.genericError);
    return;
  }
  if (files.isEmpty) return;

  DateTime data = lote.quando;
  if (confirmar) {
    final DateTime? confirmada = await confirmarEnvio(
      context,
      g: Copy.of(ctx.profile),
      profile: ctx.profile,
      type: type,
      quantidade: files.length,
      lote: lote,
    );
    if (confirmada == null || !context.mounted) return;
    data = confirmada;
  }

  if (!keepSheetOpen) Navigator.of(context).pop();

  try {
    final Entry entry = await ref
        .read(memoryRepositoryProvider)
        .addFiles(
          uid: ctx.uid,
          profile: ctx.profile,
          type: type,
          files: files,
          date: data,
          title: title,
        );
    if (!context.mounted) return;

    // Documento não tem pasta de idade para apontar: ele vai para a lista de
    // documentos e pronto.
    if (type == EntryType.document) {
      showMessage(context, message);
      return;
    }

    // A janela acompanha o envio até o fim e termina apontando a pasta.
    //
    // Antes era uma tarja de seis segundos que dizia que o envio começou e
    // nunca dizia que terminou. Quem mandasse uma foto e trocasse de tela
    // não descobria se deu certo, e principalmente não descobria **onde** a
    // foto foi parar: numa cápsula organizada por idade, esse "onde" é
    // metade da informação.
    await mostrarEnvio(
      context,
      entry: entry,
      bucket: AgeCalculator.bucketAt(ctx.profile.birth, data),
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
      padding: const EdgeInsets.only(bottom: Space.x12),
      child: Material(
        color: type.soft(context),
        borderRadius: Radii.buttonR,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.buttonR,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.x16,
              vertical: Space.x16,
            ),
            child: Row(
              children: <Widget>[
                Icon(type.icon, color: type.accent(context), size: 24),
                const SizedBox(width: Space.x16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: text.titleSmall),
                      const SizedBox(height: Space.x4),
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
