import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/icon_tokens.dart';
import '../../core/theme/radius_tokens.dart';
import '../../core/theme/spacing_tokens.dart';
import 'firefly_button.dart';

/// Trauma-informed, calm empty state component for Firefly.
///
/// Features:
/// - Gentle floating icon halo without stark visual warnings
/// - Warm, pressure-free copy that validates presence over productivity
/// - Optional secondary action to start an activity softly
class FireflyEmptyState extends StatelessWidget {
  const FireflyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    String? description,
    String? message,
    String? actionText,
    String? actionLabel,
    this.onAction,
    this.actionIcon,
  })  : description = description ?? message ?? '',
        actionText = actionText ?? actionLabel;

  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.spaceXl,
          vertical: SpacingTokens.space2xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Soft illuminated halo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.actionSage.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.actionSage.withOpacity(0.25),
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                size: IconSizeTokens.lg,
                color: colors.actionSage,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceLg),
            Text(
              title,
              style: AppTypography.headingMd.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.spaceXs),
            Text(
              description,
              style: AppTypography.bodyMd.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.spaceXl),
              FireflyButton(
                text: actionText!,
                onPressed: onAction,
                variant: FireflyButtonVariant.secondary,
                icon: actionIcon,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
