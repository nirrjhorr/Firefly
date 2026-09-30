import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expressive Journaling',
                style: AppTypography.headingLg.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Private, encrypted reflections. Never synced, never shared.',
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
