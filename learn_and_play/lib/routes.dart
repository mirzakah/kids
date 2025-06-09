import 'package:edukativna_igra/level_selection_screen.dart';
import 'package:edukativna_igra/modules/categorization/categorization_game_screen.dart';
import 'package:edukativna_igra/modules/color_shape_sorting/color_shape_sorting_screen.dart';
import 'package:edukativna_igra/modules/emotions/emotions-game-screen.dart';
import 'package:edukativna_igra/modules/profession/profession_game_screen.dart';
import 'package:edukativna_igra/modules/sorting/sorting_game_screen.dart';
import 'package:edukativna_igra/modules/odd_one_out/odd_one_out_game_screen.dart';
import 'package:edukativna_igra/modules/simple_math/simple_math_game_screen.dart';
import 'package:edukativna_igra/modules/counting_tap/counting_tap_game_screen.dart';
import 'package:edukativna_igra/modules/letter_learning/letter_learning_game_screen.dart';
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
    GoRoute(
      path: '/sorting-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'sorting',
        moduleTitle: 'Sortiraj po veličini',
        moduleColor: Colors.cyan,
      ),
    ),
    // NEW: Color/Shape sorting levels
    GoRoute(
      path: '/color_shape-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'color_shape',
        moduleTitle: 'Sortiraj po boji/obliku',
        moduleColor: Colors.pink,
      ),
    ),
    // NEW: Odd One Out levels
    GoRoute(
      path: '/odd_one_out-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'odd_one_out',
        moduleTitle: 'Koji ne pripada?',
        moduleColor: Colors.amber,
      ),
    ),
    // NEW: Simple Math levels
    GoRoute(
      path: '/simple_math-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'simple_math',
        moduleTitle: 'Jednostavna matematika',
        moduleColor: Colors.blue,
      ),
    ),
    // NEW: Counting Tap levels
    GoRoute(
      path: '/counting_tap-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'counting_tap',
        moduleTitle: 'Brojanje sa kretanjem',
        moduleColor: Colors.green,
      ),
    ),
    // NEW: Letter Learning levels
    GoRoute(
      path: '/letter_learning-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'letter_learning',
        moduleTitle: 'Učimo slova',
        moduleColor: Colors.purple,
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
    GoRoute(
      path: '/sounds',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return SoundsGameScreen(level: level);
      },
    ),
    GoRoute(
      path: '/counting',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return CountingGameScreen(level: level);
      },
    ),
    GoRoute(
      path: '/matching',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return MatchingGameScreen(level: level);
      },
    ),
    GoRoute(
      path: '/missing',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return MissingGameScreen(level: level);
      },
    ),
    GoRoute(
      path: '/sorting',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return SortingGameScreen(level: level);
      },
    ),
    // NEW: Color/Shape sorting game
    GoRoute(
      path: '/color_shape',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return ColorShapeSortingGameScreen(level: level);
      },
    ),
    // NEW: Odd One Out game
    GoRoute(
      path: '/odd_one_out',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return OddOneOutGameScreen(level: level);
      },
    ),
    // NEW: Simple Math game
    GoRoute(
      path: '/simple_math',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return SimpleMathGameScreen(level: level);
      },
    ),
    // NEW: Counting Tap game
    GoRoute(
      path: '/counting_tap',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return CountingTapGameScreen(level: level);
      },
    ),
    // NEW: Letter Learning game
    GoRoute(
      path: '/letter_learning',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return LetterLearningGameScreen(level: level);
      },
    ),
    GoRoute(
      path: '/professions-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'professions',
        moduleTitle: 'Profesije',
        moduleColor: Colors.blue,
      ),
    ),

// Profesije game
    GoRoute(
      path: '/professions',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return ProfessionsGameScreen(level: level);
      },
    ),
    GoRoute(
      path: '/emotions-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'emotions',
        moduleTitle: 'Prepoznaj emocije',
        moduleColor: Colors.purple,
      ),
    ),

// Emotions game
    GoRoute(
      path: '/emotions',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return EmotionsGameScreen(level: level);
      },
    ),

    GoRoute(
      path: '/categorization-levels',
      builder: (context, state) => const LevelSelectionScreen(
        moduleId: 'categorization',
        moduleTitle: 'Grupiši po kategoriji',
        moduleColor: Colors.green,
      ),
    ),

// Categorization game
    GoRoute(
      path: '/categorization',
      builder: (context, state) {
        final levelParam = state.uri.queryParameters['level'];
        final level = levelParam != null ? int.tryParse(levelParam) ?? 1 : 1;
        return CategorizationGameScreen(level: level);
      },
    ),
  ],
);
