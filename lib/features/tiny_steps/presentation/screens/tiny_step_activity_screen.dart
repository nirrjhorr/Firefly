import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../controllers/tiny_steps_controller.dart';
import '../controllers/tiny_step_timer_controller.dart';

class TinyStepActivityScreen extends ConsumerStatefulWidget {
  const TinyStepActivityScreen({super.key, required this.stepId});

  final String stepId;

  @override
  ConsumerState<TinyStepActivityScreen> createState() =>
      _TinyStepActivityScreenState();
}

class _TinyStepActivityScreenState
    extends ConsumerState<TinyStepActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tinyStepTimerControllerProvider(widget.stepId).notifier).start();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _triggerCompletionHaptic() async {
    try {
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics fail silently on unsupported platforms
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final timerState = ref.watch(
      tinyStepTimerControllerProvider(widget.stepId),
    );
    final timerController = ref.read(
      tinyStepTimerControllerProvider(widget.stepId).notifier,
    );

    final step = timerState.step;
    final isTimed = step.isTimed;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: colors.textSecondary,
            size: IconSizeTokens.appAction,
          ),
          tooltip: 'Exit activity',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.screenPaddingH,
            0,
            SpacingTokens.screenPaddingH,
            SpacingTokens.bottomClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.headingLg.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.spaceMd),
                    Text(
                      step.description,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLg.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.space3xl),

                    // Timer Display
                    FireflyCard(
                      variant: timerState.isTargetReached
                          ? FireflyCardVariant.raised
                          : FireflyCardVariant.flat,
                      padding: const EdgeInsets.all(
                        SpacingTokens.cardPaddingLg,
                      ),
                      borderColor: timerState.isTargetReached
                          ? colors.accentPrimary
                          : colors.borderSubtle,
                      backgroundColor: timerState.isTargetReached
                          ? colors.accentPrimary.withOpacity(0.1)
                          : colors.surfaceCard,
                      child: Column(
                        children: [
                          if (isTimed) ...[
                            Text(
                              'Target: ${step.durationMinutes} minutes',
                              style: AppTypography.labelMd.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.spaceSm),
                          ],
                          Text(
                            _formatDuration(timerState.elapsed),
                            style: AppTypography.displayLg.copyWith(
                              color: colors.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (isTimed && !timerState.isTargetReached) ...[
                            const SizedBox(height: SpacingTokens.spaceSm),
                            Text(
                              'Remaining: ${_formatDuration(timerState.remaining!)}',
                              style: AppTypography.labelMd.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ] else if (isTimed && timerState.isTargetReached) ...[
                            const SizedBox(height: SpacingTokens.spaceSm),
                            Text(
                              '${step.durationMinutes} minutes completed',
                              style: AppTypography.labelMd.copyWith(
                                color: colors.accentPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FireflyButton(
                    variant: FireflyButtonVariant.secondary,
                    isFullWidth: false,
                    icon: timerState.isRunning ? AppIcons.pause : AppIcons.play,
                    text: timerState.isRunning ? 'Pause' : 'Resume',
                    onPressed: () {
                      if (timerState.isRunning) {
                        timerController.pause();
                      } else {
                        timerController.start();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.spaceLg),
              FireflyButton(
                variant: FireflyButtonVariant.primary,
                icon: AppIcons.check,
                text: 'Mark as Done',
                onPressed: () async {
                  timerController.pause();
                  await _triggerCompletionHaptic();
                  ref
                      .read(tinyStepsControllerProvider.notifier)
                      .completeStep(step.id, timerState.elapsed);
                  if (context.mounted) {
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
