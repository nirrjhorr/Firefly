import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/icon_tokens.dart';
import '../../core/theme/spacing_tokens.dart';
import 'sos_overlay_button.dart';

/// Main navigation shell hosting bottom navigation and the persistent SOS overlay.
/// Crafted with Apple-inspired visual restraint, clear hierarchy, and non-intrusive crisis access.
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
    HapticFeedback.selectionClick();
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
    final colors = context.colors;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: colors.bgCanvasDeep,
      body: Stack(
        children: [
          child,
          const Positioned(
            bottom: SpacingTokens.spaceMd,
            right: SpacingTokens.spaceMd,
            child: SosOverlayButton(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border(
            top: BorderSide(color: colors.borderSubtle, width: 1.0),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: SpacingTokens.navBarHeight,
          indicatorColor: colors.actionSage.withOpacity(0.14),
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) => _onItemTapped(idx, context),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(AppIcons.checkIn, color: colors.textSecondary, size: IconSizeTokens.nav),
              selectedIcon: Icon(AppIcons.checkInSelected, color: colors.actionSage, size: IconSizeTokens.nav),
              label: 'Check-In',
            ),
            NavigationDestination(
              icon: Icon(AppIcons.breathe, color: colors.textSecondary, size: IconSizeTokens.nav),
              selectedIcon: Icon(AppIcons.breatheSelected, color: colors.actionSage, size: IconSizeTokens.nav),
              label: 'Breathe',
            ),
            NavigationDestination(
              icon: Icon(AppIcons.journal, color: colors.textSecondary, size: IconSizeTokens.nav),
              selectedIcon: Icon(AppIcons.journalSelected, color: colors.actionSage, size: IconSizeTokens.nav),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(AppIcons.tinySteps, color: colors.textSecondary, size: IconSizeTokens.nav),
              selectedIcon: Icon(AppIcons.tinyStepsSelected, color: colors.actionSage, size: IconSizeTokens.nav),
              label: 'Tiny Steps',
            ),
            NavigationDestination(
              icon: Icon(AppIcons.progress, color: colors.textSecondary, size: IconSizeTokens.nav),
              selectedIcon: Icon(AppIcons.progressSelected, color: colors.actionSage, size: IconSizeTokens.nav),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }
}
