import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/animation_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/icon_tokens.dart';
import '../../core/theme/radius_tokens.dart';
import '../../core/theme/spacing_tokens.dart';

enum FireflyButtonVariant {
  primary,
  secondary,
  tertiary,
  crisis,
  crisisOutlined,
  smallPrimary,
  smallSecondary,
}

/// Canonical button component for Firefly adhering strictly to Apple HIG interaction
/// dynamics, direct manipulation feedback, and trauma-informed low-stimulation styling.
///
/// Features:
/// - Exact tokenized dimensions & corner radii
/// - Direct manipulation scale feedback (0.97 scale on press, 120ms easeOut)
/// - Continuous opacity press feedback (0.88 opacity, 80ms)
/// - Integrated tactile haptic clicks on press-down
/// - Accessible touch target guarantees (>= 44x44dp hit area)
class FireflyButton extends StatefulWidget {
  const FireflyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = FireflyButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final FireflyButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  State<FireflyButton> createState() => _FireflyButtonState();
}

class _FireflyButtonState extends State<FireflyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: MotionTokens.buttonPressScale).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.enterCurve),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.enterCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;
    double height;
    double borderRadius;
    TextStyle textStyle;
    double iconSize;

    switch (widget.variant) {
      case FireflyButtonVariant.primary:
        height = SpacingTokens.buttonHeightPrimary;
        borderRadius = RadiusTokens.button;
        backgroundColor = isEnabled ? colors.actionSage : colors.surfaceSubtle;
        foregroundColor = isEnabled ? colors.textInverse : colors.textSecondary;
        textStyle = AppTypography.labelLg;
        iconSize = IconSizeTokens.appAction;
        break;

      case FireflyButtonVariant.secondary:
        height = SpacingTokens.buttonHeightSecondary;
        borderRadius = RadiusTokens.buttonSecondary;
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.textPrimary : colors.textSecondary;
        borderSide = BorderSide(
          color: isEnabled ? colors.borderOpaque : colors.borderSubtle,
          width: 1.5,
        );
        textStyle = AppTypography.labelLg;
        iconSize = IconSizeTokens.appAction;
        break;

      case FireflyButtonVariant.tertiary:
        height = SpacingTokens.buttonHeightTertiary;
        borderRadius = RadiusTokens.sm;
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.actionSage : colors.textSecondary;
        textStyle = AppTypography.labelMd;
        iconSize = IconSizeTokens.md;
        break;

      case FireflyButtonVariant.crisis:
        height = SpacingTokens.buttonHeightPrimary;
        borderRadius = RadiusTokens.button;
        backgroundColor = isEnabled ? colors.crisisAction : colors.surfaceSubtle;
        foregroundColor = Colors.white;
        textStyle = AppTypography.labelLg;
        iconSize = IconSizeTokens.appAction;
        break;

      case FireflyButtonVariant.crisisOutlined:
        height = SpacingTokens.buttonHeightSecondary;
        borderRadius = RadiusTokens.buttonSecondary;
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.crisisAction : colors.textSecondary;
        borderSide = BorderSide(
          color: isEnabled ? colors.crisisAction : colors.borderSubtle,
          width: 1.5,
        );
        textStyle = AppTypography.labelLg;
        iconSize = IconSizeTokens.appAction;
        break;

      case FireflyButtonVariant.smallPrimary:
        height = SpacingTokens.buttonHeightTertiary;
        borderRadius = RadiusTokens.sm;
        backgroundColor = isEnabled ? colors.actionSage : colors.surfaceSubtle;
        foregroundColor = isEnabled ? colors.textInverse : colors.textSecondary;
        textStyle = AppTypography.labelMd;
        iconSize = IconSizeTokens.md;
        break;

      case FireflyButtonVariant.smallSecondary:
        height = SpacingTokens.buttonHeightSmall;
        borderRadius = RadiusTokens.sm;
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.textSecondary : colors.textDisabled;
        borderSide = BorderSide(
          color: isEnabled ? colors.borderSubtle : colors.borderSubtle.withOpacity(0.5),
          width: 1.0,
        );
        textStyle = AppTypography.labelMd;
        iconSize = IconSizeTokens.sm;
        break;
    }

    final content = Center(
      child: widget.isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: iconSize, color: foregroundColor),
                  const SizedBox(width: SpacingTokens.spaceXs),
                ],
                Text(
                  widget.text,
                  style: textStyle.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );

    // Ensure minimum hit target of 44dp height for accessibility compliance
    final hitHeight = height < SpacingTokens.minTouchTarget ? SpacingTokens.minTouchTarget : height;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.text,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: hitHeight,
                minWidth: widget.isFullWidth ? double.infinity : SpacingTokens.minTouchTarget,
              ),
              child: SizedBox(
                width: widget.isFullWidth ? double.infinity : null,
                height: height,
                child: Material(
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: borderSide,
                  ),
                  child: InkWell(
                    onTap: isEnabled ? widget.onPressed : null,
                    borderRadius: BorderRadius.circular(borderRadius),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.spaceMd),
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
