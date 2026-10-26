# Project AIBO — Design System Specification

**Document Version:** 1.0.0  
**Status:** APPROVED ARCHITECTURAL STANDARD  
**Associated Documents:** `01_PROJECT_CHARTER.md`, `02_PRD.md`, `03_AGENT_RULES.md`, `05_ROADMAP_AND_STATUS.md`, `15_FEATURE_AUDIT_CHECKLIST.md`

---

## 1. Visual Direction & Identity

AIBO embodies a **Warm Japanese Lifestyle Aesthetic** that is **Minimal, Functional, and Distinctive**. 

It draws inspiration from Japanese stationery (文房具 - *Bunbōgu*), tactile paper craft (*Washi*), and calm daily utilities. It deliberately avoids the generic dark blue-purple gradient "crypto/AI dashboard" cliché. Instead, it creates a tactile, trustworthy companion that feels at home in a Tokyo apartment, local train, or municipal ward office.

```
+---------------------------------------------------------------+
|                       AIBO DESIGN PILLARS                     |
+-------------------------------+-------------------------------+
| 1. Warm Tactile Harmony       | Cream & charcoal base with    |
|                               | Japanese traditional pigments |
| 2. Functional Restraint       | Spacing over boxy containers; |
|                               | subtle borders only if needed |
| 3. Honest Precision           | Tabular numerals; zero fake   |
|                               | data; clear offline boundaries|
| 4. Purposeful Motion          | Motion only for user feedback;|
|                               | full reduced-motion support   |
+-------------------------------+-------------------------------+
```

---

## 2. Color Palette & Design Tokens

### 2.1 The Core Foundation

| Role | Token Name | Hex Code | Purpose & Application |
|---|---|:---:|---|
| **Main Background** | `--bg-main` / `washiCream` | `#FAF7EE` | Application scaffold, viewports, page background. Calms the eyes. |
| **Content Surface** | `--surface-card` / `white` | `#FFFFFF` | Card surfaces, dialog sheets, input boxes. Clean contrast against ivory. |
| **Primary Text** | `--text-primary` / `charcoal` | `#1E232A` | High-contrast body copy, titles, numbers. Softer than harsh `#000000`. |
| **Success State** | `--color-matcha` / `matchaGreen`| `#2F5D44` | Verified tasks, taken medications, positive balances, safe status. |

### 2.2 Secondary & Structural Tones

| Role | Token Name | Hex Code | Purpose & Application |
|---|---|:---:|---|
| **Secondary Text** | `--text-secondary` | `#57534E` | Metadata, subtitles, instructions, secondary labels. |
| **Muted Text / Hints**| `--text-muted` | `#78716C` | Timestamps, placeholders, inactive states. |
| **Subtle Border** | `--border-subtle` | `#EAE5D9` | 1px clean separators. Never thick or harsh. |
| **Surface Hover** | `--surface-hover` | `#F5F1E5` | Active tap feedback on lists and buttons. |

### 2.3 Semantic Accents (Japanese Pigments)

| Role | Token Name | Hex Code | Japanese Pigment | Application |
|---|---|:---:|---|---|
| **Alert / Emergency** | `--color-vermilion` | `#C84B31` | 朱色 (*Shu-iro*) | Inkan stamps, 110/119 SOS, urgent errors. |
| **Attention / Pending**| `--color-amber` | `#D97706` | 山吹色 (*Yamabuki*) | Approaching budget, scheduled dose pending. |
| **Transit / Link** | `--color-indigo` | `#1E3A8A` | 藍染 (*Aizome*) | Yamanote Line, station guides, route links. |

---

## 3. Typography System

### 3.1 Font Stack
- **Primary Interface Font**: `'Inter'`, system `-apple-system`, `BlinkMacSystemFont`, `'Segoe UI'`, `Roboto`, sans-serif.  
  *Delivers exceptional legibility at small sizes for medical dosages, budgets, and train timetables.*
- **Japanese Font Fallback**: `'Zen Maru Gothic'`, `'Noto Sans JP'`, sans-serif.  
  *Ensures Japanese kanji, hiragana, katakana, and furigana render harmoniously alongside English.*
- **Brand & Mascot Accent**: `'Outfit'`, sans-serif.  
  *Reserved strictly for app branding, companion speech, and badge seals.*

### 3.2 Type Scale

| Scale Role | Font Family | Size | Weight | Line Height | Tracking |
|---|---|:---:|:---:|:---:|:---:|
| **Display / Header** | `--font-display` | 24px (1.5rem) | 700 Bold | 1.25 | -0.02em |
| **Title 1 (Screen Title)** | `--font-display` | 20px (1.25rem) | 600 SemiBold | 1.3 | -0.01em |
| **Title 2 (Card Heading)** | `--font-sans` | 16px (1.0rem) | 600 SemiBold | 1.35 | 0 |
| **Section Label** | `--font-sans` | 12px (0.75rem) | 600 SemiBold | 1.4 | +0.05em (UPPER) |
| **Body Copy** | `--font-sans` | 14px (0.875rem) | 400 Regular | 1.55 | 0 |
| **Secondary / Caption** | `--font-sans` | 12px (0.75rem) | 400 Regular | 1.45 | 0 |
| **Micro Caption / Stamp**| `--font-jp` | 11px (0.6875rem)| 500 Medium | 1.3 | +0.02em |

### 3.3 Tabular Numerals
For financial ledgers, budget remaining, timestamps, and dosage quantities, the CSS property:
```css
font-variant-numeric: tabular-nums;
```
or Dart `FontFeature.tabularFigures()` is **mandatory**. This guarantees uniform digit widths, preventing visual jitter during value updates and maintaining strict vertical column alignment in receipts, transit times, and budgets.

---

## 4. Components & Restrained System

### 4.1 Corner-Radius Tokens
A restrained 4-tier radius system replaces arbitrary corner radii:

```css
--radius-xs: 4px;    /* Micro tags, inkan stamp borders */
--radius-sm: 8px;    /* Buttons, input fields, dropdown menus */
--radius-md: 14px;   /* Standard cards, content surfaces, dialogs */
--radius-lg: 20px;   /* Modal bottom sheets, companion banner */
--radius-pill: 999px;/* Status chips, notification badges, circular icon buttons */
```

### 4.2 Spacing & Visual Separation Rules
- **Spacing First**: Separate related sections using 12px, 16px, or 24px margins before resorting to visible borders.
- **Subtle Borders**: Card borders must never exceed `1px solid var(--border-subtle)` (`#EAE5D9`). No heavy drop shadows or competing outer frames.
- **Surface Elevation**: Cards sit on `#FFFFFF` atop the `#FAF7EE` background with an ultra-subtle ambient shadow:
  ```css
  box-shadow: 0 1px 3px rgba(30, 35, 42, 0.04), 0 1px 2px rgba(30, 35, 42, 0.02);
  ```

### 4.3 Iconography Standard
- Outlined vector icons with consistent **1.75px stroke width**, rounded caps and joins (`stroke-linecap="round" stroke-linejoin="round"`).
- Standard sizes:
  - **Inline / Action**: 16×16px
  - **Navigation / Button**: 20×20px
  - **Card / Hub**: 24×24px (enclosed within 36×36px soft tinted pill)
- **Zero Inconsistent Emojis**: System actions (Edit, Delete, Add, Call, Check) use consistent SVGs, never random OS emojis. Emojis are reserved exclusively for the mascot and cultural category tags.

### 4.4 Buttons & Controls
- **Primary Button**: Solid charcoal `#1E232A` with `#FAF7EE` text, 8px radius, 12px vertical padding.
- **Secondary / Action Button**: Subtle white surface `#FFFFFF`, 1px border `#EAE5D9`, charcoal text, hover `#F5F1E5`.
- **Destructive Button**: Muted vermilion background tint `#FDEEEB`, border `#F87171`, text `#C84B31`.
- **Success / Stamp Button**: Matcha green `#2F5D44`, `#FFFFFF` text. Triggers tactile Inkan stamp confirmation.

---

## 5. Comprehensive State Architecture

Every interactive screen and component must handle all 7 foundational states:

```
+-----------------------------------------------------------------+
|                       COMPONENT STATE LIFECYCLE                 |
+----------------+------------------------------------------------+
| 1. Loading     | Calm skeleton placeholder (warm ivory pulse);  |
|                | no jarring spinner overlays.                   |
| 2. Empty       | Washi-styled empty card, friendly explanation, |
|                | and a single primary "+ Add" action button.    |
| 3. Error       | Vermilion alert pill with retry button; never  |
|                | crash or show cryptic raw stack traces.        |
| 4. Success     | Inkan stamp animation (済) + matcha toast.      |
| 5. Disabled    | 45% opacity, cursor not-allowed, no events.    |
| 6. Offline     | "Offline Mode" header badge + transparency     |
|                | info explaining on-device vs cloud features.   |
| 7. Syncing     | Discrete rotating sync icon; pending count.    |
+----------------+------------------------------------------------+
```

### 5.1 Clear Action Feedback
- **Dose Taken**: When tapping "Log Taken (済)", the button transitions to a sealed green Inkan stamp, triggers an in-app toast, and syncs immediately to the Yakutai medicine envelope.
- **Task Completed**: Checkbox animates with a matcha fill, text transitions to muted secondary with clean strikethrough, and the routine progress counter recalculates immediately.
- **Expense Logged**: Modal closes smoothly, total spent amount increments live with tabular numerals, and the budget progress bar updates smoothly.
- **Transaction Deleted**: Requires a clear confirmation prompt; removed immediately from local database with undo toast.

---

## 6. Purposeful Motion & Accessibility

- **Motion Budget**: Animations must communicate state transitions or action confirmations. Decorative continuous bouncing is prohibited.
- **Mascot Breathing**: Gentle 4.5-second easing pulse (`transform: scale(1.01)`).
- **Reduced Motion Compliance**:
  ```css
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
      scroll-behavior: auto !important;
    }
  }
  ```
- **WCAG 2.1 AA Compliance**:
  - Contrast ratio between `#1E232A` (Charcoal) and `#FAF7EE` (Warm ivory) is **13.5:1** (exceeds AAA standard 7.0:1).
  - Contrast ratio between `#57534E` (Secondary) and `#FAF7EE` is **5.4:1** (exceeds AA standard 4.5:1).
  - Contrast ratio between `#2F5D44` (Matcha) and `#FFFFFF` is **5.8:1** (exceeds AA standard 4.5:1).
  - Minimum touch target: **48×48 dp** for all clickable elements.
