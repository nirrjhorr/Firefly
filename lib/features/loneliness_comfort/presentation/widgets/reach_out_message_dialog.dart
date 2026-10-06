import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../domain/models/loneliness_comfort_state.dart';
import '../../domain/models/reach_out_contact.dart';

/// Modal dialog for selecting or customizing a reach-out message
/// before starting the "Guess vs. Reality" prediction experiment.
class ReachOutMessageDialog extends StatefulWidget {
  const ReachOutMessageDialog({
    super.key,
    required this.contact,
    required this.initialTemplateIndex,
    required this.onProceed,
  });

  final ReachOutContact contact;
  final int initialTemplateIndex;
  final void Function(String message) onProceed;

  static Future<void> show({
    required BuildContext context,
    required ReachOutContact contact,
    required int initialTemplateIndex,
    required void Function(String message) onProceed,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReachOutMessageDialog(
        contact: contact,
        initialTemplateIndex: initialTemplateIndex,
        onProceed: onProceed,
      ),
    );
  }

  @override
  State<ReachOutMessageDialog> createState() => _ReachOutMessageDialogState();
}

class _ReachOutMessageDialogState extends State<ReachOutMessageDialog> {
  late int _selectedIndex;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTemplateIndex;
    final initialText = (_selectedIndex >= 0 && _selectedIndex < kDefaultReachOutTemplates.length)
        ? kDefaultReachOutTemplates[_selectedIndex]
        : kDefaultReachOutTemplates[0];
    _textController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTemplateSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _textController.text = kDefaultReachOutTemplates[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgCanvasDeep,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 24,
      ),
      child: SingleChildScrollView(
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
              'Message for ${widget.contact.name}',
              style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a gentle opening or edit to make it your own:',
              style: AppTypography.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),

            // 3 Pre-written templates
            for (int i = 0; i < kDefaultReachOutTemplates.length; i++) ...[
              InkWell(
                onTap: () => _onTemplateSelected(i),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedIndex == i
                        ? colors.actionSage.withOpacity(0.12)
                        : colors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedIndex == i
                          ? colors.actionSage
                          : colors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedIndex == i
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _selectedIndex == i ? colors.actionSage : colors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          kDefaultReachOutTemplates[i],
                          style: AppTypography.bodyMd.copyWith(
                            color: colors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 12),
            Text(
              'Message preview & edits',
              style: AppTypography.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _textController,
              maxLines: 3,
              style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.bgSurface,
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.actionSage),
                ),
              ),
              onChanged: (val) {
                if (_selectedIndex != -1) {
                  setState(() => _selectedIndex = -1);
                }
              },
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: FireflyButton(
                    text: 'Cancel',
                    variant: FireflyButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FireflyButton(
                    text: 'Continue',
                    variant: FireflyButtonVariant.primary,
                    onPressed: () {
                      final text = _textController.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.of(context).pop();
                        widget.onProceed(text);
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
}
