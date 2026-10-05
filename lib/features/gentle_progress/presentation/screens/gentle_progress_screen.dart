import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_card.dart';

class GentleProgressScreen extends StatelessWidget {
  const GentleProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        title: Text(
          'Gentle Progress',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                'No streaks. No scores. Just quiet presence.',
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: SpacingTokens.sectionGap),

              // Presence Card (Week view)
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
                          'Recent Presence',
                          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.spaceXs),
                    Text(
                      'Every moment you took a breath or paused here counts.',
                      style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: SpacingTokens.spaceMd),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((e) {
                        final isPresent = e.key >= 2;
                        return Column(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPresent ? colors.actionSage.withOpacity(0.2) : colors.surfaceSubtle,
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

              // Quiet Milestones
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
                      description: 'Cyclic sighing sessions paused nervous system overload.',
                    ),
                    const Divider(height: 24),
                    _buildMilestoneRow(
                      context,
                      icon: AppIcons.journal,
                      label: 'Private Reflection',
                      description: 'Thoughts written and held in device-only encrypted storage.',
                    ),
                    const Divider(height: 24),
                    _buildMilestoneRow(
                      context,
                      icon: AppIcons.tinySteps,
                      label: 'Micro-Actions Taken',
                      description: 'Low-effort behavioural activation completed without friction.',
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
