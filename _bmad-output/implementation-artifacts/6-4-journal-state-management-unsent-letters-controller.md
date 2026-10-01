# Story 6.4: Journal State Management & Unsent Letters Controller

Status: ready-for-dev

## Story Description
As a user composing an expressive journal or unsent letter,
I want a responsive state controller managing draft persistence, auto-delete intervals, and instant "burn" capabilities,
So that I can safely release heavy feelings with full control over their lifecycle.

## Acceptance Criteria
1. `JournalEditorState` and `JournalEditorController` (`StateNotifier` / Riverpod):
   - Fields: `title`, `content`, `wordCount`, `ttlOption` (`none`, `oneHour`, `twentyFourHours`, `sevenDays`), `isListening`, `isAutoDeleteEnabled`, `isSaving`, `errorMessage`.
   - Reactive word count update based on space-separated tokens.
   - Voice dictation integration: Appends streaming partial/final words from `VoiceRecognitionPort` into current cursor/editor buffer.
   - `saveEntry()`: Persists entry via `JournalRepository` with application-layer encryption.
   - `burnEntry(String id)`: Unsent letter instant purge invoking cryptographic erasure and row removal.
2. `JournalListState` and `JournalListController`:
   - Watches all journal summaries from `JournalRepository`.
   - Surfaces remaining TTL time for entries with auto-delete enabled.
   - Trigger manual purge or refresh.
3. Unit tests:
   - Verifying word count calculation.
   - Verifying TTL calculation (`DateTime.now().millisecondsSinceEpoch ~/ 1000 + durationSeconds`).
   - Verifying burn action triggers complete removal.
   - Verifying voice transcript appending logic.
