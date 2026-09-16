# flutter_edge_guard

[![pub package](https://img.shields.io/pub/v/flutter_edge_guard.svg)](https://pub.dev/packages/flutter_edge_guard)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)

Understand and fix modern Android edge-to-edge UI problems. An edge-to-edge protection layer, diagnostics engine, and developer project doctor for Flutter.

Answers a single, vital question for developers:
**"Why is my Flutter UI broken near the edge?"**

---

## Table of Contents

- [Why Android 15 & 16 Matter](#why-android-15--16-matter)
- [Key Features](#key-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration Reference](#configuration-reference)
- [Widgets in Detail](#widgets-in-detail)
  - [EdgeGuard (Root Provider)](#1-edgeguard-root-provider)
  - [EdgeGuardBottomAction](#2-edgeguardbottomaction)
  - [EdgeGuardAnimatedAction](#3-edgeguardanimatedaction)
  - [EdgeGuardBottomSheet](#4-edgeguardbottomsheet)
  - [EdgeGuardScrim](#5-edgeguardscrim)
  - [EdgeGuardInspector](#6-edgeguardinspector)
  - [EdgeGuardZoneOverlay](#7-edgeguardzoneoverlay)
- [Diagnostics Engine](#diagnostics-engine)
- [Project Doctor CLI](#project-doctor-cli)
- [Limitations](#limitations)
- [License](#license)

---

## Why Android 15 & 16 Matter

Starting with **Android 15 (API 35)**, Google enforces edge-to-edge window behavior for applications targeting the new SDK:
* Status and navigation bars become transparent by default.
* Your application content draws *behind* these system bars.
* Old assumptions about automatic window offsets break.

In **Android 16 (API 36)**, edge-to-edge opt-outs are further restricted, and predictive back gestures become a stronger platform default.

> **Note**: `EdgeGuard` does not disable edge-to-edge; it helps you build correctly for it without introducing double-padding or broken gesture interactions.

---

## Key Features

- 🛡️ **Intelligent Protection**: Automatically prevents bottom actions and bottom sheets from overlapping navigation bars or the keyboard without causing duplicate `SafeArea` padding.
- ⚡ **Animated Keyboard Handling**: Smoothly animates bottom-docked actions when the on-screen keyboard (IME) appears or dismisses.
- 🎨 **System Bar Scrims**: Dynamic gradient overlays for status and navigation bars ensuring icon and text contrast against arbitrary content.
- 🔍 **Real-Time Diagnostics Engine**: Inspects system gestures, navigation modes (3-button, 2-button, gesture), display cutouts, foldables, iOS notches, and Dynamic Island.
- 🐞 **Floating Debug Inspector**: On-screen developer tool to visualize active insets, collision zones, and export JSON diagnostic reports.
- 🩺 **Project Doctor CLI**: Scans Android manifests, Gradle configurations, and Dart code for common edge-to-edge deprecations and pitfalls.

---

## Requirements

* **Dart SDK**: `>=3.5.0 <4.0.0`
* **Flutter**: `>=3.24.0`

---

## Installation

Add `flutter_edge_guard` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_edge_guard: ^0.1.0
```

Or run:

```bash
flutter pub add flutter_edge_guard
```

---

## Quick Start

Wrap your root widget with `EdgeGuard`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';

void main() {
  runApp(
    const EdgeGuard(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdgeGuard Demo',
      home: const HomeScreen(),
    );
  }
}
```

---

## Configuration Reference

`EdgeGuardConfig` allows you to customize the behavior of the protection layer. By default, core protections (`protectBottomActions`, `protectBottomSheets`) are active, while developer tools remain opt-in:

```dart
const EdgeGuard(
  config: EdgeGuardConfig(
    protectBottomActions: true,  // Default: true
    protectBottomSheets: true,   // Default: true
    enableDiagnostics: false,    // Default: false
    enableInspector: false,      // Default: false
    enableDebugOverlay: false,   // Default: false
    showWarnings: false,         // Default: false
    debugOnlyInspector: false,   // Default: false
  ),
  child: MyApp(),
)
```

| Option | Type | Default | Description |
|---|---|---|---|
| `protectBottomActions` | `bool` | `true` | Enables automatic bottom inset protection in `EdgeGuardBottomAction`. |
| `protectBottomSheets` | `bool` | `true` | Enables automatic safe inset padding in `EdgeGuardBottomSheet`. |
| `enableDiagnostics` | `bool` | `false` | Enables real-time runtime diagnostics analysis. |
| `enableInspector` | `bool` | `false` | Enables the floating interactive inspector UI. |
| `enableDebugOverlay` | `bool` | `false` | Displays visual system inset zones directly on screen. |
| `showWarnings` | `bool` | `false` | Prints diagnostic warnings to the debug console. |
| `debugOnlyInspector` | `bool` | `false` | Limits inspector visibility strictly to debug builds (`kDebugMode`). |

---

## Widgets in Detail

### 1. EdgeGuard (Root Provider)
Extracts granular `MediaQuery` data (`paddingOf`, `viewPaddingOf`, `viewInsetsOf`, `systemGestureInsetsOf`, `displayFeaturesOf`) and shares an immutable `EdgeInsetsInfo` snapshot via `EdgeGuardScope`.

```dart
EdgeGuard(
  config: const EdgeGuardConfig.standard,
  child: MyHomePage(),
)
```

### 2. EdgeGuardBottomAction
Wraps bottom-anchored widgets (e.g. submit buttons, persistent footers) to ensure they never clip beneath navigation bars, while preventing accidental double-padding when nested under existing `SafeArea`s.

```dart
Scaffold(
  body: const ContentList(),
  bottomNavigationBar: EdgeGuardBottomAction(
    padding: const EdgeInsets.all(16.0),
    child: FilledButton(
      onPressed: () {},
      child: const Text('Submit'),
    ),
  ),
);
```

### 3. EdgeGuardAnimatedAction
Smoothly animates bottom-docked action bars when the keyboard opens or closes:

```dart
EdgeGuardAnimatedAction(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeOutCubic,
  padding: const EdgeInsets.all(16),
  child: FilledButton(
    onPressed: () {},
    child: const Text('Save Changes'),
  ),
)
```

### 4. EdgeGuardBottomSheet
A drop-in container for modal bottom sheets that respects both gesture navigation bars and keyboard insets:

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => EdgeGuardBottomSheet(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('Safe Bottom Sheet'),
        TextField(decoration: InputDecoration(labelText: 'Type here')),
      ],
    ),
  ),
);
```

### 5. EdgeGuardScrim
Draws a subtle, non-interactive gradient behind translucent status or navigation bars to maintain WCAG contrast ratios across arbitrary app backgrounds:

```dart
Stack(
  children: [
    const ColorfulBackground(),
    const EdgeGuardScrim(
      edge: EdgeGuardScrimEdge.both, // .top, .bottom, or .both
      maxOpacity: 0.4,
    ),
    const Scaffold(backgroundColor: Colors.transparent, body: MainContent()),
  ],
)
```

### 6. EdgeGuardInspector
Enables an interactive floating debug panel to inspect system insets, view identified conflicts, and export JSON diagnostics:

```dart
EdgeGuard(
  config: const EdgeGuardConfig(enableInspector: true),
  child: const EdgeGuardInspector(
    child: MyApp(),
  ),
)
```

### 7. EdgeGuardZoneOverlay
Visually renders color-coded overlays for status bars (red), navigation bars (blue), gesture areas (orange), and cutouts (purple) in development mode.

---

## Diagnostics Engine

Inspect the current window state programmatically at any point in the widget tree:

```dart
final report = EdgeGuardDiagnostics.inspect(context);

print('Active Insets: ${report.insets}');
print('Navigation Mode: ${report.platform.navigationMode}');
print('Issues Detected: ${report.issues.length}');

for (final issue in report.issues) {
  print('[${issue.severity.name}] ${issue.title}: ${issue.problem}');
  print('Suggested Fix: ${issue.solution}');
}
```

Or use the non-throwing variant:

```dart
final report = EdgeGuardDiagnostics.tryInspect(context);
```

---

## Project Doctor CLI

`flutter_edge_guard` includes a static analyzer CLI to audit your project for edge-to-edge readiness.

### Run Locally

```bash
dart run flutter_edge_guard:doctor
```

### CI/CD Integration

Run with strict exit codes in GitHub Actions or other CI pipelines:

```bash
dart run flutter_edge_guard:doctor --json --fail-on=warning
```

#### Flags:
- `--json`: Outputs machine-readable JSON.
- `--fail-on=<warning|critical>`: Exits with a non-zero exit code if issues at or above the threshold are detected.
- `--path=<directory>`: Analyzes a specific project directory.

---

## Limitations

- **Navigation Mode Heuristics**: Android gesture navigation detection relies on platform signals (`systemGestureInsets`, `viewPadding`). While highly accurate on modern devices, it is heuristic and does not access non-public OS APIs.
- **Web & Desktop Targets**: Insets are reported as zero or desktop-appropriate window paddings since edge-to-edge system bar overlaps do not apply to desktop/browser window frames.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
