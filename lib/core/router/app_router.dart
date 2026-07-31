import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/documents/document_screen.dart';
import '../../features/documents/documents_screen.dart';
import '../../features/drawings/drawings_screen.dart';
import '../../features/gallery/bucket_screen.dart';
import '../../features/gallery/gallery_screen.dart';
import '../../features/growth/growth_chart_screen.dart';
import '../../features/growth/growth_screen.dart';
import '../../features/letters/letter_editor_screen.dart';
import '../../features/letters/letter_screen.dart';
import '../../features/letters/letters_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/about_screen.dart';
import '../../features/profile/baby_info_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/shell/home_shell.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/timeline/entry_detail_screen.dart';
import '../../features/trash/trash_screen.dart';
import '../../models/entry.dart';
import '../../state/providers.dart';

abstract final class Routes {
  static const String login = '/entrar';
  static const String onboarding = '/cadastro';
  static const String timeline = '/';
  static const String search = '/busca';
  static const String profile = '/perfil';
  static const String photos = '/fotos';
  static const String videos = '/videos';
  static const String letters = '/cartas';
  static const String drawings = '/desenhos';
  static const String documents = '/documentos';
  static const String growth = '/crescimento';
  static const String growthChart = '/crescimento/grafico';
  static const String stats = '/estatisticas';
  static const String trash = '/lixeira';
  static const String settings = '/configuracoes';
  static const String about = '/sobre';
  static const String babyInfo = '/perfil/bebe';
  static const String newLetter = '/cartas/nova';

  static String bucket(String type, String bucketKey) =>
      '/$type/balde/$bucketKey';
  static String entry(String id) => '/memoria/$id';
  static String letter(String id) => '/cartas/$id';
  static String editLetter(String id) => '/cartas/$id/editar';
  static String document(String id) => '/documentos/$id';
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  // O roteador precisa reavaliar o redirecionamento sempre que a sessão ou
  // o cadastro mudarem — é o que leva o usuário de login → cadastro → app.
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.listen(profileProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.timeline,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<Object?> auth = ref.read(authStateProvider);
      final AsyncValue<Object?> profile = ref.read(profileProvider);

      // Enquanto a sessão ainda está sendo restaurada, não mexe na rota.
      if (auth.isLoading) return null;

      final bool signedIn = ref.read(uidProvider) != null;
      final String location = state.matchedLocation;

      if (!signedIn) {
        return location == Routes.login ? null : Routes.login;
      }

      if (profile.isLoading) return null;
      final bool hasProfile = profile.value != null;

      if (!hasProfile) {
        return location == Routes.onboarding ? null : Routes.onboarding;
      }

      if (location == Routes.login || location == Routes.onboarding) {
        return Routes.timeline;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.timeline,
        builder: (_, _) => const HomeShell(),
      ),
      GoRoute(
        path: Routes.search,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: Routes.photos,
        builder: (_, _) => const GalleryScreen(type: EntryType.photo),
        routes: <RouteBase>[
          GoRoute(
            path: 'balde/:bucket',
            builder: (_, GoRouterState state) => BucketScreen(
              type: EntryType.photo,
              bucketKey: state.pathParameters['bucket']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.videos,
        builder: (_, _) => const GalleryScreen(type: EntryType.video),
        routes: <RouteBase>[
          GoRoute(
            path: 'balde/:bucket',
            builder: (_, GoRouterState state) => BucketScreen(
              type: EntryType.video,
              bucketKey: state.pathParameters['bucket']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.letters,
        builder: (_, _) => const LettersScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'nova',
            builder: (_, _) => const LetterEditorScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, GoRouterState state) =>
                LetterScreen(entryId: state.pathParameters['id']!),
            routes: <RouteBase>[
              GoRoute(
                path: 'editar',
                builder: (_, GoRouterState state) => LetterEditorScreen(
                  entryId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.drawings,
        builder: (_, _) => const DrawingsScreen(),
      ),
      GoRoute(
        path: Routes.documents,
        builder: (_, _) => const DocumentsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (_, GoRouterState state) =>
                DocumentScreen(entryId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.growth,
        builder: (_, _) => const GrowthScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'grafico',
            builder: (_, _) => const GrowthChartScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.stats,
        builder: (_, _) => const StatsScreen(),
      ),
      GoRoute(
        path: Routes.trash,
        builder: (_, _) => const TrashScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.about,
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: Routes.babyInfo,
        builder: (_, _) => const BabyInfoScreen(),
      ),
      GoRoute(
        path: '/memoria/:id',
        builder: (_, GoRouterState state) =>
            EntryDetailScreen(entryId: state.pathParameters['id']!),
      ),
    ],
  );
});
