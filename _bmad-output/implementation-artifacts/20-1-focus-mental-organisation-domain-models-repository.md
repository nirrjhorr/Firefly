# Story 20.1: Focus & Mental Organisation Domain Models, State Machine & Repository

**Epic:** Epic 20: Focus & Mental Organisation Suite — Three Priorities & Serene Focus Companion (v2 Sprint 11)  
**Status:** In-Progress  
**Owner:** Product & Engineering, Firefly  

---

## 1. Context & Cognitive Rationale

During acute distress, anxiety, burnout, ADHD paralysis, or depressive exhaustion, executive functioning and working memory rapidly deteriorate (*Arnsten 2009; Sweller 2011; Snyder 2013*). When confronted with endless to-do lists, overwhelming obligations, and noisy notifications, individuals experience choice paralysis and shame.

Firefly addresses this through a trauma-informed, low-stimulation focus architecture:
1. **Brain Dump (Unstructured Externalization):** Rapid offloading of racing tasks, anxieties, and ideas from working memory into an unjudged holding space.
2. **Three Priorities ("Rule of 3" Cognitive Throttling):** Enforcing a hard ceiling of at most 3 immediate micro-intentions. Everything else is safely parked.
3. **Serene Focus Companion (Low-Stimulation Focus Interval):** Non-punitive, unhurried focus intervals (5, 10, 15, 25 minutes) with smooth ambient animations, optional soundscape accompaniment, calm pause without shame, and zero streak tracking or productivity guilt.

---

## 2. Technical Deliverables

### Domain Layer (`lib/features/focus/domain/`)
- `FocusMode`: Enum (`threePriorities`, `focusTimer`, `brainDump`).
- `FocusPriority`: Immutable domain model representing one of the capped 3 priorities:
  - `id`: Unique identifier
  - `title`: Short task description
  - `isCompleted`: Whether marked done
  - `orderIndex`: Position (0, 1, 2)
  - `createdAt`: Timestamp
- `BrainDumpItem`: Immutable domain model for unstructured thought offloading:
  - `id`: Unique identifier
  - `rawText`: Unprocessed thought or to-do
  - `isParked`: Whether safely parked for later
  - `createdAt`: Timestamp
- `FocusSession`: Immutable domain entity for timed intervals:
  - `id`: Session ID
  - `durationMinutes`: Selected interval duration (e.g. 5, 10, 15, 25)
  - `remainingSeconds`: Countdown counter
  - `priorityId`: Optional linked priority ID
  - `ambientSoundId`: Optional background soundscape (e.g., 'gentle_rain', 'forest', 'silence')
  - `isPaused`: Pause state
  - `isCompleted`: Completion status
  - `completedAt`: Timestamp
- `FocusRepository`: Abstract interface defining contracts for managing priorities, brain dump items, and completed focus sessions.

### Data Layer (`lib/features/focus/data/`)
- `FocusRepositoryImpl`: Thread-safe, offline-first repository managing local storage with zero cloud dependencies and absolute privacy.

---

## 3. Acceptance Criteria
- [ ] `FocusPriority` enforces at most 3 active priorities with immutable value semantics.
- [ ] `BrainDumpItem` and `FocusSession` support complete JSON roundtripping and immutability.
- [ ] `FocusRepository` provides clean CRUD operations for priorities, brain dump items, and sessions.
- [ ] Zero network requests, 100% pure Dart verifiable in standalone audit suite.
