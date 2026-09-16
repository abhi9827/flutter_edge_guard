import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

class InsetDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    // Detect missing edge-to-edge configuration on Android 15/16 (heuristically).
    // If we are on Android and padding is 0 but it's not a fullscreen app (handled elsewhere),
    // it might be a legacy app forced into edge-to-edge by Android 15+
    // or a non-edge-to-edge app.
    // Edge-to-edge enforcement only applies to Android. On other platforms
    // (iOS uses safe area, desktop has window chrome, web uses CSS),
    // zero padding is normal and should not be flagged.
    if (platform.isAndroid && !insets.isEdgeToEdge) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.edgeToEdgeConfiguration,
          title: 'Edge-to-Edge Disabled or Unavailable',
          problem:
              'The application is not reporting top/bottom safe area insets.',
          evidence:
              'padding.top = ${insets.padding.top}, padding.bottom = ${insets.padding.bottom}',
          recommendation:
              'Verify that edge-to-edge is properly enabled (e.g. using SystemChrome.setEnabledSystemUIMode or Android WindowCompat). Android 15+ enforces edge-to-edge by default.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    // Status bar overlap risk
    if (insets.isEdgeToEdge && insets.statusBars.top > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.statusBarOverlap,
          title: 'Status Bar Overlap Risk',
          problem:
              'Top content may be drawing behind the transparent status bar.',
          evidence: 'statusBars.top = ${insets.statusBars.top}',
          recommendation:
              'Ensure top-aligned widgets use SafeArea or EdgeGuard padding if they contain text or interactive elements.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    return issues;
  }
}
