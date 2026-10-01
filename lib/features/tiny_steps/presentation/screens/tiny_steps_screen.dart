import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/tiny_step.dart';
import '../controllers/tiny_steps_controller.dart';

/// Screen displaying 3 manageable behavioural activation micro-actions.
///
/// Designed with low cognitive load, zero gamification, tactile completion feedback,
/// and quiet, guilt-free dismiss options.
class TinyStepsScreen extends ConsumerWidget {
  const TinyStepsScreen({super.key});

  Future<void> _triggerWarmDoubleTapHaptic() async {
    try {
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics fail silently on unsupported platforms
    }
  }

  IconData _getCategoryIcon(TinyStepCategory category) {
    switch (category) {
      case TinyStepCategory.sensory:
        return Icons.visibility_outlined;
      case TinyStepCategory.physical:
        return Icons.accessibility_new_outlined;
      case TinyStepCategory.environment:
        return Icons.wb_sunny_outlined;
      case TinyStepCategory.nourishment:
        return Icons.water_drop_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(tinyStepsControllerProvider);
    final controller = ref.read(tinyStepsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      appBar: AppBar(
        backgroundColor: colors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textSecondary),
          tooltip: 'Return to Home',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Tiny Steps',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textSecondary),
            tooltip: 'Try different options',
            onPressed: () => controller.shuffle(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accentPrimary),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calming Header
                    Text(
                      'One small thing',
                      style: AppTypography.headingLg.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick one tiny action that feels possible right now. No expectations, no pressure.',
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Compassionate acknowledgement on completion
                    if (state.hasCompleted) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.accentPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.accentPrimary.withOpacity(0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: colors.accentPrimary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Momentum started. You can rest now or do another if you feel like it.',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colors.textSecondary,
                                    side: BorderSide(
                                      color: colors.textSecondary.withOpacity(0.3),
                                    ),
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => controller.resetCompleted(),
                                  child: const Text('Do another step'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.accentPrimary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(AppRoutes.home);
                                    }
                                  },
                                  child: const Text('Rest / Return home'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 3 Candidate Action Cards
                    ...state.candidates.map((step) {
                      final isCompleted = state.completedStepId == step.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MicroActionCard(
                          step: step,
                          isCompleted: isCompleted,
                          iconData: _getCategoryIcon(step.category),
                          onComplete: () async {
                            await _triggerWarmDoubleTapHaptic();
                            controller.completeStep(step.id);
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Low-pressure Secondary Controls
                    Center(
                      child: Column(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(220, 48),
                              foregroundColor: colors.textSecondary,
                              side: BorderSide(
                                color: colors.textSecondary.withOpacity(0.25),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.shuffle, size: 18),
                            label: const Text('Try different options'),
                            onPressed: () => controller.shuffle(),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(220, 44),
                              foregroundColor: colors.textMuted,
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.home);
                              }
                            },
                            child: const Text("I'll do this later"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Accessible micro-action card (touch target ≥ 72dp) with soft sage fade.
class _MicroActionCard extends StatelessWidget {
  const _MicroActionCard({
    required this.step,
    required this.isCompleted,
    required this.iconData,
    required this.onComplete,
  });

  final TinyStep step;
  final bool isCompleted;
  final IconData iconData;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: 76),
      decoration: BoxDecoration(
        color: isCompleted
            ? colors.accentPrimary.withOpacity(0.14)
            : colors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? colors.accentPrimary
              : colors.bgOverlay,
          width: isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colors.accentPrimary.withOpacity(0.25)
                        : colors.bgOverlay,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : iconData,
                    color: isCompleted ? colors.accentPrimary : colors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: AppTypography.headingSm.copyWith(
                          color: colors.textPrimary,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: AppTypography.bodySm.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Duration & category indicators
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.bgOverlay,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '≤ ${step.durationMinutes} min',
                            style: AppTypography.labelSm.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.bgOverlay,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.category.displayName,
                        style: AppTypography.labelSm.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                // "I did this" button
                isCompleted
                    ? Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colors.accentPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Done',
                            style: AppTypography.labelMd.copyWith(
                              color: colors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.accentPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(110, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('I did this'),
                        onPressed: onComplete,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
