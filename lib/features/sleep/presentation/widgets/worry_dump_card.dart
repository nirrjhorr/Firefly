import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../controllers/sleep_suite_controller.dart';

/// Card providing pre-bed worry offloading with dual disposition:
/// - "Park until morning" (locked until 8:00 AM)
/// - "Let it dissolve" (immediate serene dissolve animation & crypto memory wipe)
class WorryDumpCard extends ConsumerStatefulWidget {
  const WorryDumpCard({super.key});

  @override
  ConsumerState<WorryDumpCard> createState() => _WorryDumpCardState();
}

class _WorryDumpCardState extends ConsumerState<WorryDumpCard> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: ref.read(sleepSuiteProvider).worryText,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepSuiteProvider);
    final notifier = ref.read(sleepSuiteProvider.notifier);

    // Synchronize controller if cleared from state (e.g. after parking or dissolving)
    if (state.worryText.isEmpty && _textController.text.isNotEmpty && !state.isDissolving) {
      _textController.clear();
    }

    final hasText = state.worryText.trim().isNotEmpty;

    // Sub-3000K warm palette tokens for low circadian disruption
    const warmAmber = Color(0xFFE5B870);
    const warmSurface = Color(0xFF14191D);
    const warmBorder = Color(0x33E5B870);
    const warmHint = Color(0x99C4CDD4);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sanctuary Intro Banner
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: warmSurface,
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(color: warmBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.nightlight_round,
                  color: warmAmber,
                  size: IconSizeTokens.standard,
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Text(
                    'Put intrusive thoughts here so your mind can let them rest. Choose to hold them until daylight or let them dissolve completely.',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFFE8ECF0),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Thought Input Area with Dissolve Animation Support
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: state.isDissolving ? (1.0 - state.dissolveProgress).clamp(0.0, 1.0) : 1.0,
            child: Transform.scale(
              scale: state.isDissolving ? (1.0 - (state.dissolveProgress * 0.1)) : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: warmSurface,
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  border: Border.all(
                    color: hasText ? warmAmber : warmBorder,
                    width: hasText ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: TextField(
                  controller: _textController,
                  enabled: !state.isDissolving,
                  maxLines: 6,
                  minLines: 4,
                  cursorColor: warmAmber,
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFFF2D9A8), // Warm incandescent color
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'What is looping in your thoughts tonight? Write it down without judgment...',
                    hintStyle: TextStyle(
                      color: warmHint,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onChanged: (val) => notifier.updateWorryText(val),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Dual Action Buttons (Touch target ≥ 56dp)
          Row(
            children: [
              // 1. "Park until morning"
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: hasText && !state.isDissolving
                        ? () async {
                            HapticFeedback.lightImpact();
                            await notifier.parkUntilMorning();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warmAmber,
                      foregroundColor: const Color(0xFF0A0D0F),
                      disabledBackgroundColor: const Color(0x33E5B870),
                      disabledForegroundColor: const Color(0x550A0D0F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.button),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.lock_clock_outlined, size: IconSizeTokens.appAction),
                    label: Text(
                      'Park until 8 AM',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasText ? const Color(0xFF0A0D0F) : const Color(0x550A0D0F),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),

              // 2. "Let it dissolve"
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: hasText && !state.isDissolving
                        ? () async {
                            HapticFeedback.mediumImpact();
                            await notifier.letItDissolve();
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: warmAmber,
                      disabledForegroundColor: const Color(0x33E5B870),
                      side: BorderSide(
                        color: hasText ? warmAmber : const Color(0x33E5B870),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.button),
                      ),
                    ),
                    icon: const Icon(Icons.blur_on_rounded, size: IconSizeTokens.appAction),
                    label: Text(
                      'Let it dissolve',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasText ? warmAmber : const Color(0x33E5B870),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xl),

          // Status reassurance message
          if (state.statusMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0x2284B09A), // subtle sage
                borderRadius: BorderRadius.circular(RadiusTokens.chip),
                border: Border.all(color: const Color(0x4484B09A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF84B09A), size: 18),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      state.statusMessage!,
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFFDFF0E6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
          ],

          // Parked Worries Section (Locked Vault)
          if (state.parkedEntries.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: warmAmber, size: IconSizeTokens.sm),
                const SizedBox(width: SpacingTokens.xs),
                Text(
                  'Parked for Daylight (${state.parkedEntries.length})',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: warmAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.parkedEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.xs),
              itemBuilder: (context, index) {
                final entry = state.parkedEntries[index];
                return Container(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1316),
                    borderRadius: BorderRadius.circular(RadiusTokens.card),
                    border: Border.all(color: const Color(0x22E5B870)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: warmAmber,
                        size: IconSizeTokens.standard,
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.lockStatusDescription,
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFFE8ECF0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Content encrypted. Sealed until morning to protect your rest.',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF9AAAB6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF6B7E8C), size: 18),
                        onPressed: () {
                          notifier.deleteParkedEntry(entry.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
