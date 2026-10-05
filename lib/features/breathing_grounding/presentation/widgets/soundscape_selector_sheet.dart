import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../soundscapes/data/repositories/soundscape_repository.dart';
import '../controllers/breathing_session_controller.dart';

/// Soundscape option metadata.
class SoundscapeItem {
  final String? id;
  final String title;
  final String description;
  final IconData icon;

  const SoundscapeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<SoundscapeItem> availableSoundscapes = [
  SoundscapeItem(
    id: RespirationSoundscapes.cyclicSighAmbience,
    title: 'Cyclic Ambience',
    description: 'Calming wind drone tuned for physiological sighing',
    icon: AppIcons.breathe,
  ),
  SoundscapeItem(
    id: RespirationSoundscapes.gentleRain,
    title: 'Gentle Rain',
    description: 'Steady, soft rain drops for acoustic grounding',
    icon: AppIcons.waterDrop,
  ),
  SoundscapeItem(
    id: RespirationSoundscapes.groundingChime,
    title: 'Grounding Chimes',
    description: 'Resonant Tibetan singing bowl for sensory anchoring',
    icon: AppIcons.singingBowl,
  ),
  SoundscapeItem(
    id: 'assets/audio/ocean_waves.mp3',
    title: 'Ocean Waves',
    description: 'Tidal pacing for respiratory sinus arrhythmia',
    icon: AppIcons.soundWaves,
  ),
  SoundscapeItem(
    id: 'assets/audio/calm_brown_noise.mp3',
    title: 'Deep Brown Noise',
    description: 'Low-frequency acoustic curtain for overstimulation',
    icon: AppIcons.audioFrequency,
  ),
  SoundscapeItem(
    id: null,
    title: 'Mute / Silence',
    description: 'Complete quiet with only tactile haptic pacing',
    icon: AppIcons.volumeMute,
  ),
];

/// Bottom sheet modal allowing users to select an offline soundscape.
class SoundscapeSelectorSheet extends ConsumerWidget {
  final String? currentSoundscape;
  final ValueChanged<String?> onSelect;

  const SoundscapeSelectorSheet({
    super.key,
    required this.currentSoundscape,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required String? currentSoundscape,
    required ValueChanged<String?> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.sheet)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollCtrl) => SoundscapeSelectorSheet(
          currentSoundscape: currentSoundscape,
          onSelect: onSelect,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.screenPaddingH,
          vertical: SpacingTokens.spaceMd,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderSubtle,
                  borderRadius: BorderRadius.circular(RadiusTokens.xs),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.audioFrequency, color: colors.actionSage, size: IconSizeTokens.standard),
                    const SizedBox(width: SpacingTokens.spaceSm),
                    Text(
                      'Ambient Soundscapes',
                      style: AppTypography.headingMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(AppIcons.soundWaves, size: IconSizeTokens.sm),
                  label: const Text('Full Library'),
                  style: TextButton.styleFrom(foregroundColor: colors.actionSage),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.soundscapes);
                  },
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.space2xs),
            Text(
              '100% offline evidence-informed acoustic loops for nervous system regulation.',
              style: AppTypography.bodySm.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),

            // Respiration Preset Options
            ...availableSoundscapes.map((item) {
              final isSelected = currentSoundscape == item.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.spaceSm),
                child: InkWell(
                  key: Key('soundscape_option_${item.id ?? "mute"}'),
                  onTap: () {
                    onSelect(item.id);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(RadiusTokens.card),
                  child: Container(
                    padding: const EdgeInsets.all(SpacingTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.actionSage.withOpacity(0.12)
                          : colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(RadiusTokens.card),
                      border: Border.all(
                        color: isSelected
                            ? colors.actionSage.withOpacity(0.4)
                            : colors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? colors.actionSage
                              : colors.textSecondary,
                          size: IconSizeTokens.nav,
                        ),
                        const SizedBox(width: SpacingTokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTypography.labelLg.copyWith(
                                  color: isSelected
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: AppTypography.bodySm.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            AppIcons.checkCircleFilled,
                            color: colors.actionSage,
                            size: IconSizeTokens.appAction,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
