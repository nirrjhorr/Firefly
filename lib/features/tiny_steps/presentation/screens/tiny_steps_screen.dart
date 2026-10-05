import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/tiny_step.dart';
import '../controllers/tiny_steps_controller.dart';

/// Screen displaying 3 manageable behavioural activation micro-actions.
///
/// Designed with low cognitive load, zero gamification, tactile completion feedback,
/// and quiet, guilt-free dismiss options.
class TinyStepsScreen extends ConsumerWidget {
  const TinyStepsScreen({super.key});

  Future<void> _triggerWarmDoubleTapHaptic() async {
    try {
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics fail silently on unsupported platforms
    }
  }

  IconData _getCategoryIcon(TinyStepCategory category) {
    switch (category) {
      case TinyStepCategory.sensory:
        return AppIcons.sensory;
      case TinyStepCategory.physical:
        return AppIcons.physical;
      case TinyStepCategory.environment:
        return AppIcons.environment;
      case TinyStepCategory.nourishment:
        return AppIcons.nourishment;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(tinyStepsControllerProvider);
    final controller = ref.read(tinyStepsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: colors.textSecondary, size: IconSizeTokens.appAction),
          tooltip: 'Return to Home',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Tiny Steps',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.refresh, color: colors.textSecondary, size: IconSizeTokens.appAction),
            tooltip: 'Try different options',
            onPressed: () => controller.shuffle(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accentPrimary),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.screenPaddingH,
                  SpacingTokens.screenPaddingV,
                  SpacingTokens.screenPaddingH,
                  SpacingTokens.bottomClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calming Header
                    Text(
                      'One small thing',
                      style: AppTypography.headingLg.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.spaceXs),
                    Text(
                      'Pick one tiny action that feels possible right now. No expectations, no pressure.',
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sectionGap),

                    // Compassionate acknowledgement on completion
                    if (state.hasCompleted) ...[
                      FireflyCard(
                        variant: FireflyCardVariant.raised,
                        padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                        borderColor: colors.accentPrimary.withOpacity(0.35),
                        backgroundColor: colors.accentPrimary.withOpacity(0.12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  AppIcons.check,
                                  color: colors.accentPrimary,
                                  size: IconSizeTokens.standard,
                                ),
                                const SizedBox(width: SpacingTokens.elementGap),
                                Expanded(
                                  child: Text(
                                    'Momentum started. You can rest now or do another if you feel like it.',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpacingTokens.elementGap),
                            Row(
                              children: [
                                Expanded(
                                  child: FireflyButton(
                                    variant: FireflyButtonVariant.smallSecondary,
                                    text: 'Do another step',
                                    onPressed: () => controller.resetCompleted(),
                                  ),
                                ),
                                const SizedBox(width: SpacingTokens.elementGap),
                                Expanded(
                                  child: FireflyButton(
                                    variant: FireflyButtonVariant.smallPrimary,
                                    text: 'Rest / Home',
                                    onPressed: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go(AppRoutes.home);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.sectionGap),
                    ],

                    // 3 Candidate Action Cards
                    ...state.candidates.map((step) {
                      final isCompleted = state.completedStepId == step.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: SpacingTokens.elementGap),
                        child: _MicroActionCard(
                          step: step,
                          isCompleted: isCompleted,
                          iconData: _getCategoryIcon(step.category),
                          onComplete: () async {
                            await _triggerWarmDoubleTapHaptic();
                            controller.completeStep(step.id);
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: SpacingTokens.elementGap),

                    // Low-pressure Secondary Controls
                    Center(
                      child: FireflyButton(
                        variant: FireflyButtonVariant.secondary,
                        isFullWidth: false,
                        icon: AppIcons.shuffle,
                        text: 'Shuffle other options',
                        onPressed: () => controller.shuffle(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MicroActionCard extends StatelessWidget {
  const _MicroActionCard({
    required this.step,
    required this.isCompleted,
    required this.iconData,
    required this.onComplete,
  });

  final TinyStep step;
  final bool isCompleted;
  final IconData iconData;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FireflyCard(
      variant: isCompleted ? FireflyCardVariant.raised : FireflyCardVariant.interactive,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: isCompleted ? colors.accentPrimary : colors.borderSubtle,
      backgroundColor: isCompleted
          ? colors.accentPrimary.withOpacity(0.14)
          : colors.surfaceCard,
      onTap: onComplete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? colors.accentPrimary.withOpacity(0.25)
                      : colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                ),
                child: Icon(
                  isCompleted ? AppIcons.check : iconData,
                  color: isCompleted ? colors.accentPrimary : colors.textSecondary,
                  size: IconSizeTokens.standard,
                ),
              ),
              const SizedBox(width: SpacingTokens.elementGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: AppTypography.headingSm.copyWith(
                        color: colors.textPrimary,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: AppTypography.bodySm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.elementGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Duration indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(RadiusTokens.xs),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.timer,
                      size: IconSizeTokens.xs,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '≤ ${step.durationMinutes} min',
                      style: AppTypography.labelSm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Completion prompt text
              Text(
                isCompleted ? 'Completed' : 'Tap to mark done',
                style: AppTypography.caption.copyWith(
                  color: isCompleted ? colors.accentPrimary : colors.textSecondary,
                  fontWeight: isCompleted ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
