# Story 4.3: Cyclic Sigh Bloom Visualizer (CustomPainter)

Status: ready-for-dev

## Story Description
As a user following a breathing session,
I want an organic, smoothly expanding bloom visualizer that guides my breath without visual noise or frame drops,
So that I can follow the pacing effortlessly with eyes open or in peripheral vision.

## Acceptance Criteria
1. `CyclicSighBloomPainter` extending `CustomPainter`:
   - Radius smoothly scales from 50dp (exhale / rest) to 120dp (peak inhale).
   - 3 concentric glow rings drawn with radial gradients or layered paths at decreasing opacities (e.g. 0.35, 0.20, 0.08).
   - Color transitions via `ColorTween` between serene sage (`#4A7862`) during inhale and dusk blue (`#3B5B6C`) during exhale.
2. Performance & Jank Prevention:
   - `shouldRepaint` accurately compares previous vs new progress and phase; returns false when identical.
   - Zero unnecessary allocations in `paint()` method.
3. Accessibility:
   - Reduced Motion: when device or user requests reduced motion (`MotionTokens.resolve()`), collapses bloom animation to a steady static calming circle.
4. Widget tests for rendering, radius bounds, and reduced motion fallback.
