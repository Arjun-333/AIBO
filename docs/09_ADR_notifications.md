# Architecture Decision Record: ADR-004

## Notification Reliability and Scheduling Strategy

| Field | Value |
|---|---|
| **ADR ID** | ADR-004 |
| **Decision ID** | U-7 |
| **Title** | Notification Reliability and Scheduling Strategy |
| **Status** | ✅ **Approved** |
| **Date** | 2026-10-25 |
| **Decision Owner** | Project Owner |
| **Target Phase** | Phase 02 (Architecture & Technology Selection) |
| **Supersedes** | N/A |
| **Superseded By** | N/A |

---

## 1. Context and Problem Statement

Project AIBO must remind the user of daily life commitments, scheduled tasks, appointment times, and Japanese municipal garbage disposal days (e.g. burnable garbage on Tuesday/Friday morning).

Core constraints and problems:
1. **₹0/month cost (Hard Constraint):** No paid push notification infrastructure or third-party notification services.
2. **Offline reliability (P0):** The user may be in an underground subway tunnel, in airplane mode, or have weak mobile signal when a scheduled reminder is due. The reminder must trigger regardless of network availability.
3. **Android Doze mode:** Modern Android aggressively puts idle apps into deep sleep. Alarms that do not use exact alarm scheduling APIs (`AlarmManager.setExactAndAllowWhileIdle()`) are deferred or silenced until the device is plugged in or manually unlocked.

---

## 2. Options Evaluated

### Option A: Web Push Notifications (via Push API & FCM)
- **Description:** Cloud-pushed notifications from an external server to a Service Worker.
- **Flaw:** Requires active internet and a running push server. Cannot trigger scheduled reminders when offline.
- **Verdict:** Disqualified.

### Option B: Native Android Exact Alarms (`AlarmManager` via `flutter_local_notifications`)
- **Description:** Direct integration with Android's system `AlarmManager` using `flutter_local_notifications`.
- **Pros:** 100% reliable offline delivery. Bypasses Doze mode via exact alarm scheduling. Zero network calls or external push servers.
- **Cons:** Requires user permission for `POST_NOTIFICATIONS` (Android 13+) and `SCHEDULE_EXACT_ALARM` (Android 12+).
- **Verdict:** **Approved for background task reminders.**

### Option C: In-App "Today" Summary Screen (MVP Baseline)
- **Description:** Dedicated overview screen presented whenever the user launches AIBO, aggregating today's schedule, deadlines, and overdue items from local SQLite.
- **Pros:** 100% platform-agnostic, zero permission hurdles, zero battery consumption in background, zero failure risk.
- **Cons:** Does not proactively sound an audible alarm if the user forgets to open the app.
- **Verdict:** **Adopted as primary in-app presentation baseline.**

---

## 3. Decision

**AIBO adopts a Dual Notification Strategy:**

1. **In-App Baseline:** The **"Today" Summary Dashboard** (Option C) is the primary in-app view upon opening the application, displaying all tasks, upcoming garbage schedules, and deadlines for the day.
2. **Device-Level Background Alarms:** Offline background notifications and reminders will be scheduled natively using **Android `AlarmManager` via `flutter_local_notifications`** (Option B). Alarms fire deterministically at the exact scheduled second, even when the device is completely offline and in deep sleep.

---

## 4. Structured Comparison

| Criterion | Option A: Web Push | Option B: Android Exact Alarms (Selected) | Option C: In-App Today Summary (Selected) |
|---|---|---|---|
| **Offline Delivery** | ❌ Fails completely | ✅ 100% reliable | ✅ 100% reliable upon launch |
| **Deep Sleep (Doze)** | Deferred / Suppressed | ✅ Wakes device at exact second | N/A (runs on app open) |
| **Network Traffic** | Network polling | **Zero network calls** | **Zero network calls** |
| **Monthly Cost** | ₹0 | **₹0 permanently** | **₹0 permanently** |
| **User Privacy** | Cloud routed | **100% on-device** | **100% on-device** |

---

## 5. Technical Implementation Details for Phase 03/05

1. **Flutter Plugin:** `flutter_local_notifications`.
2. **Android Manifest Permissions:**
   ```xml
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```
3. **Reboot Resilience:** A lightweight native BroadcastReceiver listens for `BOOT_COMPLETED` to reschedule pending task alarms from the local SQLite database after device reboots.

---

## 6. Approval Sign-Off

- **Decision Owner:** Project Owner
- **Decision:** **Option C (In-App Today Summary) + Option B (Native Android Exact Alarms via Flutter)**
- **Status:** **APPROVED & CLOSED**
- **Date:** 2026-10-25
