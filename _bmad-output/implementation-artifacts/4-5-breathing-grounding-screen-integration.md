# Story 4.5: Breathing & Grounding Screen Integration

Status: done

## Story Description
As a user routed from the affect check-in or home navigation,
I want a complete, low-stimulation respiration screen with soundscape controls and emergency safety access,
So that I can complete a calming session in comfort and exit whenever I need to.

## Acceptance Criteria
1. Full implementation of `BreathingGroundingScreen` replacing placeholder:
   - Deep canvas background (`bgCanvasDeep` / `#111518`).
   - Reads `?mode=grounding` query param: renders Grounding flow if true, otherwise renders Cyclic Sighing flow.
   - Pacing typography: `displayMd` ("Breathe in" / "Let go" / sensory instructions).
   - Minimalist cycle count in `caption` style (no streak tracking).
2. Soundscape selector drawer / modal:
   - Options: Ambience, Rain, Chimes, Mute.
   - Saves selection to `AudioPreferences` / state.
3. Clean exit controls:
   - Secondary button at bottom to end session gracefully.
   - Navigating back or exiting cleans up all timers and audio playback instantly.
4. Persistent SOS overlay remains functional on top of screen.
5. Widget tests for route handling, screen rendering, mode switching, and cleanup.
