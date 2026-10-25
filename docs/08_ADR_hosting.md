# Architecture Decision Record: ADR-003

## Hosting Platform and Database Service Selection

| Field | Value |
|---|---|
| **ADR ID** | ADR-003 |
| **Decision ID** | U-3 |
| **Title** | Hosting Platform and Database Service Selection |
| **Status** | ✅ **Approved** |
| **Date** | 2026-10-25 |
| **Decision Owner** | Project Owner |
| **Target Phase** | Phase 02 (Architecture & Technology Selection) |
| **Supersedes** | N/A |
| **Superseded By** | N/A |

---

## 1. Context and Problem Statement

Project AIBO requires an application delivery mechanism and a data persistence strategy for a single-user personal companion running on an Android smartphone in Japan.

Key constraints and requirements:
1. **₹0/month operating cost (Hard Constraint):** Zero hosting or database recurring bills.
2. **Absolute data privacy (P0, NFR-P-02):** The app stores highly sensitive personal information, including Japan residence card scans, emergency medical data, daily personal expenses, and schedules.
3. **100% deterministic offline operation (Hard Constraint):** All personal data must be readable and writable with zero latency, even in areas with poor or no cellular reception (e.g. subway tunnels, rural areas, or during disaster network outages).
4. **Maintenance overhead:** As a personal project, zero backend maintenance (database migrations, server patching, auto-pause monitoring) is strongly preferred.

---

## 2. Options Evaluated

### Option A: Firebase (Cloud Firestore + Firebase Hosting)
- **Description:** Google Cloud managed NoSQL database with offline synchronization SDK.
- **Pros:** Free Spark plan (1 GB storage, 50k reads/day); automatic client SDK offline cache.
- **Cons:** Proprietary NoSQL document model; daily quota cutoffs; sensitive vault documents would reside on Google Cloud servers unless encrypted client-side; unnecessary complexity for a single user on one device.
- **Verdict:** Rejected for MVP.

### Option B: Supabase (Managed PostgreSQL)
- **Description:** Open-source Firebase alternative providing managed PostgreSQL with Row-Level Security.
- **Pros:** Standard relational SQL; open-source.
- **Cons:** **Fatal friction flaw:** Free-tier Supabase projects are automatically paused after 7 days of inactivity, breaking the companion unexpectedly unless manually resumed via a web console. Additionally, Supabase mobile SDK lacks automatic offline write queuing.
- **Verdict:** Disqualified due to the 7-day auto-pause policy.

### Option C: GitHub Releases Distribution + 100% Local Encrypted SQLite (Selected)
- **Description:** The Flutter Android application is packaged as a standalone release APK hosted on GitHub Releases (public repository, unlimited free bandwidth) or sideloaded directly via USB. 100% of user data resides strictly on the local device within an AES-256 encrypted SQLite database (`sqflite` + `sqflite_sqlcipher`).
- **Pros:**
  - **Zero infrastructure to manage:** No cloud database, no servers, no API tokens, no monthly quotas, no risk of auto-pause.
  - **Maximum privacy:** Personal data, Japan Residence Card scans, expenses, and notes never touch any cloud server.
  - **100% deterministic offline reliability:** Instant read/write access with zero latency and zero dependency on network state.
  - **Cost:** Exactly ₹0/month permanently.
- **Cons:**
  - No automated real-time cross-device synchronization (addressed via manual encrypted backup in U-8).
- **Verdict:** **Selected.**

---

## 3. Decision

1. **Application Delivery:** AIBO will be distributed as an Android APK compiled via Flutter, distributed and updated via **GitHub Releases** (and local USB sideloading during development). No paid app store or web hosting infrastructure is required.
2. **Data Persistence:** 100% of application state and user records will be persisted locally on the Android device using **SQLite encrypted with AES-256** via `sqflite` and `sqflite_sqlcipher`.

---

## 4. Structured Comparison

| Criterion | Option A: Firebase | Option B: Supabase | Option C: Local SQLite + GitHub Releases (Selected) |
|---|---|---|---|
| **Monthly Cost** | ₹0 (within quotas) | ₹0 (free tier) | **₹0 permanently (zero cloud infra)** |
| **Privacy Attack Surface** | Cloud-hosted | Cloud-hosted | **Zero cloud exposure (100% on device)** |
| **Offline Reliability** | Cache-based SDK | Requires custom sync | **100% deterministic native SQLite** |
| **Operational Overhead** | Low | High (7-day pause) | **Zero maintenance** |
| **Installation Delivery** | Web / PWA host | Web / PWA host | **Direct Android APK via GitHub Releases** |

---

## 5. Technical Implementation Details for Phase 03

1. **Database Library:** `sqflite` with `sqflite_sqlcipher` (SQLCipher 4.x, AES-256 CBC encryption).
2. **Key Derivation:** Master database key generated via PBKDF2 (SHA-256) and secured in the Android Keystore using `flutter_secure_storage`.
3. **Database Schema:** Standard relational tables for:
   - `tasks` (id, title, due_date, priority, status, category, created_at)
   - `expenses` (id, amount_jpy, category, note, timestamp)
   - `chat_history` (id, session_id, role, content, timestamp)
   - `document_vault` (id, doc_type, file_path_encrypted, notes, updated_at)
   - `emergency_card` (id, full_name, blood_type, emergency_contact, medical_notes)
4. **App Distribution Workflow:**
   - GitHub Actions CI (free tier: 2,000 min/month) builds release APK on git tags.
   - APK attached as GitHub Release asset for one-tap direct download and install.

---

## 6. Approval Sign-Off

- **Decision Owner:** Project Owner
- **Decision:** **Option C (GitHub Releases APK Distribution + 100% Local Encrypted SQLite)**
- **Status:** **APPROVED & CLOSED**
- **Date:** 2026-10-25
