import 'dart:math' as math;
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
import '../../domain/models/focus_mode.dart';
import '../../domain/models/focus_priority.dart';
import '../providers/focus_providers.dart';

/// Screen executing the Focus & Mental Organisation suite:
/// - Three Priorities (Rule of 3 cognitive throttling)
/// - Brain Dump (Externalization of mental clutter)
/// - Serene Focus Companion (Low-stimulation, non-punitive interval timer)
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({
    super.key,
    this.initialMode,
  });

  final String? initialMode;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _priorityInputController;
  late final TextEditingController _brainDumpInputController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _priorityInputController = TextEditingController();
    _brainDumpInputController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    if (widget.initialMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mode = widget.initialMode?.toLowerCase();
        if (mode == 'braindump') {
          ref.read(focusNotifierProvider.notifier).setMode(FocusMode.brainDump);
        } else if (mode == 'focustimer' || mode == 'timer') {
          ref.read(focusNotifierProvider.notifier).setMode(FocusMode.focusTimer);
        } else {
          ref.read(focusNotifierProvider.notifier).setMode(FocusMode.threePriorities);
        }
      });
    }
  }

  @override
  void dispose() {
    _priorityInputController.dispose();
    _brainDumpInputController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusNotifierProvider);
    final notifier = ref.read(focusNotifierProvider.notifier);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                FireflyNavHeader(
                  title: state.mode.displayName,
                  subtitle: state.mode.subtitle,
                  onBackPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                ),

                // Mode Selector Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.xs,
                  ),
                  child: Row(
                    children: [
                      for (final mode in FocusMode.values)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _buildModeTab(
                              context: context,
                              mode: mode,
                              isSelected: state.mode == mode,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                notifier.setMode(mode);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: SpacingTokens.sm),

                // Main Content View according to active mode
                Expanded(
                  child: AnimatedSwitcher(
                    duration: MotionTokens.normal,
                    switchInCurve: MotionTokens.emphasizedCurve,
                    child: switch (state.mode) {
                      FocusMode.threePriorities => _buildThreePrioritiesView(context, state, notifier),
                      FocusMode.focusTimer => _buildFocusTimerView(context, state, notifier),
                      FocusMode.brainDump => _buildBrainDumpView(context, state, notifier),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required BuildContext context,
    required FocusMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: MotionTokens.fast,
        curve: MotionTokens.standardCurve,
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm,
          horizontal: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary.withOpacity(0.18)
              : colors.bgSurface,
          borderRadius: BorderRadius.circular(RadiusTokens.full),
          border: Border.all(
            color: isSelected
                ? colors.accentPrimary.withOpacity(0.4)
                : colors.borderSubtle.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            mode.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected ? colors.accentPrimary : colors.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. THREE PRIORITIES VIEW (RULE OF 3)
  // ===========================================================================

  Widget _buildThreePrioritiesView(
    BuildContext context,
    FocusState state,
    FocusNotifier notifier,
  ) {
    final colors = context.colors;

    return ListView(
      key: const ValueKey('three_priorities_view'),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.sm,
      ),
      children: [
        // Cognitive load reassurance banner
        FireflyCard(
          backgroundColor: colors.bgSurface.withOpacity(0.7),
          borderColor: colors.borderSubtle.withOpacity(0.3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.sparkles,
                color: colors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  'When executive function is low, hold at most three small intentions. Complete or release one before inviting another.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: SpacingTokens.lg),

        // Section header & slot counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Three Slots',
              style: AppTypography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: BorderRadius.circular(RadiusTokens.full),
                border: Border.all(color: colors.borderSubtle.withOpacity(0.3)),
              ),
              child: Text(
                '${state.priorities.length} / 3 slots',
                style: AppTypography.labelXs.copyWith(
                  color: state.canAddPriority
                      ? colors.accentPrimary
                      : colors.accentWarmth,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: SpacingTokens.sm),

        // 3 Slots Card Stack
        for (int i = 0; i < 3; i++) ...[
          if (i < state.priorities.length)
            _buildPriorityItemCard(
              context,
              state.priorities[i],
              index: i,
              isActive: state.activePriorityIndex == i,
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.setActivePriorityIndex(i);
              },
              onToggle: () {
                HapticFeedback.lightImpact();
                notifier.togglePriority(state.priorities[i].id);
              },
              onDelete: () {
                HapticFeedback.mediumImpact();
                notifier.deletePriority(state.priorities[i].id);
              },
            )
          else
            _buildEmptySlotCard(context, slotIndex: i),
          const SizedBox(height: SpacingTokens.sm),
        ],

        const SizedBox(height: SpacingTokens.md),

        // Add priority field if slots available
        if (state.canAddPriority) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priorityInputController,
                  style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'One small thing to focus on...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: colors.textMuted.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: colors.bgSurface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      borderSide: BorderSide(color: colors.borderSubtle.withOpacity(0.4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      borderSide: BorderSide(color: colors.borderSubtle.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      borderSide: BorderSide(color: colors.accentPrimary),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      notifier.addPriority(val);
                      _priorityInputController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              FireflyButton(
                text: 'Add',
                isFullWidth: false,
                variant: FireflyButtonVariant.smallPrimary,
                onPressed: () {
                  final text = _priorityInputController.text.trim();
                  if (text.isNotEmpty) {
                    HapticFeedback.selectionClick();
                    notifier.addPriority(text);
                    _priorityInputController.clear();
                  }
                },
              ),
            ],
          ),
        ] else ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
              child: Text(
                'All 3 slots filled. Complete or remove one before adding another.',
                style: AppTypography.labelXs.copyWith(color: colors.textMuted),
              ),
            ),
          ),
        ],

        const SizedBox(height: SpacingTokens.lg),

        // Action button to start focus timer on active priority
        if (state.priorities.isNotEmpty) ...[
          FireflyButton(
            text: state.activePriority != null
                ? 'Focus on "${state.activePriority!.title}"'
                : 'Start Focus Companion',
            icon: AppIcons.sparkles,
            variant: FireflyButtonVariant.primary,
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.setMode(FocusMode.focusTimer);
            },
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPriorityItemCard(
    BuildContext context,
    FocusPriority priority, {
    required int index,
    required bool isActive,
    required VoidCallback onTap,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    final colors = context.colors;

    return FireflyCard(
      variant: isActive ? FireflyCardVariant.interactive : FireflyCardVariant.flat,
      backgroundColor: isActive
          ? colors.accentPrimary.withOpacity(0.08)
          : colors.bgSurface,
      borderColor: isActive
          ? colors.accentPrimary.withOpacity(0.5)
          : colors.borderSubtle.withOpacity(0.2),
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          // Checkmark toggle
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: priority.isCompleted
                    ? colors.accentPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: priority.isCompleted
                      ? colors.accentPrimary
                      : colors.textMuted.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: priority.isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.black)
                  : null,
            ),
          ),
          const SizedBox(width: SpacingTokens.md),

          // Title & active badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  priority.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: priority.isCompleted
                        ? colors.textMuted
                        : colors.textPrimary,
                    decoration: priority.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Active Focus Item',
                    style: AppTypography.labelXs.copyWith(
                      color: colors.accentPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Delete button
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: colors.textMuted.withOpacity(0.7),
            ),
            tooltip: 'Remove',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotCard(BuildContext context, {required int slotIndex}) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(
          color: colors.borderSubtle.withOpacity(0.15),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.borderSubtle.withOpacity(0.25),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Text(
                '${slotIndex + 1}',
                style: AppTypography.labelXs.copyWith(color: colors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Text(
            'Empty Priority Slot',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textMuted.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. FOCUS COMPANION VIEW (SERENE TIMER)
  // ===========================================================================

  Widget _buildFocusTimerView(
    BuildContext context,
    FocusState state,
    FocusNotifier notifier,
  ) {
    final colors = context.colors;
    final session = state.session;

    return ListView(
      key: const ValueKey('focus_timer_view'),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.sm,
      ),
      children: [
        // Priority reminder if linked
        if (state.activePriority != null) ...[
          FireflyCard(
            backgroundColor: colors.accentPrimary.withOpacity(0.08),
            borderColor: colors.accentPrimary.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.sparkles,
                  color: colors.accentPrimary,
                  size: 18,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    'Focusing on: ${state.activePriority!.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.accentPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],

        // Circular Timer Display
        Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft background glow ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (state.isTimerRunning ? _pulseController.value * 0.05 : 0.0);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isTimerRunning
                              ? colors.accentPrimary.withOpacity(0.05)
                              : Colors.transparent,
                        ),
                      ),
                    );
                  },
                ),

                // Custom Circular Progress Ring
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _FocusTimerPainter(
                    progress: session.progress,
                    trackColor: colors.bgSurface,
                    progressColor: colors.accentPrimary,
                  ),
                ),

                // Center Time Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.formattedTime,
                      style: AppTypography.displayLarge.copyWith(
                        color: colors.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.isCompleted
                          ? 'Session Complete'
                          : state.isTimerRunning
                              ? 'Quiet Focus'
                              : session.isPaused
                                  ? 'Paused gently'
                                  : 'Ready when you are',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: SpacingTokens.xl),

        // Duration Selection Chips
        if (!state.isTimerRunning && !session.isCompleted) ...[
          Center(
            child: Wrap(
              spacing: SpacingTokens.sm,
              children: [5, 10, 15, 25].map((mins) {
                final isSelected = session.durationMinutes == mins;
                return ChoiceChip(
                  label: Text('$mins min'),
                  selected: isSelected,
                  selectedColor: colors.accentPrimary.withOpacity(0.2),
                  backgroundColor: colors.bgSurface,
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSelected ? colors.accentPrimary : colors.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? colors.accentPrimary.withOpacity(0.5)
                        : colors.borderSubtle.withOpacity(0.3),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      notifier.selectDuration(mins);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],

        // Ambient Sound Accompaniment Selector
        FireflyCard(
          backgroundColor: colors.bgSurface.withOpacity(0.6),
          borderColor: colors.borderSubtle.withOpacity(0.25),
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.audio,
                color: colors.accentSecondary,
                size: 20,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  'Ambient Sound',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              DropdownButton<String?>(
                value: session.ambientSoundId,
                dropdownColor: colors.bgSurface,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Quiet Silence')),
                  DropdownMenuItem(value: 'rain', child: Text('Gentle Rain')),
                  DropdownMenuItem(value: 'forest', child: Text('Forest Breeze')),
                  DropdownMenuItem(value: 'waves', child: Text('Soft Waves')),
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  notifier.selectAmbientSound(val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: SpacingTokens.xl),

        // Timer Control Buttons
        if (session.isCompleted) ...[
          FireflyCard(
            backgroundColor: colors.accentPrimary.withOpacity(0.12),
            borderColor: colors.accentPrimary.withOpacity(0.4),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: colors.accentPrimary,
                  size: 32,
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  'You gave yourself a moment of quiet focus.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rest whenever you are ready. There is no quota to meet.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          FireflyButton(
            text: 'Begin Another Gentle Session',
            variant: FireflyButtonVariant.primary,
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.resetTimer();
            },
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: FireflyButton(
                  text: state.isTimerRunning ? 'Pause' : 'Start Focus',
                  icon: state.isTimerRunning ? Icons.pause : Icons.play_arrow,
                  variant: FireflyButtonVariant.primary,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    notifier.toggleTimer();
                  },
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                flex: 2,
                child: FireflyButton(
                  text: 'Reset',
                  variant: FireflyButtonVariant.secondary,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    notifier.resetTimer();
                  },
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  // ===========================================================================
  // 3. BRAIN DUMP VIEW (UNSTRUCTURED OFFLOADING)
  // ===========================================================================

  Widget _buildBrainDumpView(
    BuildContext context,
    FocusState state,
    FocusNotifier notifier,
  ) {
    final colors = context.colors;

    return ListView(
      key: const ValueKey('brain_dump_view'),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.sm,
      ),
      children: [
        // Reassurance header
        FireflyCard(
          backgroundColor: colors.bgSurface.withOpacity(0.7),
          borderColor: colors.borderSubtle.withOpacity(0.3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.notes,
                color: colors.accentSecondary,
                size: 20,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  'Offload all racing thoughts, chores, or worries. Once they are safely written down, your mind does not have to expend energy holding them.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: SpacingTokens.md),

        // Brain dump input card
        FireflyCard(
          backgroundColor: colors.bgSurface,
          borderColor: colors.borderSubtle.withOpacity(0.3),
          child: Column(
            children: [
              TextField(
                controller: _brainDumpInputController,
                maxLines: 3,
                style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'What is cluttering your mind right now?',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: colors.textMuted.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Align(
                alignment: Alignment.centerRight,
                child: FireflyButton(
                  text: 'Offload Thought',
                  isFullWidth: false,
                  variant: FireflyButtonVariant.smallPrimary,
                  onPressed: () {
                    final text = _brainDumpInputController.text.trim();
                    if (text.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      notifier.addBrainDumpItem(text);
                      _brainDumpInputController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: SpacingTokens.lg),

        // Dumped Items List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Offloaded Thoughts (${state.brainDumpItems.length})',
              style: AppTypography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (state.brainDumpItems.isNotEmpty)
              TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  notifier.clearBrainDump();
                },
                child: Text(
                  'Clear All',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: SpacingTokens.xs),

        if (state.brainDumpItems.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xl),
            child: Center(
              child: Text(
                'No thoughts dumped yet. Write whatever comes to mind.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textMuted.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ] else ...[
          for (final item in state.brainDumpItems) ...[
            FireflyCard(
              backgroundColor: item.isParked
                  ? colors.bgSurface.withOpacity(0.4)
                  : colors.bgSurface,
              borderColor: item.isParked
                  ? colors.borderSubtle.withOpacity(0.15)
                  : colors.borderSubtle.withOpacity(0.3),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.rawText,
                          style: AppTypography.bodyMedium.copyWith(
                            color: item.isParked
                                ? colors.textMuted
                                : colors.textPrimary,
                            decoration: item.isParked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        color: colors.textMuted.withOpacity(0.6),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Delete',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          notifier.deleteBrainDumpItem(item.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Row(
                    children: [
                      // Promote to priority button
                      if (!item.isParked && state.canAddPriority) ...[
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.selectionClick();
                            final success =
                                await notifier.promoteBrainDumpToPriority(item.id);
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to Three Priorities'),
                                  duration: Duration(milliseconds: 1500),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.accentPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(RadiusTokens.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 12,
                                  color: colors.accentPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Make a Priority',
                                  style: AppTypography.labelXs.copyWith(
                                    color: colors.accentPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                      ],

                      // Park / Unpark toggle
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.toggleParkBrainDump(item.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.bgCanvas,
                            borderRadius: BorderRadius.circular(RadiusTokens.full),
                            border: Border.all(
                              color: colors.borderSubtle.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            item.isParked ? 'Unpark' : 'Park for Later',
                            style: AppTypography.labelXs.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
          ],
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

/// Custom painter for the serene circular focus progress ring.
class _FocusTimerPainter extends CustomPainter {
  _FocusTimerPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Paint
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
