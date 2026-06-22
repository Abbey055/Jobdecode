import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/analysis/presentation/screens/analysis_loading_screen.dart';
import '../features/analysis/presentation/screens/fit_screen.dart';
import '../features/analysis/presentation/screens/full_description_screen.dart';
import '../features/analysis/presentation/screens/job_description_screen.dart';
import '../features/analysis/presentation/screens/job_summary_screen.dart';
import '../features/analysis/presentation/screens/job_wants_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/premium/presentation/premium_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/saved/presentation/saved_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
    ),
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) {
        final jobUrl = state.uri.queryParameters['url'] ?? '';
        return _fadePage(state.pageKey, AnalysisLoadingScreen(jobUrl: jobUrl));
      },
    ),
    GoRoute(
      path: '/summary',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const JobSummaryScreen()),
    ),
    GoRoute(
      path: '/wants',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const JobWantsScreen()),
    ),
    GoRoute(
      path: '/description',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const JobDescriptionScreen()),
    ),
    GoRoute(
      path: '/fit',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const FitScreen()),
    ),
    GoRoute(
      path: '/full-description',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const FullDescriptionScreen()),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const HistoryScreen()),
    ),
    GoRoute(
      path: '/saved',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const SavedScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const ProfileScreen()),
    ),
    GoRoute(
      path: '/premium',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const PremiumScreen()),
    ),
  ],
);

CustomTransitionPage<void> _fadePage(LocalKey key, Widget child) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
