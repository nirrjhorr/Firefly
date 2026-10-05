# Story 10.6: App Router, Shell Navigation & SOS Panic Compatibility

Status: done
Epic: 10 - v2 State-Based Regulation Architecture & Core Suite
FR: FR-01, FR-09, FR-11, FR-12

## Overview
Registered routing configuration for all v2 core features in the GoRouter hierarchy, supporting both shell-nested routes and root modal flows, while guaranteeing full compatibility with Firefly's strict < 100ms SOS panic blank exit sequence and persistent Stanley-Brown safety overlay.

## Registered Routes
- `/home/pmr` (`AppRoutes.pmr`): Nested in MainShellScaffold bottom navigation.
- `/pmr`: Root modal presentation over any active screen with persistent SOS floating button.
- `/home/right-now` (`AppRoutes.rightNow`): Fast-path distress anchor routing.
- `/home/breathe?technique=...`: Query parameter technique selection for deep-linking.
- `/safety-plan` & `/panic`: Root-level emergency transitions accessible from any screen in ≤ 100ms.

## Changes Implemented
- [x] **Route Constants**:
  - `lib/core/routing/app_routes.dart`: Added `AppRoutes.pmr` and `AppRoutes.rightNow`.
- [x] **Router Configuration**:
  - `lib/core/routing/app_router.dart`:
    - Registered `AppRoutes.pmr` in `ShellRoute`.
    - Registered `/pmr` modal route in root navigator.
    - Preserved zero-logging privacy requirement (`debugLogDiagnostics: false`).
- [x] **Safety Integration**:
  - Validated that `SosOverlayButton` and `PanicBlankScreen` remain directly accessible from PMR, Breathing, and Right Now screens.
- [x] **Verification**:
  - `test/core/routing/verify_routing_standalone.dart`: 100% assertions passed.
