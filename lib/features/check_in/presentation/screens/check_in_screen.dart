import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/energy_slider.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../../../shared/widgets/mood_tile.dart';
import '../controllers/check_in_controller.dart';
import '../widgets/affect_result_card.dart';

class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkInControllerProvider);
    final controller = ref.read(checkInControllerProvider.notifier);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: state.activeSuggestion != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Here is your next step',
                      style: AppTypography.displayMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on how you are feeling right now.',
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AffectResultCard(
                      suggestion: state.activeSuggestion!,
                      onCheckInAgain: () => controller.resetForNewCheckIn(),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you right now?',
                      style: AppTypography.displayMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take a quiet moment to notice what is present.',
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 1. Mood Anchor (5 Moon Phase Tiles)
                    Text(
                      'Mood Anchor',
                      style: AppTypography.headingMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: MoodCategory.values.map((mood) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: MoodTile(
                              mood: mood,
                              isSelected: state.selectedMood == mood,
                              onTap: () => controller.setMood(mood),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 2. Energy Slider ("Still -> Moving")
                    FireflyCard(
                      padding: const EdgeInsets.all(16),
                      child: EnergySlider(
                        value: state.energyLevel,
                        onChanged: (val) => controller.setEnergy(val),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Anxiety Level (5-dot selector)
                    FireflyCard(
                      padding: const EdgeInsets.all(16),
                      child: _buildDotLevelSelector(
                        context,
                        title: 'Anxiety or Internal Tension',
                        description: 'Quiet → Racing or tense',
                        currentValue: state.anxietyLevel,
                        onChanged: (val) => controller.setAnxiety(val),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Loneliness Level (5-dot selector)
                    FireflyCard(
                      padding: const EdgeInsets.all(16),
                      child: _buildDotLevelSelector(
                        context,
                        title: 'Loneliness',
                        description: 'Connected / Content → Isolated',
                        currentValue: state.lonelinessLevel,
                        onChanged: (val) => controller.setLoneliness(val),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 5. Submit CTA
                    FireflyButton(
                      text: "I'm here",
                      isLoading: state.isSubmitting,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        controller.submitCheckIn();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDotLevelSelector(
    BuildContext context, {
    required String title,
    required String description,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.headingMd.copyWith(
                color: colors.textPrimary,
              ),
            ),
            Text(
              _levelDescriptor(currentValue),
              style: AppTypography.bodySm.copyWith(
                color: colors.actionSage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: AppTypography.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = level == currentValue;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(level);
              },
              child: Semantics(
                label: '$title level $level',
                selected: isSelected,
                button: true,
                child: Container(
                  width: 52,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.actionSage.withOpacity(0.18)
                        : colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.actionSage : colors.borderSubtle,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Container(
                    width: 10 + (level * 2.5),
                    height: 10 + (level * 2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? colors.actionSage : colors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _levelDescriptor(int val) {
    switch (val) {
      case 1:
        return 'Quiet';
      case 2:
        return 'Mild';
      case 3:
        return 'Noticeable';
      case 4:
        return 'Strong';
      case 5:
        return 'Intense';
      default:
        return 'Moderate';
    }
  }
}
