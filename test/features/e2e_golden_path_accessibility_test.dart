import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/routing/app_router.dart';
import 'package:firefly/core/routing/app_routes.dart';
import 'package:firefly/core/theme/app_colors.dart';
import 'package:firefly/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:firefly/features/check_in/presentation/screens/check_in_screen.dart';
import 'package:firefly/features/tiny_steps/presentation/screens/tiny_steps_screen.dart';
import 'package:firefly/shared/widgets/firefly_button.dart';
import 'package:firefly/shared/widgets/mood_tile.dart';
import 'package:firefly/shared/widgets/sos_overlay_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildRootTestApp({Widget? child}) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.canvasDeep,
        ),
        home: child ?? const CheckInScreen(),
      ),
    );
  }

  group('Golden Path E2E Smoke Workflow', () {
    testWidgets('Full Golden Path: Check-In -> Mood Select -> Suggestion Card',
        (tester) async {
      await tester.pumpWidget(buildRootTestApp());
      await tester.pumpAndSettle();

      // Step 1: Initial Check-In Screen rendering
      expect(find.text('How are you right now?'), findsOneWidget);
      expect(find.text('Mood Anchor'), findsOneWidget);

      // Step 2: Select Mood Anchor ('Overwhelmed' or 'Heavy')
      final overwhelmedTile = find.byWidgetPredicate(
        (widget) => widget is MoodTile && widget.mood == MoodCategory.overwhelmed,
      );
      expect(overwhelmedTile, findsOneWidget);
      await tester.tap(overwhelmedTile);
      await tester.pumpAndSettle();

      // Step 3: View Suggestion Button
      final submitButton = find.widgetWithText(FireflyButton, 'See My Next Step');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Step 4: Suggestion Card renders with action
      expect(find.text('Here is your next step'), findsOneWidget);
      expect(find.text('Begin Now'), findsOneWidget);
      expect(find.text('Check in again'), findsOneWidget);

      // Step 5: Resetting check-in returns to initial mood picker
      await tester.tap(find.text('Check in again'));
      await tester.pumpAndSettle();
      expect(find.text('How are you right now?'), findsOneWidget);
    });
  });

  group('Accessibility & Trauma-Informed Compliance Suite', () {
    testWidgets('SOS overlay button adheres strictly to >= 56dp touch target SLA',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SosOverlayButton()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sosFinder = find.byType(SosOverlayButton);
      expect(sosFinder, findsOneWidget);

      final size = tester.getSize(sosFinder);
      expect(size.width, greaterThanOrEqualTo(56.0),
          reason: 'SOS touch target width must be >= 56dp');
      expect(size.height, greaterThanOrEqualTo(56.0),
          reason: 'SOS touch target height must be >= 56dp');
    });

    testWidgets('SOS button provides clear Semantics label and hint for screen readers',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SosOverlayButton()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(SosOverlayButton)),
        matchesSemantics(
          label: 'Emergency Safety Plan',
          hint:
              'Tap for offline safety plan. Long press 600 milliseconds to trigger rapid panic app lock and blank screen.',
          isButton: true,
          hasTapAction: true,
          hasLongPressAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('Tiny Steps action cards enforce minimum 72dp touch target height',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const TinyStepsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cards should be rendered with generous touch targets for low-energy users
      final cardFinders = find.byType(Card);
      if (cardFinders.evaluate().isNotEmpty) {
        for (final element in cardFinders.evaluate()) {
          final renderBox = element.renderObject as RenderBox;
          expect(renderBox.size.height, greaterThanOrEqualTo(72.0));
        }
      }
    });

    test('Color contrast tokens satisfy WCAG AA low-stimulation readability', () {
      // Background: #111518 (dark canvas)
      // Text primary: #E8ECEF (light off-white)
      // Action Sage: #4A7862
      // Crisis Coral: #B05454
      expect(AppColors.canvasDeep, const Color(0xFF111518));
      expect(AppColors.actionSage, const Color(0xFF4A7862));
      expect(AppColors.crisisRed, const Color(0xFFB05454));

      // Calculate relative luminance for contrast ratio check
      double luminance(Color c) {
        return c.computeLuminance();
      }

      double contrastRatio(Color c1, Color c2) {
        final l1 = luminance(c1);
        final l2 = luminance(c2);
        final lighter = l1 > l2 ? l1 : l2;
        final darker = l1 > l2 ? l2 : l1;
        return (lighter + 0.05) / (darker + 0.05);
      }

      final textToBgContrast = contrastRatio(AppColors.textPrimary, AppColors.canvasDeep);
      expect(textToBgContrast, greaterThanOrEqualTo(4.5),
          reason: 'Primary text on dark background must exceed WCAG AA 4.5:1 ratio');
    });
  });
}
