import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/social_prediction_experiment.dart';

/// Cognitive reframing insight card appearing once ≥ 3 "Guess vs. Reality"
/// experiments have been completed. Disassembles social avoidance distortions.
class SocialInsightCard extends StatelessWidget {
  const SocialInsightCard({
    super.key,
    required this.summary,
  });

  final SocialExperimentSummary summary;

  @override
  Widget build(BuildContext context) {
    if (!summary.shouldShowInsight) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return FireflyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.actionSage.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.insights,
                  color: colors.actionSage,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.insightHeadline,
                      style: AppTypography.headingMd.copyWith(
                        color: colors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Kumar & Epley (2023) behavioral reframing',
                      style: AppTypography.caption.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            summary.insightBody,
            style: AppTypography.bodyMd.copyWith(
              color: colors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Mini statistics metrics row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.bgCanvasDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.borderSubtle, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  label: 'Reached Out',
                  value: '${summary.completedCount}x',
                ),
                Container(width: 1, height: 28, color: colors.borderSubtle),
                _buildStatItem(
                  context,
                  label: 'Warm Responses',
                  value: '${summary.actualWarmCount}',
                  valueColor: colors.actionSage,
                ),
                Container(width: 1, height: 28, color: colors.borderSubtle),
                _buildStatItem(
                  context,
                  label: 'Warmer or Met',
                  value: '${summary.warmerOrEqualPercentage}%',
                  valueColor: colors.accentAmber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final colors = context.colors;
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headingLg.copyWith(
            color: valueColor ?? colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: colors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
