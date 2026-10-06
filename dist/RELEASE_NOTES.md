# Firefly v2.8.0 Release Notes

**Version:** `2.8.0+20`  
**Date:** 2026-10-07  
**Build Hash (SHA-256):** `d73785bb4b020753d4b9c29d3feaad076f70311f8f4d8f4a864b2a7830fbc6bb`  
**Architecture:** 100% Offline Mental Wellbeing Companion & 6-Group Self-Regulation System  

## Key Highlights in v2.8.0
- **Apple HIG Design Alignment & Direct Manipulation Polish:**
  - Micro-scale direct manipulation tactile feedback (0.97 scale on press, selection click haptics) across all `FireflyButton`, `FireflyCard`, and navigation triggers.
  - Generous 44dp/56dp minimum touch targets across all interactive elements, accommodating motor tremor and emotional distress.
  - Complete WCAG 2.2 AAA color contrast compliance across illuminated sage (`#7DBA9B`, 8.19:1) and primary text (`#E2E8F0`, 14.89:1) against dark slate canvas (`#111518`).
  - Fluid easing curves (`Cubic(0.16, 1.0, 0.3, 1.0)`) with full system reduced-motion support.
- **Stitch Serene Sanctuary Harmonization:**
  - Complete 76-practice activity catalog across 6 canonical regulation groups with sub-millisecond client-side search and energy filtering.
  - Dual-mode Right Now Distress modal with 12 acute anchors and regulation group browsing.
  - Integrated Personal Sanctuary profile displaying on-device effectiveness shifts with zero streak pressure or productivity guilt.
  - Full Awe Walk protocol companion (Sturm et al. 2020) with outward attention cues and perspective shifting.
- **Clinical Safety Guardrails & Zero-Network Guarantee:**
  - Deterministic on-device crisis phrase detector with non-blocking local safety banner and 1-tap support routing.
  - Stanley-Brown 6-step Safety Plan intervention with persistent floating SOS overlay button.
  - Instant pure-black OLED panic blank screen with memory zeroing (< 15ms).
  - 100% offline verification: zero remote telemetry, zero cloud tracking, AES-256-GCM double encryption.
- **Packaging & Asset Verification:**
  - Verified launcher icons across all DPI buckets (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) + Android v26 adaptive icon.
  - Complete bundled asset verification (29 offline soundscapes, Vosk acoustic model archive, Atkinson Hyperlegible and Plus Jakarta Sans fonts).

## Installation via ADB Sideload
```bash
# Sideload release package to physical test device
adb install -r dist/firefly-v2.8.0-release.apk

# Launch app directly
adb shell monkey -p app.firefly -c android.intent.category.LAUNCHER 1
```
