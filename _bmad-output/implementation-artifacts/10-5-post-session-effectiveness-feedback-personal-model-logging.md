# Story 10.5: Post-Session Effectiveness Feedback & Personal Model Logging

Status: done
Epic: 10 - v2 State-Based Regulation Architecture & Core Suite
FR: FR-16 (Effectiveness Model & Post-Activity Feedback)

## Overview
Implemented the post-session effectiveness feedback loop for regulation activities. Uses a non-gamified 5-point discrete EMA scale (-2 to +2) with optional somatosensory reflection tags, logging directly into encrypted Drift storage via the Activities DAO.

## Discrete Rating Scale
- **-2**: Much worse (Red-accented subdued warning indicator)
- **-1**: A bit worse
- **0**: About the same
- **+1**: A bit more settled (Sage accent)
- **+2**: Much more settled (Deep Sage accent)

## Somatic Reflection Tags
- `Calmer body`
- `Quieter mind`
- `Breathing slowed`
- `Heart rate down`
- `Less overwhelmed`
- `Grounded`
- `Fell asleep`
- `Too long`
- `Distracted`

## Changes Implemented
- [x] **Domain Model**:
  - `lib/features/activities/domain/models/activity_effectiveness_log.dart`:
    - Pure Dart immutable log model with discrete rating verification assertion (`-2 <= rating <= 2`).
    - Full JSON serialization and deserialization.
- [x] **Data Access & Storage**:
  - `lib/core/database/tables/activity_effectiveness_table.dart`: Drift table with check constraints and index on activityId and timestamp.
  - `lib/core/database/daos/activities_dao.dart`: `logEffectiveness(log)` and `getEffectivenessLogsForActivity(id)` supported in both Drift and InMemory implementations.
  - `lib/features/activities/data/repositories/drift_activity_repository.dart`: Exposes `logEffectiveness`.
- [x] **UI & Integration**:
  - `lib/features/activities/presentation/widgets/effectiveness_feedback_dialog.dart`:
    - `EffectivenessFeedbackSheet`: Modal bottom sheet with rating buttons, tag wrap, save/skip actions, and 1-tap dismissibility.
  - `lib/features/breathing_grounding/presentation/screens/breathing_grounding_screen.dart`:
    - Automatically prompts for reflection upon session exit when at least one cycle was completed.
  - `lib/features/pmr/presentation/screens/pmr_screen.dart`:
    - Prompts for reflection on exit or session completion.
- [x] **Verification**:
  - `test/features/activities/verify_effectiveness_standalone.dart`: 100% assertions passed.
