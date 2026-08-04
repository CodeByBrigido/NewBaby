import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/copy.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../models/baby_profile.dart';
import '../../models/inspiration.dart';
import '../../state/providers.dart';
import '../common/widgets.dart';
import '../shell/add_sheet.dart';

/// Ideias do que fazer e do que guardar, escolhidas pela idade.
///
/// Não é um blog. Cada cartão é uma coisa que dá para fazer hoje, com o que
/// existe em casa, e quase sempre termina em algo que vale guardar. Texto
/// bonito sem ação vira leitura passiva, e este aplicativo não quer tempo de
/// tela: quer que a pessoa levante e vá brincar.
class InspirationsScreen extends ConsumerWidget {
  const InspirationsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final AsyncValue<List<Inspiration>> feed = ref.watch(inspirationsProvider);
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
        error: (Object e, _) => EmptyState(
          icon: Icons.lightbulb_outline,
          title: 'Não deu para carregar as ideias',
          message: 'Tente abrir de novo daqui a pouco.',
        ),
        data: (List<Inspiration> itens) {
          if (itens.isEmpty) {
            return const EmptyState(
              icon: Icons.lightbulb_outline,
              title: 'Nada por aqui agora',
              message: 'As ideias mudam conforme a idade. Volte em breve.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: itens.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) return _Intro(copy: copy);
              return _InspirationCard(item: itens[index - 1]);
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
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        copy.hasName
            ? 'Ideias para a fase que ${copy.theName} está vivendo agora.'
            : 'Ideias para a fase de agora.',
        style: text.bodyMedium?.copyWith(color: context.cores.textSecondary),
      ),
    );
  }
}

class _InspirationCard extends StatelessWidget {
  const _InspirationCard({required this.item});

  final Inspiration item;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final (IconData icone, Color cor, Color fundo) = _visual(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cores.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cores.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: fundo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, size: 18, color: cor),
              ),
              const SizedBox(width: 10),
              Text(
                item.kind.label,
                style: text.labelSmall?.copyWith(color: cor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: text.titleSmall),
          const SizedBox(height: 6),
          Text(item.body, style: text.bodyMedium),
          if (item.suggests != null) ...<Widget>[
            const SizedBox(height: 12),
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
    );
  }

  (IconData, Color, Color) _visual(BuildContext context) => switch (item.kind) {
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
    InspirationKind.cuidado => (
      Icons.favorite_outline,
      context.cores.audio,
      context.cores.audioSoft,
    ),
  };
}
