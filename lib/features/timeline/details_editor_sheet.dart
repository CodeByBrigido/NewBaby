import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/limits.dart';
import '../../core/theme/app_palette.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../core/utils/formatters.dart';
import '../../state/providers.dart';
import '../sealed/seal_sheet.dart';
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
  late DateTime? _sealedUntil = widget.entry.sealedUntil;
  bool _sealChanged = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String? uid = ref.read(uidProvider);
    if (uid == null) return;
    final BabyProfile? profile = ref.read(profileProvider).value;

    setState(() => _saving = true);
    try {
      await ref
          .read(memoryRepositoryProvider)
          .updateDetails(
            uid,
            widget.entry,
            title: _title.text,
            description: _description.text,
            sealedUntil: _sealedUntil,
            changeSeal: _sealChanged,
            // Marcar uma carta pela linha do tempo também precisa regravar o
            // arquivo: é a mesma carta.
            profile: profile,
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
        padding: const EdgeInsets.fromLTRB(
          Space.x20,
          Space.x12,
          Space.x20,
          Space.x20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.cores.divider,
                  borderRadius: Radii.pillR,
                ),
              ),
            ),
            const SizedBox(height: Space.x20),
            Text(
              S.milestoneOptional,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Space.x16),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: S.titleField,
                hintText: S.titleHintExample,
              ),
            ),
            const SizedBox(height: Space.x12),
            // Atalhos para os marcos que quase toda família registra.
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: S.milestoneSuggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: Space.x8),
                itemBuilder: (BuildContext context, int index) {
                  final String suggestion = S.milestoneSuggestions[index];
                  return ActionChip(
                    label: Text(suggestion),
                    backgroundColor: context.cores.primarySoft,
                    labelStyle: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: context.cores.primaryDark),
                    onPressed: () => setState(() {
                      _title.text = suggestion;
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: Space.x16),
            TextField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLength: Limits.description,
              maxLines: 3,
              decoration: InputDecoration(
                counterText: '',
                labelText: S.descriptionOptional,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: Space.x8),
            _SealRow(
              until: _sealedUntil,
              onTap: () async {
                final SealChoice? escolha = await showSealSheet(
                  context,
                  profile: ref.read(profileProvider).value,
                  current: _sealedUntil,
                );
                if (escolha == null) return;
                setState(() {
                  _sealedUntil = escolha.until;
                  _sealChanged = true;
                });
              },
            ),
            const SizedBox(height: Space.x20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(S.cancel),
                  ),
                ),
                const SizedBox(width: Space.x12),
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
                        : Text(S.save),
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

/// A linha que abre a escolha da data de abertura.
///
/// Fica junto do título e da descrição, e não escondida num menu, porque
/// decidir lacrar é uma decisão do mesmo momento em que se decide o que
/// escrever - depois, ninguém volta para procurar.
class _SealRow extends StatelessWidget {
  const _SealRow({required this.until, required this.onTap});

  final DateTime? until;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool lacrado = until != null;
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.fieldR,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.x12),
        child: Row(
          children: <Widget>[
            Icon(
              lacrado ? Icons.lock_clock : Icons.lock_open_outlined,
              size: 20,
              color: lacrado
                  ? context.cores.primary
                  : context.cores.textSecondary,
            ),
            const SizedBox(width: Space.x12),
            Expanded(
              child: Text(
                lacrado ? S.opensOn(Fmt.longDate(until!)) : S.keepForFuture,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: context.cores.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
