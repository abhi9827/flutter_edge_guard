import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/edge_guard_config.dart';
import '../core/edge_guard_scope.dart';
import '../models/edge_guard_navigation_mode.dart';
import '../models/edge_guard_platform_info.dart';
import '../models/edge_insets_info.dart';
import '../widgets/edge_guard_debug_overlay_widget.dart'; // We will create this later

/// The root widget that establishes the edge-to-edge environment.
///
/// [EdgeGuard] extracts granular [MediaQuery] properties such as
/// `paddingOf`, `viewPaddingOf`, `viewInsetsOf`, and `displayFeaturesOf`,
/// constructs an [EdgeInsetsInfo] model, and provides it to descendants
/// via [EdgeGuardScope].
///
/// It does **not** automatically apply `SafeArea` padding. It provides the
/// diagnostic foundation and configuration for other `EdgeGuard` widgets.
class EdgeGuard extends StatelessWidget {
  /// The configuration for EdgeGuard.
  final EdgeGuardConfig config;

  /// The widget below this widget in the tree.
  final Widget child;

  const EdgeGuard({
    super.key,
    this.config = EdgeGuardConfig.standard,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Reactive granular access (fixes over-rebuilding and ensures latest data)
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final displayFeatures = MediaQuery.displayFeaturesOf(context);
    final systemGestureInsets = MediaQuery.systemGestureInsetsOf(context);
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);

    // 2. Synthesize detailed insets
    // These mappings are heuristic approximations of native Android WindowInsets.
    // Real devices may vary slightly, but we use the stable Flutter signals available.

    // Status Bars: Usually represented by the top padding.
    final statusBars = EdgeInsets.only(top: padding.top);

    // Navigation Bars: Use viewPadding for bottom since it preserves the nav
    // bar inset even when the keyboard is open (unlike padding.bottom which
    // collapses to 0 while the IME is visible).
    final navigationBars = EdgeInsets.only(
      bottom: math.max(padding.bottom, viewPadding.bottom),
      left: math.max(padding.left, viewPadding.left),
      right: math.max(padding.right, viewPadding.right),
    );

    // System Gestures: Flutter provides these explicitly. Fall back to
    // navigationBars if the value is zero (common in emulators and tests).
    final rawSystemGestures = systemGestureInsets;
    final systemGestures = (rawSystemGestures.left == 0 &&
            rawSystemGestures.right == 0 &&
            rawSystemGestures.bottom == 0 &&
            rawSystemGestures.top == 0)
        ? navigationBars
        : rawSystemGestures;

    // Mandatory System Gestures: A subset of systemGestures.
    final mandatorySystemGestures = navigationBars;

    // Tappable Element: Corresponds roughly to padding.
    final tappableElement = padding;

    // IME (Keyboard): Derived from viewInsets.
    final ime = EdgeInsets.only(bottom: viewInsets.bottom);
    final keyboardVisible = viewInsets.bottom > 0;

    // Display Cutout: Extracted from display features.
    var displayCutout = EdgeInsets.zero;
    for (final feature in displayFeatures) {
      if (feature.type == DisplayFeatureType.cutout) {
        // Very basic cutout mapping; a robust implementation would intersect bounds.
        displayCutout = EdgeInsets.only(
          top: feature.bounds.top == 0 ? feature.bounds.height : 0,
        );
      }
    }

    // isEdgeToEdge: True when the app is drawing behind BOTH the status bar
    // and navigation bar (the canonical edge-to-edge definition).
    //
    // Detection strategy (all three signals are checked for robustness):
    //  • padding.top > 0           → app draws behind the status bar
    //  • effectiveBottom > 0       → padding.bottom or viewPadding.bottom carries
    //                                 the nav bar inset (3-button / 2-button nav)
    //  • systemGestureInsets.bottom > 0 → gesture-navigation mode: Android
    //                                     reports only a thin gesture strip here,
    //                                     NOT in padding.bottom, so this is the
    //                                     correct signal for gesture-nav edge-to-edge.
    //
    // Any of the bottom indicators being nonzero, combined with top > 0,
    // means the OS is handing us the insets → edge-to-edge is active.
    final effectiveBottom = math.max(padding.bottom, viewPadding.bottom);
    final gestureNavBottom = systemGestureInsets.bottom;
    final isEdgeToEdge =
        padding.top > 0 && (effectiveBottom > 0 || gestureNavBottom > 0);

    final insetsInfo = EdgeInsetsInfo(
      statusBars: statusBars,
      navigationBars: navigationBars,
      systemGestures: systemGestures,
      mandatorySystemGestures: mandatorySystemGestures,
      tappableElement: tappableElement,
      ime: ime,
      displayCutout: displayCutout,
      captionBar: EdgeInsets.zero,
      waterfall: EdgeInsets.zero,
      padding: padding,
      viewPadding: viewPadding,
      viewInsets: viewInsets,
      keyboardVisible: keyboardVisible,
      isEdgeToEdge: isEdgeToEdge,
      windowSize: size,
      orientation: orientation,
      displayFeatures: displayFeatures,
    );

    // 3. Determine Platform Info
    const isWeb = kIsWeb;
    // Use defaultTargetPlatform (works on all platforms including web).
    // dart:io Platform is intentionally NOT used here so the package
    // compiles and runs on web, Windows, Linux, and macOS.
    final isAndroid = !isWeb && defaultTargetPlatform == TargetPlatform.android;
    final isIOS = !isWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final isMacOS = !isWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final isWindows = !isWeb && defaultTargetPlatform == TargetPlatform.windows;
    final isLinux = !isWeb && defaultTargetPlatform == TargetPlatform.linux;
    final isDesktop = isMacOS || isWindows || isLinux;

    // Large screen / Foldable detection using stable displayFeatures / size heuristics.
    final isLargeScreen = size.width >= 600;

    var isFoldable = false;
    for (final feature in displayFeatures) {
      if (feature.type == DisplayFeatureType.fold ||
          feature.type == DisplayFeatureType.hinge) {
        isFoldable = true;
        break;
      }
    }

    // Navigation mode heuristic:
    // If we have bottom padding but no substantial side padding, and it's small (~16-24),
    // it might be gesture. If it's larger (~48), it might be 3-button.
    var navMode = EdgeGuardNavigationMode.unknown;
    if (isAndroid) {
      if (effectiveBottom > 0 && effectiveBottom < 30) {
        navMode = EdgeGuardNavigationMode.gesture;
      } else if (effectiveBottom >= 30) {
        navMode = EdgeGuardNavigationMode.threeButton;
      }
    }

    final platformInfo = EdgeGuardPlatformInfo(
      platform: isWeb ? 'web' : defaultTargetPlatform.name.toLowerCase(),
      isAndroid: isAndroid,
      isIOS: isIOS,
      isWeb: isWeb,
      isDesktop: isDesktop,
      isMacOS: isMacOS,
      isWindows: isWindows,
      isLinux: isLinux,
      androidSdkInt:
          null, // We avoid native calls for this unless specifically requested via platform channel later, but keeping null avoids async build issues.
      targetSdk: null,
      compileSdk: null,
      navigationMode: navMode,
      isLargeScreen: isLargeScreen,
      isFoldable: isFoldable,
      isMultiWindow:
          false, // Cannot be reliably detected synchronously via pure Dart
    );

    // 4. Build Scope
    Widget scopedChild = EdgeGuardScope(
      config: config,
      insetsInfo: insetsInfo,
      platformInfo: platformInfo,
      child: child,
    );

    // 5. Optionally inject Debug Overlay
    if (config.enableDebugOverlay &&
        (!config.debugOnlyInspector || kDebugMode)) {
      scopedChild = EdgeGuardDebugOverlayWidget(child: scopedChild);
    }

    return scopedChild;
  }
}
