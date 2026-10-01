import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app.firefly/core/theme/app_theme.dart';
import 'package:app.firefly/features/breathing_grounding/domain/models/grounding_session_state.dart';
import 'package:app.firefly/features/breathing_grounding/domain/models/grounding_stage.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/widgets/grounding_completion_card.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/widgets/grounding_prompt_card.dart';

void main() {
  Widget buildTestWidget({
    required GroundingSessionState state,
    VoidCallback? onNoticeItem,
    VoidCallback? onNextStage,
    VoidCallback? onPreviousStage,
    VoidCallback? onSkipStage,
    VoidCallback? onCompleteEarly,
    VoidCallback? onReturnHome,
    VoidCallback? onTransitionToBreathing,
    VoidCallback? onRepeat,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: GroundingPromptCard(
          state: state,
          onNoticeItem: onNoticeItem ?? () {},
          onNextStage: onNextStage ?? () {},
          onPreviousStage: onPreviousStage ?? () {},
          onSkipStage: onSkipStage ?? () {},
          onCompleteEarly: onCompleteEarly ?? () {},
          onReturnHome: onReturnHome,
          onTransitionToBreathing: onTransitionToBreathing,
          onRepeat: onRepeat,
        ),
      ),
    );
  }

  group('GroundingPromptCard', () {
    testWidgets('Renders stage 0 (See) with 5 prompts and step indicator',
        (tester) async {
      const state = GroundingSessionState(
        currentStageIndex: 0,
        currentStageNoticedCount: 0,
      );

      await tester.pumpWidget(buildTestWidget(state: state));

      expect(find.text('STEP 1 OF 5'), findsOneWidget);
      expect(find.text('5 Things you can see'), findsOneWidget);
      expect(find.text('Look around your environment'), findsOneWidget);
      expect(find.text('Skip sense'), findsOneWidget);
      expect(find.text('Finish now'), findsOneWidget);

      // Verify the 5 items are displayed
      for (final prompt in GroundingStage.standardStages[0].prompts) {
        expect(find.text(prompt), findsOneWidget);
      }
    });

    testWidgets('Tapping item check-off or notice button calls onNoticeItem',
        (tester) async {
      int noticeCount = 0;
      const state = GroundingSessionState(
        currentStageIndex: 0,
        currentStageNoticedCount: 1,
      );

      await tester.pumpWidget(buildTestWidget(
        state: state,
        onNoticeItem: () => noticeCount++,
      ));

      // Tap on second un-noticed item
      final secondItemFinder = find.byKey(const Key('grounding_item_0_1'));
      expect(secondItemFinder, findsOneWidget);
      await tester.tap(secondItemFinder);
      await tester.pump();
      expect(noticeCount, equals(1));

      // Tap on "Notice another (x left)" button
      final tapButton = find.byKey(const Key('grounding_notice_tap_button'));
      expect(tapButton, findsOneWidget);
      await tester.tap(tapButton);
      await tester.pump();
      expect(noticeCount, equals(2));
    });

    testWidgets('Tapping skip sense triggers onSkipStage without penalty',
        (tester) async {
      bool skipped = false;
      const state = GroundingSessionState(
        currentStageIndex: 1,
        currentStageNoticedCount: 0,
      );

      await tester.pumpWidget(buildTestWidget(
        state: state,
        onSkipStage: () => skipped = true,
      ));

      await tester.tap(find.byKey(const Key('grounding_skip_button')));
      await tester.pump();
      expect(skipped, isTrue);
    });

    testWidgets('Shows back button on subsequent stages and triggers onPreviousStage',
        (tester) async {
      bool wentBack = false;
      const state = GroundingSessionState(
        currentStageIndex: 2,
        currentStageNoticedCount: 1,
      );

      await tester.pumpWidget(buildTestWidget(
        state: state,
        onPreviousStage: () => wentBack = true,
      ));

      final backButton = find.byKey(const Key('grounding_back_button'));
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pump();
      expect(wentBack, isTrue);
    });

    testWidgets('Next sense button calls onNextStage', (tester) async {
      bool advanced = false;
      const state = GroundingSessionState(
        currentStageIndex: 0,
        currentStageNoticedCount: 5,
      );

      await tester.pumpWidget(buildTestWidget(
        state: state,
        onNextStage: () => advanced = true,
      ));

      await tester.tap(find.byKey(const Key('grounding_advance_button')));
      await tester.pump();
      expect(advanced, isTrue);
    });

    testWidgets('Finish now button triggers onCompleteEarly', (tester) async {
      bool completedEarly = false;
      const state = GroundingSessionState(
        currentStageIndex: 0,
        currentStageNoticedCount: 2,
      );

      await tester.pumpWidget(buildTestWidget(
        state: state,
        onCompleteEarly: () => completedEarly = true,
      ));

      await tester.tap(find.byKey(const Key('grounding_finish_early_button')));
      await tester.pump();
      expect(completedEarly, isTrue);
    });

    testWidgets('When isCompleted is true, renders GroundingCompletionCard with CTAs',
        (tester) async {
      bool returnedHome = false;
      bool transitionedToBreathing = false;
      const state = GroundingSessionState(
        currentStageIndex: 4,
        currentStageNoticedCount: 1,
        isCompleted: true,
      );

      await tester.pumpWidget(buildTestWidget(
        state: state,
        onReturnHome: () => returnedHome = true,
        onTransitionToBreathing: () => transitionedToBreathing = true,
      ));

      expect(find.byType(GroundingCompletionCard), findsOneWidget);
      expect(find.text('You are grounded.'), findsOneWidget);
      expect(find.text('Try Slow Breathing'), findsOneWidget);
      expect(find.text('Return Home'), findsOneWidget);

      await tester.tap(find.text('Try Slow Breathing'));
      await tester.pump();
      expect(transitionedToBreathing, isTrue);

      await tester.tap(find.text('Return Home'));
      await tester.pump();
      expect(returnedHome, isTrue);
    });
  });
}
