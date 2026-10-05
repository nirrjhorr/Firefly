import 'package:flutter/material.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/grounding_stage.dart';

/// Horizontal low-stimulation mode selector for the 5 evidence-informed sensory grounding modes.
class GroundingModeSelector extends StatelessWidget {
  final GroundingMode currentMode;
  final ValueChanged<GroundingMode> onSelectMode;

  const GroundingModeSelector({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
  });

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
        children: GroundingMode.values.map((mode) {
          final isSelected = mode == currentMode;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.spaceSm),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${mode.label} grounding mode',
              child: InkWell(
                key: Key('grounding_mode_${mode.name}'),
                onTap: () => onSelectMode(mode),
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
                        IconData(mode.icon.codePoint, fontFamily: mode.icon.fontFamily),
                        size: 18,
                        color: isSelected ? colors.actionSage : colors.textSecondary,
                      ),
                      const SizedBox(width: SpacingTokens.spaceXs),
                      Text(
                        mode.label,
                        style: AppTypography.labelMd.copyWith(
                          color: isSelected ? colors.textPrimary : colors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
