import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/labyrinth_pattern_type.dart';

/// Low-stimulation modal sheet allowing selection of meditative labyrinth patterns (Story 12.3).
class LabyrinthPatternSelectorSheet extends StatelessWidget {
  const LabyrinthPatternSelectorSheet({
    super.key,
    required this.currentPattern,
    required this.onPatternSelected,
  });

  final LabyrinthPatternType currentPattern;
  final ValueChanged<LabyrinthPatternType> onPatternSelected;

  static Future<void> show(
    BuildContext context, {
    required LabyrinthPatternType currentPattern,
    required ValueChanged<LabyrinthPatternType> onPatternSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LabyrinthPatternSelectorSheet(
        currentPattern: currentPattern,
        onPatternSelected: onPatternSelected,
      ),
    );
  }

  IconData _getPatternIcon(LabyrinthPatternType pattern) {
    switch (pattern) {
      case LabyrinthPatternType.classical:
        return Icons.fingerprint_rounded;
      case LabyrinthPatternType.spiral:
        return Icons.cyclone_rounded;
      case LabyrinthPatternType.infinity:
        return Icons.all_inclusive_rounded;
      case LabyrinthPatternType.meander:
        return Icons.waves_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.xl),
        ),
        border: Border(
          top: BorderSide(
            color: colors.outline.withOpacity(0.35),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline.withOpacity(0.40),
                borderRadius: BorderRadius.circular(RadiusTokens.full),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),

          Text(
            'Contemplative Tracing Patterns',
            style: AppTypography.titleMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Choose a geometric pathway to guide your fingers and settle busy thoughts.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          ...LabyrinthPatternType.values.map((pattern) {
            final isSelected = pattern == currentPattern;

            return Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: Material(
                color: isSelected
                    ? colors.primary.withOpacity(0.15)
                    : colors.surfaceContainer,
                borderRadius: BorderRadius.circular(RadiusTokens.lg),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onPatternSelected(pattern);
                  },
                  borderRadius: BorderRadius.circular(RadiusTokens.lg),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 56), // Enforce ≥ 56dp
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(RadiusTokens.lg),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.outline.withOpacity(0.25),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getPatternIcon(pattern),
                          color: isSelected ? colors.primary : colors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: SpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pattern.title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pattern.subtitle,
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: colors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
