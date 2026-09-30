import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../controllers/safety_plan_controller.dart';
import '../../domain/models/safety_plan_contact.dart';

class SafetyPlanScreen extends ConsumerStatefulWidget {
  const SafetyPlanScreen({super.key});

  @override
  ConsumerState<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends ConsumerState<SafetyPlanScreen> {
  static const String _defaultReachOutMessage =
      "Hey — I'm having a rough time right now. Could we talk?";

  Future<void> _launchCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phoneNumber.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSms(String? phoneNumber, {String? body}) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber.trim(),
      queryParameters: body != null ? {'body': body} : null,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyPlanControllerProvider);
    final colors = context.colors;

    if (state.isLoading || state.plan == null) {
      return Scaffold(
        backgroundColor: colors.bgCanvasDeep,
        appBar: AppBar(
          title: const Text('Safety Plan'),
          backgroundColor: colors.bgCanvasDeep,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final plan = state.plan!;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        title: Text(
          'Stanley-Brown Safety Plan',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.bgCanvasDeep,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colors.actionSage),
            tooltip: 'Edit Plan',
            onPressed: () => context.push(AppRoutes.safetyPlanEditor),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  Text(
                    'Stored 100% offline & encrypted',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Emergency Crisis Lines Quick Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.crisisSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.crisisCoral.withOpacity(0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emergency,
                              color: colors.crisisCoral,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Immediate Crisis Support (24/7)',
                              style: AppTypography.headingMd.copyWith(
                                color: colors.crisisCoral,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.crisisCoral,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.phone, size: 18),
                                label: const Text('Call 988'),
                                onPressed: () => _launchCall('988'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.crisisCoral,
                                  side: BorderSide(color: colors.crisisCoral),
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.sms, size: 18),
                                label: const Text('Text 741741'),
                                onPressed: () => _launchSms(
                                  '741741',
                                  body: 'HOME',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Step 1: Warning Signs
                  _buildAccordionCard(
                    context,
                    stepNumber: 1,
                    title: 'Warning Signs',
                    subtitle: 'Signals that a crisis may be brewing',
                    content: plan.warnings.isEmpty
                        ? Text(
                            'No warning signs added yet. Tap edit to add some.',
                            style: AppTypography.bodySm.copyWith(
                              color: colors.textSecondary,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: plan.warnings
                                .map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('• ',
                                            style: TextStyle(
                                                color: colors.crisisCoral,
                                                fontSize: 16)),
                                        Expanded(
                                          child: Text(
                                            w.warningText,
                                            style: AppTypography.bodyMd.copyWith(
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Step 2: Internal Coping
                  _buildAccordionCard(
                    context,
                    stepNumber: 2,
                    title: 'Internal Coping Strategies',
                    subtitle: 'Things I can do alone to calm myself',
                    content: Text(
                      plan.steps
                          .firstWhere((s) => s.stepNumber == 2,
                              orElse: () => plan.steps.first)
                          .stepContent,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step 3: Distraction Places & People
                  _buildAccordionCard(
                    context,
                    stepNumber: 3,
                    title: 'Distraction Places & People',
                    subtitle: 'Social environments that divert attention',
                    content: Text(
                      plan.steps
                          .firstWhere((s) => s.stepNumber == 3,
                              orElse: () => plan.steps.first)
                          .stepContent,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step 4: Support Contacts (People I Can Ask for Help)
                  _buildAccordionCard(
                    context,
                    stepNumber: 4,
                    title: 'People I Can Ask for Help',
                    subtitle: 'Trusted friends and family members',
                    initiallyExpanded: true,
                    content: Column(
                      children: [
                        if (plan.personalContacts.isEmpty)
                          Text(
                            'No personal contacts added yet. Tap edit to add your trusted people.',
                            style: AppTypography.bodySm.copyWith(
                              color: colors.textSecondary,
                            ),
                          )
                        else
                          ...plan.personalContacts.map(
                            (contact) => _buildContactActionTile(context, contact),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step 5: Professionals & Agencies
                  _buildAccordionCard(
                    context,
                    stepNumber: 5,
                    title: 'Professionals & Agencies',
                    subtitle: 'Healthcare providers and urgent crisis lines',
                    content: Column(
                      children: [
                        if (plan.professionalContacts.isEmpty)
                          Text(
                            'No professionals added yet. Local 988 and 741741 are always active.',
                            style: AppTypography.bodySm.copyWith(
                              color: colors.textSecondary,
                            ),
                          )
                        else
                          ...plan.professionalContacts.map(
                            (contact) => _buildContactActionTile(context, contact),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step 6: Environment Safety
                  _buildAccordionCard(
                    context,
                    stepNumber: 6,
                    title: 'Making My Environment Safe',
                    subtitle: 'Steps to remove or secure means of harm',
                    content: Text(
                      plan.steps
                          .firstWhere((s) => s.stepNumber == 6,
                              orElse: () => plan.steps.first)
                          .stepContent,
                      style: AppTypography.bodyMd.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FireflyButton(
                    text: 'Edit My Plan',
                    variant: FireflyButtonVariant.secondary,
                    icon: Icons.edit,
                    onPressed: () => context.push(AppRoutes.safetyPlanEditor),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Persistent Non-Clinical Advisory Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: colors.surfaceSubtle,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Firefly supports — it does not replace professional care.',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionCard(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String subtitle,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
    final colors = context.colors;

    return FireflyCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.actionSage.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$stepNumber',
              style: AppTypography.labelMd.copyWith(
                color: colors.actionSage,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            title,
            style: AppTypography.headingMd.copyWith(
              color: colors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
          iconColor: colors.actionSage,
          collapsedIconColor: colors.textSecondary,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactActionTile(
      BuildContext context, SafetyPlanContact contact) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.bgCanvasDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: AppTypography.headingMd.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    contact.relationship,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (contact.phoneNumber != null)
                    Text(
                      contact.phoneNumber!,
                      style: AppTypography.bodySm.copyWith(
                        color: colors.actionSage,
                      ),
                    ),
                ],
              ),
            ),
            if (contact.phoneNumber != null) ...[
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: colors.actionSage.withOpacity(0.2),
                ),
                icon: Icon(Icons.call, color: colors.actionSage, size: 20),
                tooltip: 'Call ${contact.name}',
                onPressed: () => _launchCall(contact.phoneNumber),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: colors.actionSage.withOpacity(0.2),
                ),
                icon: Icon(Icons.sms, color: colors.actionSage, size: 20),
                tooltip: 'Text ${contact.name}',
                onPressed: () => _launchSms(
                  contact.phoneNumber,
                  body: _defaultReachOutMessage,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
