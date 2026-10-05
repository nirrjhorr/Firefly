import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';

/// Screen providing gentle, non-judgmental comfort during acute loneliness.
///
/// Surfaces low-pressure connection options: comforting audio soundscapes,
/// offline safety plan contacts with pre-written templates, and unsent letters.
class LonelinessComfortScreen extends StatelessWidget {
  const LonelinessComfortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      appBar: AppBar(
        backgroundColor: colors.bgCanvasDeep,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: colors.textSecondary, size: IconSizeTokens.appAction),
          tooltip: 'Return to Home',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.checkIn);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Holding space for you',
                style: AppTypography.displayMd.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Loneliness can feel profoundly heavy. You do not have to carry everything alone right now.',
                style: AppTypography.bodyMd.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Option 1: Soft Ambient Audio
              FireflyCard(
                padding: const EdgeInsets.all(20),
                onTap: () => context.push(AppRoutes.breathe),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.actionSage.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(AppIcons.breathe, color: colors.actionSage, size: IconSizeTokens.standard),
                    ),
                    const SizedBox(width: SpacingTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gentle Soundscape & Breathing',
                            style: AppTypography.headingMd.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rest with calming rain and slow cyclic sighs.',
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(AppIcons.chevronRight, color: colors.textSecondary, size: IconSizeTokens.appAction),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceMd),

              // Option 2: Pre-written Reach Out
              FireflyCard(
                padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                onTap: () => context.push(AppRoutes.safetyPlan),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.accentAmber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(AppIcons.contactAdd, color: colors.accentAmber, size: IconSizeTokens.standard),
                    ),
                    const SizedBox(width: SpacingTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reach Out to Safe People',
                            style: AppTypography.headingMd.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Access pre-written reach-out texts and trusted contacts.',
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(AppIcons.chevronRight, color: colors.textSecondary, size: IconSizeTokens.appAction),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.spaceMd),

              // Option 3: Unsent Letter
              FireflyCard(
                padding: const EdgeInsets.all(SpacingTokens.cardPadding),
                onTap: () => context.push('${AppRoutes.journal}/new-letter?ttl=24h'),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(AppIcons.burnFlame, color: colors.textPrimary, size: IconSizeTokens.standard),
                    ),
                    const SizedBox(width: SpacingTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Write an Unsent Letter',
                            style: AppTypography.headingMd.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Say what you need to say into a private, auto-deleting vault.',
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(AppIcons.chevronRight, color: colors.textSecondary, size: IconSizeTokens.appAction),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.sectionGap),

              Center(
                child: FireflyButton(
                  text: 'Return to Check-In',
                  variant: FireflyButtonVariant.secondary,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.checkIn);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
