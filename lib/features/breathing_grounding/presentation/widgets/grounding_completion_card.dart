import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';

/// Completion card acknowledging grounded state with one-tap return to home
/// or transition to slow breathing.
class GroundingCompletionCard extends StatelessWidget {
  const GroundingCompletionCard({
    super.key,
    required this.onReturnHome,
    required this.onTransitionToBreathing,
    this.onRepeat,
  });

  final VoidCallback onReturnHome;
  final VoidCallback onTransitionToBreathing;
  final VoidCallback? onRepeat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.spaceLg,
          vertical: SpacingTokens.spaceXl,
        ),
        child: FireflyCard(
          padding: const EdgeInsets.all(SpacingTokens.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gentle anchor icon with sage glow
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.actionSage.withOpacity(0.12),
                  border: Border.all(
                    color: colors.actionSage.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.spa_outlined,
                    size: 36,
                    color: colors.actionSage,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceLg),

              // Title
              Text(
                'You are grounded.',
                textAlign: TextAlign.center,
                style: AppTypography.headingLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceSm),

              // Trauma-informed, affirming message
              Text(
                'You’ve reconnected with your senses and your physical reality. Take a moment to feel your weight supported and the space around you.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: SpacingTokens.space2xl),

              // Primary Action: Transition to Slow Breathing
              FireflyButton(
                text: 'Try Slow Breathing',
                icon: Icons.air,
                onPressed: onTransitionToBreathing,
                variant: FireflyButtonVariant.primary,
              ),
              const SizedBox(height: SpacingTokens.spaceSm),

              // Secondary Action: Return Home
              FireflyButton(
                text: 'Return Home',
                icon: Icons.home_outlined,
                onPressed: onReturnHome,
                variant: FireflyButtonVariant.secondary,
              ),

              if (onRepeat != null) ...[
                const SizedBox(height: SpacingTokens.spaceSm),
                TextButton(
                  onPressed: onRepeat,
                  child: Text(
                    'Practice Again',
                    style: AppTypography.labelMd.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
