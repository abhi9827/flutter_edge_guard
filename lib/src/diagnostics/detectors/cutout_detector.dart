import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

class CutoutDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    if (insets.displayCutout.top > 0 ||
        insets.displayCutout.bottom > 0 ||
        insets.displayCutout.left > 0 ||
        insets.displayCutout.right > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.displayCutout,
          title: 'Display Cutout Overlap',
          problem: 'Content may draw into the physical display cutout/notch.',
          evidence: 'displayCutout is non-zero: ${insets.displayCutout}',
          recommendation:
              'Ensure content respects safe area boundaries in landscape or near top edges.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    return issues;
  }
}
