# Story 19.1: Self-Compassion & Thought Untangler Domain Models & Repository

**Epic:** Epic 19: Self-Compassion & Thought Untangler Module (v2 Sprint 10)  
**Status:** In-Progress  
**Owner:** Product & Engineering, Firefly  

---

## 1. Context & Clinical Rationale

Self-compassion (*Neff 2003, 2023; Kirby et al. 2017*) is one of the strongest protective factors against depressive rumination, harsh self-blame, and emotional overwhelm. Neff's empirical model identifies three core interacting components:
1. **Mindfulness vs. Over-Identification:** Noticing emotional pain without exaggerating or suppressing it.
2. **Common Humanity vs. Isolation:** Recognizing that suffering, flaws, and difficulty are shared human experiences rather than isolated failures.
3. **Self-Kindness vs. Self-Judgment:** Offering warmth, soothing touch, and understanding to oneself rather than harsh criticism.

In parallel, Cognitive Untangling (*Hayes et al. ACT defusion; Beck CBT cognitive restructuring*) enables users to separate objective facts from harsh mental narratives.

This story implements the core domain models, state machine, repository interfaces, and in-memory/persistent repository implementations for the Self-Compassion Break and Thought Untangler.

---

## 2. Technical Deliverables

### Domain Layer (`lib/features/compassion/domain/`)
- `SelfCompassionComponent`: Enum for the 3 Neff pillars (`mindfulness`, `commonHumanity`, `selfKindness`).
- `CompassionExerciseType`: Enum for exercise modalities (`selfCompassionBreak`, `thoughtUntangler`, `lovingKindnessPhrases`).
- `UntangledThought`: Immutable domain model representing a structured untangled cognitive sequence:
  - `id`: Unique identifier
  - `distressContext`: What triggered the distress / what went wrong
  - `harshCriticVoice`: What the internal critic is saying
  - `commonHumanityValidation`: Perspective that countless other humans feel this way
  - `kindFriendReframe`: Words of compassion one would offer to a beloved friend
  - `timestamp`: Creation instant
- `CompassionSession`: Immutable domain entity recording the completed practice:
  - `id`: Session ID
  - `exerciseType`: Practice type
  - `preDistressRating`: Rating 1–5 before practice
  - `postDistressRating`: Rating 1–5 after practice
  - `completedAt`: DateTime
  - `untangledThought`: Optional associated untangled thought
- `CompassionRepository`: Abstract interface defining contracts for storing, querying, and deleting compassion sessions and untangled thoughts.

### Data Layer (`lib/features/compassion/data/`)
- `CompassionRepositoryImpl`: Thread-safe, offline-first repository managing compassion sessions and untangled thoughts with zero cloud leakage and encrypted storage compatibility.

---

## 3. Acceptance Criteria
- [ ] `SelfCompassionComponent` contains all 3 Neff pillars with descriptive prompts and clinical references.
- [ ] `UntangledThought` and `CompassionSession` are fully immutable with copyWith, equality, and JSON serialization.
- [ ] `CompassionRepository` provides `saveSession`, `getRecentSessions`, `saveUntangledThought`, `getUntangledThoughts`, and `deleteThought`.
- [ ] Pure Dart standalone tests verify model serialization, repository operations, and state machine integrity with 0 failures.
