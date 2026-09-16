# Changelog

## 0.1.0

- Initial stable release of `flutter_edge_guard`.
- **Core Provider**:
  - `EdgeGuard`: Granular `MediaQuery` extraction and scoped inset propagation.
  - `EdgeGuardConfig`: Customizable runtime configuration flags.
- **Smart Protection Widgets**:
  - `EdgeGuardBottomAction`: Prevents bottom buttons from clipping beneath navigation bars without double-padding.
  - `EdgeGuardAnimatedAction`: Smooth keyboard/IME awareness animations for bottom actions.
  - `EdgeGuardBottomSheet`: Edge-safe modal bottom sheet wrapper.
  - `EdgeGuardScrim`: Dynamic status and navigation bar contrast scrims.
- **Developer & Diagnostics Tools**:
  - `EdgeGuardInspector`: Floating debug inspector overlay with real-time issue detection and JSON export.
  - `EdgeGuardZoneOverlay`: Color-coded visual overlay for system insets and gesture zones.
  - `EdgeGuardDiagnostics`: Comprehensive programmatic analyzer for gesture collisions, keyboard overlaps, contrast, iOS Dynamic Island/notch insets, foldables, and accessibility.
- **CLI Doctor**:
  - `flutter_edge_guard:doctor`: Static analysis CLI with `--json` and `--fail-on` for CI/CD pipelines.
