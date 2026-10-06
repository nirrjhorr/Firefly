import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../controllers/sleep_suite_controller.dart';

/// Guilt-free consistent wake-time circadian anchor card.
class WakeTimeCompanionCard extends ConsumerWidget {
  const WakeTimeCompanionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sleepSuiteProvider);
    final notifier = ref.read(sleepSuiteProvider.notifier);

    const warmAmber = Color(0xFFE5B870);
    const warmSurface = Color(0xFF14191D);
    const warmBorder = Color(0x33E5B870);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Circadian Anchor Intro
          Container(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              color: warmSurface,
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(color: warmBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.wb_twilight_rounded,
                      color: warmAmber,
                      size: IconSizeTokens.standard,
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Text(
                      'Circadian Wake Anchor',
                      style: AppTypography.headlineSmall.copyWith(
                        color: const Color(0xFFF2D9A8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Sleep science shows that waking at the same time each morning — even after a restless night — is the strongest signal for building nighttime sleep drive. No blaring alarms or guilt; just a steady, peaceful cue.',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFFC4CDD4),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),

          // Target Display Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xl, horizontal: SpacingTokens.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1316),
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(color: warmBorder),
            ),
            child: Column(
              children: [
                Text(
                  'Your Morning Anchor',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF9AAAB6),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  state.formattedWakeTarget,
                  style: AppTypography.displayLarge.copyWith(
                    color: warmAmber,
                    fontWeight: FontWeight.w700,
                    fontSize: 44,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  state.isWakeTargetSet
                      ? '✓ Anchor active for tomorrow morning'
                      : 'Tap below to adjust your regular wake time',
                  style: AppTypography.caption.copyWith(
                    color: state.isWakeTargetSet ? const Color(0xFF84B09A) : const Color(0xFF9AAAB6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),

          // Adjust Time Button (Touch target ≥ 56dp)
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: state.wakeTargetHour,
                    minute: state.wakeTargetMinute,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: warmAmber,
                          surface: Color(0xFF14191D),
                          onSurface: Color(0xFFF2D9A8),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  notifier.setWakeTarget(picked.hour, picked.minute);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: warmAmber,
                foregroundColor: const Color(0xFF0A0D0F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.button),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.access_time_rounded, size: IconSizeTokens.appAction),
              label: Text(
                'Set Wake Target',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0D0F),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),

          // Non-punitive Reassurance
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: const Color(0x11E5B870),
              borderRadius: BorderRadius.circular(RadiusTokens.card),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_outline_rounded, color: warmAmber, size: 20),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Text(
                    'If you sleep past this target, that is completely okay. Rest is restorative, not a competition.',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF9AAAB6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
