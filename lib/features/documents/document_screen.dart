import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import 'nome_do_documento.dart';
import '../../core/utils/error_text.dart';

/// Detalhe de um documento: abrir, baixar ou compartilhar.
class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({required this.entryId, super.key});

  final String entryId;

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  bool _busy = false;

  Future<File?> _fetch(EntryFile file) async {
    setState(() => _busy = true);
    try {
      return await ref.read(memoryRepositoryProvider).localCopy(file);
    } on Exception catch (e) {
      if (mounted) {
        showMessage(context, userMessage(e, context: 'Baixar documento'));
      }
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(EntryFile file) async {
    final File? local = await _fetch(file);
    if (local == null) return;
    final OpenResult result = await ExternalActivity.run(
      () => OpenFilex.open(local.path),
    );
    if (result.type != ResultType.done && mounted) {
      showMessage(context, 'Nenhum aplicativo consegue abrir este arquivo.');
    }
  }

  Future<void> _download(EntryFile file) async {
    final File? local = await _fetch(file);
    if (local == null || !mounted) return;
    showMessage(context, 'Salvo em ${local.path}');
  }

  Future<void> _share(EntryFile file) async {
    final File? local = await _fetch(file);
    if (local == null || !mounted) return;
    await ExternalActivity.run(
      () => SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(local.path)]),
      ),
    );
  }

  /// Troca o nome que a lista mostra. O arquivo no Drive não muda.
  Future<void> _renomear(Entry entry) async {
    final String? nome = await perguntarNomeDoDocumento(
      context,
      sugestao: entry.title ?? entry.coverFile?.name ?? '',
      titulo: 'Renomear documento',
    );
    if (nome == null || !mounted) return;
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    await ref.read(memoryRepositoryProvider).renomear(uid, entry.id, nome);
  }

  Future<void> _delete(Entry entry) async {
    final bool confirmed = await confirm(
      context,
      title: S.deleteConfirmTitle,
      message: S.deleteConfirmBody,
      confirmLabel: S.delete,
    );
    if (!confirmed) return;
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    await ref
        .read(memoryRepositoryProvider)
        .moveToTrash(uid, entry, profile: ref.read(profileProvider).value);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final Entry? entry = ref
        .watch(entriesProvider)
        .value
        ?.firstWhereOrNull((Entry e) => e.id == widget.entryId);
    final TextTheme text = Theme.of(context).textTheme;

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: EmptyState(
          icon: Icons.description_outlined,
          title: S.documentNotFound,
        ),
      );
    }

    final EntryFile? file = entry.coverFile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.documents),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.drive_file_rename_outline),
            tooltip: 'Renomear',
            onPressed: () => _renomear(entry),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: S.delete,
            onPressed: () => _delete(entry),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.x20,
          Space.x16,
          Space.x20,
          Space.x32,
        ),
        children: <Widget>[
          Center(
            child: Container(
              width: 120,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.cores.documentSoft,
                borderRadius: Radii.buttonR,
              ),
              child: Text(
                file?.extensionLabel ?? 'DOC',
                style: text.headlineSmall?.copyWith(
                  color: context.cores.document,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.x20),
          Text(
            entry.title ?? file?.name ?? S.documents,
            textAlign: TextAlign.center,
            style: text.titleMedium,
          ),
          const SizedBox(height: Space.x24),
          SoftCard(
            child: Column(
              children: <Widget>[
                _Row(label: 'Adicionado em', value: Fmt.date(entry.date)),
                if (file != null && file.sizeBytes > 0) ...<Widget>[
                  const Divider(height: 24),
                  _Row(label: 'Tamanho', value: Fmt.bytes(file.sizeBytes)),
                ],
              ],
            ),
          ),
          const SizedBox(height: Space.block),
          if (file != null)
            Row(
              children: <Widget>[
                Expanded(
                  child: _Button(
                    icon: Icons.visibility_outlined,
                    label: S.view,
                    busy: _busy,
                    onTap: () => _open(file),
                  ),
                ),
                const SizedBox(width: Space.x12),
                Expanded(
                  child: _Button(
                    icon: Icons.download_outlined,
                    label: S.download,
                    busy: _busy,
                    onTap: () => _download(file),
                  ),
                ),
                const SizedBox(width: Space.x12),
                Expanded(
                  child: _Button(
                    icon: Icons.ios_share,
                    label: S.share,
                    busy: _busy,
                    onTap: () => _share(file),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: text.bodySmall),
        Text(value, style: text.titleSmall),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.busy,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cores.primarySoft,
      borderRadius: Radii.mediaR,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: Radii.mediaR,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.x16),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 22, color: context.cores.primaryDark),
              const SizedBox(height: Space.x8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.cores.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
