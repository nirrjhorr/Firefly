import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class EnergySlider extends StatefulWidget {
  const EnergySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value; // 1 to 5
  final ValueChanged<int> onChanged;

  @override
  State<EnergySlider> createState() => _EnergySliderState();
}

class _EnergySliderState extends State<EnergySlider> {
  int _lastTickValue = 3;

  @override
  void initState() {
    super.initState();
    _lastTickValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Energy Level',
              style: AppTypography.headingMd.copyWith(
                color: colors.textPrimary,
              ),
            ),
            Text(
              _energyLabel(widget.value),
              style: AppTypography.bodySm.copyWith(
                color: colors.actionSage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: colors.actionSage,
            inactiveTrackColor: colors.surfaceSubtle,
            thumbColor: colors.actionSage,
            overlayColor: colors.actionSage.withOpacity(0.16),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
            activeTickMarkColor: colors.surfaceCard,
            inactiveTickMarkColor: colors.borderSubtle,
          ),
          child: Slider(
            value: widget.value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (val) {
              final intValue = val.round();
              if (intValue != _lastTickValue) {
                _lastTickValue = intValue;
                if (intValue == 3) {
                  HapticFeedback.mediumImpact();
                } else {
                  HapticFeedback.selectionClick();
                }
              }
              widget.onChanged(intValue);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Still',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                'Moving',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _energyLabel(int val) {
    switch (val) {
      case 1:
        return 'Still';
      case 2:
        return 'Slow';
      case 3:
        return 'Steady';
      case 4:
        return 'Active';
      case 5:
        return 'Moving';
      default:
        return 'Steady';
    }
  }
}
