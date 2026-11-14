# Project AIBO — Architectural Guide: Personal Life OS for Japan

**Document Version:** 1.0.0  
**Status:** APPROVED ARCHITECTURAL SPECIFICATION & LOG  
**Date:** 2026-11-14  
**Associated Documents:** `01_PROJECT_CHARTER.md`, `02_PRD.md`, `03_AGENT_RULES.md`, `05_ROADMAP_AND_STATUS.md`, `15_FEATURE_AUDIT_CHECKLIST.md`

---

## 1. The Architectural Paradigm Shift

The fundamental breakthrough of Project AIBO is recognizing that **an AI companion for living in Japan should not be another generic LLM chatbot with some utility buttons attached**. 

Living in Japan as an international resident is governed by **high-friction, deterministic, localized real-world systems**:
* Municipal ward offices (*区役所 Kuyakusho*) with strict jurisdiction boundaries.
* Specific garbage sorting categories and collection days varying street by street.
* Complex kanji paper slips (*納付書 Nōfusho*) for resident tax, pension, and utility bills.
* Critical administrative deadlines (visa renewal 3-month windows, My Number registration).
* Pharmacy drug classifications (第1類 OTC requiring a licensed pharmacist vs 第2類).

When a user asks: *"I need to visit the city office tomorrow"*, a generic chatbot answers with general office hours. **AIBO as a Life OS** executes across four internal engines:
1. Reads the user's **Home Ward** from the Personal Context Engine (`Shinjuku-ku`).
2. Identifies the specific official ward office, opening hours, and station exit (`1-4-1 Kabukicho, 5 min from Shinjuku East Exit`).
3. Checks the **Document Vault** to flag potentially required documents (Zairyu card, My Number, Health insurance).
4. Emits an entry to the **Unified Life Timeline** and prepares survival Japanese phrases for the counter.

```
+-----------------------------------------------------------------------------------------+
|                               AIBO PERSONAL LIFE OS ARCHITECTURE                        |
+-----------------------------------------------------------------------------------------+
| 1. PERSONAL CONTEXT ENGINE                                                              |
|    - Home Ward & Japanese Address (for 110/119 readback)                                |
|    - Nearest Train Station & Commute Route                                              |
|    - Target JLPT Level & Target Honorific Register                                      |
|    - Visa Category & Expiration Date                                                    |
+-----------------------------------------------------------------------------------------+
| 2. JAPANESE DOCUMENT INTELLIGENCE                                                       |
|    - On-device ML Kit Japanese OCR (zero cloud upload for ID cards)                     |
|    - Structured Field Extraction: Yen amounts, deadlines, barcode payment tags         |
|    - Pre-save User Verification & Interactive Correction Card                           |
+-----------------------------------------------------------------------------------------+
| 3. PROACTIVE LIFE ASSISTANT                                                             |
|    - 100% Grounded Alerts (Visa expiry, bill due dates, daily doses, garbage morning)   |
|    - Zero AI Guesswork / Zero Hallucinated Dates                                        |
+-----------------------------------------------------------------------------------------+
| 4. UNIFIED LIFE TIMELINE                                                                |
|    - Single chronological stream: Bills + Medications + Garbage + Renewals + Tasks      |
+-----------------------------------------------------------------------------------------+
| 5. THREE-TIER OFFLINE-FIRST ENGINE                                                      |
|    - Layer 1: Deterministic Storage & Alarms (AES-256 SQLite, AlarmManager, OSM Cache)  |
|    - Layer 2: On-Device Heuristic Intelligence (Japanese regex, distance, date parsers)  |
|    - Layer 3: Optional Free Cloud AI (Gemini 2.5 Flash / BYOK Nemotron)                 |
+-----------------------------------------------------------------------------------------+
```

---

## 2. The 5 Core Engines in Detail

### 2.1 Personal Context Engine
* **Source Files**: 
  * [`lib/core/context/personal_context_model.dart`](file:///home/arjun/Desktop/AIBO/lib/core/context/personal_context_model.dart)
  * [`lib/core/context/personal_context_service.dart`](file:///home/arjun/Desktop/AIBO/lib/core/context/personal_context_service.dart)
  * [`lib/core/context/personal_context_modal.dart`](file:///home/arjun/Desktop/AIBO/lib/core/context/personal_context_modal.dart)
* **How It Works**:
  * Persists user parameters locally in the encrypted SQLite `personal_context` table.
  * Injects sanitized contextual parameters (`toSanitizedLlmContext()`) into `LlmService` when relevant keywords are detected (*ward office, garbage, station, visa, doctor*).
  * **Privacy Guarantee**: Does not send detailed apartment numbers or private keys to cloud providers; only general municipal ward and transit lines are shared.
  * **Emergency Integration**: Surfaces the Japanese address directly on the [EmergencyScreen](file:///home/arjun/Desktop/AIBO/lib/features/emergency/screens/emergency_screen.dart) with a spoken Japanese phrase template to read to 110/119 emergency dispatchers.

### 2.2 Japanese Document Intelligence (Beyond Raw OCR)
* **Source Files**:
  * [`lib/core/ocr/structured_document_model.dart`](file:///home/arjun/Desktop/AIBO/lib/core/ocr/structured_document_model.dart)
  * [`lib/core/ocr/document_understanding_service.dart`](file:///home/arjun/Desktop/AIBO/lib/core/ocr/document_understanding_service.dart)
  * [`lib/core/ocr/ocr_service.dart`](file:///home/arjun/Desktop/AIBO/lib/core/ocr/ocr_service.dart)
* **Supported Document Domains**:
  1. **Residence Card (*在留カード Zairyū Kādo*)**: Extracts 12-character card ID, status of residence, and converts Japanese era expiration dates (`令和9年4月15日` ➔ `2027-04-15`).
  2. **Electricity Bill (*電気料金請求書*)**: Detects provider (TEPCO/東京電力), total ¥ amount, due date, and konbini barcode payment viability.
  3. **Gas Bill (*ガス料金請求書*)**: Detects Tokyo Gas, due date, and payment instructions.
  4. **Water & Sewerage Bill (*水道料金・下水道料金*)**: Detects Bureau of Waterworks, bi-monthly schedule, amount.
  5. **Resident Tax & Pension Slips (*住民税・国民年金*)**: Detects municipal tax office, penalty avoidance guidance, and due dates.
  6. **Konbini Receipts (*領収書・レシート*)**: Detects store name, total ¥ spent, and tax category.
* **Pre-Save Verification Card**: Users inspect, verify, and correct recognized fields in the [VaultScreen](file:///home/arjun/Desktop/AIBO/lib/features/vault/screens/vault_screen.dart) before anything is committed to storage.

### 2.3 Proactive Life Assistant
* **Source Files**:
  * [`lib/core/timeline/unified_timeline_service.dart`](file:///home/arjun/Desktop/AIBO/lib/core/timeline/unified_timeline_service.dart)
  * [`lib/core/services/notification_service.dart`](file:///home/arjun/Desktop/AIBO/lib/core/services/notification_service.dart)
* **Operational Invariant**: Proactive notifications are **grounded strictly in stored database records**. The system never relies on probabilistic LLM inferences to alert users of upcoming deadlines:
  * Scans `structured_documents` for bills due within 3 days.
  * Audits `personal_context` for visa expiry within 90 days (the legal renewal window).
  * Evaluates local weekday schedules for morning garbage collection (08:00 AM).
  * Evaluates `medication_reminders` for pending daily doses.

### 2.4 Unified Life Timeline
* **Source Files**:
  * [`lib/core/timeline/unified_timeline_model.dart`](file:///home/arjun/Desktop/AIBO/lib/core/timeline/unified_timeline_model.dart)
  * [`lib/features/timeline/screens/timeline_screen.dart`](file:///home/arjun/Desktop/AIBO/lib/features/timeline/screens/timeline_screen.dart)
* **Functionality**:
  * Merges disparate life requirements into a single chronological stream.
  * Color-coded urgency indicators (Crimson Red for urgent, Matcha Teal for completed).
  * Filterable by category: *All Events*, *Bills & Visas*, *Tablets*, *Garbage Days*.

### 2.5 Three-Tier Offline-First Intelligence Stack
* **Layer 1 (Offline Core)**: Encrypted SQLite (`sqflite`), Android `AlarmManager` with Doze-mode bypass (`exactAllowWhileIdle`), OpenStreetMap offline tile cache, bundled 6-category phrasebook.
* **Layer 2 (On-Device Heuristic Intelligence)**: Deterministic Japanese regex parsers (Reiwa era converter, yen currency extraction), Haversine compass radar, ward office directory.
* **Layer 3 (Optional Cloud AI)**: Google Gemini 1.5/2.5 Flash free tier (1,500 RPD) + NVIDIA Nemotron BYOK for complex conversations and public sign/menu translations.

---

## 3. Database Schema Overview

```sql
-- 1. Personal Context (Life OS Core)
CREATE TABLE personal_context (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  katakana_name TEXT,
  home_ward TEXT NOT NULL,
  home_address_ja TEXT,
  nearest_station TEXT NOT NULL,
  commute_route TEXT,
  workplace_school TEXT,
  jlpt_level TEXT NOT NULL,
  residence_status TEXT NOT NULL,
  residence_expiry_date TEXT,
  monthly_budget_jpy REAL NOT NULL,
  daily_budget_jpy REAL NOT NULL,
  has_my_number_card INTEGER NOT NULL DEFAULT 1,
  national_pension_status TEXT,
  burnable_garbage_days TEXT,
  recyclable_plastics_days TEXT,
  non_burnable_days TEXT,
  updated_at TEXT NOT NULL
);

-- 2. Structured Japanese Life Documents (OCR Document Understanding)
CREATE TABLE structured_documents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vault_doc_id INTEGER,
  doc_type TEXT NOT NULL,
  title TEXT NOT NULL,
  issuer_or_provider TEXT NOT NULL,
  amount_jpy REAL,
  due_or_expiry_date TEXT,
  document_identifier TEXT,
  is_payable_at_konbini INTEGER NOT NULL DEFAULT 0,
  payment_status TEXT NOT NULL DEFAULT 'not_applicable',
  key_instructions_ja TEXT,
  key_instructions_en TEXT,
  raw_extracted_text TEXT NOT NULL,
  is_verified_by_user INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

---

## 4. Cost, Size, and Privacy Guarantees

| Metric | Guarantee | Technical Implementation |
|---|---|---|
| **Monthly Operating Cost** | **₹0 permanently** | All cloud APIs run on permanent free tiers (Google AI Studio 1,500 RPD, ODPT Transit Open Data, OSM ODbL). Zero credit card billing accounts. |
| **Install Package Footprint** | **< 200 MB** | Release APK size is ~42 MB. On-device ML Kit models initialize dynamically; no heavy offline LLM weights bundled in v1.0. |
| **Data Privacy & Egress** | **100% On-Device** | Document Vault optical character recognition (extracting text from Residence Cards, health insurance, tax slips) executes 100% locally on the device using Google ML Kit Japanese script without any network egress. |
| **Emergency ICE Policy** | **Split-Security** | Critical ICE medical data and Japanese address readback are accessible in seconds without authentication, while financial receipts and encrypted vault documents remain gated behind biometric authentication. |

---

## 9. Muchi Neko Mascot Home Screen Widget (Duolingo Style)

To ensure the user stays on top of their Tokyo daily routine without opening the app, AIBO provides an active Android 4×2 home screen widget powered by **Muchi Neko (むちねこ)**:

1. **Dynamic Mood Expressions**:
   - `reminder`: Dose due / active pending tasks ("Don't forget your 13:00 dose nya!").
   - `celebrate`: 100% of doses & tasks taken ("All medications completed today! 🎉").
   - `urgent`: Approaching visa deadline or daily budget limit ("Attention! Visa expires soon nya!").
   - `sleepy`: Late evening wrap-up ("Good job today! Time to rest nya~ 💤").
   - `happy`: Morning / calm status ("Tokyo life is peaceful today. Ganbatte!").
2. **Local Zero-Battery Architecture**:
   - Updates via Android `AppWidgetProvider` (`AiboMascotWidgetProvider.kt`) triggered only on local SQLite state mutations (expense logged, medication stamped, task checked) or standard 30-minute system broadcasts.
   - 100% offline, ₹0 operating cost, zero network wakeups.
