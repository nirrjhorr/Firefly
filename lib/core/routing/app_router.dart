import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/breathing_grounding/presentation/screens/breathing_grounding_screen.dart';
import '../../features/check_in/presentation/screens/check_in_screen.dart';
import '../../features/gentle_progress/presentation/screens/gentle_progress_screen.dart';
import '../../features/journaling/presentation/screens/journal_entry_screen.dart';
import '../../features/journaling/presentation/screens/journal_list_screen.dart';
import '../../features/onboarding/presentation/screens/biometric_lock_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/safety_plan/presentation/screens/panic_blank_screen.dart';
import '../../features/safety_plan/presentation/screens/safety_plan_editor_screen.dart';
import '../../features/safety_plan/presentation/screens/safety_plan_screen.dart';
import '../../features/tiny_steps/presentation/screens/tiny_steps_screen.dart';
import '../../shared/widgets/main_shell_scaffold.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.checkIn,
    debugLogDiagnostics: false, // Never log routes in production
    routes: [
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
            builder: (context, state) => const BreathingGroundingScreen(),
          ),
          GoRoute(
            path: AppRoutes.journal,
            builder: (context, state) => const JournalListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => JournalEntryScreen(
                  entryId: state.pathParameters['id'] ?? '',
                ),
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
        ],
      ),
    ],
  );
});
