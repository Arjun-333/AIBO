# Project AIBO — Roadmap and Status

**Document status:** DRAFT — awaiting owner approval  
**Last updated:** 2026-10-13  
**Current phase:** Phase 01 — Foundation and Documentation (IN PROGRESS)

---

## 1. The 12 Phases

| Phase | Name | Summary | Status |
|---|---|---|---|
| **01** | Foundation and Documentation | Project charter, PRD, agent rules, roadmap, testing strategy | 🟡 In Progress |
| **02** | Architecture and Technology Selection | Resolve PWA vs. native, select LLM provider, hosting, database; produce ADRs | ⬜ Not Started |
| **03** | Core Infrastructure | Project scaffolding, local storage, basic data layer, authentication, backup strategy, offline emergency screen | ⬜ Not Started |
| **04** | Conversational AI + Japanese Language Support | Chat UI, LLM integration, chat management, persistent memory, phrase lookup, furigana, offline phrase book | ⬜ Not Started |
| **05** | Document Vault + OCR Foundation | Document storage, categorisation, secure access; initial OCR exploration | ⬜ Not Started |
| **06** | Expense Tracker + Daily Planner | Expense logging, categorisation, summaries; task list, "Today" summary | ⬜ Not Started |
| **07** | Offline Maps + Navigation | Map-data licensing, offline map display, basic routing | ⬜ Not Started |
| **08** | Voice Input + Advanced Language Features | Speech-to-text, pronunciation help, advanced translation | ⬜ Not Started |
| **09** | Transit + Location-Based Features | Train/transit information (verified APIs only), location-aware suggestions | ⬜ Not Started |
| **10** | On-Device AI (Optional) | Evaluate and optionally integrate on-device AI models | ⬜ Not Started |
| **11** | Polish, Performance + Accessibility | UI refinement, performance optimisation, accessibility audit, UX improvements | ⬜ Not Started |
| **12** | Stabilisation + Long-Term Maintenance | Bug fixes, documentation finalisation, maintenance plan, future roadmap | ⬜ Not Started |

---

## 2. Phase Details

### Phase 01 — Foundation and Documentation

**Objective:** Establish project documentation, constraints, and governance before any implementation.

**Deliverables:**
- `docs/00_PROJECT_CHARTER.md` — Project vision, constraints, MVP goals
- `docs/01_PRD.md` — Requirements, user stories, acceptance criteria
- `docs/AGENT_RULES.md` — Rules governing agent and contributor behaviour
- `docs/10_ROADMAP_AND_STATUS.md` — This file
- `docs/08_TESTING_AND_QA.md` — Testing strategy and phase gate checklists
- `README.md` — Repository overview

**Exit Criteria:**
- [ ] All five documentation files created and internally consistent.
- [ ] Unresolved decisions clearly listed with target phases.
- [ ] No application code, packages, or deployments created.
- [ ] Project owner has reviewed and approved all documents.

**Dependencies:** None (first phase).

---

### Phase 02 — Architecture and Technology Selection

**Objective:** Make and document all foundational technology decisions.

**Key Decisions to Resolve:**
- U-1: PWA vs. native Android
- U-2: Cloud LLM provider (with verified free-tier quota)
- U-3: Hosting platform and database service
- U-7: Notification reliability approach
- U-8: Backup and recovery strategy

**Deliverables:**
- Architecture Decision Records (ADRs) for each decision
- Technology stack specification
- Updated PRD with technology-specific details
- Development environment setup instructions

**Exit Criteria:**
- [ ] All Phase 02 unresolved decisions resolved and documented in ADRs.
- [ ] Free-tier limits verified (not just claimed) for all selected services.
- [ ] Total projected cost confirmed as ₹0/month.
- [ ] Installation size budget allocated across components.
- [ ] Project owner has approved the architecture.

**Dependencies:** Phase 01 approved.

---

### Phase 03 — Core Infrastructure

**Objective:** Build the application skeleton with local storage, data layer, and basic security.

**Deliverables:**
- Project scaffolding (framework setup per Phase 02 decisions)
- Local storage implementation (IndexedDB, SQLite, or per architecture)
- Basic data models for all MVP features
- App-level authentication (PIN/biometric/device lock)
- Backup and recovery implementation (per U-8 decision)
- Basic offline emergency screen (emergency numbers, phrases, editable personal info card)
- CI/CD pipeline (if applicable)

**Exit Criteria:**
- [ ] App skeleton runs on Android device.
- [ ] Local storage CRUD operations verified for all data types.
- [ ] Authentication gate functional.
- [ ] Emergency numbers, phrases, and editable info card accessible offline.
- [ ] Emergency info card privacy protections (encryption, authentication) verified.
- [ ] Tests pass per `docs/08_TESTING_AND_QA.md`.
- [ ] Project owner has approved.

**Dependencies:** Phase 02 approved.

---

### Phase 04 — Conversational AI + Japanese Language Support

**Objective:** Implement the AI chat interface and Japanese language features.

**Exit Criteria:**
- [ ] Chat UI functional with LLM responses.
- [ ] No fabricated information in responses.
- [ ] Chat history deletion (individual and clear-all) functional.
- [ ] Long-term memory opt-in, inspection, editing, and deletion functional.
- [ ] Storage limits and warnings implemented for chat history.
- [ ] Data minimisation verified: document vault, financial history, and emergency info not sent to LLM by default.
- [ ] Phrase lookup and furigana display working.
- [ ] Offline phrase book functional.
- [ ] Free-tier usage within limits during testing.
- [ ] Tests pass. Project owner has approved.

**Dependencies:** Phase 03 approved. U-2 resolved.

---

### Phase 05 — Document Vault + OCR Foundation

**Exit Criteria:**
- [ ] Documents can be stored, categorised, and viewed.
- [ ] Documents accessible offline.
- [ ] Encryption at rest implemented.
- [ ] OCR approach evaluated (implementation may be deferred).
- [ ] Tests pass. Project owner has approved.

**Dependencies:** Phase 03 approved. U-4 evaluated.

---

### Phase 06 — Expense Tracker + Daily Planner

**Exit Criteria:**
- [ ] Expense CRUD and summaries functional.
- [ ] Offline expense logging verified.
- [ ] Daily planner CRUD functional offline.
- [ ] "Today" summary with overdue and upcoming tasks shown on app open, including offline.
- [ ] Tests pass. Project owner has approved.

**Dependencies:** Phase 03 approved.

---

### Phase 07 — Offline Maps + Navigation

**Exit Criteria:**
- [ ] Map-data licensing resolved (U-6).
- [ ] Offline map display functional.
- [ ] Basic routing working.
- [ ] Storage impact assessed and within budget.
- [ ] Tests pass. Project owner has approved.

**Dependencies:** Phase 03 approved. U-6 resolved.

---

### Phase 08 — Voice Input + Advanced Language Features

**Exit Criteria:**
- [ ] Voice input functional for at least English and Japanese.
- [ ] Speech-to-text approach verified within free-tier limits (U-5).
- [ ] Advanced translation features implemented.
- [ ] Tests pass. Project owner has approved.

**Dependencies:** Phase 04 approved. U-5 resolved.

---

### Phase 09 — Transit + Location-Based Features

**Exit Criteria:**
- [ ] Transit information sourced from verified API (no fabrication).
- [ ] Location-based suggestions functional.
- [ ] Offline fallback behaviour defined and working.
- [ ] Tests pass. Project owner has approved.

**Dependencies:** Phase 07 approved. Verified transit API identified.

---

### Phase 10 — On-Device AI (Optional)

**Exit Criteria:**
- [ ] On-device AI model evaluated for size, performance, and capability.
- [ ] If adopted: functional and within storage budget.
- [ ] If declined: documented rationale for skipping.
- [ ] Project owner has approved.

**Dependencies:** Phase 04 approved. Optional phase — may be skipped.

---

### Phase 11 — Polish, Performance + Accessibility

**Exit Criteria:**
- [ ] UI reviewed and refined.
- [ ] Performance benchmarks met (per NFR-PF-01, NFR-PF-02).
- [ ] Accessibility audit completed (WCAG 2.1 AA).
- [ ] Installation size verified under 200 MB.
- [ ] Tests pass. Project owner has approved.

**Dependencies:** All feature phases (04–09) approved. Phase 10 resolved (adopted or skipped).

---

### Phase 12 — Stabilisation + Long-Term Maintenance

**Exit Criteria:**
- [ ] All known bugs resolved or documented.
- [ ] Documentation finalised and up to date.
- [ ] Maintenance plan documented (update cadence, backup schedule, dependency updates).
- [ ] Future roadmap drafted (post-v1 features).
- [ ] Project owner has approved final release.

**Dependencies:** Phase 11 approved.

---

## 3. Unresolved Decisions Register

Canonical register of decisions that remain open. The **Project Owner** is the decision owner for all items. No decision is resolved until the Project Owner explicitly approves a choice. No service listed below has been verified.

---

### U-1: PWA vs. Native Android App

| Field | Detail |
|---|---|
| **Question** | Should AIBO be built as a Progressive Web App (PWA), a native Android app, or a hybrid? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) PWA** — Built with web technologies (HTML/CSS/JS), installable via browser, runs in a web view.
- **B) Native Android (Kotlin)** — Built with Android SDK, distributed via APK or Play Store.
- **C) Hybrid (e.g. Capacitor/Ionic)** — Web technologies wrapped in a native shell for device API access.

**Evaluation criteria (research required before deciding):**
- Offline storage depth and reliability (service workers vs. native storage)
- Push notification support and reliability on Android
- Camera and filesystem access for document vault
- Biometric / device-lock authentication support
- Installation size impact
- Development speed and complexity for a single developer
- One-tap emergency dial capability

---

### U-2: Cloud LLM Provider and Verified Free-Tier Quota

| Field | Detail |
|---|---|
| **Question** | Which cloud LLM provider should AIBO use for conversational AI, and does its free tier support the expected usage? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) Google Gemini API** — free tier available; quota to be verified.
- **B) OpenAI API** — limited free credits; may not sustain ongoing use at ₹0.
- **C) Anthropic Claude API** — free tier availability to be verified.
- **D) Open-source model via free hosting** — e.g. Hugging Face Inference API; capability and limits to be verified.
- **E) Other provider** — to be evaluated.

**Evaluation criteria (research required before deciding):**
- Verified free-tier quota (requests/day, tokens/month) under actual expected usage
- Response quality for Japan-life questions and Japanese language support
- Context window size and conversation length limits
- Rate limiting behaviour and graceful degradation when limits are reached
- Data privacy policy (what happens to queries sent to the provider)
- Latency on a stable connection
- Long-term free-tier sustainability (history of provider policy changes)

---

### U-3: Hosting Platform and Database Service

| Field | Detail |
|---|---|
| **Question** | What hosting platform and database service should AIBO use for any server-side components and data sync? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) Firebase (Google)** — Firestore, Hosting, Auth on free Spark plan.
- **B) Supabase** — PostgreSQL, Auth, Storage on free tier.
- **C) Vercel + managed database** — serverless hosting + database free tiers.
- **D) Self-hosted on free-tier VM** — e.g. Oracle Cloud free tier.
- **E) Local-only (no server)** — all data stays on-device; no sync or backup until later phase.

**Evaluation criteria (research required before deciding):**
- Free-tier limits (storage, bandwidth, requests)
- Data residency and privacy policies
- Authentication support (ties to U-1)
- Backup and export capabilities
- Complexity and maintenance burden
- Long-term free-tier sustainability

---

### U-4: Japanese OCR Approach

| Field | Detail |
|---|---|
| **Question** | What approach should AIBO use for extracting Japanese text from images? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 05 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) Tesseract OCR** — open-source, offline-capable; Japanese accuracy varies.
- **B) Google ML Kit** — on-device OCR, free, Japanese language support.
- **C) Cloud OCR API** — e.g. Google Cloud Vision; high accuracy but free-tier limits apply.
- **D) LLM-based extraction** — send image to multimodal LLM for text extraction.

**Evaluation criteria (research required before deciding):**
- Accuracy on Japanese text (kanji, mixed scripts, handwriting)
- Offline vs. online capability
- Cost within ₹0 target
- Installation size impact (on-device models)
- Integration complexity

---

### U-5: Voice Input / STT Implementation

| Field | Detail |
|---|---|
| **Question** | How should AIBO implement speech-to-text for English and Japanese voice input? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 08 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) Web Speech API** — browser-native, free; limited offline support.
- **B) Android native speech recognition** — device-level, free; requires native app (ties to U-1).
- **C) Whisper (local)** — open-source, offline-capable; model size impacts installation.
- **D) Cloud STT API** — e.g. Google Cloud Speech-to-Text; free-tier limits apply.

**Evaluation criteria (research required before deciding):**
- Accuracy for English and Japanese
- Offline capability
- Cost within ₹0 target
- Installation size impact
- Latency

---

### U-6: Map-Data Licensing and Offline Download Strategy

| Field | Detail |
|---|---|
| **Question** | How should AIBO provide offline map display and routing in Japan? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 07 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) OpenStreetMap + MapLibre** — open data, offline tile downloads, free.
- **B) Google Maps SDK** — limited offline support; licensing restrictions.
- **C) Mapbox** — free tier with offline packs; commercial license.
- **D) Pre-rendered static maps** — limited functionality, small storage footprint.

**Evaluation criteria (research required before deciding):**
- Licensing terms for offline storage and display
- Download size for Japan map regions
- Routing capability (walking, transit)
- Integration complexity
- Cost within ₹0 target
- Japan-specific map data quality (POIs, transit stops)

---

### U-7: Notification Reliability (PWA vs. Native)

| Field | Detail |
|---|---|
| **Question** | Can AIBO deliver reliable task reminders and notifications, and how does the platform choice affect this? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 02 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) PWA push notifications** — via Push API + service worker; reliability varies by device/browser.
- **B) Native Android notifications** — reliable via AlarmManager/WorkManager; requires native app.
- **C) In-app only (MVP)** — no background notifications; "Today" summary shown on app open.

**Evaluation criteria (research required before deciding):**
- Reliability of delivery when app is backgrounded or device is idle
- Battery impact
- Platform dependencies (ties to U-1)
- User permission requirements
- Fallback behaviour when notifications fail

> **Note:** MVP uses option C (in-app "Today" summary only). Background notifications are deferred to post-MVP pending reliability evaluation.

---

### U-8: Backup and Recovery Strategy

| Field | Detail |
|---|---|
| **Question** | How should AIBO back up user data and recover from data loss? |
| **Decision owner** | Project Owner |
| **Target phase** | Phase 03 |
| **Status** | ⬜ Open |

**Candidate options:**
- **A) Cloud sync** — automatic backup to hosting provider (ties to U-3).
- **B) Manual export/import** — user-initiated export (JSON/ZIP) to local storage or cloud drive.
- **C) Device-level backup** — rely on Android's built-in backup mechanism.
- **D) Combination** — manual export for MVP, cloud sync later.

**Evaluation criteria (research required before deciding):**
- Data completeness (all user data types: chat, expenses, documents, phrases, tasks, emergency info, memories)
- Encryption in transit and at rest
- Recovery procedure complexity
- Cost within ₹0 target
- Privacy implications of cloud backup

---

## 4. Phase Ordering Notes

- Phases 04, 05, and 06 can potentially be worked in parallel after Phase 03, but each requires separate approval.
- Phase 07 (maps) and Phase 09 (transit) have external dependencies (licensing, APIs) that may cause delays. These are intentionally placed later.
- Phase 10 (on-device AI) is explicitly optional and can be skipped entirely.
- Phases 11 and 12 are sequential and come after all feature work.

---

## Approval

- [ ] Project owner has reviewed and approved this roadmap.
- [ ] Phase 01 exit criteria checklist reviewed.
