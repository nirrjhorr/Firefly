import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/sleep_session_state.dart';
import '../controllers/sleep_suite_controller.dart';
import '../widgets/sleep_timer_selector.dart';
import '../widgets/wake_time_companion_card.dart';
import '../widgets/worry_dump_card.dart';

/// Pre-bed sleep & wind-down suite sanctuary screen (`#0A0D0F`).
/// Implements ultra-low luminance, sub-3000K warm typography, dual worry dump,
/// and fading ambient sleep timer.
class SleepSuiteScreen extends ConsumerStatefulWidget {
  final String? initialMode;
  final bool showSosOverlay;

  const SleepSuiteScreen({
    super.key,
    this.initialMode,
    this.showSosOverlay = true,
  });

  @override
  ConsumerState<SleepSuiteScreen> createState() => _SleepSuiteScreenState();
}

class _SleepSuiteScreenState extends ConsumerState<SleepSuiteScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();

    if (widget.initialMode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mode = widget.initialMode!.toLowerCase();
        if (mode.contains('ambient') || mode.contains('timer') || mode.contains('sound')) {
          ref.read(sleepSuiteProvider.notifier).switchTab(SleepSuiteTab.soundscape);
        } else if (mode.contains('wake') || mode.contains('anchor')) {
          ref.read(sleepSuiteProvider.notifier).switchTab(SleepSuiteTab.wakeAnchor);
        } else {
          ref.read(sleepSuiteProvider.notifier).switchTab(SleepSuiteTab.worryDump);
        }
      });
    }
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final state = ref.read(sleepSuiteProvider);
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    // If user interacted with the sleep suite or parked worries, invite gentle rating
    if (state.parkedEntries.isNotEmpty || elapsedSec >= 45) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_worry_dump',
        stateAtStart: 'cantSleep',
        durationSeconds: elapsedSec > 0 ? elapsedSec : 60,
      );
    }

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepSuiteProvider);
    final notifier = ref.read(sleepSuiteProvider.notifier);

    // Sleep Suite Sanctuary Canvas: Strictly #0A0D0F (ultra-dark ink950)
    const sanctuaryCanvas = Color(0xFF0A0D0F);
    const warmAmber = Color(0xFFE5B870);

    return Scaffold(
      backgroundColor: sanctuaryCanvas,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Sanctuary Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.sm,
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Leave sleep sanctuary',
                        child: IconButton(
                          key: const Key('sleep_exit_button'),
                          icon: const Icon(Icons.close_rounded),
                          color: const Color(0xFFC4CDD4),
                          tooltip: "That's enough for now",
                          onPressed: _handleExit,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sleep Sanctuary',
                              style: AppTypography.titleMedium.copyWith(
                                color: warmAmber,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Ultra-low light space to transition into rest',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF9AAAB6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sanctuary Mode Tabs (Worry Dump | Fading Ambient | Wake Anchor)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.xs,
                  ),
                  child: Row(
                    children: SleepSuiteTab.values.map((tab) {
                      final isSelected = tab == state.activeTab;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.switchTab(tab);
                            },
                            borderRadius: BorderRadius.circular(RadiusTokens.chip),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 48),
                              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1E252B) : const Color(0xFF0F1316),
                                borderRadius: BorderRadius.circular(RadiusTokens.chip),
                                border: Border.all(
                                  color: isSelected ? warmAmber : const Color(0x22E5B870),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                tab.label,
                                style: AppTypography.caption.copyWith(
                                  color: isSelected ? const Color(0xFFF2D9A8) : const Color(0xFF9AAAB6),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),

                // Active Mode Body
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: switch (state.activeTab) {
                      SleepSuiteTab.worryDump => const WorryDumpCard(key: ValueKey('worry_dump_card')),
                      SleepSuiteTab.soundscape => const SleepTimerSelector(key: ValueKey('sleep_timer_selector')),
                      SleepSuiteTab.wakeAnchor => const WakeTimeCompanionCard(key: ValueKey('wake_companion_card')),
                    },
                  ),
                ),
              ],
            ),

            // Persistent SOS Floating Panic Overlay
            if (widget.showSosOverlay)
              const Positioned(
                bottom: SpacingTokens.lg,
                right: SpacingTokens.lg,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }
}
