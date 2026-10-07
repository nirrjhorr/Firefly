import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../data/services/feedback_storage_service.dart';
import '../../domain/models/activity_effectiveness_log.dart';
import '../providers/activity_providers.dart';

/// Interactive clinical post-activity feedback sheet.
/// Uses a non-gamified -2 to +2 settlement scale and optional somatic tags.
class EffectivenessFeedbackSheet extends ConsumerStatefulWidget {
  final String activityId;
  final String stateAtStart;
  final int durationSeconds;
  final VoidCallback? onDismissed;

  const EffectivenessFeedbackSheet({
    super.key,
    required this.activityId,
    required this.stateAtStart,
    required this.durationSeconds,
    this.onDismissed,
  });

  /// Displays the feedback bottom sheet smoothly and returns whether feedback was recorded.
  static Future<bool?> show(
    BuildContext context, {
    required String activityId,
    required String stateAtStart,
    required int durationSeconds,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EffectivenessFeedbackSheet(
        activityId: activityId,
        stateAtStart: stateAtStart,
        durationSeconds: durationSeconds,
      ),
    );
  }

  @override
  ConsumerState<EffectivenessFeedbackSheet> createState() =>
      _EffectivenessFeedbackSheetState();
}

class _EffectivenessFeedbackSheetState
    extends ConsumerState<EffectivenessFeedbackSheet> {
  int? _selectedRating; // -2 to +2
  final Set<String> _selectedTags = {};
  bool _isSaving = false;

  static const List<Map<String, dynamic>> _ratingOptions = [
    {'value': -2, 'label': 'Much\nworse', 'color': Color(0xFFC76A6A)},
    {'value': -1, 'label': 'A bit\nworse', 'color': Color(0xFFD4976A)},
    {'value': 0, 'label': 'About\nsame', 'color': Color(0xFF8E9BAE)},
    {'value': 1, 'label': 'A bit\nsettled', 'color': Color(0xFF7DBA9B)},
    {'value': 2, 'label': 'Much\nsettled', 'color': Color(0xFF5BA382)},
  ];

  static const List<String> _commonTags = [
    'Calmer body',
    'Quieter mind',
    'Breathing slowed',
    'Heart rate down',
    'Less overwhelmed',
    'Grounded',
    'Fell asleep',
    'Too long',
    'Distracted',
  ];

  Future<void> _handleSave() async {
    if (_selectedRating == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final log = ActivityEffectivenessLog(
        id: const Uuid().v4(),
        activityId: widget.activityId,
        stateAtStart: widget.stateAtStart,
        rating: _selectedRating!,
        timestamp: DateTime.now(),
        durationSeconds: widget.durationSeconds,
        tags: _selectedTags.toList(),
      );

      // Persist locally on device
      await ref.read(feedbackStorageServiceProvider).saveLog(log);
      await ref.read(activityRepositoryProvider).logEffectiveness(log);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  void _handleSkip() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCanvasDeep,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.xl),
        ),
        border: Border(
          top: BorderSide(color: colors.borderSubtle, width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(
        left: SpacingTokens.screenPaddingH,
        right: SpacingTokens.screenPaddingH,
        top: SpacingTokens.spaceMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpacingTokens.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle pill
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderSubtle,
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceMd),

          // Title & Prompt
          Text(
            'How are you feeling now?',
            key: const Key('effectiveness_sheet_title'),
            textAlign: TextAlign.center,
            style: AppTypography.displaySm.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceXs),
          Text(
            'Notice any shifts in your body or thoughts.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceLg),

          // 5-Point Settlement Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _ratingOptions.map((opt) {
              final val = opt['value'] as int;
              final label = opt['label'] as String;
              final optColor = opt['color'] as Color;
              final isSelected = _selectedRating == val;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    key: Key('rating_pill_$val'),
                    onTap: () {
                      setState(() {
                        _selectedRating = val;
                      });
                    },
                    child: AnimatedContainer(
                      duration: MotionTokens.micro,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? optColor.withOpacity(0.22)
                            : colors.bgSurface,
                        borderRadius: BorderRadius.circular(RadiusTokens.md),
                        border: Border.all(
                          color: isSelected ? optColor : colors.borderSubtle,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            val > 0 ? '+$val' : '$val',
                            style: AppTypography.labelMd.copyWith(
                              color: isSelected ? optColor : colors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: AppTypography.labelXs.copyWith(
                              color: isSelected
                                  ? colors.textPrimary
                                  : colors.textSecondary.withOpacity(0.8),
                              fontSize: 10,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SpacingTokens.spaceLg),

          // Optional Somatosensory Tag Chips
          Text(
            'What felt different? (optional)',
            style: AppTypography.labelSm.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: MotionTokens.micro,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.actionSage.withOpacity(0.2)
                        : colors.bgSurfaceElevated,
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    border: Border.all(
                      color: isSelected ? colors.actionSage : colors.borderSubtle,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.labelSm.copyWith(
                      color: isSelected ? colors.actionSage : colors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SpacingTokens.spaceLg),

          // Action Buttons
          FireflyButton(
            key: const Key('effectiveness_save_button'),
            text: _isSaving ? 'Recording...' : 'Record Feeling',
            onPressed: _selectedRating != null ? _handleSave : null,
            variant: FireflyButtonVariant.primary,
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          FireflyButton(
            key: const Key('effectiveness_skip_button'),
            text: 'Skip',
            onPressed: _handleSkip,
            variant: FireflyButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}
