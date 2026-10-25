# ADR-007: Speech-to-Text (Voice Input) Architecture

**Status:** APPROVED  
**Date:** 2026-10-25  
**Deciders:** Project Owner (Arjun), Antigravity AI  
**Context:** Phase 08 — Voice Input + Advanced Language Features (Decision U-5)

---

## 1. Context and Problem Statement

Hands-free bilingual interaction (English and Japanese) is essential for rapid phrase lookup, voice query to AI, and on-the-go queries while navigating Tokyo streets.

The implementation must strictly respect:
1. **₹0/month operating cost permanently.**
2. **Installation size budget:** Total app footprint must stay comfortably under 200 MB.
3. **Privacy:** Voice recordings should not be stored or uploaded to third-party ad networks.

---

## 2. Decision

Approved **Option B: Native Android SpeechRecognizer Platform Engine (`android.speech.SpeechRecognizer`)**.

### Key Architectural Choices:
1. **Engine:** Native device speech recognition engine.
2. **Storage Impact:** Exactly **0 MB** added to the APK bundle size (uses pre-installed OS speech framework).
3. **Offline Operation:** Fully operates offline when the user enables the free Japanese/English offline speech pack in Android system settings (`Settings -> Google -> Settings for Google apps -> Search, Assistant & Voice -> Voice -> Offline speech recognition`).
4. **Fallback:** Graceful text input fallback if microphone permissions are denied or audio hardware is unavailable.

---

## 3. Options Considered

| Criterion | Option A: Web Speech API | Option B: Android Native SpeechRecognizer (Selected) | Option C: Embedded Whisper Model | Option D: Cloud STT API (Google Cloud) |
|---|---|---|---|---|
| **Cost** | ₹0 | **₹0 permanently** | ₹0 | ❌ Risk to ₹0 after 60 min |
| **Size Impact** | 0 MB | **0 MB** | +50–100 MB (model file) | 0 MB |
| **Privacy** | Streams to cloud | **Processed locally by OS** | 100% on-device | Streams to cloud |
| **Offline** | Fails offline | **Works with offline speech pack** | 100% offline | Fails offline |
| **Status** | *Rejected* | ✅ **APPROVED & ADOPTED** | *Rejected (Size constraint)* | *Disqualified (Billing risk)* |
