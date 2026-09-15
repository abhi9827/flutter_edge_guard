# Tier 2 — Integration Tests

This directory contains (or will contain) manual/scheduled integration tests for `flutter_edge_guard`.

## Methodology

Integration tests run on real Android emulators/devices to validate actual OS-reported insets match the heuristics and tests simulated in Tier 1.

Due to the cost and time required, these are **not** run on every PR/commit.

## Testing Matrix

When running these tests manually or via scheduled CI pipelines, test against the following representative baseline matrix:

* **API 26 (Android 8.0)**: Baseline for legacy non-edge-to-edge / basic safe area rendering.
* **API 34 (Android 14)**: Representative modern baseline prior to strict edge-to-edge enforcement.
* **API 36 (Android 16)**: Strict edge-to-edge enforcement and predictive back handling defaults.

Ensure you test across:
1. Gesture Navigation mode (if available).
2. 3-Button Navigation mode.
3. Portrait and Landscape orientations.
4. With and without the onscreen keyboard (IME) visible.
