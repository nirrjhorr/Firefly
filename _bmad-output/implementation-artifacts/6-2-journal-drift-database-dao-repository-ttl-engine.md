# Story 6.2: Journal Drift Database DAO, Repository & TTL Expiry Engine

Status: ready-for-dev

## Story Description
As a developer,
I want an encrypted Drift DAO and repository supporting CRUD operations and automated TTL deletion,
So that expired entries and auto-delete unsent letters are automatically purged without manual intervention.

## Acceptance Criteria
1. `JournalDao` Drift accessor attached to `JournalEntries`:
   - `insertEntry`, `updateEntry`, `deleteEntryById`, `getEntryById`, `watchAllEntries`, `deleteAll`.
   - `purgeExpiredEntries(int currentUnixTimestamp)` executing `DELETE FROM journal_entries WHERE ttl_delete_at_unix IS NOT NULL AND ttl_delete_at_unix <= :currentUnixTimestamp`.
   - `overwriteContentBeforeDelete(String id)` overwriting `contentEncrypted` with zeroes before row removal for NAND flash hygiene.
2. Domain model `JournalEntry`:
   - Properties: `id`, `checkInId` (optional), `title`, `contentPlaintext` (transient in-memory only), `contentEncrypted` (persisted), `contentType` (`text` | `voice`), `ttlDeleteAtUnix` (optional int), `isAutoDeleteEnabled`, `wordCount`, `createdAtUnix`, `updatedAtUnix`.
3. `JournalRepository` and `JournalRepositoryImpl`:
   - Need-to-know decryption pattern: Decrypts `contentEncrypted` using `JournalCryptoService` and Master Key only when an entry is specifically opened, keeping list models light and encrypted in memory.
   - Saves entries by double-encrypting through `JournalCryptoService`.
   - Triggers `purgeExpiredEntries` automatically upon repository initialization and after each insert.
4. Unit tests:
   - Verifying CRUD operations in encrypted Drift DB.
   - Verifying automated TTL query removes expired rows while retaining non-expired rows.
   - Verifying repository watch stream emits updated list when entries are created/deleted.
