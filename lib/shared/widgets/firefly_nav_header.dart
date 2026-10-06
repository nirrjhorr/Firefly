import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/icon_tokens.dart';
import '../../core/theme/radius_tokens.dart';
import '../../core/theme/spacing_tokens.dart';

/// Standardized, Apple-inspired calm navigation header for Firefly screens.
///
/// Principles:
/// - Predictable spatial layout: 20dp horizontal margin, 44x44dp hit targets.
/// - Unhurried typography: clean heading hierarchy without visual clutter.
/// - Non-judgmental exit affordance with gentle haptics.
class FireflyNavHeader extends StatelessWidget {
  const FireflyNavHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showBack = true,
    this.backIcon = AppIcons.back,
    this.backTooltip = 'Back',
    this.trailing,
    this.leading,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SpacingTokens.screenPaddingH,
      vertical: SpacingTokens.spaceSm,
    ),
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBack;
  final IconData backIcon;
  final String backTooltip;
  final Widget? trailing;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  void _handleBack(BuildContext context) {
    HapticFeedback.selectionClick();
    if (onBack != null) {
      onBack!();
    } else if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null)
            leading!
          else if (showBack)
            Semantics(
              button: true,
              label: backTooltip,
              child: SizedBox(
                width: SpacingTokens.minTouchTarget,
                height: SpacingTokens.minTouchTarget,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(backIcon, size: IconSizeTokens.appAction),
                  color: colors.textSecondary,
                  tooltip: backTooltip,
                  onPressed: () => _handleBack(context),
                  splashRadius: 22,
                ),
              ),
            ),
          if (showBack || leading != null)
            const SizedBox(width: SpacingTokens.spaceXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headingMd.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: SpacingTokens.spaceSm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
