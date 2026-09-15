import 'dart:io' show Platform;
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

    // Navigation Bars: Usually the bottom padding if viewInsets.bottom is 0.
    final navigationBars = EdgeInsets.only(
      bottom: padding.bottom,
      left: padding.left,
      right: padding.right,
    );

    // System Gestures: Provided explicitly by Flutter now.
    final systemGestures = systemGestureInsets;

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

    final isEdgeToEdge = padding.bottom > 0 || padding.top > 0;

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
    final isAndroid = !isWeb && Platform.isAndroid;
    final isIOS = !isWeb && Platform.isIOS;
    final isDesktop =
        !isWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

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
      if (padding.bottom > 0 && padding.bottom < 30) {
        navMode = EdgeGuardNavigationMode.gesture;
      } else if (padding.bottom >= 30) {
        navMode = EdgeGuardNavigationMode.threeButton;
      }
    }

    final platformInfo = EdgeGuardPlatformInfo(
      platform: isWeb ? 'web' : Platform.operatingSystem,
      isAndroid: isAndroid,
      isIOS: isIOS,
      isWeb: isWeb,
      isDesktop: isDesktop,
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
