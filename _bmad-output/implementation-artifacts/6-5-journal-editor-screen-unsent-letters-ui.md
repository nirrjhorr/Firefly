# Story 6.5: Distraction-Free Journal Editor Screen & Unsent Letters UI

Status: ready-for-dev

## Story Description
As a user seeking emotional catharsis without distraction,
I want a serene, distraction-free writing canvas with offline voice dictation and clear privacy controls,
So that I can write freely without judgment, pressure, or cognitive overwhelm.

## Acceptance Criteria
1. Full implementation of `JournalListScreen` replacing placeholder:
   - Header with calm title, search/filter, and "New Entry" / "Unsent Letter" primary actions.
   - List of journal cards displaying title, date, word count, and TTL countdown chip (e.g. "Auto-deletes in 5h" or "Unsent Letter").
   - Swipe or button to delete with haptic confirmation.
   - Empty state with compassionate prompt: "A quiet space to let thoughts exist without being judged."
2. Full implementation of `JournalEntryScreen` replacing placeholder:
   - Calming canvas in `#111518` with Atkinson Hyperlegible body font.
   - Expandable title and multi-line body editor.
   - Mic button toggling offline Vosk dictation with subtle sage pulse animation.
   - TTL selector bottom sheet or chips: "Keep permanently", "1 Hour", "24 Hours", "7 Days".
   - "Unsent Letter: Burn Now" button: Triggers warm double-tap haptic, subtle dissolve animation, and immediate cryptographic erasure.
   - Back button prompts autosave or discard cleanly without lost text.
3. Widget tests:
   - Verifying journal list renders entry cards and TTL chips.
   - Verifying editor input, word count reactive update, and TTL selection.
   - Verifying voice toggle button state.
   - Verifying burn action confirmation and navigation back to list.
