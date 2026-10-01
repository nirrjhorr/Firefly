---
title: 'Story 6.5: Distraction-Free Journal Editor Screen & Unsent Letters UI'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 1
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Existing journal screens are non-functional placeholders. Users experiencing emotional distress require a distraction-free, low-stimulation dark canvas (`#111518`), comfortable Atkinson Hyperlegible typography, offline speech-to-text dictation with gentle pulse animation, selectable auto-delete TTL presets, and an instant "Burn Now" unsent letter action with tactile confirmation and dissolve animation.

**Approach:** Replace placeholders `JournalListScreen` and `JournalEntryScreen`. In `JournalListScreen`, build a calm header, "New Reflection" and "Unsent Letter" creation buttons, list of journal cards with reactive TTL countdown chips, compassionate empty state, and swipe/button deletion. In `JournalEntryScreen`, provide a distraction-free dark canvas (`#111518`), expandable title, multi-line body with live word count, Vosk voice dictation button with sage pulse visualizer, TTL interval selection chips, and a prominent "Unsent Letter: Burn Now" button that triggers warm double haptics, dissolve animation, and immediate cryptographic erasure. Verify with widget tests in `test/features/journaling/journal_screens_test.dart`.

</frozen-after-approval>

## Implementation Notes

- **Distraction-Free Dark Canvas (`JournalEntryScreen`)**:
  - Implemented in `lib/features/journaling/presentation/screens/journal_entry_screen.dart` with trauma-informed `#111518` background, Atkinson Hyperlegible typography (`AppTypography`), and high contrast readable input fields.
  - Displayed outside `MainShellScaffold` by specifying `parentNavigatorKey: _rootNavigatorKey` in `app_router.dart`, ensuring no bottom navigation bars distract the user while writing.
  - Provided expandable title and multiline body fields with live word count in the AppBar (`$wordCount words`).
  - Added choice chips for TTL intervals: `Keep permanently`, `1 Hour`, `24 Hours`, `7 Days`.
  - Added offline Vosk voice dictation with an animated sage pulse indicator (`Icons.mic`), streaming partial transcriptions without stutter, with ticker only running during active dictation.
  - Added instant "Burn Now" action with double-tap tactile feedback (`HapticFeedback.mediumImpact()`), 350ms opacity dissolve animation, and cryptographic erasure via `controller.burnEntry()`.
  - Added dirty tracking (`_isDirty`) and `PopScope` integration preventing accidental data loss when exiting.

- **Confidential Journal & Unsent Letters List (`JournalListScreen`)**:
  - Implemented in `lib/features/journaling/presentation/screens/journal_list_screen.dart`.
  - Features quick-action buttons for `+ New Reflection` and `Unsent Letter` (pre-selecting 24h TTL preset).
  - Search filter field dynamically filtering entries by title with fallback to "Untitled reflection" matching.
  - Cards display entry titles, word counts, formatted dates, voice dictation indicators, and formatted TTL countdown chips ("Encrypted", "Auto-deletes in 24h", "Auto-deletes <1h", "Expired").
  - Background minute ticker (`Timer.periodic`) updates TTL countdown chips reactively.
  - Delete reflection button with confirmation dialog and permanent cryptographic zero-overwrite before row removal.
  - Manual purge button with explicit count / empty-state feedback.
  - Low-stimulation empty state ("A Quiet, Judgment-Free Space") with shield/lock icon when no entries exist.

- **Theme & Design System Tokens**:
  - Extended `AppCustomColorsAliases` in `lib/core/theme/app_colors.dart` with `background`, `textTertiary`, `crisisRed`, and `accentAmber` semantic aliases matching Firefly design system tokens.

- **Test Suite**:
  - Comprehensive widget tests in `test/features/journaling/journal_screens_test.dart` validating:
    - Empty and populated list views, search filtering, card formatting, TTL chips, purge feedback, and route navigation.
    - Dark canvas rendering, existing entry loading, reactive word counting, TTL choice chip selection, offline Vosk dictation toggle and streaming, voice error handling, burn sequence confirmation & dissolve animation, save persistence, clean exit on unchanged entries, dirty prompts on edited entries, and error banner indicators.

## Review Triage Log

- **Routing & ID Collision**: Fixed in `app_router.dart` and `JournalEditorController` by guarding against treating `'new'` or `'new-letter'` route segments as database primary keys, generating fresh UUIDs for new reflections.
- **Theme Color Aliases**: Added `background`, `textTertiary`, `crisisRed`, and `accentAmber` to `AppCustomColorsAliases` in `app_colors.dart`.
- **Pulse Ticker Battery Drain**: Optimized `_pulseController` to only run animation repeat ticker when `state.isListening == true`, stopping and resetting ticker when dictation is inactive.
- **Dirty State & PopScope Deadlock**: Added `_savedTitle`/`_savedContent` tracking and `_isExiting` flag, allowing clean exit for unedited entries and avoiding re-interception by `PopScope`.
- **Reactive TTL Countdown Ticker**: Added 60s periodic timer in `_JournalListScreenState` to keep remaining TTL chip durations accurate in real-time.
- **Accessibility & Touch Target Sizes**: Added `Semantics` label to mic dictation toggle, `tooltip` to back navigation button, and restored standard accessible touch targets on card deletion buttons.
- **Save & Purge Feedback**: Added explicit SnackBar messages on save failures and zero-item purges.
- **Burn Sequence Failure Resilience**: Added try/catch and opacity restoration to prevent permanent canvas blackout if cryptographic erasure encounters storage errors.
- **ShellRoute Isolation**: Added `parentNavigatorKey: _rootNavigatorKey` on `:id` route to render `JournalEntryScreen` completely distraction-free without bottom navigation tabs.
- **Textfield Unfocus**: Added `FocusScope.of(context).unfocus()` prior to burn animations and back navigation dialogues to prevent layout jumping.
