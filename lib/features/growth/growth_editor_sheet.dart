import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Registrar peso e altura - três campos, um toque para salvar.
Future<void> showGrowthEditor(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const _GrowthEditor(),
    ),
  );
}

class _GrowthEditor extends ConsumerStatefulWidget {
  const _GrowthEditor();

  @override
  ConsumerState<_GrowthEditor> createState() => _GrowthEditorState();
}

class _GrowthEditorState extends ConsumerState<_GrowthEditor> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _height = TextEditingController();
  DateTime _date = DateTime.now();
  File? _photo;
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final BabyProfile? profile = ref.read(profileProvider).value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: profile?.birthDay ?? DateTime(DateTime.now().year - 20),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickPhoto() async {
    final XFile? picked = await ExternalActivity.run(
      () => ImagePicker().pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      ),
    );
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _save() async {
    final double? kg = _parse(_weight.text);
    final double? cm = _parse(_height.text);
    if (kg == null || cm == null) {
      showMessage(context, 'Informe o peso e a altura.');
      return;
    }

    final String? uid = ref.read(uidProvider);
    final BabyProfile? profile = ref.read(profileProvider).value;
    if (uid == null || profile == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(memoryRepositoryProvider)
          .addGrowth(
            uid: uid,
            profile: profile,
            weightGrams: (kg * 1000).round(),
            heightCm: cm,
            date: _date,
            photo: _photo,
          );
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, userMessage(e, context: 'Salvar crescimento'));
      }
    }
  }

  static double? _parse(String raw) {
    final double? value = double.tryParse(raw.trim().replaceAll(',', '.'));
    return (value == null || value <= 0) ? null : value;
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
            Text(S.addGrowth, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Space.x20),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _weight,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: S.weightField,
                      suffixText: 'kg',
                    ),
                  ),
                ),
                const SizedBox(width: Space.x12),
                Expanded(
                  child: TextField(
                    controller: _height,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: S.heightField,
                      suffixText: 'cm',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.x16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(Fmt.date(_date)),
                  ),
                ),
                const SizedBox(width: Space.x12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: _photo == null
                          ? null
                          : context.cores.primaryDark,
                    ),
                    icon: Icon(
                      _photo == null
                          ? Icons.add_photo_alternate_outlined
                          : Icons.check_circle_outline,
                      size: 18,
                    ),
                    label: Text(_photo == null ? S.photoOptional : 'Foto'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.x20),
            FilledButton(
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
          ],
        ),
      ),
    );
  }
}
