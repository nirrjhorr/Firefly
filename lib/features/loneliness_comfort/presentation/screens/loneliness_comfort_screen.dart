import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/reach_out_contact.dart';
import '../../domain/models/social_prediction_experiment.dart';
import '../controllers/loneliness_comfort_controller.dart';
import '../widgets/guess_vs_reality_sheet.dart';
import '../widgets/reach_out_contact_card.dart';
import '../widgets/reach_out_message_dialog.dart';
import '../widgets/social_insight_card.dart';

/// Screen providing trauma-informed comfort, reaching-out options,
/// and the "Guess vs. Reality" cognitive behavioral experiment engine.
class LonelinessComfortScreen extends ConsumerStatefulWidget {
  const LonelinessComfortScreen({
    super.key,
    this.showSosOverlay = false,
  });

  final bool showSosOverlay;

  @override
  ConsumerState<LonelinessComfortScreen> createState() =>
      _LonelinessComfortScreenState();
}

class _LonelinessComfortScreenState
    extends ConsumerState<LonelinessComfortScreen>
    with SingleTickerProviderStateMixin {
  final Stopwatch _sessionStopwatch = Stopwatch();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    if (elapsedSec >= 30) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_loneliness_comfort',
        stateAtStart: 'lonely',
        durationSeconds: elapsedSec > 0 ? elapsedSec : 30,
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

  void _onMessagePressed(ReachOutContact contact) {
    final state = ref.read(lonelinessComfortControllerProvider);
    final controller = ref.read(lonelinessComfortControllerProvider.notifier);

    ReachOutMessageDialog.show(
      context: context,
      contact: contact,
      initialTemplateIndex: state.selectedTemplateIndex,
      onProceed: (message) {
        // Step 2: Show "Guess vs. Reality" prediction prompt
        GuessVsRealitySheet.showPrediction(
          context: context,
          contactName: contact.name,
          onConfirmed: (predictedOutcome) async {
            await controller.startPredictionExperiment(
              contact: contact,
              predictedOutcome: predictedOutcome,
              message: message,
            );
            await controller.launchSms(
              phoneNumber: contact.phoneNumber ?? '',
              message: message,
            );
          },
          onSkip: () async {
            await controller.launchSms(
              phoneNumber: contact.phoneNumber ?? '',
              message: message,
            );
          },
        );
      },
    );
  }

  void _openAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.bgCanvasDeep,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.borderSubtle, width: 1),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add a Trusted Person',
              style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Someone safe you can reach out to in moments of loneliness.',
              style: AppTypography.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.bgSurface,
                hintText: 'Name',
                hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.bgSurface,
                hintText: 'Phone number (for SMS intent)',
                hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: relationshipController,
              style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.bgSurface,
                hintText: 'Relationship (Friend, Sister, Support)',
                hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FireflyButton(
                    text: 'Cancel',
                    variant: FireflyButtonVariant.secondary,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FireflyButton(
                    text: 'Save Contact',
                    variant: FireflyButtonVariant.primary,
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        ref.read(lonelinessComfortControllerProvider.notifier).addCustomContact(
                              name: name,
                              phoneNumber: phoneController.text.trim(),
                              relationship: relationshipController.text.trim(),
                            );
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lonelinessComfortControllerProvider);
    final controller = ref.read(lonelinessComfortControllerProvider.notifier);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: colors.textSecondary, size: IconSizeTokens.appAction),
          tooltip: 'Return to Home',
          onPressed: _handleExit,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calming Header Banner
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "You don't have to feel this alone.",
                              style: AppTypography.displayMd.copyWith(
                                color: colors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "What you're feeling is real. Others have stood in this exact quiet.",
                              style: AppTypography.bodyMd.copyWith(
                                color: colors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.actionSage.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.actionSage.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            AppIcons.breathe,
                            color: colors.actionSage,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Non-judgmental Feedback Alert (if outcome logged)
                  if (state.lastFeedbackMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.actionSage.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.actionSage.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.insights, color: colors.actionSage, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.lastFeedbackMessage!,
                              style: AppTypography.bodyMd.copyWith(
                                color: colors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: colors.textSecondary, size: 18),
                            onPressed: () => controller.clearFeedback(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pending Outcome Card (Guess vs. Reality follow-up)
                  if (state.hasPendingOutcome) ...[
                    FireflyCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: colors.accentAmber.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(AppIcons.notes, color: colors.accentAmber, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Did you hear back from ${state.activePendingExperiment!.contactName}?',
                                  style: AppTypography.headingMd.copyWith(
                                    color: colors.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Logging what actually happened helps dismantle anxious predictions over time.',
                            style: AppTypography.caption.copyWith(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.accentAmber.withOpacity(0.15),
                                foregroundColor: colors.accentAmber,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: colors.accentAmber.withOpacity(0.4)),
                                ),
                              ),
                              onPressed: () {
                                GuessVsRealitySheet.showOutcome(
                                  context: context,
                                  contactName: state.activePendingExperiment!.contactName,
                                  onConfirmed: (actualOutcome) {
                                    controller.recordExperimentOutcome(
                                      experimentId: state.activePendingExperiment!.id,
                                      actualOutcome: actualOutcome,
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Log What Happened',
                                style: AppTypography.button.copyWith(
                                  color: colors.accentAmber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Psychoeducation Callout (Kumar & Epley 2023)
                  if (!state.isPsychoeducationDismissed) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(AppIcons.insights, color: colors.actionSage, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The Science of Reaching Out',
                                  style: AppTypography.headingMd.copyWith(
                                    color: colors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Research shows people almost always appreciate hearing from us far more than we expect — even when we worry it might feel awkward.',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: colors.textSecondary, size: 16),
                            tooltip: 'Dismiss',
                            onPressed: () => controller.dismissPsychoeducation(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Aggregate Insight Card (unlocked after ≥ 3 completed experiments)
                  if (state.summary.shouldShowInsight) ...[
                    SocialInsightCard(summary: state.summary),
                    const SizedBox(height: 16),
                  ],

                  // Reaching Out Contacts Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'People I could reach out to',
                        style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                      ),
                      IconButton(
                        icon: Icon(AppIcons.contactAdd, color: colors.actionSage, size: 20),
                        tooltip: 'Add trusted contact',
                        onPressed: _openAddContactDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (!state.hasContacts) ...[
                    FireflyCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(AppIcons.contactAdd, color: colors.textSecondary, size: 36),
                            const SizedBox(height: 10),
                            Text(
                              'No contacts listed yet',
                              style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add someone you could text when loneliness feels heavy, or link from your Safety Plan.',
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(color: colors.textSecondary),
                            ),
                            const SizedBox(height: 14),
                            FireflyButton(
                              text: 'Add a Trusted Person',
                              variant: FireflyButtonVariant.secondary,
                              onPressed: _openAddContactDialog,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    for (final contact in state.contacts) ...[
                      ReachOutContactCard(
                        contact: contact,
                        onMessagePressed: () => _onMessagePressed(contact),
                        onDeletePressed: contact.isSafetyPlanContact
                            ? null
                            : () => controller.deleteCustomContact(contact.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],

                  const SizedBox(height: 24),

                  // Things That Have Helped Before (Quick Comforts)
                  Text(
                    'Things that can help right now',
                    style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 10),

                  // Quick Comfort 1: Gentle Breathing & Soundscape
                  FireflyCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push(AppRoutes.breathe),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.actionSage.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(AppIcons.breathe, color: colors.actionSage, size: 22),
                        ),
                        const SizedBox(width: SpacingTokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gentle Soundscape & Breathing',
                                style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Calming ambient sound with slow cyclic sighs.',
                                style: AppTypography.caption.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(AppIcons.chevronRight, color: colors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Comfort 2: Open Hope Box
                  FireflyCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push(AppRoutes.hopeBox),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.accentAmber.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(AppIcons.notes, color: colors.accentAmber, size: 22),
                        ),
                        const SizedBox(width: SpacingTokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Open Hope Box Vault',
                                style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Reasons to keep going, meaningful photos, and voice notes.',
                                style: AppTypography.caption.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(AppIcons.chevronRight, color: colors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Comfort 3: Unsent Letter
                  FireflyCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('${AppRoutes.journal}/new-letter?ttl=24h'),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.textSecondary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(AppIcons.burnFlame, color: colors.textPrimary, size: 22),
                        ),
                        const SizedBox(width: SpacingTokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Write an Unsent Letter',
                                style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Say what you need to say into a private, auto-deleting vault.',
                                style: AppTypography.caption.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(AppIcons.chevronRight, color: colors.textSecondary, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: FireflyButton(
                      text: "That's enough for now",
                      variant: FireflyButtonVariant.secondary,
                      onPressed: _handleExit,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Persistent SOS Shield overlay if requested
            if (widget.showSosOverlay)
              const Positioned(
                bottom: 24,
                right: 24,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }
}
