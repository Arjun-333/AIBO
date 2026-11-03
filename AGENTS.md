# Project AIBO — Agent Guidelines & Definition of Done

This workspace is governed by the principles in [`docs/03_AGENT_RULES.md`](file:///home/arjun/Desktop/AIBO/docs/03_AGENT_RULES.md) and [`docs/16_DESIGN_SYSTEM.md`](file:///home/arjun/Desktop/AIBO/docs/16_DESIGN_SYSTEM.md).

## Measurable Definition of Done (DoD)
When working on Project AIBO, never settle for vague aesthetic prompts like "make it beautiful." Every task must strictly satisfy these 9 measurable criteria:

1. **Clear Primary Purpose**: Every screen must have a distinct, focused primary objective without identity confusion.
2. **Defined & Tested Controls**: Every visible button, tab, card, or form control must execute a defined, tested handler rather than being an inert mock.
3. **Shared Design System**: Typography, line spacing, palette tokens (`#FAF7EE` Warm ivory, `#FFFFFF` Soft white, `#1E232A` Charcoal, `#2F5D44` Matcha), tabular numerals, icons, and components must adhere to `docs/16_DESIGN_SYSTEM.md`.
4. **No Decorative Occlusion**: No critical data (dosage times, yen amounts, status labels) may be covered, clipped, or obscured by mascot illustrations or floating elements.
5. **No Redundant Clutter**: Screens must prioritize whitespace and content hierarchy over repeated boxed borders and duplicate cards.
6. **Truthful States**: Offline capability indicators, cached timetable timestamps, and API failure states must be truthful. Never fabricate live data.
7. **Requirement Preservation**: Existing project constraints (₹0 operating cost, <200 MB install size, zero analytics, local encrypted vault) must be preserved unless an explicit change is approved.
8. **Incremental Verification**: Each major UI or feature change must be visually and functionally verified before moving to the next.
9. **Structured Reporting**: Every completion report must clearly categorize work into:
   - **Completed Fixes**
   - **Newly Implemented Features**
   - **Unresolved Work & Boundaries**
