import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/somatic_exercise_mode.dart';
import '../controllers/somatic_controller.dart';
import '../widgets/somatic_mode_selector_sheet.dart';
import '../widgets/somatic_prompt_card.dart';
import '../widgets/somatic_visualizer_widget.dart';

/// Screen hosting the Somatic Visualizations & Body Centering Suite (Story 12.2).
/// Provides low-cognitive-load somatic regulation without streaks, countdowns, or cloud dependency.
class SomaticCenteringScreen extends ConsumerStatefulWidget {
  const SomaticCenteringScreen({
    super.key,
    this.initialMode,
    this.showSosOverlay = true,
  });

  final String? initialMode;
  final bool showSosOverlay;

  @override
  ConsumerState<SomaticCenteringScreen> createState() =>
      _SomaticCenteringScreenState();
}

class _SomaticCenteringScreenState extends ConsumerState<SomaticCenteringScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();
  Timer? _softTimer;

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();

    _softTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        ref.read(somaticControllerProvider.notifier).tickTimer();
      }
    });

    if (widget.initialMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mode = SomaticExerciseMode.fromString(widget.initialMode!);
        ref.read(somaticControllerProvider.notifier).setMode(mode);
      });
    }
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    _softTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final state = ref.read(somaticControllerProvider);
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (state.completedStages >= 1 || state.isCompleted) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_somatic_${state.mode.name}',
        stateAtStart: 'restless',
        durationSeconds: elapsedSec > 0 ? elapsedSec : 30,
      );
    }

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.checkIn);
      }
    }
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(somaticControllerProvider);
    final controller = ref.read(somaticControllerProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExit();
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Go back',
            onPressed: _handleExit,
          ),
          title: Text(
            state.mode.title,
            style: AppTypography.titleMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            // Ambient soundscape audio toggle
            IconButton(
              icon: Icon(
                state.isAudioPlaying
                    ? Icons.volume_up_rounded
                    : Icons.volume_mute_rounded,
                color: state.isAudioPlaying ? colors.primary : colors.textSecondary,
              ),
              tooltip: state.isAudioPlaying
                  ? 'Mute ambient soundscape'
                  : 'Play ambient soundscape',
              onPressed: () => controller.toggleAudio(),
            ),

            // Soft timer toggle
            IconButton(
              icon: Icon(
                state.isTimerActive
                    ? Icons.timer_outlined
                    : Icons.timer_off_outlined,
                color: colors.textSecondary,
              ),
              tooltip: state.isTimerActive ? 'Hide timer' : 'Show timer',
              onPressed: () => controller.toggleTimer(),
            ),

            // Non-judgmental early exit
            TextButton(
              onPressed: _handleExit,
              style: TextButton.styleFrom(
                foregroundColor: colors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              ),
              child: Text(
                "That's enough",
                style: AppTypography.labelMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg,
                  vertical: SpacingTokens.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Exercise mode switch bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            SomaticModeSelectorSheet.show(
                              context,
                              currentMode: state.mode,
                              onModeSelected: (m) => controller.setMode(m),
                            );
                          },
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: Text(
                            'Switch exercise',
                            style: AppTypography.labelMedium,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(130, 48),
                            foregroundColor: colors.primary,
                            side: BorderSide(
                              color: colors.primary.withValues(alpha: 0.50),
                            ),
                          ),
                        ),
                        if (state.isTimerActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.md,
                              vertical: SpacingTokens.xs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              borderRadius:
                                  BorderRadius.circular(RadiusTokens.full),
                              border: Border.all(
                                color: colors.outline.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: SpacingTokens.xs),
                                Text(
                                  _formatTimer(state.elapsedSeconds),
                                  style: AppTypography.labelMedium.copyWith(
                                    color: colors.textSecondary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.lg),

                    // Organic Somatic Visualizer Widget
                    Center(
                      child: Semantics(
                        label: 'Organic pulse aura representing physiological settling',
                        child: SomaticVisualizerWidget(
                          mode: state.mode,
                          size: 190.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),

                    // Paced Prompt Content or Completion View
                    AnimatedSwitcher(
                      duration: AnimationTokens.normal,
                      child: state.isCompleted
                          ? _buildCompletionCard(context, controller, colors)
                          : (state.currentStage != null
                              ? SomaticPromptCard(
                                  key: ValueKey(state.currentStage!.id),
                                  prompt: state.currentStage!,
                                  totalStages: state.totalStages,
                                  isLastStage: state.isLastStage,
                                  onCompleted: () => controller.advanceStage(),
                                  onSkip: () => controller.skipStage(),
                                )
                              : const SizedBox.shrink()),
                    ),
                    const SizedBox(height: SpacingTokens.xxl),
                  ],
                ),
              ),
            ),

            // Persistent SOS panic button
            if (widget.showSosOverlay)
              const Positioned(
                bottom: SpacingTokens.lg,
                right: SpacingTokens.lg,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(
    BuildContext context,
    SomaticController controller,
    ThemeColors colors,
  ) {
    return FireflyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: colors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Somatic Cycle Complete',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Your body did quiet work here.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Notice any subtle softening across your jaw, shoulders, or hands. Even small shifts matter. Take as much time as you like before moving on.',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textPrimary.withValues(alpha: 0.88),
              height: 1.5,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          SizedBox(
            height: 56, // Enforce ≥ 56dp
            child: FireflyButton(
              label: 'Finish & Reflect',
              variant: FireflyButtonVariant.primary,
              onPressed: _handleExit,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: TextButton(
              onPressed: () => controller.reset(),
              style: TextButton.styleFrom(
                minimumSize: const Size(140, 48),
                foregroundColor: colors.primary,
              ),
              child: const Text('Repeat this exercise'),
            ),
          ),
        ],
      ),
    );
  }
}
