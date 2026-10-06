import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/reach_out_contact.dart';

/// Privacy-respecting contact card for reaching out during loneliness.
///
/// Features large touch targets (≥ 56dp), clear relationship indicators,
/// and quick actions to send a comforting pre-written message.
class ReachOutContactCard extends StatelessWidget {
  const ReachOutContactCard({
    super.key,
    required this.contact,
    required this.onMessagePressed,
    this.onCallPressed,
    this.onDeletePressed,
  });

  final ReachOutContact contact;
  final VoidCallback onMessagePressed;
  final VoidCallback? onCallPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FireflyCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: contact.isSafetyPlanContact
                      ? colors.actionSage.withOpacity(0.18)
                      : colors.accentAmber.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  contact.isSafetyPlanContact ? AppIcons.safetyPlan : AppIcons.contactAdd,
                  color: contact.isSafetyPlanContact ? colors.actionSage : colors.accentAmber,
                  size: IconSizeTokens.standard,
                ),
              ),
              const SizedBox(width: SpacingTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: AppTypography.headingMd.copyWith(
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.displaySubtitle,
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!contact.isSafetyPlanContact && onDeletePressed != null)
                IconButton(
                  icon: Icon(AppIcons.delete, color: colors.textSecondary, size: 20),
                  tooltip: 'Remove contact',
                  onPressed: onDeletePressed,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56, // Touch target ≥ 56dp
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.actionSage.withOpacity(0.15),
                      foregroundColor: colors.actionSage,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colors.actionSage.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    icon: Icon(AppIcons.notes, size: 20, color: colors.actionSage),
                    label: Text(
                      'Send a message',
                      style: AppTypography.button.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: onMessagePressed,
                  ),
                ),
              ),
              if (contact.hasPhoneNumber && onCallPressed != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 56,
                  height: 56, // Touch target ≥ 56dp
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: colors.borderSubtle,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: onCallPressed,
                    child: Icon(
                      AppIcons.contactAdd,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
