import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class TinyStepsScreen extends StatelessWidget {
  const TinyStepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiny Steps'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'One small thing',
                style: AppTypography.headingLg.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gentle behavioural micro-actions to help shift momentum.',
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
