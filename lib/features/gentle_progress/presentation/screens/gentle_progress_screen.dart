import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class GentleProgressScreen extends StatelessWidget {
  const GentleProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gentle Progress'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How you\'ve been showing up for yourself',
                style: AppTypography.headingLg.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No streaks. No scores. Just presence.',
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
