/// Categories of issues that EdgeGuard can detect.
enum EdgeGuardIssueType {
  /// Content is likely overlapping or competing with the status bar.
  statusBarOverlap,

  /// Content is likely overlapping the navigation bar.
  navigationBarOverlap,

  /// Content/actions may conflict with the system gesture area.
  gestureAreaConflict,

  /// The keyboard (IME) is overlapping content.
  keyboardOverlap,

  /// Content is drawn into the physical display cutout/notch.
  displayCutout,

  /// System bar colors may lack sufficient contrast with content.
  systemBarContrast,

  /// System bar readability may be compromised in edge-to-edge mode.
  systemBarReadability,

  /// An issue with edge-to-edge configuration.
  edgeToEdgeConfiguration,

  /// Application is using fullscreen/immersive mode.
  fullscreenMode,

  /// The layout may not be adapted for large screens.
  largeScreen,

  /// Orientation-related issue.
  orientation,

  /// iOS specific: Content overlaps the home indicator.
  iosHomeIndicatorOverlap,

  /// iOS specific: Content overlaps the notch or Dynamic Island.
  iosNotchOverlap,

  /// The application is in a multi-window environment.
  multiWindow,

  /// Usage of legacy predictive back patterns (e.g., WillPopScope).
  predictiveBack,

  /// Padding applied redundantly (e.g., nested SafeAreas or manual + SafeArea)
  doublePadding,

  /// Detectable hardcoded inset values.
  hardcodedInset,

  /// A SafeArea nested within another SafeArea.
  nestedSafeArea,

  /// Interactive elements placed too close to system gesture zones,
  /// potentially conflicting with accessibility use patterns.
  accessibilityTouchTarget,

  /// An unknown or uncategorized issue.
  unknown,
}
