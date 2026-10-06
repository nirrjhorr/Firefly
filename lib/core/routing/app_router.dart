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
import '../../features/movement/presentation/screens/movement_engine_screen.dart';
import '../../features/cognitive_grounding/presentation/screens/cognitive_grounding_screen.dart';
import '../../features/pmr/presentation/screens/pmr_screen.dart';
import '../../features/safety_plan/presentation/screens/panic_blank_screen.dart';
import '../../features/safety_plan/presentation/screens/safety_plan_editor_screen.dart';
import '../../features/safety_plan/presentation/screens/safety_plan_screen.dart';
import '../../features/soundscapes/presentation/screens/soundscape_library_screen.dart';
import '../../features/tiny_steps/presentation/screens/tiny_steps_screen.dart';
import '../../features/tiny_steps/presentation/screens/tiny_step_activity_screen.dart';
import '../../features/sleep/presentation/screens/sleep_suite_screen.dart';
import '../../features/hope_box/presentation/screens/hope_box_screen.dart';
import '../../features/nature/presentation/screens/nature_observation_screen.dart';
import '../../features/somatic/presentation/screens/somatic_centering_screen.dart';
import '../../features/labyrinth/presentation/screens/labyrinth_screen.dart';
import '../../features/flow_puzzle/presentation/screens/flow_puzzle_screen.dart';
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
      
      // Full screen Tiny Step Activity
      GoRoute(
        path: AppRoutes.tinyStepActivity,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TinyStepActivityScreen(stepId: id);
        },
      ),

      // Graceful legacy grounding redirect
      GoRoute(
        path: '/home/ground',
        redirect: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'grounding';
          return '${AppRoutes.breathe}?mode=$mode';
        },
      ),

      // Progressive Muscle Relaxation (Root Modal with SOS overlay)
      GoRoute(
        path: '/pmr',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PmrScreen(
          isQuickMode: state.uri.queryParameters['mode'] == 'quick',
          showSosOverlay: true,
        ),
      ),

      // Movement & Somatic Release Engine (Root Modal with SOS overlay)
      GoRoute(
        path: '/move',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MovementEngineScreen(
          initialMode: state.uri.queryParameters['mode'],
          showSosOverlay: true,
        ),
      ),

      // Cognitive Grounding Engine (Root Modal with SOS overlay)
      GoRoute(
        path: '/cognitive-grounding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CognitiveGroundingScreen(
          initialMode: state.uri.queryParameters['mode'],
          showSosOverlay: true,
        ),
      ),

      // Sleep & Wind-Down Sanctuary (Root Modal with SOS overlay)
      GoRoute(
        path: '/sleep',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SleepSuiteScreen(
          initialMode: state.uri.queryParameters['mode'],
          showSosOverlay: true,
        ),
      ),

      // Hope Box Offline Multi-Media Coping Vault (Root Modal with SOS overlay)
      GoRoute(
        path: '/hope-box',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HopeBoxScreen(
          showSosOverlay: true,
        ),
      ),

      // Loneliness Comfort & Social Reach-Out (Root Modal with SOS overlay)
      GoRoute(
        path: '/loneliness',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LonelinessComfortScreen(
          showSosOverlay: true,
        ),
      ),

      // Guided Nature & Outdoor Micro-Observation Suite (Root Modal with SOS overlay)
      GoRoute(
        path: '/nature',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => NatureObservationScreen(
          initialMode: state.uri.queryParameters['mode'],
          showSosOverlay: true,
        ),
      ),

      // Somatic Visualizations & Body Centering (Root Modal with SOS overlay)
      GoRoute(
        path: '/somatic',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SomaticCenteringScreen(
          initialMode: state.uri.queryParameters['mode'],
          showSosOverlay: true,
        ),
      ),

      // Meditative Labyrinth Tracing & Canvas Drawing (Root Modal with SOS overlay)
      GoRoute(
        path: '/labyrinth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LabyrinthScreen(
          initialPattern: state.uri.queryParameters['pattern'],
          showSosOverlay: true,
        ),
      ),

      // Flow & Spatial Puzzles Integration (Root Modal with SOS overlay)
      GoRoute(
        path: '/flow-puzzle',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => FlowPuzzleScreen(
          initialMode: state.uri.queryParameters['mode'],
          initialPattern: state.uri.queryParameters['pattern'],
          showSosOverlay: true,
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
            builder: (context, state) => const LonelinessComfortScreen(
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.soundscapes,
            builder: (context, state) => const SoundscapeLibraryScreen(),
          ),
          GoRoute(
            path: AppRoutes.pmr,
            builder: (context, state) => PmrScreen(
              isQuickMode: state.uri.queryParameters['mode'] == 'quick',
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.move,
            builder: (context, state) => MovementEngineScreen(
              initialMode: state.uri.queryParameters['mode'],
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.cognitiveGrounding,
            builder: (context, state) => CognitiveGroundingScreen(
              initialMode: state.uri.queryParameters['mode'],
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.sleep,
            builder: (context, state) => SleepSuiteScreen(
              initialMode: state.uri.queryParameters['mode'],
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.hopeBox,
            builder: (context, state) => const HopeBoxScreen(
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.nature,
            builder: (context, state) => NatureObservationScreen(
              initialMode: state.uri.queryParameters['mode'],
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.somatic,
            builder: (context, state) => SomaticCenteringScreen(
              initialMode: state.uri.queryParameters['mode'],
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.labyrinth,
            builder: (context, state) => LabyrinthScreen(
              initialPattern: state.uri.queryParameters['pattern'],
              showSosOverlay: false,
            ),
          ),
          GoRoute(
            path: AppRoutes.flowPuzzle,
            builder: (context, state) => FlowPuzzleScreen(
              initialMode: state.uri.queryParameters['mode'],
              initialPattern: state.uri.queryParameters['pattern'],
              showSosOverlay: false,
            ),
          ),
        ],
      ),
    ],
  );
});
