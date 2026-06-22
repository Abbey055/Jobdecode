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
import '../features/splash/presentation/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const SplashScreen()),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
    ),
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) {
        final jobUrl = state.uri.queryParameters['url'] ?? '';
        return NoTransitionPage(
          key: state.pageKey,
          child: AnalysisLoadingScreen(jobUrl: jobUrl),
        );
      },
    ),
    GoRoute(
      path: '/summary',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const JobSummaryScreen()),
    ),
    GoRoute(
      path: '/wants',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const JobWantsScreen()),
    ),
    GoRoute(
      path: '/description',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const JobDescriptionScreen(),
      ),
    ),
    GoRoute(
      path: '/fit',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const FitScreen()),
    ),
    GoRoute(
      path: '/full-description',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const FullDescriptionScreen(),
      ),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const HistoryScreen()),
    ),
    GoRoute(
      path: '/saved',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const SavedScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const ProfileScreen()),
    ),
    GoRoute(
      path: '/premium',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const PremiumScreen()),
    ),
  ],
);
