import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/cooperative_activity.dart';

/// Interactive UI section presenting curated cooperative connection activities.
/// Allows users to explore low-demand connection options and invite a trusted contact.
class CooperativeActivitiesSection extends StatefulWidget {
  final ValueChanged<CooperativeActivity> onInvitePressed;

  const CooperativeActivitiesSection({
    super.key,
    required this.onInvitePressed,
  });

  @override
  State<CooperativeActivitiesSection> createState() =>
      _CooperativeActivitiesSectionState();
}

class _CooperativeActivitiesSectionState
    extends State<CooperativeActivitiesSection> {
  String? _expandedActivityId;

  IconData _resolveIcon(String iconKey) {
    switch (iconKey) {
      case 'person.2':
        return Icons.people_outline_rounded;
      case 'heart':
        return Icons.favorite_border_rounded;
      case 'puzzlepiece':
        return Icons.extension_outlined;
      case 'cup.and.saucer':
        return Icons.coffee_outlined;
      default:
        return Icons.handshake_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cooperative Activities & Connection',
              style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Low-pressure ways to connect without conversational fatigue or performance anxiety.',
          style: AppTypography.caption.copyWith(
            color: colors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kCuratedCooperativeActivities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final activity = kCuratedCooperativeActivities[index];
            final isExpanded = _expandedActivityId == activity.id;

            return FireflyCard(
              padding: const EdgeInsets.all(SpacingTokens.spaceMd),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _expandedActivityId = isExpanded ? null : activity.id;
                });
              },
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
                          color: colors.actionSage.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(RadiusTokens.chip),
                        ),
                        child: Icon(
                          _resolveIcon(activity.iconKey),
                          color: colors.actionSage,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpacingTokens.spaceXs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.bgSurface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: colors.borderSubtle),
                                  ),
                                  child: Text(
                                    activity.category,
                                    style: AppTypography.caption.copyWith(
                                      color: colors.actionSage,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.title,
                              style: AppTypography.headingMd.copyWith(
                                color: colors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity.subtitle,
                              style: AppTypography.caption.copyWith(
                                color: colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),

                  // Expanded Description & Action Drawer
                  if (isExpanded) ...[
                    const SizedBox(height: SpacingTokens.spaceMd),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.bgCanvasDeep,
                        borderRadius: BorderRadius.circular(RadiusTokens.card),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.description,
                            style: AppTypography.bodyMd.copyWith(
                              color: colors.textPrimary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                AppIcons.insights,
                                color: colors.actionSage,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  activity.evidenceNote,
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Suggested Games (if applicable)
                          if (activity.suggestedGames.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Suggested Games:',
                              style: AppTypography.caption.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            for (final game in activity.suggestedGames)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: colors.actionSage,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      game,
                                      style: AppTypography.caption.copyWith(
                                        color: colors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.spaceMd),

                    // Pre-written invitation action button (Height ≥ 48dp)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.actionSage.withOpacity(0.18),
                          foregroundColor: colors.actionSage,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(RadiusTokens.button),
                            side: BorderSide(color: colors.actionSage.withOpacity(0.4)),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onInvitePressed(activity);
                        },
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: Text(
                          'Invite a Contact via SMS',
                          style: AppTypography.button.copyWith(
                            color: colors.actionSage,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
