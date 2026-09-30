import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SafetyPlanScreen extends StatelessWidget {
  const SafetyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgCanvasDeep,
      appBar: AppBar(
        title: const Text('Safety Plan'),
        backgroundColor: context.colors.bgCanvasDeep,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stanley-Brown Safety Plan',
                style: AppTypography.headingLg.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This plan is stored 100% offline on your device, fully encrypted. It is always accessible with one tap.',
                style: AppTypography.bodyMd.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.crisisSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.colors.crisisAction.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: context.colors.crisisAction,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Firefly supports — it does not replace professional care.',
                        style: AppTypography.caption.copyWith(
                          color: context.colors.crisisText,
                        ),
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
