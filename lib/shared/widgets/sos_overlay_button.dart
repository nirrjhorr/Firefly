import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_routes.dart';

/// Persistent 1-tap Safety Plan emergency overlay trigger.
/// Designed to be quiet, dim, non-triggering, yet immediately accessible.
class SosOverlayButton extends StatelessWidget {
  const SosOverlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Emergency Safety Plan',
      hint: 'One-tap access to your offline safety plan and crisis contacts',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.safetyPlan),
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.45),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
