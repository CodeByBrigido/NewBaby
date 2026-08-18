import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/copy.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/formatters.dart';
import '../../models/inspiration.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../inspirations/inspiration_art.dart';
import '../inspirations/inspiration_article_screen.dart';

/// Uma ideia por vez, tirada das inspirações que valem para hoje.
///
/// A tela inicial tinha uma grade de atalhos para as mesmas pastas que o menu
/// lateral já lista. Ela funcionava como índice, e índice a linha do tempo já
/// faz melhor. No lugar entra a única coisa que o aplicativo tem para
/// oferecer a quem abre num dia comum: uma ideia do que fazer com a criança
/// hoje.
///
/// **Muda a cada abertura, e não a cada segundo.** A ordem sai da relevância
/// que o catálogo já calcula contra a idade e o calendário, e o ponto de
/// partida vem de um sorteio feito uma vez por abertura. Assim quem abre duas
/// vezes no mesmo minuto vê a mesma coisa, e quem abre amanhã vê outra.
///
/// Dá para deslizar entre as ideias, porque uma pessoa que não gostou da
/// primeira não deveria ter que fechar o aplicativo para ver a próxima.
class CarrosselDeInspiracao extends ConsumerStatefulWidget {
  const CarrosselDeInspiracao({super.key});

  /// Quantas ideias entram no carrossel.
  ///
  /// Poucas de propósito: o catálogo devolve dezenas, e um carrossel sem fim
  /// vira uma segunda aba de inspirações dentro da tela inicial. Cinco é o
  /// bastante para haver o que deslizar e pouco para não virar navegação.
  static const int quantas = 5;

  @override
  ConsumerState<CarrosselDeInspiracao> createState() =>
      _CarrosselDeInspiracaoState();
}

class _CarrosselDeInspiracaoState extends ConsumerState<CarrosselDeInspiracao> {
  PageController? _controle;
  int _pagina = 0;

  @override
  void dispose() {
    _controle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ActiveInspiration> ativas =
        ref.watch(inspirationsProvider).value ?? const <ActiveInspiration>[];
    if (ativas.isEmpty) return const SizedBox.shrink();

    final List<ActiveInspiration> ideias = ativas
        .take(CarrosselDeInspiracao.quantas)
        .toList();

    // O ponto de partida do sorteio da abertura, resolvido só quando já se
    // sabe quantas ideias existem.
    final int inicial = ref.read(sementeDaAberturaProvider) % ideias.length;
    final PageController controle = _controle ??= PageController(
      initialPage: inicial,
    );
    if (_controle != null && _pagina == 0) _pagina = inicial;

    final Copy g = Copy.of(ref.watch(profileProvider).value);

    return Column(
      children: <Widget>[
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: controle,
            itemCount: ideias.length,
            onPageChanged: (int i) => setState(() => _pagina = i),
            itemBuilder: (BuildContext context, int i) =>
                _Cartao(ativa: ideias[i], g: g),
          ),
        ),
        if (ideias.length > 1) ...<Widget>[
          const SizedBox(height: Space.x12),
          _Pontinhos(quantos: ideias.length, atual: _pagina),
        ],
      ],
    );
  }
}

/// Uma ideia, do jeito que ela aparece na tela inicial.
class _Cartao extends StatelessWidget {
  const _Cartao({required this.ativa, required this.g});

  final ActiveInspiration ativa;
  final Copy g;

  /// O rótulo de cima, que diz por que esta ideia está aqui hoje.
  ///
  /// Com prazo, a ideia é sobre uma data que se aproxima, e quem precisa se
  /// preparar é o adulto. Sem prazo, ela é sobre a fase que a criança está
  /// vivendo agora.
  String get _sobrancelha {
    if (ativa.hasDeadline) return 'Para você';
    return g.hasName ? 'Para ${g.name}, agora' : 'Para viver agora';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Inspiration ideia = ativa.inspiration;
    final int? faltam = ativa.daysLeft;

    return Padding(
      // A folga da direita deixa a próxima ideia espiando na borda, que é o
      // que conta que dá para deslizar sem precisar de instrução escrita.
      padding: const EdgeInsets.only(right: Space.x12),
      child: Material(
        color: context.cores.surface,
        borderRadius: Radii.cardR,
        child: InkWell(
          borderRadius: Radii.cardR,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => InspirationArticleScreen(active: ativa),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(Space.x16),
            decoration: BoxDecoration(
              borderRadius: Radii.cardR,
              boxShadow: Shadows.level1,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Sobrancelha(_sobrancelha),
                          const SizedBox(height: Space.x8),
                          Text(
                            ideia.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall,
                          ),
                          const SizedBox(height: Space.x4),
                          Text(
                            // Com prazo, a contagem vale mais que o resumo:
                            // é ela que diz por que isto é hoje e não daqui a
                            // um mês.
                            faltam == null
                                ? ideia.summary
                                : 'Faltam ${Fmt.count(faltam, "dia", "dias")}.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              color: context.cores.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Ver inspiração',
                            style: text.labelLarge?.copyWith(
                              color: context.cores.primary,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: context.cores.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.x12),
                SizedBox(
                  width: 76,
                  child: InspirationArt(
                    kind: ideia.kind,
                    seed: ideia.id,
                    height: 76,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Os pontinhos que dizem em qual ideia se está.
class _Pontinhos extends StatelessWidget {
  const _Pontinhos({required this.quantos, required this.atual});

  final int quantos;
  final int atual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: Space.x4,
      children: <Widget>[
        for (int i = 0; i < quantos; i++)
          AnimatedContainer(
            duration: Motion.micro,
            width: i == atual ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == atual ? context.cores.primary : context.cores.border,
              borderRadius: Radii.pillR,
            ),
          ),
      ],
    );
  }
}
