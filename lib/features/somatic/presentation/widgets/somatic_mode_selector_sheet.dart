import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/somatic_exercise_mode.dart';

/// Low-stimulation modal bottom sheet allowing switching between somatic centering exercises.
class SomaticModeSelectorSheet extends StatelessWidget {
  const SomaticModeSelectorSheet({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  final SomaticExerciseMode currentMode;
  final ValueChanged<SomaticExerciseMode> onModeSelected;

  static Future<void> show(
    BuildContext context, {
    required SomaticExerciseMode currentMode,
    required ValueChanged<SomaticExerciseMode> onModeSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SomaticModeSelectorSheet(
        currentMode: currentMode,
        onModeSelected: onModeSelected,
      ),
    );
  }

  IconData _getModeIcon(SomaticExerciseMode mode) {
    switch (mode) {
      case SomaticExerciseMode.heavyBody:
        return Icons.arrow_downward_rounded;
      case SomaticExerciseMode.warmHands:
        return Icons.front_hand_rounded;
      case SomaticExerciseMode.mountainPosture:
        return Icons.landscape_rounded;
      case SomaticExerciseMode.mindfulPause:
        return Icons.pause_circle_filled_rounded;
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
            'Somatic Centering Exercises',
            style: AppTypography.titleMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Choose an exercise to release tension and anchor into physical stability.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          ...SomaticExerciseMode.values.map((mode) {
            final isSelected = mode == currentMode;

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
                    onModeSelected(mode);
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
                          _getModeIcon(mode),
                          color: isSelected ? colors.primary : colors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: SpacingTokens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mode.subtitle,
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
