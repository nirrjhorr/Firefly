---
title: 'Hope Box Offline Multi-Media Coping Vault (FR-07)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: 'HEAD'
route: 'dispatch'
review_loop_iteration: 0
context:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/epics.md
  - _bmad-output/implementation-artifacts/epic-11-context.md
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Users in moments of acute despair, emotional paralysis, or depressive loneliness often lose access to reasons for staying grounded or holding on. Standard coping apps rely on cloud-synced storage, insecure device photo albums, or complex social feeds that violate privacy. The Virtual Hope Box (Bush et al. 2017) demonstrated that an offline, private repository of personalized coping items (reasons to keep going, meaningful photos, soothing audio/music, voice recordings from loved ones, and reassuring notes) significantly enhances coping self-efficacy in crisis moments without clinical judgment.

**Approach:** Implement a 100% offline, privacy-sealed **Hope Box Offline Multi-Media Coping Vault** (`#111518` canvas with sage `#84B09A` / amber `#E5B870` accents).
1. **5 Curated Coping Item Types:**
   - **Reason to keep going** (`reason`): Prompted *"Something worth staying for:"* with prominent comforting visual styling.
   - **Written note** (`text`): Encrypted personal reminder or quote.
   - **Photo memory** (`photo`): Image reference stored securely in app-private storage, encrypted in database.
   - **Voice note** (`voice`): Reassuring voice clip recorded or stored offline.
   - **Comforting song/audio** (`audio`): Offline calming audio or track reference.
2. **Privacy on List View & Masonry Layout:**
   - List view renders items with item-type icon and truncated label/title rather than exposing full raw contents on screen.
   - Tap-to-view opens a safe, warm full-content modal with appropriate viewer (text/reason card, image preview, audio playback controller).
3. **Application-Layer Encryption & Secure Physical Erasure:**
   - Text contents and file paths encrypted at rest with AES-256-GCM.
   - Physical media files quarantined exclusively in app-private storage (`getApplicationDocumentsDirectory()`) and flagged to exclude OS cloud backup.
   - Immediate multi-pass physical file deletion and memory buffer zeroing upon item deletion.
4. **Distress Fast-Path & Safety Controls:**
   - Accessible via `/home/hope-box` and `/hope-box` modal route.
   - Persistent SOS panic button support (immediate screen blanking in <100ms and memory wipe).
   - Non-judgmental early exit ("That's enough for now") and post-session effectiveness rating via `EffectivenessFeedbackSheet` (`act_hope_box_glance`).

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp (64dp FAB).
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) against `#111518` dark canvas.
- Maintain zero network calls (`FireflyHttpOverride` strictly enforced).
- Store media references and notes with AES-256-GCM encryption.
- Physical media files must reside only in app-private storage and be permanently unlinked on deletion.
- Exclude media directory from cloud backups.
- Support non-judgmental early exit and persistent SOS shield overlay.

**Never:**
- Never expose sensitive note contents or full media thumbnails on unauthenticated or high-level lists without privacy shielding.
- Never upload or sync Hope Box contents to cloud services or remote APIs.
- Never impose streaks, badges, gamification, or guilt messages when items are deleted or infrequently opened.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| First Open / Empty State | User opens Hope Box with 0 items | Renders peaceful empty state: *"This space is just for you. Add something worth holding onto."* with subtle "Add your first item" action | Safe empty list handling |
| Filter by Category | User taps filter chip (Reasons, Words, Photos, Sounds) | Smoothly filters displayed items without lag | Shows filtered empty state if none match |
| Add Reason to Keep Going | User enters reason prompted *"Something worth staying for:"* | Encrypts and saves item with `reason` type, refreshes list immediately | Disables save if text is empty |
| Add Text Note | User enters title & note content | Encrypts title and content, creates `text` item | Disables save if content is empty |
| Add Photo / Media | User selects photo path/caption | Stores reference in private vault, encrypts record, adds `photo` item | Displays gentle fallback if file cannot be read |
| Add Voice / Audio | User adds voice note or audio file reference | Encrypts metadata and file link, adds `voice` / `audio` item | Graceful fallback if audio is missing |
| Open Item Detail | User taps item in grid | Expands into full content viewer dialog with audio playback / high-res text / image | Safe back navigation |
| Delete Item | User swipes or taps delete in item viewer with confirmation | Physically unlinks file, removes from DB, zeroes memory buffers, updates list | Graceful error alert if deletion fails |
| Exit Vault | User taps "That's enough for now" or Back | Prompts post-session effectiveness sheet if visited ≥ 30s or interacted, returns cleanly | Clean disposal |

</frozen-after-approval>

## Code Map

- `lib/features/hope_box/domain/models/hope_box_item.dart` -- Domain model defining `HopeBoxItem`, `HopeBoxItemType` (`reason`, `text`, `photo`, `voice`, `audio`), and metadata.
- `lib/features/hope_box/domain/models/hope_box_state.dart` -- Immutable state model tracking item list, active category filter, search query, loading, and selection.
- `lib/features/hope_box/domain/repositories/hope_box_repository.dart` -- Repository interface for Hope Box item persistence, encryption, querying, and file disposal.
- `lib/features/hope_box/data/repositories/hope_box_repository_impl.dart` -- Concrete repository implementation with AES-256-GCM encryption, secure file management, memory zeroing, and auto-purging.
- `lib/features/hope_box/presentation/controllers/hope_box_controller.dart` -- Riverpod controller managing vault state, category filtering, item additions, deletions, and audio playback.
- `lib/features/hope_box/presentation/widgets/hope_box_item_card.dart` -- Privacy-preserving item card for grid/masonry display (icon + label, touch target ≥ 56dp).
- `lib/features/hope_box/presentation/widgets/hope_box_detail_dialog.dart` -- Warm full-screen / dialog viewer for reading reasons/notes, inspecting photos, and listening to audio clips.
- `lib/features/hope_box/presentation/widgets/add_hope_box_item_sheet.dart` -- Modal sheet for adding Reasons, Notes, Photos, Voice notes, and Audio tracks.
- `lib/features/hope_box/presentation/screens/hope_box_screen.dart` -- Main vault screen with `#111518` canvas, category filter chips, masonry grid, 64dp FAB, and persistent SOS panic overlay.
- `lib/core/routing/app_routes.dart` & `lib/core/routing/app_router.dart` -- Register `/home/hope-box` and `/hope-box` routes.
- `test/features/hope_box/verify_hope_box_standalone.dart` -- Comprehensive standalone verification suite covering encryption, all 5 item types, CRUD, memory zeroing, filtering, and edge cases.

## Tasks & Acceptance

**Execution:**
- [x] Domain models: `hope_box_item.dart`, `hope_box_state.dart`
- [x] Repository: `hope_box_repository.dart` & `hope_box_repository_impl.dart` with AES-256-GCM encryption and secure file purging
- [x] Controller: `hope_box_controller.dart` with state management, category filtering, item creation, and secure deletion
- [x] UI Widgets: `hope_box_item_card.dart`, `hope_box_detail_dialog.dart`, `add_hope_box_item_sheet.dart`
- [x] UI Screen: `hope_box_screen.dart` with dark canvas, filter chips, 64dp FAB, SOS overlay, and post-session rating
- [x] Routing: Register `AppRoutes.hopeBox` (`/home/hope-box`) and `/hope-box` modal route in `app_router.dart`
- [x] Verification: Full standalone test suite in `test/features/hope_box/verify_hope_box_standalone.dart`

**Acceptance Criteria:**
- Given `HopeBoxScreen`, all 5 item types (`reason`, `text`, `photo`, `voice`, `audio`) can be created, stored, and displayed.
- List view preserves privacy by displaying type icon and label/title rather than leaking sensitive full text or photos.
- Items are encrypted using AES-256-GCM at the application layer.
- Deletion removes the repository record and physically zeroes/unlinks associated files.
- Persistent SOS panic button remains functional and accessible.
- Non-judgmental early exit routes safely to previous screen and optionally logs effectiveness rating.
- 100% of standalone tests pass with zero network calls and full null safety.

## Implementation Notes

- Implemented 100% offline, privacy-sealed Hope Box Coping Vault (FR-07):
  - 5 Coping Item Types: Reason to keep going (`reason`), Text notes & quotes (`text`), Photo memories (`photo`), Offline voice notes (`voice`), Calming offline songs (`audio`).
  - Privacy-preserving list view using type icons and labels, preventing sensitive content from being exposed in public spaces.
  - Detail dialog with dedicated viewers: warm amber banner for Reasons to Stay, reading viewer for Notes, image viewer for Photos, audio player for Voice/Music.
  - Multi-media creator sheet (`AddHopeBoxItemSheet`) with type pills, custom prompts, category tags, and ≥ 56dp CTA button.
  - AES-256-GCM encryption at application layer, zero-plaintext storage policy, secure file unlinking with zero-byte overwrite, and memory zeroing (`cryptoEraseString`).
  - Route registration at `/home/hope-box` and `/hope-box`, with SOS panic overlay and `EffectivenessFeedbackSheet` post-session rating integration (`act_hope_box_glance`).
- Standalone verification suite in `test/features/hope_box/verify_hope_box_standalone.dart` passes 100% of assertions.
