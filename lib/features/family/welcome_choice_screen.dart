import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';

/// A primeira pergunta, e a única vez que ela é feita.
///
/// O aplicativo não tem como adivinhar se quem acabou de entrar é o pai
/// começando a cápsula da filha ou a avó que recebeu um código. Então
/// pergunta, uma vez, com as duas respostas do mesmo tamanho e sem
/// vocabulário de sistema: ninguém aqui é "administrador" nem "convidado".
///
/// Quem escolhe errado volta: a escolha não grava nada, só leva para a tela
/// seguinte.
class WelcomeChoiceScreen extends ConsumerWidget {
  const WelcomeChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(flex: 2),
              Text('Bem-vindo', style: text.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'Antes de começar, uma pergunta só.',
                style: text.bodyLarge?.copyWith(
                  color: context.cores.textSecondary,
                ),
              ),
              const Spacer(),
              _Escolha(
                icone: Icons.child_care_outlined,
                titulo: 'Vou guardar as memórias',
                descricao:
                    'Esta cápsula é do seu filho ou da sua filha. Você guarda '
                    'as fotos, as cartas e os primeiros dias, e escolhe quem '
                    'mais pode ver.',
                onTap: () => context.go(Routes.onboarding),
              ),
              const SizedBox(height: 14),
              _Escolha(
                icone: Icons.mail_outline,
                titulo: 'Recebi um convite',
                descricao:
                    'Alguém da família dividiu a cápsula com você e te passou '
                    'um código. Você vai poder acompanhar, sem precisar '
                    'guardar nada.',
                onTap: () => context.go(Routes.redeem),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _Escolha extends StatelessWidget {
  const _Escolha({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: context.cores.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.cores.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.cores.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icone, color: context.cores.primaryDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(titulo, style: text.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      descricao,
                      style: text.bodySmall?.copyWith(
                        color: context.cores.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
