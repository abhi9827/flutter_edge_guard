import 'package:flutter/widgets.dart';

import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

/// Detects common iOS-specific edge-to-edge issues.
class IosDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo info,
  ) {
    final issues = <EdgeGuardIssue>[];

    // Home Indicator Overlap
    // On iOS, the viewPadding.bottom or padding.bottom is usually > 0 on devices with a home indicator.
    if (info.padding.bottom > 0) {
      issues.add(
        const EdgeGuardIssue(
          type: EdgeGuardIssueType.iosHomeIndicatorOverlap,
          severity: EdgeGuardSeverity.warning,
          confidence: EdgeGuardConfidence.possible,
          title: 'Home Indicator Overlap',
          problem: 'Content may overlap the iOS home indicator.',
          evidence: 'bottom padding > 0',
          recommendation:
              'Ensure bottom content is padded by at least the system bottom padding.',
        ),
      );
    }

    // Notch / Dynamic Island Overlap
    // Top padding on modern iOS devices usually indicates the notch or dynamic island.
    if (info.padding.top > 20) {
      issues.add(
        const EdgeGuardIssue(
          type: EdgeGuardIssueType.iosNotchOverlap,
          severity: EdgeGuardSeverity.warning,
          confidence: EdgeGuardConfidence.possible,
          title: 'Notch / Dynamic Island Overlap',
          problem: 'Content may overlap the iOS notch or Dynamic Island.',
          evidence: 'top padding > 20',
          recommendation:
              'Use EdgeGuard top protection or ensure top content is padded by the system top padding.',
        ),
      );
    }

    return issues;
  }
}
