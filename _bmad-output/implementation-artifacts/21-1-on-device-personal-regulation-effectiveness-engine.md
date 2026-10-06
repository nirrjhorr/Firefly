# Story 21.1: Personal Regulation Effectiveness & Affinity Models, Mathematical Scoring Engine & Repository

Status: in-progress
Epic: 21 - On-Device Personal Regulation Effectiveness Engine & Affinity Profiles (v2 Sprint 12)
FR: RM-AA-19 / FR-16 (Personal Regulation Profiles & On-Device Affinity Engine)

## Overview
Operationalize Bandura's self-efficacy theory, EMA personalization, and Schleider & Baumel adaptive single-session intervention principles. Firefly computes on-device mathematical affinity scores for activities based on user-reported post-activity shifts (-2 to +2 EMA ratings), learning what actually settles the user's body and mind under specific emotional states with 100% on-device privacy and zero cloud footprint.

## Key Capabilities & Algorithms
1. **Bayesian/Laplace Damped Affinity Scoring**:
   - Computes weighted average shift with sample damping: `dampedScore = (sumRatings / (sampleCount + k))` where `k = 1.0`. Prevents single noisy ratings from causing extreme affinity swings.
   - Recency weighting: More recent logs receive proportional weighting.
   - Bounded score in range `[-1.0, 1.0]`.
2. **State-Matched Aggregation**:
   - Groups ratings by activity and emotional state (e.g., "anxious", "overwhelmed", "low", "scattered", "lonely").
   - Identifies top calming practices per state and across all states.
3. **Domain Models**:
   - `ActivityAffinity`: Immutable model tracking activityId, targetState, sampleCount, averageRating, affinityScore, and lastPracticed.
   - `PersonalRegulationProfile`: Aggregates top practices by state, overall calming rate, and total mindful regulation moments.
4. **Data Access & Storage**:
   - Extended `ActivitiesDao` with `getAllEffectivenessLogs()` and `clearEffectivenessLogs()`.
   - `PersonalisationRepository` interface and implementation providing query and reactive stream capabilities.

## Verification
- Pure Dart standalone test suite `test/features/personalisation/verify_personalisation_standalone.dart`.
- Full assertions for cold-start (zero logs), single log, multiple logs, negative feedback suppression, and state matching.
