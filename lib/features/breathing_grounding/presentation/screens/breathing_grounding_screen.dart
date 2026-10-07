import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_segmented_control.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../domain/models/breathing_session_state.dart';
import '../controllers/breathing_session_controller.dart';
import '../controllers/grounding_controller.dart';
import '../widgets/cyclic_sigh_bloom_visualizer.dart';
import '../widgets/grounding_mode_selector.dart';
import '../widgets/grounding_prompt_card.dart';
import '../widgets/soundscape_selector_sheet.dart';
import '../../domain/models/grounding_stage.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';

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
    final modeStr = widget.initialMode?.toLowerCase() ?? '';
    final isSpecificGrounding = modeStr == 'grounding' ||
        modeStr == 'textures' ||
        modeStr == 'texturehunt' ||
        modeStr == 'soundhunt' ||
        modeStr == 'coloursearch' ||
        modeStr == 'colorsearch' ||
        modeStr == 'feetonfloor';
    _isGroundingMode = isSpecificGrounding;

    if (isSpecificGrounding && modeStr != 'grounding') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final selectedMode = GroundingMode.fromString(widget.initialMode);
        ref.read(groundingControllerProvider.notifier).setMode(selectedMode);
      });
    }
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

  Future<void> _handleExit() async {
    final state = ref.read(breathingSessionControllerProvider);
    ref.read(breathingSessionControllerProvider.notifier).stop();

    if (state.cycleCount > 0 || state.elapsedSeconds >= 10) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'breathing_${state.technique.name}',
        stateAtStart: 'active_session',
        durationSeconds: state.elapsedSeconds,
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
    final technique = state.technique;

    // Pacing typography determination
    String pacingTitle;
    String pacingInstruction;

    if (!state.isActive && state.cycleCount == 0 && state.elapsedSeconds == 0) {
      pacingTitle = technique.displayName;
      final inS = (technique.inhaleMs / 1000).toStringAsFixed(technique.inhaleMs % 1000 == 0 ? 0 : 1);
      final inHoldS = (technique.inhaleHoldMs / 1000).toStringAsFixed(0);
      final exS = (technique.exhaleMs / 1000).toStringAsFixed(technique.exhaleMs % 1000 == 0 ? 0 : 1);
      final exHoldS = (technique.exhaleHoldMs / 1000).toStringAsFixed(0);

      final parts = <String>['${inS}s In'];
      if (technique.inhaleHoldMs > 0) parts.add('${inHoldS}s Hold');
      parts.add('${exS}s Out');
      if (technique.exhaleHoldMs > 0) parts.add('${exHoldS}s Rest');
      pacingInstruction = parts.join(' · ');
    } else {
      switch (state.phase) {
        case BreathingPhase.inhale:
          pacingTitle = 'Breathe in';
          pacingInstruction = 'Gentle, expansive inhale through nose';
          break;
        case BreathingPhase.inhaleHold:
          pacingTitle = 'Hold gently';
          pacingInstruction = 'Rest softly with lungs comfortably full';
          break;
        case BreathingPhase.exhale:
          pacingTitle = 'Let go';
          pacingInstruction = 'Slow, soft release through mouth';
          break;
        case BreathingPhase.exhaleHold:
          pacingTitle = 'Rest empty';
          pacingInstruction = 'Calm stillness before next breath';
          break;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Technique selector pill row
        Padding(
          padding: const EdgeInsets.only(top: SpacingTokens.spaceXs, bottom: SpacingTokens.spaceXs),
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
              itemCount: BreathingTechnique.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.spaceXs),
              itemBuilder: (context, index) {
                final t = BreathingTechnique.values[index];
                final isSelected = t == state.technique;
                return GestureDetector(
                  key: Key('technique_chip_${t.name}'),
                  onTap: () {
                    if (state.isActive) notifier.stop();
                    notifier.setTechnique(t);
                  },
                  child: AnimatedContainer(
                    duration: MotionTokens.micro,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.actionSage.withOpacity(0.18) : colors.bgSurface,
                      borderRadius: BorderRadius.circular(RadiusTokens.pill),
                      border: Border.all(
                        color: isSelected ? colors.actionSage : colors.borderSubtle,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.displayName,
                      style: AppTypography.labelSm.copyWith(
                        color: isSelected ? colors.actionSage : colors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Pacing Typography & Instructions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
          child: Column(
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
        ),

        // Visualizer Bloom
        Center(
          child: CyclicSighBloomVisualizer(
            progress: state.phaseProgress,
            phase: state.phase,
            isActive: state.isActive,
            size: 260,
            inhaleColor: colors.actionSage,
            exhaleColor: colors.accentSecondary,
            child: state.isActive
                ? Text(
                    state.phase == BreathingPhase.inhale
                        ? 'Inhale'
                        : state.phase == BreathingPhase.exhale
                            ? 'Exhale'
                            : 'Hold',
                    style: AppTypography.headingMd.copyWith(
                      color: Colors.white.withOpacity(0.92),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  )
                : null,
          ),
        ),

        // Cycle count & Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
          child: Column(
            children: [
              Text(
                state.cycleCount > 0
                    ? 'Cycle ${state.cycleCount}'
                    : state.technique.displayName,
                key: const Key('breathing_cycle_count'),
                style: AppTypography.labelSm.copyWith(
                  color: colors.textSecondary.withOpacity(0.8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceMd),

              // Controls: Play / Pause toggle
              FireflyButton(
                key: const Key('breathing_play_pause_button'),
                text: state.isActive
                    ? 'Pause Breathing'
                    : (state.elapsedSeconds > 0 ? 'Resume Breathing' : 'Begin Breathing'),
                icon: state.isActive ? AppIcons.pause : AppIcons.play,
                onPressed: () => notifier.togglePlayPause(),
                variant: FireflyButtonVariant.primary,
              ),
              const SizedBox(height: SpacingTokens.spaceSm),

              // Secondary Exit Button
              FireflyButton(
                key: const Key('breathing_end_session_button'),
                text: 'End Session',
                onPressed: () {
                  notifier.stop();
                  _handleExit();
                },
                variant: FireflyButtonVariant.secondary,
              ),
              const SizedBox(height: SpacingTokens.spaceSm),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroundingBody(BuildContext context) {
    final groundingState = ref.watch(groundingControllerProvider);
    final groundingNotifier = ref.read(groundingControllerProvider.notifier);

    return Column(
      children: [
        if (!groundingState.isCompleted)
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.spaceXs, bottom: SpacingTokens.spaceXs),
            child: GroundingModeSelector(
              currentMode: groundingState.mode,
              onSelectMode: groundingNotifier.setMode,
            ),
          ),
        Expanded(
          child: GroundingPromptCard(
            state: groundingState,
            onNoticeItem: groundingNotifier.noticeItem,
            onNextStage: groundingNotifier.nextStage,
            onPreviousStage: groundingNotifier.previousStage,
            onSkipStage: groundingNotifier.skipStage,
            onCompleteEarly: () async {
              groundingNotifier.completeEarly();
              await EffectivenessFeedbackSheet.show(
                context,
                activityId: 'grounding_${groundingState.mode.name}',
                stateAtStart: 'active_grounding',
                durationSeconds: 60,
              );
            },
            onReturnHome: () async {
              if (groundingState.isCompleted ||
                  groundingState.currentStageIndex > 0 ||
                  groundingState.currentStageNoticedCount > 0) {
                await EffectivenessFeedbackSheet.show(
                  context,
                  activityId: 'grounding_${groundingState.mode.name}',
                  stateAtStart: 'active_grounding',
                  durationSeconds: 60,
                );
              }
              if (context.mounted) {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.checkIn);
                }
              }
            },
            onTransitionToBreathing: () {
              setState(() {
                _isGroundingMode = false;
              });
              ref.read(breathingSessionControllerProvider.notifier).start();
            },
            onRepeat: groundingNotifier.reset,
          ),
        ),
      ],
    );
  }
}
