import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/inspiration.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import 'capa_da_postagem.dart';
import 'inspiration_article_screen.dart';

/// Busca dentro do blog, e só dentro dele.
///
/// A lupa da aba antes levava à busca do acervo, que procura fotos e cartas
/// no Drive. Eram duas coisas sem relação nenhuma: quem está lendo sobre a
/// primeira viagem não está procurando uma foto antiga.
///
/// Esta busca varre o catálogo **inteiro**, e não só o que vale hoje. A
/// lista da aba sugere, e sugerir algo de daqui a dois anos seria ruim; a
/// busca responde, e quem digitou "creche" quer a postagem sobre creche
/// mesmo que a criança tenha dois meses. As que ainda não chegaram vêm
/// marcadas, para a leitura não parecer um convite fora de hora.
class InspirationSearchScreen extends ConsumerStatefulWidget {
  const InspirationSearchScreen({super.key});

  @override
  ConsumerState<InspirationSearchScreen> createState() =>
      _InspirationSearchScreenState();
}

class _InspirationSearchScreenState
    extends ConsumerState<InspirationSearchScreen> {
  final TextEditingController _termo = TextEditingController();

  @override
  void dispose() {
    _termo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Inspiration> catalogo =
        ref.watch(inspirationCatalogProvider).value ?? const <Inspiration>[];
    final Set<String> ativasHoje =
        (ref.watch(inspirationsProvider).value ?? const <ActiveInspiration>[])
            .map((ActiveInspiration a) => a.inspiration.id)
            .toSet();

    final List<Inspiration> achadas = buscarInspiracoes(_termo.text, catalogo);
    final bool procurando = _termo.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _termo,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Buscar nas postagens...',
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: <Widget>[
          if (procurando)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Limpar',
              onPressed: () => setState(_termo.clear),
            ),
        ],
      ),
      body: !procurando
          ? EmptyState(
              icon: Icons.search,
              title: S.inspirationSearchHint,
              message:
                  'Procure por um assunto: sono, creche, viagem, festa, '
                  'carta, comida.',
            )
          : achadas.isEmpty
          ? EmptyState(
              icon: Icons.search_off,
              title: 'Nada sobre isso ainda',
              message: S.searchNoResults(_termo.text.trim()),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Space.x16,
                Space.x12,
                Space.x16,
                Space.scrollEnd,
              ),
              itemCount: achadas.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.x8),
              itemBuilder: (BuildContext context, int index) => _Resultado(
                inspiration: achadas[index],
                valeHoje: ativasHoje.contains(achadas[index].id),
              ),
            ),
    );
  }
}

class _Resultado extends StatelessWidget {
  const _Resultado({required this.inspiration, required this.valeHoje});

  final Inspiration inspiration;

  /// Se a postagem está entre as que a aba mostra hoje.
  final bool valeHoje;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: context.cores.surface,
      borderRadius: Radii.cardR,
      child: InkWell(
        borderRadius: Radii.cardR,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => InspirationArticleScreen(
              // Sem prazo: uma postagem achada pela busca não está numa
              // contagem regressiva, mesmo quando a versão de hoje na lista
              // está. Mostrar "faltam 3 dias" aqui seria inventar urgência.
              active: ActiveInspiration(inspiration: inspiration, relevance: 0),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(Space.x12),
          decoration: BoxDecoration(
            borderRadius: Radii.cardR,
            border: Border.all(color: context.cores.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 72,
                child: CapaDaPostagem(inspiration: inspiration, height: 72),
              ),
              const SizedBox(width: Space.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      inspiration.kind.label,
                      style: text.labelSmall?.copyWith(
                        color: context.cores.textSecondary,
                      ),
                    ),
                    const SizedBox(height: Space.x4),
                    Text(inspiration.title, style: text.titleSmall),
                    const SizedBox(height: Space.x4),
                    Text(
                      inspiration.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: context.cores.textSecondary,
                      ),
                    ),
                    // Dito, e não escondido: encontrar uma postagem de outra
                    // fase é útil, e deixar isso implícito faria a pessoa
                    // achar que está atrasada em alguma coisa.
                    if (!valeHoje) ...<Widget>[
                      const SizedBox(height: Space.x8),
                      Text(
                        'De outra fase',
                        style: text.labelSmall?.copyWith(
                          color: context.cores.muted,
                        ),
                      ),
                    ],
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
