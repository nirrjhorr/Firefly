# Design.md
# Firefly — UI/UX Design System & Interaction Specification

**Version:** 1.0.0 | **Status:** Approved Baseline | **Updated:** 2026-09-30

> **Design Philosophy:** Firefly is a quiet companion. Every visual decision must reduce cognitive load, not add to it. The interface should feel like a dimly lit room at the end of a hard day — warm, unhurried, and entirely private. No urgency. No judgment. No noise.

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
| **Safe exits always visible** | SOS overlay persists on every screen |

### 1.2 Cognitive Load Reduction

- **Whitespace is structural**: 48dp breathing room between sections — the screen must never feel full
- **Dark canvas default**: Low-stimulation dark mode is the default; Calm Daylight mode is the alternative
- **Micro-decisions only**: The check-in selector uses symbols (moon phases) + words — never numbers alone
- **Progressive disclosure**: Advanced settings (TTL, voice-to-text, hope box add) are behind a secondary tap — not on first view
- **No skeleton loaders**: Since all data is local and instant, skeleton screens are banned — they create false urgency

---

## 2. Color Palette & Semantic Tokens

### 2.1 Raw Primitive Palette

#### Dark Foundation (Ink)

| Name | Hex | HSL |
|---|---|---|
| `ink-950` | `#0E1211` | `160° 17% 6%` |
| `ink-900` | `#141C19` | `158° 16% 9%` |
| `ink-800` | `#18201D` | `157° 14% 11%` |
| `ink-700` | `#1F2A26` | `156° 15% 14%` |
| `ink-600` | `#28342F` | `155° 14% 18%` |
| `ink-500` | `#374540` | `154° 12% 24%` |

#### Sage Grounding

| Name | Hex | HSL |
|---|---|---|
| `sage-700` | `#2D4A3A` | `150° 24% 23%` |
| `sage-500` | `#4A7862` | `150° 23% 38%` |
| `sage-accent` | `#7DBA9B` | `150° 28% 61%` |
| `sage-300` | `#B5CEBC` | `140° 17% 76%` |
| `sage-100` | `#DFF0E6` | `140° 32% 91%` |

#### Dusk Blue

| Name | Hex | HSL |
|---|---|---|
| `dusk-700` | `#1E3050` | `220° 43% 21%` |
| `dusk-500` | `#5B8A99` | `194° 26% 48%` |
| `dusk-300` | `#A3BDD9` | `210° 34% 75%` |
| `dusk-100` | `#D8E6F4` | `210° 60% 91%` |

#### Warm Amber

| Name | Hex | HSL |
|---|---|---|
| `amber-600` | `#7A4A0F` | `35° 71% 27%` |
| `amber-500` | `#D99B62` | `30° 57% 62%` |
| `amber-300` | `#F2D9A8` | `40° 72% 81%` |
| `amber-100` | `#FDF3E0` | `42° 90% 94%` |

#### Crisis Coral (Safety Plan Only)

| Name | Hex | HSL |
|---|---|---|
| `coral-800` | `#2C1110` | `2° 45% 12%` |
| `coral-500` | `#E27D60` | `14° 68% 63%` |
| `coral-300` | `#F2B8A6` | `14° 70% 80%` |
| `coral-100` | `#FDF0EC` | `14° 75% 96%` |

#### Text Neutrals

| Name | Hex | HSL |
|---|---|---|
| `text-high` | `#F0F4F2` | `150° 20% 95%` |
| `text-mid` | `#C4CDD4` | `210° 12% 80%` |
| `text-muted` | `#8FA09A` | `160° 8% 60%` |
| `text-disabled` | `#5C6E68` | `158° 9% 40%` |

---

### 2.2 Semantic Token Map

#### Dark / Low-Stimulation Mode (Default)

| Semantic Token | Value | Role |
|---|---|---|
| `bg-canvas` | `#141C19` | Primary app background |
| `bg-canvas-deep` | `#0E1211` | OLED pure-black / night mode |
| `bg-surface` | `#18201D` | Cards, bottom sheets |
| `bg-surface-raised` | `#1F2A26` | Elevated modals |
| `bg-overlay` | `#28342F` | Dividers, subtle borders |
| `text-primary` | `#F0F4F2` | All headings and primary labels |
| `text-secondary` | `#C4CDD4` | Body text |
| `text-muted` | `#8FA09A` | Captions, placeholders |
| `text-disabled` | `#5C6E68` | Disabled controls |
| `accent-sage` | `#7DBA9B` | Primary interactive — CTAs |
| `accent-sage-dim` | `#4A7862` | Hover / active state |
| `accent-dusk` | `#5B8A99` | Breathing session, calm blue |
| `accent-amber` | `#D99B62` | Warmth cue, reach-out |
| `crisis-bg` | `#2C1110` | Safety plan sheet background |
| `crisis-action` | `#E27D60` | Safety plan primary CTA |
| `crisis-text` | `#F2B8A6` | Safety plan body text |
| `focus-ring` | `#5B8A99` | Keyboard focus ring (2dp) |
| `success-subtle` | `#7DBA9B` | Completion confirmation fade |

#### Calm Daylight Mode

| Semantic Token | Value | Role |
|---|---|---|
| `bg-canvas` | `#F5F7F6` | Primary background |
| `bg-surface` | `#FFFFFF` | Cards |
| `bg-surface-raised` | `#DFF0E6` | Elevated (sage tint) |
| `text-primary` | `#141C19` | Headings |
| `text-secondary` | `#1F2A26` | Body |
| `text-muted` | `#374540` | Captions |
| `accent-sage` | `#4A7862` | CTAs (darker for light bg) |
| `accent-dusk` | `#1E3050` | Breathing accent |
| `accent-amber` | `#7A4A0F` | Warmth (darker for contrast) |
| `crisis-action` | `#C05A3F` | Safety plan CTA (light) |

---

## 3. Typography System

### 3.1 Font Families

| Family | Use | Weight | Source |
|---|---|---|---|
| **Atkinson Hyperlegible** | Body, headings, labels | 400, 700 | Braille Institute (SIL OFL) |
| **Plus Jakarta Sans** | Display, large grounding words | 500, 600, 700 | Google Fonts (SIL OFL) |
| **JetBrains Mono** | Timestamps only | 400 | JetBrains (SIL OFL) |

> All fonts bundled in `assets/fonts/` — no Google Fonts API calls at runtime.

### 3.2 Type Scale

| Token | Family | Size | Line Height | Letter Spacing | Weight | Use Case |
|---|---|---|---|---|---|---|
| `display-xl` | Plus Jakarta Sans | 48sp | 1.1 | −0.02em | 700 | Grounding anchor ("Breathe") |
| `display-lg` | Plus Jakarta Sans | 36sp | 1.15 | −0.01em | 600 | Session headings |
| `display-md` | Plus Jakarta Sans | 28sp | 1.2 | −0.005em | 500 | Screen section titles |
| `heading-lg` | Atkinson Hyperlegible | 22sp | 1.3 | 0em | 700 | Check-in prompt question |
| `heading-md` | Atkinson Hyperlegible | 18sp | 1.35 | 0em | 700 | Card headers |
| `body-lg` | Atkinson Hyperlegible | 17sp | 1.55 | +0.01em | 400 | Primary reading, journal body |
| `body-md` | Atkinson Hyperlegible | 15sp | 1.55 | +0.01em | 400 | Descriptions, step text |
| `body-sm` | Atkinson Hyperlegible | 13sp | 1.5 | +0.015em | 400 | Supporting detail |
| `label-lg` | Atkinson Hyperlegible | 16sp | 1.4 | +0.02em | 700 | Button labels, nav items |
| `label-md` | Atkinson Hyperlegible | 14sp | 1.4 | +0.03em | 700 | Secondary labels |
| `caption` | Atkinson Hyperlegible | 12sp | 1.5 | +0.04em | 400 | Timestamps, helper text |
| `mono-sm` | JetBrains Mono | 12sp | 1.4 | 0em | 400 | Timestamps only |

### 3.3 Dynamic Type Rules

- **Body text** (`body-lg`, `body-md`, `body-sm`): scales freely up to 200% system setting
- **Display text** (`display-xl`, `display-lg`): capped at 1.4× to prevent layout explosion
- **Mood tile labels**: switch from inline to below-icon at scale factor > 1.3
- **Navigation tab labels**: hidden at scale factor > 1.6 (icon-only mode)
- **Overflow rule**: Text MUST use `softWrap: true` and `overflow: TextOverflow.visible` — never clip or ellipsis on primary content

---

## 4. Component Specifications

### 4.1 Touch Target Rules

| Component | Visual Size | Touch Target | Corner Radius | Notes |
|---|---|---|---|---|
| Primary Button | 56dp height, full-width | 56dp | 16dp | Sage fill |
| Secondary Button | 52dp height | 56dp | 14dp | Outlined |
| Ghost Button | 44dp height | 56dp | 12dp | 6dp invisible padding |
| Mood Selector Tile | 72×72dp | 72×72dp | 20dp | 5 per row |
| Energy Slider | 60dp track | 64dp hit area | 32dp (pill) | 48dp thumb |
| SOS Overlay Button | 44×44dp | 64×64dp | 22dp | Persistent |
| Panic Exit Button | 36×36dp | 56×56dp | 18dp | Long-press only |
| Navigation Tab | 64dp height | 64dp | 0dp | 4 tabs |
| Journal Entry Row | 72dp min | 72dp | 12dp | Expandable |
| Hope Box Item | 160×160dp | 168×168dp | 16dp | Grid tile |

### 4.2 Button Press Behavior

```
Press down:
  - Scale: 1.0 → 0.97 over 120ms (Curves.easeOut)
  - Opacity: 1.0 → 0.88 over 80ms (Curves.easeOut)
  - Haptic: HapticFeedback.lightImpact()

Release:
  - Scale: 0.97 → 1.0 over 150ms (Curves.easeOut)
  - Opacity: 0.88 → 1.0 over 100ms (Curves.easeOut)

NO: ink ripple, color flash, border flash, shadow pop
```

### 4.3 Mood Selector Tiles

```
States:
  Unselected: border = bg-overlay (1dp), icon = text-muted, bg = bg-surface
  Selected:   border = accent-sage (2dp), icon = accent-sage, bg = bg-surface-raised
  Hover:      border = accent-sage-dim (1.5dp)

Icons (Moon Phases):
  🌑 Heavy   → Full dark circle
  🌒 Low     → Crescent right
  🌓 Here    → Half moon
  🌔 Light   → Crescent left
  🌕 Open    → Full bright circle

Transition on selection: 200ms opacity cross-fade
```

### 4.4 Breathing Bloom Visualizer

```
Canvas:        280×280dp, centered on screen
Min radius:    50dp (exhale floor / idle)
Max radius:    120dp (inhale peak)
Glow rings:    3 concentric at radius × 1.12, 1.24, 1.36
               Opacity: 12%, 8%, 4% (inner → outer)
Core fill:     accent-sage (inhale) ↔ accent-dusk (exhale) via ColorTween
Timing:        Inhale: 4000ms easeInOutSine / Exhale: 8000ms easeInOutSine
Phase label:   display-md, centered, "Breathe in" / "Let go"
Background:    bg-canvas-deep (#0E1211) — full-screen OLED black
```

### 4.5 Card Component

```
Background:    bg-surface (#18201D)
Border:        1dp, bg-overlay (#28342F)
Corner radius: 16dp
Padding:       space-md (16dp) all sides
Margin:        space-xs (8dp) vertical, space-md (16dp) horizontal
Elevation:     0 — no shadow; differentiated by background color only
```

---

## 5. Motion & Haptics

### 5.1 Motion Token Catalog

| Token | Duration | Curve | Use |
|---|---|---|---|
| `motion-instant` | 0ms | — | `disableAnimations` override |
| `motion-micro` | 80ms | `easeOut` | Button press opacity |
| `motion-quick` | 150ms | `easeOut` | Chip fade, icon swap |
| `motion-standard` | 300ms | `easeInOut` | Card entrance, page element |
| `motion-deliberate` | 500ms | `easeInOutSine` | Page transition, modal slide |
| `motion-breath-in` | 4000ms | `easeInOutSine` | Bloom expand |
| `motion-breath-out` | 8000ms | `easeInOutSine` | Bloom contract |
| `motion-ambient` | 12000ms+ | `linear` | Background colour drift |

**Reduced Motion Rule:** All `AnimationController` durations pass through `MotionTokens.resolve(duration, context)`. When `MediaQuery.of(context).disableAnimations == true`, duration collapses to `Duration.zero`.

### 5.2 Haptic Mapping Table

| Event | Pattern | Flutter Call |
|---|---|---|
| Inhale phase start | Double light pulse (100ms gap) | `HapticFeedback.lightImpact()` × 2 |
| Exhale phase start | Single light pulse | `HapticFeedback.lightImpact()` × 1 |
| Mood tile selected | Selection click | `HapticFeedback.selectionClick()` |
| Energy slider midpoint | Soft tick | `HapticFeedback.selectionClick()` |
| 5-4-3-2-1 step confirm | Selection click | `HapticFeedback.selectionClick()` |
| Tiny step completed | Warm double tap (200ms gap) | `HapticFeedback.mediumImpact()` × 2 |
| Journal saved | Soft single pulse | `HapticFeedback.lightImpact()` |
| Safety plan accessed | Firm single impact | `HapticFeedback.heavyImpact()` |
| Panic button confirm | 300ms sustained | `SystemChannels` vibrate |
| Error / blocked | Short double tick (50ms gap) | `HapticFeedback.lightImpact()` × 2 |

---

## 6. Spacing & Grid System

### 6.1 Spacing Scale (4pt Baseline Grid)

| Token | Value | Use Case |
|---|---|---|
| `space-2xs` | 4dp | Icon inner padding, label gaps |
| `space-xs` | 8dp | Tight spacing, caption margin |
| `space-sm` | 12dp | Component inner padding (compact) |
| `space-md` | 16dp | Standard card padding, row spacing |
| `space-lg` | 20dp | Section internal padding |
| `space-xl` | 24dp | Between card components |
| `space-2xl` | 32dp | Section separators |
| `space-3xl` | 48dp | Screen vertical breathing room |
| `space-4xl` | 64dp | Large gap anchors |

### 6.2 Screen Layout Template

```
┌─────────────────────────────────────────┐
│  StatusBar (transparent, light icons)   │
├─────────────────────────────────────────┤  ← space-3xl top padding
│                                         │
│  Screen Title (heading-lg)              │  ← space-md below
│  Subtitle (body-md, text-muted)         │
│                                         │
├─────────────────────────────────────────┤  ← space-2xl gap
│  Primary Content                        │
│  (single task / decision)               │
│                                         │
├─────────────────────────────────────────┤  ← space-2xl gap
│  Primary CTA (56dp, full-width)         │
│  Secondary CTA (text, centered)         │
├─────────────────────────────────────────┤
│  BottomNavigation (64dp)                │
└─────────────────────────────────────────┘
```

---

## 7. Accessibility Requirements

| Requirement | Target | Tool |
|---|---|---|
| Text contrast (primary) | ≥ 7:1 (WCAG AAA) | Colour Contrast Analyser |
| Text contrast (secondary) | ≥ 4.5:1 (WCAG AA) | Colour Contrast Analyser |
| Interactive element contrast | ≥ 3:1 | WCAG 2.2 §1.4.11 |
| Touch target size | ≥ 56×56dp | Flutter `SemanticsChecker` |
| Dynamic type support | Up to 200% | Physical device test |
| Screen reader labels | All interactive elements | VoiceOver + TalkBack |
| Reduced motion | Full `disableAnimations` support | Simulator accessibility setting |
| Focus order | Logical reading order | Keyboard navigation test |
| Error identification | Never colour-only | Icon + text always |

---

## 8. Banned Design Patterns

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
| Skeleton loaders | False urgency (data is local) | Instant render |
