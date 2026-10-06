import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/ambient_mixer_channel.dart';

/// Interactive tactile card for controlling an individual audio channel.
class AmbientChannelCard extends StatelessWidget {
  final AmbientMixerChannel channel;
  final double masterVolume;
  final double fadeFactor;
  final bool isPlaying;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleMute;

  const AmbientChannelCard({
    super.key,
    required this.channel,
    required this.masterVolume,
    this.fadeFactor = 1.0,
    required this.isPlaying,
    required this.onToggle,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  IconData _resolveIcon(String iconKey) {
    switch (iconKey) {
      case 'cloud.rain':
        return Icons.water_drop_rounded;
      case 'waveform':
        return Icons.graphic_eq_rounded;
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'moon.stars':
        return Icons.nightlight_round;
      case 'water.waves':
        return Icons.waves_rounded;
      case 'bell':
        return Icons.notifications_none_rounded;
      default:
        return Icons.music_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const warmAmber = Color(0xFFE5B870);
    const warmActiveBg = Color(0xFF1E252B);
    const warmInactiveBg = Color(0xFF111518);
    const warmBorderActive = Color(0x66E5B870);
    const warmBorderInactive = Color(0x22E5B870);

    final isAudible = channel.isEnabled && !channel.isMuted && isPlaying;
    final effectivePercentage = (channel.computedVolume(masterVolume, fadeFactor: fadeFactor) * 100).round();

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: channel.isEnabled ? warmActiveBg : warmInactiveBg,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(
          color: channel.isEnabled ? warmBorderActive : warmBorderInactive,
          width: channel.isEnabled ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Channel Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: channel.isEnabled ? const Color(0x33E5B870) : const Color(0x11E5B870),
                  borderRadius: BorderRadius.circular(RadiusTokens.chip),
                ),
                child: Icon(
                  _resolveIcon(channel.iconKey),
                  color: channel.isEnabled ? warmAmber : const Color(0xFF6B7E8C),
                  size: IconSizeTokens.standard,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          channel.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: channel.isEnabled ? const Color(0xFFF2D9A8) : const Color(0xFFC4CDD4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isAudible) ...[
                          const SizedBox(width: SpacingTokens.xs),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF84B09A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      channel.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF9AAAB6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Enable / Disable Toggle Switch (Touch Target ≥ 48dp)
              Switch.adaptive(
                value: channel.isEnabled,
                activeColor: warmAmber,
                activeTrackColor: const Color(0x66E5B870),
                inactiveThumbColor: const Color(0xFF6B7E8C),
                inactiveTrackColor: const Color(0xFF20262B),
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  onToggle(val);
                },
              ),
            ],
          ),

          // Volume Slider & Mute Control (Only shown when channel is enabled)
          if (channel.isEnabled) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              children: [
                // Mute / Unmute Button
                IconButton(
                  tooltip: channel.isMuted ? 'Unmute' : 'Mute',
                  icon: Icon(
                    channel.isMuted ? Icons.volume_off_rounded : Icons.volume_down_rounded,
                    color: channel.isMuted ? const Color(0xFFB05454) : warmAmber,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onToggleMute();
                  },
                ),

                // Channel Volume Slider
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: channel.isMuted ? const Color(0xFF4A5560) : warmAmber,
                      inactiveTrackColor: const Color(0x33E5B870),
                      thumbColor: channel.isMuted ? const Color(0xFF6B7E8C) : warmAmber,
                      overlayColor: const Color(0x22E5B870),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: channel.volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: channel.isMuted ? null : onVolumeChanged,
                    ),
                  ),
                ),

                // Effective Volume Readout
                SizedBox(
                  width: 44,
                  child: Text(
                    channel.isMuted ? 'Muted' : '$effectivePercentage%',
                    textAlign: TextAlign.end,
                    style: AppTypography.caption.copyWith(
                      color: channel.isMuted ? const Color(0xFFB05454) : const Color(0xFFF2D9A8),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
