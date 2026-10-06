import 'package:flutter/material.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/cognitive_exercise.dart';

/// Low-stimulation mode selector pills for the 4 cognitive grounding modalities.
class CognitiveModeSelector extends StatelessWidget {
  const CognitiveModeSelector({
    super.key,
    required this.currentType,
    required this.onSelectType,
  });

  final CognitiveExerciseType currentType;
  final ValueChanged<CognitiveExerciseType> onSelectType;

  IconData _getIconForType(CognitiveExerciseType type) {
    switch (type) {
      case CognitiveExerciseType.alphabetCategories:
        return Icons.sort_by_alpha_rounded;
      case CognitiveExerciseType.backwardCounting:
        return Icons.pin_outlined;
      case CognitiveExerciseType.wordAssociation:
        return Icons.auto_awesome_rounded;
      case CognitiveExerciseType.memorySequence:
        return Icons.spa_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.spaceXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CognitiveExerciseType.values.map((type) {
          final isSelected = type == currentType;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.spaceSm),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${type.displayName} exercise',
              child: InkWell(
                key: Key('cognitive_mode_${type.name}'),
                onTap: () => onSelectType(type),
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                child: AnimatedContainer(
                  duration: AnimationTokens.fast,
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.spaceMd,
                    vertical: SpacingTokens.spaceSm,
                  ),
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.actionSage.withOpacity(0.18)
                        : colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    border: Border.all(
                      color: isSelected
                          ? colors.actionSage
                          : colors.borderSubtle,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForType(type),
                        size: 18,
                        color: isSelected
                            ? colors.actionSage
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: SpacingTokens.spaceSm),
                      Text(
                        type.displayName,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? colors.actionSage
                              : colors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
