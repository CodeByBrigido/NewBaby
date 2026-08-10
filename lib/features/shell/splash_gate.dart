import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../state/providers.dart';

/// A cor da abertura, tirada do próprio ícone.
///
/// Não vem da paleta da criança de propósito: esta tela aparece antes de
/// existir cadastro, e é a única imagem de marca do aplicativo. Ela também
/// está no `launch_background.xml` do Android, para que não haja um piscar
/// branco entre a tela do sistema e esta.
const Color corDaAbertura = Color(0xFFD2664F);

/// Caminho do ícone usado na abertura.
///
/// Se o arquivo ainda não estiver no projeto, a tela desenha o coração
/// simples no lugar dele. Uma imagem faltando não pode impedir o aplicativo
/// de abrir.
const String iconeDaAbertura = 'assets/icone.png';

/// Quanto tempo a abertura fica no mínimo.
///
/// Existe um piso porque a tela tem uma função além de esperar: ela é a
/// primeira impressão da marca. Sem piso, num aparelho rápido com sessão já
/// restaurada, ela apareceria por dois quadros e daria a impressão de
/// falha.
const Duration tempoMinimoDaAbertura = Duration(milliseconds: 1400);

/// E quanto tempo no máximo.
///
/// A espera é pela restauração da sessão, que depende de rede. Sem teto,
/// uma rede ruim transformaria a abertura em tela travada, que é
/// exatamente o que ela existe para evitar.
const Duration tempoMaximoDaAbertura = Duration(seconds: 4);

/// Cobre o aplicativo enquanto a sessão é restaurada.
///
/// Fica acima do roteador: assim o redirecionamento acontece por baixo, sem
/// ninguém ver o pulo de login para cadastro para linha do tempo.
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  bool _tempoMinimoPassou = false;
  bool _prazoEstourou = false;
  bool _saiu = false;

  Timer? _minimo;
  Timer? _maximo;

  @override
  void initState() {
    super.initState();
    _minimo = Timer(tempoMinimoDaAbertura, () {
      if (mounted) setState(() => _tempoMinimoPassou = true);
    });
    _maximo = Timer(tempoMaximoDaAbertura, () {
      if (mounted) setState(() => _prazoEstourou = true);
    });
  }

  @override
  void dispose() {
    _minimo?.cancel();
    _maximo?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Depois de sair, a abertura não volta: uma reconexão no meio do uso
    // não pode cobrir a tela de novo.
    if (!_saiu) {
      final bool sessaoResolvida = !ref.watch(authStateProvider).isLoading;
      _saiu =
          (_tempoMinimoPassou && sessaoResolvida) ||
          (_prazoEstourou && _tempoMinimoPassou);
    }

    return Stack(
      children: <Widget>[
        widget.child,
        // `IgnorePointer` para que o toque não atravesse durante a saída, e
        // `AnimatedOpacity` porque um corte seco entre marca e conteúdo é a
        // diferença entre "abriu" e "piscou".
        IgnorePointer(
          ignoring: _saiu,
          child: AnimatedOpacity(
            opacity: _saiu ? 0 : 1,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            child: const AberturaTela(),
          ),
        ),
      ],
    );
  }
}

/// A tela da abertura: só o ícone, centralizado, sobre a cor da marca.
class AberturaTela extends StatelessWidget {
  const AberturaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: corDaAbertura,
      child: Center(
        child: SizedBox(
          width: 132,
          height: 132,
          child: Image.asset(
            iconeDaAbertura,
            fit: BoxFit.contain,
            errorBuilder: (BuildContext context, Object _, StackTrace? _) =>
                const _IconeDeReserva(),
          ),
        ),
      ),
    );
  }
}

/// Enquanto o arquivo do ícone não existir.
class _IconeDeReserva extends StatelessWidget {
  const _IconeDeReserva();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: Radii.tileR(132),
      ),
      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 64),
    );
  }
}
