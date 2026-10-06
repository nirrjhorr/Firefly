import 'package:flutter/material.dart';

import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/nature_prompt.dart';

/// Tactile prompt card for Nature Observation with accessible touch targets (≥ 56dp).
class NaturePromptCard extends StatelessWidget {
  const NaturePromptCard({
    super.key,
    required this.prompt,
    required this.stepNumber,
    required this.totalSteps,
    required this.isCompleted,
    required this.onNext,
    this.onPrevious,
    required this.onSkip,
    required this.onRestart,
  });

  final NaturePrompt prompt;
  final int stepNumber;
  final int totalSteps;
  final bool isCompleted;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isCompleted) {
      return _buildCompletionCard(context, colors);
    }

    return AnimatedSwitcher(
      duration: AnimationTokens.medium,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<String>('nature_card_${prompt.id}'),
        width: double.infinity,
        padding: const EdgeInsets.all(SpacingTokens.spaceLg),
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(RadiusTokens.container),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Step index & sensory anchor badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step $stepNumber of $totalSteps',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.spaceSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.actionSage.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  ),
                  child: Text(
                    prompt.sensoryAnchor,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.actionSage,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.spaceMd),

            // Stage Title
            Text(
              prompt.stageTitle,
              style: AppTypography.titleLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceSm),

            // Main Cue Text
            Text(
              prompt.cueText,
              style: AppTypography.bodyLarge.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),

            // Reflection Cue Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.spaceMd),
              decoration: BoxDecoration(
                color: colors.canvas.withOpacity(0.6),
                borderRadius: BorderRadius.circular(RadiusTokens.card),
                border: Border.all(color: colors.borderSubtle.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 18,
                    color: colors.actionSage,
                  ),
                  const SizedBox(width: SpacingTokens.spaceSm),
                  Expanded(
                    child: Text(
                      prompt.reflectionCue,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Indoor Tip Box (if available)
            if (prompt.indoorTip != null) ...[
              const SizedBox(height: SpacingTokens.spaceSm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.spaceMd,
                  vertical: SpacingTokens.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 16,
                      color: colors.textTertiary,
                    ),
                    const SizedBox(width: SpacingTokens.spaceSm),
                    Expanded(
                      child: Text(
                        'Indoors: ${prompt.indoorTip}',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textTertiary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: SpacingTokens.spaceLg),

            // Action Buttons
            Column(
              children: [
                // Primary Action Button (≥ 56dp)
                Semantics(
                  button: true,
                  label: 'I noticed this, proceed to next cue',
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      key: const Key('nature_btn_next'),
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.actionSage,
                        foregroundColor: colors.canvas,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusTokens.button),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                            color: colors.canvas,
                          ),
                          const SizedBox(width: SpacingTokens.spaceSm),
                          Text(
                            stepNumber == totalSteps
                                ? 'Complete Observation'
                                : 'I Noticed This',
                            style: AppTypography.labelLarge.copyWith(
                              color: colors.canvas,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.spaceSm),

                // Navigation Row: Previous & Skip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (onPrevious != null)
                      TextButton.icon(
                        key: const Key('nature_btn_previous'),
                        onPressed: onPrevious,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                        label: Text(
                          'Previous',
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    TextButton(
                      key: const Key('nature_btn_skip'),
                      onPressed: onSkip,
                      child: Text(
                        'Skip step',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, AppCustomColors colors) {
    return Container(
      key: const Key('nature_card_completed'),
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.spaceXl),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.container),
        border: Border.all(color: colors.actionSage.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.actionSage.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.spa_rounded,
              size: 32,
              color: colors.actionSage,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceLg),
          Text(
            'Observation Complete',
            style: AppTypography.titleLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          Text(
            'You have gently anchored your attention into the physical world. Let your breath remain steady as you return to your day.',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.spaceXl),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              key: const Key('nature_btn_restart'),
              onPressed: onRestart,
              style: OutlinedButton.styleFrom(
                side: Border.all(color: colors.borderSubtle),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.button),
                ),
              ),
              child: Text(
                'Observe Again',
                style: AppTypography.labelLarge.copyWith(
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
