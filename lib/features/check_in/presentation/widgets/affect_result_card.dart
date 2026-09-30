import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/recommendation_engine/models/action_suggestion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
        return Icons.air;
      case ActionType.tinySteps:
        return Icons.touch_app_outlined;
      case ActionType.lonelinessComfort:
        return Icons.favorite_border;
      case ActionType.grounding:
        return Icons.spa_outlined;
      case ActionType.journaling:
        return Icons.edit_note_outlined;
      case ActionType.hopeBox:
        return Icons.inventory_2_outlined;
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.actionSage.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForAction(suggestion.actionType),
                          size: 16,
                          color: colors.actionSage,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Recommended Next',
                          style: AppTypography.caption.copyWith(
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
              const SizedBox(height: 16),
              Text(
                suggestion.title,
                style: AppTypography.headingLg.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                suggestion.body,
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              FireflyButton(
                text: 'Begin Now',
                icon: Icons.arrow_forward,
                variant: FireflyButtonVariant.primary,
                onPressed: () {
                  context.push(suggestion.route);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Alternative suggestions
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
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: colors.textSecondary,
                size: 20,
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
            const SizedBox(height: 8),
            ...suggestion.alternativeSuggestions.map(
              (alt) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FireflyCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onTap: () => context.push(alt.route),
                  child: Row(
                    children: [
                      Icon(
                        _iconForAction(alt.actionType),
                        color: colors.actionSage,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alt.title,
                              style: AppTypography.headingMd.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
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
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],

        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: widget.onCheckInAgain,
            child: Text(
              'Check in again',
              style: AppTypography.bodySm.copyWith(
                color: colors.actionSage,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
