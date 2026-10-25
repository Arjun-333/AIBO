# Architecture Decision Record: ADR-001

## Mobile Application Platform Selection

| Field | Value |
|---|---|
| **ADR ID** | ADR-001 |
| **Decision ID** | U-1 |
| **Title** | Mobile Application Platform Selection for Project AIBO |
| **Status** | ✅ **Approved** |
| **Date** | 2026-10-25 |
| **Decision Owner** | Project Owner |
| **Target Phase** | Phase 02 (Architecture & Technology Selection) |
| **Supersedes** | N/A |
| **Superseded By** | N/A |

---

## 1. Context and Problem Statement

Project AIBO is a personal AI companion application designed for a single user living in Japan. The application must run on an Android smartphone as a primary daily tool without requiring a running desktop or server.

The core constraints and requirements governing this decision:
1. **₹0/month operating cost (Hard Constraint):** All tools, runtimes, and local execution frameworks must be free and open-source with no licensing or subscription fees.
2. **Initial install size < 200 MB (Hard Constraint):** Base application package must comfortably stay well within budget.
3. **Deterministic offline execution (Hard Constraint):** Core life organizer features (tasks, schedule, notes, document vault, emergency card, Japanese phrasebook) must work 100% offline.
4. **Reliable offline reminders (P0):** Scheduled alarms and reminders must fire accurately even when the device is in deep sleep (Doze mode), offline, or after app termination.
5. **Local data security (P0):** Data (including identity documents in the vault) must be encrypted on-device (AES-256) and protected by biometrics (fingerprint/face).
6. **Hardware integrations:** Direct camera access for OCR/document scanning, local biometric authentication (`BiometricPrompt`), and one-tap emergency calling (`Intent.ACTION_DIAL`).
7. **Single-maintainer velocity:** Fast UI development, hot reload, and clean state management.

---

## 2. Options Considered

### Option A: Progressive Web App (PWA)
- **Description:** Web application built with HTML/CSS/JS, running in Chromium sandbox.
- **Pros:** Instant browser preview, smallest initial footprint (<10 MB), easiest zero-setup deployment.
- **Cons:** **Fatal flaw for AIBO** — PWAs cannot schedule exact local background alarms without an active internet connection and push notification server. Service workers are suspended by Android battery optimization. Eviction risk under disk pressure for IndexedDB.
- **Outcome:** **Rejected.** Unsuitable for offline-first reminders and tamper-resistant local vault.

### Option B: Native Android (Kotlin + Jetpack Compose)
- **Description:** Official native Android app using Kotlin, Jetpack Compose, Room (with SQLCipher), and AndroidX libraries.
- **Pros:** Maximum access to Android platform APIs (`AlarmManager`, `WorkManager`, `BiometricPrompt`, `CameraX`). Smallest binary footprint (~5–10 MB). Zero abstraction overhead.
- **Cons:** Slower single-developer iteration speed compared to declarative cross-platform UI with hot reload. More boilerplate code required for complex UI layouts and state flows.
- **Outcome:** **Strong contender, but superseded by Flutter** on development velocity and unified UI ecosystem.

### Option C: Hybrid App (Capacitor / Ionic + Web Frontend)
- **Description:** Web frontend running inside a native WebView wrapper compiled into an APK with Capacitor plugins.
- **Pros:** Uses web stack; native plugins bridge to Android APIs.
- **Cons:** WebView rendering bridge introduces performance overhead. Relies on a patchwork of third-party plugins for SQLite, alarms, and biometrics that frequently suffer from bitrot or breaking changes across Android OS updates.
- **Outcome:** **Rejected in favor of Flutter**, which avoids WebView bridge friction and provides first-party plugin ecosystems.

### Option D: Flutter (Dart + Skia / Impeller)
- **Description:** High-performance, cross-platform UI framework compiling directly to native Android ARM code (AOT compilation) with direct access to platform channels and native APIs.
- **Pros:**
  - **Deterministic offline alarms:** Integrates with Android `AlarmManager` via `flutter_local_notifications` and native platform channels, firing exact alarms offline during Doze mode.
  - **Hardware-accelerated UI:** Skia/Impeller engine renders directly to canvas at 60/120 fps without WebView or DOM translation.
  - **High velocity:** Stateful Hot Reload allows rapid UI tweaking and iteration for a solo developer.
  - **Encryption & security:** First-class support for encrypted SQLite via `sqflite` + `sqflite_sqlcipher` (AES-256) and hardware biometrics via `local_auth`.
  - **On-device ML & Camera:** High-quality official and community plugins for `camera` (CameraX backend) and `google_mlkit_text_recognition` for offline Japanese OCR.
  - **Install footprint:** Base release APK is ~15–22 MB, well below the 200 MB budget.
  - **Zero Cost:** 100% free and open-source (Google BSD-3 license).
- **Cons:**
  - Requires Dart (minor learning curve).
  - Base APK is ~10–15 MB larger than minimal Kotlin app (negligible against 200 MB budget).
- **Outcome:** **Selected.**

---

## 3. Decision

**Project AIBO will be built as a native Android application using Flutter.**

The mobile target will compile directly to an Android APK / App Bundle, running on the user's Android smartphone with full offline capabilities, hardware-backed biometric security, encrypted local SQLite database, and deterministic alarm scheduling.

---

## 4. Architectural Impact and Rationale

| Requirement | Flutter Solution | Verification / Guarantee |
|---|---|---|
| **Alarms & Reminders** | `flutter_local_notifications` with `AndroidAlarmManager` | Verified: Schedules exact alarms with `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` permissions. |
| **Local Storage** | `sqflite` with `sqflite_sqlcipher` | Verified: AES-256 on-disk database encryption with PBKDF2 key derivation. |
| **Biometric Auth** | `local_auth` | Verified: Integrates directly with Android `BiometricPrompt` (Fingerprint / Face / Device PIN). |
| **Document Vault Camera** | `camera` plugin | Verified: Hardware camera access with CameraX backend for high-res photo capture. |
| **Emergency Dialing** | `url_launcher` (`tel:`) or native Intent platform channel | Verified: Directly launches Android phone dialer with 110, 119, or embassy contact pre-filled. |
| **Cost** | Flutter SDK + Android SDK | Verified: ₹0/month operating cost. Open-source tools with local USB / sideload install. |
| **Install Budget** | Release APK | Verified: ~18 MB base installation size, leaving ~180 MB of headroom under the 200 MB budget. |

---

## 5. Consequences and Trade-offs

### Positive
- Rich, highly polished Material Design 3 interface with smooth fluid animations.
- True offline autonomy without browser sandbox eviction risks or background task termination.
- Extensible via Dart MethodChannels to any raw Android Java/Kotlin API if a specific plugin is ever missing.
- Option to compile to other targets (iOS, Linux, Web) in the future without rewriting core business logic.

### Negative & Mitigations
- **Trade-off:** Developer must write Dart rather than standard web JavaScript/TypeScript.
  - *Mitigation:* Dart syntax is familiar to any modern JS/TS/Java programmer; strong typing prevents runtime errors.
- **Trade-off:** Android SDK and Flutter toolchain required on development machine.
  - *Mitigation:* Document exact environment setup commands in Phase 02 deliverables.

---

## 6. Implementation Notes for Phase 03

1. **Flutter Version:** Stable channel (Flutter 3.x+).
2. **Key Packages to Initialize in Phase 03:**
   - `sqflite` + `sqflite_sqlcipher` (Encrypted local database)
   - `flutter_local_notifications` (Offline reminders & alarms)
   - `local_auth` (Biometric & PIN authentication)
   - `flutter_secure_storage` (Secure key/token storage using Android Keystore)
   - `url_launcher` (Emergency dialer & external maps)
   - `camera` (Document vault photo capture)
3. **Android Permissions to Configure:**
   - `POST_NOTIFICATIONS`
   - `SCHEDULE_EXACT_ALARM`
   - `USE_BIOMETRIC`
   - `CAMERA`
   - `CALL_PHONE` / `DIAL` intent

---

## 7. Approval Sign-Off

- **Decision Owner:** Project Owner
- **Decision:** **Option D (Flutter)**
- **Status:** **APPROVED & CLOSED**
- **Date:** 2026-10-25
