import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/gendered.dart';
import '../../core/l10n/strings.dart';
import '../../core/utils/limits.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_gender.dart';
import '../../models/baby_profile.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../../core/utils/error_text.dart';

/// Cadastro inicial. Tudo que o aplicativo precisa para calcular idade,
/// escolher pastas e montar a linha do tempo sai daqui.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _hospital = TextEditingController();

  BabyGender? _gender;
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  File? _photo;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _hospital.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 25),
      lastDate: now,
      helpText: S.birthDate,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: S.birthTime,
    );
    if (picked != null) setState(() => _birthTime = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final BabyGender? gender = _gender;
    if (gender == null) {
      showMessage(context, 'Escolha se é menino ou menina.');
      return;
    }

    final DateTime? date = _birthDate;
    if (date == null) {
      showMessage(context, 'Escolha a data de nascimento.');
      return;
    }

    final String? uid = ref.read(uidProvider);
    if (uid == null) return;

    final TimeOfDay time = _birthTime ?? const TimeOfDay(hour: 0, minute: 0);
    final BabyProfile profile = BabyProfile(
      name: _name.text.trim(),
      gender: gender,
      birth: DateTime(date.year, date.month, date.day, time.hour, time.minute),
      birthWeightGrams: _parseWeightGrams(_weight.text),
      birthHeightCm: _parseDecimal(_height.text),
      hospital: _hospital.text.trim().isEmpty ? null : _hospital.text.trim(),
    );

    setState(() => _saving = true);
    try {
      await ref
          .read(memoryRepositoryProvider)
          .setUpBaby(uid: uid, profile: profile, birthPhoto: _photo);
      // O roteador leva para a linha do tempo assim que o perfil existe.
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, userMessage(e, context: 'Concluir cadastro'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _saving,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              children: <Widget>[
                Text(
                  S.onboardingGreeting,
                  textAlign: TextAlign.center,
                  style: text.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  // Antes de escolher menino ou menina o texto é neutro.
                  G.of(_gender).onboardingSubtitle,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: _PhotoPicker(photo: _photo, onTap: _pickPhoto),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  maxLength: Limits.babyName,
                  decoration: const InputDecoration(
                    labelText: S.fullName,
                    // O contador atrapalha mais do que ajuda num campo que
                    // ninguém chega perto de encher.
                    counterText: '',
                  ),
                  validator: (String? v) =>
                      (v == null || v.trim().isEmpty) ? S.requiredField : null,
                ),
                const SizedBox(height: 16),
                _GenderPicker(
                  value: _gender,
                  onChanged: (BabyGender g) => setState(() => _gender = g),
                ),
                const SizedBox(height: 16),
                _PickerField(
                  label: S.birthDate,
                  value: _birthDate == null ? null : Fmt.date(_birthDate!),
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                _PickerField(
                  label: S.birthTime,
                  value: _birthTime == null
                      ? null
                      : '${_birthTime!.hour.toString().padLeft(2, '0')}:'
                            '${_birthTime!.minute.toString().padLeft(2, '0')}',
                  icon: Icons.schedule_outlined,
                  onTap: _pickTime,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[_decimalFormatter],
                  decoration: const InputDecoration(
                    labelText: S.birthWeight,
                    suffixText: 'kg',
                  ),
                  validator: (String? v) =>
                      _parseWeightGrams(v ?? '') == null && (v ?? '').isNotEmpty
                      ? S.invalidNumber
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _height,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[_decimalFormatter],
                  decoration: const InputDecoration(
                    labelText: S.birthHeight,
                    suffixText: 'cm',
                  ),
                  validator: (String? v) =>
                      _parseDecimal(v ?? '') == null && (v ?? '').isNotEmpty
                      ? S.invalidNumber
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hospital,
                  textCapitalization: TextCapitalization.words,
                  maxLength: Limits.hospital,
                  decoration: const InputDecoration(
                    labelText: S.hospitalOptional,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(S.continueLabel),
                ),
                if (_saving) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    S.preparingDrive,
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aceita `3,250` e `3.250` — brasileiro digita com vírgula.
final TextInputFormatter _decimalFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[0-9.,]'),
);

double? _parseDecimal(String raw) {
  final String cleaned = raw.trim().replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final double? value = double.tryParse(cleaned);
  return (value == null || value <= 0) ? null : value;
}

/// Peso vem em quilos e é guardado em gramas, para não acumular erro de
/// ponto flutuante ao longo dos anos.
int? _parseWeightGrams(String raw) {
  final double? kg = _parseDecimal(raw);
  return kg == null ? null : (kg * 1000).round();
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photo, required this.onTap});

  final File? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            width: 116,
            height: 116,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: photo == null
                ? const Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: AppColors.primaryDark,
                  )
                : Image.file(photo!, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          Text(S.birthPhoto, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Menino ou menina — define a concordância de todos os textos do app.
class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.value, required this.onChanged});

  final BabyGender? value;
  final ValueChanged<BabyGender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.gender, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            for (final BabyGender gender in BabyGender.values) ...<Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: value == gender
                          ? AppColors.primarySoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: value == gender
                            ? AppColors.primary
                            : AppColors.divider,
                        width: value == gender ? 1.6 : 1,
                      ),
                    ),
                    child: Text(
                      gender.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: value == gender
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              if (gender != BabyGender.values.last) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

/// Campo que abre um seletor em vez de teclado.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, size: 20),
        ),
        child: Text(value ?? '', style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
