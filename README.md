# flutter_edge_guard

Understand and fix modern Android edge-to-edge UI problems.

EdgeGuard provides a production-ready edge-to-edge protection layer, diagnostics engine, and developer project doctor. It answers a single, vital question for developers:

**"Why is my Flutter UI broken near the edge?"**

## Why Android 15 & 16 Matter

Starting with Android 15 (API 35), Google enforces edge-to-edge window behavior for applications targeting the new SDK. This means:
* Status and navigation bars become transparent by default.
* Your application content draws *behind* these system bars.
* Old assumptions about automatic window offsets break.

In Android 16 (API 36), edge-to-edge opt-outs are further restricted and predictive back becomes a stronger default.

**EdgeGuard does not disable edge-to-edge. It helps you build correctly for it.**

> **Note**: EdgeGuard complements `SafeArea`; it does not replace `SafeArea`.

## Requirements

* **Dart SDK**: `>=3.9.0 <4.0.0`
* **Flutter**: `>=3.35.0` (Latest stable). We rely on granular `MediaQuery` accessors (`paddingOf`, `viewInsetsOf`, `viewPaddingOf`, `displayFeaturesOf`) and `PopScope` that were stabilized in recent versions. Do not downgrade to support older Flutter versions, as you will lose the APIs this package depends on.

## Installation

```yaml
dependencies:
  flutter_edge_guard: ^0.1.0
```

## Quick Start

Wrap your application or page in an `EdgeGuard` widget.

```dart
import 'package:flutter_edge_guard/flutter_edge_guard.dart';

void main() {
  runApp(
    EdgeGuard(
      config: EdgeGuardConfig(
        enableDebugOverlay: true,
        enableInspector: true,
      ),
      child: const MyApp(),
    ),
  );
}
```

## Features

### 1. Diagnostics Engine & Inspector

EdgeGuard can analyze the current window context and report problems such as:
* Bottom actions overlapping with system gesture areas.
* Content drawn under the keyboard (IME).
* Large screen or foldable constraints conflicting with fixed mobile layouts.
* Navigation Mode heuristics.
* **iOS Overlap Checks**: Detects overlaps with the notch, Dynamic Island, and Home Indicator.

**Visual Inspector**:
Enable `enableInspector: true` in your `EdgeGuardConfig` to overlay a visual diagnostics report button in development.

### 2. Project Doctor CLI

Analyze your Flutter project structure, Gradle files, AndroidManifest, and Dart source for common edge-to-edge legacy bugs or legacy back-handling patterns.

Run from your project root:
```bash
dart run flutter_edge_guard:doctor
```

**CI Mode**:
You can run the doctor in your CI/CD pipelines (e.g., GitHub Actions) using the `--fail-on` flag:

```bash
dart run flutter_edge_guard:doctor --json --fail-on=warning
```
* `--json`: Outputs a machine-readable JSON report.
* `--fail-on=<warning|critical>`: Exits with a non-zero status code if issues of that severity are found.

### 3. Smart Widgets

* `EdgeGuardBottomAction`: A wrapper for buttons attached to the bottom of the screen.
* `EdgeGuardBottomSheet`: Helpers for creating edge-to-edge safe bottom sheets.

## Limitations

* **Navigation Mode Detection**: Navigation mode detection on Android (Gesture vs 3-Button) is heuristic and will often be reported as `unknown` or `possible`. `flutter_edge_guard` intentionally does not read undocumented system settings to improve accuracy, adhering to strict pub.dev public API compliance.

## Testing

EdgeGuard employs a split testing methodology:

* **Tier 1 — Widget/unit tests (CI, every commit)**: Simulates inset scenarios by constructing fake `MediaQueryData`/`ViewPadding` values representative of what each Android version *typically* produces.
* **Tier 2 — Integration tests (manual/scheduled, not every commit)**: Real Android emulator/device runs for a small representative matrix (e.g., API 26, API 34, API 36) to validate actual OS-reported insets. This requires local emulator setup. See `test/integration/README.md`.

## Related Packages / Roadmap

The following related packages are planned for future releases (v0.2+) and are currently out-of-scope for v0.1:
* `flutter_edge_guard_lints`: A `custom_lint` plugin to flag hardcoded inset patterns directly in the IDE.
* `test_utils`: A set of pre-built `MediaQueryData` test fixtures.
