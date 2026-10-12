# Project AIBO — Agent Rules

**Document status:** DRAFT — awaiting owner approval  
**Last updated:** 2026-10-13  
**Phase:** 01 — Foundation and Documentation  
**Audience:** Any AI agent or human contributor working on Project AIBO

---

## Purpose

This document defines mandatory rules that govern all agent (AI-assisted) work on Project AIBO. These rules exist to prevent scope creep, data loss, cost overruns, and unapproved changes. Violations are treated as bugs.

---

## 1. Read Before Edit

| Rule | Detail |
|---|---|
| **R-1.1** | Before modifying any file, read its current contents and the contents of related documentation. |
| **R-1.2** | Before starting work on any phase, read: `docs/00_PROJECT_CHARTER.md`, `docs/01_PRD.md`, `docs/AGENT_RULES.md`, `docs/10_ROADMAP_AND_STATUS.md`, and `docs/08_TESTING_AND_QA.md`. |
| **R-1.3** | Check `git status` and `git diff` before making changes to understand the current state of the repository. |
| **R-1.4** | If a build guide or supplementary instructions exist (e.g. `project-aibo-build-guide.md`), read them before beginning implementation work. |

---

## 2. No Unapproved Features or Destructive Changes

| Rule | Detail |
|---|---|
| **R-2.1** | Do not implement features not listed in the approved scope for the current phase. |
| **R-2.2** | Do not add dependencies, services, or integrations that have not been approved. |
| **R-2.3** | Do not delete, overwrite, or substantially restructure existing files without explicit owner approval. |
| **R-2.4** | Do not silently change product scope, rename agreed features, or promote suggestions to requirements. |
| **R-2.5** | If a potentially useful feature or improvement is identified during work, document it as a suggestion in the relevant document and flag it for owner review. Do not implement it. |

---

## 3. Phase Boundaries and Approval Gates

| Rule | Detail |
|---|---|
| **R-3.1** | Work must remain within the boundaries of the currently approved phase. |
| **R-3.2** | Do not begin the next phase until the current phase has been explicitly approved as complete by the project owner. |
| **R-3.3** | Each phase completion requires a report listing: files changed, requirements met, tests passed, unresolved issues, and a confirmation that no out-of-scope work was performed. |
| **R-3.4** | Phase exit criteria are defined in `docs/10_ROADMAP_AND_STATUS.md`. All exit criteria must be met before requesting approval. |

---

## 4. Testing and Documentation Obligations

| Rule | Detail |
|---|---|
| **R-4.1** | Every implemented feature must have corresponding tests as defined in `docs/08_TESTING_AND_QA.md`. |
| **R-4.2** | Documentation must be updated before or alongside code changes, never deferred. |
| **R-4.3** | The roadmap (`docs/10_ROADMAP_AND_STATUS.md`) must be updated to reflect current status after each significant change. |
| **R-4.4** | Architecture Decision Records (ADRs) must be written for any non-trivial technology choice (format TBD in Phase 02). |

---

## 5. Free-Tier and Cost Restrictions

| Rule | Detail |
|---|---|
| **R-5.1** | Target monthly operating cost is ₹0. No paid service may be adopted without explicit owner approval. |
| **R-5.2** | Before using any external service, document its free-tier limits, rate limits, and what happens when the limit is exceeded. |
| **R-5.3** | Never configure automatic fallback to a paid tier. If a free-tier limit is reached, the system must degrade gracefully (reduced functionality, clear user message) rather than incur cost. |
| **R-5.4** | Do not trust marketing claims about "free forever" or "generous free tier." Verify with actual documentation or testing. Record the verification date. |
| **R-5.5** | Listing a service in a planning document does not constitute verification or approval. Verification requires actual testing or confirmed documentation review. |

---

## 6. Security and Privacy Rules

| Rule | Detail |
|---|---|
| **R-6.1** | Never commit API keys, secrets, tokens, or credentials to version control. |
| **R-6.2** | Never embed secrets in client-side code. |
| **R-6.3** | Personal data (documents, financial records, chat history, emergency medical information) must be stored securely. Encryption at rest is required for the document vault and emergency medical information. |
| **R-6.4** | Minimise data sent to external services. Only send what is necessary for the specific function (e.g. current chat query and user-approved memory to LLM, never the full document vault, financial history, or emergency medical info by default). |
| **R-6.5** | No analytics, telemetry, or tracking unless the owner explicitly enables it. |
| **R-6.6** | Handle all user data under the assumption that it contains sensitive personal information. |

---

## 7. Honest Reporting of Failures and Limitations

| Rule | Detail |
|---|---|
| **R-7.1** | Never fabricate prices, train schedules, official procedures, or API response data. |
| **R-7.2** | If a feature does not work, report it as broken. Do not present partial success as full success. |
| **R-7.3** | If an external service is down or a free-tier limit is reached, display a clear, honest error message to the user. |
| **R-7.4** | If a task cannot be completed within the current constraints, report what was achieved, what failed, and what is needed — rather than working around the limitation silently. |
| **R-7.5** | Test results must be reported accurately. Do not claim tests pass without actually running them. |
| **R-7.6** | If the agent is uncertain whether a change is safe or in-scope, it must ask the owner rather than proceed. |

---

## 8. Implementation Boundaries (Phase-Specific)

During **Phase 01 (Foundation and Documentation)**, the following actions are explicitly prohibited:

- Creating application source code or UI components
- Installing packages or dependencies
- Initialising or modifying application frameworks
- Creating databases or connecting to external services
- Adding API keys, secrets, or credentials
- Deploying anything
- Beginning Phase 02 or any later work

Permitted actions during Phase 01:

- Creating and editing the five core documentation files
- Initialising the Git repository
- Creating a `.gitignore` and `README.md`
- Inspecting the file system and Git state

---

## 9. Conflict Resolution

If these rules conflict with an instruction from the project owner:

1. The owner's explicit instruction takes precedence.
2. Document the exception in the relevant file.
3. Do not extend the exception beyond its stated scope.

If these rules conflict with each other, flag the conflict and ask the owner for guidance.

---

## Approval

- [ ] Project owner has reviewed and approved these agent rules.
