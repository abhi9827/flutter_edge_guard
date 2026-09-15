import 'edge_guard_navigation_mode.dart';

/// Information about the current platform and its edge-to-edge capabilities.
class EdgeGuardPlatformInfo {
  /// The operating system (e.g., android, ios).
  final String platform;

  /// True if running on Android.
  final bool isAndroid;

  /// True if running on iOS.
  final bool isIOS;

  /// True if running on the Web.
  final bool isWeb;

  /// True if running on a desktop platform (macOS, Windows, Linux).
  final bool isDesktop;

  /// The Android SDK version, if available and reliably determined at runtime.
  /// Otherwise, null.
  final int? androidSdkInt;

  /// The target SDK version, if available and reliably determined at runtime.
  /// Otherwise, null.
  final int? targetSdk;

  /// The compile SDK version, if available and reliably determined at runtime.
  /// Otherwise, null.
  final int? compileSdk;

  /// The heuristic navigation mode in use.
  final EdgeGuardNavigationMode navigationMode;

  /// Whether the window size indicates a large screen (e.g., tablet).
  final bool isLargeScreen;

  /// Whether the display appears to be foldable or has a hinge.
  final bool isFoldable;

  /// Whether the application appears to be running in multi-window mode.
  final bool isMultiWindow;

  const EdgeGuardPlatformInfo({
    required this.platform,
    required this.isAndroid,
    required this.isIOS,
    required this.isWeb,
    required this.isDesktop,
    this.androidSdkInt,
    this.targetSdk,
    this.compileSdk,
    required this.navigationMode,
    required this.isLargeScreen,
    required this.isFoldable,
    required this.isMultiWindow,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'isAndroid': isAndroid,
      'isIOS': isIOS,
      'isWeb': isWeb,
      'isDesktop': isDesktop,
      'androidSdkInt': androidSdkInt ?? 'unavailable',
      'targetSdk': targetSdk ?? 'unavailable',
      'compileSdk': compileSdk ?? 'unavailable',
      'navigationMode': navigationMode.name,
      'isLargeScreen': isLargeScreen,
      'isFoldable': isFoldable,
      'isMultiWindow': isMultiWindow,
    };
  }
}
