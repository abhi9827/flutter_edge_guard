import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

class KeyboardDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    if (insets.keyboardVisible) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.keyboardOverlap,
          title: 'Keyboard Overlay',
          problem: 'Keyboard is currently consuming bottom window space.',
          evidence: 'IME bottom inset = ${insets.ime.bottom}',
          recommendation:
              'Use EdgeGuardBottomAction or Scaffold with resizeToAvoidBottomInset to ensure text fields remain visible.',
          confidence: EdgeGuardConfidence.confirmed,
        ),
      );
    }

    return issues;
  }
}
