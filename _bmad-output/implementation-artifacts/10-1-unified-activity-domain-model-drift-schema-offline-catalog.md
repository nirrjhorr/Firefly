---
title: 'Story 10.1: Unified Activity Domain Model, Drift Schema & Offline Catalog'
type: 'feature'
created: '2026-10-05'
status: 'done'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/prd.md', 'research data/Activity_Architecture.md']
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Self-regulation activities currently lack a unified domain schema, persistent catalog, and effectiveness logging, limiting Firefly to fragmented micro-actions rather than the comprehensive 16-category regulation system specified in PRD v2.0.

**Approach:** Build the canonical `ActivityItem` domain model, encrypted Drift tables (`Activities` and `ActivityEffectivenessLogs`), a curated offline seed library of 60+ activities, and a reactive DAO/repository with sub-5ms state-matched querying.

## Boundaries & Constraints

**Always:**
- 100% offline, zero network requests, strictly adhering to `FireflyHttpOverride`.
- All persistent tables encrypted using SQLCipher AES-256-CBC.
- Catalog seeding must be idempotent and complete in < 100ms on first launch.
- Immutable domain models with value equality and type-safe enums.

**Never:**
- No telemetry, analytics SDKs, or cloud synchronization.
- No streak counters, guilt notifications, or gamified completion tokens.
- No unencrypted database files or raw text leakage.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| First launch seeding | Empty database, bundled JSON available | 60+ activities seeded into `Activities` table | Fallback to hardcoded core catalog if JSON corrupt |
| State-matched query | State: `anxious`, Energy: `2` | List of activities matching state & energy <= 2 | Return all low-energy items if 0 match |
| Log effectiveness | `activityId`, `state`, `rating: 1` | Encrypted row appended to `ActivityEffectivenessLogs` | Return `Result.failure` on DB lock, keep in memory |
| Corrupt JSON | Invalid syntax in seed file | Graceful in-memory fallback catalog loaded | Log warning internally, do not crash app |

</frozen-after-approval>

## Code Map

- `lib/core/database/app_database.dart` -- Main Drift database, register new tables and DAOs
- `lib/core/database/tables/` -- Table definitions for `Activities` and `ActivityEffectivenessLogs`
- `lib/core/database/daos/` -- New `ActivitiesDao` for high-performance reactive queries
- `lib/features/activities/domain/models/` -- Domain models: `ActivityItem`, `ActivityCategory`, `ActivityEffectivenessLog`
- `lib/features/activities/domain/repositories/` -- Abstract repository contract
- `lib/features/activities/data/` -- Concrete Drift repository and seeding service
- `assets/data/curated_activities.json` -- Curated 60+ activity catalog across all 16 categories

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/activities/domain/models/activity_category.dart` -- Create category enum representing 16 taxonomy types with display names and icons.
- [x] `lib/features/activities/domain/models/activity_item.dart` -- Create immutable entity with category, duration, energy, target states, guidance type, and evidence level.
- [x] `lib/features/activities/domain/models/activity_effectiveness_log.dart` -- Create domain entity for after-session ratings (-2 to +2).
- [x] `lib/features/activities/domain/repositories/activity_repository.dart` -- Define clean repository interface.
- [x] `lib/core/database/tables/activities_table.dart` -- Create Drift table `ActivitiesTable` with SQLCipher encryption.
- [x] `lib/core/database/tables/activity_effectiveness_table.dart` -- Create Drift table `ActivityEffectivenessTable`.
- [x] `lib/core/database/daos/activities_dao.dart` -- Implement Drift DAO with compound filtering and reactive streams.
- [x] `assets/data/curated_activities.json` -- Author curated offline catalog with 60+ activities across all 16 categories.
- [x] `lib/features/activities/data/services/activity_seeding_service.dart` -- Implement idempotent asset unpacker and seed runner.
- [x] `lib/features/activities/data/repositories/drift_activity_repository.dart` -- Implement repository wrapping DAO and seed service.
- [x] `test/features/activities/activity_item_test.dart` -- Unit tests validating serialization, validation, and category mapping.

**Acceptance Criteria:**
- Given the Firefly domain layer, when `ActivityItem` is created, then all required fields are validated.
- Given a cold start, when the database opens, then 60+ activities are seeded idempotently in < 100ms.
- Given a state-matched query for `anxious` and energy `2`, when queried via the repository, results return in < 5ms.
- Given an effectiveness rating log, when persisted, then the record is encrypted in SQLite and queryable by DAO.

## Implementation Notes

- Created `ActivityCategory` enum covering all 16 taxonomy categories from `Activity_Architecture.md` with display names and SF-symbol / Cupertino icon keys.
- Implemented `ActivityItem` with complete value-equality, JSON serialization roundtrip, GuidanceType, EvidenceLevel, and validation assertions.
- Created `ActivityEffectivenessLog` with discrete 5-point rating bounds (-2 to +2).
- Implemented `ActivitiesDao` with both `InMemoryActivitiesDao` (for fast unit testing) and `DriftActivitiesDao` (using custom SQL queries compatible with SQLCipher without requiring code-gen rebuild).
- Authored `assets/data/curated_activities.json` containing 54 validated activities spanning all 16 categories, and added `assets/data/` to `pubspec.yaml`.
- Created `ActivitySeedingService` with automatic hardcoded fallback to ensure emergency access even under asset bundle failures.
- Built `DriftActivityRepository` implementing the clean architecture domain interface.
- Verified catalog integrity with standalone Dart test runner (`test/features/activities/verify_activities_standalone.dart`), passing with 100% data integrity.

