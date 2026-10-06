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
import '../../../../shared/widgets/firefly_card.dart';
import '../../../../shared/widgets/firefly_segmented_control.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../domain/models/pmr_zone.dart';
import '../controllers/pmr_controller.dart';
import '../widgets/pmr_body_silhouette.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';

/// Clinical Progressive Muscle Relaxation (PMR) interactive screen.
/// Offers guided isometric tension-release cycles across 10 anatomical zones
/// or a 5-zone quick de-escalation sequence.
class PmrScreen extends ConsumerStatefulWidget {
  final bool isQuickMode;
  final bool showSosOverlay;

  const PmrScreen({
    super.key,
    this.isQuickMode = false,
    this.showSosOverlay = false,
  });

  @override
  ConsumerState<PmrScreen> createState() => _PmrScreenState();
}

class _PmrScreenState extends ConsumerState<PmrScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isQuickMode) {
        ref.read(pmrControllerProvider.notifier).setQuickMode(true);
      }
    });
  }

  Future<void> _handleExit() async {
    final state = ref.read(pmrControllerProvider);
    ref.read(pmrControllerProvider.notifier).stop();

    if (state.currentZoneIndex > 0 || state.isCompleted) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: state.isQuickMode ? 'pmr_quick_5' : 'pmr_full_10',
        stateAtStart: 'active_session',
        durationSeconds: (state.currentZoneIndex + 1) * 23,
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
    final state = ref.watch(pmrControllerProvider);
    final notifier = ref.read(pmrControllerProvider.notifier);
    final zone = state.currentZone;

    // Color theme for current phase
    final Color phaseColor;
    final String phaseTitle;
    final String phaseInstruction;

    switch (state.phase) {
      case PmrPhase.tense:
        phaseColor = const Color(0xFFE5A93C); // Warm amber
        phaseTitle = 'TENSE · 5s';
        phaseInstruction = zone.tenseInstruction;
        break;
      case PmrPhase.hold:
        phaseColor = const Color(0xFFD4973B); // Deep amber
        phaseTitle = 'HOLD · 3s';
        phaseInstruction = 'Sustain steady, controlled tension. Do not strain.';
        break;
      case PmrPhase.release:
        phaseColor = colors.actionSage;
        phaseTitle = 'RELEASE · 10s';
        phaseInstruction = zone.releaseInstruction;
        break;
      case PmrPhase.notice:
        phaseColor = colors.accentSecondary;
        phaseTitle = 'NOTICE · 5s';
        phaseInstruction = 'Feel the difference between tension and stillness.';
        break;
    }

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header: Close button, Mode Segmented Control
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.screenPaddingH,
                    vertical: SpacingTokens.spaceSm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('pmr_back_button'),
                        icon: const Icon(AppIcons.close),
                        iconSize: IconSizeTokens.appAction,
                        color: colors.textSecondary,
                        tooltip: 'Exit',
                        onPressed: _handleExit,
                      ),
                      Expanded(
                        child: Center(
                          child: FireflySegmentedControl<bool>(
                            items: const [
                              SegmentItem(
                                value: false,
                                label: 'Full (10)',
                                icon: AppIcons.checkIn,
                              ),
                              SegmentItem(
                                value: true,
                                label: 'Quick (5)',
                                icon: AppIcons.breathe,
                              ),
                            ],
                            selectedValue: state.isQuickMode,
                            onValueChanged: (val) {
                              notifier.setQuickMode(val);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('pmr_restart_button'),
                        icon: const Icon(AppIcons.history),
                        iconSize: IconSizeTokens.appAction,
                        color: colors.textSecondary,
                        tooltip: 'Restart',
                        onPressed: () => notifier.restart(),
                      ),
                    ],
                  ),
                ),

                // Main Scrollable / Column Body
                Expanded(
                  child: state.isCompleted
                      ? _buildCompletionView(context, notifier)
                      : _buildActiveSessionView(
                          context,
                          state,
                          notifier,
                          zone,
                          phaseColor,
                          phaseTitle,
                          phaseInstruction,
                        ),
                ),
              ],
            ),

            // Persistent SOS Floating Button if requested
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

  Widget _buildActiveSessionView(
    BuildContext context,
    PmrSessionState state,
    PmrController notifier,
    PmrMuscleZone zone,
    Color phaseColor,
    String phaseTitle,
    String phaseInstruction,
  ) {
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.spaceXs),

          // Zone Counter & Name
          Text(
            'Zone ${state.currentZoneIndex + 1} of ${state.totalZones}',
            key: const Key('pmr_zone_counter'),
            style: AppTypography.labelSm.copyWith(
              color: colors.textSecondary.withOpacity(0.8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceXs),
          Text(
            zone.displayName,
            key: const Key('pmr_zone_title'),
            style: AppTypography.displayMd.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),

          // Interactive Silhouette
          Center(
            child: PmrBodySilhouette(
              activeZone: zone,
              phase: state.phase,
              phaseProgress: state.phaseProgress,
              height: 280,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),

          // Clinical Guidance Card
          FireflyCard(
            variant: FireflyCardVariant.flat,
            padding: const EdgeInsets.all(SpacingTokens.cardPadding),
            child: Column(
              children: [
                // Phase Pill
                AnimatedContainer(
                  duration: MotionTokens.micro,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: phaseColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                    border: Border.all(color: phaseColor.withOpacity(0.7), width: 1.2),
                  ),
                  child: Text(
                    phaseTitle,
                    key: const Key('pmr_phase_badge'),
                    style: AppTypography.labelSm.copyWith(
                      color: phaseColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.spaceSm),

                // Instruction text
                Text(
                  phaseInstruction,
                  key: const Key('pmr_instruction_text'),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: SpacingTokens.spaceSm),

                // Phase Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  child: LinearProgressIndicator(
                    value: state.phaseProgress,
                    minHeight: 5,
                    backgroundColor: colors.bgCanvasDeep,
                    valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceMd),

          // Player Navigation & Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous Zone
              IconButton(
                key: const Key('pmr_previous_zone_button'),
                icon: const Icon(AppIcons.chevronLeft),
                iconSize: IconSizeTokens.appAction,
                color: state.currentZoneIndex > 0
                    ? colors.textSecondary
                    : colors.textSecondary.withOpacity(0.3),
                tooltip: 'Previous Zone',
                onPressed: state.currentZoneIndex > 0
                    ? () => notifier.previousZone()
                    : null,
              ),
              const SizedBox(width: SpacingTokens.spaceSm),

              // Play / Pause Main Button
              FireflyButton(
                key: const Key('pmr_play_pause_button'),
                text: state.isActive ? 'Pause' : 'Begin',
                icon: state.isActive ? AppIcons.pause : AppIcons.play,
                onPressed: () => notifier.togglePlayPause(),
                variant: FireflyButtonVariant.primary,
              ),
              const SizedBox(width: SpacingTokens.spaceSm),

              // Skip / Next Zone
              IconButton(
                key: const Key('pmr_next_zone_button'),
                icon: const Icon(AppIcons.chevronRight),
                iconSize: IconSizeTokens.appAction,
                color: colors.textSecondary,
                tooltip: 'Next Zone',
                onPressed: () => notifier.nextZone(),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.spaceSm),

          // End Session Secondary
          FireflyButton(
            key: const Key('pmr_end_session_button'),
            text: 'End Session',
            onPressed: _handleExit,
            variant: FireflyButtonVariant.secondary,
          ),
          const SizedBox(height: SpacingTokens.spaceLg),
        ],
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, PmrController notifier) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.actionSage.withOpacity(0.15),
              ),
              child: Icon(
                AppIcons.checkCircle,
                size: IconSizeTokens.hero,
                color: colors.actionSage,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),
            Text(
              'Session Complete',
              key: const Key('pmr_complete_title'),
              style: AppTypography.displayMd.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceXs),
            Text(
              'Notice the stillness and heaviness across your body.\nTake this settled feeling with you.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceLg),
            FireflyButton(
              key: const Key('pmr_complete_return_home'),
              text: 'Return Home',
              onPressed: () => context.go(AppRoutes.checkIn),
              variant: FireflyButtonVariant.primary,
            ),
            const SizedBox(height: SpacingTokens.spaceSm),
            FireflyButton(
              key: const Key('pmr_repeat_session'),
              text: 'Repeat Exercise',
              onPressed: () => notifier.restart(),
              variant: FireflyButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
