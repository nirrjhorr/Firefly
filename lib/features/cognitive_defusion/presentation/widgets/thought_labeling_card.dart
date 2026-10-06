import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../domain/models/defusion_session_state.dart';
import '../../domain/models/defusion_thought.dart';

/// Card guiding user through progressive 3-tier linguistic cognitive defusion.
class ThoughtLabelingCard extends StatelessWidget {
  const ThoughtLabelingCard({
    required this.state,
    required this.onAdvanceStep,
    required this.onSelectThought,
    super.key,
  });

  final DefusionSessionState state;
  final VoidCallback onAdvanceStep;
  final void Function(String thought) onSelectThought;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.spaceLg),
      child: Column(
        children: [
          // Progressive Defusion Box
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.spaceXl),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(RadiusTokens.card),
                border: Border.all(color: colors.borderSubtle, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Step Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.actionSage.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                      border: Border.all(color: colors.actionSage.withOpacity(0.4)),
                    ),
                    child: Text(
                      'Distance Level ${state.labelingStep} of 3',
                      style: AppTypography.captionSm.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: SpacingTokens.spaceXl),

                  // Progressive Defusion Text Block
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.08),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Container(
                      key: ValueKey('step_${state.labelingStep}_${state.labelingThoughtText}'),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(RadiusTokens.input),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Text(
                        state.formattedLabelingText,
                        style: AppTypography.headingMd.copyWith(
                          color: colors.textPrimary,
                          height: 1.5,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: SpacingTokens.spaceLg),

                  Text(
                    _stepGuidance(state.labelingStep),
                    style: AppTypography.bodySm.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: SpacingTokens.spaceXl),

                  // Step Advance Button
                  SizedBox(
                    width: double.infinity,
                    child: FireflyButton.primary(
                      label: state.labelingStep < 3 ? 'Step Back Further' : 'Try Another Thought',
                      onPressed: onAdvanceStep,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: SpacingTokens.spaceMd),

          // Starter thought suggestions
          Text(
            'Or select a common heavy thought:',
            style: AppTypography.captionSm.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kCuratedDefusionPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = kCuratedDefusionPrompts[index];
                final isSelected = state.labelingThoughtText == prompt;
                return ChoiceChip(
                  label: Text(prompt),
                  selected: isSelected,
                  onSelected: (_) => onSelectThought(prompt),
                  selectedColor: colors.actionSage.withOpacity(0.2),
                  backgroundColor: colors.surfaceSubtle,
                  labelStyle: AppTypography.captionSm.copyWith(
                    color: isSelected ? colors.actionSage : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    side: BorderSide(
                      color: isSelected ? colors.actionSage : colors.borderSubtle,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _stepGuidance(int step) {
    switch (step) {
      case 1:
        return 'Notice how it feels when you are completely merged with this thought.';
      case 2:
        return 'Notice the gentle gap that opens when you acknowledge it as just an active mental event.';
      case 3:
        return 'You are the calm sky witnessing the weather. The thought is not who you are.';
      default:
        return '';
    }
  }
}
