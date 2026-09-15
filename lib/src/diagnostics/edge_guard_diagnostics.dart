import 'package:flutter/widgets.dart';

import '../../flutter_edge_guard.dart';
import 'detectors/cutout_detector.dart';
import 'detectors/fullscreen_detector.dart';
import 'detectors/inset_detector.dart';
import 'detectors/keyboard_detector.dart';
import 'detectors/large_screen_detector.dart';
import 'detectors/navigation_detector.dart';
import 'detectors/ios_detector.dart';

/// The core diagnostics engine for EdgeGuard.
class EdgeGuardDiagnostics {
  /// Inspects the current [context] and generates an [EdgeGuardReport].
  ///
  /// This must be called from a widget that is a descendant of [EdgeGuard]
  /// or [EdgeGuardScope]. If no scope is found, it will attempt to extract
  /// basic information using [MediaQuery], but diagnostics will be limited.
  static EdgeGuardReport inspect(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);

    // We cannot proceed robustly without a scope, but we shouldn't crash.
    if (scope == null) {
      throw StateError(
        'EdgeGuardDiagnostics.inspect called with a context that does not contain an EdgeGuardScope. '
        'Ensure you have wrapped your app or page in an EdgeGuard widget.',
      );
    }

    final platformInfo = scope.platformInfo;
    final insetsInfo = scope.insetsInfo;
    final issues = <EdgeGuardIssue>[];

    // Run detectors
    issues.addAll(FullscreenDetector.detect(insetsInfo, platformInfo));

    // If not immersive/fullscreen, we run normal layout detectors.
    final isFullscreen = issues.any(
      (i) => i.type == EdgeGuardIssueType.fullscreenMode,
    );

    if (!isFullscreen) {
      issues.addAll(InsetDetector.detect(insetsInfo, platformInfo));
      issues.addAll(NavigationDetector.detect(insetsInfo, platformInfo));
      issues.addAll(CutoutDetector.detect(insetsInfo, platformInfo));
    }

    issues.addAll(KeyboardDetector.detect(insetsInfo, platformInfo));
    issues.addAll(LargeScreenDetector.detect(insetsInfo, platformInfo));

    if (platformInfo.isIOS) {
      issues.addAll(IosDetector.detect(context, insetsInfo));
    }

    return EdgeGuardReport(
      timestamp: DateTime.now().toUtc().toIso8601String(),
      platformInfo: platformInfo,
      insetsInfo: insetsInfo,
      issues: issues,
    );
  }
}
