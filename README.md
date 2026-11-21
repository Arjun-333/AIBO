# Project AIBO

**AI Buddy & Organiser** — A personal AI companion for living in Japan.

## Status

🟡 **Post-v1.0 release reconciliation** — Roadmap phases are complete on paper; local
Flutter/Android verification and a small set of explicitly deferred integrations remain.

## What is AIBO?

AIBO is a mobile-first personal tool designed to help a single user navigate daily life in Japan. It combines conversational AI, Japanese language support, expense tracking, document management, and daily planning — with meaningful offline capabilities.

This is a personal project, not a commercial product.

## Documentation

| Document | Description |
|---|---|
| [`docs/01_PROJECT_CHARTER.md`](docs/01_PROJECT_CHARTER.md) | Vision, constraints, MVP goals, success criteria |
| [`docs/02_PRD.md`](docs/02_PRD.md) | Requirements, user stories, acceptance criteria |
| [`docs/03_AGENT_RULES.md`](docs/03_AGENT_RULES.md) | Rules for AI agents and contributors |
| [`docs/05_ROADMAP_AND_STATUS.md`](docs/05_ROADMAP_AND_STATUS.md) | 12-phase roadmap, dependencies, current status |
| [`docs/04_TESTING_AND_QA.md`](docs/04_TESTING_AND_QA.md) | Testing strategy, validation criteria, phase gates |

## Key Constraints

- **Zero operating cost** — no paid services without explicit approval.
- **Under 200 MB** initial installation (excluding optional downloads).
- **Mobile-first** — works without a desktop/laptop running.
- **Offline capable** — phrases, expenses, documents, tasks, and emergency information work without internet.
- **No fabrication** — never invents prices, schedules, or official procedures.
- **Privacy first** — personal data stored securely, minimal external sharing.

## Phases

See [`docs/05_ROADMAP_AND_STATUS.md`](docs/05_ROADMAP_AND_STATUS.md) for the full 12-phase plan.

## How to Run

### 1. Interactive Web Prototype & Dashboard (Quickest)
The interactive Japanese Stationery UI, Muchi Neko mascot companion, and live dashboard can be previewed immediately with zero external dependencies using Python 3:

```bash
# Start the local server on port 8080
python3 -m http.server 8080 --directory preview
```

Then open your browser to:
- **`http://localhost:8080/index.html`**

*(Alternatively, with Node.js: `npx serve preview -l 8080`)*

### 2. Native Mobile App (Flutter & Android)

#### Prerequisites
- **Flutter SDK**: `>= 3.16.0` (Dart SDK `>= 3.2.0`)
- **Android Studio / Android SDK**: Platform 34 (Android 14)
- Physical Android device or emulator with Developer Mode enabled

#### Setup & Execution
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run on connected device / emulator:
   ```bash
   flutter run
   ```

3. Build Release APK:
   ```bash
   flutter build apk --release
   ```
   The generated APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

### 3. Android Mascot Widget (Muchi Neko 4×2)
AIBO features a zero-battery-drain dynamic home screen companion:
- **Implementation**: [`android/app/src/main/kotlin/com/aibo/aibo/AiboMascotWidgetProvider.kt`](android/app/src/main/kotlin/com/aibo/aibo/AiboMascotWidgetProvider.kt)
- **Usage**: Once installed on an Android device, long-press the home screen, select **Widgets**, find **AIBO**, and place the **Muchi Neko Companion (4×2)** widget.

### 4. Testing & Verification
```bash
# Run Flutter automated test suite
flutter test

# Verify preview script syntax
node -c preview/app.js
```

## Contributing

This is a single-user personal project. All AI agents working on this project must read and follow [`docs/03_AGENT_RULES.md`](docs/03_AGENT_RULES.md) before making any changes.
