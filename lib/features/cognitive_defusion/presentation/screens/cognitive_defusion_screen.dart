import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/defusion_mode.dart';
import '../../domain/models/defusion_session_state.dart';
import '../../domain/models/defusion_thought.dart';
import '../controllers/cognitive_defusion_controller.dart';
import '../widgets/defusion_mode_selector.dart';
import '../widgets/leaves_stream_canvas.dart';
import '../widgets/thought_clouds_canvas.dart';
import '../widgets/thought_labeling_card.dart';

/// Serene, evidence-based Cognitive Defusion Suite providing psychological distance
/// through Leaves on a Stream, Thought Cloud Dissolve, and 3-tier Linguistic Defusion.
class CognitiveDefusionScreen extends ConsumerStatefulWidget {
  const CognitiveDefusionScreen({
    this.initialMode,
    this.showSosOverlay = true,
    super.key,
  });

  final String? initialMode;
  final bool showSosOverlay;

  @override
  ConsumerState<CognitiveDefusionScreen> createState() =>
      _CognitiveDefusionScreenState();
}

class _CognitiveDefusionScreenState
    extends ConsumerState<CognitiveDefusionScreen> {
  late final TextEditingController _inputController;
  Timer? _driftTimer;
  final Stopwatch _sessionStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _sessionStopwatch.start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialMode != null) {
        final mode = DefusionMode.fromString(widget.initialMode!);
        ref.read(cognitiveDefusionControllerProvider.notifier).setMode(mode);
      }
      // Populate with 2 initial gentle drifting thoughts for visual calm
      final controller =
          ref.read(cognitiveDefusionControllerProvider.notifier);
      controller.releaseThought("I notice my thoughts are active right now");
      controller.releaseThought("Letting words pass like autumn leaves");
    });

    // 60fps drift progression ticker (paced at ~0.003 progress / 50ms)
    _driftTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      ref
          .read(cognitiveDefusionControllerProvider.notifier)
          .advanceDrift(0.004);
      ref.read(cognitiveDefusionControllerProvider.notifier).tickTimer();
    });
  }

  @override
  void dispose() {
    _driftTimer?.cancel();
    _sessionStopwatch.stop();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final state = ref.read(cognitiveDefusionControllerProvider);
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (state.totalReleasedCount >= 1 || elapsedSec >= 20) {
      final actId = state.activeMode == DefusionMode.leavesOnStream
          ? 'act_defusion_leaves_stream'
          : (state.activeMode == DefusionMode.thoughtClouds
              ? 'act_defusion_thought_clouds'
              : 'act_defusion_thought_labeling');

      await EffectivenessFeedbackSheet.show(
        context,
        activityId: actId,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(cognitiveDefusionControllerProvider);
    final controller =
        ref.read(cognitiveDefusionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back,
              color: colors.textSecondary, size: IconSizeTokens.appAction),
          tooltip: 'Back',
          onPressed: _handleExit,
        ),
        title: Text(
          state.activeMode.displayName,
          style: AppTypography.headingSm.copyWith(color: colors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _handleExit,
              child: Text(
                "That's enough",
                style: AppTypography.bodySm.copyWith(
                  color: colors.actionSage,
                  fontWeight: FontWeight.w600,
                ),
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
                const SizedBox(height: SpacingTokens.spaceSm),

                // Mode Selector
                DefusionModeSelector(
                  activeMode: state.activeMode,
                  onSelectMode: controller.setMode,
                ),

                const SizedBox(height: SpacingTokens.spaceSm),

                // Main Interactive Canvas / Card View
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildActiveModeView(state, controller),
                  ),
                ),

                // Bottom Input Toolbar (for stream & clouds modes)
                if (state.activeMode != DefusionMode.thoughtLabeling)
                  _buildBottomThoughtInput(colors, state, controller),
              ],
            ),
          ),

          // Persistent SOS Floating Overlay
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

  Widget _buildActiveModeView(
    DefusionSessionState state,
    CognitiveDefusionController controller,
  ) {
    switch (state.activeMode) {
      case DefusionMode.leavesOnStream:
        return LeavesStreamCanvas(
          key: const ValueKey('leaves_canvas'),
          thoughts: state.thoughts,
          onTapLeaf: (t) => controller.dissolveThought(t.id),
        );
      case DefusionMode.thoughtClouds:
        return ThoughtCloudsCanvas(
          key: const ValueKey('clouds_canvas'),
          thoughts: state.thoughts,
          onTapCloud: (t) => controller.dissolveThought(t.id),
        );
      case DefusionMode.thoughtLabeling:
        return ThoughtLabelingCard(
          key: const ValueKey('labeling_card'),
          state: state,
          onAdvanceStep: controller.advanceLabelingStep,
          onSelectThought: controller.setLabelingThought,
        );
    }
  }

  Widget _buildBottomThoughtInput(
    AppCustomColors colors,
    DefusionSessionState state,
    CognitiveDefusionController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.spaceLg,
        vertical: SpacingTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Starter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kCuratedDefusionPrompts.take(6).map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(prompt),
                    onPressed: () {
                      controller.releaseThought(prompt);
                    },
                    backgroundColor: colors.surfaceSubtle,
                    labelStyle: AppTypography.captionSm
                        .copyWith(color: colors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                      side: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: SpacingTokens.spaceSm),

          // Custom text field & Release button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onChanged: controller.updateInputText,
                  style: AppTypography.bodyMd
                      .copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: state.activeMode == DefusionMode.leavesOnStream
                        ? 'Place a thought onto a leaf...'
                        : 'Type a heavy thought into a cloud...',
                    hintStyle: AppTypography.bodySm.copyWith(
                      color: colors.textTertiary,
                    ),
                    filled: true,
                    fillColor: colors.surfaceSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.input),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.input),
                      borderSide: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      controller.releaseThought(val);
                      _inputController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: SpacingTokens.spaceSm),
              FireflyButton.primary(
                label: 'Release',
                icon: state.activeMode == DefusionMode.leavesOnStream
                    ? AppIcons.nature
                    : Icons.air,
                onPressed: () {
                  if (_inputController.text.trim().isNotEmpty) {
                    controller.releaseThought(_inputController.text);
                    _inputController.clear();
                  } else {
                    controller.releaseThought(
                      kCuratedDefusionPrompts[
                          state.totalReleasedCount %
                              kCuratedDefusionPrompts.length],
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
