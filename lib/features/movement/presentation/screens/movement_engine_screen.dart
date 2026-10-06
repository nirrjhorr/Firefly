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
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/data/movement_catalog.dart';
import '../../domain/models/movement_activity.dart';
import '../../domain/models/movement_session_state.dart';
import '../controllers/movement_session_controller.dart';
import '../widgets/movement_pulse_ring.dart';

/// Clinical and low-stimulation movement engine screen.
/// Supports active physical regulation, somatic release, and routine behavioral actions.
class MovementEngineScreen extends ConsumerStatefulWidget {
  final String? initialMode;
  final bool showSosOverlay;

  const MovementEngineScreen({
    super.key,
    this.initialMode,
    this.showSosOverlay = true,
  });

  @override
  ConsumerState<MovementEngineScreen> createState() => _MovementEngineScreenState();
}

class _MovementEngineScreenState extends ConsumerState<MovementEngineScreen> {
  late MovementType _selectedType;

  @override
  void initState() {
    super.initState();
    final initialActivity = MovementCatalog.findByIdOrMode(widget.initialMode);
    _selectedType = initialActivity.type;
  }

  Future<void> _handleExit() async {
    final controller = ref.read(movementSessionControllerProvider(widget.initialMode).notifier);
    final state = ref.read(movementSessionControllerProvider(widget.initialMode));
    controller.pause();

    // If user engaged for more than 5 seconds or completed, offer effectiveness feedback
    if (state.elapsedSeconds >= 5 || state.status.isDone) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: state.activity.id,
        stateAtStart: 'restless_or_low_energy',
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
    final typography = context.typography;
    final state = ref.watch(movementSessionControllerProvider(widget.initialMode));
    final controller = ref.read(movementSessionControllerProvider(widget.initialMode).notifier);
    final availableActivities = MovementCatalog.byType(_selectedType);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: colors.textPrimary),
          tooltip: 'Back',
          onPressed: _handleExit,
        ),
        title: Text(
          'Movement & Somatic Release',
          style: typography.titleMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.showSosOverlay)
            const Padding(
              padding: EdgeInsets.only(right: SpacingTokens.sm),
              child: SosOverlayButton(),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: SpacingTokens.xs),

              // Category Selector (Tabs)
              _buildCategorySelector(colors, typography, controller),

              const SizedBox(height: SpacingTokens.sm),

              // Horizontal activity list chips
              _buildActivityChips(availableActivities, state.activity, colors, typography, controller),

              const SizedBox(height: SpacingTokens.md),

              // Activity Header Info
              _buildActivityHeader(state.activity, colors, typography),

              const SizedBox(height: SpacingTokens.lg),

              // Rhythmic Pulse & Progress Ring
              MovementPulseRing(
                state: state,
                onTap: () {
                  if (state.status == MovementSessionStatus.active) {
                    controller.pause();
                  } else {
                    controller.start();
                  }
                },
              ),

              const SizedBox(height: SpacingTokens.lg),

              // Step Guidance Card
              if (state.activity.instructions.isNotEmpty)
                _buildInstructionCard(state, colors, typography, controller),

              // Sensory Anchor Callout
              if (state.activity.sensoryAnchor != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                _buildSensoryAnchorCard(state.activity.sensoryAnchor!, colors, typography),
              ],

              const SizedBox(height: SpacingTokens.lg),

              // Controls Bar (Play/Pause, Reset, Complete)
              _buildControlsBar(state, colors, controller),

              const SizedBox(height: SpacingTokens.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(
    AppColors colors,
    AppTypography typography,
    MovementSessionController controller,
  ) {
    const categories = [
      MovementType.activePhysical,
      MovementType.somaticRelease,
      MovementType.routineAction,
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.bgSurfaceElevated,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      padding: const EdgeInsets.all(SpacingTokens.xxs),
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == _selectedType;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedType != cat) {
                  setState(() => _selectedType = cat);
                  final firstInCat = MovementCatalog.byType(cat).first;
                  controller.selectActivity(firstInCat);
                }
              },
              child: AnimatedContainer(
                duration: AnimationTokens.fast,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
                decoration: BoxDecoration(
                  color: isSelected ? colors.actionSage.withOpacity(0.25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat.displayName,
                  textAlign: TextAlign.center,
                  style: typography.labelMedium.copyWith(
                    color: isSelected ? colors.textPrimary : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityChips(
    List<MovementActivity> activities,
    MovementActivity current,
    AppColors colors,
    AppTypography typography,
    MovementSessionController controller,
  ) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.xs),
        itemBuilder: (context, index) {
          final act = activities[index];
          final isSelected = act.id == current.id;
          return FilterChip(
            selected: isSelected,
            label: Text(act.title),
            labelStyle: typography.labelSmall.copyWith(
              color: isSelected ? colors.textPrimary : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            backgroundColor: colors.bgSurfaceElevated,
            selectedColor: colors.actionSage.withOpacity(0.35),
            checkmarkColor: colors.actionSage,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.full),
              side: BorderSide(
                color: isSelected ? colors.actionSage : colors.bgBorderSubtle,
                width: 1,
              ),
            ),
            onSelected: (_) {
              if (current.id != act.id) {
                controller.selectActivity(act);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityHeader(
    MovementActivity activity,
    AppColors colors,
    AppTypography typography,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Energy badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.bgSurfaceElevated,
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              child: Text(
                '⚡ Energy: ${activity.energyRequired}/3',
                style: typography.labelSmall.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(width: SpacingTokens.xs),
            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.bgSurfaceElevated,
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              child: Text(
                '⏱ ${activity.formattedDuration}',
                style: typography.labelSmall.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          activity.title,
          textAlign: TextAlign.center,
          style: typography.headlineMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        Text(
          activity.description,
          textAlign: TextAlign.center,
          style: typography.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard(
    MovementSessionState state,
    AppColors colors,
    AppTypography typography,
    MovementSessionController controller,
  ) {
    final instructions = state.activity.instructions;
    final currentIndex = state.currentStepIndex.clamp(0, instructions.length - 1);
    final instruction = instructions[currentIndex];

    return FireflyCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      backgroundColor: colors.bgSurfaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP ${currentIndex + 1} OF ${instructions.length}',
                style: typography.labelSmall.copyWith(
                  color: colors.actionSage,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(AppIcons.back, size: 18, color: currentIndex > 0 ? colors.textPrimary : colors.textTertiary),
                    onPressed: currentIndex > 0 ? controller.previousStep : null,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Previous step',
                  ),
                  IconButton(
                    icon: Icon(AppIcons.forward, size: 18, color: currentIndex < instructions.length - 1 ? colors.textPrimary : colors.textTertiary),
                    onPressed: currentIndex < instructions.length - 1 ? controller.nextStep : null,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Next step',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            instruction,
            style: typography.bodyLarge.copyWith(
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensoryAnchorCard(
    String anchor,
    AppColors colors,
    AppTypography typography,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        color: colors.bgSurfaceElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: colors.bgBorderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.sensory, size: 18, color: colors.actionSage),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: Text(
              anchor,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar(
    MovementSessionState state,
    AppColors colors,
    MovementSessionController controller,
  ) {
    final isRunning = state.status == MovementSessionStatus.active;
    final isDone = state.status == MovementSessionStatus.completed;

    return Row(
      children: [
        // Reset button
        IconButton.filledTonal(
          icon: Icon(AppIcons.restart, color: colors.textSecondary),
          tooltip: 'Reset',
          style: IconButton.styleFrom(
            backgroundColor: colors.bgSurfaceElevated,
            minimumSize: const Size(56, 56),
          ),
          onPressed: controller.reset,
        ),
        const SizedBox(width: SpacingTokens.sm),

        // Main Action Button (Play / Pause / Resume)
        Expanded(
          child: FireflyButton(
            text: isDone
                ? 'Finish'
                : isRunning
                    ? 'Pause'
                    : state.status == MovementSessionStatus.paused
                        ? 'Resume'
                        : 'Begin',
            icon: isDone
                ? AppIcons.check
                : isRunning
                    ? AppIcons.pause
                    : AppIcons.play,
            backgroundColor: isDone ? colors.actionSage : colors.actionSage,
            height: 56,
            onPressed: () {
              if (isDone) {
                _handleExit();
              } else if (isRunning) {
                controller.pause();
              } else {
                controller.start();
              }
            },
          ),
        ),

        const SizedBox(width: SpacingTokens.sm),

        // Done / That's enough button
        IconButton.filledTonal(
          icon: Icon(AppIcons.check, color: colors.actionSage),
          tooltip: 'That\'s enough for now',
          style: IconButton.styleFrom(
            backgroundColor: colors.bgSurfaceElevated,
            minimumSize: const Size(56, 56),
          ),
          onPressed: () {
            controller.complete();
            _handleExit();
          },
        ),
      ],
    );
  }
}
