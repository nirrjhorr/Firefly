import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';

/// Quiet Onboarding & Sensory Setup screen for Firefly (aligned with Stitch Serene Sanctuary).
///
/// Principles:
/// - Unhurried, low-stimulation welcome without high cognitive load.
/// - Clear statement of clinical scope (supports rather than replaces professional care).
/// - Reassurance of 100% offline encryption and zero accounts.
/// - Adaptive layout constrained to 640dp max-width.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _reducedSensory = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.screenPaddingH,
                vertical: SpacingTokens.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: SpacingTokens.spaceXl),
                  // Quiet Glowing Firefly Indicator
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.actionSage.withOpacity(0.15),
                        border: Border.all(
                          color: colors.actionSage.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.actionSage.withOpacity(0.2),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        AppIcons.checkIn,
                        color: colors.actionSage,
                        size: IconSizeTokens.lg,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.spaceXl),

                  Center(
                    child: Text(
                      'Welcome to Firefly',
                      style: AppTypography.displayLg.copyWith(
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.spaceSm),
                  Center(
                    child: Text(
                      'A calm, private sanctuary for your nervous system.\nNo streaks. No accounts. Take your time.',
                      style: AppTypography.bodyLg.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.space2xl),

                  // Three Quiet Pillars
                  FireflyCard(
                    padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                    child: Column(
                      children: [
                        _buildPillarRow(
                          icon: AppIcons.vaultLock,
                          title: '100% On-Device & Encrypted',
                          subtitle: 'Your entries are encrypted locally with hardware-backed keys. Nothing is ever uploaded.',
                          colors: colors,
                        ),
                        Divider(color: colors.borderSubtle, height: SpacingTokens.spaceLg),
                        _buildPillarRow(
                          icon: AppIcons.safeEnvironment,
                          title: 'Gentle Clinical Scope',
                          subtitle: 'Firefly provides self-regulation tools (Cyclic Sighing, PMR, Safety Plan). It supports rather than replaces professional clinical care.',
                          colors: colors,
                        ),
                        Divider(color: colors.borderSubtle, height: SpacingTokens.spaceLg),
                        _buildPillarRow(
                          icon: AppIcons.progress,
                          title: 'Anti-Gamified Presence',
                          subtitle: 'No red badges, no lost-streak penalties. Progress is measured solely by quiet presence when you need it.',
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.spaceLg),

                  // Sensory Pace Preference
                  FireflyCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.cardPadding,
                      vertical: SpacingTokens.spaceSm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Low Sensory Mode',
                                style: AppTypography.headingSm.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Gentler contrasts, subdued haptics, and minimal motion.',
                                style: AppTypography.caption.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _reducedSensory,
                          activeColor: colors.actionSage,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _reducedSensory = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.space2xl),

                  FireflyButton(
                    text: 'Enter Sanctuary',
                    variant: FireflyButtonVariant.primary,
                    icon: AppIcons.forward,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.go(AppRoutes.checkIn);
                    },
                  ),
                  const SizedBox(height: SpacingTokens.spaceXl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillarRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppCustomColors colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.actionSage.withOpacity(0.12),
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
          child: Icon(
            icon,
            size: IconSizeTokens.appAction,
            color: colors.actionSage,
          ),
        ),
        const SizedBox(width: SpacingTokens.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headingSm.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySm.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
