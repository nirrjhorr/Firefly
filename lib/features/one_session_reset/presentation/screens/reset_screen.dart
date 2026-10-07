import 'dart:async';
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
import '../../domain/models/reset_distress_anchor.dart';
import '../../domain/models/reset_phase.dart';
import '../providers/reset_session_providers.dart';

/// Interactive Single-Session Intervention (SSI) screen executing the 5-step
/// One-Session Reset protocol (Anchor → Regulate → Reframe → Commit → Complete).
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _reframeController;
  Timer? _countdownTimer;
  int _secondsRemaining = 90;
  bool _isTimerActive = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _reframeController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _reframeController.dispose();
    super.dispose();
  }

  void _startRegulationTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerActive = true;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerActive = false;
        });
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _pauseRegulationTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final session = ref.watch(resetSessionProvider);
    final notifier = ref.read(resetSessionProvider.notifier);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: Column(
          children: [
            FireflyNavHeader(
              title: 'One-Session Reset',
              subtitle: session.currentPhase.title,
              onBackPressed: session.currentPhase.hasPrevious
                  ? () => notifier.previousPhase()
                  : () => context.pop(),
            ),
            _buildStepperIndicator(context, session.currentPhase),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.screenPaddingH,
                  vertical: SpacingTokens.spaceMd,
                ),
                child: _buildPhaseContent(context, session, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperIndicator(BuildContext context, ResetPhase currentPhase) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.spaceXs,
      ),
      child: Row(
        children: ResetPhase.values.map((phase) {
          final isCurrent = phase == currentPhase;
          final isPast = phase.stepNumber < currentPhase.stepNumber;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isPast || isCurrent
                    ? colors.actionSage
                    : colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context,
    dynamic session,
    ResetSessionNotifier notifier,
  ) {
    switch (session.currentPhase as ResetPhase) {
      case ResetPhase.anchor:
        return _buildAnchorPhase(context, session, notifier);
      case ResetPhase.regulate:
        return _buildRegulatePhase(context, session, notifier);
      case ResetPhase.reframe:
        return _buildReframePhase(context, session, notifier);
      case ResetPhase.commit:
        return _buildCommitPhase(context, session, notifier);
      case ResetPhase.complete:
        return _buildCompletePhase(context, session, notifier);
    }
  }

  // Phase 1: Name the Moment (Affect Labeling)
  Widget _buildAnchorPhase(
    BuildContext context,
    dynamic session,
    ResetSessionNotifier notifier,
  ) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What feels heaviest right now?',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: SpacingTokens.spaceXs),
        Text(
          ResetPhase.anchor.guidancePrompt,
          style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: SpacingTokens.spaceLg),
        ...ResetDistressAnchor.values.map((anchor) {
          final isSelected = session.anchor == anchor;
          return Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.spaceSm),
            child: FireflyCard(
              variant: FireflyCardVariant.interactive,
              padding: const EdgeInsets.all(SpacingTokens.cardPadding),
              backgroundColor: isSelected
                  ? colors.actionSage.withOpacity(0.12)
                  : colors.surfaceCard,
              borderColor: isSelected ? colors.actionSage : colors.borderSubtle,
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.selectAnchor(anchor);
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.actionSage.withOpacity(0.2)
                          : colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? Icons.check_rounded : _resolveAnchorIcon(anchor),
                        size: 20,
                        color: isSelected ? colors.actionSage : colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anchor.label,
                          style: AppTypography.bodyMd.copyWith(
                            color: colors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          anchor.subtitle,
                          style: AppTypography.captionSm.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: SpacingTokens.spaceLg),
        FireflyButton(
          text: 'Continue to Body Reset',
          onPressed: () {
            notifier.nextPhase();
            _startRegulationTimer();
          },
        ),
      ],
    );
  }

  // Phase 2: Autonomic Down-Regulation (90s Paced Cadence)
  Widget _buildRegulatePhase(
    BuildContext context,
    dynamic session,
    ResetSessionNotifier notifier,
  ) {
    final colors = context.colors;
    final technique = session.selectedTechnique ?? 'Autonomic Breath';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '90-Second Somatic Settle',
                style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: SpacingTokens.spaceXs),
              Text(
                'Technique: $technique. Let shoulders drop away from your ears.',
                style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceXl),

        // Animated Breathing/Settling Bloom
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.22);
            return Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.actionSage.withOpacity(0.12 * _pulseController.value + 0.08),
                border: Border.all(
                  color: colors.actionSage.withOpacity(0.4 * _pulseController.value + 0.3),
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.actionSage.withOpacity(0.25),
                    ),
                    child: Center(
                      child: Text(
                        '${_secondsRemaining}s',
                        style: AppTypography.headingMd.copyWith(
                          color: colors.actionSage,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: SpacingTokens.spaceLg),

        Text(
          _isTimerActive
              ? (_pulseController.status == AnimationStatus.forward
                  ? 'Breathe in slowly...'
                  : 'Gently release and let go...')
              : 'Paced timer paused',
          style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: SpacingTokens.spaceMd),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              icon: Icon(
                _isTimerActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: colors.actionSage,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                if (_isTimerActive) {
                  _pauseRegulationTimer();
                } else {
                  _startRegulationTimer();
                }
              },
            ),
            const SizedBox(width: SpacingTokens.spaceMd),
            TextButton(
              onPressed: () {
                _pauseRegulationTimer();
                setState(() => _secondsRemaining = 0);
              },
              child: Text(
                'Ready to continue',
                style: AppTypography.bodySm.copyWith(color: colors.actionSage),
              ),
            ),
          ],
        ),

        const SizedBox(height: SpacingTokens.spaceXl),
        FireflyButton(
          text: 'Continue to Perspective',
          onPressed: () {
            _pauseRegulationTimer();
            notifier.nextPhase();
          },
        ),
      ],
    );
  }

  // Phase 3: Compassionate Perspective (Reframe)
  Widget _buildReframePhase(
    BuildContext context,
    dynamic session,
    ResetSessionNotifier notifier,
  ) {
    final colors = context.colors;
    final presetReframes = [
      'This intensity is real, but it is temporary.',
      'I don’t have to solve my whole life tonight.',
      'I am allowed to rest without justifying it.',
      'Right now, breathing and being here is enough.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A Moment of Distance',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: SpacingTokens.spaceXs),
        Text(
          'If someone you deeply cared about was right here feeling this, what gentle reassurance would you whisper to them?',
          style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: SpacingTokens.spaceLg),

        // Quick comfort chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetReframes.map((prompt) {
            final isSelected = session.reframeReflection == prompt;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _reframeController.text = prompt;
                notifier.setReframe(prompt);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.actionSage.withOpacity(0.18)
                      : colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(RadiusTokens.radiusPill),
                  border: Border.all(
                    color: isSelected ? colors.actionSage : colors.borderSubtle,
                  ),
                ),
                child: Text(
                  prompt,
                  style: AppTypography.bodySm.copyWith(
                    color: isSelected ? colors.actionSage : colors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: SpacingTokens.spaceMd),

        // Optional custom note
        TextField(
          controller: _reframeController,
          maxLines: 3,
          style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Or write your own quiet reminder...',
            hintStyle: AppTypography.bodySm.copyWith(color: colors.textTertiary),
            filled: true,
            fillColor: colors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
              borderSide: BorderSide(color: colors.actionSage),
            ),
          ),
          onChanged: (val) => notifier.setReframe(val),
        ),
        const SizedBox(height: SpacingTokens.spaceXl),

        FireflyButton(
          text: 'Continue to One Small Step',
          onPressed: () => notifier.nextPhase(),
        ),
      ],
    );
  }

  // Phase 4: Single Micro-Commitment
  Widget _buildCommitPhase(
    BuildContext context,
    dynamic session,
    ResetSessionNotifier notifier,
  ) {
    final colors = context.colors;
    final commitments = [
      'Drink one cool glass of water',
      'Step outside or open a window for cool air',
      'Wash hands or face with soothing water',
      'Turn off overhead lights and lie down',
      'Put phone on do-not-disturb for 30 minutes',
      'Make one warm cup of tea',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'One Small Real-World Act',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: SpacingTokens.spaceXs),
        Text(
          'Agency returns in tiny drops. Choose one 2-minute act of care to carry out after leaving this screen.',
          style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: SpacingTokens.spaceLg),

        ...commitments.map((item) {
          final isSelected = session.microCommitment == item;
          return Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.spaceSm),
            child: FireflyCard(
              variant: FireflyCardVariant.interactive,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              backgroundColor: isSelected
                  ? colors.actionSage.withOpacity(0.12)
                  : colors.surfaceCard,
              borderColor: isSelected ? colors.actionSage : colors.borderSubtle,
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.setCommitment(item);
              },
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
                    size: 20,
                    color: isSelected ? colors.actionSage : colors.textTertiary,
                  ),
                  const SizedBox(width: SpacingTokens.spaceMd),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: SpacingTokens.spaceLg),

        FireflyButton(
          text: 'Complete Sanctuary Reset',
          onPressed: () => notifier.nextPhase(),
        ),
      ],
    );
  }

  // Phase 5: Sanctuary Close & Post-Session Shift Check
  Widget _buildCompletePhase(
    BuildContext context,
    dynamic session,
    ResetSessionNotifier notifier,
  ) {
    final colors = context.colors;
    final shiftOptions = [
      {'val': 'muchBetter', 'label': 'Much better', 'icon': Icons.sentiment_very_satisfied_rounded},
      {'val': 'aLittleBetter', 'label': 'A little lighter', 'icon': Icons.sentiment_satisfied_rounded},
      {'val': 'same', 'label': 'About the same', 'icon': Icons.sentiment_neutral_rounded},
      {'val': 'heavier', 'label': 'Still heavy', 'icon': Icons.sentiment_dissatisfied_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: SpacingTokens.spaceLg),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colors.actionSage.withOpacity(0.16),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.spa_rounded,
              size: 36,
              color: colors.actionSage,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceMd),

        Text(
          'You Paused and Showed Up',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.spaceXs),
        Text(
          'In a world that rushes, giving yourself 5 minutes of quiet regulation is an act of quiet courage.',
          style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.spaceXl),

        // Before-and-After feedback
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'How is your nervous system feeling now?',
            style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: SpacingTokens.spaceSm),

        ...shiftOptions.map((opt) {
          final isSelected = session.effectivenessRating == opt['val'];
          return Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.spaceSm),
            child: FireflyCard(
              variant: FireflyCardVariant.interactive,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: isSelected
                  ? colors.actionSage.withOpacity(0.12)
                  : colors.surfaceCard,
              borderColor: isSelected ? colors.actionSage : colors.borderSubtle,
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.completeSession(opt['val'] as String);
              },
              child: Row(
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    size: 22,
                    color: isSelected ? colors.actionSage : colors.textSecondary,
                  ),
                  const SizedBox(width: SpacingTokens.spaceMd),
                  Expanded(
                    child: Text(
                      opt['label'] as String,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_rounded, size: 18, color: colors.actionSage),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: SpacingTokens.spaceLg),

        FireflyButton(
          text: 'Return Home',
          onPressed: () {
            notifier.restart();
            context.go(AppRoutes.home);
          },
        ),
        const SizedBox(height: SpacingTokens.spaceSm),
        FireflyButton(
          text: 'Open Safety Plan',
          variant: FireflyButtonVariant.secondary,
          onPressed: () => context.push(AppRoutes.safetyPlan),
        ),
      ],
    );
  }

  IconData _resolveAnchorIcon(ResetDistressAnchor anchor) {
    switch (anchor) {
      case ResetDistressAnchor.racingThoughts:
        return Icons.psychology_outlined;
      case ResetDistressAnchor.physicalTension:
        return Icons.air_rounded;
      case ResetDistressAnchor.heavyInertia:
        return Icons.directions_walk_rounded;
      case ResetDistressAnchor.sensoryOverwhelm:
        return Icons.touch_app_outlined;
      case ResetDistressAnchor.lonelinessDread:
        return Icons.favorite_border_rounded;
      case ResetDistressAnchor.generalDistress:
        return Icons.auto_awesome_rounded;
    }
  }
}
