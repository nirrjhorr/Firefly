# Story 4.4: 5-4-3-2-1 Sensory Grounding Mode

Status: ready-for-dev

## Story Description
As an overwhelmed user experiencing sensory or cognitive overload,
I want a step-by-step 5-4-3-2-1 sensory grounding exercise,
So that I can anchor myself in my immediate physical reality through guided perceptual prompts.

## Acceptance Criteria
1. Domain models & state for 5 sensory stages:
   - 5 things to see
   - 4 things to touch / feel
   - 3 things to hear
   - 2 things to smell
   - 1 thing to taste
2. `GroundingController` managing stage index, items noticed, and completion state.
3. `GroundingPromptCard` UI:
   - Displays current sensory prompt with high-contrast, low-stimulation styling.
   - Interactive item check-offs or gentle tap to advance.
   - Haptic click feedback on each confirmed sensation.
   - Back / skip options without penalty.
4. Completion card acknowledging grounded state with one-tap return to home or transition to slow breathing.
5. Unit and widget tests verifying step-by-step navigation and state reset.
