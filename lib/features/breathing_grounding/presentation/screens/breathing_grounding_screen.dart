import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BreathingGroundingScreen extends StatelessWidget {
  const BreathingGroundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgCanvasDeep,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Breathe',
                style: AppTypography.displayLg.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cyclic sighing & grounding',
                style: AppTypography.bodyMd.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
