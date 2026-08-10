/// O cartão entrando conforme a rolagem alcança ele.
///
/// Um cartão que já está desenhado quando chega à vista não diz nada. Um que
/// sobe alguns pixels e ganha opacidade diz "isto é novo aqui", e é o que
/// separa uma lista de arquivos de um acervo que se folheia.
///
/// A animação acontece **uma vez por item**, e não a cada vez que ele volta
/// à vista. Repetir a cada rolagem transformaria a lista num piscar contínuo
/// e deixaria a leitura mais lenta, que é o contrário do que se quer.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

class EntradaNaRolagem extends StatefulWidget {
  const EntradaNaRolagem({
    required this.indice,
    required this.child,
    super.key,
  });

  /// Posição na lista, que vira o atraso da entrada.
  final int indice;

  final Widget child;

  /// Quantos itens ainda ganham atraso antes de todos entrarem juntos.
  ///
  /// Sem teto, o vigésimo cartão esperaria quase um segundo, e quem abre o
  /// aplicativo para ver uma foto ficaria olhando o nada. Depois deste
  /// ponto a lista inteira já está fora da primeira tela de qualquer jeito.
  static const int escalonados = 6;

  /// O atraso entre um cartão e o seguinte.
  static const Duration passo = Duration(milliseconds: 45);

  @override
  State<EntradaNaRolagem> createState() => _EntradaNaRolagemState();
}

class _EntradaNaRolagemState extends State<EntradaNaRolagem> {
  bool _entrou = false;

  /// Guardado para poder ser cancelado.
  ///
  /// Um `Future.delayed` solto aqui continuaria vivo depois de o cartão sair
  /// da árvore, segurando este estado inteiro até disparar. Numa lista que a
  /// pessoa rola rápido, são dezenas deles pendurados de uma vez, e o
  /// ambiente de teste reprova por isso antes mesmo de virar problema em
  /// aparelho.
  Timer? _espera;

  @override
  void initState() {
    super.initState();

    // Sem animação no aparelho, o cartão já nasce no lugar. Não há atraso
    // nem transição: a lista aparece inteira, de uma vez.
    if (WidgetsBinding.instance.disableAnimations) {
      _entrou = true;
      return;
    }

    final int passos = widget.indice.clamp(0, EntradaNaRolagem.escalonados);
    _espera = Timer(EntradaNaRolagem.passo * passos, () {
      if (mounted) setState(() => _entrou = true);
    });
  }

  @override
  void dispose() {
    _espera?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      // Doze pixels, e não cem: o cartão precisa parecer que assentou, e não
      // que veio voando de fora da tela.
      offset: _entrou ? Offset.zero : const Offset(0, 0.06),
      duration: Motion.slide,
      curve: Motion.entrada,
      child: AnimatedOpacity(
        opacity: _entrou ? 1 : 0,
        duration: Motion.fade,
        curve: Motion.padrao,
        child: widget.child,
      ),
    );
  }
}
