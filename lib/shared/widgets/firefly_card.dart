import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/animation_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/radius_tokens.dart';
import '../../core/theme/spacing_tokens.dart';

enum FireflyCardVariant {
  flat,
  raised,
  interactive,
  crisis,
}

/// Canonical surface container for Firefly.
/// Implements Apple's principles of physical depth, visual restraint, and responsive direct manipulation.
class FireflyCard extends StatefulWidget {
  const FireflyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SpacingTokens.cardPadding),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = RadiusTokens.lg,
    this.variant = FireflyCardVariant.flat,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final FireflyCardVariant variant;
  final VoidCallback? onTap;

  @override
  State<FireflyCard> createState() => _FireflyCardState();
}

class _FireflyCardState extends State<FireflyCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: MotionTokens.cardPressScale).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.enterCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _controller.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color resolvedBg;
    Color resolvedBorder;

    switch (widget.variant) {
      case FireflyCardVariant.flat:
        resolvedBg = widget.backgroundColor ?? colors.surfaceCard;
        resolvedBorder = widget.borderColor ?? colors.borderSubtle;
        break;
      case FireflyCardVariant.raised:
        resolvedBg = widget.backgroundColor ?? colors.surfaceSubtle;
        resolvedBorder = widget.borderColor ?? colors.borderSubtle;
        break;
      case FireflyCardVariant.interactive:
        resolvedBg = widget.backgroundColor ?? colors.surfaceCard;
        resolvedBorder = widget.borderColor ?? colors.borderSubtle;
        break;
      case FireflyCardVariant.crisis:
        resolvedBg = widget.backgroundColor ?? colors.crisisCoralSurface;
        resolvedBorder = widget.borderColor ?? colors.crisisCoral.withOpacity(0.35);
        break;
    }

    final isInteractive = widget.onTap != null;

    final cardContent = Container(
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: resolvedBorder,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: Colors.transparent,
          highlightColor: isInteractive
              ? colors.actionSage.withOpacity(0.04)
              : Colors.transparent,
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (!isInteractive) {
      return cardContent;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: cardContent,
      ),
    );
  }
}
