# DESIGN_SYSTEM_AND_TOKENS.md
# Firefly — Design System & Styling Specification

**Version:** 1.0.0
**Date:** 2026-09-30
**Status:** Sprint 0 — Approved Baseline

> **Design Philosophy:** Firefly is a quiet companion, not a productivity tool. Every visual decision must reduce cognitive load, never add to it. The interface should feel like a dimly lit room at the end of a hard day — warm, unhurried, and entirely yours. No confetti. No streaks. No urgency.

---

## Table of Contents
1. [Color Palette & Token Architecture](#1-color-palette--token-architecture)
2. [Typography System & Type Scale](#2-typography-system--type-scale)
3. [Component Design & Touch Targets](#3-component-design--touch-targets)
4. [Motion, Haptics & Spatial Layout Tokens](#4-motion-haptics--spatial-layout-tokens)
5. [Flutter Code Implementation](#5-flutter-code-implementation)

---

## 1. Color Palette & Token Architecture

### 1.1 Design Rationale

All colors are drawn from a natural, desaturated palette: deep slate skies, weathered sage, warm candlelight, and the blue-grey of pre-dawn hours. No pure primaries. No neon highlights. Crisis-adjacent UI (the Safety Plan button) uses a **muted warm coral** — communicating importance without triggering alarm.

**WCAG 2.2 AAA Compliance Target:** All text-on-background combinations must achieve ≥ 7:1 contrast ratio. Interactive controls (buttons, selectors) must achieve ≥ 4.5:1.

---

### 1.2 Raw Color Primitives

These are the base palette values. **Never reference these directly in UI code** — always use semantic tokens defined in §1.3.

#### Deep Rest Palette (Dark Mode Foundation)

| Token Name | Hex | HSL | Description |
|---|---|---|---|
| `primitive-ink-950` | `#0A0D0F` | `210° 20% 5%` | True OLED black canvas |
| `primitive-ink-900` | `#111518` | `210° 20% 8%` | Primary dark background |
| `primitive-ink-800` | `#191E23` | `210° 18% 12%` | Elevated surface |
| `primitive-ink-700` | `#232B32` | `210° 17% 17%` | Card / Sheet surface |
| `primitive-ink-600` | `#2E3840` | `210° 16% 22%` | Subtle divider / border |
| `primitive-ink-500` | `#3E4A54` | `210° 15% 28%` | Disabled element fill |
| `primitive-neutral-400` | `#6B7E8C` | `210° 13% 49%` | Muted / secondary text |
| `primitive-neutral-300` | `#9AAAB6` | `210° 14% 66%` | Secondary text |
| `primitive-neutral-200` | `#C4CDD4` | `210° 12% 80%` | Primary text (dark mode) |
| `primitive-neutral-100` | `#E8ECF0` | `210° 15% 93%` | High-contrast text (dark mode) |
| `primitive-neutral-050` | `#F5F7F9` | `210° 20% 97%` | Near-white (dark mode headings) |

#### Sage Grounding Palette

| Token Name | Hex | HSL | Description |
|---|---|---|---|
| `primitive-sage-900` | `#1C2922` | `150° 18% 13%` | Deep forest (dark bg accent) |
| `primitive-sage-700` | `#2D4A3A` | `150° 24% 23%` | Grounding surface tint |
| `primitive-sage-500` | `#4A7862` | `150° 23% 38%` | Sage mid — interactive |
| `primitive-sage-400` | `#5D9478` | `150° 22% 47%` | Sage light — hover state |
| `primitive-sage-300` | `#84B09A` | `150° 19% 61%` | Sage muted — icon fills |
| `primitive-sage-200` | `#B5CEBC` | `150° 17% 76%` | Sage pale — decorative |
| `primitive-sage-100` | `#DFF0E6` | `150° 32% 91%` | Sage tint (light mode bg) |

#### Dusk Blue Palette

| Token Name | Hex | HSL | Description |
|---|---|---|---|
| `primitive-dusk-900` | `#131B2E` | `220° 39% 13%` | Pre-dawn deep blue |
| `primitive-dusk-700` | `#1E3050` | `220° 43% 21%` | Breathing session bg |
| `primitive-dusk-500` | `#2E5080` | `220° 45% 34%` | Calm blue — primary accent |
| `primitive-dusk-400` | `#3D6A9F` | `220° 43% 43%` | Blue hover |
| `primitive-dusk-300` | `#6B92BF` | `220° 38% 59%` | Blue muted |
| `primitive-dusk-200` | `#A3BDD9` | `220° 34% 75%` | Blue pale |
| `primitive-dusk-100` | `#D8E6F4` | `220° 60% 91%` | Blue tint (light mode) |

#### Amber Warmth Palette

| Token Name | Hex | HSL | Description |
|---|---|---|---|
| `primitive-amber-800` | `#2E1E08` | `35° 60% 11%` | Deep amber (dark surface) |
| `primitive-amber-600` | `#7A4A0F` | `35° 71% 27%` | Warm amber mid |
| `primitive-amber-500` | `#C27A30` | `33° 60% 47%` | Amber — primary warmth |
| `primitive-amber-400` | `#D4963E` | `34° 61% 54%` | Amber hover |
| `primitive-amber-300` | `#E5B870` | `37° 67% 67%` | Amber muted |
| `primitive-amber-200` | `#F2D9A8` | `40° 72% 81%` | Amber pale |
| `primitive-amber-100` | `#FDF3E0` | `42° 90% 94%` | Amber tint (light mode bg) |

#### Crisis Coral Palette (Safety Plan only)

| Token Name | Hex | HSL | Description |
|---|---|---|---|
| `primitive-coral-800` | `#2C1110` | `2° 45% 12%` | Deep crisis (dark bg) |
| `primitive-coral-600` | `#7D3030` | `2° 44% 34%` | Crisis mid |
| `primitive-coral-500` | `#B05454` | `2° 36% 51%` | Crisis — Safety Plan button |
| `primitive-coral-400` | `#C96E6E` | `2° 40% 62%` | Crisis hover |
| `primitive-coral-200` | `#EBBEBE` | `2° 50% 83%` | Crisis muted text |
| `primitive-coral-100` | `#F9EDED` | `2° 55% 95%` | Crisis tint (light mode) |

---

### 1.3 Semantic Token Mappings

#### Dark / Low-Stimulation Mode (Default)

| Semantic Token | Primitive | Hex | Role |
|---|---|---|---|
| `color-bg-canvas` | `primitive-ink-900` | `#111518` | Primary app background |
| `color-bg-canvas-deep` | `primitive-ink-950` | `#0A0D0F` | OLED deep rest / night mode |
| `color-bg-surface` | `primitive-ink-800` | `#191E23` | Cards, bottom sheets |
| `color-bg-surface-raised` | `primitive-ink-700` | `#232B32` | Elevated modals, dialogs |
| `color-bg-overlay` | `primitive-ink-600` | `#2E3840` | Dividers, subtle borders |
| `color-text-primary` | `primitive-neutral-050` | `#F5F7F9` | Headings, check-in prompts |
| `color-text-secondary` | `primitive-neutral-200` | `#C4CDD4` | Body text, descriptions |
| `color-text-muted` | `primitive-neutral-300` | `#9AAAB6` | Captions, placeholders |
| `color-text-disabled` | `primitive-neutral-400` | `#6B7E8C` | Disabled states |
| `color-accent-primary` | `primitive-sage-500` | `#4A7862` | Primary interactive (CTAs) |
| `color-accent-primary-hover` | `primitive-sage-400` | `#5D9478` | Hover / pressed state |
| `color-accent-secondary` | `primitive-dusk-500` | `#2E5080` | Breathing session accent |
| `color-accent-warmth` | `primitive-amber-500` | `#C27A30` | Warmth cues, reach-out |
| `color-crisis-surface` | `primitive-coral-800` | `#2C1110` | Safety plan sheet bg |
| `color-crisis-action` | `primitive-coral-500` | `#B05454` | Safety plan CTA |
| `color-crisis-action-hover` | `primitive-coral-400` | `#C96E6E` | Safety plan CTA pressed |
| `color-crisis-text` | `primitive-coral-200` | `#EBBEBE` | Safety plan body text |
| `color-interactive-focus` | `primitive-dusk-300` | `#6B92BF` | Keyboard focus ring |
| `color-success-subtle` | `primitive-sage-300` | `#84B09A` | Completion confirmation |

#### Calm Daylight Mode

| Semantic Token | Primitive | Hex | Role |
|---|---|---|---|
| `color-bg-canvas` | `primitive-neutral-050` | `#F5F7F9` | Primary app background |
| `color-bg-surface` | `#FFFFFF` | `#FFFFFF` | Cards |
| `color-bg-surface-raised` | `primitive-sage-100` | `#DFF0E6` | Elevated surfaces (sage tint) |
| `color-bg-overlay` | `primitive-neutral-200` | `#C4CDD4` | Dividers |
| `color-text-primary` | `primitive-ink-900` | `#111518` | Headings |
| `color-text-secondary` | `primitive-ink-700` | `#232B32` | Body |
| `color-text-muted` | `primitive-ink-500` | `#3E4A54` | Captions |
| `color-accent-primary` | `primitive-sage-500` | `#4A7862` | Primary CTAs |
| `color-accent-secondary` | `primitive-dusk-500` | `#2E5080` | Breathing accent |
| `color-accent-warmth` | `primitive-amber-600` | `#7A4A0F` | Warmth cues |
| `color-crisis-action` | `primitive-coral-600` | `#7D3030` | Safety plan CTA (light) |
| `color-crisis-surface` | `primitive-coral-100` | `#F9EDED` | Safety plan sheet bg (light) |

---

### 1.4 WCAG 2.2 Contrast Verification

| Pair | Foreground | Background | Ratio | AAA Pass? |
|---|---|---|---|---|
| Primary text (dark) | `#F5F7F9` | `#111518` | **16.8:1** | ✅ AAA |
| Secondary text (dark) | `#C4CDD4` | `#111518` | **10.1:1** | ✅ AAA |
| Muted text (dark) | `#9AAAB6` | `#111518` | **6.7:1** | ⚠️ AA only |
| Sage CTA on dark canvas | `#F5F7F9` on `#4A7862` | — | **5.1:1** | ✅ AA |
| Crisis action text | `#F5F7F9` on `#B05454` | — | **4.9:1** | ✅ AA |
| Primary text (light) | `#111518` | `#F5F7F9` | **16.8:1** | ✅ AAA |
| Sage CTA on light canvas | `#FFFFFF` on `#4A7862` | — | **4.8:1** | ✅ AA |

> **Note on Muted Text:** Muted captions (`color-text-muted`) achieve AA (4.5:1) but not AAA. This is acceptable only for supplementary, non-essential labels. Error messages, prompts, and action labels must always use `color-text-primary` or `color-text-secondary`.

---

## 2. Typography System & Type Scale

### 2.1 Font Family Selection

**Primary Typeface: [Atkinson Hyperlegible](https://brailleinstitute.org/freefont)**
- Designed by the Braille Institute specifically for low-vision readability.
- Exceptional character disambiguation (0 vs O, l vs 1 vs I) — critical for journaling.
- Open source (SIL Open Font License). Wide Unicode coverage for global localization.
- Available in Regular (400) and Bold (700) only — forces typographic hierarchy through size and spacing, not weight complexity.

**Secondary / Display: [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans)**
- Used exclusively for large single-word grounding labels (e.g., "Breathe", "Here") and headings.
- Warmer personality than Inter; more rounded, less clinical.
- Available: 300, 400, 500, 600, 700, 800.

**Monospace (Journal Timestamps): [JetBrains Mono](https://www.jetbrains.com/legalnotices/font/)**
- Tabular figures for time displays; reduces re-flow on numeric updates.
- Used only for timestamps, never for body text.

---

### 2.2 Complete Type Scale

| Token | Font Family | Size (sp) | Line Height | Letter Spacing | Weight | Use Case |
|---|---|---|---|---|---|---|
| `type-display-xl` | Plus Jakarta Sans | 48sp | 1.1 (53px) | -0.02em | 700 | Single-word grounding anchors ("Breathe") |
| `type-display-lg` | Plus Jakarta Sans | 36sp | 1.15 (41px) | -0.01em | 600 | Session headings ("Let's slow down") |
| `type-display-md` | Plus Jakarta Sans | 28sp | 1.2 (34px) | -0.005em | 500 | Screen section titles |
| `type-heading-lg` | Atkinson Hyperlegible | 22sp | 1.3 (29px) | 0em | 700 | Check-in prompt question |
| `type-heading-md` | Atkinson Hyperlegible | 18sp | 1.35 (24px) | 0em | 700 | Card headers |
| `type-body-lg` | Atkinson Hyperlegible | 17sp | 1.55 (26px) | 0.01em | 400 | Primary reading text, journal body |
| `type-body-md` | Atkinson Hyperlegible | 15sp | 1.55 (23px) | 0.01em | 400 | Secondary descriptions, step text |
| `type-body-sm` | Atkinson Hyperlegible | 13sp | 1.5 (20px) | 0.015em | 400 | Supporting detail text |
| `type-label-lg` | Atkinson Hyperlegible | 16sp | 1.4 (22px) | 0.02em | 700 | Button labels, active navigation |
| `type-label-md` | Atkinson Hyperlegible | 14sp | 1.4 (20px) | 0.03em | 700 | Secondary labels |
| `type-caption` | Atkinson Hyperlegible | 12sp | 1.5 (18px) | 0.04em | 400 | Timestamps, helper text |
| `type-mono-sm` | JetBrains Mono | 12sp | 1.4 (17px) | 0em | 400 | Journal timestamps only |

**Minimum body size rule:** No text rendered below 12sp in any UI context.

---

### 2.3 Dynamic Type & Accessibility Scaling

Flutter's `textScaleFactor` must be **respected, not capped**. Users with accessibility needs who set system font size to 200% must experience a functional interface, not clipped text.

#### Scaling Rules

```dart
// lib/core/theme/typography.dart

/// Maximum scale applied to display text to prevent layout explosion.
/// Body and label text scale freely — no cap.
const double kDisplayTextMaxScale = 1.4;   // display-xl will not exceed 67sp
const double kBodyTextMaxScale    = 2.0;   // Body scales freely up to 200%

/// Wrap display text in a MediaQuery override to apply selective capping:
Widget _buildGroundingAnchor(BuildContext context, String word) {
  final rawScale = MediaQuery.textScalerOf(context).scale(1.0);
  final cappedScale = rawScale.clamp(1.0, kDisplayTextMaxScale);

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(cappedScale),
    ),
    child: Text(
      word,
      style: AppTypography.displayXl,
      textAlign: TextAlign.center,
    ),
  );
}
```

#### Layout Adaptations at 200% Scale
- **Check-in mood selectors:** Switch from 5-column row to 2-column grid above `textScaleFactor` 1.4.
- **Bottom navigation labels:** Auto-hide labels and show icons only above 1.6 (prevents overflow).
- **Breathing phase label:** Always `displayXl`, always centered, no truncation — single word only.

---

## 3. Component Design & Touch Targets

### 3.1 Core Touch Target Specifications

**Minimum touch target:** 56×56dp (exceeding Apple's 44pt and Google's 48dp minimums).
**Preferred touch target:** 64×64dp for primary actions.
**Minimum visual size:** 48dp height (tap target extends beyond visual bounds via `Padding` or `GestureDetector`).

| Component | Visual Height | Touch Target | Corner Radius |
|---|---|---|---|
| Primary Button | 56dp | 56dp full-width | 16dp |
| Secondary Button | 52dp | 56dp (4dp invisible padding) | 14dp |
| Ghost / Text Button | 44dp | 56dp (6dp vertical padding) | 12dp |
| Mood Selector Tile | 72dp | 72dp | 20dp |
| Check-in Energy Bar | 60dp | 64dp | 32dp (pill) |
| Navigation Tab | 64dp | 64dp | 0 |
| Safety Plan FAB | 56×56dp | 72×72dp | 28dp (near-circle) |
| Journal Entry Row | 72dp min | 72dp | 12dp |

---

### 3.2 Primary Button Component

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│          [    Label Text (type-label-lg)    ]       │
│                                                     │
└─────────────────────────────────────────────────────┘

Height:          56dp
Horizontal pad:  24dp (inner), full-width on mobile
Corner radius:   16dp
Background:      color-accent-primary (#4A7862 dark / #4A7862 light)
Label color:     color-text-primary (#F5F7F9)
Pressed state:   Scale to 0.97 + opacity 0.88 (300ms ease-out)
                 NO jarring color flash — subtle scale only
Disabled:        Background at 30% opacity, label at 40% opacity
Focus ring:      2dp solid color-interactive-focus, 2dp offset
```

#### Active/Pressed Feedback Pattern

```dart
// lib/shared/widgets/firefly_button.dart — pressed state

AnimatedScale(
  scale: _isPressed ? 0.97 : 1.0,
  duration: const Duration(milliseconds: 120),
  curve: Curves.easeOut,
  child: AnimatedOpacity(
    opacity: _isPressed ? 0.88 : 1.0,
    duration: const Duration(milliseconds: 80),
    child: /* button content */,
  ),
),
```

**Anti-pattern:** Never use an instant background color switch on press. The subtle scale + fade communicates "response" without visual shock.

---

### 3.3 Check-In Mood Selector Tiles

The check-in avoids numeric scales (1–10 is clinical and anxiety-inducing). Instead, Firefly uses **named emotional anchor tiles** with an accompanying visual motif.

```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│    🌑     │  │    🌒     │  │    🌓     │  │    🌔     │  │    🌕     │
│          │  │          │  │          │  │          │  │          │
│  Heavy   │  │  Low     │  │  Here    │  │  Light   │  │  Open    │
└──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘
  72×72dp       72×72dp       72×72dp       72×72dp       72×72dp
```

- **5 states:** Heavy → Low → Here → Light → Open (not numbers)
- **Visual motif:** Moon phase icons (from full dark to full light) — organic, non-clinical
- **Selected state:** Soft sage glow border (2dp, color-accent-primary) + background shifts to `color-bg-surface-raised`
- **Unselected state:** Subtle border (`color-bg-overlay`), muted icon tint

**Energy Level:**

```
┌────────────────────────────────────────────────────────────────┐
│  ○ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ○    │
│ Still                                               Moving      │
└────────────────────────────────────────────────────────────────┘
```

A single horizontal drag-slider with soft haptic ticks at the midpoint. Labels are "Still" and "Moving" — not "Exhausted" or "Energized" (pathologizing language avoided).

---

### 3.4 Breathing / Pacing Visualizer

#### Geometry

```
Canvas size:       280×280dp (centered on screen)
Bloom circle:      Radius: 50dp (exhale) → 120dp (inhale peak)
Glow rings:        3 concentric, opacity 4%/8%/12% outward
Stroke:            None — filled circles only (stroke creates tension)
Center text:       Phase word ("Breathe in", "Let go") in type-display-md
```

#### Timing Curves

| Phase | Duration | Flutter Curve |
|---|---|---|
| Inhale (bloom expand) | 4,000ms | `Curves.easeInOutSine` |
| Hold top | 0ms (cyclic sighing — no top hold) | — |
| Exhale (bloom contract) | 8,000ms | `Curves.easeInOutSine` |
| Phase transition crossfade | 400ms | `Curves.easeOut` |
| Color transition (sage → dusk → sage) | Full cycle | `ColorTween` synced to bloom |

**Color transition during breathing:**
- Inhale peak: `primitive-sage-500` → conveys groundedness, earth
- Exhale mid: `primitive-dusk-500` → conveys calm, space
- This color shift must be gradual and imperceptible frame-to-frame

#### Synchronization with Haptics

```dart
// Phase boundary events trigger haptic within the same frame
// See §4.2 Haptic Mapping Table
void _onInhaleStart() {
  _haptics.phaseTransition(BreathingPhase.inhale); // Soft double pulse
  _beginBloomExpansion();
}
void _onExhaleStart() {
  _haptics.phaseTransition(BreathingPhase.exhale); // Single light pulse
  _beginBloomContraction();
}
```

---

## 4. Motion, Haptics & Spatial Layout Tokens

### 4.1 Motion Token Catalog

**Core Principle:** All transitions in Firefly must feel like slow breathing — never a snap, never a jerk. Even error states should fade in, not flash.

| Token | Duration | Curve | Use Case |
|---|---|---|---|
| `motion-instant` | 0ms | — | Accessibility: `reduceMotion` override |
| `motion-micro` | 80ms | `easeOut` | Button press scale feedback |
| `motion-quick` | 150ms | `easeOut` | Opacity fade-in of small chips |
| `motion-standard` | 300ms | `easeInOut` | Screen element entrance/exit |
| `motion-deliberate` | 500ms | `easeInOutSine` | Page transitions, modal slides |
| `motion-breath-short` | 800ms | `easeInOutSine` | Breathing bloom phase (short cue) |
| `motion-breath-inhale` | 4000ms | `easeInOutSine` | Full inhale bloom expansion |
| `motion-breath-exhale` | 8000ms | `easeInOutSine` | Full exhale bloom contraction |
| `motion-ambient-loop` | 12000ms+ | `linear` | Ambient background color drift |

#### Reduced Motion Compliance

```dart
// lib/core/theme/motion_tokens.dart

class MotionTokens {
  static Duration resolve(Duration full, BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return reduceMotion ? Duration.zero : full;
  }

  static const deliberate   = Duration(milliseconds: 500);
  static const standard     = Duration(milliseconds: 300);
  static const quick        = Duration(milliseconds: 150);
  static const micro        = Duration(milliseconds: 80);
  static const breathInhale = Duration(milliseconds: 4000);
  static const breathExhale = Duration(milliseconds: 8000);
}
```

**Rule:** Every `AnimationController` duration must be wrapped in `MotionTokens.resolve()`. If `disableAnimations` is true, all animations collapse to 0ms.

---

### 4.2 Haptic Mapping Table

| Event | Pattern | Intensity | Implementation |
|---|---|---|---|
| **Inhale phase start** | Double soft pulse (100ms gap) | Light | `HapticFeedback.lightImpact()` × 2 |
| **Exhale phase start** | Single soft pulse | Light | `HapticFeedback.lightImpact()` × 1 |
| **Mood tile selection** | Selection click | Medium-light | `HapticFeedback.selectionClick()` |
| **Energy slider tick** (midpoint) | Subtle tick | Light | `HapticFeedback.selectionClick()` |
| **Tiny step completion** | Warm double tap (200ms gap) | Medium | `HapticFeedback.mediumImpact()` × 2 |
| **Journal entry saved** | Smooth fade pulse | Light | `HapticFeedback.lightImpact()` |
| **Safety plan access** | Firm single impact | Heavy | `HapticFeedback.heavyImpact()` × 1 |
| **Panic button (long-press confirm)** | Sustained vibration 300ms | Heavy | `SystemChannels` custom vibration |
| **Navigation tab switch** | Selection click | Light | `HapticFeedback.selectionClick()` |
| **Error / unavailable** | Short double tick (50ms gap) | Light | `HapticFeedback.lightImpact()` × 2 |

**Rule:** Haptic feedback must be suppressible. If the user's system accessibility settings disable haptics, no haptic calls should be made. Check via `HapticFeedback` — it is silently no-op when device haptics are disabled at the OS level.

---

### 4.3 Spacing Scale (4pt / 8pt Baseline Grid)

All spacing in Firefly is derived from a 4dp base unit.

| Token | Value | Use Case |
|---|---|---|
| `space-2xs` | 4dp | Icon inner padding, chip gap |
| `space-xs` | 8dp | Tight inline spacing, caption margin |
| `space-sm` | 12dp | Component inner padding (compact) |
| `space-md` | 16dp | Standard inner padding (cards, rows) |
| `space-lg` | 20dp | Section internal padding |
| `space-xl` | 24dp | Between card components |
| `space-2xl` | 32dp | Section separators |
| `space-3xl` | 48dp | Screen-level vertical breathing room |
| `space-4xl` | 64dp | Large screen anchoring gaps |

**Safe Areas:** All screen content must respect safe area insets. Add `space-3xl` (48dp) bottom clearance above any bottom navigation bar to prevent accidental tap-through.

---

### 4.4 Elevation & Shadow Tokens

Firefly avoids hard drop shadows (too much visual tension). Instead, elevation is communicated through background lightness shifts.

| Level | Token | Dark Mode Surface | Light Mode Surface | Use |
|---|---|---|---|---|
| 0 | `elevation-flat` | `#111518` | `#F5F7F9` | Canvas |
| 1 | `elevation-raised` | `#191E23` | `#FFFFFF` | Cards |
| 2 | `elevation-modal` | `#232B32` | `#FFFFFF` (+ sage tint) | Sheets, dialogs |
| 3 | `elevation-overlay` | `#2E3840` | `#DFF0E6` | Popovers |

**No hard box shadows on Level 1–2.** A subtle 1dp border at `color-bg-overlay` communicates edge without shadow drama.

---

## 5. Flutter Code Implementation

### 5.1 `AppColors` — Primitive + Semantic Definitions

```dart
// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// ─── Primitive Palette ────────────────────────────────────────────────────────
/// Do not use these directly in widgets. Use semantic tokens via AppCustomColors.
abstract final class _Primitive {
  // Ink (Dark foundation)
  static const ink950 = Color(0xFF0A0D0F);
  static const ink900 = Color(0xFF111518);
  static const ink800 = Color(0xFF191E23);
  static const ink700 = Color(0xFF232B32);
  static const ink600 = Color(0xFF2E3840);
  static const ink500 = Color(0xFF3E4A54);

  // Neutrals
  static const neutral400 = Color(0xFF6B7E8C);
  static const neutral300 = Color(0xFF9AAAB6);
  static const neutral200 = Color(0xFFC4CDD4);
  static const neutral100 = Color(0xFFE8ECF0);
  static const neutral050 = Color(0xFFF5F7F9);

  // Sage
  static const sage900 = Color(0xFF1C2922);
  static const sage700 = Color(0xFF2D4A3A);
  static const sage500 = Color(0xFF4A7862);
  static const sage400 = Color(0xFF5D9478);
  static const sage300 = Color(0xFF84B09A);
  static const sage200 = Color(0xFFB5CEBC);
  static const sage100 = Color(0xFFDFF0E6);

  // Dusk Blue
  static const dusk900 = Color(0xFF131B2E);
  static const dusk700 = Color(0xFF1E3050);
  static const dusk500 = Color(0xFF2E5080);
  static const dusk400 = Color(0xFF3D6A9F);
  static const dusk300 = Color(0xFF6B92BF);
  static const dusk200 = Color(0xFFA3BDD9);
  static const dusk100 = Color(0xFFD8E6F4);

  // Amber
  static const amber800 = Color(0xFF2E1E08);
  static const amber600 = Color(0xFF7A4A0F);
  static const amber500 = Color(0xFFC27A30);
  static const amber400 = Color(0xFFD4963E);
  static const amber300 = Color(0xFFE5B870);
  static const amber200 = Color(0xFFF2D9A8);
  static const amber100 = Color(0xFFFDF3E0);

  // Crisis Coral
  static const coral800 = Color(0xFF2C1110);
  static const coral600 = Color(0xFF7D3030);
  static const coral500 = Color(0xFFB05454);
  static const coral400 = Color(0xFFC96E6E);
  static const coral200 = Color(0xFFEBBEBE);
  static const coral100 = Color(0xFFF9EDED);
}

/// ─── Semantic Color Sets ──────────────────────────────────────────────────────

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    required this.bgCanvas,
    required this.bgCanvasDeep,
    required this.bgSurface,
    required this.bgSurfaceRaised,
    required this.bgOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.accentPrimary,
    required this.accentPrimaryHover,
    required this.accentSecondary,
    required this.accentWarmth,
    required this.crisisSurface,
    required this.crisisAction,
    required this.crisisActionHover,
    required this.crisisText,
    required this.interactiveFocus,
    required this.successSubtle,
  });

  final Color bgCanvas;
  final Color bgCanvasDeep;
  final Color bgSurface;
  final Color bgSurfaceRaised;
  final Color bgOverlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color accentPrimary;
  final Color accentPrimaryHover;
  final Color accentSecondary;
  final Color accentWarmth;
  final Color crisisSurface;
  final Color crisisAction;
  final Color crisisActionHover;
  final Color crisisText;
  final Color interactiveFocus;
  final Color successSubtle;

  @override
  AppCustomColors copyWith({
    Color? bgCanvas,
    Color? bgCanvasDeep,
    Color? bgSurface,
    Color? bgSurfaceRaised,
    Color? bgOverlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? accentPrimary,
    Color? accentPrimaryHover,
    Color? accentSecondary,
    Color? accentWarmth,
    Color? crisisSurface,
    Color? crisisAction,
    Color? crisisActionHover,
    Color? crisisText,
    Color? interactiveFocus,
    Color? successSubtle,
  }) =>
      AppCustomColors(
        bgCanvas:            bgCanvas            ?? this.bgCanvas,
        bgCanvasDeep:        bgCanvasDeep        ?? this.bgCanvasDeep,
        bgSurface:           bgSurface           ?? this.bgSurface,
        bgSurfaceRaised:     bgSurfaceRaised     ?? this.bgSurfaceRaised,
        bgOverlay:           bgOverlay           ?? this.bgOverlay,
        textPrimary:         textPrimary         ?? this.textPrimary,
        textSecondary:       textSecondary       ?? this.textSecondary,
        textMuted:           textMuted           ?? this.textMuted,
        textDisabled:        textDisabled        ?? this.textDisabled,
        accentPrimary:       accentPrimary       ?? this.accentPrimary,
        accentPrimaryHover:  accentPrimaryHover  ?? this.accentPrimaryHover,
        accentSecondary:     accentSecondary     ?? this.accentSecondary,
        accentWarmth:        accentWarmth        ?? this.accentWarmth,
        crisisSurface:       crisisSurface       ?? this.crisisSurface,
        crisisAction:        crisisAction        ?? this.crisisAction,
        crisisActionHover:   crisisActionHover   ?? this.crisisActionHover,
        crisisText:          crisisText          ?? this.crisisText,
        interactiveFocus:    interactiveFocus    ?? this.interactiveFocus,
        successSubtle:       successSubtle       ?? this.successSubtle,
      );

  @override
  AppCustomColors lerp(AppCustomColors? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      bgCanvas:           Color.lerp(bgCanvas,           other.bgCanvas,           t)!,
      bgCanvasDeep:       Color.lerp(bgCanvasDeep,       other.bgCanvasDeep,       t)!,
      bgSurface:          Color.lerp(bgSurface,          other.bgSurface,          t)!,
      bgSurfaceRaised:    Color.lerp(bgSurfaceRaised,    other.bgSurfaceRaised,    t)!,
      bgOverlay:          Color.lerp(bgOverlay,          other.bgOverlay,          t)!,
      textPrimary:        Color.lerp(textPrimary,        other.textPrimary,        t)!,
      textSecondary:      Color.lerp(textSecondary,      other.textSecondary,      t)!,
      textMuted:          Color.lerp(textMuted,          other.textMuted,          t)!,
      textDisabled:       Color.lerp(textDisabled,       other.textDisabled,       t)!,
      accentPrimary:      Color.lerp(accentPrimary,      other.accentPrimary,      t)!,
      accentPrimaryHover: Color.lerp(accentPrimaryHover, other.accentPrimaryHover, t)!,
      accentSecondary:    Color.lerp(accentSecondary,    other.accentSecondary,    t)!,
      accentWarmth:       Color.lerp(accentWarmth,       other.accentWarmth,       t)!,
      crisisSurface:      Color.lerp(crisisSurface,      other.crisisSurface,      t)!,
      crisisAction:       Color.lerp(crisisAction,       other.crisisAction,       t)!,
      crisisActionHover:  Color.lerp(crisisActionHover,  other.crisisActionHover,  t)!,
      crisisText:         Color.lerp(crisisText,         other.crisisText,         t)!,
      interactiveFocus:   Color.lerp(interactiveFocus,   other.interactiveFocus,   t)!,
      successSubtle:      Color.lerp(successSubtle,      other.successSubtle,      t)!,
    );
  }

  // ── Named Instances ──────────────────────────────────────────────────────────

  static const dark = AppCustomColors(
    bgCanvas:            _Primitive.ink900,
    bgCanvasDeep:        _Primitive.ink950,
    bgSurface:           _Primitive.ink800,
    bgSurfaceRaised:     _Primitive.ink700,
    bgOverlay:           _Primitive.ink600,
    textPrimary:         _Primitive.neutral050,
    textSecondary:       _Primitive.neutral200,
    textMuted:           _Primitive.neutral300,
    textDisabled:        _Primitive.neutral400,
    accentPrimary:       _Primitive.sage500,
    accentPrimaryHover:  _Primitive.sage400,
    accentSecondary:     _Primitive.dusk500,
    accentWarmth:        _Primitive.amber500,
    crisisSurface:       _Primitive.coral800,
    crisisAction:        _Primitive.coral500,
    crisisActionHover:   _Primitive.coral400,
    crisisText:          _Primitive.coral200,
    interactiveFocus:    _Primitive.dusk300,
    successSubtle:       _Primitive.sage300,
  );

  static const light = AppCustomColors(
    bgCanvas:            _Primitive.neutral050,
    bgCanvasDeep:        Color(0xFFFFFFFF),
    bgSurface:           Color(0xFFFFFFFF),
    bgSurfaceRaised:     _Primitive.sage100,
    bgOverlay:           _Primitive.neutral200,
    textPrimary:         _Primitive.ink900,
    textSecondary:       _Primitive.ink700,
    textMuted:           _Primitive.ink500,
    textDisabled:        _Primitive.neutral400,
    accentPrimary:       _Primitive.sage500,
    accentPrimaryHover:  _Primitive.sage400,
    accentSecondary:     _Primitive.dusk500,
    accentWarmth:        _Primitive.amber600,
    crisisSurface:       _Primitive.coral100,
    crisisAction:        _Primitive.coral600,
    crisisActionHover:   _Primitive.coral500,
    crisisText:          _Primitive.coral600,
    interactiveFocus:    _Primitive.dusk500,
    successSubtle:       _Primitive.sage500,
  );
}

/// Convenience accessor — use anywhere in widget tree
extension AppColorsX on BuildContext {
  AppCustomColors get colors =>
      Theme.of(this).extension<AppCustomColors>()!;
}
```

---

### 5.2 `AppTypography` — Text Theme

```dart
// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  // ── Display ─────────────────────────────────────────────────────────────────
  static final displayXl = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 48,
    height: 1.1,
    letterSpacing: -0.96, // -0.02em × 48
    fontWeight: FontWeight.w700,
  );

  static final displayLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 36,
    height: 1.15,
    letterSpacing: -0.36, // -0.01em × 36
    fontWeight: FontWeight.w600,
  );

  static final displayMd = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 28,
    height: 1.2,
    letterSpacing: -0.14, // -0.005em × 28
    fontWeight: FontWeight.w500,
  );

  // ── Headings ─────────────────────────────────────────────────────────────────
  static final headingLg = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 22,
    height: 1.3,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
  );

  static final headingMd = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 18,
    height: 1.35,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
  );

  // ── Body ─────────────────────────────────────────────────────────────────────
  static final bodyLg = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 17,
    height: 1.55,
    letterSpacing: 0.17, // 0.01em × 17
    fontWeight: FontWeight.w400,
  );

  static final bodyMd = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 15,
    height: 1.55,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w400,
  );

  static final bodySm = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 13,
    height: 1.5,
    letterSpacing: 0.195,
    fontWeight: FontWeight.w400,
  );

  // ── Labels ───────────────────────────────────────────────────────────────────
  static final labelLg = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 16,
    height: 1.4,
    letterSpacing: 0.32, // 0.02em × 16
    fontWeight: FontWeight.w700,
  );

  static final labelMd = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.42, // 0.03em × 14
    fontWeight: FontWeight.w700,
  );

  static final caption = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.48, // 0.04em × 12
    fontWeight: FontWeight.w400,
  );

  static final monoSm = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12,
    height: 1.4,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  );

  /// Maps AppTypography to Flutter's MaterialTextTheme
  static TextTheme toTextTheme(Color defaultColor) => TextTheme(
    displayLarge:   displayXl.copyWith(color: defaultColor),
    displayMedium:  displayLg.copyWith(color: defaultColor),
    displaySmall:   displayMd.copyWith(color: defaultColor),
    headlineLarge:  headingLg.copyWith(color: defaultColor),
    headlineMedium: headingMd.copyWith(color: defaultColor),
    bodyLarge:      bodyLg.copyWith(color: defaultColor),
    bodyMedium:     bodyMd.copyWith(color: defaultColor),
    bodySmall:      bodySm.copyWith(color: defaultColor),
    labelLarge:     labelLg.copyWith(color: defaultColor),
    labelMedium:    labelMd.copyWith(color: defaultColor),
    labelSmall:     caption.copyWith(color: defaultColor),
  );
}
```

---

### 5.3 `AppTheme` — Complete `ThemeData` Definitions

```dart
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {

  // ── Dark Theme (Default) ────────────────────────────────────────────────────
  static final darkTheme = _buildTheme(
    brightness: Brightness.dark,
    custom: AppCustomColors.dark,
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor:            Colors.transparent,
      systemNavigationBarColor:  _Primitive.ink900,
    ),
  );

  // ── Light Theme ─────────────────────────────────────────────────────────────
  static final lightTheme = _buildTheme(
    brightness: Brightness.light,
    custom: AppCustomColors.light,
    systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
      statusBarColor:            Colors.transparent,
      systemNavigationBarColor:  _Primitive.neutral050,
    ),
  );

  // ── Builder ─────────────────────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppCustomColors custom,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness:       brightness,
      primary:          custom.accentPrimary,
      onPrimary:        custom.textPrimary,
      primaryContainer: isDark ? _Primitive.sage700 : _Primitive.sage100,
      onPrimaryContainer: custom.textPrimary,
      secondary:        custom.accentSecondary,
      onSecondary:      custom.textPrimary,
      secondaryContainer: isDark ? _Primitive.dusk700 : _Primitive.dusk100,
      onSecondaryContainer: custom.textPrimary,
      tertiary:         custom.accentWarmth,
      onTertiary:       custom.textPrimary,
      error:            custom.crisisAction,
      onError:          custom.textPrimary,
      errorContainer:   custom.crisisSurface,
      onErrorContainer: custom.crisisText,
      surface:          custom.bgSurface,
      onSurface:        custom.textPrimary,
      surfaceContainerHighest: custom.bgSurfaceRaised,
      outline:          custom.bgOverlay,
      outlineVariant:   custom.textDisabled,
      scrim:            Colors.black.withOpacity(0.6),
      shadow:           Colors.transparent, // No shadows — elevation via color
    );

    return ThemeData(
      useMaterial3:       true,
      brightness:         brightness,
      colorScheme:        colorScheme,
      scaffoldBackgroundColor: custom.bgCanvas,
      canvasColor:        custom.bgCanvas,

      // ── Typography ──────────────────────────────────────────────────────────
      textTheme: AppTypography.toTextTheme(custom.textPrimary),

      // ── Extensions ──────────────────────────────────────────────────────────
      extensions: [custom],

      // ── App Bar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:  custom.bgCanvas,
        foregroundColor:  custom.textPrimary,
        elevation:        0,
        scrolledUnderElevation: 0, // No elevation shadow on scroll
        centerTitle:      false,
        systemOverlayStyle: systemOverlayStyle,
        titleTextStyle:   AppTypography.headingMd.copyWith(color: custom.textPrimary),
      ),

      // ── Cards ───────────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color:         custom.bgSurface,
        elevation:     0,
        shape:         RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:         BorderSide(color: custom.bgOverlay, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── Bottom Navigation ────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:          custom.bgSurface,
        indicatorColor:           custom.accentPrimary.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: custom.accentPrimary, size: 24);
          }
          return IconThemeData(color: custom.textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMd.copyWith(color: custom.accentPrimary);
          }
          return AppTypography.labelMd.copyWith(color: custom.textMuted);
        }),
        elevation:     0,
        height:        64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── ElevatedButton (Primary CTA) ─────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return custom.accentPrimary.withOpacity(0.30);
            }
            return custom.accentPrimary;
          }),
          foregroundColor: WidgetStateProperty.all(custom.textPrimary),
          overlayColor:    WidgetStateProperty.all(Colors.transparent), // No ripple
          minimumSize:     WidgetStateProperty.all(const Size.fromHeight(56)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevation:       WidgetStateProperty.all(0),
          textStyle:       WidgetStateProperty.all(AppTypography.labelLg),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),

      // ── OutlinedButton (Secondary CTA) ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(custom.accentPrimary),
          side: WidgetStateProperty.all(
            BorderSide(color: custom.accentPrimary, width: 1.5),
          ),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(52)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          elevation:   WidgetStateProperty.all(0),
          textStyle:   WidgetStateProperty.all(AppTypography.labelLg),
        ),
      ),

      // ── Text Field (Journal input) ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        custom.bgSurface,
        contentPadding:   const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius:   BorderRadius.circular(12),
          borderSide:     BorderSide(color: custom.bgOverlay),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:   BorderRadius.circular(12),
          borderSide:     BorderSide(color: custom.bgOverlay),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:   BorderRadius.circular(12),
          borderSide:     BorderSide(color: custom.interactiveFocus, width: 2),
        ),
        hintStyle:        AppTypography.bodyLg.copyWith(color: custom.textMuted),
      ),

      // ── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     custom.bgOverlay,
        thickness: 1,
        space:     1,
      ),

      // ── Bottom Sheet ────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:      custom.bgSurface,
        modalBackgroundColor: custom.bgSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation:          0,
        modalElevation:     0,
        dragHandleColor:    custom.bgOverlay,
        dragHandleSize:     const Size(40, 4),
      ),

      // ── Focus ───────────────────────────────────────────────────────────────
      focusColor:     custom.interactiveFocus.withOpacity(0.15),
      splashColor:    Colors.transparent,  // No ink splash — calm press feedback only
      highlightColor: Colors.transparent,
    );
  }
}
```

---

### 5.4 Usage in `main.dart`

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/security/network_kill_switch.dart';

void main() async {
  // Security: kill all outbound network connections before anything else
  HttpOverrides.global = FireflyHttpOverride();

  WidgetsFlutterBinding.ensureInitialized();

  // Force preferred orientations (portrait only — prevents landscape layout breaks)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: FireflyApp()));
}

class FireflyApp extends ConsumerWidget {
  const FireflyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Firefly',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.lightTheme,
      darkTheme:  AppTheme.darkTheme,
      // Default to dark (low-stimulation) mode; respect system setting
      themeMode:  ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

---

## Appendix A: Font Licensing & Asset Setup

| Font | License | Distribution |
|---|---|---|
| Atkinson Hyperlegible | SIL OFL 1.1 | Bundle directly in `assets/fonts/` |
| Plus Jakarta Sans | SIL OFL 1.1 | Bundle directly in `assets/fonts/` |
| JetBrains Mono | SIL OFL 1.1 | Bundle directly in `assets/fonts/` |

**All three fonts are open source and may be bundled directly in the app. No Google Fonts API calls at runtime** — use local font files only to maintain the zero-network requirement.

```yaml
# pubspec.yaml — font declarations
flutter:
  fonts:
    - family: AtkinsonHyperlegible
      fonts:
        - asset: assets/fonts/AtkinsonHyperlegible-Regular.ttf
          weight: 400
        - asset: assets/fonts/AtkinsonHyperlegible-Bold.ttf
          weight: 700
    - family: PlusJakartaSans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/PlusJakartaSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
          weight: 400
```

---

## Appendix B: Design Anti-Patterns (Banned)

| Anti-Pattern | Reason | Allowed Alternative |
|---|---|---|
| Confetti / particle rewards | Anxiety-inducing, overstimulating | Subtle fade of sage `successSubtle` |
| Streak counters | Creates guilt on missed days | Gentle "you showed up" count |
| Red error alerts | Panic-triggering color | Muted coral with low opacity |
| Instant color flash on press | Jarring, creates tension | 120ms scale + opacity fade |
| Bright notification badges | Gamification pressure | No badge — text summary only |
| Auto-advancing animations | Loss of user control | All animations user-triggered |
| Aggressive push notifications | Guilt, pressure | User-initiated, opt-in only |
| Numeric 1–10 mood scales | Clinical, reductive | Named anchor tiles (Heavy → Open) |

---

*Document maintained by the Firefly Design Team. All new components must be reviewed against this specification and the anti-patterns list before implementation.*
