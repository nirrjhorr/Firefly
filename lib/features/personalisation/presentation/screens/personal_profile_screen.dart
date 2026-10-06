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
import '../../../../shared/widgets/firefly_empty_state.dart';
import '../../../../shared/widgets/firefly_nav_header.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../controllers/personal_profile_controller.dart';

/// Screen displaying the user's on-device personal regulation effectiveness
/// profile, showing which practices bring the most settledness across emotional states.
class PersonalProfileScreen extends ConsumerStatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  ConsumerState<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends ConsumerState<PersonalProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(personalProfileControllerProvider.notifier).loadProfile();
    });
  }

  String _formatActivityTitle(String activityId) {
    // Map known activity IDs to friendly titles
    final mapping = {
      'act_cyclic_sighing': 'Cyclic Sighing Breathing',
      'act_box_breathing': 'Box Breathing',
      'act_54321': '5-4-3-2-1 Sensory Grounding',
      'act_three_priorities': 'Three Priorities Mode',
      'act_serene_focus_timer': 'Serene Focus Companion',
      'act_self_compassion_break': 'Self-Compassion Break',
      'act_thought_untangler': 'Thought Untangler',
      'act_one_session_reset': 'One-Session Reset',
      'act_pmr_full': 'Progressive Muscle Relaxation',
      'act_hope_box': 'Hope Box Vault',
      'act_loneliness_comfort': 'Loneliness Comfort',
      'act_shakeout': 'Somatic Shakeout',
      'act_tiny_steps': 'Tiny Steps (Micro-Action)',
      'act_soundscape': 'Sound Sanctuary',
      'act_labyrinth': 'Meditative Labyrinth',
      'act_flow_puzzle': 'Spatial Flow Puzzle',
    };
    if (mapping.containsKey(activityId)) return mapping[activityId]!;

    // Clean fallback: "act_foo_bar" -> "Foo Bar"
    final clean = activityId.replaceFirst('act_', '').replaceAll('_', ' ');
    if (clean.isEmpty) return 'Regulation Practice';
    return clean[0].toUpperCase() + clean.substring(1);
  }

  String _routeForActivity(String activityId) {
    if (activityId.contains('sighing') || activityId.contains('breathing')) {
      return AppRoutes.breathe;
    }
    if (activityId.contains('54321') || activityId.contains('grounding')) {
      return '${AppRoutes.breathe}?mode=grounding';
    }
    if (activityId.contains('priorities') || activityId.contains('focus')) {
      return AppRoutes.focus;
    }
    if (activityId.contains('compassion') || activityId.contains('thought')) {
      return AppRoutes.compassion;
    }
    if (activityId.contains('reset')) {
      return AppRoutes.reset;
    }
    if (activityId.contains('pmr')) {
      return AppRoutes.pmr;
    }
    if (activityId.contains('hope')) {
      return AppRoutes.hopeBox;
    }
    if (activityId.contains('loneliness')) {
      return AppRoutes.loneliness;
    }
    if (activityId.contains('shakeout') || activityId.contains('move')) {
      return '${AppRoutes.movement}?mode=shakeout';
    }
    if (activityId.contains('sound') || activityId.contains('audio')) {
      return AppRoutes.soundscapes;
    }
    if (activityId.contains('labyrinth')) {
      return AppRoutes.labyrinth;
    }
    if (activityId.contains('puzzle') || activityId.contains('flow')) {
      return AppRoutes.flowPuzzle;
    }
    return AppRoutes.activities;
  }

  void _showClearHistoryDialog() {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.container),
          ),
          title: Text(
            'Reset Sanctuary Learning?',
            style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
          ),
          content: Text(
            'This will clear your on-device activity ratings and return recommendations to clinical defaults. Your journal, hope box, and check-in history will remain intact.',
            style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Keep Learning',
                style: AppTypography.labelMd.copyWith(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                HapticFeedback.mediumImpact();
                ref.read(personalProfileControllerProvider.notifier).clearHistory();
              },
              child: Text(
                'Reset Profile',
                style: AppTypography.labelMd.copyWith(color: colors.crisisCoral),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(personalProfileControllerProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                FireflyNavHeader(
                  title: 'Personal Sanctuary',
                  subtitle: 'What settles your nervous system',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: state.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation(colors.actionSage),
                          ),
                        )
                      : profile.isEmpty
                          ? FireflyEmptyState(
                              icon: Icons.spa_outlined,
                              title: 'Your sanctuary is learning with you',
                              description:
                                  'After any regulation practice, note how your body and mind feel. Firefly will quietly discover what brings you back to center.',
                              actionText: 'Explore Practices',
                              actionIcon: AppIcons.forward,
                              onAction: () => context.push(AppRoutes.activities),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpacingTokens.screenPaddingH,
                                vertical: SpacingTokens.spaceMd,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 640),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Summary Metrics Card
                                      FireflyCard(
                                        padding: const EdgeInsets.all(
                                          SpacingTokens.cardPaddingLg,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: colors.actionSage
                                                        .withOpacity(0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.auto_awesome_rounded,
                                                    color: colors.actionSage,
                                                    size: IconSizeTokens.md,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: SpacingTokens.spaceSm,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Moments of Self-Care',
                                                        style: AppTypography
                                                            .labelSm
                                                            .copyWith(
                                                          color: colors
                                                              .actionSage,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${profile.totalMomentsOfCare} guided sessions completed',
                                                        style: AppTypography
                                                            .headingMd
                                                            .copyWith(
                                                          color: colors
                                                              .textPrimary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: SpacingTokens.spaceMd,
                                            ),
                                            Text(
                                              '${(profile.calmingRate * 100).round()}% of your sessions brought measurable settledness to your nervous system. Zero streaks, zero guilt—just self-awareness.',
                                              style: AppTypography.bodySm
                                                  .copyWith(
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: SpacingTokens.sectionGap,
                                      ),

                                      // Breakdown by State
                                      Text(
                                        'What Helps You Most',
                                        style: AppTypography.headingMd
                                            .copyWith(
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: SpacingTokens.spaceXs,
                                      ),
                                      Text(
                                        'Practices that have proven effective when you feel these states:',
                                        style: AppTypography.bodySm
                                            .copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: SpacingTokens.spaceMd,
                                      ),

                                      ...profile.topPracticesByState.entries
                                          .map((entry) {
                                        final stateName = entry.key;
                                        final affinities = entry.value;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: SpacingTokens.spaceLg,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: colors.actionSage,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: SpacingTokens.spaceXs,
                                                  ),
                                                  Text(
                                                    'When feeling ${stateName.toUpperCase()}',
                                                    style: AppTypography
                                                        .labelMd
                                                        .copyWith(
                                                      color: colors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: SpacingTokens.spaceSm,
                                              ),
                                              ...affinities.map((aff) {
                                                final title =
                                                    _formatActivityTitle(
                                                        aff.activityId);
                                                final route =
                                                    _routeForActivity(
                                                        aff.activityId);
                                                final avgShift = aff
                                                            .averageRating >
                                                        0
                                                    ? '+${aff.averageRating.toStringAsFixed(1)}'
                                                    : aff.averageRating
                                                        .toStringAsFixed(1);

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom:
                                                        SpacingTokens.spaceXs,
                                                  ),
                                                  child: FireflyCard(
                                                    variant: FireflyCardVariant
                                                        .interactive,
                                                    padding:
                                                        const EdgeInsets.all(
                                                      SpacingTokens.spaceMd,
                                                    ),
                                                    onTap: () {
                                                      HapticFeedback
                                                          .selectionClick();
                                                      context.push(route);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                title,
                                                                style: AppTypography
                                                                    .labelMd
                                                                    .copyWith(
                                                                  color: colors
                                                                      .textPrimary,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 2,
                                                              ),
                                                              Text(
                                                                'Practiced ${aff.sampleCount} times • Avg shift: $avgShift / 2',
                                                                style: AppTypography
                                                                    .caption
                                                                    .copyWith(
                                                                  color: colors
                                                                      .textSecondary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(
                                                          AppIcons.forward,
                                                          size:
                                                              IconSizeTokens.sm,
                                                          color: colors
                                                              .actionSage,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        );
                                      }),

                                      const SizedBox(
                                        height: SpacingTokens.spaceLg,
                                      ),

                                      // On-Device Privacy Shield
                                      FireflyCard(
                                        padding: const EdgeInsets.all(
                                          SpacingTokens.cardPadding,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.shield_outlined,
                                              color: colors.actionSage,
                                              size: IconSizeTokens.lg,
                                            ),
                                            const SizedBox(
                                              width: SpacingTokens.spaceMd,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '100% On-Device & Encrypted. Your regulation profile never leaves this phone. No telemetry, no accounts, zero cloud access.',
                                                style: AppTypography.captionSm
                                                    .copyWith(
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: SpacingTokens.spaceMd,
                                      ),

                                      // Clear learning button
                                      Center(
                                        child: TextButton.icon(
                                          onPressed: _showClearHistoryDialog,
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            color: colors.textSecondary,
                                            size: IconSizeTokens.sm,
                                          ),
                                          label: Text(
                                            'Reset Sanctuary Learning',
                                            style: AppTypography.captionSm
                                                .copyWith(
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: SpacingTokens.space2xl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
            // Floating persistent SOS overlay
            Positioned(
              top: SpacingTokens.spaceSm,
              right: SpacingTokens.spaceSm,
              child: const SosOverlayButton(),
            ),
          ],
        ),
      ),
    );
  }
}
