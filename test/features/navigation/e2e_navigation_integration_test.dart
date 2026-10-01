import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:firefly/core/recommendation_engine/models/action_suggestion.dart';
import 'package:firefly/core/recommendation_engine/models/affect_state.dart';
import 'package:firefly/core/recommendation_engine/recommendation_engine.dart';
import 'package:firefly/core/routing/app_router.dart';
import 'package:firefly/core/routing/app_routes.dart';
import 'package:firefly/features/check_in/presentation/widgets/affect_result_card.dart';
import 'package:firefly/features/loneliness_comfort/presentation/screens/loneliness_comfort_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestApp({required Widget child, GoRouter? router}) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  Widget createRouterApp(GoRouter router) {
    return ProviderScope(
      overrides: [
        appRouterProvider.overrideWithValue(router),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('Recommendation Engine to Route Mapping Verification', () {
    test('routes high anxiety (>=4) directly to /home/breathe', () {
      final state = const AffectState(
        moodCategory: 'anxious',
        energyLevel: 3,
        anxietyLevel: 5,
        lonelinessLevel: 1,
      );
      final suggestion = RecommendationEngine.evaluate(state);
      expect(suggestion.actionType, ActionType.breathing);
      expect(suggestion.route, AppRoutes.breathe);
    });

    test('routes low mood + low energy (<=2) to /home/tiny-steps', () {
      final state = const AffectState(
        moodCategory: 'low',
        energyLevel: 1,
        anxietyLevel: 1,
        lonelinessLevel: 1,
      );
      final suggestion = RecommendationEngine.evaluate(state);
      expect(suggestion.actionType, ActionType.tinySteps);
      expect(suggestion.route, AppRoutes.tinySteps);
    });

    test('routes high loneliness (>=4) to /home/loneliness', () {
      final state = const AffectState(
        moodCategory: 'okay',
        energyLevel: 3,
        anxietyLevel: 2,
        lonelinessLevel: 5,
      );
      final suggestion = RecommendationEngine.evaluate(state);
      expect(suggestion.actionType, ActionType.lonelinessComfort);
      expect(suggestion.route, AppRoutes.loneliness);
    });

    test('routes overwhelmed mood to grounding mode query', () {
      final state = const AffectState(
        moodCategory: 'overwhelmed',
        energyLevel: 3,
        anxietyLevel: 2,
        lonelinessLevel: 1,
      );
      final suggestion = RecommendationEngine.evaluate(state);
      expect(suggestion.actionType, ActionType.grounding);
      expect(suggestion.route, '${AppRoutes.breathe}?mode=grounding');
    });

    test('routes moderate anxiety (>=2) to /home/journal', () {
      final state = const AffectState(
        moodCategory: 'okay',
        energyLevel: 4,
        anxietyLevel: 3,
        lonelinessLevel: 1,
      );
      final suggestion = RecommendationEngine.evaluate(state);
      expect(suggestion.actionType, ActionType.journaling);
      expect(suggestion.route, AppRoutes.journal);
    });
  });

  group('AffectResultCard Navigation Dispatch', () {
    testWidgets('tapping Begin Now triggers navigation push to destination route',
        (tester) async {
      String? pushedRoute;
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => Scaffold(
              body: AffectResultCard(
                suggestion: const ActionSuggestion(
                  actionType: ActionType.breathing,
                  title: 'Slowing down with breath',
                  body: '2-minute cyclic sighing breath.',
                  route: '/target-destination',
                  durationMinutes: 2,
                ),
                onCheckInAgain: () {},
              ),
            ),
          ),
          GoRoute(
            path: '/target-destination',
            builder: (context, state) {
              pushedRoute = '/target-destination';
              return const Scaffold(body: Text('Target Reached'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Begin Now'), findsOneWidget);
      await tester.tap(find.text('Begin Now'));
      await tester.pumpAndSettle();

      expect(pushedRoute, '/target-destination');
      expect(find.text('Target Reached'), findsOneWidget);
    });
  });

  group('Loneliness Comfort Screen Interaction & Back Navigation', () {
    testWidgets('renders supportive options and navigates back cleanly', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const LonelinessComfortScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Holding space for you'), findsOneWidget);
      expect(find.text('Gentle Soundscape & Breathing'), findsOneWidget);
      expect(find.text('Reach Out to Safe People'), findsOneWidget);
      expect(find.text('Write an Unsent Letter'), findsOneWidget);
      expect(find.text('Return to Check-In'), findsOneWidget);
    });
  });
}
