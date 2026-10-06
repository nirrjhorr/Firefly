import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/sleep_sound_track.dart';
import '../controllers/sleep_suite_controller.dart';

/// Interactive soundscape selector with play controls and fading ambient timer.
class SleepTimerSelector extends ConsumerWidget {
  const SleepTimerSelector({super.key});

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
          // Multi-Track Ambient Mixer Launch Banner
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(AppRoutes.ambientMixer);
            },
            borderRadius: BorderRadius.circular(RadiusTokens.card),
            child: Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              margin: const EdgeInsets.only(bottom: SpacingTokens.md),
              decoration: BoxDecoration(
                color: const Color(0x18E5B870),
                borderRadius: BorderRadius.circular(RadiusTokens.card),
                border: Border.all(color: const Color(0x55E5B870)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0x33E5B870),
                      borderRadius: BorderRadius.circular(RadiusTokens.chip),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: warmAmber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multi-Track Ambient Mixer',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFFF2D9A8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Layer rain, hearth, brown noise & chimes together',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF9AAAB6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: warmAmber,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          // Active Track & Playback Controller
          Container(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              color: warmSurface,
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              border: Border.all(color: warmBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x22E5B870),
                        borderRadius: BorderRadius.circular(RadiusTokens.chip),
                      ),
                      child: const Icon(
                        Icons.graphic_eq_rounded,
                        color: warmAmber,
                        size: IconSizeTokens.standard,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedTrack.title,
                            style: AppTypography.headlineSmall.copyWith(
                              color: const Color(0xFFF2D9A8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.selectedTrack.subtitle,
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF9AAAB6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.lg),

                // Play / Pause Main Action (Touch target ≥ 56dp)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      notifier.togglePlayback();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warmAmber,
                      foregroundColor: const Color(0xFF0A0D0F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.button),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: IconSizeTokens.hero,
                    ),
                    label: Text(
                      state.isPlaying ? 'Pause Soundscape' : 'Play Soundscape',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A0D0F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),

                // Volume slider
                Row(
                  children: [
                    const Icon(Icons.volume_mute_rounded, color: Color(0xFF9AAAB6), size: 18),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: warmAmber,
                          inactiveTrackColor: const Color(0x33E5B870),
                          thumbColor: warmAmber,
                          overlayColor: const Color(0x22E5B870),
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        ),
                        child: Slider(
                          value: state.baseVolume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (val) => notifier.setVolume(val),
                        ),
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, color: Color(0xFF9AAAB6), size: 18),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),

          // Sleep Timer Options
          Text(
            'Fading Sleep Timer',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: warmAmber,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Volume fades logarithmically over the final 5 minutes so waking transitions do not occur.',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF9AAAB6),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),

          // Timer duration chips (15, 30, 45, 60 min, Off)
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              _TimerChip(
                label: '15 min',
                isSelected: state.timerMinutes == 15,
                onTap: () => notifier.setTimer(15),
              ),
              _TimerChip(
                label: '30 min',
                isSelected: state.timerMinutes == 30,
                onTap: () => notifier.setTimer(30),
              ),
              _TimerChip(
                label: '45 min',
                isSelected: state.timerMinutes == 45,
                onTap: () => notifier.setTimer(45),
              ),
              _TimerChip(
                label: '60 min',
                isSelected: state.timerMinutes == 60,
                onTap: () => notifier.setTimer(60),
              ),
              _TimerChip(
                label: 'Off',
                isSelected: state.timerMinutes == null,
                onTap: () => notifier.setTimer(null),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),

          // Active Countdown Indicator
          if (state.timerSecondsRemaining != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0x22E5B870),
                borderRadius: BorderRadius.circular(RadiusTokens.chip),
                border: Border.all(color: const Color(0x44E5B870)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: warmAmber, size: 18),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    'Time remaining: ${state.formattedTimeRemaining}',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFFF2D9A8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if ((state.timerSecondsRemaining ?? 0) <= 300)
                    Text(
                      'Fading gently',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF84B09A),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
          ] else
            const SizedBox(height: SpacingTokens.lg),

          // Soundscape Track Catalog
          Text(
            'Ambient Library',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: warmAmber,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kCuratedSleepTracks.length,
            separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.xs),
            itemBuilder: (context, index) {
              final track = kCuratedSleepTracks[index];
              final isSelected = track.id == state.selectedTrack.id;

              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.selectTrack(track);
                },
                borderRadius: BorderRadius.circular(RadiusTokens.card),
                child: Container(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E252B) : const Color(0xFF111518),
                    borderRadius: BorderRadius.circular(RadiusTokens.card),
                    border: Border.all(
                      color: isSelected ? warmAmber : const Color(0x22E5B870),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? warmAmber : const Color(0xFF6B7E8C),
                        size: 20,
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: AppTypography.bodySmall.copyWith(
                                color: isSelected ? const Color(0xFFF2D9A8) : const Color(0xFFE8ECF0),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            Text(
                              track.subtitle,
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF9AAAB6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimerChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const warmAmber = Color(0xFFE5B870);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(RadiusTokens.chip),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: isSelected ? warmAmber : const Color(0xFF14191D),
          borderRadius: BorderRadius.circular(RadiusTokens.chip),
          border: Border.all(
            color: isSelected ? warmAmber : const Color(0x33E5B870),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF0A0D0F) : const Color(0xFFC4CDD4),
          ),
        ),
      ),
    );
  }
}
