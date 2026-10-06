import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/regulation_group.dart';

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
    route: '/home/breathe?mode=grounding',
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
    route: '${AppRoutes.move}?mode=shakeout',
  ),
  RightNowAnchor(
    id: 'cant_focus',
    title: 'I cannot focus',
    subtitle: 'Meditative finger tracing',
    iconKey: 'circle.hexagonpath',
    route: AppRoutes.labyrinth,
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
    route: AppRoutes.flowPuzzle,
  ),
  RightNowAnchor(
    id: 'connect',
    title: 'I want to connect',
    subtitle: 'Low-friction check-in text',
    iconKey: 'person.2',
    route: AppRoutes.loneliness,
  ),
  RightNowAnchor(
    id: 'losing_hope',
    title: 'I need a reminder to hold on',
    subtitle: 'Visit your offline Hope Box',
    iconKey: 'heart',
    route: AppRoutes.hopeBox,
  ),
  RightNowAnchor(
    id: 'complete_reset',
    title: 'I need a complete reset',
    subtitle: '5-minute guided step-by-step reset',
    iconKey: 'spa',
    route: AppRoutes.reset,
  ),
  RightNowAnchor(
    id: 'hard_on_myself',
    title: 'I am being too hard on myself',
    subtitle: 'Self-compassion & thought untangling',
    iconKey: 'heart',
    route: AppRoutes.compassion,
  ),
  RightNowAnchor(
    id: 'dont_know',
    title: 'I do not know what I need',
    subtitle: 'Gentle ambient sound sanctuary',
    iconKey: 'headphones',
    route: AppRoutes.soundscapes,
  ),
];

/// Multi-tab acute distress modal allowing users to either choose an immediate
/// feeling anchor or browse practices grouped by the 6 core regulation groups.
class RightNowModal extends StatefulWidget {
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
  State<RightNowModal> createState() => _RightNowModalState();
}

class _RightNowModalState extends State<RightNowModal> {
  int _selectedTabIndex = 0; // 0 = Acute Anchors, 1 = By Regulation Group

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.90,
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
                        'Choose an urgent feeling or explore by group.',
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

            // Mode Selector Tabs (Acute Anchors vs By Regulation Group)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(RadiusTokens.radiusPill),
                  border: Border.all(color: colors.borderSubtle, width: 1.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModalTab(
                        context,
                        title: 'Acute Anchors',
                        icon: Icons.flash_on_rounded,
                        isSelected: _selectedTabIndex == 0,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTabIndex = 0);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildModalTab(
                        context,
                        title: 'By Regulation Group',
                        icon: Icons.grid_view_rounded,
                        isSelected: _selectedTabIndex == 1,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTabIndex = 1);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: SpacingTokens.spaceSm),

            // Tab Content
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildAcuteAnchorsList(context)
                  : _buildRegulationGroupsList(context),
            ),

            // Bottom Full Library Action
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.screenPaddingH,
                vertical: SpacingTokens.spaceSm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                border: Border(
                  top: BorderSide(color: colors.borderSubtle, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Want to explore all 70 practices?',
                      style: AppTypography.captionSm.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      context.push(AppRoutes.activities);
                    },
                    icon: Icon(Icons.arrow_forward_rounded, size: 16, color: colors.actionSage),
                    label: Text(
                      'Browse Library',
                      style: AppTypography.labelMd.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: MotionTokens.quick,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceCard : Colors.transparent,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusPill),
          border: isSelected
              ? Border.all(color: colors.actionSage.withOpacity(0.4), width: 1.0)
              : Border.all(color: Colors.transparent, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? colors.actionSage : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTypography.labelMd.copyWith(
                color: isSelected ? colors.textPrimary : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcuteAnchorsList(BuildContext context) {
    return ListView.separated(
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
    );
  }

  Widget _buildRegulationGroupsList(BuildContext context) {
    final colors = context.colors;
    final groups = RegulationGroup.values.where((g) => g != RegulationGroup.all).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.screenPaddingH,
        SpacingTokens.spaceXs,
        SpacingTokens.screenPaddingH,
        SpacingTokens.bottomClearance,
      ),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const SizedBox(height: SpacingTokens.elementGap),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              context.push('${AppRoutes.activities}?group=${group.name}');
            },
            borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
            child: Ink(
              padding: const EdgeInsets.all(SpacingTokens.cardPadding),
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                border: Border.all(
                  color: colors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.actionSage.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
                    ),
                    child: Center(
                      child: Icon(
                        _resolveGroupIcon(group),
                        size: 22,
                        color: colors.actionSage,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.displayName,
                          style: AppTypography.headingSm.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          group.description,
                          style: AppTypography.captionSm.copyWith(
                            color: colors.textSecondary,
                            height: 1.35,
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
      },
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
      case 'heart':
      case 'favorite':
        return Icons.favorite_border_rounded;
      case 'headphones':
        return Icons.headphones_outlined;
      default:
        return Icons.spa_outlined;
    }
  }

  IconData _resolveGroupIcon(RegulationGroup group) {
    switch (group) {
      case RegulationGroup.all:
        return Icons.auto_awesome_rounded;
      case RegulationGroup.movement:
        return AppIcons.physical;
      case RegulationGroup.respiration:
        return AppIcons.breathe;
      case RegulationGroup.grounding:
        return AppIcons.nature;
      case RegulationGroup.flow:
        return Icons.psychology_outlined;
      case RegulationGroup.expression:
        return AppIcons.journal;
      case RegulationGroup.restAndSocial:
        return AppIcons.audio;
    }
  }
}
