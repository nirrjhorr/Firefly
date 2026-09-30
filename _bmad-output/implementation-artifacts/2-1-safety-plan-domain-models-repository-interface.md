# Story 2.1: Safety Plan Domain Models & Repository Interface

Status: done

## Story Description
As a developer,
I want clear domain models and an abstract repository interface for the Stanley-Brown Safety Plan,
So that the safety architecture adheres strictly to clean architectural boundaries.

## Acceptance Criteria
1. Domain models `SafetyPlan`, `SafetyPlanWarning`, `SafetyPlanStep`, and `SafetyPlanContact` are created in `lib/features/safety_plan/domain/models/`.
2. Step types follow the Stanley-Brown clinical specification:
   - Warning Signs
   - Internal Coping Strategies
   - People & Social Settings for Distraction
   - People to Ask for Help (Support Contacts)
   - Professionals & Agencies (Professional Contacts & Crisis Lines)
   - Making the Environment Safe
3. `SafetyPlanRepository` interface is created in `lib/features/safety_plan/domain/repositories/safety_plan_repository.dart` with methods returning `Future<Result<T, Exception>>`:
   - `getPlan()`
   - `savePlan(SafetyPlan plan)`
   - `updateStep(SafetyPlanStep step)`
   - `addContact(SafetyPlanContact contact)`
   - `updateContact(SafetyPlanContact contact)`
   - `deleteContact(String contactId)`
   - `addWarning(SafetyPlanWarning warning)`
   - `deleteWarning(String warningId)`
4. Models support immutability and `copyWith`.
