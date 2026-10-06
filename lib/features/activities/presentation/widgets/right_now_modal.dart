import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';

/// Data representation of an acute distress need anchor.
class RightNowAnchor {
  const RightNowAnchor({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.route,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final String route;
}

/// The 12 canonical acute distress anchors defined in PRD v2.0 FR-10.
const List<RightNowAnchor> kRightNowAnchors = [
  RightNowAnchor(
    id: 'calm_down',
    title: 'I need to calm down',
    subtitle: 'Cyclic sighing & breathwork',
    iconKey: 'wind',
    route: AppRoutes.breathe,
  ),
  RightNowAnchor(
    id: 'cant_stop_thinking',
    title: 'I cannot stop thinking',
    subtitle: 'Cognitive grounding & words',
    iconKey: 'brain.head.profile',
    route: AppRoutes.cognitiveGrounding,
  ),
  RightNowAnchor(
    id: 'overwhelmed',
    title: 'I feel overwhelmed',
    subtitle: '5-4-3-2-1 sensory grounding',
    iconKey: 'hand.point.up.left',
    route: AppRoutes.breathe,
  ),
  RightNowAnchor(
    id: 'low_energy',
    title: 'I have very little energy',
    subtitle: '2-minute tiny step',
    iconKey: 'checklist',
    route: AppRoutes.tinySteps,
  ),
  RightNowAnchor(
    id: 'restless',
    title: 'I feel restless',
    subtitle: 'Physical release & shakeout',
    iconKey: 'figure.walk',
    route: '/home/move?mode=shakeout',
  ),
  RightNowAnchor(
    id: 'cant_focus',
    title: 'I cannot focus',
    subtitle: 'Meditative finger tracing',
    iconKey: 'circle.hexagonpath',
    route: AppRoutes.tinySteps,
  ),
  RightNowAnchor(
    id: 'emotionally_heavy',
    title: 'I feel emotionally heavy',
    subtitle: 'Muscle relaxation & release',
    iconKey: 'figure.mind.and.body',
    route: AppRoutes.pmr,
  ),
  RightNowAnchor(
    id: 'want_to_sleep',
    title: 'I want to sleep',
    subtitle: 'Night worry dump & audio fade',
    iconKey: 'moon.stars',
    route: AppRoutes.sleep,
  ),
  RightNowAnchor(
    id: 'express_feeling',
    title: 'I want to express something',
    subtitle: 'Private unsent writing',
    iconKey: 'pencil.and.outline',
    route: AppRoutes.journal,
  ),
  RightNowAnchor(
    id: 'distracting',
    title: 'I want something distracting',
    subtitle: 'Calm tactile puzzle',
    iconKey: 'sparkles',
    route: AppRoutes.tinySteps,
  ),
  RightNowAnchor(
    id: 'connect',
    title: 'I want to connect',
    subtitle: 'Low-friction check-in text',
    iconKey: 'person.2',
    route: AppRoutes.loneliness,
  ),
  RightNowAnchor(
    id: 'dont_know',
    title: 'I do not know what I need',
    subtitle: 'Gentle ambient sound sanctuary',
    iconKey: 'headphones',
    route: AppRoutes.soundscapes,
  ),
];

/// Full-screen, low-stimulation modal allowing a user in distress to immediately
/// self-select what they need without cognitive overhead or multi-step questionnaires.
class RightNowModal extends StatelessWidget {
  const RightNowModal({super.key});

  /// Displays the modal using smooth fade transition.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RightNowModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.88,
      decoration: BoxDecoration(
        color: colors.bgCanvasDeep,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.modalRadius),
        ),
        border: Border(
          top: BorderSide(
            color: colors.borderSubtle,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag Handle
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.spaceSm, bottom: SpacingTokens.spaceXs),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderMuted,
                    borderRadius: BorderRadius.circular(RadiusTokens.radiusPill),
                  ),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.screenPaddingH,
                vertical: SpacingTokens.spaceSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What do you need right now?',
                        style: AppTypography.headingLg.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap one that fits. We will guide you from there.',
                        style: AppTypography.bodySm.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textTertiary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            const SizedBox(height: SpacingTokens.spaceXs),

            // 12 Distress Need Anchors List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.screenPaddingH,
                  SpacingTokens.spaceXs,
                  SpacingTokens.screenPaddingH,
                  SpacingTokens.bottomClearance,
                ),
                itemCount: kRightNowAnchors.length,
                separatorBuilder: (context, index) => const SizedBox(height: SpacingTokens.elementGap),
                itemBuilder: (context, index) {
                  final anchor = kRightNowAnchors[index];
                  return _AnchorCard(
                    anchor: anchor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      context.push(anchor.route);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnchorCard extends StatelessWidget {
  const _AnchorCard({
    required this.anchor,
    required this.onTap,
  });

  final RightNowAnchor anchor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.spaceMd,
            vertical: SpacingTokens.spaceSm + 2,
          ),
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
            border: Border.all(
              color: colors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.bgElevated,
                  borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
                ),
                child: Center(
                  child: Icon(
                    _resolveIcon(anchor.iconKey),
                    size: 20,
                    color: colors.accentSage,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anchor.title,
                      style: AppTypography.headingSm.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      anchor.subtitle,
                      style: AppTypography.captionSm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _resolveIcon(String key) {
    switch (key) {
      case 'wind':
        return Icons.air_rounded;
      case 'brain.head.profile':
        return Icons.psychology_outlined;
      case 'hand.point.up.left':
        return Icons.touch_app_outlined;
      case 'checklist':
        return Icons.check_circle_outline_rounded;
      case 'figure.walk':
        return Icons.directions_walk_rounded;
      case 'circle.hexagonpath':
        return Icons.gesture_rounded;
      case 'figure.mind.and.body':
        return Icons.self_improvement_rounded;
      case 'moon.stars':
        return Icons.bedtime_outlined;
      case 'pencil.and.outline':
        return Icons.edit_note_rounded;
      case 'sparkles':
        return Icons.auto_awesome_rounded;
      case 'person.2':
        return Icons.people_outline_rounded;
      case 'headphones':
        return Icons.headphones_outlined;
      default:
        return Icons.spa_outlined;
    }
  }
}
