# Architecture Decision Record: ADR-005

## Backup and Recovery Strategy

| Field | Value |
|---|---|
| **ADR ID** | ADR-005 |
| **Decision ID** | U-8 |
| **Title** | Backup and Recovery Strategy for Local-First Data |
| **Status** | ✅ **Approved** |
| **Date** | 2026-10-25 |
| **Decision Owner** | Project Owner |
| **Target Phase** | Phase 02 (Architecture & Technology Selection) / Phase 03 Implementation |
| **Supersedes** | N/A |
| **Superseded By** | N/A |

---

## 1. Context and Problem Statement

Project AIBO stores all user data locally on an Android smartphone in an encrypted SQLite database and private document directory (U-3). If the user loses their phone, damages it, or switches to a new device, a deterministic backup and recovery process must exist to prevent permanent data loss.

Constraints and considerations:
1. **₹0/month cost (Hard Constraint):** No paid backup server or subscription cloud bucket.
2. **Data security & privacy (P0, NFR-P-02):** The backup file contains residence card scans, emergency info, notes, and financial logs. Any exported backup must be encrypted at rest using industry-standard cryptography (AES-256).
3. **No cloud dependency for MVP:** Must work without standing cloud infrastructure or complex two-way synchronization engines.

---

## 2. Options Evaluated

### Option A: Automated Real-Time Cloud Sync
- **Description:** Real-time multi-device database sync to Firebase or Supabase.
- **Flaws:** Complex two-way conflict resolution; client-side encryption severely complicates querying and syncing; risk of cloud quota exhaustion; Supabase 7-day auto-pause risk.
- **Verdict:** Deferred to post-MVP future enhancements.

### Option B: Android OS Auto-Backup (Google Drive App Data)
- **Description:** Standard Android framework backup to user's Google Drive.
- **Flaws:** Android enforces a strict **25 MB limit** per app. Document vault photos will quickly exceed this limit, causing backups to silently fail.
- **Verdict:** Unreliable for vault photos.

### Option C: Manual Encrypted Export / Import (Selected MVP Baseline)
- **Description:** In-app feature where the user taps "Export Backup", sets or confirms a passphrase, and receives an AES-256 encrypted archive (`aibo_backup_YYYYMMDD_HHMM.enc`) containing the SQLite database dump and vault images.
- **Pros:**
  - 100% serverless, zero infrastructure, ₹0 permanently.
  - Zero cloud attack surface: The user controls where to save or share the file (Google Drive, USB OTG, local Downloads, or Telegram Saved Messages).
  - Works on Day 1 with deterministic import/recovery.
- **Cons:** Relies on the user performing periodic manual exports.
- **Verdict:** **Selected as Primary MVP Recovery Mechanism.**

---

## 3. Decision

**AIBO adopts Option D (Hybrid: Manual Encrypted Export/Import for MVP → Optional Cloud Sync in Future Phases):**

1. **MVP Implementation (Phase 03):**
   - **Export:** One-tap export generates an AES-256-GCM encrypted ZIP archive combining the SQLite database file and document vault image assets.
   - **Key Derivation:** Argon2id / PBKDF2 (SHA-256) key derivation from user master password with random salt.
   - **Android Sharing:** Triggers Android system share sheet (`share_plus`), allowing the user to seamlessly save the encrypted archive to Google Drive, local storage, or personal cloud storage.
   - **Import / Restore:** "Restore from Backup" screen allows selecting a `.enc` file, entering the passphrase, verifying archive checksum, and restoring the database and vault on any Android phone running AIBO.
2. **Post-MVP Phases:** Optional automated backup to personal Google Drive (via Google Drive REST API using the user's personal free 15 GB Drive storage) can be introduced once core features stabilize.

---

## 4. Structured Comparison

| Criterion | Option A: Real-Time Cloud Sync | Option B: Android OS Auto-Backup | Option C / D: Manual Encrypted Export (Selected) |
|---|---|---|---|
| **Cost** | ₹0 only within quotas | ₹0 | **₹0 permanently** |
| **Size Limitation** | Free-tier storage caps | **25 MB hard cap (fails vault)** | **Unlimited (phone storage dependent)** |
| **Encryption** | Complex to sync encrypted rows | Unencrypted by app (Google-managed) | **AES-256-GCM user-passphrase encrypted** |
| **Recovery Speed** | Instant | Automatic on reinstall | **Simple 1-step file import** |
| **Implementation Complexity** | High | Low | **Low–Medium (deterministic)** |

---

## 5. Technical Implementation Details for Phase 03

1. **Encryption Scheme:**
   - Cipher: AES-256-GCM (authenticated encryption to detect tampering).
   - Key Derivation: PBKDF2 with 100,000 iterations and 16-byte random salt.
2. **Archive Structure:**
   ```
   aibo_backup_20261025.enc (Encrypted container)
   └── Contents:
       ├── database.sqlite (Database dump)
       ├── manifest.json (Schema version, timestamp, checksum)
       └── vault/ (Encrypted photo assets)
   ```
3. **Flutter Packages:**
   - `archive` (Zip packaging)
   - `cryptography` or `encrypt` (AES-256 GCM)
   - `file_picker` (Selecting backup file for restore)
   - `share_plus` (Exporting via Android share sheet)

---

## 6. Approval Sign-Off

- **Decision Owner:** Project Owner
- **Decision:** **Option D (Manual Encrypted Export/Import for MVP, Hybrid Future Cloud Sync)**
- **Status:** **APPROVED & CLOSED**
- **Date:** 2026-10-25
