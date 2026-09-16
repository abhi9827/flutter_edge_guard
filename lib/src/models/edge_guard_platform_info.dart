import 'edge_guard_navigation_mode.dart';

/// Information about the current platform and its edge-to-edge capabilities.
///
/// All fields are derived from Flutter's stable public APIs (`kIsWeb`,
/// `defaultTargetPlatform`, and `MediaQuery` insets/size).
///
/// **No `dart:io` dependency** — this model works on every Flutter target:
/// Android, iOS, Web, macOS, Windows, Linux, and Fuchsia.
class EdgeGuardPlatformInfo {
  /// The operating system name (e.g., 'android', 'ios', 'web', 'windows',
  /// 'linux', 'macos').
  final String platform;

  /// True if running on Android.
  final bool isAndroid;

  /// True if running on iOS.
  final bool isIOS;

  /// True if running in a web browser (via `kIsWeb`).
  final bool isWeb;

  /// True if running on a desktop OS (macOS, Windows, or Linux).
  final bool isDesktop;

  /// True if running on macOS (desktop).
  final bool isMacOS;

  /// True if running on Windows (desktop).
  final bool isWindows;

  /// True if running on Linux (desktop).
  final bool isLinux;

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

  /// Whether the window size indicates a large screen (e.g., tablet, desktop).
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
    this.isMacOS = false,
    this.isWindows = false,
    this.isLinux = false,
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
      'isMacOS': isMacOS,
      'isWindows': isWindows,
      'isLinux': isLinux,
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
