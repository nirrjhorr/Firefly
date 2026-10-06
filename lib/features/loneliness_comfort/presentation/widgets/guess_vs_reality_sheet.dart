import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../domain/models/social_prediction_experiment.dart';

enum GuessMode {
  prediction,
  outcome,
}

/// Interactive sheet for logging predictions ("Guess") before sending SMS,
/// or logging actual outcomes ("Reality") upon returning to the app.
class GuessVsRealitySheet extends StatefulWidget {
  const GuessVsRealitySheet({
    super.key,
    required this.mode,
    required this.contactName,
    this.initialSelection = SocialOutcome.neutral,
    required this.onConfirmed,
    this.onSkip,
  });

  final GuessMode mode;
  final String contactName;
  final SocialOutcome initialSelection;
  final void Function(SocialOutcome outcome) onConfirmed;
  final VoidCallback? onSkip;

  static Future<void> showPrediction({
    required BuildContext context,
    required String contactName,
    required void Function(SocialOutcome outcome) onConfirmed,
    VoidCallback? onSkip,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GuessVsRealitySheet(
        mode: GuessMode.prediction,
        contactName: contactName,
        onConfirmed: onConfirmed,
        onSkip: onSkip,
      ),
    );
  }

  static Future<void> showOutcome({
    required BuildContext context,
    required String contactName,
    required void Function(SocialOutcome outcome) onConfirmed,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GuessVsRealitySheet(
        mode: GuessMode.outcome,
        contactName: contactName,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<GuessVsRealitySheet> createState() => _GuessVsRealitySheetState();
}

class _GuessVsRealitySheetState extends State<GuessVsRealitySheet> {
  late SocialOutcome _selectedOutcome;

  @override
  void initState() {
    super.initState();
    _selectedOutcome = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPrediction = widget.mode == GuessMode.prediction;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCanvasDeep,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isPrediction ? colors.accentAmber : colors.actionSage).withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPrediction ? AppIcons.notes : AppIcons.check,
                  color: isPrediction ? colors.accentAmber : colors.actionSage,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPrediction ? 'Guess vs. Reality Experiment' : 'What actually happened?',
                      style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPrediction
                          ? 'How do you predict ${widget.contactName} will respond?'
                          : 'With ${widget.contactName}:',
                      style: AppTypography.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Outcome choices
          for (final outcome in SocialOutcome.values) ...[
            InkWell(
              onTap: () {
                setState(() => _selectedOutcome = outcome);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedOutcome == outcome
                      ? (isPrediction ? colors.accentAmber.withOpacity(0.12) : colors.actionSage.withOpacity(0.12))
                      : colors.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedOutcome == outcome
                        ? (isPrediction ? colors.accentAmber : colors.actionSage)
                        : colors.borderSubtle,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedOutcome == outcome
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _selectedOutcome == outcome
                          ? (isPrediction ? colors.accentAmber : colors.actionSage)
                          : colors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        outcome.label,
                        style: AppTypography.bodyMd.copyWith(
                          color: colors.textPrimary,
                          fontWeight: _selectedOutcome == outcome ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (isPrediction) ...[
            const SizedBox(height: 6),
            Text(
              'Kumar & Epley (2023) showed that people consistently underestimate how warm and appreciative others feel when reached out to.',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              if (isPrediction && widget.onSkip != null) ...[
                Expanded(
                  child: FireflyButton(
                    text: 'Skip',
                    variant: FireflyButtonVariant.secondary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onSkip!();
                    },
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FireflyButton(
                  text: isPrediction ? 'Confirm & Send' : 'Save Outcome',
                  variant: FireflyButtonVariant.primary,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onConfirmed(_selectedOutcome);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
