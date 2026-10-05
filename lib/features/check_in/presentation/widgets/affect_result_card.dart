import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/recommendation_engine/models/action_suggestion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';

class AffectResultCard extends StatefulWidget {
  const AffectResultCard({
    super.key,
    required this.suggestion,
    required this.onCheckInAgain,
  });

  final ActionSuggestion suggestion;
  final VoidCallback onCheckInAgain;

  @override
  State<AffectResultCard> createState() => _AffectResultCardState();
}

class _AffectResultCardState extends State<AffectResultCard> {
  bool _showAlternatives = false;

  IconData _iconForAction(ActionType action) {
    switch (action) {
      case ActionType.breathing:
        return AppIcons.breathe;
      case ActionType.tinySteps:
        return AppIcons.tinySteps;
      case ActionType.lonelinessComfort:
        return Icons.favorite_border_rounded;
      case ActionType.grounding:
        return AppIcons.progress;
      case ActionType.journaling:
        return AppIcons.journal;
      case ActionType.hopeBox:
        return Icons.inventory_2_outlined;
      case ActionType.soundscape:
        return AppIcons.soundWaves;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final suggestion = widget.suggestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FireflyCard(
          padding: const EdgeInsets.all(SpacingTokens.cardPaddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.spaceSm,
                      vertical: SpacingTokens.space2xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.actionSage.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForAction(suggestion.actionType),
                          size: IconSizeTokens.sm,
                          color: colors.actionSage,
                        ),
                        const SizedBox(width: SpacingTokens.spaceXs),
                        Text(
                          'Recommended Next',
                          style: AppTypography.labelSm.copyWith(
                            color: colors.actionSage,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '~${suggestion.durationMinutes} min',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.spaceMd),
              Text(
                suggestion.title,
                style: AppTypography.headingLg.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceXs),
              Text(
                suggestion.body,
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: SpacingTokens.sectionGap),
              FireflyButton(
                text: 'Begin Now',
                icon: AppIcons.forward,
                variant: FireflyButtonVariant.primary,
                onPressed: () {
                  context.push(suggestion.route);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.elementGap),

        // Alternative suggestions toggle
        if (suggestion.alternativeSuggestions.isNotEmpty) ...[
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showAlternatives = !_showAlternatives;
                });
              },
              icon: Icon(
                _showAlternatives
                    ? AppIcons.chevronUp
                    : AppIcons.chevronDown,
                color: colors.textSecondary,
                size: IconSizeTokens.appAction,
              ),
              label: Text(
                _showAlternatives
                    ? 'Hide other options'
                    : 'Try something else',
                style: AppTypography.bodySm.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          if (_showAlternatives) ...[
            const SizedBox(height: SpacingTokens.spaceXs),
            ...suggestion.alternativeSuggestions.map(
              (alt) => Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.spaceXs),
                child: FireflyCard(
                  variant: FireflyCardVariant.interactive,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.spaceMd,
                    vertical: SpacingTokens.spaceSm,
                  ),
                  onTap: () => context.push(alt.route),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SpacingTokens.spaceXs),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconForAction(alt.actionType),
                          color: colors.actionSage,
                          size: IconSizeTokens.md,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.elementGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alt.title,
                              style: AppTypography.labelMd.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alt.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                        size: IconSizeTokens.md,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],

        const SizedBox(height: SpacingTokens.elementGap),

        // Reset & Check-in again
        FireflyButton(
          text: 'Check in again',
          variant: FireflyButtonVariant.secondary,
          onPressed: widget.onCheckInAgain,
        ),
      ],
    );
  }
}
