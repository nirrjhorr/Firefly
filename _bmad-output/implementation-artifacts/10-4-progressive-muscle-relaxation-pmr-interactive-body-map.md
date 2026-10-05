# Story 10.4: Progressive Muscle Relaxation (PMR) Interactive Body Map

Status: done
Epic: 10 - v2 State-Based Regulation Architecture & Core Suite
FR: FR-12 (PMR Interactive Body Map)

## Overview
Implemented an interactive Progressive Muscle Relaxation (PMR) somatic module featuring a low-stimulation anatomical body silhouette, automated and manual muscle zone traversal across 10 anatomical regions, a 4-phase clinical timing sequence (Tense 5s -> Hold 3s -> Release 10s -> Notice 5s), tactile haptics, and a 5-zone quick de-escalation sequence.

## Anatomical Muscle Zones
1. **Forehead & Brow**: Eyebrow raise/furrow (Y: 0.12)
2. **Eyes & Face**: Gentle nose/eye scrunch (Y: 0.16)
3. **Jaw & Mouth**: Gentle dental clench, tongue press (Y: 0.20)
4. **Neck & Shoulders**: High shoulder shrug (Y: 0.26)
5. **Hands & Forearms**: Dual fist clench (Y: 0.45)
6. **Chest & Upper Body**: Deep inhalation hold (Y: 0.35)
7. **Abdomen & Core**: Core muscle contraction (Y: 0.47)
8. **Upper & Lower Back**: Shoulder blade retraction (Y: 0.40)
9. **Thighs & Hips**: Glute and quadricep tension (Y: 0.62)
10. **Calves & Feet**: Toe curl, calf plantarflexion (Y: 0.85)

## 4-Phase Protocol
- **Tense (5s)**: Isometric contraction highlighted by warm amber glow (`#E5A93C`).
- **Hold (3s)**: Sustained tension without strain, deeper amber tone (`#D4973B`).
- **Release (10s)**: Sudden release accompanied by soothing Sage green (`#7DBA9B`).
- **Notice (5s)**: Passive somatosensory awareness of lingering warmth and heaviness (`#5B8A99`).

## Changes Implemented
- [x] **Domain Models**:
  - `lib/features/pmr/domain/models/pmr_zone.dart`:
    - `PmrMuscleZone`: 10 muscle groups with instructions and silhouette coordinates.
    - `PmrPhase`: 4 clinical phases with explicit duration in seconds/ms and labels.
    - `PmrSessionState`: Immutable session state tracking current zone, phase, progress, and quick mode.
- [x] **Controller**:
  - `lib/features/pmr/presentation/controllers/pmr_controller.dart`:
    - Reactive `PmrController` with ticker, play/pause, next/previous zone, direct jump, restart, and 5-zone quick mode toggle.
    - Haptics integration with phase-specific tactile cues.
- [x] **Visualizer**:
  - `lib/features/pmr/presentation/widgets/pmr_body_silhouette.dart`:
    - Vector anatomical human silhouette CustomPainter with animated glowing oval highlights for active zones.
- [x] **UI**:
  - `lib/features/pmr/presentation/screens/pmr_screen.dart`:
    - Low-stimulation dark canvas screen, phase pill, clinical guidance card, progress bar, audio/haptic controls, completion screen, and SOS overlay button.
- [x] **Verification**:
  - `test/features/pmr/verify_pmr_standalone.dart`: 100% assertions passed.
