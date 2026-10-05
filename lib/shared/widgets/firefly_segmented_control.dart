import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/animation_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/icon_tokens.dart';
import '../../core/theme/radius_tokens.dart';

class SegmentItem<T> {
  const SegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Canonical Apple-inspired segmented pill control.
/// Offers tactile sliding feedback, high legibility, and low cognitive load.
class FireflySegmentedControl<T> extends StatelessWidget {
  const FireflySegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.height = 42.0,
  });

  final List<SegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: height,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        border: Border.all(
          color: colors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onValueChanged(item.value);
                }
              },
              child: AnimatedContainer(
                duration: MotionTokens.quick,
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? colors.surfaceCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  border: isSelected
                      ? Border.all(color: colors.actionSage.withOpacity(0.4), width: 1.0)
                      : Border.all(color: Colors.transparent, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: IconSizeTokens.sm,
                          color: isSelected ? colors.actionSage : colors.textSecondary,
                        ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.label,
                      style: AppTypography.labelMd.copyWith(
                        color: isSelected ? colors.textPrimary : colors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
