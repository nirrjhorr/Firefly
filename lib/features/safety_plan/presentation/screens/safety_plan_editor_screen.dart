import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../controllers/safety_plan_controller.dart';
import '../../domain/models/safety_plan_contact.dart';

class SafetyPlanEditorScreen extends ConsumerStatefulWidget {
  const SafetyPlanEditorScreen({super.key});

  @override
  ConsumerState<SafetyPlanEditorScreen> createState() =>
      _SafetyPlanEditorScreenState();
}

class _SafetyPlanEditorScreenState
    extends ConsumerState<SafetyPlanEditorScreen> {
  final Map<int, TextEditingController> _stepControllers = {};
  final TextEditingController _warningInputController = TextEditingController();

  @override
  void dispose() {
    for (final controller in _stepControllers.values) {
      controller.dispose();
    }
    _warningInputController.dispose();
    super.dispose();
  }

  TextEditingController _getControllerForStep(int stepNumber, String initialText) {
    return _stepControllers.putIfAbsent(
      stepNumber,
      () => TextEditingController(text: initialText),
    );
  }

  void _showAddContactDialog(BuildContext context, {bool isProfessional = false}) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.colors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.dialog),
          ),
          title: Text(
            isProfessional ? 'Add Professional Contact' : 'Add Support Contact',
            style: AppTypography.headingMd.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name / Service Name',
                  ),
                ),
                const SizedBox(height: SpacingTokens.spaceSm),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                ),
                const SizedBox(height: SpacingTokens.spaceSm),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(
                    labelText: isProfessional ? 'Role (e.g. Therapist, Clinic)' : 'Relationship (e.g. Friend, Sister)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.actionSage,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.buttonSecondary),
                ),
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  ref.read(safetyPlanControllerProvider.notifier).addContact(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim().isEmpty
                            ? null
                            : phoneController.text.trim(),
                        relationship: relationshipController.text.trim().isEmpty
                            ? (isProfessional ? 'Professional' : 'Friend')
                            : relationshipController.text.trim(),
                        isProfessional: isProfessional,
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Add Contact'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyPlanControllerProvider);
    final colors = context.colors;

    if (state.isLoading || state.plan == null) {
      return Scaffold(
        backgroundColor: colors.bgCanvasDeep,
        appBar: AppBar(
          title: const Text('Edit Safety Plan'),
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
          'Edit Safety Plan',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.bgCanvasDeep,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: colors.textPrimary, size: IconSizeTokens.appAction),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.screenPaddingH,
            vertical: SpacingTokens.screenPaddingV,
          ),
          children: [
            Text(
              'Your Personalized Plan',
              style: AppTypography.headingLg.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: SpacingTokens.spaceXs),
            Text(
              'Changes are automatically saved to your encrypted device database.',
              style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.sectionGap),

            // Step 1: Warning Signs
            _buildSectionHeader(
              context,
              number: 1,
              title: 'Warning Signs',
              subtitle: 'Signals indicating an emotional crisis may be starting',
            ),
            ...plan.warnings.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.spaceXs),
                child: FireflyCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(AppIcons.warning,
                          color: colors.crisisCoral, size: IconSizeTokens.appAction),
                      const SizedBox(width: SpacingTokens.spaceSm),
                      Expanded(
                        child: Text(
                          w.warningText,
                          style: AppTypography.bodyMd.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(AppIcons.close, color: colors.textSecondary, size: IconSizeTokens.sm),
                        onPressed: () => ref
                            .read(safetyPlanControllerProvider.notifier)
                            .removeWarningSign(w.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _warningInputController,
                    decoration: InputDecoration(
                      hintText: 'Add a new personal warning sign...',
                      hintStyle: AppTypography.bodySm.copyWith(color: colors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.input),
                        borderSide: BorderSide(color: colors.borderSubtle),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.spaceXs),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: colors.actionSage,
                  ),
                  icon: Icon(AppIcons.add, color: Colors.white, size: IconSizeTokens.appAction),
                  onPressed: () {
                    final text = _warningInputController.text.trim();
                    if (text.isNotEmpty) {
                      ref
                          .read(safetyPlanControllerProvider.notifier)
                          .addWarningSign(text);
                      _warningInputController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Step 2: Internal Coping
            _buildStepEditorCard(
              context,
              stepNumber: 2,
              title: 'Internal Coping Strategies',
              subtitle: 'Things I can do on my own to soothe or distract myself',
              initialText: plan.steps
                  .firstWhere((s) => s.stepNumber == 2,
                      orElse: () => plan.steps.first)
                  .stepContent,
            ),
            const SizedBox(height: 28),

            // Step 3: Distraction Places & People
            _buildStepEditorCard(
              context,
              stepNumber: 3,
              title: 'People & Places for Distraction',
              subtitle: 'Social settings or places that take my mind off distress',
              initialText: plan.steps
                  .firstWhere((s) => s.stepNumber == 3,
                      orElse: () => plan.steps.first)
                  .stepContent,
            ),
            const SizedBox(height: 28),

            // Step 4: Support Contacts (People to ask for help)
            _buildSectionHeader(
              context,
              number: 4,
              title: 'People I Can Ask for Help',
              subtitle: 'Trusted friends or family members I can reach out to',
            ),
            ...plan.personalContacts.map(
              (c) => _buildContactCard(context, c),
            ),
            FireflyButton(
              text: 'Add Support Contact',
              variant: FireflyButtonVariant.secondary,
              icon: AppIcons.contactAdd,
              onPressed: () => _showAddContactDialog(context, isProfessional: false),
            ),
            const SizedBox(height: SpacingTokens.sectionGap),

            // Step 5: Professionals & Crisis Lines
            _buildSectionHeader(
              context,
              number: 5,
              title: 'Professionals & Crisis Lines',
              subtitle: 'Clinicians, therapists, hospitals, and crisis helplines',
            ),
            ...plan.professionalContacts.map(
              (c) => _buildContactCard(context, c),
            ),
            FireflyButton(
              text: 'Add Professional Contact',
              variant: FireflyButtonVariant.secondary,
              icon: AppIcons.emergencyShield,
              onPressed: () => _showAddContactDialog(context, isProfessional: true),
            ),
            const SizedBox(height: SpacingTokens.sectionGap),

            // Step 6: Environment Safety
            _buildStepEditorCard(
              context,
              stepNumber: 6,
              title: 'Making My Environment Safe',
              subtitle: 'Actions to eliminate or secure hazardous means',
              initialText: plan.steps
                  .firstWhere((s) => s.stepNumber == 6,
                      orElse: () => plan.steps.first)
                  .stepContent,
            ),
            const SizedBox(height: SpacingTokens.spaceXl),

            FireflyButton(
              text: 'Done Editing',
              variant: FireflyButtonVariant.primary,
              icon: AppIcons.check,
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: SpacingTokens.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required int number,
    required String title,
    required String subtitle,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.actionSage.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: AppTypography.caption.copyWith(
                    color: colors.actionSage,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.headingMd.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySm.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepEditorCard(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String subtitle,
    required String initialText,
  }) {
    final colors = context.colors;
    final controller = _getControllerForStep(stepNumber, initialText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context,
            number: stepNumber, title: title, subtitle: subtitle),
        TextField(
          controller: controller,
          maxLines: 4,
          onChanged: (val) {
            ref
                .read(safetyPlanControllerProvider.notifier)
                .updateStepContent(stepNumber, val);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(SpacingTokens.spaceMd),
            hintText: 'Describe strategies or specifics for this step...',
            hintStyle: AppTypography.bodySm.copyWith(color: colors.textSecondary),
            filled: true,
            fillColor: colors.surfaceCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
          ),
          style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, SafetyPlanContact contact) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FireflyCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              contact.isProfessional
                  ? AppIcons.emergencyShield
                  : AppIcons.contactAdd,
              color: colors.actionSage,
              size: IconSizeTokens.standard,
            ),
            const SizedBox(width: SpacingTokens.spaceSm),
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
                  if (contact.phoneNumber != null)
                    Text(
                      contact.phoneNumber!,
                      style: AppTypography.bodySm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  Text(
                    contact.relationship,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(AppIcons.delete, color: colors.crisisCoral, size: IconSizeTokens.appAction),
              onPressed: () => ref
                  .read(safetyPlanControllerProvider.notifier)
                  .removeContact(contact.id),
            ),
          ],
        ),
      ),
    );
  }
}
