import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../../../shared/widgets/firefly_empty_state.dart';
import '../../../../shared/widgets/firefly_nav_header.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../domain/models/activity_category.dart';
import '../../domain/models/activity_item.dart';
import '../../domain/models/regulation_group.dart';
import '../providers/activity_providers.dart';

/// Full-catalog Activities Screen organizing all 76 evidence-based practices
/// across the 6 canonical regulation groups defined in PRD v2.0 & Activity Architecture.
class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({
    this.initialGroup,
    super.key,
  });

  final String? initialGroup;

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.initialGroup != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final matchedGroup = RegulationGroup.values.firstWhere(
          (g) => g.name.toLowerCase() == widget.initialGroup!.toLowerCase(),
          orElse: () => RegulationGroup.all,
        );
        ref.read(selectedRegulationGroupProvider.notifier).state = matchedGroup;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedGroup = ref.watch(selectedRegulationGroupProvider);
    final groupCounts = ref.watch(groupActivityCountsProvider);
    final filteredActivities = ref.watch(filteredActivitiesProvider);
    final selectedEnergy = ref.watch(activityEnergyFilterProvider);
    final catalogAsync = ref.watch(activityCatalogProvider);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Navigation Header
                FireflyNavHeader(
                  title: 'Activity Library',
                  subtitle: 'Evidence-based self-regulation practices',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.auto_awesome_rounded,
                          color: colors.accentSecondary,
                          size: IconSizeTokens.appAction,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.push(AppRoutes.profile);
                        },
                        tooltip: 'Personal Sanctuary',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: selectedEnergy != null ? colors.actionSage : colors.textSecondary,
                          size: IconSizeTokens.appAction,
                        ),
                        onPressed: () => _showEnergyFilterModal(context),
                        tooltip: 'Filter by energy level',
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.screenPaddingH,
                    vertical: SpacingTokens.spaceXs,
                  ),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
                      border: Border.all(color: colors.borderSubtle, width: 1.0),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
                      onChanged: (val) {
                        ref.read(activitySearchQueryProvider.notifier).state = val;
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: InputBorder.none,
                        hintText: 'Search by practice, state, or sense...',
                        hintStyle: AppTypography.bodySm.copyWith(color: colors.textTertiary),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colors.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: colors.textTertiary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(activitySearchQueryProvider.notifier).state = '';
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: SpacingTokens.spaceXs),

                // 6 Core Regulation Groups Horizontal Tab Bar
                _RegulationGroupTabBar(
                  selectedGroup: selectedGroup,
                  groupCounts: groupCounts,
                  onGroupSelected: (group) {
                    HapticFeedback.selectionClick();
                    ref.read(selectedRegulationGroupProvider.notifier).state = group;
                  },
                ),

                const SizedBox(height: SpacingTokens.spaceSm),

                // Group Context Overview Banner
                if (selectedGroup != RegulationGroup.all)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
                        border: Border.all(color: colors.borderSubtle, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(selectedGroup.icon, size: 18, color: colors.actionSage),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedGroup.description,
                              style: AppTypography.captionSm.copyWith(
                                color: colors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: SpacingTokens.spaceXs),

                // Activities List
                Expanded(
                  child: catalogAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Unable to load activity catalog.',
                        style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
                      ),
                    ),
                    data: (_) {
                      if (filteredActivities.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: SpacingTokens.space2xl),
                          child: FireflyEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No matching practices',
                            message: 'Try adjusting your search terms or clearing the energy filter.',
                            actionLabel: 'Reset Filters',
                            onAction: () {
                              _searchController.clear();
                              ref.read(activitySearchQueryProvider.notifier).state = '';
                              ref.read(activityEnergyFilterProvider.notifier).state = null;
                              ref.read(selectedRegulationGroupProvider.notifier).state = RegulationGroup.all;
                            },
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          SpacingTokens.screenPaddingH,
                          SpacingTokens.spaceSm,
                          SpacingTokens.screenPaddingH,
                          SpacingTokens.bottomClearance + 40,
                        ),
                        itemCount: filteredActivities.length,
                        separatorBuilder: (context, index) => const SizedBox(height: SpacingTokens.elementGap),
                        itemBuilder: (context, index) {
                          final activity = filteredActivities[index];
                          return _ActivityCard(activity: activity);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // Persistent SOS Shield Button
            const Positioned(
              bottom: SpacingTokens.spaceMd,
              right: SpacingTokens.spaceMd,
              child: SosOverlayButton(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnergyFilterModal(BuildContext context) {
    final colors = context.colors;
    final currentEnergy = ref.read(activityEnergyFilterProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.modalRadius)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.screenPaddingH,
              vertical: SpacingTokens.spaceMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Energy Level',
                  style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose practices that match your current physical & cognitive bandwidth.',
                  style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: SpacingTokens.spaceMd),
                _buildEnergyOption(ctx, null, 'Any Energy (All levels)', currentEnergy == null),
                _buildEnergyOption(ctx, 1, 'Level 1: Minimal (In bed, sitting still)', currentEnergy == 1),
                _buildEnergyOption(ctx, 2, 'Level 2: Gentle (Low movement, slow paced)', currentEnergy == 2),
                _buildEnergyOption(ctx, 3, 'Level 3: Moderate (Some focus or movement)', currentEnergy == 3),
                _buildEnergyOption(ctx, 4, 'Level 4: Active (Physical exertion or coordination)', currentEnergy == 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergyOption(BuildContext context, int? energy, String label, bool isSelected) {
    final colors = context.colors;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? colors.actionSage : colors.textTertiary,
      ),
      title: Text(
        label,
        style: AppTypography.bodyMd.copyWith(
          color: isSelected ? colors.textPrimary : colors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(activityEnergyFilterProvider.notifier).state = energy;
        Navigator.of(context).pop();
      },
    );
  }
}

/// Horizontal scrollable tabs representing the 6 Core Regulation Groups + All.
class _RegulationGroupTabBar extends StatelessWidget {
  const _RegulationGroupTabBar({
    required this.selectedGroup,
    required this.groupCounts,
    required this.onGroupSelected,
  });

  final RegulationGroup selectedGroup;
  final Map<RegulationGroup, int> groupCounts;
  final ValueChanged<RegulationGroup> onGroupSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenPaddingH),
        scrollDirection: Axis.horizontal,
        itemCount: RegulationGroup.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final group = RegulationGroup.values[index];
          final isSelected = group == selectedGroup;
          final count = groupCounts[group] ?? 0;

          return GestureDetector(
            onTap: () => onGroupSelected(group),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: MotionTokens.quick,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colors.actionSage.withOpacity(0.18) : colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(RadiusTokens.radiusPill),
                border: Border.all(
                  color: isSelected ? colors.actionSage : colors.borderSubtle,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    group.icon,
                    size: 15,
                    color: isSelected ? colors.actionSage : colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    group.shortLabel,
                    style: AppTypography.labelMd.copyWith(
                      color: isSelected ? colors.textPrimary : colors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.actionSage.withOpacity(0.25)
                            : colors.borderSubtle,
                        borderRadius: BorderRadius.circular(RadiusTokens.radiusPill),
                      ),
                      child: Text(
                        '$count',
                        style: AppTypography.captionSm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colors.actionSage : colors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Serene Apple-inspired activity card.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FireflyCard(
      variant: FireflyCardVariant.interactive,
      padding: const EdgeInsets.all(SpacingTokens.cardPadding),
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(activity.route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon Halo
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.actionSage.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
                ),
                child: Center(
                  child: Icon(
                    _resolveCategoryIcon(activity.category),
                    size: 20,
                    color: colors.actionSage,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTypography.headingSm.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.category.displayName,
                      style: AppTypography.captionSm.copyWith(
                        color: colors.actionSage,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 16,
                color: colors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          Text(
            activity.description,
            style: AppTypography.bodySm.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),

          // Metadata Chips Row (Duration, Energy, Evidence)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (activity.durationMinutes != null)
                _buildChip(
                  context,
                  icon: Icons.timer_outlined,
                  label: '${activity.durationMinutes} min',
                ),
              _buildChip(
                context,
                icon: Icons.bolt_outlined,
                label: 'Energy ${activity.energyRequired}/5',
              ),
              _buildChip(
                context,
                icon: Icons.verified_outlined,
                label: activity.evidenceLevel.name == 'verified'
                    ? 'Evidence Verified'
                    : 'Clinical Consensus',
                color: colors.accentWarmth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final colors = context.colors;
    final chipColor = color ?? colors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusXs),
        border: Border.all(color: colors.borderSubtle, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.captionSm.copyWith(
              fontSize: 11,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveCategoryIcon(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.physical:
        return AppIcons.physical;
      case ActivityCategory.respiration:
        return AppIcons.breathe;
      case ActivityCategory.sensoryGrounding:
        return AppIcons.sensory;
      case ActivityCategory.cognitiveGrounding:
        return Icons.psychology_outlined;
      case ActivityCategory.flow:
        return Icons.auto_awesome_rounded;
      case ActivityCategory.labyrinth:
        return Icons.gesture_rounded;
      case ActivityCategory.mindfulness:
        return Icons.self_improvement_rounded;
      case ActivityCategory.pmr:
        return Icons.accessibility_new_rounded;
      case ActivityCategory.emotionalExpression:
        return AppIcons.journal;
      case ActivityCategory.behavioralActivation:
        return AppIcons.tinySteps;
      case ActivityCategory.nature:
        return AppIcons.nature;
      case ActivityCategory.audio:
        return AppIcons.audio;
      case ActivityCategory.sleep:
        return Icons.bedtime_outlined;
      case ActivityCategory.social:
        return Icons.people_outline_rounded;
      case ActivityCategory.creative:
        return Icons.palette_outlined;
      case ActivityCategory.cognitiveDefusion:
        return Icons.cloud_outlined;
      case ActivityCategory.selfCompassion:
        return Icons.volunteer_activism_rounded;
      case ActivityCategory.focus:
        return Icons.filter_center_focus_rounded;
    }
  }
}
