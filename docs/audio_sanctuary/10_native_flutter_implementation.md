# Native Flutter Implementation & Architecture

**Document Reference:** FIREFLY-AUDIO-IMP-10  
**Technology Stack:** Flutter 3.x / Dart 3.x / Flutter Riverpod 2.5 / JustAudio 0.9 / GoRouter 14.0  
**Design Philosophy:** Apple Human Interface Guidelines (Fluid gestures, frosted glass elevation, typographic hierarchy)  
**Offline Integrity:** 100% Native Asset Bundling via `rootBundle`

---

## 1. Architectural Overview & Component Hierarchy

The soundscapes feature is organized following clean architecture principles within `lib/features/soundscapes/`:

```
lib/features/soundscapes/
├── domain/
│   └── models/
│       ├── soundscape_track.dart            # Domain entity with JSON serialization
│       └── soundscape_playlist.dart         # Playlist model with curated presets
├── data/
│   └── repositories/
│       └── soundscape_repository.dart       # Asset repository with JSON loader & fallback
└── presentation/
    ├── controllers/
    │   └── soundscape_player_controller.dart # StateNotifier player controller with just_audio
    ├── screens/
    │   └── soundscape_library_screen.dart   # Full Apple HIG audio library screen
    └── widgets/
        └── soundscape_evidence_sheet.dart   # Modal sheet displaying research citations
```

---

## 2. Key Code Implementations

### A. Domain Entity (`SoundscapeTrack`)
- Located at: [`lib/features/soundscapes/domain/models/soundscape_track.dart`](file:///c:/Users/mdhas/Documents/Firefly/lib/features/soundscapes/domain/models/soundscape_track.dart)
- Immutable Dart model representing an individual audio asset with technical, legal, and scientific fields.
- Implements `fromJson` and `toJson` for lossless parsing from `assets/audio/audio_catalogue.json`.

### B. Repository Layer (`SoundscapeRepository`)
- Located at: [`lib/features/soundscapes/data/repositories/soundscape_repository.dart`](file:///c:/Users/mdhas/Documents/Firefly/lib/features/soundscapes/data/repositories/soundscape_repository.dart)
- Uses `rootBundle.loadString('assets/audio/audio_catalogue.json')` to dynamically parse the bundled manifest on app launch.
- Provides fallback hardcoded records for testing resilience.
- Exposes `soundscapeRepositoryProvider` and `allSoundscapeTracksProvider`.

### C. State Management & Player Engine (`SoundscapePlayerController`)
- Located at: [`lib/features/soundscapes/presentation/controllers/soundscape_player_controller.dart`](file:///c:/Users/mdhas/Documents/Firefly/lib/features/soundscapes/presentation/controllers/soundscape_player_controller.dart)
- Powered by `just_audio`'s native audio engine.
- Features:
  - **Offline Asset Playback:** `_audioPlayer.setAsset(track.assetPath)`
  - **Looping Mode:** `_audioPlayer.setLoopMode(LoopMode.one)` for gapless continuous playback.
  - **Volume Attenuation:** Dynamic volume slider mapped to linear-to-perceptual logarithmic scaling.
  - **Sleep Countdown Timer:** Built-in 5, 10, 15, 30, and 60-minute auto-stop timers with graceful fade-out.
  - **Audio Session Focus:** Configured with `audio_session` to handle phone calls and headphone disconnect events gracefully.

### D. Apple-Inspired UI (`SoundscapeLibraryScreen`)
- Located at: [`lib/features/soundscapes/presentation/screens/soundscape_library_screen.dart`](file:///c:/Users/mdhas/Documents/Firefly/lib/features/soundscapes/presentation/screens/soundscape_library_screen.dart)
- Design details:
  - **Header & Philosophy:** "Sound Sanctuary — Offline Restorative Audio Library".
  - **Curated Playlist Carousel:** Horizontal scrolling cards with colored glass tinting and session badges.
  - **Category Filter Chips:** Animated pill-shaped selector chips for Nature, Ambient, Sleep, Focus, and Relaxation.
  - **Track Cards:** Display title, environment, duration, quality score, loop badge, and an evidence info button.
  - **Sticky Floating Player:** Glassmorphic floating playback bar at the bottom with play/pause, volume control, track title, and progress indicator.
  - **Evidence Sheet:** Tap info icon on any track to reveal a modal sheet explaining the research literature behind that sound category.

---

## 3. Router & Navigation Integration

1. Registered in `AppRoutes`:
   ```dart
   static const soundscapes = '/home/soundscapes';
   ```
2. Mapped in `AppRouter` as a primary shell route within `MainShellScaffold`.
3. Integrated into:
   - **`CheckInScreen`:** Calming quick-access card immediately beneath the check-in form.
   - **`RecommendationEngine`:** Suggested automatically as a restorative alternative for high stress or anxious affect states.
   - **`SoundscapeSelectorSheet`:** Breathing & Grounding companion picker with a direct button to explore the full library.
