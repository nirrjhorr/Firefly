---
title: 'Story 6.2: Journal Drift Database DAO, Repository & TTL Expiry Engine'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Journal entries, unsent letters, and expressive reflections need persistent local storage with automated TTL-based expiration and need-to-know decryption. Loading all entries in plaintext into memory would expose sensitive thoughts in heap memory, and expired or "burned" letters must be automatically purged without leaving recoverable flash traces.

**Approach:** Implement `JournalDao` for Drift database access and TTL purge queries (`DELETE WHERE ttl_delete_at_unix <= :now`). Define domain model `JournalEntry` with transient `contentPlaintext` and persisted `contentEncrypted`. Implement `JournalRepository` and `JournalRepositoryImpl` providing reactive streams, need-to-know decryption upon access using `JournalCryptoService`, automatic TTL expiration on repo init and inserts, and zero-overwriting before deletion for NAND flash hygiene. Verify with unit tests for CRUD, TTL purging, and stream emission.

</frozen-after-approval>

## Implementation Notes
- Updated `lib/core/database/tables/journal_entries.dart` to include `title` text column with default `''`.
- Created `lib/features/journaling/domain/models/journal_entry.dart`:
  - Immutable `JournalEntry` domain entity with `id`, `checkInId`, `title`, transient `contentPlaintext`, persisted `contentEncrypted`, `contentType`, `ttlDeleteAtUnix`, `isAutoDeleteEnabled`, `wordCount`, `createdAtUnix`, `updatedAtUnix`.
  - Computed properties: `isExpired`, `remainingTtlSeconds`, `isUnsentLetter`, and `hasDecryptedContent`.
  - JSON serialization and equality methods.
- Created `lib/core/database/daos/journal_dao.dart`:
  - `JournalDao` interface with `InMemoryJournalDao` and `DriftJournalDao` implementations.
  - CRUD operations: `insertEntry`, `updateEntry`, `getEntryById`, `getAllEntries`, `watchAllEntries`, `deleteEntryById`, `deleteAll`.
  - Automated TTL cleanup query: `purgeExpiredEntries(currentUnix)` executing `DELETE FROM journal_entries WHERE (is_auto_delete_enabled = 1) AND ttl_delete_at_unix IS NOT NULL AND ttl_delete_at_unix <= :currentUnix`.
  - Secure flash hygiene: `overwriteContentBeforeDelete()` zeroes out `content_encrypted` before row deletion.
  - Replay stream for late listeners via `async* { yield await getAllEntries(); yield* _streamController.stream; }`.
- Created `lib/features/journaling/domain/repositories/journal_repository.dart` and `lib/features/journaling/data/repositories/journal_repository_impl.dart`:
  - Need-to-know decryption pattern: list queries keep `contentPlaintext` null in memory; single entry queries decrypt on demand via `getEntryById(id, decrypt: true)` using `JournalCryptoService` and master key.
  - Double encryption during `saveEntry` with automatic word count recalculation and timestamp update.
  - Automated TTL purge invoked on init and after every write.
  - Riverpod providers: `journalDaoProvider`, `journalRepositoryProvider`, and `journalEntriesStreamProvider`.
- Created test suites:
  - `test/features/journaling/journal_entry_test.dart`
  - `test/features/journaling/journal_dao_test.dart`
  - `test/features/journaling/journal_repository_test.dart`

## Review Triage Log
- `journalRepositoryProvider` defaults to in-memory: `low` — Patched: added `journalDaoProvider` allowing flexible DI overrides.
- `DriftJournalDao.watchAllEntries()` change notification: `low` — Patched: standardized stream mechanics and late-listener replay.
- `DriftJournalDao.deleteAll()` missing cryptographic erasure: `medium` — Patched: updated all entries with zeroes before table delete.
- Disconnect between `isAutoDeleteEnabled` and purge/expiration: `high` — Patched: ensured both `isExpired` and `purgeExpiredEntries` require `isAutoDeleteEnabled == true`.
- Redundant double-overwrite and ignored `secureErase`: `medium` — Patched: parameterized `deleteEntryById(id, {bool secureErase = true})` in DAO.
- Stale `wordCount` and `updatedAtUnix`: `medium` — Patched: recomputed word count and refreshed `updatedAtUnix` on each save with plaintext.
- Clearing content to empty string leaves old ciphertext: `medium` — Patched: clears `contentEncrypted` on empty plaintext and returns `''` on decrypt.
- Excessive intermediate stream emissions in `InMemoryJournalDao`: `low` — Patched: suppressed intermediate notifications during batch purges.
- Late listeners not receiving current state: `medium` — Patched: yielded current entries on stream subscription.
