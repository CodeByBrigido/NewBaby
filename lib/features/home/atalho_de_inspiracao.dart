import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/copy.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/inspiration.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../inspirations/capa_da_postagem.dart';
import '../inspirations/inspiration_article_screen.dart';

/// Um atalho para uma postagem das inspirações, na tela inicial.
///
/// A grade de atalhos do Acervo saiu daqui porque era um terceiro caminho
/// para as mesmas pastas que o menu lateral lista e a linha do tempo
/// percorre. No lugar entra a única coisa que o aplicativo tem para oferecer
/// a quem abre num dia comum, sem nada para guardar: uma ideia do que fazer
/// com a criança hoje.
///
/// **Muda a cada abertura do aplicativo, e só nela.** Não desliza com o dedo:
/// a variedade vem de abrir o aplicativo de novo, e uma coisa que se move
/// enquanto a pessoa lê pede atenção que a tela inicial não deveria cobrar.
/// Quem quiser ver todas tem a aba de Inspirações inteira a um toque.
///
/// **Todo o conteúdo sai do arquivo da postagem.** O título, o resumo, a capa
/// e até a etiqueta de cima vêm de `assets/inspiracoes/<id>.json` e do `.webp`
/// ao lado dele. Não há texto escrito aqui dentro sobre nenhuma postagem
/// específica, e é isso que faz corrigir uma delas ser mexer num arquivo, sem
/// tocar em código.
class AtalhoDeInspiracao extends ConsumerWidget {
  const AtalhoDeInspiracao({super.key});

  /// De quantas ideias o sorteio escolhe.
  ///
  /// O catálogo devolve dezenas ordenadas por relevância, e sortear entre
  /// todas traria à tona a que combina menos com a fase da criança. O corte
  /// mantém o sorteio entre as que de fato valem para hoje.
  static const int entreAsPrimeiras = 8;

  /// A ideia da abertura, escolhida entre as mais relevantes.
  ///
  /// Função à parte, e pura, porque é a única regra aqui: dá para perguntar
  /// se ela varia entre aberturas e se ela aguenta uma lista de um item só,
  /// sem montar tela nenhuma.
  @visibleForTesting
  static ActiveInspiration? sorteada(
    List<ActiveInspiration> ativas,
    int semente,
  ) {
    if (ativas.isEmpty) return null;
    final int quantas = ativas.length < entreAsPrimeiras
        ? ativas.length
        : entreAsPrimeiras;
    // `abs` porque a semente é um instante em microssegundos, e o resto de um
    // número negativo em Dart também é negativo.
    return ativas[semente.abs() % quantas];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ActiveInspiration> ativas =
        ref.watch(inspirationsProvider).value ?? const <ActiveInspiration>[];

    final ActiveInspiration? ativa = sorteada(
      ativas,
      ref.watch(sementeDaAberturaProvider),
    );
    // Sem catálogo, o bloco some inteiro. Um cartão vazio é um buraco no meio
    // da tela inicial.
    if (ativa == null) return const SizedBox.shrink();

    final TextTheme text = Theme.of(context).textTheme;
    final Inspiration ideia = ativa.inspiration;
    final Copy g = Copy.of(ref.watch(profileProvider).value);

    return Material(
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
                  children: <Widget>[
                    Sobrancelha(etiquetaDe(ativa, g)),
                    const SizedBox(height: Space.x8),
                    Text(
                      ideia.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: Space.x4),
                    Text(
                      ideia.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: context.cores.textSecondary,
                      ),
                    ),
                    // A contagem entra como linha própria, e não no lugar do
                    // resumo: o resumo é o que a postagem tem a dizer, e a
                    // contagem é só o motivo de ela estar aparecendo hoje.
                    if (ativa.daysLeft case final int faltam) ...<Widget>[
                      const SizedBox(height: Space.x8),
                      Text(
                        faltam == 0
                            ? S.isToday
                            : 'Faltam ${S.contarDias(faltam)}',
                        style: text.labelSmall?.copyWith(
                          color: context.cores.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: Space.x16),
                    Row(
                      children: <Widget>[
                        Text(
                          S.seeInspiration,
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
              // A capa da própria postagem. Enquanto o `.webp` não existe,
              // `CapaDaPostagem` desenha a ilustração do tipo, então uma
              // postagem escrita hoje já aparece aqui e ganha a foto depois.
              SizedBox(
                width: 76,
                child: CapaDaPostagem(inspiration: ideia, height: 76),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O rótulo de cima do cartão.
///
/// Sai da postagem quando ela traz um, no campo `etiqueta`. É o caminho
/// preferido: quem escreve a postagem sabe melhor que qualquer regra por que
/// aquele texto merece a tela inicial.
///
/// Sem o campo, o cartão monta uma sozinho. Com prazo, a postagem aponta para
/// uma data que se aproxima e quem precisa se preparar é o adulto; sem prazo,
/// ela é sobre a fase que a criança está vivendo agora.
@visibleForTesting
String etiquetaDe(ActiveInspiration ativa, Copy g) {
  final String? daPostagem = ativa.inspiration.label;
  if (daPostagem != null) return daPostagem;
  if (ativa.hasDeadline) return S.forYou;
  return g.hasName ? 'Para ${g.name}, agora' : 'Para viver agora';
}
