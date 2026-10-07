import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../domain/models/crisis_support_config.dart';
import '../../domain/models/safety_plan_contact.dart';

/// Modal for configuring immediate 1-tap crisis call and text dispatch targets.
/// Supports manual entry, picking from Step 4 trusted contacts, and 1-tap default presets.
class CrisisSupportConfigModal extends StatefulWidget {
  const CrisisSupportConfigModal({
    super.key,
    required this.initialConfig,
    required this.step4Contacts,
    required this.onSave,
    required this.onUseDefaults,
  });

  final CrisisSupportConfig? initialConfig;
  final List<SafetyPlanContact> step4Contacts;
  final ValueChanged<CrisisSupportConfig> onSave;
  final VoidCallback onUseDefaults;

  static Future<void> show({
    required BuildContext context,
    required CrisisSupportConfig? initialConfig,
    required List<SafetyPlanContact> step4Contacts,
    required ValueChanged<CrisisSupportConfig> onSave,
    required VoidCallback onUseDefaults,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.sheet)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: CrisisSupportConfigModal(
          initialConfig: initialConfig,
          step4Contacts: step4Contacts,
          onSave: onSave,
          onUseDefaults: onUseDefaults,
        ),
      ),
    );
  }

  @override
  State<CrisisSupportConfigModal> createState() => _CrisisSupportConfigModalState();
}

class _CrisisSupportConfigModalState extends State<CrisisSupportConfigModal> {
  late final TextEditingController _callNameController;
  late final TextEditingController _callPhoneController;
  late final TextEditingController _textNameController;
  late final TextEditingController _textPhoneController;
  late final TextEditingController _textMessageController;

  @override
  void initState() {
    super.initState();
    final call = widget.initialConfig?.primaryCallContact;
    final text = widget.initialConfig?.primaryTextContact;

    _callNameController = TextEditingController(text: call?.name ?? '');
    _callPhoneController = TextEditingController(text: call?.phone ?? '');
    _textNameController = TextEditingController(text: text?.name ?? '');
    _textPhoneController = TextEditingController(text: text?.phone ?? '');
    _textMessageController = TextEditingController(text: text?.defaultMessage ?? 'HOME');
  }

  @override
  void dispose() {
    _callNameController.dispose();
    _callPhoneController.dispose();
    _textNameController.dispose();
    _textPhoneController.dispose();
    _textMessageController.dispose();
    super.dispose();
  }

  void _applyStep4Contact(SafetyPlanContact contact, bool forCall) {
    setState(() {
      if (forCall) {
        _callNameController.text = contact.name;
        if (contact.phoneNumber != null) {
          _callPhoneController.text = contact.phoneNumber!;
        }
      } else {
        _textNameController.text = contact.name;
        if (contact.phoneNumber != null) {
          _textPhoneController.text = contact.phoneNumber!;
        }
      }
    });
  }

  void _submit() {
    final callPhone = _callPhoneController.text.trim();
    final textPhone = _textPhoneController.text.trim();

    final callContact = callPhone.isNotEmpty
        ? CrisisContact(
            name: _callNameController.text.trim().isNotEmpty
                ? _callNameController.text.trim()
                : callPhone,
            phone: callPhone,
          )
        : null;

    final textContact = textPhone.isNotEmpty
        ? CrisisContact(
            name: _textNameController.text.trim().isNotEmpty
                ? _textNameController.text.trim()
                : textPhone,
            phone: textPhone,
            defaultMessage: _textMessageController.text.trim().isNotEmpty
                ? _textMessageController.text.trim()
                : null,
          )
        : null;

    final newConfig = CrisisSupportConfig(
      primaryCallContact: callContact,
      primaryTextContact: textContact,
    );

    widget.onSave(newConfig);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.screenPaddingH,
        vertical: SpacingTokens.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(AppIcons.emergencyShield, color: colors.crisisCoral, size: IconSizeTokens.standard),
              const SizedBox(width: SpacingTokens.spaceSm),
              Expanded(
                child: Text(
                  'Immediate Crisis Support Setup',
                  style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.close),
                color: colors.textSecondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.spaceXs),
          Text(
            'Configure 1-tap rapid dispatch targets. You can enter any number or pick from Step 4 contacts.',
            style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.spaceMd),

          // Quick preset action
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.actionSage,
              side: BorderSide(color: colors.actionSage.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.buttonSecondary),
              ),
            ),
            icon: const Icon(AppIcons.refresh, size: IconSizeTokens.sm),
            label: const Text('Use Default National Helplines (988 / 741741)'),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onUseDefaults();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: SpacingTokens.spaceLg),

          // Primary Call Target Section
          Text(
            'Primary Call Contact',
            style: AppTypography.labelLg.copyWith(color: colors.crisisCoral),
          ),
          const SizedBox(height: SpacingTokens.spaceXs),
          if (widget.step4Contacts.isNotEmpty) ...[
            Text(
              'Pick from Step 4 (People I Can Ask for Help):',
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.step4Contacts.map((c) {
                return ActionChip(
                  label: Text(c.name, style: TextStyle(color: colors.textPrimary, fontSize: 12)),
                  backgroundColor: colors.surfaceSubtle,
                  side: BorderSide(color: colors.borderSubtle),
                  onPressed: () => _applyStep4Contact(c, true),
                );
              }).toList(),
            ),
            const SizedBox(height: SpacingTokens.spaceSm),
          ],
          TextField(
            controller: _callNameController,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Contact / Service Name',
              hintText: 'e.g. 988 or Alex (Friend)',
              labelStyle: TextStyle(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          TextField(
            controller: _callPhoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'e.g. 988 or +1234567890',
              labelStyle: TextStyle(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceLg),

          // Primary Text Target Section
          Text(
            'Primary Text Contact',
            style: AppTypography.labelLg.copyWith(color: colors.actionSage),
          ),
          const SizedBox(height: SpacingTokens.spaceXs),
          if (widget.step4Contacts.isNotEmpty) ...[
            Text(
              'Pick from Step 4 (People I Can Ask for Help):',
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.step4Contacts.map((c) {
                return ActionChip(
                  label: Text(c.name, style: TextStyle(color: colors.textPrimary, fontSize: 12)),
                  backgroundColor: colors.surfaceSubtle,
                  side: BorderSide(color: colors.borderSubtle),
                  onPressed: () => _applyStep4Contact(c, false),
                );
              }).toList(),
            ),
            const SizedBox(height: SpacingTokens.spaceSm),
          ],
          TextField(
            controller: _textNameController,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Contact / Service Name',
              hintText: 'e.g. 741741 or Dr. Miller',
              labelStyle: TextStyle(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          TextField(
            controller: _textPhoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'SMS Phone / Shortcode',
              hintText: 'e.g. 741741 or +1234567890',
              labelStyle: TextStyle(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          TextField(
            controller: _textMessageController,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Default SMS Message (Optional)',
              hintText: 'e.g. HOME or Need support right now',
              labelStyle: TextStyle(color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceLg),

          // Save Button
          FireflyButton(
            text: 'Save Crisis Support Settings',
            variant: FireflyButtonVariant.primary,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
