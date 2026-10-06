import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/energy_slider.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../../../shared/widgets/mood_tile.dart';
import '../../../activities/presentation/widgets/right_now_modal.dart';
import '../controllers/check_in_controller.dart';
import '../widgets/affect_result_card.dart';

/// Primary check-in screen for Firefly.
/// Designed for low cognitive load: rapid affect labeling without clinical numbers.
class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkInControllerProvider);
    final controller = ref.read(checkInControllerProvider.notifier);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.screenPaddingH,
            SpacingTokens.screenPaddingV,
            SpacingTokens.screenPaddingH,
            SpacingTokens.bottomClearance,
          ),
          child: state.activeSuggestion != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Here is your next step',
                      style: AppTypography.displayMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.spaceXs),
                    Text(
                      'Based on how you are feeling right now.',
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sectionGap),
                    AffectResultCard(
                      suggestion: state.activeSuggestion!,
                      onCheckInAgain: () => controller.resetForNewCheckIn(),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you right now?',
                      style: AppTypography.displayMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take a quiet moment to notice what is present.',
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.spaceMd),

                    // FR-10: Immediate distress fast-path entry
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        RightNowModal.show(context);
                      },
                      borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.spaceMd,
                          vertical: SpacingTokens.spaceSm + 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.bgSurface,
                          borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                          border: Border.all(
                            color: colors.accentSage.withOpacity(0.35),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colors.accentSage.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bolt_rounded,
                                size: 18,
                                color: colors.accentSage,
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Need something right now?',
                                    style: AppTypography.headingSm.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Skip the check-in and start regulating immediately',
                                    style: AppTypography.captionSm.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: colors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sectionGap),

                    // 1. Mood Anchor (5 Moon Phase Tiles)
                    Text(
                      'Mood Anchor',
                      style: AppTypography.headingMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.elementGap),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: MoodCategory.values.map((mood) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: MoodTile(
                              mood: mood,
                              isSelected: state.selectedMood == mood,
                              onTap: () => controller.setMood(mood),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sectionGap),

                    // 2. Energy Slider ("Still -> Moving")
                    FireflyCard(
                      padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                      child: EnergySlider(
                        value: state.energyLevel,
                        onChanged: (val) => controller.setEnergy(val),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sectionGap),

                    // 3. Anxiety Level (5-dot selector)
                    FireflyCard(
                      padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                      child: _buildDotLevelSelector(
                        context,
                        title: 'Anxiety or Internal Tension',
                        description: 'Quiet → Racing or tense',
                        currentValue: state.anxietyLevel,
                        onChanged: (val) => controller.setAnxiety(val),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sectionGap),

                    // 4. Loneliness Level (5-dot selector)
                    FireflyCard(
                      padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                      child: _buildDotLevelSelector(
                        context,
                        title: 'Loneliness',
                        description: 'Connected / Content → Isolated',
                        currentValue: state.lonelinessLevel,
                        onChanged: (val) => controller.setLoneliness(val),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.space2xl),

                    // 5. Submit CTA
                    FireflyButton(
                      text: "I'm here",
                      isLoading: state.isSubmitting,
                      variant: FireflyButtonVariant.primary,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        controller.submitCheckIn();
                      },
                    ),
                    const SizedBox(height: SpacingTokens.sectionGap),

                    // 6. Sound Sanctuary Quick Access Card
                    FireflyCard(
                      variant: FireflyCardVariant.interactive,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRoutes.soundscapes);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.actionSage.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              AppIcons.audioFrequency,
                              color: colors.actionSage,
                              size: IconSizeTokens.nav,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sound Sanctuary',
                                  style: AppTypography.headingMd.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '29 offline restorative nature & noise soundscapes',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.chevronRight,
                            color: colors.textSecondary,
                            size: IconSizeTokens.appAction,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.elementGap),

                    // 7. Hope Box & Sleep Sanctuary Quick Access Row
                    Row(
                      children: [
                        Expanded(
                          child: FireflyCard(
                            variant: FireflyCardVariant.interactive,
                            padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push(AppRoutes.hopeBox);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5B870).withOpacity(0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite_border_rounded,
                                    color: Color(0xFFE5B870),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: SpacingTokens.spaceSm),
                                Text(
                                  'Hope Box',
                                  style: AppTypography.labelLg.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Reasons to stay & memories',
                                  style: AppTypography.captionSm.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.elementGap),
                        Expanded(
                          child: FireflyCard(
                            variant: FireflyCardVariant.interactive,
                            padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push(AppRoutes.sleep);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B8A9E).withOpacity(0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.bedtime_outlined,
                                    color: Color(0xFF6B8A9E),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: SpacingTokens.spaceSm),
                                Text(
                                  'Sleep Suite',
                                  style: AppTypography.labelLg.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Worry dump & fading timer',
                                  style: AppTypography.captionSm.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.elementGap),

                    // 8. Full Activity Library Entry Card
                    FireflyCard(
                      variant: FireflyCardVariant.interactive,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRoutes.activities);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.actionSage.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome_mosaic_rounded,
                              color: colors.actionSage,
                              size: IconSizeTokens.nav,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explore All Activities',
                                  style: AppTypography.headingMd.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '76 practices organized across 6 regulation groups',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.chevronRight,
                            color: colors.textSecondary,
                            size: IconSizeTokens.appAction,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.elementGap),

                    // 9. One-Session Reset (Single-Session Intervention)
                    FireflyCard(
                      variant: FireflyCardVariant.interactive,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRoutes.reset);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.actionSage.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.spa_rounded,
                              color: colors.actionSage,
                              size: IconSizeTokens.nav,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'One-Session Reset',
                                  style: AppTypography.headingMd.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '5-minute guided reset when you feel overwhelmed',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.chevronRight,
                            color: colors.textSecondary,
                            size: IconSizeTokens.appAction,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.elementGap),

                    // 10. Personal Sanctuary & Regulation Profile
                    FireflyCard(
                      variant: FireflyCardVariant.interactive,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRoutes.profile);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.accentSecondary.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: colors.accentSecondary,
                              size: IconSizeTokens.nav,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Sanctuary',
                                  style: AppTypography.headingMd.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'What settles your body & mind based on past relief',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.chevronRight,
                            color: colors.textSecondary,
                            size: IconSizeTokens.appAction,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDotLevelSelector(
    BuildContext context, {
    required String title,
    required String description,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.headingMd.copyWith(
                color: colors.textPrimary,
              ),
            ),
            Text(
              _levelDescriptor(currentValue),
              style: AppTypography.bodySm.copyWith(
                color: colors.actionSage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: AppTypography.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = level == currentValue;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(level);
              },
              child: Semantics(
                label: '$title level $level',
                selected: isSelected,
                button: true,
                child: Container(
                  width: 52,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.actionSage.withOpacity(0.18)
                        : colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    border: Border.all(
                      color: isSelected ? colors.actionSage : colors.borderSubtle,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Container(
                    width: 10 + (level * 2.5),
                    height: 10 + (level * 2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colors.actionSage
                          : colors.textSecondary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _levelDescriptor(int val) {
    switch (val) {
      case 1:
        return 'Quiet';
      case 2:
        return 'Mild';
      case 3:
        return 'Noticeable';
      case 4:
        return 'Strong';
      case 5:
        return 'Intense';
      default:
        return 'Moderate';
    }
  }
}
