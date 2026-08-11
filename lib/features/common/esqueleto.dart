/// O esqueleto do conteúdo, no lugar da bolinha girando.
///
/// A bolinha diz "espere" e mais nada. O esqueleto diz o que vem: quantos
/// cartões, de que tamanho, com foto ou sem. Quando o conteúdo chega, ele
/// ocupa o lugar que já estava desenhado, e a tela não dá o salto que faz a
/// pessoa perder o que estava lendo.
///
/// A diferença não é de estética, é de tempo percebido: a mesma espera
/// parece mais curta quando há forma na tela.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';

/// Um bloco cinza que respira.
///
/// O brilho atravessa da esquerda para a direita em [Motion.esqueleto], que
/// é lento de propósito: rápido demais vira pisca-pisca e chama mais atenção
/// que o conteúdo que vai chegar.
class Esqueleto extends StatefulWidget {
  const Esqueleto({
    required this.largura,
    required this.altura,
    this.raio,
    super.key,
  });

  /// Um bloco de linha de texto, com a altura de uma linha da escala.
  const Esqueleto.linha({double largura = double.infinity, Key? key})
    : this(largura: largura, altura: 12, raio: 6, key: key);

  final double largura;
  final double altura;
  final double? raio;

  @override
  State<Esqueleto> createState() => _EsqueletoState();
}

class _EsqueletoState extends State<Esqueleto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: Motion.esqueleto,
  );

  @override
  void initState() {
    super.initState();
    // Quem desligou animações no aparelho recebe o bloco parado. Um brilho
    // que atravessa a tela sem parar é exatamente o tipo de movimento que
    // esse ajuste existe para remover.
    if (!WidgetsBinding.instance.disableAnimations) _pulso.repeat();
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = context.cores.surfaceMuted;
    final Color brilho = context.cores.background;

    return SizedBox(
      width: widget.largura,
      height: widget.altura,
      child: AnimatedBuilder(
        animation: _pulso,
        builder: (BuildContext context, Widget? _) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.raio ?? Radii.media),
            gradient: _pulso.isAnimating
                ? LinearGradient(
                    colors: <Color>[base, brilho, base],
                    stops: const <double>[0.1, 0.5, 0.9],
                    // O ponto de partida sai bem fora da esquerda e chega
                    // bem fora da direita, para o brilho entrar e sair em
                    // vez de aparecer e sumir no meio do bloco.
                    begin: Alignment(-2 + _pulso.value * 4, 0),
                    end: Alignment(_pulso.value * 4, 0),
                  )
                : null,
            color: _pulso.isAnimating ? null : base,
          ),
        ),
      ),
    );
  }
}

/// O esqueleto da linha do tempo: cabeçalho de dia e cartões.
class EsqueletoDaLinhaDoTempo extends StatelessWidget {
  const EsqueletoDaLinhaDoTempo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.page,
        Space.x16,
        Space.page,
        Space.scrollEnd,
      ),
      // Não rola: por baixo não há nada, e uma lista falsa que se arrasta
      // dá a impressão de que o conteúdo já chegou.
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        // Alinhado à esquerda de propósito. Numa lista vertical o filho
        // recebe a largura inteira como restrição apertada, e sem isto a
        // barra do dia atravessa a tela e parece um título, não uma data.
        const Align(
          alignment: Alignment.centerLeft,
          child: Esqueleto.linha(largura: 120),
        ),
        const SizedBox(height: Space.x16),
        // Três cartões bastam para encher a primeira tela de qualquer
        // telefone. Mais que isso é desenho que ninguém chega a ver.
        for (int i = 0; i < 3; i++) ...<Widget>[
          const _CartaoFantasma(),
          const SizedBox(height: Space.card),
        ],
      ],
    );
  }
}

/// A silhueta de um cartão da linha do tempo.
class _CartaoFantasma extends StatelessWidget {
  const _CartaoFantasma();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Space.x16),
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: Radii.cardR,
        border: Border.all(color: context.cores.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Esqueleto(
                largura: Sizes.iconSmall,
                altura: Sizes.iconSmall,
                raio: Radii.pill,
              ),
              const SizedBox(width: Space.x8),
              // Fração, e não largura fixa: o cartão muda de largura entre
              // um telefone e um tablet, e uma barra de 160 que sobra na
              // tela grande deixa de parecer uma linha de texto.
              const Expanded(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.62,
                  child: Esqueleto.linha(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.x12),
          const Esqueleto(largura: double.infinity, altura: 92),
        ],
      ),
    );
  }
}

/// O esqueleto de uma grade de miniaturas.
class EsqueletoDeGrade extends StatelessWidget {
  const EsqueletoDeGrade({this.colunas = 3, super.key});

  final int colunas;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(Space.x12),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas,
        crossAxisSpacing: Space.x8,
        mainAxisSpacing: Space.x8,
      ),
      itemCount: colunas * 4,
      itemBuilder: (BuildContext context, int _) =>
          const Esqueleto(largura: double.infinity, altura: double.infinity),
    );
  }
}
