import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/defusion_mode.dart';

/// Clean, low-stimulation selector for switching between the 3 Defusion modes.
class DefusionModeSelector extends StatelessWidget {
  const DefusionModeSelector({
    required this.activeMode,
    required this.onSelectMode,
    super.key,
  });

  final DefusionMode activeMode;
  final ValueChanged<DefusionMode> onSelectMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.spaceLg),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: DefusionMode.values.map((mode) {
          final isSelected = activeMode == mode;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              label: mode.displayName,
              child: InkWell(
                onTap: () => onSelectMode(mode),
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.surfaceCard
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    border: isSelected
                        ? Border.all(color: colors.actionSage.withOpacity(0.5))
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getModeIcon(mode),
                        size: 16,
                        color: isSelected
                            ? colors.actionSage
                            : colors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getShortName(mode),
                          style: AppTypography.captionSm.copyWith(
                            color: isSelected
                                ? colors.textPrimary
                                : colors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
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

  IconData _getModeIcon(DefusionMode mode) {
    switch (mode) {
      case DefusionMode.leavesOnStream:
        return AppIcons.nature;
      case DefusionMode.thoughtClouds:
        return Icons.cloud_outlined;
      case DefusionMode.thoughtLabeling:
        return Icons.format_quote_rounded;
    }
  }

  String _getShortName(DefusionMode mode) {
    switch (mode) {
      case DefusionMode.leavesOnStream:
        return 'Stream';
      case DefusionMode.thoughtClouds:
        return 'Clouds';
      case DefusionMode.thoughtLabeling:
        return 'Distance';
    }
  }
}
