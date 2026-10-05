import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.screenPaddingH,
            vertical: SpacingTokens.screenPaddingV,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Quiet Glowing Firefly Indicator
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.actionSage.withOpacity(0.15),
                  border: Border.all(color: colors.actionSage.withOpacity(0.4)),
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
              const SizedBox(height: SpacingTokens.sectionGap),

              Text(
                'Welcome to Firefly',
                style: AppTypography.displayLg.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceMd),
              Text(
                'There is no streak here. Come when you need to. Leave when you\'re ready. Your thoughts never leave this device.',
                style: AppTypography.bodyLg.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
              const Spacer(),

              FireflyButton(
                text: 'Enter Sanctuary',
                variant: FireflyButtonVariant.primary,
                icon: AppIcons.forward,
                onPressed: () => context.go(AppRoutes.checkIn),
              ),
              const SizedBox(height: SpacingTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
