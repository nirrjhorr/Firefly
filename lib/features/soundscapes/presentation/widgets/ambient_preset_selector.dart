import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/ambient_mixer_preset.dart';

/// Horizontal selector for curated restorative audio mixer presets.
class AmbientPresetSelector extends StatelessWidget {
  final List<AmbientMixerPreset> presets;
  final String? activePresetId;
  final ValueChanged<AmbientMixerPreset> onPresetSelected;

  const AmbientPresetSelector({
    super.key,
    required this.presets,
    required this.activePresetId,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    const warmAmber = Color(0xFFE5B870);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Restorative Presets',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: warmAmber,
              ),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Text(
              '• Zero-decision combinations',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF84B09A),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((preset) {
              final isSelected = preset.id == activePresetId;

              return Padding(
                padding: const EdgeInsets.only(right: SpacingTokens.sm),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onPresetSelected(preset);
                  },
                  borderRadius: BorderRadius.circular(RadiusTokens.chip),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0x33E5B870) : const Color(0xFF14191D),
                      borderRadius: BorderRadius.circular(RadiusTokens.chip),
                      border: Border.all(
                        color: isSelected ? warmAmber : const Color(0x33E5B870),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      preset.title,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFFF2D9A8) : const Color(0xFFC4CDD4),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
