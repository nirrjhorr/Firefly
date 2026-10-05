import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/animation_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/icon_tokens.dart';
import '../../core/theme/radius_tokens.dart';
import '../../core/theme/spacing_tokens.dart';

enum MoodCategory {
  heavy('Heavy', AppIcons.moodHeavy, 'Heavy emotional state'),
  low('Low', AppIcons.moodLow, 'Low energy or flat mood'),
  here('Here', AppIcons.moodHere, 'Present and holding steady'),
  light('Light', AppIcons.moodLight, 'Lighter and easing'),
  open('Open', AppIcons.moodOpen, 'Open and receptive');

  const MoodCategory(this.label, this.icon, this.semanticDescription);

  final String label;
  final IconData icon;
  final String semanticDescription;
}

/// Canonical mood selector tile for Firefly.
/// Implements exact 72x72dp dimensions, 20dp corner radius, and calm tactile feedback.
class MoodTile extends StatefulWidget {
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
  State<MoodTile> createState() => _MoodTileState();
}

class _MoodTileState extends State<MoodTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final borderColor =
        widget.isSelected ? colors.actionSage : colors.borderSubtle;
    final backgroundColor = widget.isSelected
        ? colors.actionSage.withOpacity(0.14)
        : colors.surfaceCard;
    final iconColor =
        widget.isSelected ? colors.actionSage : colors.textSecondary;
    final textColor =
        widget.isSelected ? colors.textPrimary : colors.textSecondary;

    return Semantics(
      label: '${widget.mood.label}: ${widget.mood.semanticDescription}',
      selected: widget.isSelected,
      button: true,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedContainer(
            duration: MotionTokens.quick,
            curve: Curves.easeOut,
            width: SpacingTokens.moodTileSize,
            height: SpacingTokens.moodTileSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(RadiusTokens.xl),
              border: Border.all(
                color: borderColor,
                width: widget.isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.mood.icon,
                  color: iconColor,
                  size: IconSizeTokens.tile,
                ),
                const SizedBox(height: SpacingTokens.space2xs),
                Text(
                  widget.mood.label,
                  style: AppTypography.labelSm.copyWith(
                    color: textColor,
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
