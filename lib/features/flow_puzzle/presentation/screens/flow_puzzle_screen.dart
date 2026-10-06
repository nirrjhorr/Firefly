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
import '../../domain/models/constellation_pattern.dart';
import '../../domain/models/flow_puzzle_type.dart';
import '../controllers/flow_puzzle_controller.dart';
import '../widgets/constellation_canvas_widget.dart';
import '../widgets/flow_puzzle_mode_sheet.dart';
import '../widgets/sliding_tile_grid_widget.dart';

/// Screen hosting Flow & Spatial Puzzles (Story 13.2 / Epic 13).
/// Non-demanding spatial tasks consuming working memory with zero scoring, timers, or fail states.
class FlowPuzzleScreen extends ConsumerStatefulWidget {
  const FlowPuzzleScreen({
    super.key,
    this.initialMode,
    this.initialPattern,
    this.showSosOverlay = true,
  });

  final String? initialMode;
  final String? initialPattern;
  final bool showSosOverlay;

  @override
  ConsumerState<FlowPuzzleScreen> createState() => _FlowPuzzleScreenState();
}

class _FlowPuzzleScreenState extends ConsumerState<FlowPuzzleScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();
  Timer? _softTimer;

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();

    _softTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        ref.read(flowPuzzleControllerProvider.notifier).tickTimer();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(flowPuzzleControllerProvider.notifier);
      if (widget.initialMode != null) {
        final mode = FlowPuzzleMode.fromString(widget.initialMode!);
        controller.setMode(mode);
      }
      if (widget.initialPattern != null) {
        final pattern = ConstellationPattern.fromString(widget.initialPattern!);
        controller.setConstellation(pattern);
      }
    });
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    _softTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final state = ref.read(flowPuzzleControllerProvider);
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (state.totalInteractions >= 3 || state.isCompleted) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_flow_puzzle_${state.mode.name}',
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
    final state = ref.watch(flowPuzzleControllerProvider);
    final controller = ref.read(flowPuzzleControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF111518),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB8C2CC)),
          tooltip: 'Return',
          onPressed: _handleExit,
        ),
        title: Text(
          'Flow & Spatial Focus',
          style: context.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          // Gentle session timer
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: SpacingTokens.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2228),
                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  border: Border.all(color: const Color(0xFF2E3A44), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF8A98A5)),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimer(state.elapsedSeconds),
                      style: context.bodySmall?.copyWith(
                        color: const Color(0xFFCCD5DD),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Mode switch button
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFFE8B86D)),
            tooltip: 'Change mode',
            onPressed: () {
              FlowPuzzleModeSheet.show(
                context,
                currentMode: state.mode,
                currentConstellation: state.activeConstellation,
                onSelectMode: controller.setMode,
                onSelectConstellation: controller.setConstellation,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
              child: Column(
                children: [
                  // Mode & Pattern Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B20),
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      border: Border.all(color: const Color(0xFF263038), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.mode == FlowPuzzleMode.constellationConnect
                              ? Icons.auto_awesome
                              : Icons.grid_view,
                          color: const Color(0xFF82A796),
                          size: 20,
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.mode == FlowPuzzleMode.constellationConnect
                                    ? state.activeConstellation.name
                                    : 'Harmony Tiles',
                                style: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                state.mode == FlowPuzzleMode.constellationConnect
                                    ? (state.isCompleted
                                        ? 'Constellation complete. Rest here a moment.'
                                        : 'Touch star ${state.nextExpectedNodeId} to continue the celestial line.')
                                    : 'Slide numbered tiles into gentle sequential order.',
                                style: context.bodySmall?.copyWith(
                                  color: const Color(0xFF8A98A5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            FlowPuzzleModeSheet.show(
                              context,
                              currentMode: state.mode,
                              currentConstellation: state.activeConstellation,
                              onSelectMode: controller.setMode,
                              onSelectConstellation: controller.setConstellation,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Text(
                                  'Change',
                                  style: context.bodySmall?.copyWith(
                                    color: const Color(0xFFE8B86D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down,
                                    color: Color(0xFFE8B86D), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: SpacingTokens.sm),

                  // Main Puzzle Surface
                  Expanded(
                    child: Center(
                      child: state.mode == FlowPuzzleMode.constellationConnect
                          ? ConstellationCanvasWidget(
                              pattern: state.activeConstellation,
                              connectedNodeIndices: state.connectedNodeIndices,
                              nextExpectedNodeId: state.nextExpectedNodeId,
                              isCompleted: state.isCompleted,
                              onNodeTapped: controller.connectNode,
                            )
                          : SlidingTileGridWidget(
                              gridState: state.gridState,
                              isSolved: state.gridState.isSolved,
                              moveCount: state.moveCount,
                              onTileTapped: controller.slideTile,
                              onShuffle: controller.shuffleGrid,
                              onReset: controller.resetGrid,
                            ),
                    ),
                  ),

                  const SizedBox(height: SpacingTokens.sm),

                  // Bottom Action Bar
                  Row(
                    children: [
                      if (state.mode == FlowPuzzleMode.constellationConnect) ...[
                        OutlinedButton.icon(
                          onPressed: controller.undoLastNode,
                          icon: const Icon(Icons.undo, size: 18),
                          label: const Text('Undo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8A98A5),
                            side: const BorderSide(color: Color(0xFF2E3A44)),
                            minimumSize: const Size(90, 52),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        OutlinedButton.icon(
                          onPressed: controller.resetConstellation,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8A98A5),
                            side: const BorderSide(color: Color(0xFF2E3A44)),
                            minimumSize: const Size(90, 52),
                          ),
                        ),
                      ],
                      const SizedBox(width: SpacingTokens.sm),
                      Expanded(
                        child: FireflyButton.primary(
                          label: "That's enough for now",
                          onPressed: _handleExit,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: SpacingTokens.md),
                ],
              ),
            ),
          ),

          // Persistent SOS Overlay Button
          if (widget.showSosOverlay)
            const Positioned(
              bottom: 80,
              right: 16,
              child: SosOverlayButton(),
            ),
        ],
      ),
    );
  }
}
