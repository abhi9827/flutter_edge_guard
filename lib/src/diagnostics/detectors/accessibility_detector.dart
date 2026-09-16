import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

/// Detects potential accessibility conflicts between interactive elements
/// and system gesture zones.
///
/// On Android gesture navigation, side edges are reserved for the back gesture.
/// Users with motor difficulties may accidentally trigger system gestures when
/// attempting to interact with UI elements placed at the screen edge, especially
/// if those elements are smaller than 48dp.
class AccessibilityDetector {
  /// Minimum recommended distance from screen edge to interactive elements, in dp.
  static const double _minEdgeDistance = 16.0;

  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    // Gesture zone accessibility issues only apply to mobile (Android, iOS).
    // Desktop OSes use mouse/keyboard, not swipe gestures.
    if (!platform.isAndroid && !platform.isIOS) return issues;

    // If system gesture zones are active on the sides (gesture navigation),
    // flag that interactive elements must be kept away from screen edges.
    if (insets.systemGestures.left > _minEdgeDistance ||
        insets.systemGestures.right > _minEdgeDistance) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.accessibilityTouchTarget,
          title: 'Side Gesture Accessibility Risk',
          problem: 'System back gesture zones are active on the side edges. '
              'Interactive elements placed within ${_minEdgeDistance}dp of the screen edge '
              'may be accidentally triggered by system gestures, creating accessibility problems '
              'for users with motor difficulties.',
          evidence: 'systemGestures.left = ${insets.systemGestures.left}, '
              'systemGestures.right = ${insets.systemGestures.right}',
          recommendation:
              'Ensure all interactive elements (buttons, sliders, swipe actions) '
              'maintain at least ${_minEdgeDistance}dp margin from the screen edge. '
              'Avoid placing horizontal sliders flush against screen edges.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    // If gesture navigation is inferred and bottom inset is small,
    // alert about home swipe area conflicts.
    if (platform.isAndroid &&
        insets.systemGestures.bottom > 0 &&
        insets.systemGestures.bottom < 20) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.accessibilityTouchTarget,
          title: 'Bottom Gesture Zone Detected',
          problem:
              'A small bottom gesture zone is active. The home gesture swipe area '
              'may overlap with bottom-aligned interactive elements.',
          evidence: 'systemGestures.bottom = ${insets.systemGestures.bottom}',
          recommendation:
              'Use EdgeGuardBottomAction or EdgeGuardAnimatedAction to ensure '
              'bottom-aligned interactive elements are properly offset from the gesture zone.',
          confidence: EdgeGuardConfidence.informational,
        ),
      );
    }

    return issues;
  }
}
