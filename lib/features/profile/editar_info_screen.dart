import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/error_text.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_gender.dart';
import '../../models/baby_profile.dart';
import '../../core/theme/app_palette.dart';
import '../../state/providers.dart';

/// Corrige o cadastro feito na primeira abertura.
///
/// Existe porque o cadastro acontece no pior momento possível para exigir
/// exatidão: com um recém-nascido em casa, de madrugada, com o cartão do
/// hospital em algum lugar da bolsa. Errar o peso por um zero, digitar o
/// nome sem acento ou pular a hora é o caso comum, não a exceção.
///
/// Sem esta tela a única saída era apagar a conta e começar de novo, o que
/// numa cápsula do tempo significa perder tudo por causa de um acento.
class EditarInfoScreen extends ConsumerStatefulWidget {
  const EditarInfoScreen({super.key});

  @override
  ConsumerState<EditarInfoScreen> createState() => _EditarInfoScreenState();
}

class _EditarInfoScreenState extends ConsumerState<EditarInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _peso = TextEditingController();
  final TextEditingController _altura = TextEditingController();
  final TextEditingController _hospital = TextEditingController();

  BabyGender? _genero;
  DateTime? _nascimento;
  TimeOfDay? _hora;

  /// Preenchido uma vez, quando o perfil chega.
  ///
  /// Sem esta trava o formulário se reescreveria a cada atualização do
  /// Firestore, e o que a pessoa está digitando some no meio da frase.
  bool _carregado = false;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _peso.dispose();
    _altura.dispose();
    _hospital.dispose();
    super.dispose();
  }

  void _carregar(BabyProfile profile) {
    if (_carregado) return;
    _carregado = true;
    _nome.text = profile.name;
    _genero = profile.gender;
    _nascimento = profile.birth;
    // Meia-noite aqui quer dizer "não informada", e é assim que o
    // Informacoes.txt já trata: mostrar 00:00 no campo faria a pessoa achar
    // que a hora está preenchida e sair sem informar a de verdade.
    _hora = profile.birth.hour == 0 && profile.birth.minute == 0
        ? null
        : TimeOfDay.fromDateTime(profile.birth);
    _peso.text = profile.birthWeightGrams == null
        ? ''
        : Fmt.weightInput(profile.birthWeightGrams!);
    _altura.text = profile.birthHeightCm == null
        ? ''
        : Fmt.decimalInput(profile.birthHeightCm!);
    _hospital.text = profile.hospital ?? '';
  }

  Future<void> _escolherData() async {
    final DateTime agora = DateTime.now();
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _nascimento ?? agora,
      firstDate: DateTime(agora.year - 25),
      lastDate: agora,
      helpText: S.birthDate,
    );
    if (escolhida != null) setState(() => _nascimento = escolhida);
  }

  Future<void> _escolherHora() async {
    final TimeOfDay? escolhida = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: S.birthTime,
    );
    if (escolhida != null) setState(() => _hora = escolhida);
  }

  Future<void> _salvar(BabyProfile atual) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final DateTime? data = _nascimento;
    final BabyGender? genero = _genero;
    if (data == null || genero == null) return;

    final String? uid = ref.read(uidProvider);
    if (uid == null) return;

    final TimeOfDay hora = _hora ?? const TimeOfDay(hour: 0, minute: 0);
    // `copyWith` a partir do perfil atual, e não um `BabyProfile` novo: os
    // ids do Drive (pasta raiz, foto, Informacoes.txt) não aparecem neste
    // formulário, e recriar o objeto do zero os apagaria em silêncio. O
    // acervo continuaria no Drive, e o aplicativo deixaria de achá-lo.
    final BabyProfile novo = atual.copyWith(
      name: _nome.text.trim(),
      gender: genero,
      birth: DateTime(data.year, data.month, data.day, hora.hour, hora.minute),
      birthWeightGrams: Fmt.parseWeightGrams(_peso.text),
      birthHeightCm: Fmt.parseDecimal(_altura.text),
      hospital: _hospital.text.trim().isEmpty ? null : _hospital.text.trim(),
      clearWeight: Fmt.parseWeightGrams(_peso.text) == null,
      clearHeight: Fmt.parseDecimal(_altura.text) == null,
      clearHospital: _hospital.text.trim().isEmpty,
    );

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await ref.read(memoryRepositoryProvider).atualizarCadastro(uid, novo);
      if (mounted) {
        context.canPop() ? context.pop() : context.go(Routes.babyInfo);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _salvando = false;
          _erro = userMessage(e, context: S.saveInfo);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _carregar(profile);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.editInfo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.babyInfo),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _salvando,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.x20,
              Space.x16,
              Space.x20,
              Space.scrollEnd,
            ),
            children: <Widget>[
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: S.fullName),
                validator: (String? v) =>
                    (v ?? '').trim().isEmpty ? 'Escreva o nome' : null,
              ),
              const SizedBox(height: Space.x16),
              _Escolha(
                label: S.birthDate,
                valor: _nascimento == null ? null : Fmt.longDate(_nascimento!),
                vazio: 'Escolher a data',
                onTap: _escolherData,
              ),
              const SizedBox(height: Space.x12),
              _Escolha(
                label: S.birthTime,
                valor: _hora?.format(context),
                vazio: S.notProvided,
                onTap: _escolherHora,
              ),
              const SizedBox(height: Space.x16),
              SegmentedButton<BabyGender>(
                segments: const <ButtonSegment<BabyGender>>[
                  ButtonSegment<BabyGender>(
                    value: BabyGender.girl,
                    label: Text('Menina'),
                  ),
                  ButtonSegment<BabyGender>(
                    value: BabyGender.boy,
                    label: Text('Menino'),
                  ),
                ],
                selected: <BabyGender>{?_genero},
                emptySelectionAllowed: true,
                onSelectionChanged: (Set<BabyGender> s) =>
                    setState(() => _genero = s.firstOrNull),
              ),
              const SizedBox(height: Space.x16),
              TextFormField(
                controller: _peso,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: S.birthWeight,
                  hintText: '3,250',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: Space.x16),
              TextFormField(
                controller: _altura,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: S.birthHeight,
                  hintText: '49',
                  suffixText: 'cm',
                ),
              ),
              const SizedBox(height: Space.x16),
              TextFormField(
                controller: _hospital,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Hospital'),
              ),
              if (_erro case final String erro) ...<Widget>[
                const SizedBox(height: Space.x16),
                Text(
                  erro,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppPalette.danger),
                ),
              ],
              const SizedBox(height: Space.x24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      onPressed: _salvando ? null : () => context.pop(),
                      child: Text(S.cancel),
                    ),
                  ),
                  const SizedBox(width: Space.x12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _salvando ? null : () => _salvar(profile),
                      child: Text(
                        _salvando ? 'Salvando...' : S.save,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um campo que não se digita: abre um seletor e mostra o que foi escolhido.
class _Escolha extends StatelessWidget {
  const _Escolha({
    required this.label,
    required this.valor,
    required this.vazio,
    required this.onTap,
  });

  final String label;
  final String? valor;
  final String vazio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.fieldR,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(valor ?? vazio),
      ),
    );
  }
}
