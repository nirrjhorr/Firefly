import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/ambient_mixer_preset.dart';
import '../controllers/ambient_audio_mixer_controller.dart';
import '../widgets/ambient_channel_card.dart';
import '../widgets/ambient_preset_selector.dart';

/// Pre-bed multi-track ambient audio mixer and sleep wind-down sanctuary.
/// Implements ultra-low luminance `#0A0D0F` canvas, independent channel controls,
/// restful presets, and logarithmic timer attenuation.
class AmbientAudioMixerScreen extends ConsumerStatefulWidget {
  final bool showSosOverlay;

  const AmbientAudioMixerScreen({
    super.key,
    this.showSosOverlay = true,
  });

  @override
  ConsumerState<AmbientAudioMixerScreen> createState() =>
      _AmbientAudioMixerScreenState();
}

class _AmbientAudioMixerScreenState
    extends ConsumerState<AmbientAudioMixerScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (elapsedSec >= 45) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_audio_sound_mixer',
        stateAtStart: 'cantSleep',
        durationSeconds: elapsedSec > 0 ? elapsedSec : 60,
      );
    }

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ambientAudioMixerProvider);
    final notifier = ref.read(ambientAudioMixerProvider.notifier);

    const sanctuaryCanvas = Color(0xFF0A0D0F);
    const warmAmber = Color(0xFFE5B870);
    const warmSurface = Color(0xFF14191D);
    const warmBorder = Color(0x33E5B870);

    return Scaffold(
      backgroundColor: sanctuaryCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFC4CDD4)),
          tooltip: 'Return to Home',
          onPressed: _handleExit,
        ),
        title: Text(
          'Ambient Sound Sanctuary',
          style: AppTypography.headlineSmall.copyWith(
            color: const Color(0xFFF2D9A8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Calming Subtitle Guidance
                  Text(
                    'Layer soothing textures to mask distractions and calm autonomic arousal.',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF9AAAB6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),

                  // Restorative Presets Selector
                  AmbientPresetSelector(
                    presets: kCuratedMixerPresets,
                    activePresetId: state.activePresetId,
                    onPresetSelected: (preset) => notifier.applyPreset(preset),
                  ),
                  const SizedBox(height: SpacingTokens.xl),

                  // Master Playback Controller Card
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    decoration: BoxDecoration(
                      color: warmSurface,
                      borderRadius: BorderRadius.circular(RadiusTokens.card),
                      border: Border.all(color: warmBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SpacingTokens.sm,
                                vertical: SpacingTokens.xs,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x22E5B870),
                                borderRadius: BorderRadius.circular(RadiusTokens.chip),
                              ),
                              child: Text(
                                '${state.activeChannelCount} active ${state.activeChannelCount == 1 ? 'layer' : 'layers'}',
                                style: AppTypography.caption.copyWith(
                                  color: warmAmber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (state.timerSecondsRemaining != null)
                              Text(
                                'Timer: ${state.formattedTimeRemaining}',
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF84B09A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: SpacingTokens.md),

                        // Play / Pause Main Action (Touch target ≥ 56dp)
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              notifier.togglePlayPause();
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
                              state.isPlaying ? 'Pause Sanctuary' : 'Play Sanctuary',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0A0D0F),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.md),

                        // Master Volume Slider
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
                                  value: state.masterVolume,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (val) => notifier.setMasterVolume(val),
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

                  // Fading Sleep Timer Section
                  Text(
                    'Fading Sleep Timer',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: warmAmber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Volume curves logarithmically to zero across the final 5 minutes so waking transitions do not occur.',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF9AAAB6),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),

                  // Timer Chips
                  Wrap(
                    spacing: SpacingTokens.sm,
                    runSpacing: SpacingTokens.sm,
                    children: [
                      _TimerChip(
                        label: '15 min',
                        isSelected: state.timerMinutes == 15,
                        onTap: () => notifier.setSleepTimer(15),
                      ),
                      _TimerChip(
                        label: '30 min',
                        isSelected: state.timerMinutes == 30,
                        onTap: () => notifier.setSleepTimer(30),
                      ),
                      _TimerChip(
                        label: '45 min',
                        isSelected: state.timerMinutes == 45,
                        onTap: () => notifier.setSleepTimer(45),
                      ),
                      _TimerChip(
                        label: '60 min',
                        isSelected: state.timerMinutes == 60,
                        onTap: () => notifier.setSleepTimer(60),
                      ),
                      _TimerChip(
                        label: 'Off',
                        isSelected: state.timerMinutes == null,
                        onTap: () => notifier.setSleepTimer(null),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xl),

                  // Multi-Channel Layers Rack
                  Text(
                    'Sound Layers',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: warmAmber,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.channels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.sm),
                    itemBuilder: (context, index) {
                      final ch = state.channels[index];
                      return AmbientChannelCard(
                        channel: ch,
                        masterVolume: state.masterVolume,
                        fadeFactor: state.effectiveFadeFactor,
                        isPlaying: state.isPlaying,
                        onToggle: (_) => notifier.toggleChannel(ch.id),
                        onVolumeChanged: (vol) => notifier.setChannelVolume(ch.id, vol),
                        onToggleMute: () => notifier.toggleChannelMute(ch.id),
                      );
                    },
                  ),
                  const SizedBox(height: SpacingTokens.xxl),

                  // Non-judgmental exit button (Touch target ≥ 56dp)
                  Center(
                    child: OutlinedButton(
                      onPressed: _handleExit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC4CDD4),
                        side: const BorderSide(color: Color(0x44E5B870)),
                        minimumSize: const Size(200, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusTokens.button),
                        ),
                      ),
                      child: Text(
                        "That's enough for now",
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFFC4CDD4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xxl),
                ],
              ),
            ),

            // Persistent SOS Shield overlay if enabled
            if (widget.showSosOverlay)
              const Positioned(
                bottom: 24,
                right: 24,
                child: SosOverlayButton(),
              ),
          ],
        ),
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
