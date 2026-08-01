import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gendered.dart';
import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Escrever ou editar uma carta. Só dois campos — título e mensagem.
class LetterEditorScreen extends ConsumerStatefulWidget {
  const LetterEditorScreen({super.key, this.entryId});

  /// `null` cria uma carta nova.
  final String? entryId;

  @override
  ConsumerState<LetterEditorScreen> createState() => _LetterEditorScreenState();
}

class _LetterEditorScreenState extends ConsumerState<LetterEditorScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _message = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Entry? get _existing {
    final String? id = widget.entryId;
    if (id == null) return null;
    return ref
        .watch(entriesProvider)
        .value
        ?.firstWhereOrNull((Entry e) => e.id == id);
  }

  Future<void> _save() async {
    final String title = _title.text.trim();
    final String message = _message.text.trim();
    if (title.isEmpty && message.isEmpty) {
      showMessage(context, 'Escreva alguma coisa antes de salvar.');
      return;
    }

    final String? uid = ref.read(uidProvider);
    final BabyProfile? profile = ref.read(profileProvider).value;
    if (uid == null || profile == null) return;

    setState(() => _saving = true);
    try {
      final Entry? existing = _existing;
      if (existing == null) {
        await ref
            .read(memoryRepositoryProvider)
            .addLetter(
              uid: uid,
              profile: profile,
              title: title.isEmpty ? 'Carta' : title,
              message: message,
            );
      } else {
        await ref
            .read(memoryRepositoryProvider)
            .updateDetails(
              uid,
              existing,
              title: title.isEmpty ? 'Carta' : title,
              description: message,
            );
      }
      if (mounted) {
        context.canPop() ? context.pop() : context.go(Routes.letters);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, userMessage(e, context: 'Salvar carta'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Entry? existing = _existing;
    if (existing != null && !_loaded) {
      _title.text = existing.title ?? '';
      _message.text = existing.description ?? '';
      _loaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'Nova carta' : 'Editar carta'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.letters),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text(S.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: InputDecoration(
                labelText: S.titleField,
                hintText: G
                    .of(ref.watch(profileProvider).value?.gender)
                    .letterHint,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _message,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.6),
                decoration: const InputDecoration(
                  labelText: S.messageField,
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
