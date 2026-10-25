# Project AIBO — Testing and Quality Assurance Strategy

**Document status:** APPROVED — Phase 01 sign-off complete  
**Last updated:** 2026-10-25  
**Phase:** 01 — Foundation and Documentation

---

## 1. Purpose

This document defines AIBO's testing strategy, phase gate checklists, and quality validation criteria. It applies to all phases from Phase 03 onward (when implementation begins). During Phases 01 and 02, testing obligations are limited to documentation review and consistency checks.

---

## 2. Testing Principles

| Principle | Detail |
|---|---|
| **Test what matters** | Focus on user-facing behaviour and data integrity over internal implementation details. |
| **Offline first** | Every feature with offline capability must be tested in both online and offline states. |
| **No fabricated test results** | Tests must actually be run. Do not claim a test passes without executing it. |
| **Regression safety** | Changes must not break previously working features. Run the full relevant test suite before requesting approval. |
| **Honest failure reporting** | If a test fails, report it accurately. Do not silence, skip, or work around failures without documentation. |

---

## 3. Testing Levels

### 3.1 Unit Tests

- Cover individual functions, data transformations, and utility logic.
- Focus areas: expense calculations, data formatting, currency handling, date/time logic, input validation.
- Framework: TBD in Phase 02 (depends on technology selection).

### 3.2 Integration Tests

- Verify that components work together correctly.
- Focus areas: local storage ↔ UI, AI chat ↔ LLM API, data sync (when implemented).
- Must include tests for error conditions (network failure, API errors, storage full).

### 3.3 End-to-End (E2E) Tests

- Simulate real user workflows on the target device (or emulator).
- Focus areas: complete user stories from `docs/02_PRD.md`.
- Must cover critical paths: logging an expense, saving a phrase, viewing a document, sending a chat message.

### 3.4 Manual Testing

- Required for visual/UX verification, accessibility, and platform-specific behaviour.
- Document manual test results in test reports.
- Manual testing does not replace automated tests for regression coverage.

---

## 4. Validation Criteria by Category

### 4.1 Storage Validation

| Criterion | Test |
|---|---|
| SV-01 | Initial installation size is under 200 MB (excluding optional downloads). |
| SV-02 | Local data storage does not grow unbounded; reasonable limits are enforced or warned. |
| SV-03 | Data persists across app restarts. |
| SV-04 | Data is not lost during online ↔ offline transitions. |

### 4.2 Cost Validation

| Criterion | Test |
|---|---|
| CV-01 | Monthly operating cost is ₹0 under expected usage patterns. |
| CV-02 | Free-tier limits for all external services are documented with actual quotas. |
| CV-03 | The app degrades gracefully when a free-tier limit is approached or reached (no silent paid escalation). |
| CV-04 | Usage tracking / monitoring is in place to detect limit approach before hitting hard caps. |

### 4.3 Privacy Validation

| Criterion | Test |
|---|---|
| PV-01 | No personal data is sent to third parties except the cloud LLM (and only current query context). |
| PV-02 | Document vault contents are encrypted at rest. |
| PV-03 | No API keys, secrets, or tokens are present in client-side code or version control. |
| PV-04 | No analytics or telemetry is active unless explicitly enabled by the user. |
| PV-05 | App-level authentication prevents casual access to sensitive data. |
| PV-06 | Deleting a conversation or memory item permanently removes it from local storage, including any caches or derived data. |
| PV-07 | Emergency medical information (blood type, allergies, conditions, emergency contacts) is encrypted at rest and protected by app-level authentication. |

### 4.4 Accessibility Validation

| Criterion | Test |
|---|---|
| AV-01 | Text is legible at default and enlarged font sizes. |
| AV-02 | Touch targets are at least 48×48 dp. |
| AV-03 | Colour contrast meets WCAG 2.1 AA. |
| AV-04 | Basic screen-reader navigation works for primary workflows. |

### 4.5 Offline Validation

| Criterion | Test |
|---|---|
| OV-01 | Saved phrases are accessible without internet. |
| OV-02 | Expenses can be created, read, edited, and deleted offline. |
| OV-03 | Stored documents are viewable offline. |
| OV-04 | Daily planner tasks work fully offline. |
| OV-05 | Features requiring connectivity show a clear offline message (not a silent failure or fabricated response). |
| OV-06 | Data created offline is preserved and consistent when connectivity returns. |
| OV-07 | Emergency numbers, phrases, and personal emergency info card are accessible offline. |
| OV-08 | "Today" task summary (including overdue items) displays correctly when offline. |

### 4.6 Reliability Validation

| Criterion | Test |
|---|---|
| RV-01 | App does not crash during normal use (tested on target device/emulator). |
| RV-02 | Network errors produce user-visible error messages (never silent failures). |
| RV-03 | Interrupted operations (e.g. killed mid-save) do not corrupt data. |

### 4.7 Performance Validation

| Criterion | Test |
|---|---|
| PFV-01 | App loads to interactive state within 3 seconds on a mid-range Android device. |
| PFV-02 | Offline features load within 2 seconds from local storage. |
| PFV-03 | AI chat responses return within 10 seconds on a stable connection. |

---

## 5. Phase Gate Checklist

Before requesting owner approval to close any phase, the following checklist must be completed:

### General Phase Gate (Phases 03–12)

- [ ] All features planned for this phase are implemented and functional.
- [ ] All relevant unit, integration, and E2E tests pass.
- [ ] No known regressions in previously approved features.
- [ ] Offline validation criteria (§4.5) pass for all applicable features.
- [ ] Privacy validation criteria (§4.3) pass.
- [ ] Storage validation criteria (§4.1) pass.
- [ ] Cost validation criteria (§4.2) pass (no paid services without approval).
- [ ] Accessibility validation criteria (§4.4) pass at the level appropriate for the phase.
- [ ] Documentation is up to date (PRD, roadmap, ADRs).
- [ ] Roadmap status (`docs/05_ROADMAP_AND_STATUS.md`) updated.
- [ ] Completion report submitted to project owner.
- [ ] No unapproved features or out-of-scope changes.

### Phase 01 Gate (Documentation Only)

- [ ] All five core documents created and internally consistent.
- [ ] Unresolved decisions listed with target phases.
- [ ] No application code, packages, databases, APIs, or deployments created.
- [ ] Project owner has reviewed all documents.

### Phase 02 Gate (Architecture)

- [ ] All Phase 02 unresolved decisions resolved with ADRs.
- [ ] Free-tier limits verified (not just claimed) for all selected services.
- [ ] Total projected cost confirmed as ₹0/month.
- [ ] Installation size budget allocated.
- [ ] Development environment setup documented and tested.

---

## 6. Test Reporting

Each phase completion report must include:

| Section | Content |
|---|---|
| **Tests run** | List of test suites executed, with pass/fail counts. |
| **Failures** | Description of any failures, root cause (if known), and remediation. |
| **Manual test results** | Summary of manual tests performed and outcomes. |
| **Coverage gaps** | Known areas not covered by tests, with rationale. |
| **Validation checklist** | Completed checklist from §5. |

---

## 7. Regression Testing

| Rule | Detail |
|---|---|
| RT-01 | When a bug is fixed, add a test that reproduces the bug to prevent regression. |
| RT-02 | Before each phase gate, run all existing tests (not just new ones). |
| RT-03 | If a regression is found, it must be fixed before the phase can be approved. |

---

## 8. Technology-Specific Testing Details

Testing framework, tooling, and device-specific testing procedures will be defined in Phase 02 after the architecture decisions are made. This section will be updated at that time.

**Placeholder decisions for Phase 02:**
- Test framework (Jest, Vitest, Playwright, Detox, etc.)
- Device testing approach (physical device, emulator, BrowserStack, etc.)
- CI/CD integration for automated tests
- Code coverage targets (if any)

---

## Approval

- [x] Project owner has reviewed and approved this testing strategy.
