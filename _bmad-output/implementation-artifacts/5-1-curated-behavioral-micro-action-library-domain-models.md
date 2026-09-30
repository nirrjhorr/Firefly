# Story 5.1: Curated Behavioral Micro-Action Library & Domain Models

Status: ready-for-dev

## Story Description
As a developer,
I want domain models and an offline library of 20+ evidence-based micro-actions,
So that low-energy users receive immediate, practical behavioral activation tasks without requiring network access.

## Acceptance Criteria
1. Domain entity `TinyStep`:
   - Properties: `id` (String), `title` (String), `description` (String), `category` (enum: `sensory`, `physical`, `environment`, `nourishment`), `minEnergyLevel` (1-5), `maxEnergyLevel` (1-5), `durationMinutes` (int, <= 2).
2. Curated offline catalog of 20+ micro-actions stored in code/constants (no network, instant read):
   - Very low energy (1-2): e.g. "Take a sip of water", "Unclench your jaw and shoulders", "Look out a window for 30 seconds", "Feel your feet against the floor".
   - Moderate energy (3): e.g. "Wash your face with cool water", "Stretch your arms overhead", "Step outside for two deep breaths".
   - Higher energy / restless (4-5): e.g. "Tidy one surface", "Put away three items", "Step onto the balcony/porch".
3. Unit tests verifying all entries have valid durations <= 2 min, non-empty fields, and adequate distribution across energy levels.
