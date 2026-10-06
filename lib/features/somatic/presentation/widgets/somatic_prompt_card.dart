import 'package:flutter/material.dart';

import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/somatic_prompt.dart';

/// Tactile prompt card for a single somatic centering stage (Story 12.2).
/// Features high contrast typography (≥ 4.5:1), ≥ 56dp primary touch target,
/// non-judgmental skip option, and sensory anchor cues.
class SomaticPromptCard extends StatelessWidget {
  const SomaticPromptCard({
    super.key,
    required this.prompt,
    required this.totalStages,
    required this.onCompleted,
    required this.onSkip,
    this.isLastStage = false,
  });

  final SomaticPrompt prompt;
  final int totalStages;
  final VoidCallback onCompleted;
  final VoidCallback onSkip;
  final bool isLastStage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FireflyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stage header badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                  vertical: SpacingTokens.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(RadiusTokens.full),
                ),
                child: Text(
                  'Stage ${prompt.stageNumber} of $totalStages',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '~${prompt.durationSeconds}s',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),

          // Stage Title
          Text(
            prompt.stageTitle,
            style: AppTypography.titleLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),

          // Main guidance text
          Text(
            prompt.guidanceText,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textPrimary.withOpacity(0.90),
              height: 1.55,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),

          // Sensation Focus Highlight
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(RadiusTokens.md),
              border: Border.all(
                color: colors.outline.withOpacity(0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.adjust_rounded,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Where to feel it:',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prompt.sensationFocus,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),

          // Breath Anchor Cue
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withOpacity(0.45),
              borderRadius: BorderRadius.circular(RadiusTokens.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.air_rounded,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(
                    prompt.breathingAnchor,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Action buttons: Primary advance + Secondary non-judgmental skip
          SizedBox(
            height: 56, // Enforcing ≥ 56dp touch target
            child: FireflyButton(
              label: isLastStage ? 'Complete Exercise' : 'Step Completed',
              variant: FireflyButtonVariant.primary,
              onPressed: onCompleted,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),

          Center(
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(120, 48),
                foregroundColor: colors.textSecondary,
              ),
              child: Text(
                'Skip this step',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
