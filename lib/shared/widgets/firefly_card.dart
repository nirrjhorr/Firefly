import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FireflyCard extends StatelessWidget {
  const FireflyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? colors.borderSubtle,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.transparent,
          highlightColor: colors.actionSage.withOpacity(0.05),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
