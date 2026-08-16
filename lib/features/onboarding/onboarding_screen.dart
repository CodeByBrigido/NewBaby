import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/copy.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/limits.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_gender.dart';
import '../../models/baby_profile.dart';
import '../../services/lock_service.dart';
import '../../state/providers.dart';
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

  /// A última falha, mantida na tela até a próxima tentativa.
  String? _erro;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _hospital.dispose();
    super.dispose();
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
    // Nome, sexo e data validam juntos, e o formulário marca cada campo que
    // faltou. Antes o sexo e a data eram conferidos aqui, um de cada vez,
    // com aviso no rodapé: quem deixasse os dois em branco corrigia um,
    // tocava de novo, e só então descobria o outro.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final BabyGender? gender = _gender;
    final DateTime? date = _birthDate;
    if (gender == null || date == null) return;

    final String? uid = ref.read(uidProvider);
    if (uid == null) return;

    final TimeOfDay time = _birthTime ?? const TimeOfDay(hour: 0, minute: 0);
    final BabyProfile profile = BabyProfile(
      name: _name.text.trim(),
      gender: gender,
      birth: DateTime(date.year, date.month, date.day, time.hour, time.minute),
      birthWeightGrams: Fmt.parseWeightGrams(_weight.text),
      birthHeightCm: Fmt.parseDecimal(_height.text),
      hospital: _hospital.text.trim().isEmpty ? null : _hospital.text.trim(),
    );

    setState(() {
      _saving = true;
      _erro = null;
    });
    // Segura o roteador até o servidor responder. Sem isto ele sai daqui
    // assim que o Firestore grava no cache local, e uma recusa do servidor
    // dois segundos depois devolve a pessoa a um formulário vazio, sem
    // mensagem nenhuma: o aviso teria sido escrito nesta tela, que já não
    // existe mais.
    final CadastroEmAndamento porta = ref.read(
      cadastroEmAndamentoProvider.notifier,
    );
    porta.comecou();
    try {
      await ref
          .read(memoryRepositoryProvider)
          .setUpBaby(uid: uid, profile: profile, birthPhoto: _photo);
      // O roteador leva para a linha do tempo assim que a porta abre.
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _erro = userMessage(e, context: 'Concluir cadastro');
        });
      }
    } finally {
      porta.terminou();
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
              padding: const EdgeInsets.fromLTRB(
                Space.x24,
                Space.x32,
                Space.x24,
                Space.x32,
              ),
              children: <Widget>[
                Text(
                  S.onboardingGreeting,
                  textAlign: TextAlign.center,
                  style: text.headlineMedium,
                ),
                const SizedBox(height: Space.x8),
                Text(
                  // Antes de escolher menino ou menina o texto é neutro.
                  Copy.generic.onboardingSubtitle,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: context.cores.textSecondary,
                  ),
                ),
                const SizedBox(height: Space.block),
                Center(
                  child: _PhotoPicker(photo: _photo, onTap: _pickPhoto),
                ),
                const SizedBox(height: Space.block),
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
                const SizedBox(height: Space.x16),
                FormField<BabyGender>(
                  initialValue: _gender,
                  // Some assim que a pessoa escolhe. Sem isto, a mensagem
                  // fica ali depois de o campo já estar certo, e ela passa a
                  // acusar quem acabou de acertar.
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (BabyGender? v) =>
                      v == null ? S.requiredField : null,
                  builder: (FormFieldState<BabyGender> campo) => _ComErro(
                    erro: campo.errorText,
                    child: _GenderPicker(
                      value: _gender,
                      temErro: campo.hasError,
                      onChanged: (BabyGender g) {
                        setState(() => _gender = g);
                        campo.didChange(g);
                        // A paleta do aplicativo inteiro segue esta escolha
                        // na hora, antes de o cadastro existir. É a primeira
                        // vez que a pessoa vê a cor da própria filha.
                        ref.read(generoEscolhidoProvider.notifier).escolher(g);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: Space.x16),
                FormField<DateTime>(
                  initialValue: _birthDate,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (DateTime? v) =>
                      v == null ? S.requiredField : null,
                  builder: (FormFieldState<DateTime> campo) => _ComErro(
                    erro: campo.errorText,
                    child: _PickerField(
                      label: S.birthDate,
                      value: _birthDate == null ? null : Fmt.date(_birthDate!),
                      icon: Icons.calendar_today_outlined,
                      temErro: campo.hasError,
                      onTap: () async {
                        await _pickDate();
                        campo.didChange(_birthDate);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: Space.x16),
                _PickerField(
                  label: S.birthTimeOptional,
                  value: _birthTime == null
                      ? null
                      : '${_birthTime!.hour.toString().padLeft(2, '0')}:'
                            '${_birthTime!.minute.toString().padLeft(2, '0')}',
                  icon: Icons.schedule_outlined,
                  onTap: _pickTime,
                ),
                const SizedBox(height: Space.x16),
                TextFormField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[_decimalFormatter],
                  decoration: const InputDecoration(
                    labelText: S.birthWeightOptional,
                    suffixText: 'kg',
                  ),
                  validator: (String? v) =>
                      Fmt.parseWeightGrams(v ?? '') == null &&
                          (v ?? '').isNotEmpty
                      ? S.invalidNumber
                      : null,
                ),
                const SizedBox(height: Space.x16),
                TextFormField(
                  controller: _height,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[_decimalFormatter],
                  decoration: const InputDecoration(
                    labelText: S.birthHeightOptional,
                    suffixText: 'cm',
                  ),
                  validator: (String? v) =>
                      Fmt.parseDecimal(v ?? '') == null && (v ?? '').isNotEmpty
                      ? S.invalidNumber
                      : null,
                ),
                const SizedBox(height: Space.x16),
                TextFormField(
                  controller: _hospital,
                  textCapitalization: TextCapitalization.words,
                  maxLength: Limits.hospital,
                  decoration: const InputDecoration(
                    labelText: S.hospitalOptional,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: Space.x32),
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
                  const SizedBox(height: Space.x16),
                  Text(
                    S.preparingDrive,
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),
                ],
                // A falha fica na tela, e não some sozinha como o aviso de
                // rodapé. Aqui a pessoa está parada: sem o cadastro não há
                // aplicativo, e um recado que dura quatro segundos é um
                // recado que ela vai ler pela metade e reler tocando de novo.
                if (_erro != null) ...<Widget>[
                  const SizedBox(height: Space.x16),
                  Text(
                    _erro!,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: AppPalette.danger),
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

/// Aceita `3,250` e `3.250` - brasileiro digita com vírgula.
final TextInputFormatter _decimalFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[0-9.,]'),
);

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
            decoration: BoxDecoration(
              color: context.cores.primarySoft,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: photo == null
                ? Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: context.cores.primaryDark,
                  )
                : Image.file(photo!, fit: BoxFit.cover),
          ),
          const SizedBox(height: Space.x12),
          Text(S.birthPhoto, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Menino ou menina - define a concordância de todos os textos do app.
class _GenderPicker extends StatelessWidget {
  const _GenderPicker({
    required this.value,
    required this.onChanged,
    this.temErro = false,
  });

  final BabyGender? value;
  final ValueChanged<BabyGender> onChanged;

  /// Pinta a borda de erro enquanto nada foi escolhido e o formulário já
  /// foi conferido. Sem isso, a mensagem embaixo não diz a qual dos campos
  /// em branco ela pertence.
  final bool temErro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.gender, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: Space.x8),
        Row(
          children: <Widget>[
            for (final BabyGender gender in BabyGender.values) ...<Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: Space.x16),
                    decoration: BoxDecoration(
                      color: value == gender
                          ? context.cores.primarySoft
                          : context.cores.surface,
                      borderRadius: Radii.fieldR,
                      border: Border.all(
                        color: value == gender
                            ? context.cores.primary
                            : (temErro
                                  ? AppPalette.error
                                  : context.cores.divider),
                        width: value == gender ? 1.6 : 1,
                      ),
                    ),
                    child: Text(
                      gender.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: value == gender
                            ? context.cores.primaryDark
                            : context.cores.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              if (gender != BabyGender.values.last)
                const SizedBox(width: Space.x12),
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
    this.temErro = false,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;
  final bool temErro;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.fieldR,
      child: InputDecorator(
        // `errorText` vazio, e nao a mensagem: quem escreve a mensagem e o
        // `_ComErro`, embaixo, e o Material desenharia as duas. O que se
        // quer daqui e so a borda no estado de erro, que sai do tema e nao
        // de uma cor escolhida na mao.
        decoration: InputDecoration(
          labelText: label,
          errorText: temErro ? '' : null,
          errorStyle: const TextStyle(fontSize: 0, height: 0),
          suffixIcon: Icon(icon, size: 20),
        ),
        child: Text(value ?? '', style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

/// Um campo que não é `TextFormField` mostrando a mensagem de erro dele.
///
/// O Material desenha isso sozinho num campo de texto, e não num seletor.
/// Sem este envelope, o sexo e a data em branco só se anunciavam por um
/// aviso no rodapé da tela, longe do campo que faltou preencher, e quem
/// tivesse deixado os dois em branco descobria um de cada vez.
class _ComErro extends StatelessWidget {
  const _ComErro({required this.child, this.erro});

  final Widget child;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    if (erro == null) return child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        child,
        const SizedBox(height: Space.x8),
        Padding(
          // O mesmo recuo que o Material dá à mensagem de um campo de texto,
          // para as duas ficarem na mesma coluna.
          padding: const EdgeInsets.only(left: Space.x12),
          child: Text(
            erro!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.error),
          ),
        ),
      ],
    );
  }
}
