## 0.1.0

- Initial release.
- Added Android edge-to-edge diagnostics.
- Added inset inspection (`EdgeInsetsInfo`).
- Added bottom action protection (`EdgeGuardBottomAction`).
- Added bottom sheet protection (`EdgeGuardBottomSheet`).
- Added keyboard/IME awareness.
- Added navigation mode diagnostics.
- Added display cutout diagnostics.
- Added fullscreen & large screen heuristics using `DisplayFeatures`.
- Added iOS home indicator and notch overlap detection.
- Added `flutter_edge_guard:doctor` CLI command with JSON output and CI failure options.
- **Breaking/Constraint**: Minimum supported Flutter version is `3.35.0` and Dart SDK `3.9.0` to ensure access to stable `MediaQueryData.paddingOf` and `PopScope` API access.
