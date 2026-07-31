import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/entry.dart';
import 'providers.dart';

/// Texto digitado na busca.
final NotifierProvider<SearchQuery, String> searchQueryProvider =
    NotifierProvider<SearchQuery, String>(SearchQuery.new);

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
  void clear() => state = '';
}

/// Categoria selecionada na busca; `null` significa "todas".
final NotifierProvider<SearchCategory, EntryType?> searchCategoryProvider =
    NotifierProvider<SearchCategory, EntryType?>(SearchCategory.new);

class SearchCategory extends Notifier<EntryType?> {
  @override
  EntryType? build() => null;

  void toggle(EntryType type) => state = state == type ? null : type;
  void clear() => state = null;
}

/// Resultado da busca.
///
/// A filtragem é feita em memória, sobre o cache local do Firestore: sem
/// ida ao servidor, o resultado aparece enquanto a pessoa digita.
final Provider<List<Entry>> searchResultsProvider = Provider<List<Entry>>((
  Ref ref,
) {
  final String query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final EntryType? category = ref.watch(searchCategoryProvider);
  final List<Entry> all =
      ref.watch(entriesProvider).value ?? const <Entry>[];

  if (query.isEmpty && category == null) return const <Entry>[];

  // Cada palavra digitada precisa aparecer em algum lugar da entrada, o que
  // deixa "primeiro sorriso" encontrar "Primeiro sorriso da manhã".
  final List<String> terms = query.split(RegExp(r'\s+'))
    ..removeWhere((String t) => t.isEmpty);

  return all.where((Entry entry) {
    if (category != null && entry.type != category) return false;
    if (terms.isEmpty) return true;
    final String haystack = entry.searchable;
    return terms.every(haystack.contains);
  }).toList();
});

/// Buscas recentes, guardadas no aparelho.
final AsyncNotifierProvider<RecentSearches, List<String>>
recentSearchesProvider =
    AsyncNotifierProvider<RecentSearches, List<String>>(RecentSearches.new);

class RecentSearches extends AsyncNotifier<List<String>> {
  static const String _key = 'buscas_recentes';
  static const int _max = 8;

  @override
  Future<List<String>> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const <String>[];
  }

  Future<void> remember(String term) async {
    final String value = term.trim();
    if (value.isEmpty) return;

    final List<String> current = List<String>.from(state.value ?? const <String>[])
      ..removeWhere((String t) => t.toLowerCase() == value.toLowerCase())
      ..insert(0, value);
    final List<String> trimmed = current.take(_max).toList();

    state = AsyncData<List<String>>(trimmed);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, trimmed);
  }

  Future<void> clear() async {
    state = const AsyncData<List<String>>(<String>[]);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
