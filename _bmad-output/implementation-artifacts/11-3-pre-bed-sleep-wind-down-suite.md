---
title: 'Pre-Bed Sleep & Wind-Down Suite (FR-15 / RM-03)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: 'a027cb1'
route: 'dispatch'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Intrusive racing thoughts, bedtime anxiety, and blue-light screen exposure severely disrupt sleep onset and sleep maintenance. Users trapped in rumination cannot "switch off" because their minds continuously cycle through tomorrow's tasks or unresolved anxieties. Existing sleep apps often feature high-contrast bright screens, complex gamified streaks, or jarring abrupt audio cutoffs that wake users right as they begin drifting to sleep.

**Approach:** Build a dedicated, non-clinical Pre-Bed Sleep & Wind-Down Suite (`#0A0D0F` Sleep Sanctuary). Provide:
1. **Ultra-Dark Sleep Sanctuary Canvas:** Minimalist `#0A0D0F` background with warm sub-3000K amber/gold typography and accents that protect circadian melatonin release.
2. **Dual-Disposition Worry Dump:**
   - *"Park until morning"*: Encrypts the thought note using AES-256-GCM and locks it until 8:00 AM the next morning, removing it from view so the brain is granted permission to rest, with a default 24-hour auto-delete TTL.
   - *"Let it dissolve"*: Serene particle/fade dissolve animation accompanied by immediate cryptographic memory zeroing and disk erasure.
3. **Fading Ambient Sleep Timer:** Gapless offline soundscapes (Night Rain, Ocean Waves, Brown Noise, Night Crickets, Wind Chimes) with customizable sleep timers (15m, 30m, 45m, 60m) featuring smooth logarithmic volume attenuation over the final 5 minutes to prevent wake transitions.
4. **Consistent Wake-Time Companion:** Gentle, guilt-free circadian anchor setting a target wake time without harsh alarms.
5. **Integrated Post-Session Effectiveness Rating:** Optional, gentle feedback via `EffectivenessFeedbackSheet` without storing free-text notes.

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) against `#0A0D0F` dark canvas using warm amber tokens.
- Maintain zero network calls (`FireflyHttpOverride` strictly enforced).
- "Let it dissolve" must cryptographically zero memory buffers and guarantee non-recoverability.
- "Park until morning" must lock entries until 8:00 AM next day (`DateTime(now.year, now.month, now.day + 1, 8, 0)`).
- Ambient timer volume attenuation must follow a smooth logarithmic curve over the final 5 minutes.
- Support non-judgmental early exit ("That's enough for now") and persistent SOS shield overlay.

**Never:**
- Never use bright blue, high-luminance white, or flashy saturated colors in the Sleep Suite.
- Never display countdown timers, failure alerts, alarms, or buzzing chimes.
- Never force a user to read back parked worries before morning.
- Never transmit or sync sleep worry dumps to external servers.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Open Sleep Suite | User navigates to `/home/sleep` or taps "I want to sleep" in `RightNowModal` | Renders `#0A0D0F` Sleep Sanctuary with tab/toggle between Worry Dump & Fading Ambient Timer | Default to Worry Dump if `?mode=worryDump` |
| Enter Worry Note | User types racing thoughts in warm text field | Responsive auto-expanding input; buttons enable when text is non-empty | Disables actions when field is empty |
| Park Until Morning | User taps "Park until morning" | Generates UUID, derives unlock time (8:00 AM next day), encrypts content, saves to repository with 24h TTL, shows calming confirmation, clears input | Graceful error alert if storage fails |
| Let It Dissolve | User taps "Let it dissolve" | Initiates 800ms peaceful dissolve animation, zeros text in memory, permanently deletes any draft, prompts effectiveness rating | Memory wiped even if animation interrupted |
| Start Sleep Timer | User selects soundscape track (e.g. "Gentle Rain") & duration (30 min) | Starts playback, initiates timer; at remaining time ≤ 5 min, begins logarithmic volume fade down to 0.0, then stops cleanly | Audio pauses safely on screen leave or timer end |
| Wake Target Time | User sets 7:00 AM wake companion target | Saves preference quietly; shows reassuring circadian anchor note | Non-punitive if user sleeps in |
| Early Exit | User taps "That's enough for now" | Stops audio, clears transient state, returns to previous screen | Clean disposal |

</frozen-after-approval>

## Code Map

- `lib/features/sleep/domain/models/sleep_sound_track.dart` -- Sleep ambient soundscape track models and presets.
- `lib/features/sleep/domain/models/worry_dump_entry.dart` -- Domain model for pre-bed worry dumps (parked vs dissolved, unlock timestamps, TTL).
- `lib/features/sleep/domain/models/sleep_session_state.dart` -- Immutable session state model tracking active tab, active track, timer remaining, and parked entries.
- `lib/features/sleep/domain/repositories/worry_dump_repository.dart` -- Repository interface for storing and querying encrypted parked worries.
- `lib/features/sleep/data/repositories/worry_dump_repository_impl.dart` -- Repository implementation using AES-256-GCM double encryption and in-memory/drift storage.
- `lib/features/sleep/presentation/controllers/sleep_suite_controller.dart` -- StateNotifier managing worry dumping, cryptographic erasure, timer tick, and logarithmic volume fading.
- `lib/features/sleep/presentation/widgets/worry_dump_card.dart` -- Ultra-dark warm text input card with "Park until morning" and "Let it dissolve" actions.
- `lib/features/sleep/presentation/widgets/sleep_timer_selector.dart` -- Low-stimulation duration picker (15m, 30m, 45m, 60m) and track selector.
- `lib/features/sleep/presentation/widgets/wake_time_companion_card.dart` -- Guilt-free circadian wake anchor card.
- `lib/features/sleep/presentation/screens/sleep_suite_screen.dart` -- Sanctuary screen (`#0A0D0F`), SOS shield overlay, route query integration.
- `lib/core/routing/app_routes.dart` & `lib/core/routing/app_router.dart` -- Register `/home/sleep` and `/sleep` routes.
- `test/features/sleep/verify_sleep_suite_standalone.dart` -- Standalone verification test suite validating worry dump states, crypto erasure, logarithmic volume curves, and timer logic.

## Tasks & Acceptance

**Execution:**
- [x] Domain models: `sleep_sound_track.dart`, `worry_dump_entry.dart`, `sleep_session_state.dart`
- [x] Repository: `worry_dump_repository.dart` & `worry_dump_repository_impl.dart` with AES-256-GCM encryption & secure erasure
- [x] Controller: `sleep_suite_controller.dart` with dual worry disposition and logarithmic volume attenuation
- [x] UI Widgets: `worry_dump_card.dart`, `sleep_timer_selector.dart`, `wake_time_companion_card.dart`
- [x] UI Screen: `sleep_suite_screen.dart` with `#0A0D0F` dark canvas and amber warmth
- [x] Routing: Connect `AppRoutes.sleep` (`/home/sleep`), wire `RightNowModal` and `CuratedActivities`
- [x] Verification: Comprehensive test suite in `test/features/sleep/verify_sleep_suite_standalone.dart`

**Acceptance Criteria:**
- Given `SleepSuiteScreen`, the background is `#0A0D0F` and typography uses warm amber sub-3000K tones.
- Given "Let it dissolve", the text is memory-zeroed immediately and deleted without recovery.
- Given "Park until morning", the entry is AES-256-GCM encrypted and locked until 8:00 AM next day.
- Given ambient audio timer, the volume follows a logarithmic curve during the final 5 minutes down to 0.0.
- All tests pass with zero network calls and full null safety.

## Implementation Notes

- Implemented dedicated `#0A0D0F` Sleep Sanctuary with sub-3000K warm incandescent amber styling (`Color(0xFFE5B870)` and `Color(0xFFF2D9A8)`).
- Implemented Dual Disposition Worry Dump:
  - "Park until morning": Locks the thought until 8:00 AM next day (or 8:00 AM today if created in early AM), preventing nocturnal rumination. Defaults to 24-hour auto-delete TTL.
  - "Let it dissolve": 800ms smooth peaceful dissolution with instantaneous cryptographic zeroing of in-memory string buffers (`cryptoEraseString`).
- Implemented Fading Ambient Audio Timer:
  - Offline gapless loop tracks (Gentle Rain, Deep Brown Noise, Night Crickets, Ocean Waves, Warm Hearth, Night Chimes).
  - Customizable timer (15, 30, 45, 60 min).
  - Exact logarithmic volume attenuation curve over the final 5 minutes (`computeLogarithmicFadeFactor = ln(1 + 9 * (t / T)) / ln(10)`).
- Implemented Circadian Wake Companion Anchor:
  - Guilt-free, non-punitive morning wake target.
- Connected acute distress routing in `RightNowModal` ('I want to sleep' -> `AppRoutes.sleep`).
- Authored and passed `verify_sleep_suite_standalone.dart` validating all domain models, morning unlock calculations, 24h TTL, logarithmic attenuation curves, and memory zeroing.
