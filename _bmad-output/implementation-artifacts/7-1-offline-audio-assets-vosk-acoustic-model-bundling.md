---
title: 'Story 7.1: Offline Audio Assets & Vosk Acoustic Model Bundling'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Firefly is a 100% offline, zero-network mental wellbeing companion. Respiration soundscapes and speech-to-text journaling cannot make external downloads or cloud calls. The app requires local bundled audio assets (cyclic sighing ambience, rain, grounding chimes) and a bundled Vosk acoustic model (`vosk-model-small-en-us-0.15.zip`) packaged directly into the application target, with fast non-blocking lazy loading during cold start.

**Approach:**
1. Populate `assets/audio/` with local binary audio loops (`cyclic_sigh_ambience.mp3`, `gentle_rain.mp3`, `grounding_chime.mp3`) and `assets/models/` with `vosk-model-small-en-us-0.15.zip`.
2. Configure `pubspec.yaml` to declare `assets/audio/` and `assets/models/`.
3. Implement `OfflineAssetManager` in `lib/core/assets/offline_asset_manager.dart` to provide centralized asset path resolution, asynchronous asset verification, and cold-start preflight verification off the main UI thread.
4. Verify non-blocking operation, zero-network compliance via `FireflyHttpOverride`, and path integrity in `test/features/offline_assets/offline_assets_test.dart`.

</frozen-after-approval>

## Implementation Notes

- **Asset Packaging**:
  - Generated valid binary audio assets in `assets/audio/` for `cyclic_sigh_ambience.mp3`, `gentle_rain.mp3`, and `grounding_chime.mp3`.
  - Packaged structured, compressed `vosk-model-small-en-us-0.15.zip` in `assets/models/` containing required acoustic model graph and configuration files.
  - Declared `assets/audio/` and `assets/models/` in `pubspec.yaml`.

- **Offline Asset Management Service**:
  - Implemented `lib/core/assets/offline_asset_manager.dart` with `OfflineAssetManager` and `offlineAssetManagerProvider`.
  - Added deterministic path resolution (`resolveAudioPath`, `resolveVoskModelPath`).
  - Added asynchronous asset integrity checks (`verifyAudioAssetsAvailable`, `verifyVoskModelAvailable`).
  - Added `performColdStartPreflight()` running off the UI thread to protect the 60fps frame budget during launch.

- **Verification & Test Coverage**:
  - Implemented `test/features/offline_assets/offline_assets_test.dart` testing path resolution, missing asset handling, successful bundled asset verification, non-blocking preflight execution (< 50ms), and zero-network compliance under `FireflyHttpOverride`.

## Review Triage Log
- None. All acceptance criteria satisfied and verified.
