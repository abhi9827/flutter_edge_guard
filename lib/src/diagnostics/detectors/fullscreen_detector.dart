import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

class FullscreenDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    // If both top and bottom insets are exactly 0 on a mobile device,
    // it strongly suggests an immersive or fullscreen mode.
    if (platform.isAndroid || platform.isIOS) {
      if (insets.padding.top == 0 &&
          insets.padding.bottom == 0 &&
          !insets.keyboardVisible) {
        issues.add(
          const EdgeGuardIssue(
            severity: EdgeGuardSeverity.info,
            type: EdgeGuardIssueType.fullscreenMode,
            title: 'Fullscreen/Immersive Mode',
            problem:
                'Application appears to be using fullscreen/immersive mode.',
            evidence: 'padding.top = 0 and padding.bottom = 0.',
            recommendation:
                'EdgeGuard will not treat missing normal system insets as an error.',
            confidence: EdgeGuardConfidence.possible,
          ),
        );
      }
    }

    return issues;
  }
}
