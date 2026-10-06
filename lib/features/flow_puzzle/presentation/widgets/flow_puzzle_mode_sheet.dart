import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/constellation_pattern.dart';
import '../../domain/models/flow_puzzle_type.dart';

/// Modal bottom sheet allowing selection between Flow & Spatial Puzzle modes and constellation patterns.
class FlowPuzzleModeSheet extends StatelessWidget {
  const FlowPuzzleModeSheet({
    super.key,
    required this.currentMode,
    required this.currentConstellation,
    required this.onSelectMode,
    required this.onSelectConstellation,
  });

  final FlowPuzzleMode currentMode;
  final ConstellationPattern currentConstellation;
  final ValueChanged<FlowPuzzleMode> onSelectMode;
  final ValueChanged<ConstellationPattern> onSelectConstellation;

  static Future<void> show(
    BuildContext context, {
    required FlowPuzzleMode currentMode,
    required ConstellationPattern currentConstellation,
    required ValueChanged<FlowPuzzleMode> onSelectMode,
    required ValueChanged<ConstellationPattern> onSelectConstellation,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14191D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.xl)),
      ),
      builder: (context) => FlowPuzzleModeSheet(
        currentMode: currentMode,
        currentConstellation: currentConstellation,
        onSelectMode: onSelectMode,
        onSelectConstellation: onSelectConstellation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg,
          SpacingTokens.md,
          SpacingTokens.lg,
          SpacingTokens.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B4854),
                    borderRadius: BorderRadius.circular(RadiusTokens.pill),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              Text(
                'Flow & Spatial Activities',
                style: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'Non-demanding spatial tasks that absorb working memory to calm racing thoughts.',
                style: context.bodyMedium?.copyWith(
                  color: const Color(0xFF8A98A5),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Mode 1: Constellation Flow
              _ModeSelectionTile(
                title: FlowPuzzleMode.constellationConnect.displayName,
                description: FlowPuzzleMode.constellationConnect.description,
                icon: Icons.auto_awesome,
                isSelected: currentMode == FlowPuzzleMode.constellationConnect,
                onTap: () {
                  onSelectMode(FlowPuzzleMode.constellationConnect);
                },
              ),
              const SizedBox(height: SpacingTokens.sm),

              // Mode 2: Harmony Tiles
              _ModeSelectionTile(
                title: FlowPuzzleMode.spatialSliding.displayName,
                description: FlowPuzzleMode.spatialSliding.description,
                icon: Icons.grid_view,
                isSelected: currentMode == FlowPuzzleMode.spatialSliding,
                onTap: () {
                  onSelectMode(FlowPuzzleMode.spatialSliding);
                  Navigator.pop(context);
                },
              ),

              if (currentMode == FlowPuzzleMode.constellationConnect) ...[
                const SizedBox(height: SpacingTokens.lg),
                Text(
                  'Select Constellation',
                  style: context.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE8B86D),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                ...kCuratedConstellations.map((constellation) {
                  final isChosen = currentConstellation.id == constellation.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                    child: InkWell(
                      onTap: () {
                        onSelectConstellation(constellation);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.md,
                          vertical: SpacingTokens.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          color: isChosen ? const Color(0xFF1E2830) : const Color(0xFF161C22),
                          borderRadius: BorderRadius.circular(RadiusTokens.md),
                          border: Border.all(
                            color: isChosen
                                ? const Color(0xFFE8B86D).withOpacity(0.6)
                                : const Color(0xFF263038),
                            width: isChosen ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isChosen ? Icons.stars : Icons.star_border,
                              color: isChosen ? const Color(0xFFE8B86D) : const Color(0xFF5A6672),
                              size: 20,
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    constellation.name,
                                    style: context.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isChosen ? Colors.white : const Color(0xFFCCD5DD),
                                    ),
                                  ),
                                  Text(
                                    constellation.description,
                                    style: context.bodySmall?.copyWith(
                                      color: const Color(0xFF8A98A5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isChosen)
                              const Icon(
                                Icons.check,
                                color: Color(0xFFE8B86D),
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSelectionTile extends StatelessWidget {
  const _ModeSelectionTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C252E) : const Color(0xFF161C22),
            borderRadius: BorderRadius.circular(RadiusTokens.lg),
            border: Border.all(
              color: isSelected ? const Color(0xFF82A796) : const Color(0xFF263038),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF82A796).withOpacity(0.18)
                      : const Color(0xFF1F272F),
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFF82A796) : const Color(0xFF8A98A5),
                  size: 22,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: context.bodySmall?.copyWith(
                        color: const Color(0xFF8A98A5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
