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
import '../../domain/models/labyrinth_pattern_type.dart';
import '../controllers/labyrinth_controller.dart';
import '../widgets/labyrinth_canvas_widget.dart';
import '../widgets/labyrinth_pattern_selector_sheet.dart';

/// Screen hosting Meditative Labyrinth Tracing & Canvas Drawing (Story 12.3).
/// Continuous kinesthetic motor soothing with zero scoring, timers, or wall collisions.
class LabyrinthScreen extends ConsumerStatefulWidget {
  const LabyrinthScreen({
    super.key,
    this.initialPattern,
    this.showSosOverlay = true,
  });

  final String? initialPattern;
  final bool showSosOverlay;

  @override
  ConsumerState<LabyrinthScreen> createState() => _LabyrinthScreenState();
}

class _LabyrinthScreenState extends ConsumerState<LabyrinthScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();
  Timer? _softTimer;

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();

    _softTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        ref.read(labyrinthControllerProvider.notifier).tickTimer();
      }
    });

    if (widget.initialPattern != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pattern = LabyrinthPatternType.fromString(widget.initialPattern!);
        ref.read(labyrinthControllerProvider.notifier).setPattern(pattern);
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
    final state = ref.read(labyrinthControllerProvider);
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (state.totalPointsTraced >= 20 || state.isCompleted) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_labyrinth_${state.pattern.name}',
        stateAtStart: 'racingThoughts',
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
    final state = ref.watch(labyrinthControllerProvider);
    final controller = ref.read(labyrinthControllerProvider.notifier);

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
            state.pattern.title,
            style: AppTypography.titleMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            // Toggle guide path visibility
            IconButton(
              icon: Icon(
                state.showGuidePath
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: colors.textSecondary,
              ),
              tooltip: state.showGuidePath ? 'Hide guide path' : 'Show guide path',
              onPressed: () => controller.toggleGuidePath(),
            ),

            // Clear current finger trail
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Clear trail to retrace',
              onPressed: () => controller.clearTrail(),
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
              child: Column(
                children: [
                  // Top control info bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.lg,
                      vertical: SpacingTokens.xs,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            LabyrinthPatternSelectorSheet.show(
                              context,
                              currentPattern: state.pattern,
                              onPatternSelected: (p) => controller.setPattern(p),
                            );
                          },
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: Text(
                            'Switch pattern',
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.md,
                            vertical: SpacingTokens.xs,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(RadiusTokens.full),
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
                  ),

                  // Main Interactive Tracing Canvas
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(RadiusTokens.xl),
                        child: Container(
                          color: colors.surfaceContainer.withValues(alpha: 0.35),
                          child: LabyrinthCanvasWidget(
                            state: state,
                            onPanStart: (pos) => controller.onPanStart(pos),
                            onPanUpdate: (pos, guides) =>
                                controller.onPanUpdate(pos, guides),
                            onPanEnd: () => controller.onPanEnd(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom guidance / completion feedback card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.lg,
                      SpacingTokens.xs,
                      SpacingTokens.lg,
                      SpacingTokens.md,
                    ),
                    child: FireflyCard(
                      child: Row(
                        children: [
                          Icon(
                            state.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.touch_app_rounded,
                            color: colors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: SpacingTokens.md),
                          Expanded(
                            child: Text(
                              state.isCompleted
                                  ? 'You reached the center. Rest here as long as you like, or retrace at your own rhythm.'
                                  : 'Trace smoothly with your finger. There are no dead ends or wrong turns.',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
}
