# Firefly — Screen Inventory & Feature Mapping Specification

**Version:** 2.1.0  
**Status:** Approved & Implemented  
**Classification:** Product Architecture & Design Systems Source of Truth  
**Target Platform:** Flutter (Mobile iOS & Android, 100% Offline, Privacy-First)  

---

## 1. Executive Summary & Design Constraints

This document defines the comprehensive screen architecture, visual hierarchy, and interaction mapping for **Firefly**. Every screen adheres strictly to Firefly's core design philosophy:

1. **Serene & Low Cognitive Load:** Exactly one primary CTA per screen. No visual clutter. Low information density during moments of distress.
2. **Anti-Gamification:** ZERO streak counters, achievement badges, confetti, or "missed day" red alerts. Progress is measured by presence, not performance.
3. **Accessibility-First:** All touch targets meet or exceed $56 \times 56\text{dp}$ ($72\text{dp}$ for micro-actions). WCAG 2.2 AAA contrast for body typography. Full support for 200% dynamic type scale.
4. **Color Palette & Tone:** Muted slate canvas (`#F8FAFC`) or night canvas (`#111518` / `#0A0D0F`). Sage Green (`#4A7862` / `#7DBA9B`) for primary actions, Dusk Blue (`#5B8A99`) for secondary, Crisis Coral (`#B05454`) for clinical safety. Warm, non-clinical, unhurried tone.
5. **Persistent Global Anchors:** Subtle SOS shield button anchored to the bottom-right of every content screen.

---

## 2. Global UI Component Inventory

To ensure consistency and maintainability, all views are composed from standardized, reusable design system components:

| Component | Visual Specification | Behavior & Accessibility |
|---|---|---|
| `FireflyPrimaryButton` | $\ge 56\text{dp}$ height, $28\text{dp}$ pill radius. Background: Sage Green (`#4A7862` / `#7DBA9B`), Text: Pure white (`#FFFFFF`, AAA ratio $\ge 4.5:1$). | Micro-scale spring (0.98) on press, light haptic feedback. Max 1 instance per viewport. |
| `FireflySecondaryButton` | $\ge 56\text{dp}$ height, transparent background with $1.5\text{dp}$ Dusk Blue (`#5B8A99`) border or subtle fill (`#1E2328`). | De-escalated, optional actions ("I'll do this later", "Explore more"). |
| `SosOverlayButton` | Floating shield button ($56 \times 56\text{dp}$) at 25% resting opacity. Anchored at bottom-right (`Positioned(bottom: 24, right: 16)`). | Tapping immediately opens the Stanley-Brown Emergency Safety Overlay. |
| `MoodTile` | 5 moon-phase circular or rounded tiles (Heavy, Low, Here, Light, Open) with high-contrast icon glyphs. | Mutually exclusive toggle. Immediate visual confirmation without pressure. |
| `EnergySlider` | Horizontal continuous drag bar with tactile stops: "Still → Sluggish → Steady → Active → Moving". | Real-time state mapping to energy-tiered activity filtering. |
| `CyclicSighBloomPainter` | Procedural organic mathematical bloom visualizer drawn on `CustomPainter`. Smooth 60fps expansion (sage) and contraction (dusk blue). | Phase-synchronized with respiration engine (4s double-inhale, 8s exhale) with gentle haptic boundaries. |
| `PmrSilhouette` | Interactive anatomical vector body map highlighting 10 distinct muscle zones during tension/release cycles. | Head-to-toe progression with synchronized haptic guidance. |
| `LocalSafetyBanner` | Low-stimulation card in `surfaceCard` with subtle `#B05454` crisis coral border. Non-intrusive, non-blocking text alert. | Surfaces when `CrisisPhraseDetector` triggers. Direct 1-tap pathway to `/safety-plan`. Dismissible. |
| `SereneBottomSheet` | Dark modal sheet with rounded top corners ($24\text{dp}$) and drag handle. | Displays secondary menus, audio timers, and after-session effectiveness feedback. |

---

## 3. Feature-to-Screen Mapping

### Module 1: Onboarding & Clinical Scope Disclaimers
* **Screen Name & Route:** `OnboardingScreen` (`/onboarding`)
* **Core Purpose:** Transparently establish clinical scope boundaries, introduce offline privacy, and guide the user gently into the app.
* **Key UI Elements:** Serene introductory cards, clear statement that Firefly supports rather than replaces professional care, and hardware encryption setup explanation.
* **Primary CTA:** "Begin Sanctuary" (`FireflyPrimaryButton`).
* **Design Vibe:** Quiet, spacious slate canvas with generous margins. No pressure, no account creation, no email fields.

### Module 2: The Affect Check-In Engine
* **Screen Name & Route:** `CheckInScreen` (`/home/check-in`)
* **Core Purpose:** State-matched self-reflection capturing mood, energy, anxiety, and loneliness without clinical scoring.
* **Key UI Elements:** 5 moon-phase mood tiles, horizontal energy slider ("Still → Moving"), 5-dot anxiety/loneliness selectors, and quick-access emergency cards.
* **Primary CTA:** "Find What Helps" (`FireflyPrimaryButton`).
* **Design Vibe:** Low-stimulation `#111518` background. Soft ambient lighting, unhurried animations.

### Module 3: The "Right Now" Urgent Fast Path
* **Screen Name & Route:** `RightNowModal` (`/home/right-now`)
* **Core Purpose:** Zero-friction rescue path offering 13 acute distress anchors for users with near-zero cognitive bandwidth.
* **Key UI Elements:** Tactile anchor cards (e.g., "Racing Heart", "Cannot Sleep", "Heavy Fog", "Panic / SOS", "Freeze").
* **Primary CTA:** Tap on any distress card immediately routes to the target regulation exercise.
* **Design Vibe:** Full-screen modal barrier with high-contrast, large touch targets ($\ge 64\text{dp}$) and instant routing (< 1ms).

### Module 4: Breathing Studio (Respiration Engine)
* **Screen Name & Route:** `BreathingGroundingScreen` (`/home/breathe`)
* **Core Purpose:** Down-regulate the autonomic nervous system via evidence-based cyclic sighing, box breathing, and resonance breathing.
* **Key UI Elements:** Central `CyclicSighBloomPainter`, technique selector pill, audio ambience toggle, and pacing timer.
* **Primary CTA:** "Begin Breathing" / "Pause" (`FireflyPrimaryButton`).
* **Design Vibe:** Deep sanctuary dark mode (`#0A0D0F`), soothing rhythmic expansion and contraction in sage green and dusk blue.

### Module 5: Progressive Muscle Relaxation (PMR)
* **Screen Name & Route:** `PmrScreen` (`/home/pmr`)
* **Core Purpose:** Somatic discharge of physical tension from head to toe using the Jacobson protocol.
* **Key UI Elements:** Interactive anatomical silhouette highlighting active muscle regions (Forehead, Jaw, Shoulders, Hands, Abdomen, Feet) during Tense/Hold/Release phases.
* **Primary CTA:** "Begin Session" / "Next Muscle Group" (`FireflyPrimaryButton`).
* **Design Vibe:** Calming dark silhouette with glowing sage tension indicators.

### Module 6: Sensory & Cognitive Grounding
* **Screen Name & Route:** `CognitiveGroundingScreen` (`/home/cognitive-grounding`) & `SensoryGroundingScreen`
* **Core Purpose:** Shift working memory away from intrusive thoughts or internal spirals toward structured external anchors.
* **Key UI Elements:** 5-4-3-2-1 tactile progression cards, category name prompts, backward counting, and alphabet association tasks.
* **Primary CTA:** "Next Step" / "That's Enough for Now" (`FireflyPrimaryButton`).
* **Design Vibe:** High readability typography, zero timers, zero scoring, zero error buzzers.

### Module 7: Tiny Steps (Behavioral Activation)
* **Screen Name & Route:** `TinyStepsScreen` (`/home/tiny-steps`) & `TinyStepDetailScreen` (`/tiny-step/:id`)
* **Core Purpose:** Overcome depressive inertia with state-matched micro-actions completable in under 2 minutes.
* **Key UI Elements:** Large action cards ($\ge 72\text{dp}$ touch target) filtered by current energy; optional 2-minute soft timer; guilt-free "I'll do this later" button.
* **Primary CTA:** "Done" with gentle haptic pulse (no confetti, no streaks).
* **Design Vibe:** Tactile card deck with generous padding and warm illustrations.

### Module 8: Expressive Journaling & Sleep Worry Dump
* **Screen Name & Route:** `JournalEntryScreen` (`/home/journal` & `/home/worry-dump`)
* **Core Purpose:** Externalize emotions with double-encrypted AES-256-GCM storage, optional offline Vosk voice dictation, and "Burn Now" zeroing.
* **Key UI Elements:** Distraction-free writing canvas, word count badge, TTL auto-delete selector, "Burn Now" button, and `LocalSafetyBanner` for crisis phrase interception.
* **Primary CTA:** "Save" (`FireflyPrimaryButton`) or "Burn Now" (`FireflySecondaryButton`).
* **Design Vibe:** Deep graphite canvas (`#111518`), monospace word counter, clean typography without toolbars.

### Module 9: Loneliness Comfort & Social Connection
* **Screen Name & Route:** `LonelinessComfortScreen` (`/home/loneliness`)
* **Core Purpose:** Normalize isolation, challenge rejection fears via "Guess vs. Reality" cognitive experiments, and facilitate low-barrier outreach.
* **Key UI Elements:** Normalization quote cards, 7 pre-scripted SMS outreach templates, cooperative activity suggestions (Parallel Quiet, Shared Puzzles), and prediction outcome logger.
* **Primary CTA:** "Send Message" (`FireflyPrimaryButton` triggering system SMS intent).
* **Design Vibe:** Warm amber and dusk tones providing warmth without false cheerfulness.

### Module 10: Hope Box (Offline Coping Vault)
* **Screen Name & Route:** `HopeBoxScreen` (`/home/hope-box`)
* **Core Purpose:** Multi-media offline repository of personal comfort anchors (photos, reasons to keep going, audio notes, quotes).
* **Key UI Elements:** Encrypted media grid, filter tabs (Photos, Words, Audio, Reminders), media importer, and full-screen serene viewer.
* **Primary CTA:** "Add Comfort Anchor" (`FireflyPrimaryButton`).
* **Design Vibe:** Warm, personal gallery with soft corners and subtle transitions.

### Module 11: Gentle Progress (Presence Reflection)
* **Screen Name & Route:** `GentleProgressScreen` (`/home/progress`)
* **Core Purpose:** Zero-guilt reflection on moments of presence without numerical streak counters or gamification pressure.
* **Key UI Elements:** Organic presence garden / gentle constellation dots, recent regulation tools used, and personal effectiveness insights.
* **Primary CTA:** "Reflect on Today" (`FireflySecondaryButton`).
* **Design Vibe:** Serene landscape visualization where absence leaves quiet space rather than broken chains.

### Module 12: Stanley-Brown Safety Plan & Emergency System
* **Screen Name & Route:** `SafetyPlanScreen` (`/safety-plan`), `SafetyPlanEditorScreen` (`/safety-plan/edit`), & `PanicBlankScreen` (`/panic`)
* **Core Purpose:** Clinical SPI crisis intervention across 6 evidence-based steps, 1-tap phone/sms reach-out, and panic screen blanking (< 100ms).
* **Key UI Elements:** 6 interactive step accordions, trusted contacts with call/text buttons, crisis hotlines (988), emergency blanking trigger, and fast contact editor.
* **Primary CTA:** "Call" / "Text" / "Edit Safety Plan".
* **Design Vibe:** High-clarity, high-contrast interface designed for acute crisis situations with zero ambiguity.

---

## 4. Extended Sanctuary Screens (v2 Architecture)

| Route | Screen Name | Regulation Mechanism |
|---|---|---|
| `/home/nature` | `NatureObservationScreen` | Guided outdoor micro-observation (Sky gazing, Tree canopy, Light & shadow). |
| `/home/somatic` | `SomaticCenteringScreen` | Somatic visualizations (Heavy body gravity settling, Warm hands peripheral dilation). |
| `/home/labyrinth` | `LabyrinthScreen` | Continuous finger classical labyrinth and spiral tracing canvas. |
| `/home/flow-puzzle` | `FlowPuzzleScreen` | Cognitive flow and spatial working memory interruption. |
| `/home/defusion` | `CognitiveDefusionScreen` | Acceptance & Commitment Therapy defusion (Leaves on a Stream, Thought Cloud Dissolve). |
| `/home/ambient-mixer` | `AmbientAudioMixerScreen` | 6-channel multi-track soundscape mixer with Weber-Fechner logarithmic sleep timer attenuation. |

---

## 5. Z-Index & Overlay Architecture

To guarantee user safety and sensory protection, the application implements a strict 6-layer visual hierarchy:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        FIREFLY OVERLAY HIERARCHY                       │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 6: Local Crisis Phrase Interceptor (LocalSafetyBanner)           │
│          Non-blocking top alert when acute crisis language is detected │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 5: Panic Blackout Shield (PanicBlankScreen)                      │
│          Pure black (#000000) OLED blanking for emergency privacy      │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 4: Stanley-Brown Safety Plan Modal Overlay                       │
│          Root modal accessible anywhere via 1 tap without losing state │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 3: System Sheets & Feedback Dialogs (SereneBottomSheet)          │
│          Effectiveness rating, audio timers, preset selectors          │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 2: Floating SOS Shield & Audio Pill (SosOverlayButton)           │
│          Persistent bottom-right shield (25% resting opacity)          │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 1: Base Application Viewport & Shell Navigation                  │
│          Active feature screens, bottom navigation shell, scrollers    │
└────────────────────────────────────────────────────────────────────────┘
```

1. **Layer 1: Base Application Viewport:** Active feature view and navigation shell mounted within `MainShellScaffold`.
2. **Layer 2: Persistent SOS Shield:** Anchored at `Positioned(bottom: 24, right: 16)` across all screens with 25% resting opacity.
3. **Layer 3: System Sheets:** Modal bottom sheets for after-session effectiveness feedback (`EffectivenessFeedbackDialog`), audio mixers, and configuration drawers.
4. **Layer 4: Stanley-Brown Safety Modal:** Root navigator modal mounted over any view without resetting active session state.
5. **Layer 5: Panic Blackout Shield:** Instant pure black (`#000000`) screen blanking with memory zeroing (`_zeroMemory`), activated in < 15ms.
6. **Layer 6: Local Crisis Phrase Interceptor:** Non-blocking soft banner mounted dynamically in text-entry views when acute distress keywords are detected locally.
