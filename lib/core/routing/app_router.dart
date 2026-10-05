import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/breathing_grounding/presentation/screens/breathing_grounding_screen.dart';
import '../../features/check_in/presentation/screens/check_in_screen.dart';
import '../../features/gentle_progress/presentation/screens/gentle_progress_screen.dart';
import '../../features/journaling/presentation/controllers/journal_editor_controller.dart';
import '../../features/journaling/presentation/screens/journal_entry_screen.dart';
import '../../features/journaling/presentation/screens/journal_list_screen.dart';
import '../../features/loneliness_comfort/presentation/screens/loneliness_comfort_screen.dart';
import '../../features/onboarding/presentation/screens/biometric_lock_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/safety_plan/presentation/screens/panic_blank_screen.dart';
import '../../features/safety_plan/presentation/screens/safety_plan_editor_screen.dart';
import '../../features/safety_plan/presentation/screens/safety_plan_screen.dart';
import '../../features/soundscapes/presentation/screens/soundscape_library_screen.dart';
import '../../features/tiny_steps/presentation/screens/tiny_steps_screen.dart';
import '../../shared/widgets/main_shell_scaffold.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.checkIn,
    restorationScopeId: 'firefly_router',
    debugLogDiagnostics: false, // Never log routes in production
    routes: [
      GoRoute(
        path: AppRoutes.home,
        redirect: (context, state) => AppRoutes.checkIn,
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyLock,
        builder: (context, state) => const BiometricLockScreen(),
      ),

      // Rapid Panic Blank Route
      GoRoute(
        path: AppRoutes.panicBlank,
        builder: (context, state) => const PanicBlankScreen(),
      ),

      // Emergency Safety Plan: Full-screen modal over any route
      GoRoute(
        path: AppRoutes.safetyPlan,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SafetyPlanScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.safetyPlanEditor,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SafetyPlanEditorScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),

      // Main Shell: Bottom Navigation Shell
      ShellRoute(
        builder: (context, state, child) => MainShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.checkIn,
            builder: (context, state) => const CheckInScreen(),
          ),
          GoRoute(
            path: AppRoutes.breathe,
            builder: (context, state) => BreathingGroundingScreen(
              initialMode: state.uri.queryParameters['mode'],
            ),
          ),
          GoRoute(
            path: AppRoutes.journal,
            builder: (context, state) => const JournalListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  final ttlParam = state.uri.queryParameters['ttl'];
                  JournalTtlOption? initialTtl;
                  if (ttlParam == '1h') initialTtl = JournalTtlOption.oneHour;
                  if (ttlParam == '24h') initialTtl = JournalTtlOption.twentyFourHours;
                  if (ttlParam == '7d') initialTtl = JournalTtlOption.sevenDays;
                  return JournalEntryScreen(
                    entryId: id,
                    initialTtl: initialTtl,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.tinySteps,
            builder: (context, state) => const TinyStepsScreen(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (context, state) => const GentleProgressScreen(),
          ),
          GoRoute(
            path: AppRoutes.loneliness,
            builder: (context, state) => const LonelinessComfortScreen(),
          ),
          GoRoute(
            path: AppRoutes.soundscapes,
            builder: (context, state) => const SoundscapeLibraryScreen(),
          ),
        ],
      ),
    ],
  );
});
