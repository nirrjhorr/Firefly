# Story 3.2: Check-In Domain Models & Drift Database Implementation

Status: done

## Story Description
As a developer,
I want domain models and a Drift DAO repository for mood check-in entries,
So that check-in history is safely stored and aggregated in the encrypted database.

## Acceptance Criteria
1. `CheckInEntry` domain entity defined in `lib/features/check_in/domain/models/check_in_entry.dart`.
2. `CheckInRepository` interface defined in `lib/features/check_in/domain/repositories/check_in_repository.dart`.
3. `CheckInRepositoryImpl` implemented in `lib/features/check_in/data/repositories/check_in_repository_impl.dart`.
4. Saves check-in entry with mood, energy, anxiety, loneliness, and serialized suggestion to `MoodCheckIns` table.
5. Queries latest check-in entry and check-in history for progress aggregation.
