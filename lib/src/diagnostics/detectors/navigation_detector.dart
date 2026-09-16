import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_navigation_mode.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

class NavigationDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    // Navigation bar / gesture concepts only exist on mobile (Android, iOS).
    // Desktop (Windows, macOS, Linux) and web have no swipeable navigation bars.
    if (!platform.isAndroid && !platform.isIOS) return issues;

    if (insets.navigationBars.bottom > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.navigationBarOverlap,
          title: 'Bottom Action Risk',
          problem:
              'A bottom action or content may enter the system navigation area.',
          evidence: 'navigationBars.bottom = ${insets.navigationBars.bottom}',
          recommendation:
              'Use EdgeGuardBottomAction or SafeArea for bottom-aligned interactive elements.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    if (insets.systemGestures.left > 0 || insets.systemGestures.right > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.gestureAreaConflict,
          title: 'Side Gesture Area',
          problem: 'Side edges are reserved for system back gestures.',
          evidence:
              'systemGestures.left = ${insets.systemGestures.left}, right = ${insets.systemGestures.right}',
          recommendation:
              'Avoid placing horizontal sliders or swipe actions flush against the screen edge.',
          confidence: EdgeGuardConfidence.informational,
        ),
      );
    }

    if (platform.navigationMode != EdgeGuardNavigationMode.unknown) {
      final modeDesc =
          platform.navigationMode == EdgeGuardNavigationMode.gesture
              ? 'Gesture Navigation'
              : '3-Button Navigation';
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.edgeToEdgeConfiguration,
          title: 'Navigation Mode Inferred',
          problem: 'Navigation mode was heuristically determined as $modeDesc.',
          evidence: 'bottom inset = ${insets.padding.bottom}',
          recommendation:
              'Note: Navigation mode detection is heuristic and uses stable signals only, never private OS settings.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    return issues;
  }
}
