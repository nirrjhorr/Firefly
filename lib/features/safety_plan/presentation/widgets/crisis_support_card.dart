import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/crisis_support_config.dart';

/// Dynamic crisis support card for Stanley-Brown Safety Plan.
/// Shows unconfigured CTA or dynamic Call/Text buttons with an edit pencil trigger.
class CrisisSupportCard extends StatelessWidget {
  const CrisisSupportCard({
    super.key,
    required this.config,
    required this.onConfigure,
    required this.onUseDefaults,
    required this.onCall,
    required this.onText,
  });

  final CrisisSupportConfig? config;
  final VoidCallback onConfigure;
  final VoidCallback onUseDefaults;
  final ValueChanged<String> onCall;
  final void Function(String phone, String? message) onText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isConfigured = config != null && config!.isConfigured;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.cardPadding),
      decoration: BoxDecoration(
        color: colors.crisisSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
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
                AppIcons.emergencyShield,
                color: colors.crisisCoral,
                size: IconSizeTokens.standard,
              ),
              const SizedBox(width: SpacingTokens.spaceSm),
              Expanded(
                child: Text(
                  'Immediate Crisis Support (24/7)',
                  style: AppTypography.headingMd.copyWith(
                    color: colors.crisisCoral,
                  ),
                ),
              ),
              if (isConfigured)
                IconButton(
                  icon: Icon(AppIcons.edit, size: IconSizeTokens.md, color: colors.crisisCoral),
                  tooltip: 'Edit Crisis Contacts',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onConfigure();
                  },
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.spaceSm),

          if (!isConfigured) ...[
            Text(
              'No rapid crisis contacts set. Configure your local helpline or trusted contact for 1-tap rapid dispatch.',
              style: AppTypography.bodySm.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceMd),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.crisisCoral,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, SpacingTokens.buttonHeightSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.buttonSecondary),
                      ),
                    ),
                    icon: const Icon(AppIcons.edit, size: IconSizeTokens.md),
                    label: const Text('Configure Support'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onConfigure();
                    },
                  ),
                ),
                const SizedBox(width: SpacingTokens.spaceSm),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.crisisCoral,
                      side: BorderSide(color: colors.crisisCoral.withOpacity(0.6)),
                      minimumSize: const Size(0, SpacingTokens.buttonHeightSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.buttonSecondary),
                      ),
                    ),
                    child: const Text('Use 988 / 741741'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onUseDefaults();
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                // Dynamic Call button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.crisisCoral,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, SpacingTokens.buttonHeightSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.buttonSecondary),
                      ),
                    ),
                    icon: Icon(AppIcons.phone, size: IconSizeTokens.md),
                    label: Text(
                      config?.primaryCallContact != null
                          ? 'Call ${config!.primaryCallContact!.name}'
                          : 'Configure Call',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: config?.primaryCallContact != null
                        ? () => onCall(config!.primaryCallContact!.phone)
                        : onConfigure,
                  ),
                ),
                const SizedBox(width: SpacingTokens.spaceSm),

                // Dynamic Text button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.crisisCoral,
                      side: BorderSide(color: colors.crisisCoral),
                      minimumSize: const Size(0, SpacingTokens.buttonHeightSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.buttonSecondary),
                      ),
                    ),
                    icon: Icon(AppIcons.sms, size: IconSizeTokens.md),
                    label: Text(
                      config?.primaryTextContact != null
                          ? 'Text ${config!.primaryTextContact!.name}'
                          : 'Configure Text',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: config?.primaryTextContact != null
                        ? () => onText(
                              config!.primaryTextContact!.phone,
                              config!.primaryTextContact!.defaultMessage,
                            )
                        : onConfigure,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
