import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you right now?',
                style: AppTypography.headingLg.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a quiet moment to check in with yourself.',
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
