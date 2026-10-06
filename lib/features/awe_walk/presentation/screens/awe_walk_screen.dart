import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../shared/widgets/firefly_nav_header.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/awe_prompt.dart';
import '../../domain/models/awe_walk_phase.dart';
import '../../domain/models/awe_walk_session.dart';
import '../providers/awe_walk_providers.dart';

/// Interactive guided Awe Walk screen operationalizing Virginia Sturm et al. 2020 (Emotion).
/// Low-stimulation outdoor walking companion facilitating outward attention, vastness,
/// and the calming shift to the 'small self'.
class AweWalkScreen extends ConsumerStatefulWidget {
  const AweWalkScreen({
    super.key,
    this.initialDurationMinutes = 10,
    this.showSosOverlay = true,
  });

  final int initialDurationMinutes;
  final bool showSosOverlay;

  @override
  ConsumerState<AweWalkScreen> createState() => _AweWalkScreenState();
}

class _AweWalkScreenState extends ConsumerState<AweWalkScreen> {
  late final TextEditingController _anchorNoteController;

  @override
  void initState() {
    super.initState();
    _anchorNoteController = TextEditingController();
  }

  @override
  void dispose() {
    _anchorNoteController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleExit(AweWalkSession session) async {
    if (session.elapsedSeconds > 30 || session.isComplete) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_awe_walk',
        stateAtStart: 'racingThoughts',
        durationSeconds: session.elapsedSeconds > 0 ? session.elapsedSeconds : 60,
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
    final session = ref.watch(aweWalkSessionProvider);
    final notifier = ref.read(aweWalkSessionProvider.notifier);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                FireflyNavHeader(
                  title: 'Awe Walk Protocol',
                  subtitle: session.currentPhase.title,
                  onBackPressed: () => _handleExit(session),
                ),
                _buildPhaseProgressBar(context, session),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.screenPaddingH,
                      vertical: SpacingTokens.spaceMd,
                    ),
                    child: AnimatedSwitcher(
                      duration: MotionTokens.screenTransition,
                      switchInCurve: MotionTokens.standardCurve,
                      child: _buildPhaseContent(context, session, notifier),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.showSosOverlay)
              const Positioned(
                bottom: SpacingTokens.spaceLg,
                right: SpacingTokens.screenPaddingH,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseProgressBar(BuildContext context, AweWalkSession session) {
    final colors = context.colors;
    final phases = [
      AweWalkPhase.preparation,
      AweWalkPhase.vastness,
      AweWalkPhase.smallSelf,
      AweWalkPhase.gratitude,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.spaceXs,
      ),
      child: Row(
        children: phases.map((phase) {
          final isCurrent = session.currentPhase == phase;
          final isPast = session.currentPhase.stepNumber > phase.stepNumber ||
              session.currentPhase == AweWalkPhase.complete;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isCurrent
                    ? colors.actionSage
                    : (isPast
                        ? colors.actionSage.withOpacity(0.5)
                        : colors.borderSubtle),
                borderRadius: BorderRadius.circular(RadiusTokens.radiusPill),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context,
    AweWalkSession session,
    AweWalkNotifier notifier,
  ) {
    switch (session.currentPhase) {
      case AweWalkPhase.preparation:
        return _buildPreparationView(context, session, notifier);
      case AweWalkPhase.vastness:
      case AweWalkPhase.smallSelf:
        return _buildActiveWalkView(context, session, notifier);
      case AweWalkPhase.gratitude:
        return _buildGratitudeAnchorView(context, session, notifier);
      case AweWalkPhase.complete:
        return _buildCompletionView(context, session, notifier);
    }
  }

  Widget _buildPreparationView(
    BuildContext context,
    AweWalkSession session,
    AweWalkNotifier notifier,
  ) {
    final colors = context.colors;

    return Column(
      key: const ValueKey('awe_prep'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FireflyCard(
          backgroundColor: colors.bgSurface,
          padding: const EdgeInsets.all(SpacingTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.actionSage.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.park_outlined,
                        color: colors.actionSage,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Science of Awe',
                          style: AppTypography.headingMd.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Sturm et al. 2020 RCT (Emotion)',
                          style: AppTypography.captionSm.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.spaceMd),
              Text(
                'Walking outdoors with an explicit instruction to seek vastness and wonder reduces rumination, calms autonomic distress, and inspires the comforting "small self" perspective.',
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceLg),
        Text(
          'Choose Paced Duration',
          style: AppTypography.labelMd.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceSm),
        Row(
          children: [5, 10, 15].map((minutes) {
            final isSelected = session.targetDurationMinutes == minutes;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.setDuration(minutes);
                  },
                  child: AnimatedContainer(
                    duration: MotionTokens.quick,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.actionSage.withOpacity(0.16)
                          : colors.bgSurface,
                      borderRadius:
                          BorderRadius.circular(RadiusTokens.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? colors.actionSage
                            : colors.borderSubtle,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$minutes min',
                          style: AppTypography.labelMd.copyWith(
                            color: isSelected
                                ? colors.actionSage
                                : colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          minutes == 5
                              ? 'Brief reset'
                              : (minutes == 10 ? 'Optimal RCT' : 'Deep stroll'),
                          style: AppTypography.captionSm.copyWith(
                            color: colors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: SpacingTokens.spaceLg),
        FireflyCard(
          backgroundColor: colors.bgSurface,
          padding: const EdgeInsets.all(SpacingTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Before you step out:',
                style: AppTypography.labelMd.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceSm),
              _buildGuidanceBullet(
                context,
                icon: Icons.notifications_off_outlined,
                text: 'Put your phone on silent. Let it rest in your hand or pocket.',
              ),
              const SizedBox(height: SpacingTokens.spaceXs),
              _buildGuidanceBullet(
                context,
                icon: Icons.remove_red_eye_outlined,
                text: 'Lift your chin slightly. Expand your gaze past the ground.',
              ),
              const SizedBox(height: SpacingTokens.spaceXs),
              _buildGuidanceBullet(
                context,
                icon: Icons.air_rounded,
                text: 'There is no pace requirement. Walk as slowly as you like.',
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceXl),
        FireflyButton(
          text: 'Begin Outdoor Walk',
          icon: Icons.directions_walk_rounded,
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.nextPhase();
          },
        ),
      ],
    );
  }

  Widget _buildGuidanceBullet(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.actionSage),
        const SizedBox(width: SpacingTokens.spaceSm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.captionSm.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveWalkView(
    BuildContext context,
    AweWalkSession session,
    AweWalkNotifier notifier,
  ) {
    final colors = context.colors;
    final currentPrompt = notifier.currentPrompt;
    final elapsedText = _formatDuration(session.elapsedSeconds);
    final targetText = _formatDuration(session.totalTargetSeconds);

    return Column(
      key: ValueKey('awe_active_${session.currentPhase.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Paced Timer & Progress Card
        FireflyCard(
          backgroundColor: colors.bgSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.spaceLg,
            vertical: SpacingTokens.spaceMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WALK IN PROGRESS',
                    style: AppTypography.captionSm.copyWith(
                      color: colors.textMuted,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$elapsedText / $targetText',
                    style: AppTypography.headingMd.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  notifier.togglePause();
                },
                icon: Icon(
                  session.isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: colors.actionSage,
                  size: 28,
                ),
                tooltip: session.isPaused ? 'Resume' : 'Pause',
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceMd),

        // Observational Prompt Card
        FireflyCard(
          backgroundColor: colors.bgSurface,
          padding: const EdgeInsets.all(SpacingTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.actionSage.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(RadiusTokens.radiusPill),
                    ),
                    child: Text(
                      currentPrompt.modality.displayName.toUpperCase(),
                      style: AppTypography.captionSm.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    'Prompt ${session.activePromptIndex + 1} of ${notifier.prompts.length}',
                    style: AppTypography.captionSm.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.spaceMd),
              Text(
                currentPrompt.title,
                style: AppTypography.headingLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceSm),
              Text(
                currentPrompt.instruction,
                style: AppTypography.bodyLg.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceLg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SpacingTokens.spaceMd),
                decoration: BoxDecoration(
                  color: colors.bgCanvasDeep,
                  borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                  border: Border.all(
                    color: colors.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERSPECTIVE SHIFT',
                      style: AppTypography.captionSm.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentPrompt.reflectionCue,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceMd),

        // Prompt Cycle Controls
        Row(
          children: [
            Expanded(
              child: FireflyButton(
                text: 'Previous Cue',
                variant: FireflyButtonVariant.secondary,
                onPressed: session.activePromptIndex > 0
                    ? () {
                        HapticFeedback.selectionClick();
                        notifier.previousPrompt();
                      }
                    : null,
              ),
            ),
            const SizedBox(width: SpacingTokens.spaceSm),
            Expanded(
              child: FireflyButton(
                text: 'Next Cue',
                variant: FireflyButtonVariant.secondary,
                onPressed: session.activePromptIndex < notifier.prompts.length - 1
                    ? () {
                        HapticFeedback.selectionClick();
                        notifier.markCurrentPromptComplete();
                        notifier.nextPrompt();
                      }
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.spaceLg),

        // Phase Advance Button
        FireflyButton(
          text: session.currentPhase == AweWalkPhase.vastness
              ? 'Shift to Small Self (${AweWalkPhase.smallSelf.shortLabel})'
              : 'Proceed to Sensory Anchor',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.markCurrentPromptComplete();
            notifier.nextPhase();
          },
        ),
      ],
    );
  }

  Widget _buildGratitudeAnchorView(
    BuildContext context,
    AweWalkSession session,
    AweWalkNotifier notifier,
  ) {
    final colors = context.colors;

    return Column(
      key: const ValueKey('awe_anchor'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FireflyCard(
          backgroundColor: colors.bgSurface,
          padding: const EdgeInsets.all(SpacingTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sensory Anchor',
                style: AppTypography.headingMd.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceSm),
              Text(
                'Before returning indoors, choose one single sight, sound, or natural pattern you noticed today. This detail acts as your grounded memory anchor.',
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceLg),
              TextField(
                controller: _anchorNoteController,
                onChanged: notifier.setAnchorDetail,
                maxLines: 3,
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Amber veins on a fallen maple leaf, wind rustling the high pine branches...',
                  hintStyle: AppTypography.bodyMd.copyWith(
                    color: colors.textMuted,
                  ),
                  filled: true,
                  fillColor: colors.bgCanvasDeep,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                    borderSide: BorderSide(color: colors.actionSage),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceXl),
        FireflyButton(
          text: 'Complete Walk & Settle',
          icon: Icons.check_circle_outline_rounded,
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.completeWalk();
          },
        ),
      ],
    );
  }

  Widget _buildCompletionView(
    BuildContext context,
    AweWalkSession session,
    AweWalkNotifier notifier,
  ) {
    final colors = context.colors;
    final minutes = (session.elapsedSeconds / 60).ceil();

    return Column(
      key: const ValueKey('awe_complete'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FireflyCard(
          backgroundColor: colors.bgSurface,
          padding: const EdgeInsets.all(SpacingTokens.cardPadding),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.actionSage.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.spa_rounded,
                    color: colors.actionSage,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceMd),
              Text(
                'Walk Completed',
                style: AppTypography.headingLg.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceSm),
              Text(
                'You gave your mind and body ${minutes > 0 ? minutes : 1} minute(s) of spacious perspective. Your worries were allowed to become small.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              if (session.anchorDetail != null &&
                  session.anchorDetail!.trim().isNotEmpty) ...[
                const SizedBox(height: SpacingTokens.spaceMd),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SpacingTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: colors.bgCanvasDeep,
                    borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Text(
                    'Anchor: "${session.anchorDetail}"',
                    style: AppTypography.captionSm.copyWith(
                      color: colors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceLg),
        FireflyButton(
          text: 'Rate Settledness (Shift)',
          icon: Icons.rate_review_outlined,
          onPressed: () => _handleExit(session),
        ),
        const SizedBox(height: SpacingTokens.spaceSm),
        FireflyButton(
          text: 'Return to Sanctuary',
          variant: FireflyButtonVariant.secondary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.checkIn);
            }
          },
        ),
      ],
    );
  }
}
