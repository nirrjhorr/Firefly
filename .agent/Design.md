# Firefly — UI/UX Design System & Interaction Specification

**Version:** 1.0.0 | **Status:** Sprint 0 — Approved Baseline | **Updated:** 2026-09-30

> **Design Philosophy:** Firefly is a quiet companion, not a productivity tool. Every visual decision must reduce cognitive load, never add to it. The interface should feel like a dimly lit room at the end of a hard day — warm, unhurried, and entirely yours. No confetti. No streaks. No urgency. No judgment. No noise.

---

## 1. UI/UX Principles for Mental Distress

### 1.1 Trauma-Informed Design Rules

| Principle | Implementation |
|---|---|
| **One primary decision per screen** | Never more than one primary CTA visible at a time |
| **Delivery of relief in < 2 minutes** | Every intervention is completable in under 120 seconds |
| **No forced paths** | Every screen has a visible escape route (back arrow or "not now") |
| **Predictability** | Transitions are always slow and expected — no surprise animations |
| **No guilt language** | "You showed up" not "You missed 3 days" |
| **Non-clinical tone** | "How are you right now?" not "Rate your depressive episode severity" |
| **Quiet affirmations only** | Completion: subtle sage fade — never confetti, badges, or sounds |
| **Safe exits always visible** | SOS Safety Plan overlay persists and is reachable from anywhere within one tap |

### 1.2 Cognitive Load Reduction

- **Whitespace is structural**: 48dp breathing room between sections — the screen must never feel full
- **Dark canvas default**: Low-stimulation dark mode is the default; Calm Daylight mode is the alternative
- **Micro-decisions only**: The check-in selector uses symbols (moon phases) + words — never numbers alone
- **Progressive disclosure**: Advanced settings are behind a secondary tap — not on first view
- **No skeleton loaders**: Since all data is local and instant (Riverpod + Drift), skeleton screens are banned — they create false urgency

---

## 2. Color Palette & Token Architecture

All colors are drawn from a natural, desaturated palette: deep slate skies, weathered sage, warm candlelight, and the blue-grey of pre-dawn hours. No pure primaries. No neon highlights. Crisis-adjacent UI uses a **muted warm coral** — communicating importance without triggering alarm.

**WCAG 2.2 AAA Compliance Target:** All text-on-background combinations must achieve ≥ 7:1 contrast ratio. Interactive controls must achieve ≥ 4.5:1.

### 2.1 Raw Color Primitives

**Note:** Never reference these directly in UI code — always use semantic tokens.

| Palette Category | Examples & Description |
|---|---|
| **Deep Rest (Dark Mode)** | OLED black canvas (`#0A0D0F`), Elevated surfaces (`#191E23`, `#232B32`), Text neutrals (`#C4CDD4`, `#F5F7F9`) |
| **Sage Grounding** | Primary interactive (`#4A7862`), Pale decorative (`#B5CEBC`) |
| **Dusk Blue** | Calm accent (`#2E5080`), Hover states (`#3D6A9F`) |
| **Amber Warmth** | Primary warmth (`#C27A30`), Pale amber (`#F2D9A8`) |
| **Crisis Coral** | Safety Plan action (`#B05454`), Crisis surface (`#2C1110`) |

### 2.2 Semantic Token Mappings

#### Dark / Low-Stimulation Mode (Default)

| Semantic Token | Hex | Role |
|---|---|---|
| `color-bg-canvas` | `#111518` | Primary app background |
| `color-bg-canvas-deep` | `#0A0D0F` | OLED deep rest / night mode |
| `color-bg-surface` | `#191E23` | Cards, bottom sheets |
| `color-bg-surface-raised` | `#232B32` | Elevated modals, dialogs |
| `color-bg-overlay` | `#2E3840` | Dividers, subtle borders |
| `color-text-primary` | `#F5F7F9` | Headings, check-in prompts |
| `color-text-secondary` | `#C4CDD4` | Body text, descriptions |
| `color-text-muted` | `#9AAAB6` | Captions, placeholders (AA contrast only) |
| `color-text-disabled` | `#6B7E8C` | Disabled states |
| `color-accent-primary` | `#4A7862` | Primary interactive (CTAs) |
| `color-accent-primary-hover` | `#5D9478` | Hover / pressed state |
| `color-accent-secondary` | `#2E5080` | Breathing session accent |
| `color-accent-warmth` | `#C27A30` | Warmth cues, reach-out |
| `color-crisis-surface` | `#2C1110` | Safety plan sheet bg |
| `color-crisis-action` | `#B05454` | Safety plan CTA |
| `color-crisis-text` | `#EBBEBE` | Safety plan body text |
| `color-interactive-focus` | `#6B92BF` | Keyboard focus ring |
| `color-success-subtle` | `#84B09A` | Completion confirmation |

#### Calm Daylight Mode

| Semantic Token | Hex | Role |
|---|---|---|
| `color-bg-canvas` | `#F5F7F9` | Primary app background |
| `color-bg-surface` | `#FFFFFF` | Cards |
| `color-bg-surface-raised` | `#DFF0E6` | Elevated surfaces (sage tint) |
| `color-bg-overlay` | `#C4CDD4` | Dividers |
| `color-text-primary` | `#111518` | Headings |
| `color-text-secondary` | `#232B32` | Body |
| `color-text-muted` | `#3E4A54` | Captions |
| `color-accent-primary` | `#4A7862` | Primary CTAs |
| `color-accent-secondary` | `#2E5080` | Breathing accent |
| `color-accent-warmth` | `#7A4A0F` | Warmth cues |
| `color-crisis-action` | `#7D3030` | Safety plan CTA (light) |
| `color-crisis-surface` | `#F9EDED` | Safety plan sheet bg (light) |

---

## 3. Typography System & Type Scale

### 3.1 Font Family Selection

- **Primary Typeface: Atkinson Hyperlegible** — Designed by the Braille Institute for low-vision readability. Exceptional character disambiguation.
- **Secondary / Display: Plus Jakarta Sans** — Used for large single-word grounding labels and headings.
- **Monospace: JetBrains Mono** — Used only for timestamps (tabular figures reduce re-flow on numeric updates).

### 3.2 Complete Type Scale

| Token | Font Family | Size (sp) | Line Height | Letter Spacing | Weight | Use Case |
|---|---|---|---|---|---|---|
| `type-display-xl` | Plus Jakarta Sans | 48sp | 1.1 | -0.02em | 700 | Single-word grounding anchors ("Breathe") |
| `type-display-lg` | Plus Jakarta Sans | 36sp | 1.15 | -0.01em | 600 | Session headings |
| `type-display-md` | Plus Jakarta Sans | 28sp | 1.2 | -0.005em | 500 | Screen section titles |
| `type-heading-lg` | Atkinson Hyperlegible | 22sp | 1.3 | 0em | 700 | Check-in prompt question |
| `type-heading-md` | Atkinson Hyperlegible | 18sp | 1.35 | 0em | 700 | Card headers |
| `type-body-lg` | Atkinson Hyperlegible | 17sp | 1.55 | 0.01em | 400 | Primary reading text, journal body |
| `type-body-md` | Atkinson Hyperlegible | 15sp | 1.55 | 0.01em | 400 | Secondary descriptions, step text |
| `type-body-sm` | Atkinson Hyperlegible | 13sp | 1.5 | 0.015em | 400 | Supporting detail text |
| `type-label-lg` | Atkinson Hyperlegible | 16sp | 1.4 | 0.02em | 700 | Button labels, active navigation |
| `type-label-md` | Atkinson Hyperlegible | 14sp | 1.4 | 0.03em | 700 | Secondary labels |
| `type-caption` | Atkinson Hyperlegible | 12sp | 1.5 | 0.04em | 400 | Timestamps, helper text |
| `type-mono-sm` | JetBrains Mono | 12sp | 1.4 | 0em | 400 | Journal timestamps only |

### 3.3 Dynamic Type & Accessibility Scaling

Flutter's `textScaleFactor` must be **respected, not capped** for accessibility.
- **Body and label text:** scales freely up to 200%.
- **Display text:** (`display-xl` down to `display-md`) capped at maximum `1.4` scale via `MediaQuery` to prevent layout explosion.
- **Layout Adaptations at 200% Scale:** Check-in mood selectors switch from 5-column row to 2-column grid. Bottom navigation labels auto-hide to show icons only.

---

## 4. Component Design & Touch Targets

### 4.1 Core Touch Target Specifications

**Minimum touch target:** 56×56dp (exceeding Apple/Google minimums). **Preferred:** 64×64dp for primary actions. Minimum visual size is 48dp.

| Component | Visual Height | Touch Target | Corner Radius |
|---|---|---|---|
| Primary Button | 56dp | 56dp full-width | 16dp |
| Secondary Button | 52dp | 56dp | 14dp |
| Ghost / Text Button | 44dp | 56dp | 12dp |
| Mood Selector Tile | 72dp | 72dp | 20dp |
| Check-in Energy Bar | 60dp | 64dp | 32dp (pill) |
| Navigation Tab | 64dp | 64dp | 0 |
| Safety Plan FAB | 56×56dp | 72×72dp | 28dp (near-circle) |
| Journal Entry Row | 72dp min | 72dp | 12dp |

### 4.2 Button Behavior

- **Background:** `color-accent-primary` (#4A7862)
- **Label:** `color-text-primary` (#F5F7F9)
- **Active/Pressed:** Scale to 0.97 + opacity 0.88 over 120ms (`Curves.easeOut`). Release scales 0.97 → 1.0 over 150ms.
- **Rule:** Never use an instant background color switch on press. No ink ripple, shadow pop, or border flash.

### 4.3 Check-In Mood Selector Tiles

The check-in avoids numeric scales. Uses named emotional anchor tiles (72×72dp) with visual motifs (Moon phases).
- **States:** Heavy (🌑) → Low (🌒) → Here (🌓) → Light (🌔) → Open (🌕)
- **Selected:** Soft sage glow border (2dp, `color-accent-primary`) + bg shifts to `color-bg-surface-raised`.
- **Unselected:** Subtle border (`color-bg-overlay`), muted icon tint.

### 4.4 Breathing / Pacing Visualizer

Implemented as a `CustomPainter` capped at 60fps, completely shader-free (unless Impeller is active).
- **Canvas size:** 280×280dp (centered)
- **Bloom circle:** Radius 50dp (exhale) → 120dp (inhale peak)
- **Glow rings:** 3 concentric, opacity 4%/8%/12% outward. Filled circles only.
- **Timing:** Inhale (4000ms), Exhale (8000ms) using `Curves.easeInOutSine`.
- **Color transition:** `primitive-sage-500` (inhale) → `primitive-dusk-500` (exhale). Gradual and imperceptible.

---

## 5. Motion, Haptics & Spatial Layout Tokens

### 5.1 Motion Token Catalog

All transitions in Firefly must feel like slow breathing — never a snap, never a jerk. All durations must be wrapped in `MotionTokens.resolve()` to respect `reduceMotion` accessibility preferences.

| Token | Duration | Curve | Use Case |
|---|---|---|---|
| `motion-instant` | 0ms | — | Accessibility `reduceMotion` override |
| `motion-micro` | 80ms | `easeOut` | Button press scale feedback |
| `motion-quick` | 150ms | `easeOut` | Opacity fade-in of small chips |
| `motion-standard` | 300ms | `easeInOut` | Screen element entrance/exit |
| `motion-deliberate` | 500ms | `easeInOutSine` | Page transitions, modal slides |
| `motion-breath-inhale` | 4000ms | `easeInOutSine` | Full inhale bloom expansion |
| `motion-breath-exhale` | 8000ms | `easeInOutSine` | Full exhale bloom contraction |
| `motion-ambient-loop`| 12000ms+| `linear` | Ambient background color drift |

**Animation Toolkit Tiers:**
- `CustomPainter` + `AnimationController`: Breathing bloom (Zero widget tree overhead).
- `flutter_animate`: Micro-interactions (Button press, card appear).
- `rive` runtime: Complex animations.
- `go_router` `CustomTransitionPage`: Page transitions.

### 5.2 Haptic Mapping Table

| Event | Pattern | Implementation |
|---|---|---|
| **Inhale phase start** | Double soft pulse | `HapticFeedback.lightImpact()` × 2 |
| **Exhale phase start** | Single soft pulse | `HapticFeedback.lightImpact()` × 1 |
| **Mood tile selection** | Selection click | `HapticFeedback.selectionClick()` |
| **Energy slider tick** | Subtle tick | `HapticFeedback.selectionClick()` |
| **Tiny step completion** | Warm double tap | `HapticFeedback.mediumImpact()` × 2 |
| **Journal entry saved** | Smooth fade pulse | `HapticFeedback.lightImpact()` |
| **Safety plan access** | Firm single impact | `HapticFeedback.heavyImpact()` × 1 |
| **Panic confirm** | Sustained vibration | `SystemChannels` custom vibration |

### 5.3 Spacing Scale (4pt / 8pt Baseline Grid)

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

**Safe Areas:** All screen content must respect safe area insets. Include `space-3xl` bottom clearance above bottom nav bars.

### 5.4 Elevation & Shadow Tokens

Firefly avoids hard drop shadows. Elevation is communicated through background lightness shifts.
- **Level 0 (Flat):** `elevation-flat` — Canvas (`#111518`)
- **Level 1 (Raised):** `elevation-raised` — Cards (`#191E23`)
- **Level 2 (Modal):** `elevation-modal` — Sheets, dialogs (`#232B32`)
- **Level 3 (Overlay):** `elevation-overlay` — Popovers (`#2E3840`)
(No hard box shadows on Levels 1–2. A subtle 1dp border at `color-bg-overlay` communicates edge.)

---

## 6. Architecture & State Management UX Integrity

- **Resource cleanup:** `ref.onDispose` guarantees teardown of audio, timers, and haptics when navigating away. Critical for trauma-informed UX where an abrupt exit must gracefully pause any overstimulation.
- **Emergency Safety Plan:** Accessible via a persistent `SosOverlayButton` positioned just above the `NavigationShell`. Opens in a `go_router` instant modal overlay. Reachable within one tap anywhere in the app.
- **Audio fade-in/out:** Implemented via `just_audio` with a 300ms volume fade to prevent jarring cuts.

---

## 7. Banned Design Patterns

| Pattern | Reason | Alternative |
|---|---|---|
| Confetti / particles | Overstimulating | Subtle sage fade |
| Streak counters | Guilt on miss | "Showed up N times" |
| Red error alerts | Alarm-triggering | Muted coral with icon |
| Instant colour flash on tap | Jarring | 120ms scale + fade |
| Numeric 1–10 mood scales | Clinical, reductive | Named moon-phase tiles |
| Push notification guilt | Anxiety-inducing | User-initiated, opt-in |
| Auto-advancing animations | Loss of control | User-triggered only |
| Bold saturated gradients | High stimulation | Muted single-hue surfaces |
| Modal dialogs without dismiss | Trap anxiety | Always dismissible |
| Skeleton loaders | False urgency (data is local) | Instant render via Riverpod `AsyncNotifier` |
