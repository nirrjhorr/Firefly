import 'package:flutter/material.dart';

import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/nature_observation_mode.dart';

/// Low-stimulation mode selector pills for the 5 nature observation modalities.
class NatureModeSelector extends StatelessWidget {
  const NatureModeSelector({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
  });

  final NatureObservationMode currentMode;
  final ValueChanged<NatureObservationMode> onSelectMode;

  IconData _getIconForMode(NatureObservationMode mode) {
    switch (mode) {
      case NatureObservationMode.skyGazing:
        return Icons.cloud_outlined;
      case NatureObservationMode.treeCanopy:
        return Icons.park_outlined;
      case NatureObservationMode.lightAndShadow:
        return Icons.wb_sunny_outlined;
      case NatureObservationMode.outdoorGrounding:
        return Icons.nature_people_outlined;
      case NatureObservationMode.weatherNotice:
        return Icons.air_rounded;
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
        children: NatureObservationMode.values.map((mode) {
          final isSelected = mode == currentMode;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.spaceSm),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${mode.title} observation mode',
              child: InkWell(
                key: Key('nature_mode_${mode.name}'),
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
                      color: isSelected ? colors.actionSage : colors.borderSubtle,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForMode(mode),
                        size: 18,
                        color: isSelected
                            ? colors.actionSage
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: SpacingTokens.spaceSm),
                      Text(
                        mode.title,
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
