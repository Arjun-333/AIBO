# Project AIBO — Long-Term Maintenance and Operations Plan

**Document version:** 1.0.0  
**Effective date:** 2026-10-25  
**Governing Phase:** Phase 12 (Stabilisation + Long-Term Maintenance)

---

## 1. Operating Principle: ₹0 Cost & 100% Privacy Preservation

AIBO is architected as an autonomous, self-contained personal companion application. It requires zero cloud databases, zero recurring server infrastructure, and zero paid subscription tiers.

---

## 2. Maintenance Cadence and Schedules

### A. Monthly Backup Hygiene
* **Cadence:** 1st of every calendar month (or automatically prompted by the in-app reminder).
* **Procedure:** Open AIBO -> Tap **Backup Icon** in Dashboard -> Enter master AES-256 password -> Export encrypted `.aibo.enc` archive -> Store safely in Google Drive, personal PC, or external USB drive.
* **Restore Test:** Test decrypting and restoring on a secondary device once per quarter to verify archive integrity.

### B. Dependency & Security Patching
* **Cadence:** Bi-annual (every 6 months) or upon critical Android OS updates (e.g. Android 15/16 permission changes).
* **Procedure:**
  ```bash
  flutter pub outdated
  flutter pub upgrade
  ```
* Ensure `flutter_secure_storage`, `sqflite`, and `encrypt` remain pinned to stable releases.

### C. LLM Quota & API Key Rotation
* **Google Gemini API Key:** Perpetually free (1,500 requests/day). Check usage once per quarter in Google AI Studio console (`aistudio.google.com`).
* **NVIDIA Nemotron / BYOK Key:** Replenish or switch endpoints in `.env` if custom model endpoints are updated.
* **Secrets Security:** `.env` remains locked down with `chmod 600` and permanently excluded from git version control.

---

## 3. Disaster Preparedness & Emergency Offline Protocol (Disaster / Earthquake)

In the event of a major seismic disaster (e.g., Tokyo Metropolitan Inland Earthquake or typhoon power blackout):
1. **Emergency Screen Accessibility:** Tap the lock screen **EMERGENCY** button (no PIN or biometric required) for instant 110/119 dialer, furigana emergency phrases, and editable medical info card.
2. **Offline Maps & Koban Finder:** Open **Offline Maps & Navigation** to view straight-line compass bearings and distances to the nearest police boxes (*koban*), emergency hospitals, and designated evacuation centers.
3. **Document Vault Access:** All scanned Residence Cards (*Zairyu Card*), health insurance cards, and passport copies are accessible 100% offline from device storage.

---

## 4. Post-v1.0 Future Roadmap (Backlog)

* **v1.1:** Add interactive Tokyo Metro animated subway map canvas with line color filters.
* **v1.2:** Integrate Bluetooth BLE mesh peer-to-peer messaging for local offline communication during network blackouts.
* **v1.3:** Connect Android AICore system API when Gemini Nano becomes a universal unbundled system service.
