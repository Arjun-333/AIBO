# ADR-006: Map-Data Licensing and Offline Download Strategy

**Status:** APPROVED  
**Date:** 2026-10-25  
**Deciders:** Project Owner (Arjun), Antigravity AI  
**Context:** Phase 07 — Offline Maps + Navigation (Decision U-6)

---

## 1. Context and Problem Statement

A personal companion application for a resident living in Tokyo, Japan, requires offline map viewing and spatial orientation (locating neighborhood ward offices, local train stations, police boxes (*koban*), emergency hospitals, and home) without relying on active cellular data or incurring monthly service fees.

The solution must respect the project's hard constraints:
1. **Strict ₹0/month operating cost** permanently.
2. **Absolute privacy:** Location data and navigation queries must never be transmitted to ad networks or third-party telemetry aggregators.
3. **100% offline capability:** Must operate seamlessly inside subway stations, concrete buildings, or during emergency cellular network blackouts.
4. **Storage budget:** Must fit within the <200 MB initial install and total asset allocation.

---

## 2. Decision

The Project Owner evaluated four architectural options and approved **Option A: OpenStreetMap (OSM) with Offline Tile Caching and Local Geographic Indexing**.

### Key Architectural Choices:
1. **Map Data Source:** OpenStreetMap (OSM) vector and raster tiles distributed under the Open Database License (ODbL).
2. **Offline Storage Strategy:** Region-bounded caching centered around the user's home ward and Tokyo transit corridors. Bounded tile sets for high-frequency areas occupy ~25–45 MB, safely preserving >150 MB of headroom under the 200 MB budget cap.
3. **Routing & Direction Logic:** On-device mathematical navigation helper using the Haversine formula, compass bearing calculations, and local landmark waypoints (koban, station exits, evacuation centers) operating 100% offline.
4. **Personal Waypoints Database:** User-saved places (Home, Ward Office, Immigration Bureau, Embassy, Hospital) stored in the AES-256 encrypted local SQLite database.

---

## 3. Options Considered and Analysis

| Criterion | Option A: OSM + Offline Cache (Selected) | Option B: Google Maps SDK | Option C: Mapbox SDK | Option D: Static Raster PDF Maps |
|---|---|---|---|---|
| **Cost** | **₹0 permanently** | ❌ Violates ₹0 constraint | ❌ Paid after free credit | ₹0 |
| **Privacy** | **100% local, zero telemetry** | ❌ Sends location to Google | ⚠️ Collects device telemetry | 100% local |
| **Offline Capability** | **100% offline** | ❌ **Violates Google ToS 3.2.4** (prohibits offline tile caching) | ⚠️ Limited offline pack caps | 100% offline |
| **Interactivity** | Pan, zoom, pin waypoints, distance calculation | Full native SDK | Full native SDK | Static image (no GPS pins or distance) |
| **Storage Impact** | ~25–45 MB for Tokyo metro region | App binary only, but requires network | 30–50 MB SDK + tile packs | ~10 MB |
| **Status** | ✅ **APPROVED & ADOPTED** | ❌ Disqualified (ToS & Cost) | ❌ Disqualified (Telemetry & Cost) | ❌ Disqualified (Fails navigation) |

---

## 4. Consequences and Mitigations

- **Positive:** Absolute privacy, ₹0 cost, deterministic offline performance during natural disasters or subway commutes.
- **Limitation:** Turn-by-turn vector road graph recalculation across all of Japan would require hundreds of megabytes of raw road network data.
- **Mitigation:** AIBO uses landmark-assisted straight-line bearing and station-exit waypoint guidance combined with offline saved locations, perfectly matching urban Tokyo pedestrian navigation without bloating storage.
