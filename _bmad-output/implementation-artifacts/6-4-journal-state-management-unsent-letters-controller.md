---
title: 'Story 6.4: Journal State Management & Unsent Letters Controller'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Composing emotional reflections and unsent letters requires real-time word counting, live voice streaming dictation, TTL auto-delete interval selection (1h, 24h, 7d, none), draft autosaving, and an immediate "burn" action that cryptographically erases the entry from memory and disk.

**Approach:** Implement `JournalEditorController` and `JournalListController` using Riverpod `StateNotifier`. In `JournalEditorController`, manage reactive word count, voice dictation streaming via `VoiceRecognitionPort`, TTL preset calculation, draft persistence through `JournalRepository`, and instant burn cryptographic erasure. In `JournalListController`, watch repository entries, compute TTL horizons, and provide manual purge/refresh actions. Verify with exhaustive unit tests in `test/features/journaling/journal_editor_controller_test.dart` and `test/features/journaling/journal_list_controller_test.dart`.

</frozen-after-approval>

## Implementation Notes
- Created `lib/features/journaling/presentation/controllers/journal_editor_controller.dart`:
  - `JournalTtlOption` enum: `none`, `oneHour`, `twentyFourHours`, `sevenDays` with duration calculations and friendly labels.
  - `JournalEditorState` immutable model with `title`, `content`, `wordCount`, `ttlOption`, `isListening`, `isAutoDeleteEnabled`, `isSaving`, `isBurned`, `errorMessage`, `contentType`, `initialCreatedAtUnix`.
  - `JournalEditorController` (`StateNotifier`):
    - Reactive space-delimited word count calculation.
    - Integration with `VoiceRecognitionPort` streaming partial hypotheses into the editor buffer and halting cleanly on errors or burn.
    - `saveEntry()` persisting double-encrypted entry through `JournalRepository`.
    - `burnEntry()` executing instant cryptographic wipe and purging local state.
    - `loadEntry(id)` auto-populating state for existing entries.
    - `mounted` guards preventing state mutations across async gaps.
    - Riverpod family provider `journalEditorControllerProvider(entryId)`.
- Created `lib/features/journaling/presentation/controllers/journal_list_controller.dart`:
  - `JournalListState` with `entries`, `isLoading`, `errorMessage`, and `lastPurgedCount`.
  - `JournalListController` subscribing to `watchEntries()`, providing `purgeExpired()`, `deleteEntry(id)`, and `refresh()`.
  - Riverpod provider `journalListControllerProvider`.
- Created test suites:
  - `test/features/journaling/journal_editor_controller_test.dart`
  - `test/features/journaling/journal_list_controller_test.dart`

## Review Triage Log
- `JournalEditorState.operator ==` and `hashCode` omit `initialCreatedAtUnix`: `medium` — Patched: included field in equality and hash code methods.
- First `saveEntry()` does not update `initialCreatedAtUnix`: `medium` — Patched: updated state with `initialCreatedAtUnix: createdAt` upon save.
- `journalEditorControllerProvider` family does not load existing entries: `medium` — Patched: automatically invokes `loadEntry(entryId)` in controller constructor.
- `loadEntry()` silently swallows repository errors: `medium` — Patched: sets descriptive error message on repository failure or missing record.
- `dispose()` in `JournalEditorController` fails to stop active microphone: `medium` — Patched: stops listening in `dispose()`.
- Missing `mounted` guards before updating state: `medium` — Patched: verified `mounted` checks across all async methods.
- `burnEntry()` and active voice dictation: `medium` — Patched: terminates active voice dictation immediately when burning.
- Voice `onError` listener leaves dictation in inconsistent state: `medium` — Patched: cancels voice subscriptions and stops listening on error.
- `JournalListController` lacks retry/refresh: `low` — Patched: added `refresh()` method to reconnect stream.
- Identifier generation collision risks: `low` — Patched: combined timestamp with secure random salt.
- Test suites omit coverage for error branches: `low` — Patched: added tests for error states and provider auto-loading.
