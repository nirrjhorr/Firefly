import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Firefly',
                style: AppTypography.displayLg.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'There is no streak here. Come when you need to. Leave when you\'re ready. Your thoughts never leave this device.',
                style: AppTypography.bodyLg.copyWith(
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
