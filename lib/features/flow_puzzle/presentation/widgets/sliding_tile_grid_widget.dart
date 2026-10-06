import 'package:flutter/material.dart';

import '../../../../core/theme/animation_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/sliding_grid_state.dart';

/// Interactive tactile 3x3 sliding tile grid widget (Story 13.2).
class SlidingTileGridWidget extends StatelessWidget {
  const SlidingTileGridWidget({
    super.key,
    required this.gridState,
    required this.isSolved,
    required this.moveCount,
    required this.onTileTapped,
    required this.onShuffle,
    required this.onReset,
  });

  final SlidingGridState gridState;
  final bool isSolved;
  final int moveCount;
  final ValueChanged<int> onTileTapped;
  final VoidCallback onShuffle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Grid Container
        Container(
          width: 310,
          height: 310,
          padding: const EdgeInsets.all(SpacingTokens.sm),
          decoration: BoxDecoration(
            color: const Color(0xFF161B20),
            borderRadius: BorderRadius.circular(RadiusTokens.lg),
            border: Border.all(
              color: isSolved ? const Color(0xFF82A796).withOpacity(0.4) : const Color(0xFF263038),
              width: 1.5,
            ),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: SpacingTokens.xs,
              mainAxisSpacing: SpacingTokens.xs,
            ),
            itemBuilder: (context, index) {
              final value = gridState.tiles[index];
              final canMove = gridState.canMove(index);

              if (value == 0) {
                // Empty slot: subtle recessed recess
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1316),
                    borderRadius: BorderRadius.circular(RadiusTokens.md),
                  ),
                );
              }

              return Semantics(
                button: true,
                label: 'Tile $value, ${canMove ? "can slide" : "fixed"}',
                child: InkWell(
                  onTap: () => onTileTapped(index),
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: canMove ? const Color(0xFF222B32) : const Color(0xFF1B2228),
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      border: Border.all(
                        color: canMove
                            ? const Color(0xFF82A796).withOpacity(0.5)
                            : const Color(0xFF2E3A44),
                        width: canMove ? 1.5 : 1.0,
                      ),
                      boxShadow: canMove
                          ? [
                              BoxShadow(
                                color: const Color(0xFF82A796).withOpacity(0.08),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: context.displayMedium?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: canMove ? const Color(0xFFE8B86D) : const Color(0xFFB8C2CC),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: SpacingTokens.md),

        // Solved banner or move hints
        if (isSolved)
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF82A796).withOpacity(0.12),
                borderRadius: BorderRadius.circular(RadiusTokens.pill),
                border: Border.all(
                  color: const Color(0xFF82A796).withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF82A796), size: 18),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    'Harmonious order restored.',
                    style: context.bodyMedium?.copyWith(
                      color: const Color(0xFF82A796),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Text(
            'Tap any highlighted tile adjacent to the space.',
            style: context.bodySmall?.copyWith(
              color: const Color(0xFF8A98A5),
            ),
          ),

        const SizedBox(height: SpacingTokens.md),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onShuffle,
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('Shuffle Gently'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE8B86D),
                side: const BorderSide(color: Color(0xFF3B4854)),
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                minimumSize: const Size(130, 48),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Solve Gently'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8A98A5),
                side: const BorderSide(color: Color(0xFF3B4854)),
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                minimumSize: const Size(130, 48),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
