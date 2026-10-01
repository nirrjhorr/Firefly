import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing_tokens.dart';
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
    description: 'Calming synthesizer drone tuned for nervous system regulation',
    icon: Icons.waves,
  ),
  SoundscapeItem(
    id: RespirationSoundscapes.gentleRain,
    title: 'Gentle Rain',
    description: 'Steady, soft rain drops for acoustic grounding',
    icon: Icons.water_drop_outlined,
  ),
  SoundscapeItem(
    id: RespirationSoundscapes.groundingChime,
    title: 'Grounding Chimes',
    description: 'Warm resonant acoustic chimes marking gentle transitions',
    icon: Icons.notifications_none,
  ),
  SoundscapeItem(
    id: null,
    title: 'Mute / Silence',
    description: 'Complete quiet with only tactile haptic pacing',
    icon: Icons.volume_off_outlined,
  ),
];

/// Bottom sheet modal allowing users to select an offline soundscape.
class SoundscapeSelectorSheet extends StatelessWidget {
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
      backgroundColor: context.colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SoundscapeSelectorSheet(
        currentSoundscape: currentSoundscape,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.spaceLg,
          vertical: SpacingTokens.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),

            // Header
            Row(
              children: [
                Icon(Icons.graphic_eq, color: colors.actionSage, size: 24),
                const SizedBox(width: SpacingTokens.spaceSm),
                Text(
                  'Ambient Soundscape',
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.space2xs),
            Text(
              'Offline audio loops to soothe sensory overload without distraction.',
              style: AppTypography.bodySm.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceLg),

            // List of Soundscapes
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
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(SpacingTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.actionSage.withOpacity(0.12)
                          : colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(16),
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
                          size: 22,
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
                            Icons.check_circle,
                            color: colors.actionSage,
                            size: 20,
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
