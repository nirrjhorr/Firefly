import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_segmented_control.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../domain/models/breathing_session_state.dart';
import '../controllers/breathing_session_controller.dart';
import '../controllers/grounding_controller.dart';
import '../widgets/cyclic_sigh_bloom_visualizer.dart';
import '../widgets/grounding_prompt_card.dart';
import '../widgets/soundscape_selector_sheet.dart';

/// Clinical respiration and sensory grounding screen.
/// Offers guided Cyclic Sighing (4s inhale / 8s exhale) and 5-4-3-2-1 Sensory Grounding.
class BreathingGroundingScreen extends ConsumerStatefulWidget {
  final String? initialMode;
  final bool showSosOverlay;

  const BreathingGroundingScreen({
    super.key,
    this.initialMode,
    this.showSosOverlay = false,
  });

  @override
  ConsumerState<BreathingGroundingScreen> createState() =>
      _BreathingGroundingScreenState();
}

class _BreathingGroundingScreenState
    extends ConsumerState<BreathingGroundingScreen> {
  late bool _isGroundingMode;

  @override
  void initState() {
    super.initState();
    _isGroundingMode = widget.initialMode == 'grounding';
  }

  void _onSoundscapeTap(String? currentSoundscape) {
    SoundscapeSelectorSheet.show(
      context,
      currentSoundscape: currentSoundscape,
      onSelect: (newSoundscape) {
        ref
            .read(breathingSessionControllerProvider.notifier)
            .setSoundscape(newSoundscape);
      },
    );
  }

  void _handleExit() {
    ref.read(breathingSessionControllerProvider.notifier).stop();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.checkIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final breathingState = ref.watch(breathingSessionControllerProvider);
    final breathingNotifier =
        ref.read(breathingSessionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header: Navigation back, Canonical Segmented Selector, Soundscape
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.screenPaddingH,
                    vertical: SpacingTokens.spaceSm,
                  ),
                  child: Row(
                    children: [
                      // Back / Exit icon
                      IconButton(
                        key: const Key('breathing_screen_back_button'),
                        icon: const Icon(AppIcons.close),
                        iconSize: IconSizeTokens.appAction,
                        color: colors.textSecondary,
                        tooltip: 'Exit',
                        onPressed: _handleExit,
                      ),

                      // Canonical Sliding Segmented Mode Selector
                      Expanded(
                        child: Center(
                          child: FireflySegmentedControl<bool>(
                            items: const [
                              SegmentItem(
                                value: false,
                                label: 'Breathing',
                                icon: AppIcons.breathe,
                              ),
                              SegmentItem(
                                value: true,
                                label: '5-4-3-2-1',
                                icon: AppIcons.progress,
                              ),
                            ],
                            selectedValue: _isGroundingMode,
                            onValueChanged: (val) {
                              setState(() {
                                _isGroundingMode = val;
                              });
                            },
                          ),
                        ),
                      ),

                      // Soundscape Button
                      IconButton(
                        key: const Key('breathing_soundscape_button'),
                        icon: Icon(
                          breathingState.soundscape == null
                              ? AppIcons.volumeMute
                              : AppIcons.audioFrequency,
                        ),
                        iconSize: IconSizeTokens.appAction,
                        color: breathingState.soundscape == null
                            ? colors.textSecondary
                            : colors.actionSage,
                        tooltip: 'Soundscape',
                        onPressed: () =>
                            _onSoundscapeTap(breathingState.soundscape),
                      ),
                    ],
                  ),
                ),

                // Main Content Body: Grounding or Respiration
                Expanded(
                  child: _isGroundingMode
                      ? _buildGroundingBody(context)
                      : _buildRespirationBody(
                          context, breathingState, breathingNotifier),
                ),
              ],
            ),

            // Persistent SOS Overlay if requested explicitly
            if (widget.showSosOverlay)
              const Positioned(
                bottom: 24,
                right: 16,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRespirationBody(
    BuildContext context,
    BreathingSessionState state,
    BreathingSessionNotifier notifier,
  ) {
    final colors = context.colors;

    // Pacing typography determination
    String pacingTitle;
    String pacingInstruction;

    if (!state.isActive && state.cycleCount == 0 && state.elapsedSeconds == 0) {
      pacingTitle = 'Breathe';
      pacingInstruction = '4s Inhale · 8s Exhale';
    } else if (state.phase.isInhale) {
      pacingTitle = 'Breathe in';
      pacingInstruction = 'Gentle inhale through your nose';
    } else {
      pacingTitle = 'Let go';
      pacingInstruction = 'Slow, soft release through mouth';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: SpacingTokens.spaceMd),

          // Pacing Typography & Instructions
          Column(
            children: [
              Text(
                pacingTitle,
                key: const Key('breathing_pacing_title'),
                style: AppTypography.displayMd.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceXs),
              Text(
                pacingInstruction,
                key: const Key('breathing_pacing_instruction'),
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),

          // Visualizer Bloom
          Center(
            child: CyclicSighBloomVisualizer(
              progress: state.phaseProgress,
              phase: state.phase,
              size: 280,
              inhaleColor: colors.actionSage,
              exhaleColor: colors.accentSecondary,
              child: state.isActive
                  ? null
                  : Icon(
                      AppIcons.play,
                      size: IconSizeTokens.hero,
                      color: colors.actionSage.withOpacity(0.6),
                    ),
            ),
          ),

          // Cycle count
          Column(
            children: [
              Text(
                state.cycleCount > 0
                    ? 'Cycle ${state.cycleCount}'
                    : 'Parasympathetic Reset',
                key: const Key('breathing_cycle_count'),
                style: AppTypography.labelSm.copyWith(
                  color: colors.textSecondary.withOpacity(0.8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceLg),

              // Controls: Play / Pause toggle
              FireflyButton(
                key: const Key('breathing_play_pause_button'),
                text: state.isActive ? 'Pause' : 'Begin Breathing',
                icon: state.isActive ? AppIcons.pause : AppIcons.play,
                onPressed: () => notifier.togglePlayPause(),
                variant: FireflyButtonVariant.primary,
              ),
              const SizedBox(height: SpacingTokens.spaceSm),

              // Secondary Exit Button
              FireflyButton(
                key: const Key('breathing_end_session_button'),
                text: 'End Session',
                onPressed: _handleExit,
                variant: FireflyButtonVariant.secondary,
              ),
              const SizedBox(height: SpacingTokens.spaceMd),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroundingBody(BuildContext context) {
    final groundingState = ref.watch(groundingControllerProvider);
    final groundingNotifier = ref.read(groundingControllerProvider.notifier);

    return GroundingPromptCard(
      state: groundingState,
      onNoticeItem: groundingNotifier.noticeItem,
      onNextStage: groundingNotifier.nextStage,
      onPreviousStage: groundingNotifier.previousStage,
      onSkipStage: groundingNotifier.skipStage,
      onCompleteEarly: groundingNotifier.completeEarly,
      onReturnHome: () => context.go(AppRoutes.checkIn),
      onTransitionToBreathing: () {
        setState(() {
          _isGroundingMode = false;
        });
        ref.read(breathingSessionControllerProvider.notifier).start();
      },
      onRepeat: groundingNotifier.reset,
    );
  }
}
