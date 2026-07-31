import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';

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
      if (mounted) showMessage(context, 'Não foi possível baixar: $e');
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(EntryFile file) async {
    final File? local = await _fetch(file);
    if (local == null) return;
    final OpenResult result = await OpenFilex.open(local.path);
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
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[XFile(local.path)]),
    );
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
    await ref.read(memoryRepositoryProvider).moveToTrash(uid, entry);
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
        body: const EmptyState(
          icon: Icons.description_outlined,
          title: 'Documento não encontrado',
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
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(entry),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: <Widget>[
          Center(
            child: Container(
              width: 120,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.documentSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                file?.extensionLabel ?? 'DOC',
                style: text.headlineSmall?.copyWith(
                  color: AppColors.document,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            entry.title ?? file?.name ?? S.documents,
            textAlign: TextAlign.center,
            style: text.titleMedium,
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 28),
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
                const SizedBox(width: 10),
                Expanded(
                  child: _Button(
                    icon: Icons.download_outlined,
                    label: S.download,
                    busy: _busy,
                    onTap: () => _download(file),
                  ),
                ),
                const SizedBox(width: 10),
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
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 22, color: AppColors.primaryDark),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
