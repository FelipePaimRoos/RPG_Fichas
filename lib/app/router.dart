import 'package:app_flutter/features/characters/presentation/screens/characters_screen.dart';
import 'package:app_flutter/features/characters/presentation/screens/sheet_screen.dart';
import 'package:go_router/go_router.dart';

/// Rotas do app: dashboard em `/` e ficha em `/ficha/:id` (deep link
/// direto, como o doc pede).
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CharactersScreen(),
    ),
    GoRoute(
      path: '/ficha/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return SheetScreen(characterId: id);
      },
    ),
  ],
);
