import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../controllers/gentle_progress_controller.dart';
import '../../domain/models/gentle_progress_data.dart';

/// Gentle Progress Screen (PRD §5 / FR-06 / FR-07):
/// Quiet, non-gamified presence indicator and cognitive reframing evidence.
///
/// Principles:
/// - Anti-gamification: Zero streaks, zero scores, zero shame on missed days.
/// - Live data synthesis from encrypted local DB (journaling, grounding, micro-actions, social experiments).
/// - Discrete presence dots for the current week.
class GentleProgressScreen extends ConsumerWidget {
  const GentleProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final progressAsync = ref.watch(gentleProgressControllerProvider);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        title: Text(
          'Gentle Progress',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textSecondary),
            tooltip: 'Refresh presence',
            onPressed: () => ref.read(gentleProgressControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: SafeArea(
        child: progressAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.screenPaddingH),
              child: Text(
                'Presence is quietly recorded on your device.',
                style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
          data: (data) => _buildContent(context, ref, data),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    GentleProgressData data,
  ) {
    final colors = context.colors;

    final subtitleDays = data.activeDaysCount == 0
        ? 'Showing up whenever you are ready.'
        : 'You showed up ${data.activeDaysCount} ${data.activeDaysCount == 1 ? 'day' : 'days'} this week.';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.screenPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How you\'ve been showing up for yourself',
            style: AppTypography.headingLg.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceXs),
          Text(
            '$subtitleDays No streaks. No pressure. Just quiet care.',
            style: AppTypography.bodyMd.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: SpacingTokens.sectionGap),

          // Presence Card (Week view dynamically rendered)
          FireflyCard(
            padding: const EdgeInsets.all(SpacingTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.progress, color: colors.actionSage, size: IconSizeTokens.appAction),
                    const SizedBox(width: SpacingTokens.spaceSm),
                    Text(
                      'This Week\'s Presence',
                      style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.spaceXs),
                Text(
                  'Every moment you paused, took a breath, or rested here is recognized.',
                  style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: SpacingTokens.spaceMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((e) {
                    final isPresent = e.key < data.weekPresence.length
                        ? data.weekPresence[e.key]
                        : false;

                    return Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPresent
                                ? colors.actionSage.withOpacity(0.2)
                                : colors.surfaceSubtle,
                            border: Border.all(
                              color: isPresent ? colors.actionSage : colors.borderSubtle,
                            ),
                          ),
                          child: isPresent
                              ? Icon(AppIcons.check, size: IconSizeTokens.xs, color: colors.actionSage)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          e.value,
                          style: AppTypography.caption.copyWith(
                            color: isPresent ? colors.textPrimary : colors.textTertiary,
                            fontWeight: isPresent ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceMd),

          // Empirical Cognitive Reframing (Guess vs. Reality) Card if unlocked
          if (data.socialSummary != null && data.socialSummary!.shouldShowInsight) ...[
            FireflyCard(
              padding: const EdgeInsets.all(SpacingTokens.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_outlined, color: Color(0xFFE5A93C), size: 24),
                      const SizedBox(width: SpacingTokens.spaceSm),
                      Expanded(
                        child: Text(
                          data.socialSummary!.insightHeadline,
                          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.spaceXs),
                  Text(
                    data.socialSummary!.insightBody,
                    style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: SpacingTokens.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5A93C).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(RadiusTokens.xs),
                    ),
                    child: Text(
                      '${data.socialSummary!.warmerOrEqualPercentage}% of reach-outs were warmer or equal to your fears.',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFFE5A93C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),
          ],

          // Quiet Milestones (Moments of Care Taken)
          FireflyCard(
            padding: const EdgeInsets.all(SpacingTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moments of Care Taken',
                  style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: SpacingTokens.spaceSm),
                _buildMilestoneRow(
                  context,
                  icon: AppIcons.breathe,
                  label: 'Grounding & Respiration',
                  description: data.groundingSessionsCount > 0
                      ? '${data.groundingSessionsCount} sessions completed to pause nervous system overload.'
                      : 'Cyclic sighing and somatic grounding whenever your body needs a pause.',
                ),
                const Divider(height: 24),
                _buildMilestoneRow(
                  context,
                  icon: AppIcons.journal,
                  label: 'Private Reflection',
                  description: data.journalEntriesCount > 0
                      ? '${data.journalEntriesCount} thoughts written and held in device-only encrypted storage.'
                      : 'Unsent letters and private notes encrypted on your device.',
                ),
                const Divider(height: 24),
                _buildMilestoneRow(
                  context,
                  icon: AppIcons.tinySteps,
                  label: 'Micro-Actions Taken',
                  description: data.tinyStepsCount > 0
                      ? '${data.tinyStepsCount} low-effort behavioural activations completed.'
                      : 'Gentle tiny steps to restore momentum without friction.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
  }) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.actionSage.withOpacity(0.12),
            borderRadius: BorderRadius.circular(RadiusTokens.xs),
          ),
          child: Icon(icon, color: colors.actionSage, size: IconSizeTokens.appAction),
        ),
        const SizedBox(width: SpacingTokens.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
