# Project AIBO — Project Charter

**Document status:** DRAFT — awaiting owner approval  
**Last updated:** 2026-10-13  
**Phase:** 01 — Foundation and Documentation

---

## 1. Project Vision and Purpose

AIBO (*AI Buddy & Organiser*) is a personal AI companion designed to help a single user live, navigate, and manage daily life in Japan. It combines conversational AI assistance with practical tools for language support, expense tracking, document management, navigation, and daily planning — all accessible from a mobile device, even when the user's development computer is switched off.

AIBO is **not** a general-purpose app or a commercial product. It is a personal tool built for one user, optimised for the specific challenges of living in Japan as a non-native speaker.

---

## 2. Target User and Usage Context

| Attribute | Detail |
|---|---|
| **User** | Single user (the project owner) |
| **Location** | Japan (initially urban areas) |
| **Primary language** | English, with heavy interaction in Japanese (reading, speaking, translating) |
| **Primary device** | Android smartphone |
| **Connectivity** | Variable — must function usefully offline |
| **Use cases** | Daily planning, Japanese language help, expense tracking, document reference, navigation, conversational AI assistance |

---

## 3. Core Principles and Non-Negotiable Constraints

### 3.1 Cost

| Constraint | Detail |
|---|---|
| Target operating cost | ₹0 per month (zero paid services) |
| No automatic paid fallback | Any paid service requires explicit owner approval before use |
| Free-tier verification | Every external service must have its free-tier quota documented and verified before adoption |

### 3.2 Size and Performance

| Constraint | Detail |
|---|---|
| Initial installation size | Under 200 MB |
| Exclusions from size limit | Separately downloaded map packs, future on-device AI models |

### 3.3 Accessibility and Availability

| Constraint | Detail |
|---|---|
| Mobile-first | Usable on Android without requiring a desktop/laptop to be running |
| Offline capabilities | Saved information, Japanese phrases, expense logging, supported offline map functionality must work without connectivity |

### 3.4 AI Strategy

| Constraint | Detail |
|---|---|
| Initial AI | Cloud-based LLM (provider TBD — see §6) |
| Future option | On-device AI models considered as an optional future upgrade, not an MVP requirement |

### 3.5 Integrity and Safety

| Constraint | Detail |
|---|---|
| No fabrication | The system must never fabricate prices, train schedules, official procedures, or successful API responses |
| Data security | Personal information, financial records, and documents must be securely handled |
| Scope control | No unapproved features or scope expansion |
| Architecture approval | Architecture decisions must be documented and approved before implementation |

---

## 4. First-Release (MVP) Goals

The MVP delivers the minimum set of features that makes AIBO genuinely useful for daily life in Japan. Each feature is scoped in detail in `docs/01_PRD.md`.

| # | MVP Feature | Summary |
|---|---|---|
| 1 | **Conversational AI assistant** | Cloud-LLM-powered chat for general questions, Japan-life advice, and contextual help; chat history management and optional persistent memory |
| 2 | **Japanese language support** | Phrase lookup, basic translation, furigana display; offline phrase book |
| 3 | **Expense tracker** | Log expenses in ¥ and ₹, categorise, view history; works offline with sync |
| 4 | **Document vault** | Store and retrieve photos/scans of important documents (residence card, insurance, etc.) locally on device |
| 5 | **Offline essentials** | Saved phrases, logged expenses, stored documents, and emergency information accessible without internet |
| 6 | **Basic daily planner** | Task/reminder list with "Today" summary on app open; in-app reminders only in MVP |
| 7 | **Basic offline emergency support** | Japan emergency numbers, essential Japanese emergency phrases, editable personal emergency info card; all offline-accessible |

> **Note:** Features like full offline maps, OCR, voice input, and notification-based reminders are out of scope for MVP. See §5.

---

## 5. Explicitly Out-of-Scope (MVP)

The following are **not** part of the first release. Some may appear in later phases, but none are approved for implementation until their respective phase is reached and approved.

| Feature | Reason / Status |
|---|---|
| Offline map display and routing | Requires map-data licensing decision (unresolved) |
| Japanese OCR (text from images) | Implementation approach TBD (Phase 05) |
| Voice input / speech-to-text | Implementation approach TBD (Phase 08) |
| On-device AI models | Optional future upgrade; not MVP |
| Multi-user support | AIBO is a single-user personal tool |
| Commercial deployment / app store publication | Not planned |
| Smart-home integration | Not planned |
| Social media integration | Not planned |
| Real-time transit tracking | Requires verified API; not MVP |
| Automated bill payments | Not planned |
| Background push notifications / alarms | Notification reliability unresolved; deferred. MVP uses in-app "Today" summary only. |
| Live emergency location sharing | Not MVP; requires separate approval |
| Live shelter and evacuation information | Not MVP; requires separate approval |
| Emergency route guidance | Not MVP; requires separate approval |

---

## 6. Unresolved Decisions

These decisions are recorded here and must be resolved before their dependent phases begin. They are **not** pre-decided. The **Project Owner** is the decision owner for all items.

The canonical register with candidate options, evaluation criteria, and full details is maintained in [`docs/10_ROADMAP_AND_STATUS.md` §3](docs/10_ROADMAP_AND_STATUS.md).

| ID | Decision | Depends on | Target Phase | Status |
|---|---|---|---|---|
| U-1 | PWA vs. native Android app | Architecture, offline capability, installation size | Phase 02 | ⬜ Open |
| U-2 | Cloud LLM provider and verified free-tier quota | Cost constraint, AI feature | Phase 02 | ⬜ Open |
| U-3 | Hosting platform and database service | Cost constraint, data security | Phase 02 | ⬜ Open |
| U-4 | Japanese OCR approach | Accuracy, cost, offline viability | Phase 05 | ⬜ Open |
| U-5 | Voice input / STT implementation | Cost, accuracy, language support | Phase 08 | ⬜ Open |
| U-6 | Map-data licensing and offline download strategy | Licensing, storage, routing | Phase 07 | ⬜ Open |
| U-7 | Notification reliability (PWA vs. native) | Platform decision (U-1) | Phase 02 | ⬜ Open |
| U-8 | Backup and recovery strategy | Platform, data security | Phase 03 | ⬜ Open |

---

## 7. Success Criteria

The MVP is considered successful when:

1. The user can open AIBO on their Android phone without a desktop/laptop running.
2. Conversational AI responds accurately to Japan-life questions (no fabricated information).
3. Chat history can be viewed, deleted (individual or all), and managed by the user.
4. Optional long-term memory can be enabled, inspected, edited, and deleted by the user.
5. Japanese phrases can be looked up and displayed correctly, including offline.
6. Expenses can be logged, categorised, and reviewed — including while offline.
7. Important documents can be stored and retrieved on-device.
8. A "Today" summary of tasks and overdue items is shown on app open.
9. Japan emergency numbers, phrases, and a personal emergency info card are accessible offline.
10. Total monthly operating cost is ₹0.
11. Initial installation is under 200 MB (excluding optional downloads).
12. Personal data (including emergency medical info and AI memories) is stored securely and not exposed to third parties.
13. No unapproved features were implemented.

---

## Approval

- [ ] Project owner has reviewed and approved this charter.
- [ ] Unresolved decisions acknowledged.
- [ ] Ready to proceed to Phase 02 planning (pending approval).
