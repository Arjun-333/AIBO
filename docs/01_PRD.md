# Project AIBO — Product Requirements Document (PRD)

**Document status:** DRAFT — awaiting owner approval  
**Last updated:** 2026-10-13  
**Phase:** 01 — Foundation and Documentation  
**Companion documents:** `00_PROJECT_CHARTER.md`, `AGENT_RULES.md`, `10_ROADMAP_AND_STATUS.md`

---

## 1. Overview

This PRD defines the functional and non-functional requirements for AIBO's MVP release, organised by feature area. Each requirement includes user stories, acceptance criteria, and explicit online/offline behaviour.

Requirements are classified as:

| Priority | Meaning |
|---|---|
| **MVP** | Must be delivered in the first usable release |
| **Later** | Planned for a specific post-MVP phase |
| **Optional** | Desirable but not committed; requires separate approval |

---

## 2. Functional Requirements — MVP Features

### 2.1 Conversational AI Assistant

**Description:** A chat interface where the user can ask questions and receive AI-generated responses, powered by a cloud LLM.

**User Stories:**

| ID | Story | Acceptance Criteria |
|---|---|---|
| US-AI-01 | As the user, I want to ask AIBO a question in English and get a helpful response. | Response is returned within reasonable latency (<10 s on stable connection). Response is relevant to the query. |
| US-AI-02 | As the user, I want AIBO to help me with Japan-specific questions (e.g. how to pay utility bills, what a municipal letter says). | Response references Japan-relevant context. No fabricated official procedures or prices. |
| US-AI-03 | As the user, I want to see my recent chat history when I reopen the app. | At least the last 50 messages are persisted locally and displayed on app open. |
| US-AI-04 | As the user, I want a clear indication when AIBO cannot answer (rather than a fabricated answer). | The system displays an explicit "I'm not sure" or equivalent rather than guessing factual data. |
| US-AI-05 | As the user, I want to delete individual conversations from my chat history. | Selected conversation is permanently removed from local storage. Remaining history is unaffected. |
| US-AI-06 | As the user, I want to clear all chat history at once. | All conversations are permanently removed from local storage. Confirmation prompt is shown before deletion. |
| US-AI-07 | As the user, I want to opt in to long-term memory so AIBO remembers my preferences and context across sessions. | Long-term memory is off by default. When enabled, saved items are listed in a dedicated screen. Only user-approved items are retained. |
| US-AI-08 | As the user, I want to inspect, edit, and delete individual saved memories. | All saved memory items are viewable in a dedicated screen. Each item can be edited or deleted. Deletion is permanent. |
| US-AI-09 | As the user, I want to know when local chat storage is approaching its limit. | A clear warning is shown when storage usage reaches a defined threshold. The user can delete old conversations to free space. |

**Online / Offline Behaviour:**

| State | Behaviour |
|---|---|
| Online | Full LLM-powered responses. Long-term memory sync if cloud backup exists (later phase). |
| Offline | Chat history and saved memories viewable. Memory inspection, editing, and deletion work offline. New AI queries display a clear "offline — cannot reach AI" message. No cached/stale AI responses are presented as live answers. |

**Open Questions:**
- LLM provider and free-tier quota (Unresolved Decision U-2)
- Maximum context window / conversation length to stay within free tier
- Long-term memory implementation approach (storage mechanism TBD in Phase 02/03)
- Storage limits for chat history and saved memories (specific values TBD in Phase 02)
- Types of data eligible for long-term memory (preferences, context, learned facts — boundaries TBD)
- Deletion guarantees for conversations and memories: policy for caches or derived data (TBD in Phase 02)
- Data minimisation: the full document vault, financial history, and emergency medical info must never be sent to the LLM by default

---

### 2.2 Japanese Language Support

**Description:** Lookup and display Japanese phrases with readings (furigana), meanings, and example usage. An offline phrase book of saved/bookmarked entries.

**User Stories:**

| ID | Story | Acceptance Criteria |
|---|---|---|
| US-JP-01 | As the user, I want to search for an English word or phrase and see its Japanese translation. | Translation is displayed with kanji, hiragana/katakana reading, and English meaning. |
| US-JP-02 | As the user, I want to see furigana (reading aids) above kanji. | Furigana is rendered correctly using ruby text or equivalent. |
| US-JP-03 | As the user, I want to save phrases to a personal phrase book for offline access. | Saved phrases persist locally. Accessible without internet. |
| US-JP-04 | As the user, I want to browse my saved phrase book when offline. | Phrase book loads fully from local storage. |

**Online / Offline Behaviour:**

| State | Behaviour |
|---|---|
| Online | Live translation via AI or dictionary API. Save to local phrase book. |
| Offline | Phrase book fully accessible. New translations unavailable; clear message shown. |

**Open Questions:**
- Dictionary data source (free API vs. bundled dictionary vs. LLM translation)
- Furigana rendering approach (ruby HTML, custom component, or library)

---

### 2.3 Expense Tracker

**Description:** Log daily expenses in JPY (¥) and INR (₹), categorise them, and review spending history.

**User Stories:**

| ID | Story | Acceptance Criteria |
|---|---|---|
| US-EX-01 | As the user, I want to log an expense with amount, currency (¥ or ₹), category, and optional note. | Expense is saved with timestamp. Entry appears in history immediately. |
| US-EX-02 | As the user, I want to view my expense history filtered by date range and category. | Filter controls work. Results are accurate. |
| US-EX-03 | As the user, I want to log expenses while offline and have them preserved. | Expenses logged offline are stored locally and persist across app restarts. |
| US-EX-04 | As the user, I want to see a simple summary of spending (e.g. total this month by category). | Summary is calculated from local data. Displays correctly. |
| US-EX-05 | As the user, I want to edit or delete a previously logged expense. | Edited/deleted entries update immediately in history and summaries. |

**Online / Offline Behaviour:**

| State | Behaviour |
|---|---|
| Online | Full functionality. If cloud sync exists, sync occurs. |
| Offline | Full expense logging, viewing, editing, and deletion from local storage. |

**Open Questions:**
- Currency conversion: live rate vs. manual entry vs. no conversion in MVP
- Data export format (CSV, JSON) — MVP or later?

---

### 2.4 Document Vault

**Description:** Store photos or scans of important personal documents (residence card, health insurance card, bank documents, etc.) securely on-device for quick reference.

**User Stories:**

| ID | Story | Acceptance Criteria |
|---|---|---|
| US-DOC-01 | As the user, I want to photograph or upload a document and save it with a label and category. | Document is stored locally with metadata (label, category, date). |
| US-DOC-02 | As the user, I want to browse and view my stored documents. | Documents are listed by category. Full-resolution image viewable. |
| US-DOC-03 | As the user, I want my documents to be accessible offline. | All stored documents load from local storage without internet. |
| US-DOC-04 | As the user, I want my documents to be protected from casual access. | App-level authentication (PIN, biometric, or device lock) before viewing documents. Requirement details TBD in Phase 02. |

**Online / Offline Behaviour:**

| State | Behaviour |
|---|---|
| Online | Full functionality. Optional cloud backup (if implemented in later phase). |
| Offline | Full functionality. All documents stored and served locally. |

**Open Questions:**
- Storage format (encrypted local files, IndexedDB, device filesystem)
- Maximum storage recommendation to stay within installation-size constraint
- Authentication mechanism (platform-dependent; ties to U-1 PWA vs. native decision)

---

### 2.5 Offline Essentials

**Description:** Core data that must be available without internet — saved phrases, logged expenses, and stored documents.

This is not a separate feature but a cross-cutting requirement that applies to §2.2, §2.3, §2.4, §2.6, and §2.7. It is listed here to make the offline contract explicit.

**Acceptance Criteria:**

| Criterion | Detail |
|---|---|
| OE-01 | All saved phrases are readable offline. |
| OE-02 | All logged expenses are readable, editable, and new entries can be created offline. |
| OE-03 | All stored documents are viewable offline. |
| OE-04 | The app clearly indicates when a feature requires connectivity. |
| OE-05 | No data is lost when transitioning between online and offline states. |
| OE-06 | Emergency numbers, phrases, and personal emergency info card are accessible offline. |

---

### 2.6 Basic Daily Planner

**Description:** A simple task/reminder list for daily planning.

**User Stories:**

| ID | Story | Acceptance Criteria |
|---|---|---|
| US-PL-01 | As the user, I want to create a task with a title and optional due date. | Task is saved locally and appears in the task list. |
| US-PL-02 | As the user, I want to mark tasks as complete. | Completed tasks are visually distinguished. |
| US-PL-03 | As the user, I want to view today's tasks and upcoming tasks. | Tasks are grouped/sorted by date. |
| US-PL-04 | As the user, I want to edit or delete tasks. | Changes are reflected immediately. |
| US-PL-05 | As the user, I want my tasks to be available offline. | Full CRUD operations on tasks work without internet. |
| US-PL-06 | As the user, I want to see a "Today" summary when I open AIBO, showing today's tasks and any overdue items. | On app open, a summary screen or section displays today's tasks, overdue tasks, and upcoming tasks. Works offline from local storage. |

**Online / Offline Behaviour:**

| State | Behaviour |
|---|---|
| Online | Full functionality. Sync if cloud storage is available. |
| Offline | Full functionality from local storage, including "Today" summary. |

**Open Questions:**
- Background push notifications and alarms — deferred to post-MVP, dependent on platform evaluation and reliability testing (U-7). MVP reminders are limited to the in-app "Today" summary shown on app open.
- Time zone handling (JST primary, IST for reference?)

---

### 2.7 Basic Offline Emergency Support

**Description:** A dedicated offline-accessible screen providing essential emergency information for living in Japan.

**User Stories:**

| ID | Story | Acceptance Criteria |
|---|---|---|
| US-EM-01 | As the user, I want to view Japan emergency contact numbers (police 110, fire/ambulance 119, coast guard 118) without internet. | Numbers are correctly labelled, verified before release, and accessible offline. One-tap dial where the platform supports it. |
| US-EM-02 | As the user, I want to see essential Japanese emergency phrases with English meanings. | At least 10 core phrases covering medical, police, fire, and general help situations. Accessible offline. |
| US-EM-03 | As the user, I want to create and edit a personal emergency information card (emergency contacts, blood type, allergies, medical conditions, insurance info). | Card is editable, stored locally, and accessible offline. |
| US-EM-04 | As the user, I want my emergency medical information protected with the same privacy controls as the document vault. | Emergency info card requires app-level authentication. Encrypted at rest. |
| US-EM-05 | As the user, I want AIBO to never falsely claim it has called emergency services, shared my location, or verified a route to safety. | No UI element or message implies autonomous emergency action that has not actually occurred. |

**Online / Offline Behaviour:**

| State | Behaviour |
|---|---|
| Online | Full functionality. |
| Offline | Full functionality. All emergency numbers, phrases, and personal info card are served from local storage. |

**Open Questions:**
- One-tap dial capability (platform-dependent; ties to U-1 PWA vs. native decision)
- Phrase list curation and verification process before release
- Whether the emergency info card should be accessible without full app authentication in genuine emergencies (quick-access vs. privacy trade-off — requires owner decision)

---

## 3. Functional Requirements — Later Phases

These features are planned but **not approved for implementation** until their respective phase is reached. They are listed here for traceability.

| Feature | Target Phase | Notes |
|---|---|---|
| Offline maps with routing | Phase 07 | Blocked by U-6 (map-data licensing) |
| Japanese OCR (text extraction from images) | Phase 05 | Blocked by U-4 |
| Voice input / speech-to-text | Phase 08 | Blocked by U-5 |
| Transit / train information | Phase 09 | Requires verified, free API; no fabrication |
| Cloud sync and backup | Phase 03 | Blocked by U-3, U-8 |
| On-device AI | Phase 10+ | Optional future upgrade |

---

## 4. Functional Requirements — Optional / Unplanned

These features have been discussed but are **not committed** to any phase. They require separate approval.

- Multi-language UI (beyond English + Japanese)
- Smart-home integration
- Social features
- Automated financial categorisation via AI
- Shared expense splitting
- Live emergency location sharing
- Live shelter and evacuation information
- Emergency route guidance

---

## 5. Non-Functional Requirements

### 5.1 Privacy and Data Security

| ID | Requirement |
|---|---|
| NFR-P-01 | Personal data (documents, expenses, chat history) must be stored securely on-device. Encryption at rest is required for the document vault. |
| NFR-P-02 | No personal data is sent to third-party services except the cloud LLM for chat queries (and only the current query context, not the full vault). |
| NFR-P-03 | No analytics, telemetry, or tracking beyond what the user explicitly enables. |
| NFR-P-04 | API keys and secrets must never be committed to version control or embedded in client-side code. |
| NFR-P-05 | Chat history and long-term memory data must follow the same secure storage standards as other personal data. Deletion of a conversation or memory item must be permanent and complete, including any local caches or derived data. |
| NFR-P-06 | The full document vault, financial history, and emergency medical information must never be sent to the LLM by default. Only the current query context and explicitly user-approved memory items may be included in LLM requests. |
| NFR-P-07 | Emergency medical information (blood type, allergies, conditions, emergency contacts) must be encrypted at rest and protected by app-level authentication, equivalent to document vault privacy. |

### 5.2 Accessibility

| ID | Requirement |
|---|---|
| NFR-A-01 | Text must be legible at default and enlarged font sizes. |
| NFR-A-02 | Interactive elements must have sufficient touch-target size (minimum 48×48 dp). |
| NFR-A-03 | Colour contrast must meet WCAG 2.1 AA for text. |
| NFR-A-04 | Screen-reader compatibility is a goal, with basic ARIA/semantic markup in MVP and progressive improvement in later phases. |

### 5.3 Reliability

| ID | Requirement |
|---|---|
| NFR-R-01 | The app must not crash or lose data during normal use. |
| NFR-R-02 | Offline-to-online transitions must not cause data corruption or duplication. |
| NFR-R-03 | Failed network requests must be handled gracefully with user-visible error messages (never silent failures or fabricated success responses). |

### 5.4 Performance

| ID | Requirement |
|---|---|
| NFR-PF-01 | App must load to interactive state within 3 seconds on a mid-range Android device over a stable connection. |
| NFR-PF-02 | Offline features must load within 2 seconds from local storage. |
| NFR-PF-03 | Initial installation size must be under 200 MB (excluding optional map packs and AI models). |

### 5.5 Cost

| ID | Requirement |
|---|---|
| NFR-C-01 | Monthly operating cost must be ₹0. No paid services without explicit owner approval. |
| NFR-C-02 | Every external service must have its free-tier limits documented before adoption. |
| NFR-C-03 | The system must degrade gracefully (not break) if a free-tier limit is reached. |

---

## 6. Boundaries and Honest Reporting

| Rule | Detail |
|---|---|
| No fabrication | Prices, schedules, official procedures, and API success statuses must never be invented. |
| Verified vs. planned | This document distinguishes between verified functionality and future plans. Features marked "Later" or "Optional" are not commitments. |
| Service verification | No external service is considered "verified" until its free tier is tested with AIBO's actual usage patterns. Listing a service here does not constitute verification. |

---

## Approval

- [ ] Project owner has reviewed and approved MVP scope.
- [ ] Open questions acknowledged.
- [ ] Ready for Phase 02 architecture planning (pending approval).
