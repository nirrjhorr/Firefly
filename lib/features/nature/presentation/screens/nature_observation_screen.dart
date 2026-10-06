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
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/nature_observation_mode.dart';
import '../controllers/nature_controller.dart';
import '../widgets/nature_mode_selector.dart';
import '../widgets/nature_prompt_card.dart';

/// Screen hosting the Guided Nature & Outdoor Micro-Observation Suite (Story 12.1).
/// Provides low-cognitive-load environmental grounding prompts without streaks, scores, or cloud dependency.
class NatureObservationScreen extends ConsumerStatefulWidget {
  const NatureObservationScreen({
    super.key,
    this.initialMode,
    this.showSosOverlay = true,
  });

  final String? initialMode;
  final bool showSosOverlay;

  @override
  ConsumerState<NatureObservationScreen> createState() =>
      _NatureObservationScreenState();
}

class _NatureObservationScreenState
    extends ConsumerState<NatureObservationScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();
  Timer? _softTimer;

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();

    _softTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        ref.read(natureControllerProvider.notifier).tickTimer();
      }
    });

    if (widget.initialMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mode = NatureObservationMode.fromString(widget.initialMode!);
        ref.read(natureControllerProvider.notifier).setMode(mode);
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
    final state = ref.read(natureControllerProvider);
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (state.completedPrompts >= 1 || state.isCompleted) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_nature_${state.mode.name}',
        stateAtStart: 'overwhelmed',
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
    final state = ref.watch(natureControllerProvider);
    final controller = ref.read(natureControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.screenPaddingH,
                    vertical: SpacingTokens.spaceSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back / Exit Button
                      Semantics(
                        button: true,
                        label: 'Leave nature grounding session',
                        child: IconButton(
                          key: const Key('nature_btn_back'),
                          onPressed: _handleExit,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: colors.textSecondary,
                            size: 24,
                          ),
                          tooltip: 'Exit',
                        ),
                      ),

                      // Screen Title
                      Text(
                        'Nature Grounding',
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Soft Ambient Timer Toggle
                      IconButton(
                        key: const Key('nature_btn_timer_toggle'),
                        onPressed: controller.toggleTimer,
                        icon: Icon(
                          state.isTimerActive
                              ? Icons.timer_outlined
                              : Icons.timer_off_outlined,
                          color: state.isTimerActive
                              ? colors.actionSage
                              : colors.textTertiary,
                          size: 22,
                        ),
                        tooltip: state.isTimerActive
                            ? 'Hide ambient timer'
                            : 'Show ambient timer',
                      ),
                    ],
                  ),
                ),

                // Soft Timer Banner (if enabled)
                if (state.isTimerActive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.spaceSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.spaceMd,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(RadiusTokens.pill),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Text(
                        _formatTimer(state.elapsedSeconds),
                        style: AppTypography.monoMedium.copyWith(
                          color: colors.actionSage,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                // Mode Selector Pills
                NatureModeSelector(
                  currentMode: state.mode,
                  onSelectMode: (mode) => controller.setMode(mode),
                ),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.screenPaddingH,
                    vertical: SpacingTokens.spaceSm,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    child: LinearProgressIndicator(
                      value: state.progressFraction,
                      minHeight: 3,
                      backgroundColor: colors.surfaceSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.actionSage),
                    ),
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.screenPaddingH,
                      vertical: SpacingTokens.spaceMd,
                    ),
                    child: Column(
                      children: [
                        NaturePromptCard(
                          prompt: state.currentPrompt,
                          stepNumber: state.currentPromptIndex + 1,
                          totalSteps: state.totalPrompts,
                          isCompleted: state.isCompleted,
                          onNext: controller.nextPrompt,
                          onPrevious: state.hasPrevious ? controller.previousPrompt : null,
                          onSkip: controller.skipPrompt,
                          onRestart: controller.reset,
                        ),
                        const SizedBox(height: SpacingTokens.spaceXl),

                        // Non-judgmental early exit button
                        TextButton(
                          key: const Key('nature_btn_enough'),
                          onPressed: _handleExit,
                          child: Text(
                            "That's enough for now",
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.spaceXxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // SOS Overlay Button (Respects shell nesting)
            if (widget.showSosOverlay)
              const Positioned(
                bottom: SpacingTokens.spaceLg,
                right: SpacingTokens.spaceLg,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }
}
