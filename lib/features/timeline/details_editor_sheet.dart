import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Dá nome a uma memória depois que ela já foi guardada.
///
/// O envio continua sendo de dois toques, sem formulário: quem quiser dizer
/// que aquele lote era o "Primeiro sorriso" faz isso aqui, quando quiser,
/// pela linha do tempo ou pelo aviso que aparece logo após o envio.
Future<void> showDetailsEditor(BuildContext context, Entry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _DetailsEditor(entry: entry),
    ),
  );
}

class _DetailsEditor extends ConsumerStatefulWidget {
  const _DetailsEditor({required this.entry});

  final Entry entry;

  @override
  ConsumerState<_DetailsEditor> createState() => _DetailsEditorState();
}

class _DetailsEditorState extends ConsumerState<_DetailsEditor> {
  late final TextEditingController _title = TextEditingController(
    text: widget.entry.title ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.entry.description ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(memoryRepositoryProvider)
          .updateDetails(
            uid,
            widget.entry,
            title: _title.text,
            description: _description.text,
          );
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, userMessage(e, context: 'Salvar detalhes'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.milestoneOptional,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: S.titleField,
                hintText: 'Primeiro sorriso',
              ),
            ),
            const SizedBox(height: 12),
            // Atalhos para os marcos que quase toda família registra.
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: S.milestoneSuggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final String suggestion = S.milestoneSuggestions[index];
                  return ActionChip(
                    label: Text(suggestion),
                    backgroundColor: AppColors.primarySoft,
                    labelStyle: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AppColors.primaryDark),
                    onPressed: () => setState(() {
                      _title.text = suggestion;
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: S.descriptionOptional,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text(S.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(S.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
