import 'package:flutter/widgets.dart';

import '../../flutter_edge_guard.dart';
import 'detectors/accessibility_detector.dart';
import 'detectors/contrast_detector.dart';
import 'detectors/cutout_detector.dart';
import 'detectors/desktop_detector.dart';
import 'detectors/fullscreen_detector.dart';
import 'detectors/inset_detector.dart';
import 'detectors/ios_detector.dart';
import 'detectors/keyboard_detector.dart';
import 'detectors/large_screen_detector.dart';
import 'detectors/navigation_detector.dart';
import 'detectors/web_pwa_detector.dart';

/// The core diagnostics engine for EdgeGuard.
class EdgeGuardDiagnostics {
  /// Inspects the current [context] and generates an [EdgeGuardReport].
  ///
  /// This must be called from a widget that is a descendant of [EdgeGuard]
  /// or [EdgeGuardScope]. If no scope is found, it will throw [StateError].
  ///
  /// For safe nullable access use [tryInspect] instead.
  static EdgeGuardReport inspect(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);

    if (scope == null) {
      throw StateError(
        'EdgeGuardDiagnostics.inspect called with a context that does not '
        'contain an EdgeGuardScope. Ensure you have wrapped your app or page '
        'in an EdgeGuard widget.',
      );
    }

    return _runDetectors(scope);
  }

  /// Inspects the current [context] and returns null if no [EdgeGuardScope]
  /// is found, rather than throwing.
  static EdgeGuardReport? tryInspect(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);
    if (scope == null) return null;
    return _runDetectors(scope);
  }

  static EdgeGuardReport _runDetectors(EdgeGuardScope scope) {
    final platformInfo = scope.platformInfo;
    final insetsInfo = scope.insetsInfo;
    final issues = <EdgeGuardIssue>[];

    // Fullscreen check runs first — many other detectors should be skipped
    // in genuine fullscreen/immersive mode.
    issues.addAll(FullscreenDetector.detect(insetsInfo, platformInfo));

    final isFullscreen = issues.any(
      (i) => i.type == EdgeGuardIssueType.fullscreenMode,
    );

    if (!isFullscreen) {
      issues.addAll(InsetDetector.detect(insetsInfo, platformInfo));
      issues.addAll(NavigationDetector.detect(insetsInfo, platformInfo));
      issues.addAll(CutoutDetector.detect(insetsInfo, platformInfo));
      issues.addAll(ContrastDetector.detect(insetsInfo, platformInfo));
    }

    issues.addAll(KeyboardDetector.detect(insetsInfo, platformInfo));
    issues.addAll(LargeScreenDetector.detect(insetsInfo, platformInfo));
    issues.addAll(AccessibilityDetector.detect(insetsInfo, platformInfo));
    issues.addAll(WebPwaDetector.detect(insetsInfo, platformInfo));
    issues.addAll(DesktopDetector.detect(insetsInfo, platformInfo));

    if (platformInfo.isIOS) {
      issues.addAll(IosDetector.detect(insetsInfo));
    }

    return EdgeGuardReport(
      timestamp: DateTime.now().toUtc().toIso8601String(),
      platformInfo: platformInfo,
      insetsInfo: insetsInfo,
      issues: issues,
    );
  }
}
