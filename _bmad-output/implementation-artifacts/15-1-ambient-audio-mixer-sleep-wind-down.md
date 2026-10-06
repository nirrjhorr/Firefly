---
title: 'Story 15.1: Ambient Audio Mixer & Sleep Wind-Down (Epic 15 / FR-02 / RM-03)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '61214e1'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/epics.md', 'research data/Activity_Architecture.md']
---

## Intent

**Problem:** Sleep disruption, bedtime hyperarousal, and insomnia are major drivers of distress and autonomic dysregulation. Single-track soundscapes often fail to match an individual's acoustic sensitivity (e.g. rain may be too sharp without brown noise masking; crickets may need gentle wind chimes). Furthermore, sudden silence when a timer ends frequently wakes users who were drifting off.

**Approach:** Implement a multi-channel Ambient Audio Mixer and Sleep Wind-Down suite (`AmbientAudioMixerScreen` / `SleepWindDownScreen`):
1. **Multi-Channel Sound Mixing:** Layer 2-3 simultaneous offline tracks (Gentle Rain, Deep Brown Noise, Night Crickets, Warm Hearth, Night Chimes, Ocean Waves) with independent channel volume controls, mute/unmute states, and master volume.
2. **Restful Presets:** Evidence-informed curated presets ("Rainy Hearth", "Night Meadow", "Tidal Blanket", "Deep Masking") allowing single-tap relaxation without decision fatigue.
3. **Logarithmic Fading Sleep Timer:** Smooth logarithmic volume attenuation over the final 5 minutes of a 15–60 minute session, preventing sleep-state awakening caused by sudden audio termination.
4. **Low-Stimulation Design:** Ultra-dark `#0A0D0F` canvas, warm amber `#E5B870` sub-3000K typography, accessible touch targets ≥ 56dp, zero gamification or streaks.
5. **Universal Integration:** Seamless routing via `AppRoutes.ambientMixer` (`/home/ambient-mixer` and modal `/ambient-mixer`), SOS panic overlay protection, and post-session `EffectivenessFeedbackSheet` logging.

## Acceptance Criteria Verification

- [x] Domain models for `AmbientMixerChannel`, `AmbientMixerPreset`, and `AmbientMixerState` with immutable copyWith, state transitions, and volume computation.
- [x] Multi-channel audio mixer controller supporting independent channel audio players, volume attenuation, master level, presets, and logarithmic timer attenuation.
- [x] `AmbientAudioMixerScreen` adhering to ultra-dark `#0A0D0F` design system, responsive touch controls, and preset selectors.
- [x] Logarithmic attenuation mathematical verification (`computeLogarithmicFadeFactor`) over final 300 seconds (Weber-Fechner psychoacoustic modeling).
- [x] Full routing integration in `AppRoutes` and `app_router.dart` with SOS overlay compatibility.
- [x] Catalog alignment in `curated_activities.json` and `ActivitySeedingService`.
- [x] Standalone test runner (`test/features/soundscapes/verify_ambient_audio_mixer_standalone.dart`) with 100% assertions passing.

## Code Artifacts

- `lib/features/soundscapes/domain/models/ambient_mixer_channel.dart`
- `lib/features/soundscapes/domain/models/ambient_mixer_preset.dart`
- `lib/features/soundscapes/domain/models/ambient_mixer_state.dart`
- `lib/features/soundscapes/presentation/controllers/ambient_audio_mixer_controller.dart`
- `lib/features/soundscapes/presentation/widgets/ambient_channel_card.dart`
- `lib/features/soundscapes/presentation/widgets/ambient_preset_selector.dart`
- `lib/features/soundscapes/presentation/screens/ambient_audio_mixer_screen.dart`
- `lib/core/routing/app_routes.dart`
- `lib/core/routing/app_router.dart`
- `lib/features/sleep/presentation/widgets/sleep_timer_selector.dart`
- `lib/features/activities/data/services/activity_seeding_service.dart`
- `test/features/soundscapes/verify_ambient_audio_mixer_standalone.dart`
