# Firefly Skills Directory & Catalog

> Comprehensive index of all **115 onboarded agent skills** in the Firefly repository (`.agent/skills/`), organized into 10 functional domains with specific task capabilities and activation triggers.

## Summary by Functional Domain

| # | Domain | Skills Count | Focus Area |
|---|---|---|---|
| 1 | **Flutter & Dart Core Architecture** | `21` | MVVM architecture, Riverpod 3.x, Dart 3 idioms, routing, performance & lifecycle |
| 2 | **Data, Persistence & Domain Value Objects** | `5` | Drift/SQLite persistence, schema migrations, canonical value objects & backup |
| 3 | **UI/UX, Design Systems, Motion & Graphics** | `24` | Design tokens, animations, Apple HIG polish, gestures, canvas & responsive design |
| 4 | **Accessibility & Internationalization** | `3` | WCAG/Semantics-as-code, RTL support, i18n translations & a11y testing |
| 5 | **Hardware, Notifications & Monetization** | `2` | Local push notifications scheduler & rewarded-first monetization/IAP |
| 6 | **Quality, Testing & Code Review** | `8` | Testing strategy, TDD cycles, AI code review & golden regression suites |
| 7 | **Security, Privacy & Compliance** | `3` | OWASP security audits, multi-layer hardening & SAST vulnerability scanning |
| 8 | **Tooling, Codegen, CI/CD & Hygiene** | `9` | Build runner codegen, dependency hygiene, strict linter & GitHub Actions CI |
| 9 | **BMAD Product Lifecycle & Multi-Agent Orchestration** | `29` | Full BMAD framework (PM, UX, Dev, Architect, PRD, Epics, Stories, Retro & Party Mode) |
| 10 | **Developer Discipline, Workflows & Simplicity** | `11` | Ponytail anti-overengineering, Conductor tracks, C4 architecture & prompt patterns |
| | **Total Active Skills** | `115` | Fully cataloged & verified |

---

## 1. FLUTTER & DART CORE ARCHITECTURE (21 Skills)

### 1. `flutter-architecture`
- **Skill Path**: [flutter-architecture](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-architecture/SKILL.md)
- **Tasks Performed**: Feature-first layered MVVM architecture enforcing dumb Views, single 1:1 Notifier ViewModels, and repositories as the sole write path.
- **When & Why to Activate**: Designing new features, folder organization, layer boundaries, or refactoring architectural structure.

### 2. `flutter-expert`
- **Skill Path**: [flutter-expert](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-expert/SKILL.md)
- **Tasks Performed**: Master Flutter development with Dart 3, advanced widgets, reactive state, and multi-platform deployment.
- **When & Why to Activate**: Proactively for all Flutter technical architecture, UI implementation, or cross-platform features.

### 3. `flutter-conventions-index`
- **Skill Path**: [flutter-conventions-index](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-conventions-index/SKILL.md)
- **Tasks Performed**: The repo front-door for Flutter/Dart apps; enforces house rules, architecture DAG, and routes tasks to specialized deep-dive skills.
- **When & Why to Activate**: Starting any Flutter feature, deciding which layer code belongs in, or onboarding to repository conventions.

### 4. `state-management-riverpod`
- **Skill Path**: [state-management-riverpod](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/state-management-riverpod/SKILL.md)
- **Tasks Performed**: Riverpod 3.x state architecture; enforces Notifier/AsyncNotifier ViewModels, watch/read/listen split, family+autoDispose, and bans legacy containers.
- **When & Why to Activate**: Adding state to a screen, writing controllers, wiring dependency injection, or reviewing rebuild leaks.

### 5. `flutter-riverpod-expert`
- **Skill Path**: [flutter-riverpod-expert](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-riverpod-expert/SKILL.md)
- **Tasks Performed**: Expert 2025 Riverpod patterns; AsyncNotifierProvider, code generation, mutations, reactive synchronization, and testing.
- **When & Why to Activate**: Solving complex state flows, AsyncValue handling, autoDispose lifecycles, and asynchronous mutations.

### 6. `flutter-riverpod-init`
- **Skill Path**: [flutter-riverpod-init](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-riverpod-init/SKILL.md)
- **Tasks Performed**: Initializes Flutter projects into runnable scaffolds with Riverpod, go_router, Dio, Freezed, SharedPreferences, and clean architecture.
- **When & Why to Activate**: Bootstrapping a new Flutter project, creating baseline core providers, or setting up app routing scaffolds.

### 7. `scaffold-feature-module`
- **Skill Path**: [scaffold-feature-module](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/scaffold-feature-module/SKILL.md)
- **Tasks Performed**: Scaffolds a complete navigable feature module (dumb View + 1:1 Notifier ViewModel + widgets/ + scoped providers + go_router route).
- **When & Why to Activate**: Adding a new screen, tab, or feature module to ensure strict structural consistency across the codebase.

### 8. `widget-composition`
- **Skill Path**: [widget-composition](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/widget-composition/SKILL.md)
- **Tasks Performed**: Flutter widget composition best practices; extract const Widget classes (never _buildX()), lean build(), controller disposal, and layout optimization.
- **When & Why to Activate**: Authoring or reviewing UI widgets, breaking up oversized build methods, or optimizing widget rendering trees.

### 9. `dart3-idioms-and-coding-standards`
- **Skill Path**: [dart3-idioms-and-coding-standards](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/dart3-idioms-and-coding-standards/SKILL.md)
- **Tasks Performed**: Enforces Dart 3 constructs; sealed classes, exhaustive switches without default, class modifiers, immutable value types, and complexity limits.
- **When & Why to Activate**: Authoring or reviewing types, writing pattern switches, defining value equality, or enforcing class modifiers.

### 10. `async-safety`
- **Skill Path**: [async-safety](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/async-safety/SKILL.md)
- **Tasks Performed**: Eliminates silent async failures; catches unawaited Future drops, enforces mounted guards after every await, and cleans up subscriptions/timers.
- **When & Why to Activate**: Writing async methods, handling mounted checks across BuildContext, or managing asynchronous stream lifecycles.

### 11. `error-handling-typed-results`
- **Skill Path**: [error-handling-typed-results](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/error-handling-typed-results/SKILL.md)
- **Tasks Performed**: Enforces a typed-error spine with sealed Result<T, F> and per-boundary sealed Failure carrying stable error codes instead of localized strings.
- **When & Why to Activate**: Designing service/repository boundaries, handling recoverable failures without throwing exceptions, or writing draft/undo data safety layers.

### 12. `naming-conventions`
- **Skill Path**: [naming-conventions](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/naming-conventions/SKILL.md)
- **Tasks Performed**: Effective Dart casing and architectural role suffixes (Screen, Notifier, Repository, Dao, Service, Failure) so names reveal layers.
- **When & Why to Activate**: Creating new files, naming classes, members, or methods, and organizing grouped/sorted import directives.

### 13. `flutter-performance`
- **Skill Path**: [flutter-performance](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-performance/SKILL.md)
- **Tasks Performed**: Runtime performance optimization; const subtrees, .select rebuild scoping, lazy list builders, off-isolate compute, and surgical RepaintBoundary.
- **When & Why to Activate**: Diagnosing UI jank, tuning long lists/images, offloading heavy computations, or profiling 60/120fps frame rates.

### 14. `app-startup-and-bootstrap`
- **Skill Path**: [app-startup-and-bootstrap](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/app-startup-and-bootstrap/SKILL.md)
- **Tasks Performed**: Fixed main() launch order; error sinks installed first, settings read before runApp, composition-root DI overrides, and lifecycle state flush.
- **When & Why to Activate**: Editing main.dart or bootstrap.dart, reordering initialization routines, or handling app background/resume lifecycle flushes.

### 15. `navigation-and-routing`
- **Skill Path**: [navigation-and-routing](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/navigation-and-routing/SKILL.md)
- **Tasks Performed**: Enforces app-wide GoRouter; path-param identity, redirect guards, StatefulShellRoute tab shells, and PopScope unsaved-changes protection.
- **When & Why to Activate**: Wiring routing, registering deep links, setting up nested tab navigation, or intercepting back-button navigation.

### 16. `service-boundary-and-native`
- **Skill Path**: [service-boundary-and-native](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/service-boundary-and-native/SKILL.md)
- **Tasks Performed**: Isolates side effects and native channels behind throwing abstract interfaces overridden at the composition root; MethodChannel quarantine.
- **When & Why to Activate**: Adding third-party service ports, platform channels, native widget bridges, or injecting Clock/analytics abstractions.

### 17. `ui-states-and-feedback`
- **Skill Path**: [ui-states-and-feedback](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ui-states-and-feedback/SKILL.md)
- **Tasks Performed**: Handles non-happy paths in one switch (loading/empty/error/content); delayed skeletons, typed Failure retry, and the inline-snackbar-modal surface ladder.
- **When & Why to Activate**: Writing loading skeletons, empty filters, error retry states, snackbars, banners, or confirmation dialogs.

### 18. `forms-and-input`
- **Skill Path**: [forms-and-input](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/forms-and-input/SKILL.md)
- **Tasks Performed**: Form + GlobalKey with TextFormField; sync/async validation, FocusNode traversal, keyboard actions, input formatters, and controller disposal.
- **When & Why to Activate**: Building user input forms, managing text editing controllers, focus traversal, or validating input data.

### 19. `dartdoc-conventions`
- **Skill Path**: [dartdoc-conventions](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/dartdoc-conventions/SKILL.md)
- **Tasks Performed**: Effective-Dart public API documentation; one-sentence summaries explaining WHY, documented units/ranges/throws, and [bracket] cross-links.
- **When & Why to Activate**: Authoring public APIs, writing library documentation, or establishing exported barrel comments.

### 20. `write-swift`
- **Skill Path**: [write-swift](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/write-swift/SKILL.md)
- **Tasks Performed**: Modern Swift engineering; value types, Swift 6 data-race safety, concurrency, actors, and AppKit/SwiftUI native platform integration.
- **When & Why to Activate**: Writing or reviewing native iOS/macOS plugins, bridging native Darwin APIs, or debugging Swift concurrency issues.

### 21. `animate-expo`
- **Skill Path**: [animate-expo](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/animate-expo/SKILL.md)
- **Tasks Performed**: React Native and Expo animations; Reanimated, Gesture Handler, Expo Router transitions, and expo-haptics.
- **When & Why to Activate**: Building React Native or Expo mobile apps that require fluid screen transitions, gestures, and haptic feedback.

---

## 2. DATA, PERSISTENCE & DOMAIN VALUE OBJECTS (5 Skills)

### 22. `persistence-drift`
- **Skill Path**: [persistence-drift](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/persistence-drift/SKILL.md)
- **Tasks Performed**: Governs on-device Drift/SQLite data layer; STRICT tables, CHECK/FK constraints, WAL mode, single transaction per mutation, and keyset pagination.
- **When & Why to Activate**: Defining or altering database tables, DAOs, writing transactions, or building WAL-safe backup routines.

### 23. `run-migration`
- **Skill Path**: [run-migration](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/run-migration/SKILL.md)
- **Tasks Performed**: Safe, verified SQLite/Drift schema migrations; step-by-step migration scripts, drift-schema verify tests, and pre-release migration dry runs.
- **When & Why to Activate**: Altering database schemas, adding tables/columns, or running migration verification test suites.

### 24. `value-objects-money-and-units`
- **Skill Path**: [value-objects-money-and-units](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/value-objects-money-and-units/SKILL.md)
- **Tasks Performed**: Pure-Dart value objects storing quantities canonically (integers for minor units, ISO currencies, SI units, UTC timestamps) with largest-remainder allocation.
- **When & Why to Activate**: Handling financial transactions, currencies, measurements, unit calculations, or precision numeric data.

### 25. `data-export-and-restore`
- **Skill Path**: [data-export-and-restore](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/data-export-and-restore/SKILL.md)
- **Tasks Performed**: Offline-first backup and restore engine; atomic VACUUM INTO, ZIP packaging, checksum verification, schema validation, and safe restore.
- **When & Why to Activate**: Implementing user data backup, database exports, cloud restore features, or data migration tools.

### 26. `seeded-determinism-and-golden-vectors`
- **Skill Path**: [seeded-determinism-and-golden-vectors](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/seeded-determinism-and-golden-vectors/SKILL.md)
- **Tasks Performed**: Seeded pseudo-random data generators and deterministic golden vectors for testing, mocks, and reproducible simulation.
- **When & Why to Activate**: Creating repeatable test fixtures, mock data sets, or property-based deterministic testing vectors.

---

## 3. UI/UX, DESIGN SYSTEMS, MOTION & GRAPHICS (24 Skills)

### 27. `design-system-structure`
- **Skill Path**: [design-system-structure](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/design-system-structure/SKILL.md)
- **Tasks Performed**: Scalable design system architecture; design tokens (colors, typography, spacing, elevations), theme extensions, and atomic widget libraries.
- **When & Why to Activate**: Structuring design tokens, extending ThemeExtension, or establishing cohesive styling libraries.

### 28. `adaptive-layout`
- **Skill Path**: [adaptive-layout](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/adaptive-layout/SKILL.md)
- **Tasks Performed**: Adapts layouts based on constraints/size classes (compact, medium, expanded) rather than platform checks; LayoutBuilder, NavigationRail/BottomNav adaptivity.
- **When & Why to Activate**: Building responsive screens, tablet/desktop layouts, master-detail views, or foldable device support.

### 29. `custom-canvas-and-gestures`
- **Skill Path**: [custom-canvas-and-gestures](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/custom-canvas-and-gestures/SKILL.md)
- **Tasks Performed**: High-performance CustomPainter, RenderObject, gesture disambiguation, path operations, and touch drawing.
- **When & Why to Activate**: Creating custom graphic visualizers, audio waveforms, interactive gesture canvases, or specialized charts.

### 30. `motion-and-haptics`
- **Skill Path**: [motion-and-haptics](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/motion-and-haptics/SKILL.md)
- **Tasks Performed**: Interaction feedback design; immediate acknowledgement, HapticTheme intensity mapping, interruptible animations, and bounded celebrations.
- **When & Why to Activate**: Adding micro-interactions, haptic feedback on button presses, celebrations, or screen entry motion.

### 31. `flutter-animations`
- **Skill Path**: [flutter-animations](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-animations/SKILL.md)
- **Tasks Performed**: Deep Flutter animation patterns; AnimationController, Tween, CurvedAnimation, Hero transitions, physics simulations, and staggered sequences.
- **When & Why to Activate**: Building explicit Flutter animations, hero route transitions, physics-based springs, or gesture flings.

### 32. `flutter-animating-apps`
- **Skill Path**: [flutter-animating-apps](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-animating-apps/SKILL.md)
- **Tasks Performed**: Production Flutter motion effects, interactive page routes, shared element heroes, and aesthetic transitions.
- **When & Why to Activate**: Polishing Flutter user interfaces with modern, fluid, production-grade transitions and motion design.

### 33. `logo-design`
- **Skill Path**: [logo-design](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/logo-design/SKILL.md)
- **Tasks Performed**: Vector logo design, app iconography, branding geometry, SVG optimization, and brand asset generation.
- **When & Why to Activate**: Designing brand logos, application icons, marketing marks, or vector graphic identities.

### 34. `apple-design`
- **Skill Path**: [apple-design](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/apple-design/SKILL.md)
- **Tasks Performed**: Human Interface Guidelines (HIG) compliance and polish; Apple design craft, Liquid Glass, typography leading, and iOS/macOS platform conventions.
- **When & Why to Activate**: Auditing UI for Apple HIG compliance, reviewing design aesthetics, or crafting premium iOS interfaces.

### 35. `emil-apple-design`
- **Skill Path**: [emil-apple-design](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/emil-apple-design/SKILL.md)
- **Tasks Performed**: Emil Kowalski's translation of Apple interface physics, fluid gestures, springs, sheets, depth, and momentum for web and mobile.
- **When & Why to Activate**: Building gesture-driven UI, bottom sheets, momentum gestures, or realistic spring animations.

### 36. `emil-design-eng`
- **Skill Path**: [emil-design-eng](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/emil-design-eng/SKILL.md)
- **Tasks Performed**: UI polish and design engineering craft; microscopic details, spring physics, layout shifts, keyboard navigation, and delightful micro-interactions.
- **When & Why to Activate**: Elevating component polish from standard to state-of-the-art, fixing subtle layout jumps, or perfecting interactions.

### 37. `animate`
- **Skill Path**: [animate](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/animate/SKILL.md)
- **Tasks Performed**: Web animation design from scratch; decides tools, properties, duration, curves, interruptibility, and exit transitions.
- **When & Why to Activate**: Adding web motion effects, designing component entrance/exit transitions, or building interactive CSS/JS animations.

### 38. `improve-animations`
- **Skill Path**: [improve-animations](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/improve-animations/SKILL.md)
- **Tasks Performed**: Senior motion advisor codebase audit; scans existing motion code, detects jank or awkward curves, and builds prioritized improvement plans.
- **When & Why to Activate**: Auditing app motion across an entire repository to improve motion feel, performance, and consistency.

### 39. `review-animations`
- **Skill Path**: [review-animations](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/review-animations/SKILL.md)
- **Tasks Performed**: Targeted motion critique; reviews animation diffs, curves, durations, and accessibility fallbacks.
- **When & Why to Activate**: Reviewing animation pull requests or critiquing specific UI transitions against motion guidelines.

### 40. `find-animation-opportunities`
- **Skill Path**: [find-animation-opportunities](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/find-animation-opportunities/SKILL.md)
- **Tasks Performed**: Read-only discovery tool; scans UI for static moments that would benefit from subtle motion.
- **When & Why to Activate**: Surveying screens to identify static elements that feel lifeless and need subtle interactive motion.

### 41. `animation-vocabulary`
- **Skill Path**: [animation-vocabulary](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/animation-vocabulary/SKILL.md)
- **Tasks Performed**: Reverse-lookup motion glossary; maps natural language descriptions to precise motion and animation terms.
- **When & Why to Activate**: Translating user/designer descriptions of motion into accurate technical terms for implementation.

### 42. `frontend-design`
- **Skill Path**: [frontend-design](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/frontend-design/SKILL.md)
- **Tasks Performed**: Distinctive visual design direction; typography, color theory, spacing, and avoiding generic UI patterns.
- **When & Why to Activate**: Shaping unique visual identities for websites or web apps to avoid generic, templated aesthetics.

### 43. `responsive-design`
- **Skill Path**: [responsive-design](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/responsive-design/SKILL.md)
- **Tasks Performed**: Modern responsive layouts; fluid typography, container queries, CSS Grid, and mobile-first breakpoint systems.
- **When & Why to Activate**: Building adaptive web pages, fluid component layouts, or debugging cross-device responsive rendering.

### 44. `mobile-native`
- **Skill Path**: [mobile-native](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/mobile-native/SKILL.md)
- **Tasks Performed**: Web-to-native mobile polish; fixes sticky hovers, 100vh viewport bugs, tap delays, notch safe areas, and mobile browser quirks.
- **When & Why to Activate**: Optimizing web apps or PWAs to feel indistinguishable from native mobile applications on touch devices.

### 45. `break-ui`
- **Skill Path**: [break-ui](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/break-ui/SKILL.md)
- **Tasks Performed**: Stress-tests UI components with worst-case data (huge strings, emoji, zero states, extreme numbers) to expose layout breaks.
- **When & Why to Activate**: Testing UI robustness before shipping by feeding extreme edge-case data into components and screens.

### 46. `prototype`
- **Skill Path**: [prototype](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/prototype/SKILL.md)
- **Tasks Performed**: Rapid UI prototyping and interactive mockups; builds functional prototypes to validate ideas before full production engineering.
- **When & Why to Activate**: Validating early product ideas, interaction models, or exploratory features with lightweight functional mockups.

### 47. `pick-ui-library`
- **Skill Path**: [pick-ui-library](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/pick-ui-library/SKILL.md)
- **Tasks Performed**: Objective evaluation framework for UI libraries and component frameworks based on bundle size, accessibility, and maintenance.
- **When & Why to Activate**: Evaluating third-party UI component libraries or making architectural technology stack decisions.

### 48. `better-icons`
- **Skill Path**: [better-icons](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/better-icons/SKILL.md)
- **Tasks Performed**: CLI and MCP integration for searching and retrieving SVGs from over 200 icon libraries (Iconify).
- **When & Why to Activate**: Searching for, selecting, and downloading clean SVG icon assets for user interface components.

### 49. `ask-sonner`
- **Skill Path**: [ask-sonner](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ask-sonner/SKILL.md)
- **Tasks Performed**: Comprehensive guide to Sonner toast notifications in React; promise toasts, styling, position, and modal layering.
- **When & Why to Activate**: Implementing, positioning, or troubleshooting Sonner toast notifications in React applications.

### 50. `frontend-mobile-development-component-scaffold`
- **Skill Path**: [frontend-mobile-development-component-scaffold](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/frontend-mobile-development-component-scaffold/SKILL.md)
- **Tasks Performed**: Scaffolds production-ready, accessible, and performant React/mobile components with TypeScript and tests.
- **When & Why to Activate**: Scaffolding new React or React Native component files with complete typing, tests, and styles.

---

## 4. ACCESSIBILITY & INTERNATIONALIZATION (3 Skills)

### 51. `accessibility-as-code`
- **Skill Path**: [accessibility-as-code](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/accessibility-as-code/SKILL.md)
- **Tasks Performed**: Enforces a11y as a compile-time correctness property; Semantics labels, 44px tap targets, 4.5:1 contrast, boldText/reduce-motion support.
- **When & Why to Activate**: Authoring tap targets, icons, images, text styles, or reviewing views for screen reader accessibility.

### 52. `i18n-rtl-l10n`
- **Skill Path**: [i18n-rtl-l10n](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/i18n-rtl-l10n/SKILL.md)
- **Tasks Performed**: Comprehensive localization, RTL layout mirroring, plural rules, number/date formatting, and ARB translation parity.
- **When & Why to Activate**: Adding multi-language translation strings, supporting right-to-left scripts, or formatting locale-sensitive data.

### 53. `widget-golden-and-a11y-testing`
- **Skill Path**: [widget-golden-and-a11y-testing](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/widget-golden-and-a11y-testing/SKILL.md)
- **Tasks Performed**: Widget and accessibility test harness; verifies semantics tree, contrast calculations, font scaling, and automated a11y checks.
- **When & Why to Activate**: Writing automated accessibility tests, verifying contrast compliance, or testing font scaling behaviors.

---

## 5. HARDWARE, NOTIFICATIONS & MONETIZATION (2 Skills)

### 54. `local-notifications-scheduler`
- **Skill Path**: [local-notifications-scheduler](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/local-notifications-scheduler/SKILL.md)
- **Tasks Performed**: Local notifications engine with DB as source of truth, idempotent syncNotifications reconciliation, wall-clock recurrence, DST handling, and boot re-arm.
- **When & Why to Activate**: Scheduling local push notifications, recurring reminders, managing device boot alarms, or timezone calculations.

### 55. `ads-and-iap-monetization`
- **Skill Path**: [ads-and-iap-monetization](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ads-and-iap-monetization/SKILL.md)
- **Tasks Performed**: Opt-in rewarded monetization, single write-path purchase verification, non-consumable restore, and entitlement gating before ad SDK initialization.
- **When & Why to Activate**: Wiring rewarded video earn loops, interstitial ads, in-app purchases, subscription paywalls, or feature gating.

---

## 6. QUALITY, TESTING & CODE REVIEW (8 Skills)

### 56. `testing-strategy`
- **Skill Path**: [testing-strategy](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/testing-strategy/SKILL.md)
- **Tasks Performed**: Architectural test strategy; pure package tests, seeded fuzz testing, ProviderContainer headless tests, and Drift in-memory database suites.
- **When & Why to Activate**: Establishing testing standards, writing integration test suites, or designing robust unit testing layers.

### 57. `tdd-workflows-tdd-cycle`
- **Skill Path**: [tdd-workflows-tdd-cycle](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/tdd-workflows-tdd-cycle/SKILL.md)
- **Tasks Performed**: Strict Test-Driven Development (Red-Green-Refactor); writes failing tests first, minimal implementation to pass, and safe refactoring.
- **When & Why to Activate**: Implementing new domain logic, bug fixes, or complex algorithms following disciplined TDD cycles.

### 58. `unit-testing-test-generate`
- **Skill Path**: [unit-testing-test-generate](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/unit-testing-test-generate/SKILL.md)
- **Tasks Performed**: Generates maintainable, edge-case focused unit tests across languages and frameworks.
- **When & Why to Activate**: Writing automated unit test suites for functions, classes, and business logic with high branch coverage.

### 59. `e2e-testing-patterns`
- **Skill Path**: [e2e-testing-patterns](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/e2e-testing-patterns/SKILL.md)
- **Tasks Performed**: End-to-end testing strategies using Playwright and Cypress; reliable selectors, network mocks, and flaky test prevention.
- **When & Why to Activate**: Authoring end-to-end browser tests, stabilizing flaky test suites, or setting up test automation frameworks.

### 60. `flutter-dart-code-review`
- **Skill Path**: [flutter-dart-code-review](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/flutter-dart-code-review/SKILL.md)
- **Tasks Performed**: Comprehensive Flutter/Dart code review checklist covering state management, performance, a11y, idioms, and architecture.
- **When & Why to Activate**: Conducting thorough peer reviews of Flutter code diffs, pull requests, or evaluating architectural compliance.

### 61. `code-review-ai-ai-review`
- **Skill Path**: [code-review-ai-ai-review](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/code-review-ai-ai-review/SKILL.md)
- **Tasks Performed**: AI-assisted static analysis and pattern recognition code reviews across multiple languages.
- **When & Why to Activate**: Performing automated multi-language static code reviews or identifying hidden bugs and regressions.

### 62. `design-review-workflow`
- **Skill Path**: [design-review-workflow](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/design-review-workflow/SKILL.md)
- **Tasks Performed**: Structured design review process comparing implemented UI against design specs, tokens, and UX guidelines.
- **When & Why to Activate**: Validating visual parity between Figma/design specifications and implemented UI components.

### 63. `run-goldens-rebaseline`
- **Skill Path**: [run-goldens-rebaseline](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/run-goldens-rebaseline/SKILL.md)
- **Tasks Performed**: Golden file generation, comparison, and rebaselining workflow under strict OS font and rendering controls.
- **When & Why to Activate**: Updating visual regression golden files, rebaselining screen snapshots, or debugging golden test failures.

---

## 7. SECURITY, PRIVACY & COMPLIANCE (3 Skills)

### 64. `security-auditor`
- **Skill Path**: [security-auditor](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/security-auditor/SKILL.md)
- **Tasks Performed**: Deep security audits; OWASP Top 10, authentication/OAuth2, threat modeling, cloud posture, and compliance (GDPR, HIPAA, SOC2).
- **When & Why to Activate**: Conducting security vulnerability assessments, reviewing authentication flows, or auditing compliance.

### 65. `security-scanning-security-hardening`
- **Skill Path**: [security-scanning-security-hardening](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/security-scanning-security-hardening/SKILL.md)
- **Tasks Performed**: Multi-layer security hardening across dependencies, containers, infrastructure, and secrets management.
- **When & Why to Activate**: Hardening application builds, reviewing dependency vulnerabilities, or implementing DevSecOps controls.

### 66. `sast-configuration`
- **Skill Path**: [sast-configuration](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/sast-configuration/SKILL.md)
- **Tasks Performed**: Static Application Security Testing (SAST) tool configuration and CI automation for vulnerability detection.
- **When & Why to Activate**: Setting up automated static security analysis tools in CI/CD pipelines to catch security flaws early.

---

## 8. TOOLING, CODEGEN, CI/CD & HYGIENE (9 Skills)

### 67. `codegen-and-toolchain`
- **Skill Path**: [codegen-and-toolchain](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/codegen-and-toolchain/SKILL.md)
- **Tasks Performed**: Deterministic build_runner discipline; build.yaml scoping, gitignore-vs-commit rules for *.g.dart, and CI freshness gates.
- **When & Why to Activate**: Configuring build_runner code generation, resolving build conflicts, or setting up generated file excludes.

### 68. `run-codegen`
- **Skill Path**: [run-codegen](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/run-codegen/SKILL.md)
- **Tasks Performed**: Executes build_runner and code generators with clean outputs, scoped builders, and conflict resolution.
- **When & Why to Activate**: Regenerating Freezed, Riverpod, Drift, or JSON serialization code during active feature development.

### 69. `dependency-hygiene`
- **Skill Path**: [dependency-hygiene](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/dependency-hygiene/SKILL.md)
- **Tasks Performed**: Pubspec and lockfile discipline; caret ranges, lockfile pinning, transitive dependency audits, and license checks.
- **When & Why to Activate**: Adding or upgrading dependencies, auditing third-party transitive packages, or resolving version conflicts.

### 70. `lint-and-style-config`
- **Skill Path**: [lint-and-style-config](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/lint-and-style-config/SKILL.md)
- **Tasks Performed**: Strict analysis_options.yaml with very_good_analysis, error promotions, strict casts, and formatting enforcement.
- **When & Why to Activate**: Configuring Dart analyzer linter rules, enabling strict type checks, or diagnosing analyzer warnings.

### 71. `ci-pipeline-and-gates`
- **Skill Path**: [ci-pipeline-and-gates](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ci-pipeline-and-gates/SKILL.md)
- **Tasks Performed**: Lean GitHub Actions Flutter CI; pinned runners, formatting, fatal analyzer infos, build_runner freshness, and randomized tests.
- **When & Why to Activate**: Authoring or updating GitHub Actions workflows, setting up quality gates, or optimizing CI build speeds.

### 72. `cicd-automation-workflow-automate`
- **Skill Path**: [cicd-automation-workflow-automate](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/cicd-automation-workflow-automate/SKILL.md)
- **Tasks Performed**: General CI/CD pipeline automation and workflow optimization for multi-stage deployments.
- **When & Why to Activate**: Automating complex deployment pipelines, branch protection workflows, or artifact publishing.

### 73. `github-actions-templates`
- **Skill Path**: [github-actions-templates](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/github-actions-templates/SKILL.md)
- **Tasks Performed**: Production-ready GitHub Actions templates for automated testing, matrix builds, release packaging, and publishing.
- **When & Why to Activate**: Quickly setting up reusable CI/CD workflows using standardized GitHub Actions templates.

### 74. `release-and-store-shipping`
- **Skill Path**: [release-and-store-shipping](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/release-and-store-shipping/SKILL.md)
- **Tasks Performed**: Production release checklist; version bumping, app signing, store metadata, ProGuard/obfuscation, and release bundle generation.
- **When & Why to Activate**: Preparing release builds for Google Play or Apple App Store submission and release checklist validation.

### 75. `project-structure-and-packages`
- **Skill Path**: [project-structure-and-packages](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/project-structure-and-packages/SKILL.md)
- **Tasks Performed**: Scaffolds maintainable monorepos and packages; feature-first folders, clean foundation layering, and modular architecture.
- **When & Why to Activate**: Restructuring project folders, extracting shared logic into pure packages, or enforcing dependency boundaries.

---

## 9. BMAD PRODUCT LIFECYCLE & MULTI-AGENT ORCHESTRATION (29 Skills)

### 76. `bmad-agent-pm`
- **Skill Path**: [bmad-agent-pm](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-agent-pm/SKILL.md)
- **Tasks Performed**: Product Manager agent persona (John) for PRD creation, feature prioritization, and requirements discovery.
- **When & Why to Activate**: Engaging the BMAD Product Manager persona to lead product definition and requirement gathering.

### 77. `bmad-agent-analyst`
- **Skill Path**: [bmad-agent-analyst](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-agent-analyst/SKILL.md)
- **Tasks Performed**: Business Analyst agent persona (Mary) for market research, competitive analysis, and feasibility studies.
- **When & Why to Activate**: Engaging the BMAD Business Analyst persona to investigate market viability and competitive landscapes.

### 78. `bmad-agent-architect`
- **Skill Path**: [bmad-agent-architect](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-agent-architect/SKILL.md)
- **Tasks Performed**: System Architect agent persona (Winston) for high-level technical design, component boundaries, and architecture spines.
- **When & Why to Activate**: Engaging the BMAD System Architect persona to design technical blueprints and structural boundaries.

### 79. `bmad-agent-ux-designer`
- **Skill Path**: [bmad-agent-ux-designer](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-agent-ux-designer/SKILL.md)
- **Tasks Performed**: UX Designer agent persona (Sally) for user flows, interaction specs, and wireframe definitions.
- **When & Why to Activate**: Engaging the BMAD UX Designer persona to design intuitive user experiences and interaction models.

### 80. `bmad-agent-dev`
- **Skill Path**: [bmad-agent-dev](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-agent-dev/SKILL.md)
- **Tasks Performed**: Senior Software Engineer agent persona (Amelia) for story implementation, coding, and technical problem solving.
- **When & Why to Activate**: Engaging the BMAD Developer persona to execute feature stories, write clean code, and debug issues.

### 81. `bmad-prd`
- **Skill Path**: [bmad-prd](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-prd/SKILL.md)
- **Tasks Performed**: Author, update, and validate comprehensive Product Requirement Documents (PRD).
- **When & Why to Activate**: Creating, refining, or validating PRD specifications before technical architecture begins.

### 82. `bmad-product-brief`
- **Skill Path**: [bmad-product-brief](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-product-brief/SKILL.md)
- **Tasks Performed**: Author and validate high-level product briefs and vision statements.
- **When & Why to Activate**: Initiating new product discovery, defining high-level goals, and scoping project boundaries.

### 83. `bmad-prfaq`
- **Skill Path**: [bmad-prfaq](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-prfaq/SKILL.md)
- **Tasks Performed**: Amazon Working Backwards PRFAQ methodology; draft press releases and customer/stakeholder FAQs before building.
- **When & Why to Activate**: Validating high-risk product concepts from a customer perspective before investing engineering effort.

### 84. `bmad-spec`
- **Skill Path**: [bmad-spec](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-spec/SKILL.md)
- **Tasks Performed**: Condense briefs, transcripts, or notes into actionable SPEC.md documents and user stories.
- **When & Why to Activate**: Distilling unorganized notes or user feedback into structured technical specification documents.

### 85. `bmad-architecture`
- **Skill Path**: [bmad-architecture](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-architecture/SKILL.md)
- **Tasks Performed**: Author and validate system architecture spines and technical design documents.
- **When & Why to Activate**: Documenting system architecture, data flows, and component interfaces across a product.

### 86. `bmad-ux`
- **Skill Path**: [bmad-ux](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-ux/SKILL.md)
- **Tasks Performed**: Author DESIGN.md and EXPERIENCE.md for visual guidelines and interaction models.
- **When & Why to Activate**: Documenting UX specifications, visual style rules, interaction behaviors, and user journeys.

### 87. `bmad-create-epics-and-stories`
- **Skill Path**: [bmad-create-epics-and-stories](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-create-epics-and-stories/SKILL.md)
- **Tasks Performed**: Decompose PRDs and specs into structured epics, user stories, and acceptance criteria.
- **When & Why to Activate**: Breaking down product requirements into bite-sized, implementable stories during sprint planning.

### 88. `bmad-sprint-planning`
- **Skill Path**: [bmad-sprint-planning](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-sprint-planning/SKILL.md)
- **Tasks Performed**: Verify implementation readiness and generate sprint-status.yaml tracking files.
- **When & Why to Activate**: Checking implementation readiness, prioritizing sprint backlogs, and initializing sprint tracking.

### 89. `bmad-build`
- **Skill Path**: [bmad-build](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-build/SKILL.md)
- **Tasks Performed**: Autonomous story implementation engine; executes stories with verification, tests, and code reviews.
- **When & Why to Activate**: Delegating feature implementation, bug fixes, or story tasks to autonomous development workflows.

### 90. `bmad-build-auto`
- **Skill Path**: [bmad-build-auto](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-build-auto/SKILL.md)
- **Tasks Performed**: Unattended iterative development loop executing consecutive stories.
- **When & Why to Activate**: Running autonomous, batch implementation of backlog stories in an unattended loop.

### 91. `bmad-code-review`
- **Skill Path**: [bmad-code-review](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-code-review/SKILL.md)
- **Tasks Performed**: Multi-perspective parallel code review with triaged findings and severity ratings.
- **When & Why to Activate**: Conducting rigorous multi-agent code reviews on pull requests or major implementation diffs.

### 92. `bmad-review`
- **Skill Path**: [bmad-review](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-review/SKILL.md)
- **Tasks Performed**: Multi-lens review engine examining diffs for edge cases, verification gaps, and architectural alignment.
- **When & Why to Activate**: Running deep multi-lens critiques on code changes, technical specs, or documentation artifacts.

### 93. `bmad-walkthrough`
- **Skill Path**: [bmad-walkthrough](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-walkthrough/SKILL.md)
- **Tasks Performed**: Interactive walkthrough guiding developers through changes, testing steps, and review notes.
- **When & Why to Activate**: Walking stakeholders through implemented code changes, testing instructions, and validation notes.

### 94. `bmad-correct-course`
- **Skill Path**: [bmad-correct-course](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-correct-course/SKILL.md)
- **Tasks Performed**: Mid-sprint impact analysis and course correction proposals across PRD, epics, and architecture.
- **When & Why to Activate**: Adapting plans when requirements change mid-sprint or unanticipated obstacles arise.

### 95. `bmad-retrospective`
- **Skill Path**: [bmad-retrospective](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-retrospective/SKILL.md)
- **Tasks Performed**: Epic and sprint retrospective analysis based on commit history, specs, and outcomes.
- **When & Why to Activate**: Reflecting on sprint execution, assessing delivered outcomes, and documenting continuous improvements.

### 96. `bmad-deep-recon`
- **Skill Path**: [bmad-deep-recon](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-deep-recon/SKILL.md)
- **Tasks Performed**: Deep topic research across market, technical, domain, and competitive dimensions.
- **When & Why to Activate**: Conducting deep, evidence-based research on unknown technical domains, APIs, or competitors.

### 97. `bmad-brainstorming`
- **Skill Path**: [bmad-brainstorming](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-brainstorming/SKILL.md)
- **Tasks Performed**: Creative ideation using structured brainstorming methodologies (SCAMPER, Six Thinking Hats).
- **When & Why to Activate**: Generating creative solutions for product features, UX challenges, or complex problems.

### 98. `bmad-forge-idea`
- **Skill Path**: [bmad-forge-idea](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-forge-idea/SKILL.md)
- **Tasks Performed**: Multi-persona idea stress-testing to probe weak points and harden product hypotheses.
- **When & Why to Activate**: Challenging and refining raw, unproven concepts before committing development resources.

### 99. `bmad-advanced-elicitation`
- **Skill Path**: [bmad-advanced-elicitation](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-advanced-elicitation/SKILL.md)
- **Tasks Performed**: Socratic, first-principles, and pre-mortem probing to push LLM thinking to higher depth.
- **When & Why to Activate**: Pushing technical discussions or design proposals deeper using first-principles questioning.

### 100. `bmad-party-mode`
- **Skill Path**: [bmad-party-mode](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-party-mode/SKILL.md)
- **Tasks Performed**: Orchestrates multi-agent roundtables and dynamic discussions among diverse agent personas.
- **When & Why to Activate**: Facilitating roundtables where multiple AI specialist personas debate design tradeoffs.

### 101. `bmad-qa-generate-e2e-tests`
- **Skill Path**: [bmad-qa-generate-e2e-tests](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-qa-generate-e2e-tests/SKILL.md)
- **Tasks Performed**: Generates automated API and end-to-end tests for newly implemented features.
- **When & Why to Activate**: Authoring automated end-to-end integration tests to verify newly implemented feature stories.

### 102. `bmad-project-context`
- **Skill Path**: [bmad-project-context](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-project-context/SKILL.md)
- **Tasks Performed**: Sets up and audits repository AGENTS.md instructions and recorded pitfalls.
- **When & Why to Activate**: Refreshing agent operating context, recording developer pitfalls, or onboarding AI agents.

### 103. `bmad-customize`
- **Skill Path**: [bmad-customize](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-customize/SKILL.md)
- **Tasks Performed**: Authors and updates custom overrides for BMAD skills and agent behaviors.
- **When & Why to Activate**: Customizing BMAD prompts, adjusting persona behaviors, or extending workflow templates.

### 104. `bmad-help`
- **Skill Path**: [bmad-help](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/bmad-help/SKILL.md)
- **Tasks Performed**: Intelligent router analyzing current state to recommend the optimal BMAD skill.
- **When & Why to Activate**: Seeking guidance on which BMAD workflow, tool, or next step to take in a project.

---

## 10. DEVELOPER DISCIPLINE, WORKFLOWS & SIMPLICITY (11 Skills)

### 105. `ponytail`
- **Skill Path**: [ponytail](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ponytail/SKILL.md)
- **Tasks Performed**: Extreme simplicity and minimalism; enforces the laziest effective solution, YAGNI, standard library first, zero bloat.
- **When & Why to Activate**: Any coding or architecture task to resist speculative complexity and keep code minimal and clean.

### 106. `ponytail-review`
- **Skill Path**: [ponytail-review](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ponytail-review/SKILL.md)
- **Tasks Performed**: Over-engineering code review; hunts speculative abstractions, reinvented standard library features, and unnecessary dependencies.
- **When & Why to Activate**: Reviewing diffs or pull requests specifically to identify and eliminate unnecessary complexity.

### 107. `ponytail-audit`
- **Skill Path**: [ponytail-audit](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ponytail-audit/SKILL.md)
- **Tasks Performed**: Repository-wide simplicity audit; identifies bloated files, dead flexibility, and complex code to delete.
- **When & Why to Activate**: Scanning codebases for bloat, unnecessary packages, or over-engineered abstractions to remove.

### 108. `ponytail-debt`
- **Skill Path**: [ponytail-debt](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ponytail-debt/SKILL.md)
- **Tasks Performed**: Tracks ponytail: shortcut and deferral comments across the codebase into an actionable debt ledger.
- **When & Why to Activate**: Reviewing and triaging intentional shortcuts, temporary deferrals, and technical debt markers.

### 109. `ponytail-gain`
- **Skill Path**: [ponytail-gain](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ponytail-gain/SKILL.md)
- **Tasks Performed**: Displays measured impact scoreboard (lines deleted, complexity reduced, build speed gained).
- **When & Why to Activate**: Evaluating simplicity gains and productivity improvements achieved through code reduction.

### 110. `ponytail-help`
- **Skill Path**: [ponytail-help](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/ponytail-help/SKILL.md)
- **Tasks Performed**: Quick-reference cheat sheet for all Ponytail simplicity modes and intensity levels.
- **When & Why to Activate**: Referencing available Ponytail modes, intensity flags, and simplicity guidelines.

### 111. `conductor-implement`
- **Skill Path**: [conductor-implement](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/conductor-implement/SKILL.md)
- **Tasks Performed**: Executes tasks from a Conductor track's implementation plan with strict TDD workflow.
- **When & Why to Activate**: Implementing tasks from an approved Conductor feature track following TDD principles.

### 112. `conductor-new-track`
- **Skill Path**: [conductor-new-track](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/conductor-new-track/SKILL.md)
- **Tasks Performed**: Creates a new specification track with phased implementation plans and milestones.
- **When & Why to Activate**: Planning and breaking down major multi-phase feature initiatives using Conductor tracks.

### 113. `context-driven-development`
- **Skill Path**: [context-driven-development](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/context-driven-development/SKILL.md)
- **Tasks Performed**: Context-driven development methodology managing product.md, tech-stack.md, and workflow.md artifacts.
- **When & Why to Activate**: Structuring, updating, and aligning project-level context documents and architecture blueprints.

### 114. `c4-architecture-c4-architecture`
- **Skill Path**: [c4-architecture-c4-architecture](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/c4-architecture-c4-architecture/SKILL.md)
- **Tasks Performed**: Generates comprehensive bottom-up C4 architectural documentation (Context, Container, Component, Code).
- **When & Why to Activate**: Documenting complex codebases with structured C4 architectural models and relationship maps.

### 115. `prompt-engineering-patterns`
- **Skill Path**: [prompt-engineering-patterns](file:///c:/Users/mdhas/Documents/Firefly/.agent/skills/prompt-engineering-patterns/SKILL.md)
- **Tasks Performed**: Production prompt engineering patterns; few-shot templates, chain-of-thought, safety guardrails, and structured outputs.
- **When & Why to Activate**: Designing, optimizing, and evaluating production system prompts and AI agent instructions.

---
