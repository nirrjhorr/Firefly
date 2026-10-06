import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/hope_box_item.dart';

/// Privacy-preserving card representing a coping resource in the Hope Box vault.
///
/// Principles:
/// - Displays type icon and high-level label/title rather than exposing full raw content.
/// - Minimum touch target of 56dp.
/// - Subtle visual differentiation per item type using calm nature tokens.
class HopeBoxItemCard extends StatelessWidget {
  final HopeBoxItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const HopeBoxItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onTogglePin,
  });

  IconData _getIconData(HopeBoxItemType type) {
    switch (type) {
      case HopeBoxItemType.reason:
        return Icons.favorite_rounded;
      case HopeBoxItemType.text:
        return Icons.format_quote_rounded;
      case HopeBoxItemType.photo:
        return Icons.image_rounded;
      case HopeBoxItemType.voice:
        return Icons.mic_rounded;
      case HopeBoxItemType.audio:
        return Icons.music_note_rounded;
    }
  }

  Color _getTypeAccentColor(HopeBoxItemType type) {
    switch (type) {
      case HopeBoxItemType.reason:
        return const Color(0xFFE5B870); // Warm amber
      case HopeBoxItemType.text:
        return const Color(0xFF84B09A); // Calm sage
      case HopeBoxItemType.photo:
        return const Color(0xFF6B92BF); // Dusk blue
      case HopeBoxItemType.voice:
        return const Color(0xFFD4963E); // Deep amber
      case HopeBoxItemType.audio:
        return const Color(0xFF5D9478); // Deep sage
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getTypeAccentColor(item.type);

    return Semantics(
      button: true,
      label: '${item.type.label}: ${item.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
          child: Container(
            constraints: const BoxConstraints(minHeight: 80.0),
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: const Color(0xFF191E23), // ink800
              borderRadius: BorderRadius.circular(RadiusTokens.lg),
              border: Border.all(
                color: item.isPinned
                    ? accentColor.withOpacity(0.6)
                    : const Color(0xFF2E3840), // ink600
                width: item.isPinned ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item Type Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(RadiusTokens.md),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconData(item.type),
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(RadiusTokens.xs),
                            ),
                            child: Text(
                              item.type.label,
                              style: AppTypography.caption.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (item.category.isNotEmpty && item.category != 'General') ...[
                            const SizedBox(width: SpacingTokens.xs),
                            Text(
                              '• ${item.category}',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF9AAAB6), // neutral300
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        item.title,
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFFE8ECF0), // neutral100
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Pin Action Button
                IconButton(
                  icon: Icon(
                    item.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: item.isPinned ? accentColor : const Color(0xFF6B7E8C),
                    size: 20,
                  ),
                  tooltip: item.isPinned ? 'Unpin' : 'Pin to top',
                  onPressed: onTogglePin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
