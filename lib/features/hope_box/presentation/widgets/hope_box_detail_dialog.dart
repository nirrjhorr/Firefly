import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/hope_box_item.dart';
import 'hope_box_audio_player_widget.dart';

/// Modal dialog providing private, focused viewing of a Hope Box coping resource.
class HopeBoxDetailDialog extends StatelessWidget {
  final HopeBoxItem item;
  final String decryptedContent;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  const HopeBoxDetailDialog({
    super.key,
    required this.item,
    required this.decryptedContent,
    required this.onDelete,
    required this.onTogglePin,
  });

  static Future<void> show({
    required BuildContext context,
    required HopeBoxItem item,
    required String decryptedContent,
    required VoidCallback onDelete,
    required VoidCallback onTogglePin,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => HopeBoxDetailDialog(
        item: item,
        decryptedContent: decryptedContent,
        onDelete: onDelete,
        onTogglePin: onTogglePin,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF191E23),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
        title: Text(
          'Remove from Hope Box?',
          style: AppTypography.headingSmall.copyWith(
            color: const Color(0xFFE8ECF0),
          ),
        ),
        content: Text(
          'This item and its files will be permanently erased from your device.',
          style: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF9AAAB6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep',
              style: AppTypography.bodyMedium.copyWith(
                color: const Color(0xFF9AAAB6),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB05454), // Crisis coral
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // dismiss confirm
              Navigator.of(context).pop(); // dismiss detail dialog
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const canvasBg = Color(0xFF111518);
    const cardBg = Color(0xFF191E23);
    const neutral100 = Color(0xFFE8ECF0);
    const neutral300 = Color(0xFF9AAAB6);
    const warmAmber = Color(0xFFE5B870);
    const sage300 = Color(0xFF84B09A);

    return Dialog(
      backgroundColor: canvasBg,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        side: const BorderBorderSide(),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Category/Type + Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: SpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: item.type == HopeBoxItemType.reason
                        ? warmAmber.withOpacity(0.15)
                        : sage300.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  ),
                  child: Text(
                    item.type.label,
                    style: AppTypography.caption.copyWith(
                      color: item.type == HopeBoxItemType.reason ? warmAmber : sage300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    item.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: item.isPinned ? warmAmber : neutral300,
                  ),
                  tooltip: item.isPinned ? 'Unpin' : 'Pin to top',
                  onPressed: onTogglePin,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC96E6E)),
                  tooltip: 'Delete item',
                  onPressed: () => _confirmDelete(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: neutral300),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (item.type == HopeBoxItemType.reason) ...[
                      // Reason Banner
                      Container(
                        padding: const EdgeInsets.all(SpacingTokens.lg),
                        decoration: BoxDecoration(
                          color: warmAmber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(RadiusTokens.lg),
                          border: Border.all(
                            color: warmAmber.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.favorite_rounded, color: warmAmber, size: 20),
                                const SizedBox(width: SpacingTokens.sm),
                                Text(
                                  'Something worth staying for:',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: warmAmber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: SpacingTokens.md),
                            Text(
                              decryptedContent.isNotEmpty ? decryptedContent : item.title,
                              style: AppTypography.bodyLarge.copyWith(
                                color: neutral100,
                                height: 1.5,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (item.type == HopeBoxItemType.text) ...[
                      // Text Note
                      Text(
                        item.title,
                        style: AppTypography.headingSmall.copyWith(
                          color: neutral100,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Container(
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(RadiusTokens.md),
                        ),
                        child: Text(
                          decryptedContent.isNotEmpty ? decryptedContent : '(No notes)',
                          style: AppTypography.bodyMedium.copyWith(
                            color: neutral100,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ] else if (item.type == HopeBoxItemType.photo) ...[
                      // Photo Preview
                      Text(
                        item.title,
                        style: AppTypography.headingSmall.copyWith(
                          color: neutral100,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(RadiusTokens.lg),
                        child: item.filePath != null && File(item.filePath!).existsSync()
                            ? Image.file(
                                File(item.filePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => _buildPlaceholderMedia(
                                  Icons.image_not_supported_rounded,
                                  'Photo file not found on device',
                                ),
                              )
                            : _buildPlaceholderMedia(
                                Icons.image_rounded,
                                'Photo stored in private vault',
                              ),
                      ),
                      if (item.caption != null && item.caption!.isNotEmpty) ...[
                        const SizedBox(height: SpacingTokens.md),
                        Text(
                          item.caption!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: neutral300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ] else if (item.type == HopeBoxItemType.voice ||
                        item.type == HopeBoxItemType.audio) ...[
                      // Direct in-app playable audio & voice notes
                      HopeBoxAudioPlayerWidget(
                        filePath: item.filePath,
                        title: item.title,
                        isVoiceNote: item.type == HopeBoxItemType.voice,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderMedia(IconData icon, String message) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF191E23),
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF6B7E8C)),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              message,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF9AAAB6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BorderBorderSide extends BorderSide {
  const BorderBorderSide() : super(color: const Color(0xFF2E3840), width: 1.0);
}
