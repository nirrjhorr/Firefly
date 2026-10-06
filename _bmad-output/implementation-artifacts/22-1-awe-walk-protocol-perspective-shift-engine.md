# Story 22.1: Awe Walk Protocol & Perspective Shift Engine

Status: in-progress
Epic: 22 - Awe Walk Protocol & Perspective Shift Engine (v2 Sprint 13)
FR: RM-05 (Awe Walk & Perspective Shift Protocol / Sturm et al. 2020)

## Overview
Operationalize Virginia Sturm et al. 2020 (*Emotion*, UCSF RCT) demonstrating that intentional outdoor walking focused on vastness, novelty, and the "small self" significantly diminishes negative emotional distress, interrupts ruminative circular thinking, and enhances prosocial settledness. Firefly provides a tranquil, low-stimulation walking companion with curated observational prompts, gentle pacing options (5, 10, 15 minutes), and post-session settledness feedback.

## Key Capabilities & Architecture
1. **Four-Phase Protocol State Machine**:
   - `preparation`: Setting intent, posture, gentle breath, uncluttering attention.
   - `vastness`: Shifting visual and cognitive attention to scale, sky, horizons, tree canopies, architectural geometry.
   - `smallSelf`: Experiencing the relief of humility—being a small, connected part of an immense natural world.
   - `gratitude`: Anchoring sensory wonder before concluding the walk.
   - `complete`: Session summary and optional settledness feedback.

2. **Curated Evidence-Based Prompts**:
   - *Panoramic Gaze*: Expanding peripheral vision past the immediate path or phone screen.
   - *Vastness & Patterns*: Observing natural growth rings, bark texture, cloud movement, shadows.
   - *Small Self Comfort*: Feeling the weight lift as individual concerns blend into a larger living system.
   - *Micro-Wonder*: Examining intricate miniature life (moss, leaf veins, pebbles).
   - *Acoustic Openness*: Closing or softening eyes briefly to listen for multi-layered wind, leaves, distant echoes.

3. **Domain Models**:
   - `AweWalkPhase`: Enum representing the 4 core phases plus completion.
   - `AwePrompt`: Immutable model with id, title, modality (visual, auditory, tactile, panoramic), instruction, reflection cue, and duration guidance.
   - `AweWalkSession`: Immutable domain model tracking chosen duration (5/10/15 min), elapsed seconds, completed prompts, notes, and timestamp.

4. **Repository & Storage**:
   - `AweWalkRepository` with default curated prompts and session completion logging with 100% offline persistence and zero network footprint.

## Verification
- Pure Dart standalone test suite `test/features/awe_walk/verify_awe_walk_standalone.dart`.
- Full assertions for phase transitions, prompt catalog, duration presets, session logging, and state controller.
