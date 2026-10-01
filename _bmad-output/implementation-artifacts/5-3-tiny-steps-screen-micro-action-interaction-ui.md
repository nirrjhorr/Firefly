# Story 5.3: Tiny Steps Screen & Micro-Action Interaction UI

Status: done

## Story Description
As a user trying to take a small positive action,
I want an accessible, low-pressure screen displaying 3 actionable cards with tactile completion feedback,
So that completing a small step feels grounding and supportive rather than competitive.

## Acceptance Criteria
1. Full implementation of `TinyStepsScreen` replacing placeholder:
   - Header with calming title ("One small thing") and brief supportive copy.
   - Renders 3 selectable action cards (touch targets ≥ 72dp).
   - Each card displays icon, title, description, and "≤ 2 min" indicator.
2. Tactile & visual feedback on action completion:
   - Tapping "I did this" triggers warm double-tap haptic and soft sage fade.
   - Strictly NO gamified confetti, streak counters, or point popups.
   - Shows brief compassionate acknowledgement: "Momentum started. You can rest now or do another if you feel like it."
3. Low-pressure dismiss / alternative options:
   - "Try different options" button to shuffle candidates.
   - "I'll do this later" quiet dismiss action returning to Home.
4. Widget tests verifying card rendering, completion interaction, shuffle, and exit behavior.
