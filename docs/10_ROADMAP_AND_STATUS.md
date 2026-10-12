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
| **03** | Core Infrastructure | Project scaffolding, local storage, basic data layer, authentication, backup strategy | ⬜ Not Started |
| **04** | Conversational AI + Japanese Language Support | Chat UI, LLM integration, phrase lookup, furigana, offline phrase book | ⬜ Not Started |
| **05** | Document Vault + OCR Foundation | Document storage, categorisation, secure access; initial OCR exploration | ⬜ Not Started |
| **06** | Expense Tracker + Daily Planner | Expense logging, categorisation, summaries; task list, reminders | ⬜ Not Started |
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
- CI/CD pipeline (if applicable)

**Exit Criteria:**
- [ ] App skeleton runs on Android device.
- [ ] Local storage CRUD operations verified for all data types.
- [ ] Authentication gate functional.
- [ ] Tests pass per `docs/08_TESTING_AND_QA.md`.
- [ ] Project owner has approved.

**Dependencies:** Phase 02 approved.

---

### Phase 04 — Conversational AI + Japanese Language Support

**Objective:** Implement the AI chat interface and Japanese language features.

**Exit Criteria:**
- [ ] Chat UI functional with LLM responses.
- [ ] No fabricated information in responses.
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

Canonical list of decisions that remain open. Each has a target phase for resolution.

| ID | Decision | Target Phase | Status |
|---|---|---|---|
| U-1 | PWA vs. native Android | Phase 02 | ⬜ Open |
| U-2 | Cloud LLM provider and verified free-tier quota | Phase 02 | ⬜ Open |
| U-3 | Hosting platform and database service | Phase 02 | ⬜ Open |
| U-4 | Japanese OCR approach | Phase 05 | ⬜ Open |
| U-5 | Voice input / STT implementation | Phase 08 | ⬜ Open |
| U-6 | Map-data licensing and offline download strategy | Phase 07 | ⬜ Open |
| U-7 | Notification reliability (PWA vs. native) | Phase 02 | ⬜ Open |
| U-8 | Backup and recovery strategy | Phase 03 | ⬜ Open |

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
