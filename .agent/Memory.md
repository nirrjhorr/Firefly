# Memory.md
# Firefly — Agent Working Memory & Decision Log

**Version:** 1.0.0 | **Type:** Living Document — Updated After Every Session | **Created:** 2026-09-30

> This is the agent's working memory. It is updated at the end of every session and read at the start of every session. It is the single source of truth for current state, next steps, and all architectural decisions made to date.

---

## 1. Current Phase & Sprint Goal

| Field | Value |
|---|---|
| **Current Phase** | Phase 0 — Workspace Scaffolding |
| **Sprint Goal** | `flutter create` the project, install dependencies, configure linting, security baseline |
| **Phase Status** | ⬜ Not Started |
| **Blocked?** | No |

---

## 2. Active Task & File Under Edit

| Field | Value |
|---|---|
| **Active Task** | None — awaiting Phase 0 execution |
| **File Under Active Edit** | None |
| **Last File Completed** | `.agent/Memory.md` (this file) |

---

## 3. Completed Units Checklist

### Pre-Development (Research & Documentation) ✅

- ✅ Clinical evidence research — Product_Research_Scope.md
- ✅ Primary paper verification — Research_Findings_Part1.md
- ✅ Digital interventions, harms, engagement research — Research_Findings_Part2.md
- ✅ Evidence table & feature priority tiers — Research_Findings_Part3.md
- ✅ Frontend architecture specification — FRONTEND_ARCHITECTURE.md
- ✅ Local backend architecture specification — LOCAL_BACKEND_ARCHITECTURE.md
- ✅ Security & privacy specification — SECURITY_AND_PRIVACY.md
- ✅ Design system & tokens specification — DESIGN_SYSTEM_AND_TOKENS.md
- ✅ `.agent/Architecture.md` compass document
- ✅ `.agent/Rules.md` compass document
- ✅ `.agent/Phases.md` compass document
- ✅ `.agent/Design.md` compass document
- ✅ `.agent/Memory.md` compass document (this file)

### Phase 0 — Workspace Scaffolding ⬜

- ⬜ Flutter project created
- ⬜ Dependencies installed
- ⬜ Linting configured
- ⬜ Security baseline files created
- ⬜ Asset directory structure created
- ⬜ First commit pushed

### Phase 1 — Security Engine ⬜

*(Awaiting Phase 0)*

### Phase 2 — Design System ⬜

*(Awaiting Phase 1)*

### Phase 3 — Safety Plan ⬜

*(Awaiting Phase 2)*

### Phase 4 — Check-In & Recommendation Engine ⬜

*(Awaiting Phase 3)*

### Phase 5 — Respiration Engine ⬜

*(Awaiting Phase 4)*

### Phase 6 — Tiny Steps, Journaling, Hope Box ⬜

*(Awaiting Phase 5)*

### Phase 7 — Accessibility, SAST & Release ⬜

*(Awaiting Phase 6)*

---

## 4. Next Immediate Steps (Numbered, Ordered)

1. **Run `flutter create`** with package name `app.firefly` targeting iOS and Android
2. **Install all approved packages** from `Rules.md §1` into `pubspec.yaml`
3. **Configure `analysis_options.yaml`** with strict linting rules
4. **Create directory scaffolding**: `core/`, `features/`, `shared/`, `assets/`
5. **Copy bundled fonts** to `assets/fonts/` and register in `pubspec.yaml`
6. **Copy bundled audio** (ambient sounds) to `assets/audio/` and register
7. **Create `.semgrep/firefly_security.yaml`** security rules
8. **Create `scripts/security_gate.sh`** deny-list CI script
9. **Configure Android**: `allowBackup=false`, `usesCleartextTraffic=false`, `network_security_config.xml`
10. **Configure iOS**: ATS blocking in `Info.plist`
11. **Create `core/errors/result.dart`** — sealed `Result<T, E>` type
12. **Replace `main.dart`** with `ProviderScope` shell + `HttpOverrides.global`
13. **First `git commit`**: `"feat: Phase 0 — workspace scaffolding and security baseline"`
14. **Run `flutter analyze`** — confirm zero warnings
15. **Mark Phase 0 complete** and begin Phase 1

---

## 5. Architectural Decisions Log

All significant architectural decisions are logged here with rationale. Never change an established decision without adding a new entry explaining the override.

---

### ADR-001: Riverpod over BLoC
**Date:** 2026-09-30
**Decision:** Use Riverpod with `@riverpod` codegen and `AsyncNotifier` as the state management solution.
**Rationale:** `ref.onDispose()` contract guarantees teardown of timers, audio players, and haptic controllers when a user navigates away mid-session. BLoC requires manual `close()` which introduces leak risk in audio/haptic lifecycle. Compile-time safety via code generation eliminates runtime provider-not-found crashes.
**Alternatives Considered:** BLoC (rejected — boilerplate, manual teardown risk), Provider (rejected — lacks compile-time safety).

---

### ADR-002: Drift + SQLCipher over Isar
**Date:** 2026-09-30
**Decision:** Use `drift` with `sqlcipher_flutter_libs` for local data storage.
**Rationale:** The Safety Plan feature requires hierarchical relational data (Plans → Steps → Contacts) with CASCADE delete enforcement. Isar's document model cannot enforce referential integrity at the schema level. SQLCipher provides transparent AES-256-CBC encryption — no application-level plaintext handling. WAL mode ensures crash safety on battery exhaustion.
**Alternatives Considered:** Isar (rejected — no FK enforcement), Hive (rejected — no ACID, no encryption, declining maintenance).

---

### ADR-003: Deterministic Rule Engine over On-Device LLM
**Date:** 2026-09-30
**Decision:** The recommendation engine is a pure Dart deterministic state machine. No LLM in v1.0.
**Rationale:** LLM outputs are non-deterministic — an unguided LLM response in a crisis-adjacent context carries an unacceptable risk of harmful content. A pure Dart engine gives sub-millisecond response, zero app size cost, and 100% predictable output. Any future on-device LLM must be: (a) opt-in, (b) sandboxed to journaling prompts only, (c) filtered by crisis-keyword blocklist.
**Alternatives Considered:** MediaPipe Gemma 2B (rejected for v1.0 — 1.5GB model, non-deterministic, requires crisis filtering), Cloud LLM (banned — network dependency).

---

### ADR-004: Cyclic Sighing as Default Breathing Pattern
**Date:** 2026-09-30
**Decision:** The default breathing technique is cyclic sighing (double inhale + prolonged exhale, 4s/8s).
**Rationale:** Balban et al. 2023 (Cell Reports Medicine) demonstrated cyclic sighing produced greater mood improvement and larger reduction in respiratory rate than box breathing, cyclic hyperventilation, and mindfulness over 1 month of daily 5-min practice. The prolonged exhale activates the parasympathetic nervous system faster than equal inhale/exhale patterns.
**Alternatives Considered:** Box breathing (4-4-4-4) — included as alternative mode, not default.

---

### ADR-005: Atkinson Hyperlegible as Primary Typeface
**Date:** 2026-09-30
**Decision:** Use Atkinson Hyperlegible for all body text, headings, and labels.
**Rationale:** Designed by the Braille Institute for maximum legibility in low-vision and low-light environments. Character disambiguation (0/O, 1/l/I) is critical for users reading journaling prompts or safety plan contacts under distress at low screen brightness. Plus Jakarta Sans is used for display-level text only (single words like "Breathe").
**Alternatives Considered:** Inter (rejected — adequate but not optimised for low-vision), Roboto (rejected — clinical feel).

---

### ADR-006: Moon Phase Mood Selector over Numeric Scale
**Date:** 2026-09-30
**Decision:** Mood check-in uses 5 named states (Heavy → Low → Here → Light → Open) represented by moon phase icons, not a numeric 1–10 scale.
**Rationale:** Numeric scales (PHQ-9 style 0–3 or 1–10) are associated with clinical/diagnostic contexts. Research shows reductive numeric framing can increase self-monitoring anxiety. Named emotional anchors with visual metaphors reduce cognitive load and feel less pathologizing. Moon phases are culturally accessible, gender-neutral, and non-threatening.
**Alternatives Considered:** Emoji faces (rejected — ambiguous, culturally variable), Numeric slider (rejected — clinical, gameable), Colour gradient (rejected — accessibility failure on colour-blind profiles).

---

### ADR-007: Safety Plan Shipped Before Any Other Feature
**Date:** 2026-09-30
**Decision:** Phase 3 (Safety Plan) is implemented before Phase 4 (Check-In) despite the check-in being the app's entry point.
**Rationale:** The Safety Plan is the single non-negotiable safety infrastructure. If a user in distress opens the app and the Safety Plan is not functional, the app fails at its most critical moment. Feature sequencing must prioritise safety over feature completeness. The SOS overlay is persistent from Phase 3 onwards — even before check-in is built.
**Alternatives Considered:** Ship check-in first (rejected — safety cannot be a later phase).

---

### ADR-008: Cryptographic Erasure for Journal TTL
**Date:** 2026-09-30
**Decision:** Expired journal entries are erased via HKDF subkey rotation (key versioning), not standard SQL DELETE.
**Rationale:** Standard SQL DELETE on SQLite does not overwrite NAND sectors — bytes remain recoverable via chip-off forensic extraction until sector reuse. Key rotation makes all existing ciphertext permanently unreadable regardless of storage medium state. VACUUM is additionally called to reclaim freed pages, and `PRAGMA secure_delete = ON` overwrites pages with zeros at the SQLCipher layer.
**Alternatives Considered:** Standard `DELETE` + VACUUM (insufficient — bytes remain on NAND until sector reuse), Row overwrite + DELETE (partial — does not address NAND wear-leveling).

---

### ADR-009: FLAG_SECURE + iOS Blur Overlay
**Date:** 2026-09-30
**Decision:** Android `FLAG_SECURE` is set globally (not per-screen) in `MainActivity.onCreate()`. iOS uses a `UIVisualEffectView` blur overlay injected in `applicationWillResignActive`.
**Rationale:** Mental health content captured in app-switcher thumbnails could be seen by cohabitants or domestic partners — one of the highest-severity threat scenarios. `FLAG_SECURE` blocks screenshots, screen recording, accessibility services, and OS thumbnails on Android. iOS does not support `FLAG_SECURE` equivalently — the blur overlay must be applied before iOS takes the switcher snapshot (in `willResignActive`, not `didEnterBackground`).
**Alternatives Considered:** Per-screen `FLAG_SECURE` (rejected — complex, easy to miss on new screens), No protection (rejected — unacceptable for sensitive content).

---

## 6. Known Blockers & Open Questions

| ID | Blocker / Question | Status | Owner |
|---|---|---|---|
| B-001 | Vosk offline STT model size (~50MB) needs to be included in app bundle or offered as a first-launch download | Open | Engineering |
| B-002 | `sqlcipher_flutter_libs` desktop (macOS/Windows) compatibility needs verification before any desktop build | Open | Engineering |
| B-003 | App Store mental health category requires specific crisis line disclosure — confirm which countries' crisis numbers to pre-populate | Open | Product |
| B-004 | Hope Box photo storage: confirm whether to use app-private directory (most secure) or user-accessible photo library | Open | Product + Engineering |
| Q-001 | Should the OLED deep-black canvas (`#0E1211`) be the default or an opt-in "Night Mode"? | Open | Design |
| Q-002 | Vosk model language selection: ship English only in v1.0, or offer multi-language download? | Open | Product |

---

## 7. File Registry

| File | Path | Status | Phase |
|---|---|---|---|
| `Architecture.md` | `.agent/Architecture.md` | ✅ Complete | Pre-Dev |
| `Rules.md` | `.agent/Rules.md` | ✅ Complete | Pre-Dev |
| `Phases.md` | `.agent/Phases.md` | ✅ Complete | Pre-Dev |
| `Design.md` | `.agent/Design.md` | ✅ Complete | Pre-Dev |
| `Memory.md` | `.agent/Memory.md` | ✅ Complete | Pre-Dev |
| `Product_Research_Scope.md` | `research data/` | ✅ Complete | Pre-Dev |
| `Research_Findings_Part1.md` | `research data/` | ✅ Complete | Pre-Dev |
| `Research_Findings_Part2.md` | `research data/` | ✅ Complete | Pre-Dev |
| `Research_Findings_Part3.md` | `research data/` | ✅ Complete | Pre-Dev |
| `FRONTEND_ARCHITECTURE.md` | `research data/` | ✅ Complete | Pre-Dev |
| `LOCAL_BACKEND_ARCHITECTURE.md` | `research data/` | ✅ Complete | Pre-Dev |
| `SECURITY_AND_PRIVACY.md` | `research data/` | ✅ Complete | Pre-Dev |
| `DESIGN_SYSTEM_AND_TOKENS.md` | `research data/` | ✅ Complete | Pre-Dev |
| `pubspec.yaml` | `/` | ⬜ Not Created | Phase 0 |
| `analysis_options.yaml` | `/` | ⬜ Not Created | Phase 0 |
| `main.dart` | `lib/` | ⬜ Not Created | Phase 0 |
| `app_database.dart` | `lib/core/database/` | ⬜ Not Created | Phase 1 |
| `key_manager.dart` | `lib/core/security/` | ⬜ Not Created | Phase 1 |
| `biometric_guard.dart` | `lib/core/security/` | ⬜ Not Created | Phase 1 |
| `app_router.dart` | `lib/core/routing/` | ⬜ Not Created | Phase 1 |
| `app_colors.dart` | `lib/core/theme/` | ⬜ Not Created | Phase 2 |
| `app_typography.dart` | `lib/core/theme/` | ⬜ Not Created | Phase 2 |
| `app_theme.dart` | `lib/core/theme/` | ⬜ Not Created | Phase 2 |
| `firefly_button.dart` | `lib/shared/widgets/` | ⬜ Not Created | Phase 2 |
| `safety_plan_screen.dart` | `lib/features/safety_plan/` | ⬜ Not Created | Phase 3 |
| `recommendation_engine.dart` | `lib/core/recommendation_engine/` | ⬜ Not Created | Phase 4 |
| `check_in_screen.dart` | `lib/features/check_in/` | ⬜ Not Created | Phase 4 |
| `breathing_session_controller.dart` | `lib/features/breathing_grounding/` | ⬜ Not Created | Phase 5 |
| `journal_entry_screen.dart` | `lib/features/journaling/` | ⬜ Not Created | Phase 6 |

---

## 8. Session Log

| Date | Session Summary | Phase Moved |
|---|---|---|
| 2026-09-30 | Git initialized, branch renamed to `main`. All research documentation created (8 docs, research data folder). Five architecture specs written (frontend, backend, security, design system, tech stack). Five compass documents written (.agent/). All files committed. | Pre-Dev → Ready for Phase 0 |

---

*This file MUST be updated at the end of every development session. Read it first at the start of every session.*
