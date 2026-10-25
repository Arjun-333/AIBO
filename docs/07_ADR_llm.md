# Architecture Decision Record: ADR-002

## Cloud LLM Provider Selection and Architecture

| Field | Value |
|---|---|
| **ADR ID** | ADR-002 |
| **Decision ID** | U-2 |
| **Title** | Cloud LLM Provider Selection and Provider-Agnostic Client Architecture |
| **Status** | ✅ **Approved** |
| **Date** | 2026-10-25 |
| **Decision Owner** | Project Owner |
| **Target Phase** | Phase 02 (Architecture & Technology Selection) |
| **Supersedes** | N/A |
| **Superseded By** | N/A |

---

## 1. Context and Problem Statement

Project AIBO requires a conversational AI engine to provide guidance on daily life in Japan (e.g., municipal garbage sorting rules, cultural etiquette, bilingual communication, transit navigation, administrative procedures).

The key architectural constraints:
1. **₹0/month operating cost (Hard Constraint):** The baseline system must function indefinitely without requiring any credit card on file, prepaid credits, or monthly subscription fees.
2. **Perpetual reliability:** The system must not suddenly break or shut down when a promotional trial period expires.
3. **Japanese language proficiency:** Must accurately comprehend and generate Japanese text, including cultural nuance, polite forms (*keigo*), and administrative terminology.
4. **Data privacy & minimisation (NFR-P-02, NFR-P-06):** Inbound prompts must never contain unencrypted personal identity documents, credentials, or financial numbers.
5. **Offline honesty (NFR-O-04):** When offline, the application must honestly indicate that cloud AI is unreachable rather than fabricating responses.

---

## 2. Options and Candidates Evaluated

### Option A: Google Gemini API (via Google AI Studio)
- **Model:** Gemini 1.5 Flash / Gemini 2.0 Flash
- **Free Tier Allowance:** 15 Requests Per Minute (RPM), 1,500 Requests Per Day (RPD), 1 Million Tokens Per Minute (TPM).
- **Cost:** ₹0 permanently. No credit card required.
- **Quota Behavior:** Hard cutoff (returns HTTP 429 when quota is reached); zero risk of accidental billing.
- **Capabilities:** 1M token context window, multimodal vision support, excellent native Japanese language comprehension.
- **Trade-off:** Free-tier inputs may be logged by Google for product improvement; strict client-side data sanitization is required.
- **Verdict:** **Selected as Primary Default Baseline.**

### Option B: NVIDIA NIM / Nemotron (via `build.nvidia.com`)
- **Model:** `nvidia/llama-3.1-nemotron-70b-instruct`, `meta/llama-3.1-70b-instruct`
- **Free Allowance:** 1,000 free promotional trial credits upon signup.
- **Cost:** Free during trial; once trial credits are consumed or the validity window expires, requests fail with `402 Cloud credits expired`.
- **Capabilities:** Outstanding reasoning, state-of-the-art open weights, standard OpenAI-compatible REST API.
- **Trade-off:** **Does not meet the perpetual ₹0 constraint as a sole dependency** because credits are a finite trial pool, not a recurring daily allowance.
- **Verdict:** **Adopted as a First-Class Supported "Bring Your Own Key" (BYOK) Option.** Users with an active NVIDIA API key can use their free credits seamlessly, with automatic fallback to Gemini.

### Option C: Groq / Cloudflare Workers AI / Open-Weights Free Tiers
- **Model:** Llama 3.1 8B/70B, Qwen 2.5
- **Free Allowance:** Generous daily rate limits (Groq: 30 RPM, 14,400 RPD).
- **Verdict:** Fully supported via the OpenAI-compatible architecture as a secondary fallback.

### Option D: OpenAI API (GPT-4o mini) & Anthropic Claude
- **Cost:** Disqualified. Neither offers an ongoing, perpetual free tier (OpenAI trial credits expire in 90 days; Anthropic requires paid credits).

---

## 3. Decision

**AIBO adopts a Dual-Layer Strategy:**

1. **Default Baseline Provider:** **Google Gemini 1.5 Flash (via Google AI Studio)** is adopted as the primary, out-of-the-box cloud LLM. It guarantees a permanent, daily replenishing quota of 1,500 requests/day at guaranteed ₹0/month.
2. **Provider-Agnostic "Bring Your Own Key" (BYOK) Client:** The Flutter application will implement an abstract, OpenAI-compatible LLM service interface. The user settings screen will allow the Project Owner to input an **NVIDIA NIM / Nemotron API key** (or Groq, OpenRouter, or custom endpoint) to spend free credits at will, with seamless switching.

---

## 4. Structured Comparison

| Criterion | Google Gemini 1.5 Flash (Default) | NVIDIA NIM Nemotron (BYOK) | Groq Llama 3.1 (Fallback) | OpenAI / Anthropic |
|---|---|---|---|---|
| **Perpetual ₹0?** | ✅ Yes (1,500 RPD forever) | ⚠️ Trial only (1,000 credits) | ✅ Yes (daily rate limits) | ❌ No (Paid only) |
| **Credit Card Required?** | ❌ No | ❌ No | ❌ No | ✅ Yes (after trial) |
| **Japanese Quality** | Excellent | Very Good | Good | Excellent |
| **Multimodal (Vision)** | ✅ Yes (Native) | ⚠️ Text focused | ❌ Text only (standard) | ✅ Yes (paid) |
| **API Format** | Google AI Studio REST / SDK | OpenAI-Compatible (`/v1`) | OpenAI-Compatible (`/v1`) | OpenAI / Anthropic REST |
| **Role in AIBO** | **Default Primary Provider** | **Supported BYOK Provider** | **Supported BYOK / Fallback** | Disqualified |

---

## 5. Architectural Implementation Details

### 5.1 Abstract Service Layer
In Phase 05/06 implementation, the LLM client will be structured as:

```dart
abstract class LlmService {
  Future<String> generateText({
    required String systemPrompt,
    required String userPrompt,
    List<ChatMessage> conversationHistory = const [],
    List<Uint8List> imageAttachments = const [],
  });
}
```

Two concrete implementations will be provided:
1. `GeminiLlmService`: Direct integration with Google AI Studio API (`generativelanguage.googleapis.com`).
2. `OpenAiCompatibleLlmService`: Universal client for NVIDIA NIM (`https://integrate.api.nvidia.com/v1`), Groq, or any `/v1/chat/completions` endpoint.

### 5.2 Key Management & Security
- API keys will be stored exclusively on the user's Android device using `flutter_secure_storage` backed by the **Android Keystore (Hardware-backed TEE)**.
- Keys are never committed to version control, bundled in compiled APKs, or sent to any central server.
- The user can change, test, or revoke their API keys at any time via in-app Settings.

### 5.3 Privacy & Data Minimisation (NFR-P-06)
Before any prompt payload is transmitted over HTTPS:
- Client-side sanitization strips document vault filenames, account numbers, and personal identity fields.
- System prompts explicitly instruct the model never to solicit personal identification numbers or bank passwords.

### 5.4 Error & Quota Handling
- HTTP 429 (Rate Limit): Displays: *"Daily free AI quota reached. Resets at midnight, or switch to your NVIDIA Nemotron key in Settings."*
- HTTP 402 / Expired Credits: Displays: *"NVIDIA credits exhausted. Reverting to Gemini free tier."*
- Offline (no network): Displays: *"Offline — cannot reach AI. Core notes and emergency tools remain available."*

---

## 6. Approval Sign-Off

- **Decision Owner:** Project Owner
- **Decision:** **Option A (Google Gemini Default) + Provider-Agnostic BYOK (NVIDIA Nemotron / OpenAI-compatible)**
- **Status:** **APPROVED & CLOSED**
- **Date:** 2026-10-25
