import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/tokens.dart';
import '../../models/baby_profile.dart';
import '../../models/inspiration.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../shell/add_sheet.dart';
import 'inspiration_art.dart';
import 'inspiration_article_screen.dart';

/// Ideias do que fazer e do que guardar, escolhidas pela idade e pelo
/// calendário.
///
/// Não é um blog. Cada cartão é uma coisa que dá para fazer, e o que tem
/// data aparece na hora certa: as ideias para o primeiro aniversário chegam
/// três semanas antes, não no dia nem no ano passado.
class InspirationsScreen extends ConsumerWidget {
  const InspirationsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final AsyncValue<List<ActiveInspiration>> feed = ref.watch(
      inspirationsProvider,
    );
    final Set<String> lidas = ref.watch(readInspirationsProvider);
    final Copy copy = Copy.of(profile);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Inspirações'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar nas memórias',
            onPressed: () => context.push(Routes.search),
          ),
        ],
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => const EmptyState(
          icon: Icons.lightbulb_outline,
          title: 'Não deu para carregar as ideias',
          message: 'Tente abrir de novo daqui a pouco.',
        ),
        data: (List<ActiveInspiration> itens) {
          if (itens.isEmpty) {
            return const EmptyState(
              icon: Icons.lightbulb_outline,
              title: 'Nada por aqui agora',
              message: 'As ideias mudam conforme a idade. Volte em breve.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Space.x16,
              Space.x12,
              Space.x16,
              Space.scrollEnd,
            ),
            itemCount: itens.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: Space.x12),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) return _Intro(copy: copy);
              final ActiveInspiration a = itens[index - 1];
              return _Card(active: a, isNew: !lidas.contains(a.inspiration.id));
            },
          );
        },
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.copy});

  final Copy copy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x4),
      child: Text(
        copy.hasName
            ? 'Ideias para a fase que ${copy.theName} está vivendo agora.'
            : 'Ideias para a fase de agora.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: context.cores.textSecondary),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.active, required this.isNew});

  final ActiveInspiration active;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final Inspiration i = active.inspiration;
    final TextTheme text = Theme.of(context).textTheme;
    final (IconData icone, Color cor, Color fundo) = _visual(context, i.kind);

    return Material(
      color: context.cores.surface,
      borderRadius: Radii.cardR,
      child: InkWell(
        borderRadius: Radii.cardR,
        onTap: i.hasArticle
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InspirationArticleScreen(active: active),
                ),
              )
            : null,
        child: Container(
          padding: const EdgeInsets.all(Space.x16),
          decoration: BoxDecoration(
            borderRadius: Radii.cardR,
            border: Border.all(color: context.cores.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(Space.x8),
                    decoration: BoxDecoration(
                      color: fundo,
                      borderRadius: Radii.fieldR,
                    ),
                    child: Icon(icone, size: 18, color: cor),
                  ),
                  const SizedBox(width: Space.x12),
                  Expanded(
                    child: Text(
                      i.kind.label,
                      style: text.labelSmall?.copyWith(color: cor),
                    ),
                  ),
                  if (isNew) _NewBadge(),
                ],
              ),

              if (active.daysLeft case final int dias) ...<Widget>[
                const SizedBox(height: Space.x12),
                Text(
                  dias == 0
                      ? 'É hoje'
                      : dias == 1
                      ? 'Amanhã'
                      : 'Faltam $dias dias',
                  style: text.labelMedium?.copyWith(
                    color: context.cores.primaryDark,
                  ),
                ),
              ],

              if (i.hasArticle) ...<Widget>[
                const SizedBox(height: Space.x12),
                InspirationArt(kind: i.kind, seed: i.id, height: 108),
              ],

              const SizedBox(height: Space.x8),
              Text(i.title, style: text.titleSmall),
              const SizedBox(height: Space.x8),
              Text(i.summary, style: text.bodyMedium),

              if (i.hasArticle) ...<Widget>[
                const SizedBox(height: Space.x12),
                Row(
                  children: <Widget>[
                    Text(
                      'Ler as ideias',
                      style: text.labelLarge?.copyWith(
                        color: context.cores.primaryDark,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: context.cores.primaryDark,
                    ),
                  ],
                ),
              ] else if (i.suggests != null) ...<Widget>[
                const SizedBox(height: Space.x12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: () => showAddSheet(context),
                    child: const Text('Registrar agora'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x8,
        vertical: Space.x4,
      ),
      decoration: BoxDecoration(
        color: context.cores.primaryStrong,
        borderRadius: Radii.cardR,
      ),
      child: Text(
        'novo',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
    );
  }
}

(IconData, Color, Color) _visual(BuildContext context, InspirationKind kind) =>
    switch (kind) {
      InspirationKind.brincadeira => (
        Icons.toys_outlined,
        context.cores.photo,
        context.cores.photoSoft,
      ),
      InspirationKind.passeio => (
        Icons.park_outlined,
        context.cores.accent,
        context.cores.accentSoft,
      ),
      InspirationKind.foto => (
        Icons.photo_camera_outlined,
        context.cores.photo,
        context.cores.photoSoft,
      ),
      InspirationKind.carta => (
        Icons.mail_outline,
        context.cores.letter,
        context.cores.letterSoft,
      ),
      InspirationKind.leitura => (
        Icons.menu_book_outlined,
        context.cores.document,
        context.cores.documentSoft,
      ),
      InspirationKind.preparo => (
        Icons.cake_outlined,
        context.cores.primary,
        context.cores.primarySoft,
      ),
      InspirationKind.rotina => (
        Icons.schedule_outlined,
        context.cores.video,
        context.cores.videoSoft,
      ),
      InspirationKind.cuidado => (
        Icons.favorite_outline,
        context.cores.accent,
        context.cores.accentSoft,
      ),
    };
