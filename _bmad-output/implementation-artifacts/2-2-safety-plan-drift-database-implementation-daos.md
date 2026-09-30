# Story 2.2: Safety Plan Drift Database Implementation & DAOs

Status: done

## Story Description
As a developer,
I want Drift DAOs and repository implementations for persisting safety plans, warnings, steps, and contacts,
So that all safety plan data is reliably stored in the local encrypted SQLCipher database with cascade deletion.

## Acceptance Criteria
1. `SafetyPlanRepositoryImpl` implemented in `lib/features/safety_plan/data/repositories/safety_plan_repository_impl.dart`.
2. Connects to `AppDatabase` and queries `SafetyPlans`, `SafetyPlanSteps`, `SafetyPlanContacts`, `SafetyPlanWarnings` tables.
3. Automatically seeds initial default Stanley-Brown 6-step template if none exists.
4. Cascade delete: deleting a plan removes all child steps, warnings, and contacts.
5. All operations return `Ok(value)` or `Err(failure)`.
