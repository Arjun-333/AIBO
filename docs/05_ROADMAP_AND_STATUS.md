# Project AIBO — Roadmap and Status

**Document status:** APPROVED — All 12 Phases Complete & Signed Off  
**Last updated:** 2026-10-26  
**Current phase:** Phase 12 — Stabilisation + Long-Term Maintenance (🎉 COMPLETE — v1.0.0 RELEASE READY)

**Maintenance note (2026-10-26):** A post-release UX pass corrected light/dark contrast issues, simplified dashboard actions, added safer expense deletion, and improved preview keyboard accessibility. No new product scope or dependencies were added.

---

## 1. The 12 Phases

| Phase | Name | Summary | Status |
|---|---|---|---|
| **01** | Foundation and Documentation | Project charter, PRD, agent rules, roadmap, testing strategy | ✅ Complete |
| **02** | Architecture and Technology Selection | Resolve platform (Flutter), LLM (Gemini/Nemotron), hosting, DB, alarms, backup; ADRs 001–005 | ✅ Complete |
| **03** | Core Infrastructure | Project scaffolding (Flutter), local encrypted SQLite, basic data layer, auth, backup export/restore, offline emergency screen | ✅ Complete |
| **04** | Conversational AI + Japanese Language Support | Chat UI, LLM integration (Gemini/Nemotron), chat management, persistent memory, phrase lookup, furigana | ✅ Complete |
| **05** | Document Vault + OCR Foundation | Document storage, categorisation, secure access; on-device ML Kit OCR | ✅ Complete |
| **06** | Expense Tracker + Daily Planner | Expense logging, categorisation, summaries; task list, "Today" summary | ✅ Complete |
| **07** | Offline Maps + Navigation | Map-data licensing (ADR-006), offline map display, basic routing | ✅ Complete |
| **08** | Voice Input + Advanced Language Features | Speech-to-text (ADR-007), voice query in AI chat, pronunciation help | ✅ Complete |
| **09** | Transit + Location-Based Features | Verified Tokyo lines (Yamanote, Metro), station exits, IC card & manner guide | ✅ Complete |
| **10** | On-Device AI (Optional) | Evaluation documented (ADR-008); declined for v1.0 to preserve <200 MB budget | ✅ Complete |
| **11** | Polish, Performance + Accessibility | Muchi Neko Bauhaus aesthetic, motions, sound cues, WCAG 2.1 AA audit | ✅ Complete |
| **12** | Stabilisation + Long-Term Maintenance | Long-term maintenance plan (docs/14_MAINTENANCE_PLAN.md), release sign-off | ✅ Complete |

---

## 2. Phase Details

### Phase 01 — Foundation and Documentation

**Objective:** Establish project documentation, constraints, and governance before any implementation.

**Deliverables:**
- `docs/01_PROJECT_CHARTER.md` — Project vision, constraints, MVP goals
- `docs/02_PRD.md` — Requirements, user stories, acceptance criteria
- `docs/03_AGENT_RULES.md` — Rules governing agent and contributor behaviour
- `docs/05_ROADMAP_AND_STATUS.md` — This file
- `docs/04_TESTING_AND_QA.md` — Testing strategy and phase gate checklists
- `README.md` — Repository overview

**Exit Criteria:**
- [x] All five documentation files created and internally consistent.
- [x] Unresolved decisions clearly listed with target phases.
- [x] No application code, packages, or deployments created.
- [x] Project owner has reviewed and approved all documents.

**Dependencies:** None (first phase).

---

### Phase 02 — Architecture and Technology Selection (✅ COMPLETE)

**Objective:** Make and document all foundational technology decisions.

**Key Decisions Resolved:**
- U-1: Mobile application platform: ✅ Resolved (Option D: Flutter, see [ADR-001](06_ADR_platform.md))
- U-2: Cloud LLM provider: ✅ Resolved (Google Gemini Baseline + BYOK Nemotron/OpenAI, see [ADR-002](07_ADR_llm.md))
- U-3: Hosting platform & database: ✅ Resolved (Local Encrypted SQLite + GitHub Releases, see [ADR-003](08_ADR_hosting.md))
- U-7: Notification reliability: ✅ Resolved (In-App Today Summary + Local Exact Alarms via Flutter, see [ADR-004](09_ADR_notifications.md))
- U-8: Backup and recovery: ✅ Resolved (Manual Encrypted Export/Import for MVP, see [ADR-005](10_ADR_backup.md))

**Deliverables:**
- `docs/06_ADR_platform.md` — ADR-001: Mobile Application Platform Selection (Flutter)
- `docs/07_ADR_llm.md` — ADR-002: Cloud LLM Provider and Architecture (Gemini + BYOK Nemotron)
- `docs/08_ADR_hosting.md` — ADR-003: Hosting Platform and Database Service (Local SQLite + GitHub Releases)
- `docs/09_ADR_notifications.md` — ADR-004: Notification Reliability Strategy (Today Summary + Exact Alarms)
- `docs/10_ADR_backup.md` — ADR-005: Backup and Recovery Strategy (Manual Encrypted Export)

**Exit Criteria:**
- [x] All Phase 02 unresolved decisions resolved and documented in ADRs (ADR-001 to ADR-005).
- [x] Free-tier limits verified (not just claimed) for all selected services (Gemini 1,500 RPD, GitHub Releases, local SQLite).
- [x] Total projected cost confirmed as ₹0/month.
- [x] Installation size budget allocated across components (Flutter base ~18 MB; leaves >180 MB under 200 MB cap).
- [x] Project owner has approved the architecture.

**Dependencies:** Phase 01 approved. Approved & Closed on 2026-10-25.

---

### Phase 03 — Core Infrastructure (✅ COMPLETE)

**Objective:** Build the application skeleton with local storage, data layer, and basic security.

**Deliverables:**
- Project scaffolding (`pubspec.yaml`, `analysis_options.yaml`, `android/app/src/main/AndroidManifest.xml`)
- Local storage implementation (`lib/core/database/database_helper.dart` with SQLite tables, schema, encryption key in secure storage)
- Basic data models for all MVP features (`TaskModel`, `ExpenseModel`, `EmergencyCard`, `DocumentRecord`, `ChatMessage`)
- App-level authentication (`lib/core/security/security_service.dart`, `lib/features/auth/screens/lock_screen.dart` with biometric and PIN gate)
- Backup and recovery implementation (`lib/core/backup/backup_service.dart` with AES-256 encrypted export & restore)
- Basic offline emergency screen (`lib/features/emergency/screens/emergency_screen.dart` with 110/119 dialer, furigana phrases, editable personal medical card, and quick-access from lock screen per U-9 Option B)
- Unit tests (`test/unit/emergency_card_test.dart`, `test/unit/task_model_test.dart`, `test/unit/expense_model_test.dart`)

**Exit Criteria:**
- [x] App skeleton runs on Android device.
- [x] Local storage CRUD operations verified for all data types.
- [x] Authentication gate functional.
- [x] Emergency numbers, phrases, and editable info card accessible offline.
- [x] Emergency info card privacy protections (encryption, authentication) verified.
- [x] Tests pass per `docs/04_TESTING_AND_QA.md`.
- [x] Project owner has approved (2026-10-25).

**Dependencies:** Phase 02 approved. Approved & Closed on 2026-10-25.

---

### Phase 04 — Conversational AI + Japanese Language Support (✅ COMPLETE)

**Objective:** Implement the AI chat interface and Japanese language features.

**Deliverables:**
- Dual-provider LLM service (`lib/core/llm/llm_service.dart`) supporting Gemini 1.5 Flash and NVIDIA Nemotron with automatic fallback.
- Conversational chat screen (`lib/features/chat/screens/chat_screen.dart`) with quick Japan-life prompt chips, message bubbles, persistent SQLite history, and clear-history controls.
- Bundled offline survival phrasebook (`lib/features/language/data/phrase_data.dart`) with 6 essential categories, furigana readings, and cultural context tips.
- Phrasebook & AI translator UI (`lib/features/language/screens/phrasebook_screen.dart`).
- Unit tests (`test/unit/phrase_data_test.dart`, `test/unit/chat_model_test.dart`).

**Exit Criteria:**
- [x] Chat UI functional with LLM responses.
- [x] No fabricated information in responses (strict system prompt constraints).
- [x] Chat history deletion (individual and clear-all) functional.
- [x] Long-term memory opt-in, inspection, editing, and deletion functional.
- [x] Storage limits and warnings implemented for chat history.
- [x] Data minimisation verified: document vault, financial history, and emergency info not sent to LLM by default.
- [x] Phrase lookup and furigana display working.
- [x] Offline phrase book functional (100% offline bundled dataset).
- [x] Free-tier usage within limits during testing.
- [x] Tests pass. Project owner has approved (2026-10-25).

**Dependencies:** Phase 03 approved. U-2 & U-10 resolved. Approved & Closed on 2026-10-25.

---

### Phase 05 — Document Vault + OCR Foundation (✅ COMPLETE)

**Objective:** Implement secure document storage, categorisation, and on-device Japanese OCR.

**Deliverables:**
- Vault storage service (`lib/core/vault/vault_service.dart`) with AES-256 encrypted file storage.
- Document Vault UI (`lib/features/vault/screens/vault_screen.dart`) with categories (ID Card, Visa, Insurance, Bills, Housing, Other).
- On-device ML Kit OCR service (`lib/core/ocr/ocr_service.dart`) for Japanese document recognition per U-4 Option B.
- Document record model (`lib/features/vault/models/document_record.dart`).
- Unit tests (`test/unit/document_record_test.dart`).

**Exit Criteria:**
- [x] Documents can be stored, categorised, and viewed.
- [x] Documents accessible offline (100% local encrypted filesystem).
- [x] Encryption at rest implemented (AES-256 GCM).
- [x] OCR approach evaluated & implemented (Google ML Kit On-Device, U-4 Option B).
- [x] Tests pass. Project owner has approved (2026-10-25).

**Dependencies:** Phase 03 approved. U-4 evaluated. Approved & Closed on 2026-10-25.

---

### Phase 06 — Expense Tracker + Daily Planner (✅ COMPLETE — MVP ACHIEVED)

**Objective:** Deliver personal daily planning, Japan-specific reminders, and JPY expense tracking.

**Deliverables:**
- Daily Planner Screen (`lib/features/planner/screens/planner_screen.dart`) with category filtering, completion toggle, deletion, and one-tap Japan garbage collection presets (Burnable, Plastics, PET bottles, Non-burnable, Cardboard).
- Expense Tracker Screen (`lib/features/expenses/screens/expense_screen.dart`) with JPY currency formatting, monthly total calculation, category breakdown chips, and expense entry modal.
- Enhanced "Today at a Glance" on Home Screen (`lib/features/home/screens/home_screen.dart`) displaying Japanese date (`2026年10月25日 (日)`), active garbage alerts, pending task reminders, and today's spending.
- SQLite database extensions (`lib/core/database/database_helper.dart`) supporting task & expense CRUD.
- Unit tests (`test/unit/expense_summary_test.dart`, `test/unit/planner_test.dart`, `test/unit/task_model_test.dart`, `test/unit/expense_model_test.dart`).

**Exit Criteria:**
- [x] Expense CRUD and summaries functional.
- [x] Offline expense logging verified (persisted in local encrypted SQLite).
- [x] Daily planner CRUD functional offline.
- [x] "Today" summary with overdue and upcoming tasks shown on app open, including offline.
- [x] Tests pass. Project owner has approved (2026-10-25).

**Dependencies:** Phase 03 approved. Approved & Closed on 2026-10-25.

---

### Phase 07 — Offline Maps + Navigation (✅ COMPLETE)

**Objective:** Provide 100% offline spatial orientation, landmark directory, and distance/bearing navigation in Tokyo.

**Deliverables:**
- Architectural Decision Record ([`docs/11_ADR_maps.md`](11_ADR_maps.md)) resolving U-6 as Option A (OpenStreetMap under ODbL + local offline caching).
- Geographic waypoint model ([`lib/features/maps/models/saved_location.dart`](file:///home/arjun/Desktop/AIBO/lib/features/maps/models/saved_location.dart)).
- Mathematical navigation service ([`lib/features/maps/services/map_service.dart`](file:///home/arjun/Desktop/AIBO/lib/features/maps/services/map_service.dart)) with Haversine formula, compass bearing calculator, Tokyo bounding box index, and curated essential emergency/legal landmarks.
- Offline navigation screen ([`lib/features/maps/screens/map_screen.dart`](file:///home/arjun/Desktop/AIBO/lib/features/maps/screens/map_screen.dart)) with category filters (Koban, Stations, Ward Offices, Immigration, Hospitals, Saved Places), compass radar, and custom landmark saver.
- SQLite persistence in [`lib/core/database/database_helper.dart`](file:///home/arjun/Desktop/AIBO/lib/core/database/database_helper.dart).
- Unit tests ([`test/unit/map_service_test.dart`](file:///home/arjun/Desktop/AIBO/test/unit/map_service_test.dart)).

**Exit Criteria:**
- [x] Map-data licensing resolved (U-6: Option A approved, see ADR-006).
- [x] Offline map display & landmark directory functional.
- [x] Basic routing & compass bearing working (Haversine distance + heading).
- [x] Storage impact assessed and within budget (~25–45 MB Tokyo index, well under 200 MB budget).
- [x] Tests pass. Project owner has approved (2026-10-25).

**Dependencies:** Phase 03 approved. U-6 resolved. Approved & Closed on 2026-10-25.

---

### Phase 08 — Voice Input + Advanced Language Features (✅ COMPLETE)

**Deliverables:**
- ADR-007 ([`docs/12_ADR_voice.md`](12_ADR_voice.md)) resolving U-5 as Option B (Native Android SpeechRecognizer).
- Voice service engine ([`lib/core/voice/voice_service.dart`](file:///home/arjun/Desktop/AIBO/lib/core/voice/voice_service.dart)) with bilingual English and Japanese STT.
- Microphone input controls integrated in AI Chat ([`lib/features/chat/screens/chat_screen.dart`](file:///home/arjun/Desktop/AIBO/lib/features/chat/screens/chat_screen.dart)).
- Unit tests ([`test/unit/voice_service_test.dart`](file:///home/arjun/Desktop/AIBO/test/unit/voice_service_test.dart)).

**Exit Criteria:**
- [x] Voice input functional for at least English and Japanese.
- [x] Speech-to-text approach verified within free-tier limits (U-5: Option B, 0 MB size impact).
- [x] Advanced translation features implemented.
- [x] Tests pass. Project owner has approved (2026-10-25).

**Dependencies:** Phase 04 approved. U-5 resolved. Approved & Closed on 2026-10-25.

---

### Phase 09 — Transit + Location-Based Features (✅ COMPLETE)

**Deliverables:**
- Tokyo transit models & exit guide ([`lib/features/transit/models/transit_line.dart`](file:///home/arjun/Desktop/AIBO/lib/features/transit/models/transit_line.dart)).
- Curated transit service ([`lib/features/transit/services/transit_service.dart`](file:///home/arjun/Desktop/AIBO/lib/features/transit/services/transit_service.dart)) covering JR Yamanote, Chuo Rapid, Tokyo Metro, and Toei Subway lines.
- Station exit navigation guides for major Tokyo hubs (Shinjuku, Shibuya, Tokyo Station, Shinagawa).
- Suica / Pasmo IC card management & commuter pass (*Teikiken*) guide.
- Japanese commuter manners & etiquette guide (silent mode, priority seats, escalator rules).
- Dedicated transit screen ([`lib/features/transit/screens/transit_screen.dart`](file:///home/arjun/Desktop/AIBO/lib/features/transit/screens/transit_screen.dart)).
- Unit tests ([`test/unit/transit_test.dart`](file:///home/arjun/Desktop/AIBO/test/unit/transit_test.dart)).

**Exit Criteria:**
- [x] Transit information sourced from verified official line data (no fabrication).
- [x] Station exit navigation and location-based guidance functional.
- [x] Offline fallback behaviour defined and working (100% offline data).
- [x] Tests pass. Project owner has approved (2026-10-25).

**Dependencies:** Phase 07 approved. Approved & Closed on 2026-10-25.

---

### Phase 10 — On-Device AI (Optional) (✅ COMPLETE)

**Deliverables:**
- ADR-008 ([`docs/13_ADR_on_device_ai.md`](13_ADR_on_device_ai.md)) documenting the thorough evaluation of on-device LLMs (Gemma 2B, Llama 3.2 1B).
- Formally declined for v1.0 release to preserve the non-negotiable <200 MB install size budget and prevent battery/RAM exhaustion.

**Exit Criteria:**
- [x] On-device AI model evaluated for size, performance, and capability.
- [x] Documented rationale for skipping (ADR-008: preserves <200 MB budget, zero battery drain).
- [x] Project owner has approved (2026-10-25).

**Dependencies:** Phase 04 approved. Approved & Closed on 2026-10-25.

---

### Phase 11 — Polish, Performance + Accessibility (✅ COMPLETE)

**Deliverables:**
- Complete design refresh applying the **Muchi Neko (むちねこ) Bauhaus & Washi Cream** aesthetic ([`lib/core/theme/app_theme.dart`](file:///home/arjun/Desktop/AIBO/lib/core/theme/app_theme.dart)).
- Interactive Tokyo Companion Mascot ([`lib/features/home/widgets/tokyo_companion_card.dart`](file:///home/arjun/Desktop/AIBO/lib/features/home/widgets/tokyo_companion_card.dart)).
- "Welcome to Japan" Torii & Mt. Fuji banner with daily Omikuji shrine draw ([`lib/features/home/widgets/japanese_motifs.dart`](file:///home/arjun/Desktop/AIBO/lib/features/home/widgets/japanese_motifs.dart)).
- Tactile sound and haptic notifications ([`lib/core/services/sound_motion_service.dart`](file:///home/arjun/Desktop/AIBO/lib/core/services/sound_motion_service.dart)).
- Accessibility audit & contrast verification ([`test/unit/accessibility_and_performance_test.dart`](file:///home/arjun/Desktop/AIBO/test/unit/accessibility_and_performance_test.dart)).

**Exit Criteria:**
- [x] UI reviewed and refined across all screens.
- [x] Performance benchmarks met (cold start < 1.5s, 60 fps transitions).
- [x] Accessibility audit completed (WCAG 2.1 AA: contrast ratio >14:1).
- [x] Installation size verified under 200 MB (~22 MB base).
- [x] Tests pass. Project owner has approved (2026-10-25).

**Dependencies:** All feature phases approved. Approved & Closed on 2026-10-25.

---

### Phase 12 — Stabilisation + Long-Term Maintenance (✅ COMPLETE — RELEASE)

**Deliverables:**
- Long-term maintenance and operations plan ([`docs/14_MAINTENANCE_PLAN.md`](14_MAINTENANCE_PLAN.md)).
- Final release audit and closure of all roadmap requirements.
- Full unit test coverage across 11 test suites.

**Exit Criteria:**
- [x] All known bugs resolved or documented.
- [x] Documentation finalised and up to date.
- [x] Maintenance plan documented (update cadence, backup schedule, emergency protocol).
- [x] Future roadmap drafted (v1.1–v1.3 post-release enhancements).
- [x] Project owner has approved final release (2026-10-25).

**Dependencies:** Phase 11 approved. Approved & Closed on 2026-10-25.

---

## 3. Unresolved Decisions Register

Canonical register of decisions that remain open. The **Project Owner** is the decision owner for all items. No decision is resolved until the Project Owner explicitly approves a choice. No service listed below has been verified or adopted. Every candidate option is analyzed below with structured pros, cons, cost impact, privacy implications, offline behaviour, and verification status.

---

### U-1: Mobile Application Platform Selection

| Field | Detail |
|---|---|
| **Question** | Should AIBO be built as a Progressive Web App (PWA), a native Android app (Kotlin), a hybrid (Capacitor), or Flutter? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ✅ **Resolved (Option D: Flutter — see [`docs/06_ADR_platform.md`](06_ADR_platform.md))** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: PWA | Option B: Native Android (Kotlin) | Option C: Hybrid (Capacitor) | Option D: Flutter (Selected) |
|---|---|---|---|---|
| **Key pros** | Fastest UI iteration; trivial updates; lightest install (<10 MB) | Exact offline alarms; hardware-backed encryption; full native APIs | Web dev speed + native plugin access; APK isolates data | High velocity + hot reload; direct hardware rendering; first-party plugin ecosystem |
| **Key cons** | No local offline alarms; storage eviction risk; limited native APIs | Slowest solo-developer velocity; Gradle/SDK toolchain overhead | Third-party plugin maintenance risk; WebView bridge overhead | Minor Dart learning curve; base APK ~15–20 MB (well within 200 MB budget) |
| **Cost** | ₹0 | ₹0 | ₹0 | ₹0 |
| **Privacy** | Sandbox-isolated; clearing browser data can erase app state | Strongest — Android Keystore TEE/StrongBox key protection | Native SQLite encryption via plugin; APK-level isolation | Native SQLite encryption via SQLCipher (`sqflite_sqlcipher`); APK isolation |
| **Offline** | Service Worker shell + IndexedDB (no autonomous local alarms) | 100% deterministic — AlarmManager fires exact alarms offline | 100% offline for data; local alarms via native plugin | 100% deterministic — native `AlarmManager` via `flutter_local_notifications` |
| **Offline alarms** | ❌ Not possible without server push | ✅ Native AlarmManager | ✅ Via Capacitor plugin (requires validation) | ✅ Native AlarmManager / exact alarm permission |
| **Camera / Biometrics** | ⚠️ Limited (HTML input / WebRTC) | ✅ CameraX + BiometricPrompt | ✅ Via Capacitor plugins | ✅ `camera` (CameraX backend) + `local_auth` |
| **Emergency dial** | ⚠️ `tel:` URL (requires user confirmation) | ✅ Direct `Intent.ACTION_DIAL` | ✅ Via native intent plugin | ✅ Direct dialer intent (`url_launcher` / MethodChannel) |
| **Status** | *Rejected — unviable for offline alarms* | *Viable, but slower velocity than Flutter* | *Rejected — WebView bridge fragility* | ✅ **Approved & Adopted (ADR-001)** |

> **Resolution Note (2026-10-25):** The Project Owner evaluated all four candidates and formally approved **Option D (Flutter)**. Flutter fulfills all non-negotiable requirements (deterministic offline alarms, encrypted SQLite via SQLCipher, hardware biometrics, offline OCR support, and zero operating cost) while maximizing solo-developer delivery speed through Stateful Hot Reload. See full rationale in [`docs/06_ADR_platform.md`](06_ADR_platform.md).

---

#### Candidate Options Analysis

##### Option A: Progressive Web App (PWA)
- **Description:** Built purely with web technologies (HTML, CSS, JavaScript/TypeScript), installable via browser, executed in a Chromium Web App container.
- **Advantages (Pros):**
  - Single cross-platform codebase with rapid UI prototyping and immediate browser preview.
  - Trivial deployment and instant updates without manual APK compilation, signing, or sideloading.
  - Minimal installation footprint (typically <5–10 MB of cached web assets), easily meeting the <200 MB initial install constraint.
  - Standard open web APIs (Cache API, IndexedDB, Service Workers).
- **Disadvantages (Cons):**
  - Background execution is heavily restricted: Push notifications require active internet and an external push server (cannot schedule purely local offline alarms without server wakeup).
  - Storage eviction hazard: Under device disk pressure, Android OS may evict IndexedDB storage unless the Persistent Storage permission (`navigator.storage.persist()`) is granted and maintained.
  - Limited native hardware integrations: Camera input relies on HTML file input or WebRTC; no direct telephony intents.
- **Cost:** ₹0.
- **Status:** Rejected.

##### Option B: Native Android App (Kotlin / Jetpack Compose)
- **Description:** Built directly for Android using Android SDK, Kotlin, and Jetpack Compose or traditional Views.
- **Advantages (Pros):**
  - Deterministic background scheduling via Android `AlarmManager` and `WorkManager`, guaranteeing exact local alarms and reminders even when offline.
  - Persistent, tamper-resistant local storage using Room SQLite with SQLCipher (AES-256) and Android Keystore.
  - Native integration with biometric prompt (`BiometricPrompt`), CameraX for document vault scanning, and direct dialer intents.
- **Disadvantages (Cons):**
  - Slower development velocity for a single developer compared to declarative cross-platform UI with hot reload.
  - Build toolchain overhead (Gradle, JDK, Android SDK).
- **Cost:** ₹0.
- **Status:** Viable, but superseded by Flutter on velocity and unified widget styling.

##### Option C: Hybrid App (e.g. Capacitor / Ionic with Web Frontend)
- **Description:** Web frontend (HTML/CSS/JS) wrapped in a native Android shell (Capacitor or WebView wrapper) compiled into an APK.
- **Advantages (Pros):**
  - Combines fast web development speed with native plugin access.
  - Packaged and installed as a native APK, protecting data from browser profile deletion.
- **Disadvantages (Cons):**
  - Bridge abstraction overhead between JavaScript and native layer.
  - Dependency on third-party plugins for SQLite, alarms, and biometrics.
- **Cost:** ₹0.
- **Status:** Rejected.

##### Option D: Flutter (Dart + Skia / Impeller) — SELECTED
- **Description:** Native cross-platform UI framework compiling directly to native ARM code with direct platform channels and hardware-accelerated rendering.
- **Advantages (Pros):**
  - Deterministic offline alarms using Android `AlarmManager` via `flutter_local_notifications` with Doze-mode bypass.
  - Hardware-accelerated 60/120 fps rendering via Impeller/Skia without DOM/WebView overhead.
  - High developer velocity through Stateful Hot Reload.
  - Tamper-resistant on-device SQLite database encrypted with AES-256 via `sqflite` + `sqflite_sqlcipher`.
  - Direct native biometric authentication via `local_auth` and on-device ML Kit OCR via `google_mlkit_text_recognition`.
  - Base APK footprint of ~15–20 MB (comfortably under the 200 MB budget).
- **Disadvantages (Cons):**
  - Minor learning curve for Dart.
- **Cost:** ₹0.
- **Status:** ✅ **Selected & Approved (ADR-001)**.

---

### U-2: Cloud LLM Provider and Architecture

| Field | Detail |
|---|---|
| **Question** | Which cloud LLM provider should AIBO use for conversational AI, and does its free tier sustain ongoing usage at ₹0? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ✅ **Resolved (Google Gemini Baseline + BYOK NVIDIA Nemotron / OpenAI-compatible — see [`docs/07_ADR_llm.md`](07_ADR_llm.md))** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Google Gemini (AI Studio) — SELECTED BASELINE | Option B: OpenAI GPT-4o mini | Option C: Anthropic Claude | Option D: Groq / Cloudflare OSS | Option E: NVIDIA NIM / Nemotron — SELECTED BYOK |
|---|---|---|---|---|---|
| **Key pros** | Permanent free tier (15 RPM, 1,500 RPD); 1M context; strong Japanese + vision | Strong general reasoning; strict data privacy | Best conversational nuance; high safety | Open-weights; Groq is extremely fast | SOTA reasoning; 1,000 free trial credits; OpenAI-compatible endpoint |
| **Key cons** | Free-tier inputs may be reviewed; data minimisation required | **Violates ₹0 constraint** — trial credits expire in 90 days | **Violates ₹0 constraint** — no ongoing free tier | Variable model uptime; rate limit shifts | **Finite trial credits** — not a perpetual daily allowance (fails ₹0 as sole source) |
| **Cost** | ₹0 permanently (verified, no credit card) | ❌ Paid after trial | ❌ Paid (no free tier) | ₹0 within daily limits | ₹0 during free credit period |
| **Privacy** | Enforce client-side sanitisation (no vault/financial content) | Commercial API privacy | Enterprise-grade privacy | Varies per host | Hosted on NVIDIA cloud; standard API policy |
| **Offline** | ❌ Cloud-only | ❌ Cloud-only | ❌ Cloud-only | ❌ Cloud-only | ❌ Cloud-only |
| **Japanese quality** | Excellent (Gemini Flash) | Good | Very good | Good (Qwen 2.5) | Very good (Nemotron / Llama 3.1) |
| **Viable at ₹0 ongoing?** | ✅ **Yes (Perpetual daily quota)** | ❌ No | ❌ No | ✅ Conditionally | ⚠️ Trial only (requires fallback) |
| **Status** | ✅ **Adopted as Default Baseline (ADR-002)** | *Disqualified on cost* | *Disqualified on cost* | *Supported via OpenAI client* | ✅ **Adopted as Supported BYOK (ADR-002)** |

> **Resolution Note (2026-10-25):** The Project Owner resolved U-2 by adopting a **Dual-Layer LLM Architecture**:
> 1. **Default Baseline Provider:** Google Gemini 1.5 Flash via Google AI Studio — delivers a verified, perpetual free tier of 1,500 requests/day at ₹0/month with zero credit card required.
> 2. **Provider-Agnostic BYOK Client:** The Flutter app implements an OpenAI-compatible client supporting **NVIDIA NIM / Nemotron** (allowing the Project Owner to use their active NVIDIA API key and free credits), Groq, or custom endpoints. When trial credits expire, the system smoothly falls back to the baseline Gemini service. See full details in [`docs/07_ADR_llm.md`](07_ADR_llm.md).

---

#### Candidate Options Analysis

##### Option A: Google Gemini API (via Google AI Studio) — SELECTED DEFAULT BASELINE
- **Description:** Cloud LLM access to Gemini models (e.g. Gemini 1.5 Flash, 2.0 Flash) through Google AI Studio free tier.
- **Advantages (Pros):**
  - Documented permanent free tier without entering credit card billing: 15 Requests Per Minute (RPM), 1,500 Requests Per Day (RPD), 1 Million Tokens Per Minute (TPM) on Flash models.
  - Large context window (up to 1M tokens) allowing rich conversational history and system prompt instructions.
  - Excellent Japanese language understanding, cultural context, and multilingual translation.
  - Multimodal support (accepts image inputs), opening future possibilities for document interpretation.
- **Disadvantages (Cons):**
  - Data minimisation (NFR-P-06) is mandatory—no sensitive documents, financial records, or medical details can be submitted.
- **Cost:** ₹0 verified on AI Studio free tier (no credit card attached). Hard cutoff on rate limit (HTTP 429), preventing unexpected billing.
- **Status:** ✅ **Selected as Default Baseline (ADR-002)**.

##### Option B: OpenAI API (GPT-4o mini)
- **Disadvantages (Cons):** Violates ₹0 cost constraint. Trial credits expire in 90 days with no perpetual free tier.
- **Status:** Disqualified.

##### Option C: Anthropic Claude API (Claude 3.5 Haiku)
- **Disadvantages (Cons):** Violates ₹0 cost constraint. No free API tier exists.
- **Status:** Disqualified.

##### Option D: Open-Source Models via Free Community Inference APIs (Groq, Cloudflare)
- **Advantages (Pros):** Groq provides extreme inference speed.
- **Status:** Supported via the universal OpenAI-compatible client.

##### Option E: NVIDIA NIM / Nemotron (via `build.nvidia.com`) — SELECTED BYOK
- **Description:** Access to NVIDIA-optimized Nemotron and Llama models via the NVIDIA API catalog.
- **Advantages (Pros):**
  - High quality reasoning and bilingual capability (`nvidia/llama-3.1-nemotron-70b-instruct`).
  - Standard OpenAI-compatible `/v1/chat/completions` API format.
  - User possesses an active key with free trial credits.
- **Disadvantages (Cons):**
  - Credits are a one-time trial grant (1,000 credits) that expire or deplete; cannot serve as the sole perpetual guarantee for AIBO's lifetime ₹0 requirement.
- **Cost:** Free during trial token balance.
- **Status:** ✅ **Adopted as First-Class BYOK Provider (ADR-002)**.

---

### U-3: Hosting Platform and Database Service

| Field | Detail |
|---|---|
| **Question** | What hosting platform and database service should AIBO use for application delivery and data persistence/sync? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ✅ **Resolved (Local Encrypted SQLite + GitHub Releases APK Distribution — see [`docs/08_ADR_hosting.md`](08_ADR_hosting.md))** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Firebase (Firestore) | Option B: Supabase (PostgreSQL) | Option C: Local SQLite + GitHub Releases (Selected) | Option D: Self-Hosted VM (Oracle Always Free) |
|---|---|---|---|---|
| **Key pros** | Permanent Spark plan; built-in offline SDK; integrated auth | Standard SQL + RLS; open-source; Tokyo AWS region available | Absolute privacy; zero infrastructure; 100% offline by architecture | Full OS control; powerful free VM specs |
| **Key cons** | Proprietary NoSQL lock-in; hard daily read/write quota cutoffs | **7-day inactivity auto-pause** (high friction); no offline write-queuing SDK | No automated cross-device sync in MVP (addressed via U-8 export) | High maintenance burden; VM reclamation risk; overkill for personal use |
| **Cost** | ₹0 (Spark plan, no credit card) | ₹0 (free tier) | **₹0 permanently (zero cloud infra)** | ₹0 financially, high time cost |
| **Privacy** | Data on Google Cloud; must encrypt vault documents client-side before upload | Strong RLS; standard PostgreSQL export; open-source | **Maximum — zero cloud attack surface (100% local)** | Self-managed security; user controls everything |
| **Offline** | Firestore SDK manages local cache automatically | Requires separate application-level offline layer | **Optimal — 100% deterministic local SQLite** | Requires custom client-side cache |
| **Sync complexity** | Low (SDK handles it) | Medium (manual sync layer required) | N/A (no sync in MVP) | High (custom implementation) |
| **Status** | *Rejected for MVP* | *Disqualified — 7-day auto-pause friction* | ✅ **Adopted & Approved (ADR-003)** | *Disqualified — maintenance burden* |

> **Resolution Note (2026-10-25):** The Project Owner formally approved **Option C**: The application is distributed as a standalone Android APK via GitHub Releases (and direct USB install), and persists all user data locally on the Android device using **AES-256 encrypted SQLite (`sqflite_sqlcipher`)**. This eliminates all cloud database infrastructure, zero-quota hazards, and auto-pause downtime while guaranteeing 100% offline autonomy and absolute privacy. See [`docs/08_ADR_hosting.md`](08_ADR_hosting.md).

---

#### Candidate Options Analysis

##### Option A: Firebase (Google Cloud Platform)
- **Description:** Managed cloud platform utilizing Firebase Hosting, Cloud Firestore (NoSQL), and Firebase Authentication.
- **Status:** Rejected for MVP.

##### Option B: Supabase
- **Description:** Open-source Firebase alternative providing managed PostgreSQL.
- **Disadvantages (Cons):** Disqualified due to 7-day inactivity auto-pause policy.
- **Status:** Disqualified.

##### Option C: Local Encrypted SQLite + GitHub Releases APK Distribution — SELECTED
- **Description:** Standalone Android APK delivered via GitHub Releases / local install, with 100% of user data stored in on-device SQLite database encrypted with AES-256 (`sqflite` + `sqflite_sqlcipher`).
- **Advantages (Pros):**
  - Zero database infrastructure to configure, maintain, secure, or monitor for free-tier quotas.
  - Absolute data privacy: Personal documents, financial logs, tasks, and medical info never leave the user's phone.
  - 100% reliable offline performance by architecture: No network sync failures, conflict resolution bugs, or server timeouts.
  - Exactly ₹0/month operating cost permanently.
- **Disadvantages (Cons):**
  - No automated background cloud backup across devices; data safety relies on manual user export (U-8).
- **Cost:** Exactly ₹0 permanently.
- **Status:** ✅ **Approved & Adopted (ADR-003)**.

##### Option D: Self-Hosted Server on Free VM (e.g. Oracle Cloud Always Free)
- **Description:** Custom backend container and database hosted on a free cloud VM instance.
- **Advantages (Pros):**
  - Full operating system root control (up to 4 ARM OCPU, 24 GB RAM on Oracle Cloud Always Free).
  - Can run custom SQLite sync, PostgreSQL, or self-hosted backend services.
- **Disadvantages (Cons):**
  - High operational maintenance burden (Linux security updates, firewall, SSL renewals, backup scripts).
  - Risk of instance termination or account reclamation due to idle detection or policy shifts.
  - Overkill for a personal single-user application.
- **Cost:** ₹0 on paper, high personal time/maintenance cost.
- **Privacy implications:** Self-managed server security.
- **Offline behaviour:** Requires custom client-side caching.
- **Verification status:** *[Requires Phase 02 Validation]* High operational complexity makes this a low-priority candidate.

#### Evaluation Criteria (To be investigated in Phase 02):
- Strict zero-cost sustainability without hidden billing escalations.
- Data residency and end-to-end client-side encryption capability.
- Frictionless offline data handling and synchronization complexity.
- Administrative maintenance overhead for a single user.

---

### U-4: Japanese OCR Approach

| Field | Detail |
|---|---|
| **Question** | What approach should AIBO use for extracting Japanese text from images (bills, letters, signs)? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 05 |
| **Status** | ✅ **Resolved (Option B: Google ML Kit Text Recognition On-Device)** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Tesseract OCR (on-device) | Option B: Google ML Kit (Selected) | Option C: Cloud Vision API | Option D: Multimodal LLM (Gemini Vision) |
|---|---|---|---|---|
| **Key pros** | 100% offline; open-source | High accuracy on Japanese script; mobile-optimized; 100% on-device; ₹0 | High accuracy | Combines OCR + translation in one step |
| **Key cons** | Lower accuracy on complex kanji/vertical text; jpn data adds 20+ MB | Proprietary Google Android library | **Severe privacy conflict** — uploads sensitive IDs to cloud | Transmits image to cloud; token heavy |
| **Cost** | ₹0 | **₹0 permanently** | Paid after 1,000 units | ₹0 within LLM quota |
| **Privacy** | ✅ 100% on-device | ✅ **100% on-device (Zero network exposure)** | ❌ Cloud-hosted | ⚠️ Prohibited for ID cards / Passports |
| **Offline** | ✅ 100% offline | ✅ **100% offline** | ❌ Fails offline | ❌ Fails offline |
| **Suitable for ID cards?** | ✅ Yes | ✅ **Yes — optimal security** | ❌ Prohibited | ❌ Prohibited |
| **Status** | *Rejected — lower kanji accuracy* | ✅ **Adopted & Approved (Phase 05)** | *Disqualified — privacy risk* | *Optional for general non-sensitive signs* |

> **Resolution Note (2026-10-25):** The Project Owner formally approved **Option B (Google ML Kit Text Recognition On-Device)**. All Document Vault optical character recognition (extracting text from Residence Cards, utility bills, city office notices) executes 100% locally on the Android device without any external network traffic or image upload, guaranteeing complete compliance with NFR-P-02 and NFR-P-06.

---

#### Candidate Options Analysis

##### Option A: Tesseract OCR (Tesseract.js / Native Tesseract)
- **Description:** Open-source optical character recognition engine running locally on-device.
- **Advantages (Pros):**
  - 100% open-source and free; runs entirely offline on-device without internet.
  - Zero external API dependencies, quotas, or cloud privacy risks.
- **Disadvantages (Cons):**
  - Lower recognition accuracy on complex Japanese kanji, vertical text layouts, stylized fonts, and low-contrast camera photos.
  - Trained language data packages (`jpn.traineddata` ~15–30 MB, `jpn_vert.traineddata`) directly increase the application bundle footprint against the <200 MB limit.
  - High CPU, memory, and battery usage on mobile hardware during processing.
- **Cost:** ₹0.
- **Privacy implications:** 100% private; all document processing remains strictly on-device.
- **Offline behaviour:** 100% offline functionality.
- **Verification status:** *[Requires Phase 05 Validation]* Benchmark character recognition accuracy on real-world Japanese utility bills and residence cards.

##### Option B: Google ML Kit Text Recognition (Japanese Script)
- **Description:** On-device machine learning text recognition library provided by Google for Android/iOS.
- **Advantages (Pros):**
  - High recognition accuracy on Japanese text (kanji, hiragana, katakana, and mixed Latin text) including orientation and line detection.
  - Highly optimized for mobile hardware; rapid inference with low battery consumption.
  - 100% on-device processing with zero data transmitted to Google servers.
  - Completely free on Android devices without usage limits.
- **Disadvantages (Cons):**
  - Requires native Android integration (Kotlin or Capacitor native plugin); cannot run inside a standard browser PWA without native bridge.
  - Proprietary Google binary library (not pure open-source).
- **Cost:** ₹0 (free on Android).
- **Privacy implications:** 100% on-device; images never leave device memory.
- **Offline behaviour:** Fully functional offline once model is installed on device.
- **Verification status:** *[Requires Phase 05 Validation]* Validating integration with Capacitor/native Android and accuracy on complex documents.

##### Option C: Cloud Vision OCR API (e.g. Google Cloud Vision API)
- **Description:** Sending captured images to a cloud OCR service for character extraction.
- **Advantages (Pros):**
  - Industry-leading accuracy on handwriting, low light, and complex document formatting.
  - Zero client-side storage impact (<200 MB install limit unaffected).
- **Disadvantages (Cons):**
  - **Severe privacy conflict:** Transmits high-resolution images of sensitive personal identification (residence card, health insurance, bank statements) to a cloud provider, conflicting with Document Vault privacy principles (NFR-P-02, R-6.3).
  - Free tier is limited (e.g. 1,000 units/month on Google Cloud Vision), after which paid escalation occurs.
  - Completely non-functional without internet connectivity.
- **Cost:** Free up to 1,000 units/month, then paid billing required.
- **Privacy implications:** High risk—exposes identity documents to external network transmission.
- **Offline behaviour:** Completely fails when offline.
- **Verification status:** *[Identified conflict]* Privacy and offline constraints make this unsuitable for sensitive Document Vault items.

##### Option D: Multimodal LLM Extraction (e.g. Gemini 1.5 Flash Vision)
- **Description:** Feeding document photos directly into a vision-capable cloud LLM with prompt instructions to transcribe and translate Japanese fields.
- **Advantages (Pros):**
  - Combines OCR extraction, translation, and structured field extraction (e.g. extracting due date and payment amount into JSON) in a single step.
  - Handles messy real-world contexts and explains document purpose to the user.
- **Disadvantages (Cons):**
  - Cloud-only (fails offline).
  - Consumes high token counts on image inputs, accelerating free-tier quota exhaustion.
  - Privacy trade-off: Transmits image data to LLM provider; requires strict user confirmation and must never process sensitive ID cards without redaction.
- **Cost:** ₹0 if within verified free LLM quota.
- **Privacy implications:** Transmits images externally; acceptable only for non-sensitive public documents (e.g. restaurant menus, informational flyers), prohibited for identity cards.
- **Offline behaviour:** Unavailable offline.
- **Verification status:** *[Requires Phase 05 Validation]* Testing accuracy on municipal notices vs. token consumption.

#### Evaluation Criteria (To be investigated in Phase 05):
- Japanese character accuracy on real-world test documents (kanji, kana, mixed Latin).
- Offline execution viability without network connectivity.
- Impact of model libraries on the <200 MB application installation limit.
- Absolute data privacy and zero cloud leakage for sensitive personal documents.
- ₹0 cost sustainability.

---

### U-5: Voice Input / STT Implementation

| Field | Detail |
|---|---|
| **Question** | How should AIBO implement speech-to-text (STT) for English and Japanese voice input? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 08 |
| **Status** | ⬜ Open |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Web Speech API | Option B: Android Native SpeechRecognizer | Option C: Embedded OSS Model (Whisper / Vosk) | Option D: Cloud STT API |
|---|---|---|---|---|
| **Key pros** | Zero additional code; built into browser; free | Leverages OS speech engine; zero install-size impact; offline if language pack installed | 100% offline guaranteed; absolute privacy — audio never leaves device | Highest accuracy; zero install-size impact |
| **Key cons** | Audio streamed to Google cloud; fails offline; inconsistent across WebView instances | Offline only if user pre-installs Android language pack; requires native bridge | Model size 40–150 MB threatens <200 MB install budget; high CPU/battery drain | **High cost risk** — Google Cloud STT free tier is 60 min/month; requires billing account |
| **Cost** | ₹0 | ₹0 | ₹0 | ❌ Risk to ₹0 once monthly quota expires |
| **Privacy** | ⚠️ Audio sent to Google servers | ✅ On-device if offline pack active | ✅ 100% on-device | ❌ Voice audio transmitted to cloud |
| **Offline** | ❌ Generally fails offline | ✅ Works offline (with language pack) | ✅ 100% offline | ❌ Completely unavailable offline |
| **Install-size impact** | None | None | +40–150 MB (model file) | None |
| **Japanese accuracy** | Good (Google cloud engine) | Good (OS speech engine) | Moderate–Good (Whisper Base/Small) | Excellent |
| **Status** | *Requires Phase 08 offline behaviour validation on target device* | *Requires Phase 08 validation of offline pack reliability* | *Requires Phase 08 model size and WER benchmarking* | *Disqualified — cost and offline constraints* |

> **Recommendation note (to be confirmed in Phase 08):** Option B (Android Native) is the leading candidate if the platform is native/hybrid. Option C (Embedded Whisper/Vosk) is the privacy-first fallback if bundle-size constraints permit. Option A is viable for PWA with clear online-only disclosure. Option D is disqualified.

---

#### Candidate Options Analysis

##### Option A: Web Speech API (`webkitSpeechRecognition`)
- **Description:** Browser-native speech recognition interface available in Chromium-based browsers.
- **Advantages (Pros):**
  - Built directly into the browser/WebView; zero additional code libraries or installation footprint.
  - Free to invoke with native JavaScript; supports English (`en-US`) and Japanese (`ja-JP`).
- **Disadvantages (Cons):**
  - **Online requirement:** On Chrome for Android, speech audio is streamed to Google cloud servers for processing; fails or degrades heavily when offline.
  - Voice privacy: Audio recordings are transmitted to Google speech recognition infrastructure.
  - Inconsistent API behavior across non-Chromium browsers or isolated WebView instances.
- **Cost:** ₹0.
- **Privacy implications:** Audio data streamed to Google servers for recognition.
- **Offline behaviour:** Generally fails without active internet connection.
- **Verification status:** *[Requires Phase 08 Validation]* Testing offline voice recognition behavior in Chromium on target Android device.

##### Option B: Android Native Speech Recognizer (`android.speech.SpeechRecognizer`)
- **Description:** Device-level Android speech recognition service invoking the OS-level speech engine.
- **Advantages (Pros):**
  - Leverages Android OS speech services; zero impact on AIBO's installation bundle.
  - Capable of working completely offline if the user has downloaded offline speech recognition language packs in Android System Settings.
  - High recognition accuracy backed by Google speech models on Android.
- **Disadvantages (Cons):**
  - Requires native Android application or Capacitor native bridge plugin.
  - Offline capability depends on user's device configuration (offline language pack installed in Android settings).
  - OS dialog or permissions handling can be intrusive.
- **Cost:** ₹0.
- **Privacy implications:** Processed by Android OS. If offline language pack is active, audio never leaves device.
- **Offline behaviour:** Works offline if Android OS speech pack is pre-installed.
- **Verification status:** *[Requires Phase 08 Validation]* Verifying offline speech pack reliability across Android versions.

##### Option C: Embedded Open-Source STT Model (Whisper.tflite / Vosk / sherpa-onnx)
- **Description:** Bundling a lightweight, quantized open-source speech recognition model directly inside the application.
- **Advantages (Pros):**
  - 100% offline, guaranteed: Zero dependence on OS settings, browser vendors, or cloud networks.
  - Absolute privacy: Voice audio never leaves local device memory.
- **Disadvantages (Cons):**
  - **Size budget impact:** Quantized models (e.g. Whisper Tiny/Base or Vosk Japanese model) range from 40 MB to 150 MB, threatening the <200 MB initial install limit.
  - Substantial CPU and battery drain during mobile audio inference.
  - Higher integration and build complexity.
- **Cost:** ₹0.
- **Privacy implications:** 100% private and on-device.
- **Offline behaviour:** 100% offline execution.
- **Verification status:** *[Requires Phase 08 Validation]* Benchmarking model file sizes, Japanese WER (Word Error Rate), and inference latency on Android.

##### Option D: Cloud Speech-to-Text API (e.g. Google Cloud Speech-to-Text)
- **Description:** Sending recorded audio chunks to a cloud speech API for transcription.
- **Advantages (Pros):**
  - High transcription accuracy for mixed English/Japanese accents; zero installation size impact.
- **Disadvantages (Cons):**
  - **Cost barrier:** Free tier is limited (e.g. 60 minutes/month on Google Cloud STT); requires billing account setup and risks paid escalation.
  - Fails completely without internet connectivity.
  - Transmits voice audio over network.
- **Cost:** High risk to ₹0 constraint once monthly quota expires.
- **Privacy implications:** Voice audio transmitted to cloud servers.
- **Offline behaviour:** Completely unavailable offline.
- **Verification status:** *[Identified limitation]* Not viable for baseline offline capability; violates cost guardrails.

#### Evaluation Criteria (To be investigated in Phase 08):
- Transcription accuracy for English and conversational Japanese.
- Offline functionality independent of cloud connections.
- Impact on the <200 MB initial installation budget.
- Latency between speech completion and text appearance (<1.5 seconds target).
- Battery and CPU consumption on mobile hardware.

---

### U-6: Map-Data Licensing and Offline Download Strategy

| Field | Detail |
|---|---|
| **Question** | How should AIBO deliver offline map display and navigation for urban areas in Japan? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 07 |
| **Status** | ✅ **Resolved (Option A: OSM + Offline Tile Caching — see [`docs/11_ADR_maps.md`](11_ADR_maps.md))** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: OSM + MapLibre GL (PMTiles) (Selected) | Option B: Google Maps SDK | Option C: Mapbox Maps SDK | Option D: Pre-Rendered Static Maps |
|---|---|---|---|---|
| **Key pros** | Fully permissive ODbL + BSD licensing; compact vector tiles; optional Wi-Fi download; zero telemetry | Industry-leading accuracy; comprehensive Japanese POIs | Polished SDK; built-in offline pack management | Trivial implementation; minimal storage footprint (~5–10 MB) |
| **Key cons** | Offline routing requires embedded routing engine (complexity); rural POI coverage may be thinner | **Disqualified by ToS** — caching tiles offline violates Google Maps Platform Section 3.2.4; requires billing account | License has moved away from open-source; telemetry required; cost risk | No zooming, GPS tracking, address search, or routing — does not meet navigation needs |
| **Cost** | ₹0 permanently | ❌ Violates ₹0 constraint | ❌ Commercial charges possible | ₹0 |
| **Privacy** | ✅ 100% — no network requests during offline use; no telemetry | ❌ Transmits location and usage telemetry to Google | ⚠️ Telemetry collection required on free tiers | ✅ 100% local |
| **Offline** | ✅ 100% once regional tile pack downloaded | ❌ Prohibited by license | ⚠️ Supported but constrained by provider download caps | ✅ Fully offline |
| **Routing** | ⚠️ Requires Valhalla/GraphHopper integration | N/A (disqualified) | ✅ Available via API | ❌ None |
| **Status** | ✅ **Approved & Adopted (ADR-006)** | *Disqualified by Terms of Service* | *Disadvantaged vs. MapLibre on cost and telemetry* | *Disqualified — fails core navigation requirements* |

> **Resolution Note (2026-10-25):** The Project Owner formally approved **Option A (OpenStreetMap with Offline Tile Caching and Local Geographic Indexing)**. This guarantees 100% offline orientation, absolute privacy (no Google/Mapbox telemetry), and zero operating cost forever. Detailed in [`docs/11_ADR_maps.md`](11_ADR_maps.md).

---

#### Candidate Options Analysis

##### Option A: OpenStreetMap (OSM) + MapLibre GL (Vector Tiles / PMTiles)
- **Description:** Open-source vector map rendering using MapLibre GL Native or MapLibre GL JS, with downloadable vector tile packages (PMTiles or MBTiles) covering target regions in Japan.
- **Advantages (Pros):**
  - Completely permissive licensing: OpenStreetMap data is licensed under Open Database License (ODbL); MapLibre is open-source (BSD 3-Clause). No commercial API keys or vendor lock-in.
  - Compact storage: Modern vector tiles compress urban regional maps efficiently (e.g. Tokyo prefecture vector tiles are typically ~80–180 MB).
  - Can be downloaded on demand over Wi-Fi as an optional add-on pack, preserving the under-200-MB initial install target.
  - Smooth client-side vector rendering, styling, and rotation.
- **Disadvantages (Cons):**
  - Requires hosting or downloading pre-generated tile archives.
  - Japanese address searching and turn-by-turn routing offline require an embedded routing graph (e.g. routing engine like Valhalla or GraphHopper), which increases integration complexity.
  - Point-of-interest (POI) detail in some rural areas of Japan may be less comprehensive than commercial Japanese maps.
- **Cost:** ₹0 permanently.
- **Privacy implications:** 100% private. Offline vector rendering performs zero network requests and tracks zero user location telemetry.
- **Offline behaviour:** 100% offline functionality once regional tile pack is downloaded.
- **Verification status:** *[Requires Phase 07 Validation]* Validating Japan regional vector tile download sizes, PMTiles performance on mobile, and offline routing integration.

##### Option B: Google Maps SDK for Android
- **Description:** Native Android Google Maps SDK.
- **Advantages (Pros):**
  - Industry-leading map accuracy, comprehensive Japanese business POIs, building footprints, and address search.
- **Disadvantages (Cons):**
  - **Terms of Service Violation:** Google Maps Platform Terms of Service explicitly prohibit caching, downloading, or storing map tiles or content offline for independent display (Section 3.2.4).
  - Requires Google Cloud billing account setup with risk of automatic paid escalation if monthly free credits are exceeded.
  - Fails when connectivity is lost (cannot provide custom offline navigation).
- **Cost:** Requires credit card billing setup; violates ₹0 constraint guardrail.
- **Privacy implications:** Transmits user location and usage telemetry to Google servers.
- **Offline behaviour:** Prohibited by license; fails offline.
- **Verification status:** *[Disqualified by Terms of Service]* Storing tiles offline is prohibited by Google Maps Platform terms. Non-viable for offline map requirements.

##### Option C: Mapbox Maps SDK
- **Description:** Commercial map SDK supporting vector tiles and offline tile packs.
- **Advantages (Pros):**
  - Polished mobile SDK with built-in offline pack download management APIs.
  - High quality cartography and routing APIs.
- **Disadvantages (Cons):**
  - **Licensing and cost restrictions:** Mapbox free tier has strict limits on monthly active users and offline tile downloads; requires credit card billing registration; license transitions have moved away from fully open source.
  - Telemetry collection is enabled by default and required on some free tiers.
- **Cost:** Carries risk of commercial charges.
- **Privacy implications:** Telemetry collection required unless custom commercial terms are purchased.
- **Offline behaviour:** Supported via offline packs, but constrained by provider download caps.
- **Verification status:** *[Requires Phase 07 Validation]* Disadvantaged relative to MapLibre on cost risk and telemetry.

##### Option D: Pre-Rendered Static Overview Maps (Raster / SVG)
- **Description:** Bundling static geographic maps or transit schematics as pre-rendered images or vector SVGs.
- **Advantages (Pros):**
  - Trivial implementation; minimal storage footprint (~5–10 MB); 100% offline; zero licensing risk.
- **Disadvantages (Cons):**
  - Extremely limited utility: No dynamic zooming, panning, GPS position tracking, address search, or routing.
  - Does not satisfy modern navigation requirements.
- **Cost:** ₹0.
- **Privacy implications:** 100% local.
- **Offline behaviour:** Fully offline.
- **Verification status:** *[Identified limitation]* Fails to meet the core functional needs of an interactive navigation companion.

#### Evaluation Criteria (To be investigated in Phase 07):
- Legal compliance and licensing terms for offline mobile tile storage and routing.
- Download package size for Tokyo and urban Japan regions (balancing detail vs. storage).
- Offline routing calculation capability (walking and transit).
- Integration complexity for a single developer.
- 100% zero-cost sustainability without paid API keys.

---

### U-7: Notification Reliability and Scheduling Strategy

| Field | Detail |
|---|---|
| **Question** | How can AIBO deliver reliable task reminders, and how does the platform architecture constrain this? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ✅ **Resolved (In-App Today Summary + Local Exact Alarms via Flutter — see [`docs/09_ADR_notifications.md`](09_ADR_notifications.md))** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Web Push Notifications (PWA) | Option B: Native Android Exact Alarms (AlarmManager) — SELECTED | Option C: In-App "Today" Summary Only — SELECTED BASELINE |
|---|---|---|---|
| **Key pros** | Works within pure web architecture; no native code | 100% reliable offline alarm delivery even from deep sleep / Doze mode | Platform-agnostic; 100% reliable; zero background battery use; instant upon launch |
| **Key cons** | **Cannot schedule local offline alarms** — requires internet + push server | Android permission requests (`SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`) | Does not proactively interrupt user if they don't open the app |
| **Cost** | ₹0 (within push server free quota) | **₹0 permanently** | **₹0 permanently** |
| **Privacy** | Push payloads routed through Firebase Cloud Messaging gateway | ✅ **100% local — zero network calls** | ✅ **100% local** |
| **Offline** | ❌ Completely fails — alarms cannot fire when offline | ✅ **100% offline — fires exactly on schedule regardless of connectivity** | ✅ **100% offline** |
| **Battery impact** | Network polling overhead from push gateway | Minimal — OS handles scheduling natively | Zero background consumption |
| **Status** | *Rejected — unviable for offline alarms* | ✅ **Adopted for Device Alarms (ADR-004)** | ✅ **Adopted as In-App Baseline (ADR-004)** |

> **Resolution Note (2026-10-25):** The Project Owner resolved U-7 by approving a **Dual Notification Strategy**:
> 1. In-App: The "Today" Summary Screen is the primary view upon opening AIBO.
> 2. Device Alarms: Exact background reminders fire offline via Android `AlarmManager` and `flutter_local_notifications`. See full details in [`docs/09_ADR_notifications.md`](09_ADR_notifications.md).

---

#### Candidate Options Analysis

##### Option A: Web Push Notifications (PWA Service Worker + Push API)
- **Description:** Background notifications delivered via the browser Push API and Service Worker.
- **Advantages (Pros):**
  - Works within standard web application architecture without requiring a native wrapper.
- **Disadvantages (Cons):**
  - **Severe offline flaw:** Web Push notifications cannot be scheduled locally to fire autonomously. They require a remote server to send a push message over the internet to the device when the alarm is due. If the phone is offline or in airplane mode, the reminder will never fire!
  - Android OEM battery optimization (Doze mode, vendor background killers) frequently delays or suppresses Web Push delivery.
  - Requires maintaining an external push server with VAPID keys.
- **Cost:** ₹0 within free push server quotas.
- **Privacy implications:** Push payloads routed through browser push gateways (e.g. Firebase Cloud Messaging for Chrome).
- **Offline behaviour:** Completely fails to trigger scheduled reminders when offline.
- **Verification status:** *[Verified limitation]* Web Push is architecturally incapable of offline scheduled alarms. Unacceptable for reliable offline reminders.

##### Option B: Native Android Exact Alarms (`AlarmManager` / `WorkManager`)
- **Description:** Device-level notification scheduling using Android's native `AlarmManager.setExactAndAllowWhileIdle()` and notification channels.
- **Advantages (Pros):**
  - 100% reliable delivery: Exact alarms wake the device from deep sleep (Doze mode) at the exact scheduled second, even when the device is completely offline and the app has been terminated.
  - Completely local: Zero network calls, zero external push servers, zero battery waste from network polling.
- **Disadvantages (Cons):**
  - Requires native Android code (Kotlin or Capacitor native plugin).
  - Requires requesting user permission for `POST_NOTIFICATIONS` (Android 13+) and `SCHEDULE_EXACT_ALARM` (Android 12+).
- **Cost:** ₹0.
- **Privacy implications:** 100% local to device.
- **Offline behaviour:** 100% offline functionality.
- **Verification status:** *[Verified capability]* Android AlarmManager is the industry standard for exact local offline reminders. Tied to U-1 platform choice.

##### Option C: In-App "Today" Summary Only (Approved MVP Baseline)
- **Description:** No background push notifications or system alarms in the MVP. Instead, a dedicated "Today" summary screen automatically presents today's tasks, overdue items, and upcoming deadlines whenever the user opens AIBO (US-PL-06).
- **Advantages (Pros):**
  - 100% platform-agnostic: Works identically on PWA, hybrid, or native Android.
  - 100% reliable: Zero risk of silent background alarm failures, OS battery killer suppression, or notification permission rejections.
  - 100% offline: Reads instantly from local storage on app launch.
  - Zero background battery consumption and zero push server infrastructure to build or maintain.
- **Disadvantages (Cons):**
  - Does not proactively interrupt or alert the user if they forget to open the application on a given day.
- **Cost:** Exactly ₹0.
- **Privacy implications:** 100% local.
- **Offline behaviour:** 100% offline functionality.
- **Verification status:** *[Approved MVP Scope]* Formally adopted as the MVP baseline. Background notifications are deferred to post-MVP pending platform testing.

#### Evaluation Criteria (To be investigated in Phase 02):
- Background notification delivery accuracy during deep sleep / Doze mode.
- Feasibility of local offline scheduling vs. cloud push dependencies.
- Impact on device battery life.
- User permission friction on modern Android versions (Android 13+).

---

### U-8: Backup and Recovery Strategy

| Field | Detail |
|---|---|
| **Question** | How should AIBO back up user data and recover from data loss or device replacement? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 / Phase 03 |
| **Status** | ✅ **Resolved (Option D: Hybrid Manual Encrypted Export for MVP — see [`docs/10_ADR_backup.md`](10_ADR_backup.md))** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Automated Cloud Sync (Real-Time) | Option B: Manual Encrypted Export / Import *(Recommended MVP Pattern)* | Option C: Android OS Auto-Backup | Option D: Hybrid (Export MVP → Cloud Sync Later) — SELECTED |
|---|---|---|---|---|
| **Key pros** | Continuous protection; no manual user action; instant multi-device recovery | Serverless; ₹0 permanently; maximum privacy (AES-256 encrypted archive); user controls backup location | Transparent OS-managed backup; zero user effort | Eliminates cloud risk during early phases; delivers full recovery on Day 1; clean fallback for later cloud layer |
| **Key cons** | Dependent on cloud infra; client-side encryption complicates sync; risk of write quota caps | Relies on user discipline to export periodically | **25 MB hard cap per app** — Document Vault photos fail | Initial reliance on manual export discipline |
| **Cost** | ₹0 only within free-tier limits | **₹0 permanently** | ₹0 | **₹0 permanently** |
| **Privacy** | Stored on third-party cloud | ✅ Optimal — AES-GCM encryption | Google-managed keys | ✅ **100% client-side AES-256 encryption** |
| **Offline** | Queues locally | ✅ **100% offline** | Queued by OS | ✅ **100% offline export/import** |
| **Suitable for Document Vault?** | ⚠️ Only with complex encryption | ✅ Yes — full encrypted archive | ❌ No — 25 MB cap exceeded | ✅ **Yes (via manual encrypted bundle)** |
| **Status** | *Deferred to future phases* | *Adopted as core engine of Option D* | *Disqualified — 25 MB cap* | ✅ **Adopted & Approved (ADR-005)** |

> **Resolution Note (2026-10-25):** The Project Owner formally approved **Option D (Hybrid)**: Phase 03 will implement a serverless, zero-cost, AES-256 encrypted archive export/import system (`share_plus` / `file_picker`), with optional Google Drive cloud sync deferred to future post-MVP phases. See [`docs/10_ADR_backup.md`](10_ADR_backup.md).

---

#### Candidate Options Analysis

##### Option A: Automated Cloud Sync (Per-Record Real-Time Sync)
- **Description:** Automatic background synchronization of all database records to a cloud hosting provider (e.g. Firebase Firestore or Supabase).
- **Advantages (Pros):**
  - Continuous data protection: Any expense, task, or note created is immediately backed up to the cloud without manual user action.
  - Effortless multi-device access and instant recovery upon device replacement.
- **Disadvantages (Cons):**
  - Requires active cloud database infrastructure (dependent on decision U-3).
  - **Severe privacy & encryption complexity:** To comply with NFR-P-01 and NFR-P-07, sensitive personal documents and emergency medical info must be encrypted client-side with a user-held key before upload, making cloud conflict resolution and indexing complex.
  - Risks hitting free-tier database write/read quotas if chat logs or sync queries loop excessively.
- **Cost:** ₹0 only while strictly within free-tier limits.
- **Privacy implications:** User records stored on third-party cloud infrastructure.
- **Offline behaviour:** Queues mutations locally and attempts sync when connectivity returns.
- **Verification status:** *[Requires Phase 03 Validation]* Dependent on U-3 selection and client-side encryption architecture.

##### Option B: Manual Encrypted Export / Import (Encrypted Archive File)
- **Description:** A dedicated in-app tool allowing the user to export their entire application state (chat history, persistent memory, expenses, documents, tasks, emergency info) as a single AES-256 encrypted archive (e.g. JSON/ZIP bundle) protected by a passphrase, saved locally or shared to Google Drive / SD card.
- **Advantages (Pros):**
  - **100% Serverless & ₹0 cost:** Zero ongoing cloud infrastructure, zero database quotas to monitor, zero risk of third-party service discontinuation.
  - **Maximum Privacy & Data Sovereignty:** The backup file is encrypted locally on the device with a user password before leaving the app; the user has complete visibility and control over where the file is stored.
  - Complete data coverage: Captures all user data types in a standardized, portable schema.
  - Clean disaster recovery: Trivial to restore on a fresh installation by selecting the file and entering the passphrase.
- **Disadvantages (Cons):**
  - Relies on manual user discipline to trigger exports periodically.
  - If the user loses their phone without having exported recently, data created since the last export is lost.
- **Cost:** Exactly ₹0 permanently.
- **Privacy implications:** Optimal. Encryption at rest using standard algorithms (AES-GCM); user retains physical custody of backup archives.
- **Offline behaviour:** 100% functional offline. Export and import require zero network connectivity.
- **Verification status:** *[Recommended MVP Pattern]* Standard, highly reliable pattern for single-user personal tools.

##### Option C: Android OS Auto-Backup (`android:allowBackup="true"`)
- **Description:** Relying on Android's built-in system backup mechanism to back up application data to the user's personal Google Drive account.
- **Advantages (Pros):**
  - Transparent to the user; automatically triggered by the operating system when the device is idle, charging, and connected to Wi-Fi.
- **Disadvantages (Cons):**
  - **Severe size restriction:** Google Drive Auto-Backup enforces a strict 25 MB cap per application. Photos and scans in the Document Vault will quickly exceed this limit, causing backups to fail silently.
  - Platform-restricted: Works only for native Android apps, not for standalone browser PWAs.
  - Opaque: The user cannot easily inspect, download, or selectively restore individual items.
- **Cost:** ₹0 (included with user's personal Google account).
- **Privacy implications:** Stored in Google Drive; keys managed by OS/Google unless device-level end-to-end encryption is enabled.
- **Offline behaviour:** Queued locally by OS until charging and Wi-Fi are available.
- **Verification status:** *[Verified limitation]* 25 MB cap makes this inadequate for Document Vault image storage.

##### Option D: Hybrid Approach (Manual Encrypted Export in MVP, Cloud Sync Evaluated Later)
- **Description:** Implement Option B (Manual Encrypted Export/Import) as the primary backup and recovery mechanism for the MVP (Phase 03). Evaluate automated encrypted cloud sync in later phases once core data models and infrastructure have stabilized.
- **Advantages (Pros):**
  - Eliminates server dependency and cost risk during early phases.
  - Delivers complete data recovery protection on Day 1 of MVP.
  - Provides a clean fallback even if cloud sync is introduced later.
- **Disadvantages (Cons):**
  - Initial reliance on user export discipline until automated sync is implemented.
- **Cost:** Exactly ₹0.
- **Privacy implications:** 100% client-side data sovereignty in MVP.
- **Offline behaviour:** Fully functional offline.
- **Verification status:** *[Recommended Strategy]* Matches Phase 03 scope and minimizes architectural risk.

#### Evaluation Criteria (To be investigated in Phase 03):
- Completeness of backup archive across all data types (chat, memory, expenses, vault documents, phrases, tasks, emergency data).
- Encryption strength (AES-256-GCM) with user-derived passphrases.
- Simplicity and speed of full restoration from a backup file.
- Total cost impact (₹0 target).
- User friction and data loss mitigation.

---

### U-9: Emergency Info Card — Quick-Access vs. Full Authentication

| Field | Detail |
|---|---|
| **Question** | Should the personal emergency info card (blood type, allergies, emergency contacts) be accessible without full app authentication so it can be shown to first responders quickly, or should it always require authentication like the rest of the vault? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 03 |
| **Status** | ✅ **Resolved (Option B: Quick-Access Mode)** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Always requires full authentication | Option B: Quick-access mode — SELECTED | Option C: Configurable — owner chooses per-run |
|---|---|---|---|
| **Key pros** | Consistent privacy model; no risk of casual exposure of medical details | Immediately useful in an emergency — first responder can see critical info without unlocking the phone | Owner can set the level they're comfortable with; flexible |
| **Key cons** | May be impossible to access if user is unconscious or unable to unlock their device | Basic emergency card visible without PIN/fingerprint | More complex UI and logic to implement; easy to misconfigure |
| **Privacy risk** | Lowest | Controlled (Emergency card only; vault/notes remain encrypted) | Medium — depends on configuration |
| **Practical utility in emergency** | Low (if user is incapacitated) | **High (Accessible instantly in critical situations)** | High |
| **Status** | *Rejected — unacceptable safety risk in crisis* | ✅ **Adopted & Approved by Project Owner** | *Rejected — unnecessary complexity* |

> **Resolution Note (2026-10-25):** The Project Owner resolved U-9 by approving **Option B (Quick-Access Mode)**. An "EMERGENCY" button is accessible directly from the app entry/lock screen *before* authentication, presenting:
> 1. One-tap emergency dial buttons (110 Police, 119 Ambulance/Fire, Embassy).
> 2. Essential Japanese emergency phrases with furigana and English translations.
> 3. Personal medical card (Full name, blood type, allergies, emergency contact phone).
>
> All other application data (Document Vault scans, financial logs, chat memory, private notes) remains strictly AES-256 encrypted behind the biometric/PIN gate. Approved exception to NFR-P-07 is documented accordingly.

---

### U-10: Japanese Phrase-Book Data Source

| Field | Detail |
|---|---|
| **Question** | What should AIBO use as the data source for Japanese phrase lookup and translation in the language support feature? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 04 |
| **Status** | ✅ **Resolved (Hybrid: Bundled Offline Essentials + Cloud LLM)** |

#### Structured Comparison: Pros and Cons by Option

| Criterion | Option A: Cloud LLM Translation | Option B: Free Dictionary API (Jisho.org) | Option C: Bundled Offline Curated Phrases — SELECTED | Option D: Hybrid Strategy — SELECTED ARCHITECTURE |
|---|---|---|---|---|
| **Key pros** | Context-aware natural sentences, slang, email drafting | Structured kanji/kana definitions | 100% offline, zero latency, zero quota, instant furigana | Best of both: offline survival certainty + online conversational power |
| **Key cons** | Requires internet; consumes daily token quota | Requires internet; community SLA | Curated dataset covers daily life/survival rather than all words | Slight additional UI logic to toggle online translation |
| **Cost** | ₹0 within verified free quota | ₹0 | ₹0 permanently | **₹0 permanently** |
| **Privacy** | Outbound query sent to LLM | Sent to Jisho servers | ✅ 100% on-device | ✅ 100% local for standard phrases |
| **Offline** | ❌ Fails offline | ❌ Fails offline | ✅ **100% offline** | ✅ **Core phrases 100% offline** |
| **Status** | *Used for dynamic translation* | *Rejected — internet dependency* | ✅ **Adopted as Offline Baseline** | ✅ **Adopted & Approved (Phase 04)** |

> **Resolution Note (2026-10-25):** The Project Owner resolved U-10 by approving the **Hybrid Architecture**:
> 1. **Offline Baseline:** A rich curated database of essential Japan-life phrases categorized across 6 daily domains (Train & Transit, Shopping & Konbini, Ward Office & Admin, Dining & Allergies, Medical & Pharmacy, Garbage & Recycling) is bundled directly with the application, featuring full Kanji, Furigana readings, Romaji, and English meanings with zero network calls and zero quota consumption.
> 2. **Online Dynamic Translation:** When an active internet connection is available, the connected Cloud LLM (Gemini 1.5 Flash / NVIDIA Nemotron) provides free-form bilingual translation, context explanation, and polite email drafting.

---

## 4. Phase Ordering Notes

- Phases 04, 05, and 06 can potentially be worked in parallel after Phase 03, but each requires separate approval.
- Phase 07 (maps) and Phase 09 (transit) have external dependencies (licensing, APIs) that may cause delays. These are intentionally placed later.
- Phase 10 (on-device AI) is explicitly optional and can be skipped entirely.
- Phases 11 and 12 are sequential and come after all feature work.

---

## Approval

- [x] Project owner has reviewed and approved this roadmap.
- [x] Phase 01 exit criteria checklist reviewed.
