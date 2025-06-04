import 'package:edukativna_igra/level_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'modules/memory/memory_game_screen.dart';
import 'modules/colors/colors_game_screen.dart';
import 'modules/sounds/sounds_game_screen.dart';
import 'modules/counting/counting_game_screen.dart';
import 'modules/matching/matching_game_screen.dart';
import 'modules/missing/missing_game_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // Level selection routes
    GoRoute(
      path: '/memory-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'memory',
        moduleTitle: 'Pamti me',
        moduleColor: Colors.purple,
      ),
    ),
    GoRoute(
      path: '/colors-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'colors',
        moduleTitle: 'Prepoznaj boju',
        moduleColor: Colors.orange,
      ),
    ),
    GoRoute(
      path: '/sounds-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'sounds',
        moduleTitle: 'Ko to govori?',
        moduleColor: Colors.green,
      ),
    ),
    GoRoute(
      path: '/counting-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'counting',
        moduleTitle: 'Koliko ima?',
        moduleColor: Colors.teal,
      ),
    ),
    GoRoute(
      path: '/matching-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'matching',
        moduleTitle: 'Poveži parove',
        moduleColor: Colors.deepPurple,
      ),
    ),
    GoRoute(
      path: '/missing-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'missing',
        moduleTitle: 'Šta nedostaje?',
        moduleColor: Colors.amber,
      ),
    ),
    // Game routes with level parameter
    GoRoute(
      path: '/memory',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return MemoryGameScreen(level: level);
      },
    ),
    GoRoute(
      path: '/colors',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return ColorsGameScreen(level: level);
      },
    ),
    // GoRoute(
    //   path: '/sounds',
    //   builder: (context, state) {
    //     final levelParam = state.uri.queryParameters['level'];
    //     final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
    //     return SoundsGameScreen(level: level);
    //   },
    // ),
    // GoRoute(
    //   path: '/counting',
    //   builder: (context, state) {
    //     final levelParam = state.uri.queryParameters['level'];
    //     final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
    //     return CountingGameScreen(level: level);
    //   },
    // ),
    GoRoute(
      path: '/matching',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return MatchingGameScreen(level: level);
      },
    ),
    // GoRoute(
    //   path: '/missing',
    //   builder: (context, state) {
    //     final levelParam = state.uri.queryParameters['level'];
    //     final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
    //     return MissingGameScreen(level: level);
    //   },
    // ),
  ],
);
