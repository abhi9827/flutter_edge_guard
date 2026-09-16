import 'package:flutter/services.dart' show SystemChrome;

import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

/// Detects potential system bar readability and contrast issues in
/// edge-to-edge mode.
///
/// When an app goes edge-to-edge, light-colored content (e.g., a white
/// background or bright image) can scroll behind the status bar and navigation
/// bar. This makes white system icons invisible against the bright background.
///
/// The detector does NOT read or change [SystemChrome] colors. It only
/// inspects the inset model to determine if edge-to-edge is active and
/// flags the areas that may require a scrim or explicit contrast handling.
class ContrastDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    // Only meaningful in edge-to-edge mode.
    if (!insets.isEdgeToEdge) return issues;

    // Status bar contrast: when there is a top inset > 0, content may be
    // drawn behind the status bar. System icons need readable contrast.
    if (insets.statusBars.top > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.systemBarReadability,
          title: 'Status Bar Readability',
          problem:
              'The app is running edge-to-edge with content drawn behind the status bar. '
              'Light-colored content may make system bar icons unreadable.',
          evidence:
              'isEdgeToEdge = true, statusBars.top = ${insets.statusBars.top}',
          recommendation:
              'Use EdgeGuardScrim(edge: EdgeGuardScrimEdge.top) to add a gradient scrim '
              'over the status bar, or ensure your AppBar has sufficient background color contrast. '
              'For scrollable content, consider a semi-transparent status bar background.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    // Navigation bar contrast: similar issue at the bottom.
    if (insets.navigationBars.bottom > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.systemBarReadability,
          title: 'Navigation Bar Readability',
          problem:
              'The app is running edge-to-edge with content drawn behind the navigation bar. '
              'Light-colored content may make navigation icons or the home pill unreadable.',
          evidence:
              'isEdgeToEdge = true, navigationBars.bottom = ${insets.navigationBars.bottom}',
          recommendation:
              'Use EdgeGuardScrim(edge: EdgeGuardScrimEdge.bottom) or ensure your bottom '
              'content has sufficient contrast against the navigation bar icons.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    return issues;
  }
}
