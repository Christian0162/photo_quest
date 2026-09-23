import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/presentation/screen/camera/capture_screen.dart';
import '../../core/presentation/screen/camera/memory_reveal_screen.dart';
import '../../core/presentation/screen/home/home_screen.dart';
import '../../core/presentation/screen/memories/memories_screen.dart';
import '../../core/presentation/screen/memories/memory_detail_screen.dart';
import '../../core/presentation/screen/people/people_screen.dart';
import '../../core/presentation/screen/quests/create_quest_screen.dart';
import '../../core/presentation/screen/quests/quest_intro_screen.dart';
import '../../core/presentation/screen/quests/quest_selection_screen.dart';
import '../../core/presentation/screen/settings/settings_screen.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

/// Centralized route paths. Screens navigate through these constants
/// instead of hardcoding path strings. See CLAUDE.md §10.
abstract final class AppRoutes {
  static const home = '/';
  static const quests = '/quests';
  static const createQuest = '/quests/create';
  static const questDetail = '/quests/:questId';
  static const capture = '/capture/:sessionId';
  static const memoryReveal = '/capture/:sessionId/reveal';
  static const memories = '/memories';
  static const memoryDetail = '/memory/:memoryId';
  static const people = '/people';
  static const settings = '/settings';

  static String questDetailPath(String questId) => '/quests/$questId';
  static String capturePath(String sessionId) => '/capture/$sessionId';
  static String memoryRevealPath(String sessionId) =>
      '/capture/$sessionId/reveal';
  static String memoryDetailPath(String memoryId) => '/memory/$memoryId';
}

final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    navigatorKey: _shellNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.memories,
                builder: (context, state) => const MemoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.people,
                builder: (context, state) => const PeopleScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.quests,
        builder: (context, state) => const QuestSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.createQuest,
        builder: (context, state) => const CreateQuestScreen(),
      ),
      GoRoute(
        path: AppRoutes.questDetail,
        builder: (context, state) =>
            QuestIntroScreen(questId: state.pathParameters['questId']!),
      ),
      GoRoute(
        path: AppRoutes.capture,
        builder: (context, state) =>
            CaptureScreen(sessionId: state.pathParameters['sessionId']!),
      ),
      GoRoute(
        path: AppRoutes.memoryReveal,
        builder: (context, state) =>
            MemoryRevealScreen(sessionId: state.pathParameters['sessionId']!),
      ),
      GoRoute(
        path: AppRoutes.memoryDetail,
        builder: (context, state) =>
            MemoryDetailScreen(memoryId: state.pathParameters['memoryId']!),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
