import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/icon_tokens.dart';
import '../theme/radius_tokens.dart';
import '../theme/spacing_tokens.dart';

/// A calm, non-judgmental, non-blocking local safety banner.
/// Displayed when the deterministic [CrisisPhraseDetector] detects acute distress
/// or self-harm keywords in active text editors (PRD Section 6.2).
///
/// Invariants:
/// - Does NOT block or disable text input.
/// - Does NOT log or record detection events anywhere.
/// - Clearly dismissible with a single tap.
/// - Provides a direct, 1-tap route to the Stanley-Brown Safety Plan.
class LocalSafetyBanner extends StatelessWidget {
  const LocalSafetyBanner({
    super.key,
    required this.onDismiss,
    this.onOpenSafetyPlan,
  });

  /// Invoked when the user taps the dismiss ("Not now" / close) action.
  final VoidCallback onDismiss;

  /// Optional custom callback when "Open Safety Plan" is tapped.
  /// If null, defaults to pushing [AppRoutes.safetyPlan].
  final VoidCallback? onOpenSafetyPlan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      container: true,
      label: 'Safety resource notification: It sounds like things might be very hard right now. Your Safety Plan is here if you need it.',
      child: Container(
        margin: const EdgeInsets.only(bottom: SpacingTokens.spaceMd),
        padding: const EdgeInsets.all(SpacingTokens.spaceLg),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          border: Border.all(
            color: colors.crisisRed.withOpacity(0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.crisisRed.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.emergencyShield,
                    color: colors.crisisRed,
                    size: IconSizeTokens.appAction,
                  ),
                ),
                const SizedBox(width: SpacingTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gentle Support Available',
                        style: AppTypography.bodyMd.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'It sounds like things might be very hard right now. Your Safety Plan is here if you need it.',
                        style: AppTypography.bodySm.copyWith(
                          color: colors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                // Accessible dismiss icon
                Semantics(
                  button: true,
                  label: 'Dismiss safety banner',
                  child: IconButton(
                    icon: Icon(
                      AppIcons.close,
                      color: colors.textTertiary,
                      size: IconSizeTokens.md,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    tooltip: 'Not now',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onDismiss();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.spaceMd),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colors.crisisRed.withOpacity(0.10),
                        foregroundColor: colors.crisisRed,
                        side: BorderSide(color: colors.crisisRed.withOpacity(0.40)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusTokens.full),
                        ),
                      ),
                      icon: const Icon(AppIcons.emergencyShield, size: 18),
                      label: const Text(
                        'Open Safety Plan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        if (onOpenSafetyPlan != null) {
                          onOpenSafetyPlan!();
                        } else {
                          context.push(AppRoutes.safetyPlan);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.spaceMd),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textTertiary,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDismiss();
                  },
                  child: const Text('Not now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
