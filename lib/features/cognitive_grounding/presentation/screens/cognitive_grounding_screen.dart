import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/cognitive_exercise.dart';
import '../controllers/cognitive_grounding_controller.dart';
import '../widgets/cognitive_exercise_card.dart';
import '../widgets/cognitive_mode_selector.dart';

/// Screen hosting the Cognitive Grounding & Attention Switching Engine (FR-14).
/// Provides non-clinical working memory tasks to interrupt rumination without gamification.
class CognitiveGroundingScreen extends ConsumerStatefulWidget {
  const CognitiveGroundingScreen({
    super.key,
    this.initialMode,
    this.showSosOverlay = true,
  });

  final String? initialMode;
  final bool showSosOverlay;

  @override
  ConsumerState<CognitiveGroundingScreen> createState() =>
      _CognitiveGroundingScreenState();
}

class _CognitiveGroundingScreenState
    extends ConsumerState<CognitiveGroundingScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();
    if (widget.initialMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mode = CognitiveExerciseType.fromString(widget.initialMode!);
        ref
            .read(cognitiveGroundingControllerProvider.notifier)
            .setExerciseType(mode);
      });
    }
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final state = ref.read(cognitiveGroundingControllerProvider);
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (state.completedSteps >= 1 || state.isCompleted) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_cognitive_${state.exerciseType.name}',
        stateAtStart: 'racingThoughts',
        durationSeconds: elapsedSec > 0 ? elapsedSec : 30,
      );
    }

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.checkIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(cognitiveGroundingControllerProvider);
    final controller = ref.read(cognitiveGroundingControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.screenPaddingH,
                    vertical: SpacingTokens.spaceSm,
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Close exercise and return',
                        child: IconButton(
                          key: const Key('cognitive_exit_button'),
                          icon: const Icon(Icons.close_rounded),
                          color: colors.textSecondary,
                          onPressed: _handleExit,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.spaceSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cognitive Grounding',
                              style: AppTypography.titleMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Gentle tasks to untangle racing thoughts',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Mode Selector Bar
                CognitiveModeSelector(
                  currentType: state.exerciseType,
                  onSelectType: (type) => controller.setExerciseType(type),
                ),
                const SizedBox(height: SpacingTokens.spaceSm),

                // Calming Progress Indicator (no pressure, no percentage labels)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.screenPaddingH,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    child: LinearProgressIndicator(
                      value: state.progressFraction > 0 ? state.progressFraction : null,
                      backgroundColor: colors.surfaceSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.actionSage.withOpacity(0.5),
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.spaceMd),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.screenPaddingH,
                    ),
                    child: Column(
                      children: [
                        if (state.isCompleted)
                          _buildCompletionBanner(context, controller)
                        else
                          CognitiveExerciseCard(
                            state: state,
                            onAdvance: controller.advance,
                            onSkip: controller.skip,
                            onChangeCategory: controller.nextCategory,
                            onSelectCountingConfig: controller.setCountingConfig,
                          ),
                        const SizedBox(height: SpacingTokens.spaceLg),

                        // Low-pressure exit option
                        TextButton(
                          key: const Key('cognitive_enough_button'),
                          onPressed: _handleExit,
                          style: TextButton.styleFrom(
                            foregroundColor: colors.textTertiary,
                            minimumSize: const Size(120, 48),
                          ),
                          child: Text(
                            "That's enough for now",
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.spaceXl),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Persistent SOS Shield
            if (widget.showSosOverlay)
              const Positioned(
                bottom: SpacingTokens.spaceLg,
                right: SpacingTokens.spaceLg,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBanner(
    BuildContext context,
    CognitiveGroundingController controller,
  ) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.spaceXl),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(color: colors.actionSage.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.actionSage.withOpacity(0.15),
            ),
            child: Icon(
              Icons.check_rounded,
              color: colors.actionSage,
              size: 28,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceMd),
          Text(
            'Well done taking a quiet pause',
            style: AppTypography.titleLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          Text(
            'Your working memory had a chance to gently disengage. Feel free to rest or try another activity.',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.spaceLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('cognitive_restart_button'),
                  onPressed: controller.reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.actionSage,
                    side: BorderSide(color: colors.actionSage),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
              const SizedBox(width: SpacingTokens.spaceSm),
              Expanded(
                child: ElevatedButton(
                  key: const Key('cognitive_complete_exit_button'),
                  onPressed: _handleExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.actionSage,
                    foregroundColor: colors.canvas,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    ),
                  ),
                  child: const Text('Finish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
