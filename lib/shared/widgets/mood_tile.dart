import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum MoodCategory {
  heavy('Heavy', Icons.nightlight_round, 'Heavy emotional state'),
  low('Low', Icons.mode_night_outlined, 'Low energy or flat mood'),
  here('Here', Icons.brightness_medium_outlined, 'Present and holding steady'),
  light('Light', Icons.wb_sunny_outlined, 'Lighter and easing'),
  open('Open', Icons.brightness_7_outlined, 'Open and receptive');

  const MoodCategory(this.label, this.icon, this.semanticDescription);

  final String label;
  final IconData icon;
  final String semanticDescription;
}

class MoodTile extends StatelessWidget {
  const MoodTile({
    super.key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final MoodCategory mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final borderColor = isSelected ? colors.actionSage : colors.borderSubtle;
    final backgroundColor = isSelected
        ? colors.actionSage.withOpacity(0.12)
        : colors.surfaceCard;
    final iconColor = isSelected ? colors.actionSage : colors.textSecondary;
    final textColor = isSelected ? colors.textPrimary : colors.textSecondary;

    return Semantics(
      label: '${mood.label}: ${mood.semanticDescription}',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 68,
          height: 84,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.actionSage.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mood.icon,
                color: iconColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                mood.label,
                style: AppTypography.labelMd.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
