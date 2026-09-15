import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

class LargeScreenDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    if (platform.isLargeScreen || platform.isFoldable) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.largeScreen,
          title: 'Large Screen Detected',
          problem:
              'Window size or display features indicate a large screen or foldable device.',
          evidence:
              'isLargeScreen = ${platform.isLargeScreen}, isFoldable = ${platform.isFoldable}, size = ${insets.windowSize}',
          recommendation:
              'Review layouts that assume phone-sized portrait dimensions. Consider split-screen or multi-pane layouts.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    if (insets.windowSize.width > insets.windowSize.height &&
        platform.isAndroid &&
        !platform.isLargeScreen) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.orientation,
          title: 'Landscape Orientation',
          problem: 'Device is in landscape mode.',
          evidence:
              'width (${insets.windowSize.width}) > height (${insets.windowSize.height})',
          recommendation:
              'Ensure scroll views and edge insets handle landscape constraints properly.',
          confidence: EdgeGuardConfidence.informational,
        ),
      );
    }

    return issues;
  }
}
