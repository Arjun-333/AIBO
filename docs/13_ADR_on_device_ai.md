# ADR-008: On-Device AI Evaluation and Decision

**Status:** APPROVED (Evaluated & Declined for v1.0)  
**Date:** 2026-10-25  
**Deciders:** Project Owner (Arjun), Antigravity AI  
**Context:** Phase 10 — On-Device AI Evaluation

---

## 1. Context and Problem Statement

Phase 10 evaluates whether to bundle or embed an on-device Large Language Model (LLM) — such as Google Gemini Nano, Gemma 2B, or Llama 3.2 1B — running directly on the Android smartphone's NPU/CPU/GPU without internet access.

The evaluation must be measured against the project's hard constraints:
1. **Initial install footprint < 200 MB.**
2. **Device battery, thermal, and memory limits.**
3. **Strict ₹0/month operating cost.**
4. **Offline usability requirements.**

---

## 2. Technical Evaluation

| Candidate Model | Quantization | Model Weight File Size | Minimum RAM Required | Japanese Fluency |
|---|---|---|---|---|
| **Google Gemma 2B** | INT4 Quantized | ~1.4 GB | 2.5 GB RAM | Moderate |
| **Llama 3.2 1B** | Q4_K_M | ~800 MB | 1.8 GB RAM | Basic |
| **Qwen 2.5 0.5B** | INT4 | ~390 MB | 1.0 GB RAM | Basic (hallucination risk) |
| **Gemini Nano** | System AICore | 0 MB (system) | Android 14+ Flagship only | Varies (Pixel/Galaxy exclusive) |

---

## 3. Decision

**DECLINED for v1.0 Release.**

### Architectural Rationale:
1. **Direct Violation of the 200 MB Installation Budget:**
   Even the smallest quantized 1B open-source LLM weights (800 MB – 1.4 GB) would exceed the total allowable 200 MB application install budget by 400% to 700%.
2. **Extreme Memory & Battery Drain:**
   Running local LLM inference on mobile devices causes thermal throttling, accelerates battery discharge, and risks frequent Android low-memory-killer (LMK) process terminations.
3. **Zero Benefit Over Dual Cloud Architecture:**
   - When online, **Google Gemini 1.5 Flash** provides a perpetual 1,500 requests/day at ₹0/month with state-of-the-art Japanese comprehension, backed by **NVIDIA Nemotron** fallback.
   - When offline, AIBO's **Bundled Offline Survival Phrasebook** ([`phrase_data.dart`](../lib/features/language/data/phrase_data.dart)) already provides 100% of essential everyday, administrative, medical, and emergency phrases with furigana and cultural tips without consuming any battery or memory overhead.

---

## 4. Consequences and Future Outlook

- **Immediate Impact:** Application bundle remains lightweight (~18–25 MB base), installation takes seconds, and device battery life is fully preserved.
- **Future Re-Evaluation (Post-v1.0):** If Android AICore / Gemini Nano system API becomes ubiquitously available as an unbundled OS service across standard mid-range Android devices, AIBO will connect via the system IPC bridge with zero APK bloat.
