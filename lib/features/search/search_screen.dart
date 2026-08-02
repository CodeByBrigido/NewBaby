import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/baby_profile.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';
import '../../state/search_providers.dart';
import '../common/drive_image.dart';
import '../common/widgets.dart';

/// Busca instantânea sobre o cache local - nada vai ao servidor.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.embedded = false});

  /// Dentro da barra inferior não há botão de voltar.
  final bool embedded;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    ref.read(searchQueryProvider.notifier).set(value);
    ref.read(recentSearchesProvider.notifier).remember(value);
  }

  @override
  Widget build(BuildContext context) {
    final String query = ref.watch(searchQueryProvider);
    final EntryType? category = ref.watch(searchCategoryProvider);
    final List<Entry> results = ref.watch(searchResultsProvider);
    final bool searching = query.trim().isNotEmpty || category != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.search),
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.timeline),
              ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: (String v) =>
                  ref.read(searchQueryProvider.notifier).set(v),
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: S.searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: searching
                ? _Results(results: results)
                : _Suggestions(
                    onPick: (String term) {
                      _controller.text = term;
                      _submit(term);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> recent =
        ref.watch(recentSearchesProvider).value ?? const <String>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: <Widget>[
        const SectionHeader(title: S.searchByCategory),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (final EntryType type in <EntryType>[
              EntryType.photo,
              EntryType.video,
              EntryType.letter,
              EntryType.drawing,
              EntryType.document,
            ])
              _CategoryButton(type: type),
          ],
        ),
        const SizedBox(height: 28),
        if (recent.isNotEmpty) ...<Widget>[
          SectionHeader(
            title: S.recentSearches,
            trailing: TextButton(
              onPressed: ref.read(recentSearchesProvider.notifier).clear,
              child: const Text(S.clearHistory),
            ),
          ),
          for (final String term in recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, size: 20),
              title: Text(term, style: Theme.of(context).textTheme.bodyMedium),
              trailing: const Icon(Icons.north_west, size: 16),
              onTap: () => onPick(term),
            ),
        ],
      ],
    );
  }
}

class _CategoryButton extends ConsumerWidget {
  const _CategoryButton({required this.type});

  final EntryType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool selected = ref.watch(searchCategoryProvider) == type;

    return GestureDetector(
      onTap: () => ref.read(searchCategoryProvider.notifier).toggle(type),
      child: Column(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: type.soft,
              borderRadius: BorderRadius.circular(16),
              border: selected
                  ? Border.all(color: type.accent, width: 2)
                  : null,
            ),
            child: Icon(type.icon, color: type.accent, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            type.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? type.accent : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.results});

  final List<Entry> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BabyProfile? profile = ref.watch(profileProvider).value;
    final TextTheme text = Theme.of(context).textTheme;

    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_outlined,
        title: S.searchEmpty,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final Entry entry = results[index];
        return SoftCard(
          padding: const EdgeInsets.all(10),
          onTap: () => _open(context, entry),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 48,
                height: 48,
                child: entry.coverFile != null
                    ? DriveThumbnail(
                        file: entry.coverFile!,
                        borderRadius: BorderRadius.circular(12),
                      )
                    : CategoryBadge(type: entry.type, size: 48),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.headline,
                      style: text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      <String>[
                        Fmt.date(entry.date),
                        if (profile != null)
                          profile.ageAt(entry.date).shortLabel,
                      ].join(' · '),
                      style: text.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _open(BuildContext context, Entry entry) {
    switch (entry.type) {
      case EntryType.letter:
        context.push(Routes.letter(entry.id));
      case EntryType.document:
        context.push(Routes.document(entry.id));
      case EntryType.growth:
        context.push(Routes.growth);
      case EntryType.birth:
      case EntryType.photo:
      case EntryType.video:
      case EntryType.drawing:
        context.push(Routes.entry(entry.id));
    }
  }
}
