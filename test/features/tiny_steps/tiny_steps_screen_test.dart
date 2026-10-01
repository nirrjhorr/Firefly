import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app.firefly/core/theme/app_theme.dart';
import 'package:app.firefly/features/tiny_steps/domain/models/tiny_step.dart';
import 'package:app.firefly/features/tiny_steps/presentation/controllers/tiny_steps_controller.dart';
import 'package:app.firefly/features/tiny_steps/presentation/screens/tiny_steps_screen.dart';

void main() {
  group('TinyStepsScreen Widget Tests', () {
    Widget buildScreen({TinyStepsController? controller}) {
      return ProviderScope(
        overrides: [
          if (controller != null)
            tinyStepsControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const TinyStepsScreen(),
        ),
      );
    }

    testWidgets('renders calming header and supportive copy', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('One small thing'), findsOneWidget);
      expect(
        find.text('Pick one tiny action that feels possible right now. No expectations, no pressure.'),
        findsOneWidget,
      );
      expect(find.text('Tiny Steps'), findsOneWidget);
    });

    testWidgets('renders 3 micro-action cards with duration ≤ 2 min', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Should render 3 "I did this" buttons
      expect(find.text('I did this'), findsNWidgets(3));

      // Each card displays a duration <= 2 min indicator
      expect(find.textContaining('≤'), findsNWidgets(3));
      expect(find.textContaining('min'), findsNWidgets(3));

      // Displays secondary actions
      expect(find.text('Try different options'), findsOneWidget);
      expect(find.text("I'll do this later"), findsOneWidget);
    });

    testWidgets('completing an action shows compassionate acknowledgement without gamification', (tester) async {
      final controller = TinyStepsController();
      await tester.pumpWidget(buildScreen(controller: controller));
      await tester.pumpAndSettle();

      // Tap "I did this" on the first card
      final firstButton = find.text('I did this').first;
      await tester.tap(firstButton);
      await tester.pumpAndSettle();

      // Verify completion state updated
      expect(controller.state.hasCompleted, isTrue);

      // Verify compassionate acknowledgement banner appears
      expect(
        find.text('Momentum started. You can rest now or do another if you feel like it.'),
        findsOneWidget,
      );

      // Verify completed card shows "Done" instead of "I did this"
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('I did this'), findsNWidgets(2));

      // Verify options to do another step or return home
      expect(find.text('Do another step'), findsOneWidget);
      expect(find.text('Rest / Return home'), findsOneWidget);

      // Verify STRICTLY NO gamification elements (no points, confetti, or streak counters)
      expect(find.textContaining('streak', caseSensitive: false), findsNothing);
      expect(find.textContaining('point', caseSensitive: false), findsNothing);
      expect(find.textContaining('level up', caseSensitive: false), findsNothing);
    });

    testWidgets('shuffle changes candidate actions and clears completion', (tester) async {
      final controller = TinyStepsController();
      await tester.pumpWidget(buildScreen(controller: controller));
      await tester.pumpAndSettle();

      // Complete one item
      await tester.tap(find.text('I did this').first);
      await tester.pumpAndSettle();
      expect(controller.state.hasCompleted, isTrue);

      // Tap "Try different options"
      await tester.tap(find.text('Try different options'));
      await tester.pumpAndSettle();

      // Completion is cleared and 3 active options remain
      expect(controller.state.hasCompleted, isFalse);
      expect(find.text('I did this'), findsNWidgets(3));
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('"Do another step" resets completion state', (tester) async {
      final controller = TinyStepsController();
      await tester.pumpWidget(buildScreen(controller: controller));
      await tester.pumpAndSettle();

      // Complete first step
      await tester.tap(find.text('I did this').first);
      await tester.pumpAndSettle();
      expect(find.text('Do another step'), findsOneWidget);

      // Tap "Do another step"
      await tester.tap(find.text('Do another step'));
      await tester.pumpAndSettle();

      expect(controller.state.hasCompleted, isFalse);
      expect(find.text('Momentum started. You can rest now or do another if you feel like it.'), findsNothing);
    });
  });
}
