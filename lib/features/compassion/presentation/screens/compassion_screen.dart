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
import '../../domain/models/compassion_exercise_type.dart';
import '../../domain/models/self_compassion_component.dart';
import '../providers/compassion_providers.dart';

/// Screen executing Kristin Neff's evidence-based Self-Compassion Break
/// and Interactive Thought Untangler for shame and self-criticism relief.
class CompassionScreen extends ConsumerStatefulWidget {
  const CompassionScreen({super.key});

  @override
  ConsumerState<CompassionScreen> createState() => _CompassionScreenState();
}

class _CompassionScreenState extends ConsumerState<CompassionScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _triggerController;
  late final TextEditingController _criticController;
  late final TextEditingController _reframeController;
  late final AnimationController _soothingPulseController;

  @override
  void initState() {
    super.initState();
    _triggerController = TextEditingController();
    _criticController = TextEditingController();
    _reframeController = TextEditingController();
    _soothingPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _triggerController.dispose();
    _criticController.dispose();
    _reframeController.dispose();
    _soothingPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compassionNotifierProvider);
    final notifier = ref.read(compassionNotifierProvider.notifier);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                FireflyNavHeader(
                  title: state.isCompleted
                      ? 'Sanctuary Close'
                      : state.exerciseType ==
                              CompassionExerciseType.selfCompassionBreak
                          ? 'Self-Compassion Break'
                          : 'Thought Untangler',
                  subtitle: state.isCompleted
                      ? 'You met yourself with gentleness'
                      : 'Neff 3-Component Practice',
                  onBackPressed: () {
                    if (state.hasPreviousStep) {
                      notifier.previousStep();
                    } else if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                ),
                if (!state.isCompleted) ...[
                  // Exercise Type Pill Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.lg,
                      vertical: SpacingTokens.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ExerciseToggleChip(
                            label: 'Compassion Break',
                            icon: AppIcons.heart,
                            isSelected: state.exerciseType ==
                                CompassionExerciseType.selfCompassionBreak,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.selectExercise(
                                CompassionExerciseType.selfCompassionBreak,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: _ExerciseToggleChip(
                            label: 'Thought Untangler',
                            icon: AppIcons.notes,
                            isSelected: state.exerciseType ==
                                CompassionExerciseType.thoughtUntangler,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.selectExercise(
                                CompassionExerciseType.thoughtUntangler,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3-Step Stepper Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.lg,
                      vertical: SpacingTokens.sm,
                    ),
                    child: Row(
                      children: List.generate(state.totalSteps, (index) {
                        final isActive = index <= state.currentStep;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                              right:
                                  index < state.totalSteps - 1 ? SpacingTokens.xs : 0,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? colors.accentPrimary
                                  : colors.borderSubtle,
                              borderRadius: BorderRadius.circular(RadiusTokens.pill),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],

                // Dynamic Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: state.isCompleted
                        ? _buildCompletionView(context, state, notifier)
                        : state.exerciseType ==
                                CompassionExerciseType.selfCompassionBreak
                            ? _buildCompassionBreakStep(context, state, notifier)
                            : _buildThoughtUntanglerStep(
                                context, state, notifier),
                  ),
                ),

                // Bottom Action Footer
                if (!state.isCompleted)
                  _buildBottomBar(context, state, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassionBreakStep(
    BuildContext context,
    CompassionState state,
    CompassionNotifier notifier,
  ) {
    final colors = context.colors;
    final step = state.currentStep;

    switch (step) {
      case 0:
        // Step 1: Mindfulness (Acknowledge What Hurts)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepHeader(
              badge: 'Step 1 of 3: Mindfulness',
              title: 'This is a moment of difficulty.',
              description: SelfCompassionComponent.mindfulness.description,
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Pulsing Soothing Aura
            Center(
              child: AnimatedBuilder(
                animation: _soothingPulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_soothingPulseController.value * 0.12);
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.accentSecondary.withAlpha(60),
                          colors.accentPrimary.withAlpha(20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Icon(
                          AppIcons.heart,
                          size: 48,
                          color: colors.accentPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            FireflyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Somatic Awareness Prompt',
                    style: AppTypography.labelMd.copyWith(
                      color: colors.accentWarmth,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    SelfCompassionComponent.mindfulness.somaticPrompt,
                    style: AppTypography.bodyMd.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),

            Text(
              'Acknowledge what feels heavy right now:',
              style: AppTypography.labelSm.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                _RefinementChip(
                  label: 'This hurts right now.',
                  onTap: () => notifier.updateTriggerInput('This hurts right now.'),
                ),
                _RefinementChip(
                  label: 'I feel exhausted and overwhelmed.',
                  onTap: () =>
                      notifier.updateTriggerInput('I feel exhausted and overwhelmed.'),
                ),
                _RefinementChip(
                  label: 'I am carrying a lot today.',
                  onTap: () => notifier.updateTriggerInput('I am carrying a lot today.'),
                ),
              ],
            ),
          ],
        );

      case 1:
        // Step 2: Common Humanity (You Are Not Alone)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepHeader(
              badge: 'Step 2 of 3: Common Humanity',
              title: 'Difficulty is part of being human.',
              description: SelfCompassionComponent.commonHumanity.description,
            ),
            const SizedBox(height: SpacingTokens.lg),

            FireflyCard(
              backgroundColor: colors.bgSurfaceRaised,
              child: Column(
                children: [
                  Icon(
                    AppIcons.earth,
                    size: 40,
                    color: colors.accentSecondary,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'You are not uniquely flawed.',
                    style: AppTypography.headingSm.copyWith(
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'Millions of thoughtful, good people feel this exact self-doubt, sadness, or exhaustion today. It is not evidence of failure — it is proof that you care and feel deeply.',
                    style: AppTypography.bodySm.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),

            FireflyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grounding Truth',
                    style: AppTypography.labelMd.copyWith(
                      color: colors.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    SelfCompassionComponent.commonHumanity.somaticPrompt,
                    style: AppTypography.bodyMd.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 2:
      default:
        // Step 3: Self-Kindness (Soothing Touch & Warm Words)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepHeader(
              badge: 'Step 3 of 3: Self-Kindness',
              title: 'May I be gentle with myself.',
              description: SelfCompassionComponent.selfKindness.description,
            ),
            const SizedBox(height: SpacingTokens.lg),

            FireflyCard(
              backgroundColor: colors.bgSurfaceRaised,
              child: Row(
                children: [
                  Icon(
                    AppIcons.handHoldingHeart,
                    size: 32,
                    color: colors.accentWarmth,
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Text(
                      'Somatic Soothing: Place one warm hand gently over your heart or belly. Feel the comforting weight of your touch.',
                      style: AppTypography.bodySm.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),

            Text(
              'Choose words of kindness to offer yourself:',
              style: AppTypography.labelSm.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                _RefinementChip(
                  label: 'May I be gentle with myself right now.',
                  onTap: () => notifier.updateReframeInput(
                      'May I be gentle with myself right now.'),
                ),
                _RefinementChip(
                  label: 'I am doing the best I can with what I have.',
                  onTap: () => notifier.updateReframeInput(
                      'I am doing the best I can with what I have.'),
                ),
                _RefinementChip(
                  label: 'May I accept myself just as I am today.',
                  onTap: () => notifier.updateReframeInput(
                      'May I accept myself just as I am today.'),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildThoughtUntanglerStep(
    BuildContext context,
    CompassionState state,
    CompassionNotifier notifier,
  ) {
    final colors = context.colors;
    final step = state.currentStep;

    switch (step) {
      case 0:
        // Step 1: Externalize the Harsh Voice
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              badge: 'Step 1 of 3: Externalize the Critic',
              title: 'What is the harsh voice saying?',
              description:
                  'Putting words to your internal critic removes its silent power. Write down what it claims happened.',
            ),
            const SizedBox(height: SpacingTokens.lg),

            TextField(
              controller: _criticController,
              onChanged: notifier.updateCriticInput,
              maxLines: 4,
              style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. I messed everything up and let everyone down...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary.withAlpha(150),
                ),
                filled: true,
                fillColor: colors.bgSurfaceRaised,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.container),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.container),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.container),
                  borderSide: BorderSide(color: colors.accentPrimary),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),

            Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                _RefinementChip(
                  label: "I'm not doing enough.",
                  onTap: () {
                    _criticController.text = "I'm not doing enough.";
                    notifier.updateCriticInput("I'm not doing enough.");
                  },
                ),
                _RefinementChip(
                  label: 'I should have known better.',
                  onTap: () {
                    _criticController.text = 'I should have known better.';
                    notifier.updateCriticInput('I should have known better.');
                  },
                ),
                _RefinementChip(
                  label: 'I ruined everything.',
                  onTap: () {
                    _criticController.text = 'I ruined everything.';
                    notifier.updateCriticInput('I ruined everything.');
                  },
                ),
              ],
            ),
          ],
        );

      case 1:
        // Step 2: Reality Check & Common Humanity
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              badge: 'Step 2 of 3: Human Reality Check',
              title: 'Is this 100% objective truth?',
              description:
                  'Thoughts are mental weather, not absolute facts. Notice the exaggeration and perfectionist standards.',
            ),
            const SizedBox(height: SpacingTokens.lg),

            FireflyCard(
              backgroundColor: colors.bgSurfaceRaised,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What the critic said:',
                    style: AppTypography.labelXs.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xxs),
                  Text(
                    state.criticInput.isNotEmpty
                        ? '"${state.criticInput}"'
                        : '"I am not doing enough."',
                    style: AppTypography.bodyMd.copyWith(
                      color: colors.accentWarmth,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),

            Text(
              'Acknowledge these gentle realities:',
              style: AppTypography.labelSm.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            FireflyCard(
              child: Column(
                children: [
                  _CheckPoint(
                    text: 'One difficult moment does not erase my worth or effort.',
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  _CheckPoint(
                    text: 'Exhaustion makes challenges feel 10x larger than they are.',
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  _CheckPoint(
                    text: 'Every single human makes errors when under stress.',
                  ),
                ],
              ),
            ),
          ],
        );

      case 2:
      default:
        // Step 3: Words to a Beloved Friend
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              badge: 'Step 3 of 3: Compassionate Reframe',
              title: 'What would you say to a dear friend?',
              description:
                  'If someone you love came to you with this exact mistake, what kind, steady words would you offer them?',
            ),
            const SizedBox(height: SpacingTokens.lg),

            TextField(
              controller: _reframeController,
              onChanged: notifier.updateReframeInput,
              maxLines: 4,
              style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText:
                    'e.g. You did the best you could under heavy stress. Breathe. You are safe.',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary.withAlpha(150),
                ),
                filled: true,
                fillColor: colors.bgSurfaceRaised,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.container),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.container),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.container),
                  borderSide: BorderSide(color: colors.accentPrimary),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),

            Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                _RefinementChip(
                  label: 'You are human, and you are allowed to learn.',
                  onTap: () {
                    _reframeController.text =
                        'You are human, and you are allowed to learn.';
                    notifier.updateReframeInput(
                        'You are human, and you are allowed to learn.');
                  },
                ),
                _RefinementChip(
                  label: 'Take a breath. You are doing okay.',
                  onTap: () {
                    _reframeController.text =
                        'Take a breath. You are doing okay.';
                    notifier.updateReframeInput(
                        'Take a breath. You are doing okay.');
                  },
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildCompletionView(
    BuildContext context,
    CompassionState state,
    CompassionNotifier notifier,
  ) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: SpacingTokens.lg),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accentPrimary.withAlpha(30),
              border: Border.all(
                color: colors.accentPrimary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 40,
              color: colors.accentPrimary,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),

        Text(
          'You showed up with kindness.',
          style: AppTypography.headingMd.copyWith(
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Self-compassion is not about fixing everything. It is about treating yourself like a friend while things are hard.',
          style: AppTypography.bodyMd.copyWith(
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.xl),

        FireflyCard(
          backgroundColor: colors.bgSurfaceRaised,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How settled does your body feel now?',
                style: AppTypography.labelMd.copyWith(
                  color: colors.accentWarmth,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final rating = index + 1;
                  final isSelected =
                      state.session.postDistressRating == rating;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      notifier.setPostDistress(rating);
                    },
                    borderRadius: BorderRadius.circular(RadiusTokens.full),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? colors.accentPrimary
                            : colors.borderSubtle,
                      ),
                      child: Center(
                        child: Text(
                          '$rating',
                          style: AppTypography.labelMd.copyWith(
                            color: isSelected
                                ? colors.bgCanvas
                                : colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.xxl),

        FireflyButton(
          label: 'Return to Sanctuary',
          onPressed: () {
            HapticFeedback.lightImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CompassionState state,
    CompassionNotifier notifier,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          if (state.hasPreviousStep) ...[
            Expanded(
              flex: 1,
              child: FireflyButton(
                label: 'Previous',
                variant: FireflyButtonVariant.secondary,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.previousStep();
                },
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
          ],
          Expanded(
            flex: 2,
            child: FireflyButton(
              label: state.isLastStep ? 'Complete Practice' : 'Continue',
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.nextStep();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.badge,
    required this.title,
    required this.description,
  });

  final String badge;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xxs,
          ),
          decoration: BoxDecoration(
            color: colors.accentPrimary.withAlpha(30),
            borderRadius: BorderRadius.circular(RadiusTokens.pill),
          ),
          child: Text(
            badge,
            style: AppTypography.labelXs.copyWith(
              color: colors.accentPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          title,
          style: AppTypography.headingMd.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        Text(
          description,
          style: AppTypography.bodySm.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ExerciseToggleChip extends StatelessWidget {
  const _ExerciseToggleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.container),
        child: AnimatedContainer(
          duration: AnimationTokens.normal,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? colors.bgSurfaceRaised : colors.bgSurface,
            borderRadius: BorderRadius.circular(RadiusTokens.container),
            border: Border.all(
              color: isSelected ? colors.accentPrimary : colors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.accentPrimary : colors.textSecondary,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelSm.copyWith(
                    color: isSelected
                        ? colors.textPrimary
                        : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefinementChip extends StatelessWidget {
  const _RefinementChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(RadiusTokens.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurfaceRaised,
          borderRadius: BorderRadius.circular(RadiusTokens.pill),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: colors.accentPrimary,
          ),
        ),
      ),
    );
  }
}

class _CheckPoint extends StatelessWidget {
  const _CheckPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 18,
          color: colors.accentPrimary,
        ),
        const SizedBox(width: SpacingTokens.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySm.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
