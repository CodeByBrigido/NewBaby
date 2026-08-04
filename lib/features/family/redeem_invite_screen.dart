import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../models/family_access.dart';
import '../../services/firestore_service.dart';
import '../../state/providers.dart';

/// Onde o código de convite vira acesso.
///
/// A tela toda existe para uma pessoa que talvez nunca tenha "resgatado um
/// código" na vida. Por isso: um campo só, letras grandes, maiúsculas
/// automáticas, e nenhuma palavra de sistema. Quando dá certo, ela não volta
/// para cá nunca mais - o vínculo fica no servidor e o aplicativo abre
/// direto na cápsula.
class RedeemInviteScreen extends ConsumerStatefulWidget {
  const RedeemInviteScreen({super.key});

  @override
  ConsumerState<RedeemInviteScreen> createState() => _RedeemInviteScreenState();
}

class _RedeemInviteScreenState extends ConsumerState<RedeemInviteScreen> {
  final TextEditingController _codigo = TextEditingController();
  bool _ocupado = false;
  String? _erro;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _resgatar() async {
    final String codigo = _codigo.text.trim().toUpperCase();
    if (codigo.isEmpty) return;

    final String? uid = ref.read(uidProvider);
    final String? email = ref.read(emailProvider);
    if (uid == null || email == null) return;

    setState(() {
      _ocupado = true;
      _erro = null;
    });

    try {
      final FirestoreService firestore = ref.read(firestoreServiceProvider);
      final FamilyInvite? convite = await firestore.loadInvite(codigo);

      // Uma mensagem só para todos os casos de recusa, de propósito. Separar
      // "não existe" de "não é para você" contaria a quem digitou um código
      // ao acaso que ele acertou o código de outra pessoa.
      if (convite == null || !convite.usableAt(DateTime.now())) {
        setState(() {
          _erro =
              'Esse código não vale mais. Peça um novo para quem te chamou: '
              'os códigos valem por sete dias e servem uma vez só.';
          _ocupado = false;
        });
        return;
      }

      await firestore.redeemInvite(
        uid: uid,
        link: FamilyLink(
          ownerUid: convite.ownerUid,
          folderId: convite.folderId,
          email: email,
          code: convite.code,
          createdAt: DateTime.now(),
        ),
      );

      // Daqui em diante o roteador cuida: o vínculo chega pelo fluxo do
      // Firestore e a cápsula abre sozinha.
      if (mounted) context.go(Routes.timeline);
    } on Exception {
      if (!mounted) return;
      setState(() {
        _erro =
            'Não deu para confirmar agora. Verifique a internet e tente de '
            'novo.';
        _ocupado = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(Routes.welcome)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: <Widget>[
            Text('O código que te passaram', style: text.headlineSmall),
            const SizedBox(height: 10),
            Text(
              'São dez letras e números, em três pedaços. Não precisa se '
              'preocupar com maiúsculas.',
              style: text.bodyMedium?.copyWith(
                color: context.cores.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _codigo,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              enabled: !_ocupado,
              style: text.headlineSmall?.copyWith(letterSpacing: 2),
              decoration: const InputDecoration(
                hintText: 'AB-CDEF-GHJK',
                border: OutlineInputBorder(),
              ),
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(12),
                _UpperCase(),
              ],
              onSubmitted: (_) => _resgatar(),
            ),
            if (_erro != null) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppPalette.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _erro!,
                  style: text.bodySmall?.copyWith(
                    color: AppPalette.danger,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ocupado ? null : _resgatar,
              child: _ocupado
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar na cápsula'),
            ),
            const SizedBox(height: 28),
            Text(
              'O convite é feito para o seu endereço de email, então ele só '
              'funciona nesta conta. As fotos continuam guardadas no Google '
              'Drive de quem te chamou: você passa a poder vê-las, e nada '
              'mais.',
              style: text.bodySmall?.copyWith(
                color: context.cores.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deixa o código em maiúsculas enquanto se digita.
class _UpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antigo,
    TextEditingValue novo,
  ) => novo.copyWith(text: novo.text.toUpperCase());
}
