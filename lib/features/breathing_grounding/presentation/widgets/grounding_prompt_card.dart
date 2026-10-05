import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/grounding_session_state.dart';
import 'grounding_completion_card.dart';

/// Interactive UI card for guided 5-4-3-2-1 sensory grounding.
/// Designed with high-contrast, low-stimulation styling and penalty-free navigation.
class GroundingPromptCard extends StatelessWidget {
  const GroundingPromptCard({
    super.key,
    required this.state,
    required this.onNoticeItem,
    required this.onNextStage,
    required this.onPreviousStage,
    required this.onSkipStage,
    required this.onCompleteEarly,
    this.onReturnHome,
    this.onTransitionToBreathing,
    this.onRepeat,
  });

  final GroundingSessionState state;
  final VoidCallback onNoticeItem;
  final VoidCallback onNextStage;
  final VoidCallback onPreviousStage;
  final VoidCallback onSkipStage;
  final VoidCallback onCompleteEarly;
  final VoidCallback? onReturnHome;
  final VoidCallback? onTransitionToBreathing;
  final VoidCallback? onRepeat;

  @override
  Widget build(BuildContext context) {
    if (state.isCompleted) {
      return GroundingCompletionCard(
        onReturnHome: onReturnHome ?? () {},
        onTransitionToBreathing: onTransitionToBreathing ?? () {},
        onRepeat: onRepeat,
      );
    }

    final colors = context.colors;
    final stage = state.currentStage;
    final noticed = state.currentStageNoticedCount;
    final target = state.targetCount;
    final isStageComplete = state.isCurrentStageComplete;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.screenPaddingH,
          vertical: SpacingTokens.spaceMd,
        ),
        child: FireflyCard(
          padding: const EdgeInsets.all(SpacingTokens.cardPaddingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Stage Progress Indicator & Penalty-free Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.spaceSm,
                      vertical: SpacingTokens.space2xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.actionSage.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    ),
                    child: Text(
                      'STEP ${state.currentStageIndex + 1} OF ${state.stages.length}',
                      style: AppTypography.labelSm.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('grounding_skip_button'),
                    onPressed: onSkipStage,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.spaceSm,
                        vertical: SpacingTokens.spaceXs,
                      ),
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(
                      state.mode == GroundingMode.fiveSenses
                          ? 'Skip sense'
                          : 'Skip step',
                      style: AppTypography.labelSm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.spaceLg),

              // Sense Icon & Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceSubtle,
                      border: Border.all(
                        color: colors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      IconData(stage.icon.codePoint, fontFamily: stage.icon.fontFamily),
                      size: 26,
                      color: colors.actionSage,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.title,
                          style: AppTypography.headlineSm.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stage.subtitle,
                          style: AppTypography.bodySm.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.spaceMd),

              // Instruction text
              Text(
                stage.instruction,
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceLg),

              // Interactive Check-offs / Noticed Items list
              ...List.generate(target, (index) {
                final isNoticed = index < noticed;
                final promptText = index < stage.prompts.length
                    ? stage.prompts[index]
                    : 'Notice sensation ${index + 1}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.spaceSm),
                  child: InkWell(
                    key: Key('grounding_item_${state.currentStageIndex}_$index'),
                    onTap: isNoticed ? null : onNoticeItem,
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.spaceMd,
                        vertical: SpacingTokens.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: isNoticed
                            ? colors.actionSage.withOpacity(0.08)
                            : colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        border: Border.all(
                          color: isNoticed
                              ? colors.actionSage.withOpacity(0.3)
                              : colors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isNoticed
                                ? AppIcons.checkCircleFilled
                                : Icons.radio_button_unchecked_rounded,
                            size: IconSizeTokens.appAction,
                            color: isNoticed
                                ? colors.actionSage
                                : colors.textSecondary,
                          ),
                          const SizedBox(width: SpacingTokens.spaceSm),
                          Expanded(
                            child: Text(
                              promptText,
                              style: AppTypography.bodyMd.copyWith(
                                color: isNoticed
                                    ? colors.textPrimary
                                    : colors.textSecondary,
                                decoration: isNoticed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor:
                                    colors.actionSage.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: SpacingTokens.spaceMd),

              // Gentle Tap-to-Notice Action when not all noticed
              if (!isStageComplete) ...[
                FireflyButton(
                  key: const Key('grounding_notice_tap_button'),
                  text: 'Notice another (${target - noticed} left)',
                  icon: Icons.touch_app_rounded,
                  variant: FireflyButtonVariant.secondary,
                  onPressed: onNoticeItem,
                ),
                const SizedBox(height: SpacingTokens.spaceMd),
              ],

              // Navigation Controls: Back and Next / Complete
              Row(
                children: [
                  if (!state.isFirstStage) ...[
                    IconButton(
                      key: const Key('grounding_back_button'),
                      onPressed: onPreviousStage,
                      icon: const Icon(AppIcons.back),
                      iconSize: IconSizeTokens.appAction,
                      tooltip: 'Previous sense',
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: SpacingTokens.spaceSm),
                  ],
                  Expanded(
                    child: FireflyButton(
                      key: const Key('grounding_advance_button'),
                      text: isStageComplete
                          ? (state.isLastStage
                              ? 'Complete Grounding'
                              : 'Next Sense')
                          : 'Next Sense',
                      variant: isStageComplete
                          ? FireflyButtonVariant.primary
                          : FireflyButtonVariant.secondary,
                      onPressed: onNextStage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.spaceSm),

              // Early Exit / Finish Option without penalty
              Center(
                child: TextButton(
                  key: const Key('grounding_finish_early_button'),
                  onPressed: onCompleteEarly,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(
                    'Finish now',
                    style: AppTypography.labelSm.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
