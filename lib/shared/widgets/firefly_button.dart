import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum FireflyButtonVariant {
  primary,
  secondary,
  crisis,
}

class FireflyButton extends StatefulWidget {
  const FireflyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = FireflyButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final FireflyButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  @override
  State<FireflyButton> createState() => _FireflyButtonState();
}

class _FireflyButtonState extends State<FireflyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    final double height =
        widget.variant == FireflyButtonVariant.primary ? 56.0 : 52.0;

    switch (widget.variant) {
      case FireflyButtonVariant.primary:
        backgroundColor = isEnabled ? colors.actionSage : colors.surfaceSubtle;
        foregroundColor =
            isEnabled ? colors.textInverse : colors.textSecondary;
        break;
      case FireflyButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? colors.textPrimary : colors.textSecondary;
        borderSide = BorderSide(
          color: isEnabled ? colors.borderOpaque : colors.borderSubtle,
          width: 1.5,
        );
        break;
      case FireflyButtonVariant.crisis:
        backgroundColor = isEnabled ? colors.crisisAction : colors.surfaceSubtle;
        foregroundColor = Colors.white;
        break;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Material(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: borderSide,
            ),
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(foregroundColor),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 20, color: foregroundColor),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTypography.labelLg.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
