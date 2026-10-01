import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_routes.dart';
import 'sos_overlay_button.dart';

/// Main navigation shell hosting bottom navigation and the persistent SOS overlay.
class MainShellScaffold extends StatelessWidget {
  const MainShellScaffold({required this.child, super.key});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.breathe)) return 1;
    if (location.startsWith(AppRoutes.journal)) return 2;
    if (location.startsWith(AppRoutes.tinySteps)) return 3;
    if (location.startsWith(AppRoutes.progress)) return 4;
    return 0; // check-in is default (home)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.checkIn);
        break;
      case 1:
        context.go(AppRoutes.breathe);
        break;
      case 2:
        context.go(AppRoutes.journal);
        break;
      case 3:
        context.go(AppRoutes.tinySteps);
        break;
      case 4:
        context.go(AppRoutes.progress);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Stack(
        children: [
          child,
          const Positioned(
            bottom: 24,
            right: 16,
            child: SosOverlayButton(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_twilight_outlined),
            selectedIcon: Icon(Icons.wb_twilight),
            label: 'Check-In',
          ),
          NavigationDestination(
            icon: Icon(Icons.air_outlined),
            selectedIcon: Icon(Icons.air),
            label: 'Breathe',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk),
            label: 'Tiny Steps',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
