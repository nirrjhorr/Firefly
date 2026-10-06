import 'package:flutter/material.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/cognitive_exercise.dart';
import '../../domain/models/cognitive_session_state.dart';

/// Interactive card presenting the active cognitive working memory task.
class CognitiveExerciseCard extends StatelessWidget {
  const CognitiveExerciseCard({
    super.key,
    required this.state,
    required this.onAdvance,
    required this.onSkip,
    required this.onChangeCategory,
    required this.onSelectCountingConfig,
  });

  final CognitiveSessionState state;
  final VoidCallback onAdvance;
  final VoidCallback onSkip;
  final VoidCallback onChangeCategory;
  final ValueChanged<int> onSelectCountingConfig;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.spaceLg),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Subtitle / context cue
          _buildContextCue(context),
          const SizedBox(height: SpacingTokens.spaceLg),

          // Core Interactive Focal Element
          _buildFocalContent(context),
          const SizedBox(height: SpacingTokens.spaceXl),

          // Primary and Secondary Actions
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildContextCue(BuildContext context) {
    final colors = context.colors;

    switch (state.exerciseType) {
      case CognitiveExerciseType.alphabetCategories:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.activeCategory.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.actionSage,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onChangeCategory,
              icon: Icon(Icons.refresh_rounded, size: 16, color: colors.textSecondary),
              label: Text(
                'Change',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(48, 36),
              ),
            ),
          ],
        );

      case CognitiveExerciseType.backwardCounting:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step down by ${state.activeCountingConfig.stepDown}',
              style: AppTypography.titleMedium.copyWith(
                color: colors.actionSage,
                fontWeight: FontWeight.w600,
              ),
            ),
            PopupMenuButton<int>(
              tooltip: 'Choose step size',
              initialValue: state.activeCountingConfigIndex,
              onSelected: onSelectCountingConfig,
              color: colors.surfaceElevated,
              itemBuilder: (context) => kCountingConfigs.asMap().entries.map((e) {
                return PopupMenuItem<int>(
                  value: e.key,
                  child: Text(
                    e.value.name,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pacing',
                      style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                    ),
                    Icon(Icons.arrow_drop_down, color: colors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ],
        );

      case CognitiveExerciseType.wordAssociation:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tranquil Word Sequence',
            style: AppTypography.titleMedium.copyWith(
              color: colors.actionSage,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case CognitiveExerciseType.memorySequence:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Gentle Present Awareness',
            style: AppTypography.titleMedium.copyWith(
              color: colors.actionSage,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  Widget _buildFocalContent(BuildContext context) {
    final colors = context.colors;

    switch (state.exerciseType) {
      case CognitiveExerciseType.alphabetCategories:
        return Column(
          children: [
            AnimatedSwitcher(
              duration: AnimationTokens.fast,
              child: Container(
                key: ValueKey('letter_${state.currentLetter}'),
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.actionSage.withOpacity(0.12),
                  border: Border.all(
                    color: colors.actionSage.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  state.currentLetter,
                  style: AppTypography.displayLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),
            Text(
              '${state.activeCategory.hint} starting with "${state.currentLetter}"',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        );

      case CognitiveExerciseType.backwardCounting:
        return Column(
          children: [
            AnimatedSwitcher(
              duration: AnimationTokens.fast,
              child: Container(
                key: ValueKey('count_${state.currentCount}'),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  color: colors.surfaceSubtle,
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Text(
                  '${state.currentCount}',
                  style: AppTypography.displayLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),
            Text(
              'Quietly compute: ${state.currentCount} minus ${state.activeCountingConfig.stepDown}',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        );

      case CognitiveExerciseType.wordAssociation:
        return Column(
          children: [
            AnimatedSwitcher(
              duration: AnimationTokens.fast,
              child: Container(
                key: ValueKey('word_${state.currentWord}'),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  color: colors.actionSage.withOpacity(0.1),
                  border: Border.all(color: colors.actionSage.withOpacity(0.3)),
                ),
                child: Text(
                  state.currentWord,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),
            Text(
              'Notice what feelings or images this brings up for one breath.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        );

      case CognitiveExerciseType.memorySequence:
        final steps = [
          'Feel the steady surface supporting your body right now.',
          'Notice three quiet colors currently in your surroundings.',
          'Bring to mind the face of someone who wishes you peace.',
          'Take one slow, effortless breath without changing it.',
          'Allow your shoulders to settle gently into gravity.',
        ];
        final prompt = steps[state.completedSteps % steps.length];

        return Column(
          children: [
            AnimatedSwitcher(
              duration: AnimationTokens.fast,
              child: Container(
                key: ValueKey('step_${state.completedSteps}'),
                padding: const EdgeInsets.all(SpacingTokens.spaceLg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  color: colors.surfaceSubtle,
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Text(
                  prompt,
                  textAlign: TextAlign.center,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // Primary advance button (≥ 56dp)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            key: const Key('cognitive_advance_button'),
            onPressed: onAdvance,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.actionSage,
              foregroundColor: colors.canvas,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_rounded, size: 20),
                const SizedBox(width: SpacingTokens.spaceSm),
                Text(
                  _getAdvanceButtonLabel(),
                  style: AppTypography.labelLarge.copyWith(
                    color: colors.canvas,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceSm),

        // Skip button (no shame, no penalty)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            key: const Key('cognitive_skip_button'),
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: colors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
              ),
            ),
            child: Text(
              _getSkipButtonLabel(),
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getAdvanceButtonLabel() {
    switch (state.exerciseType) {
      case CognitiveExerciseType.alphabetCategories:
        return 'I have a word';
      case CognitiveExerciseType.backwardCounting:
        return 'Calculated — next step';
      case CognitiveExerciseType.wordAssociation:
        return 'Next reflection';
      case CognitiveExerciseType.memorySequence:
        return 'I am here';
    }
  }

  String _getSkipButtonLabel() {
    switch (state.exerciseType) {
      case CognitiveExerciseType.alphabetCategories:
        return 'Skip this letter';
      case CognitiveExerciseType.backwardCounting:
        return 'Skip this number';
      case CognitiveExerciseType.wordAssociation:
      case CognitiveExerciseType.memorySequence:
        return 'Skip this step';
    }
  }
}
