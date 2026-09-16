import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

/// Detects edge/inset issues specific to desktop platforms
/// (macOS, Windows, Linux).
///
/// Desktop apps in Flutter run in resizable windows. Unlike mobile, there are
/// no system gesture bars, but there are desktop-specific concerns:
///
/// - **Caption bar / title bar**: On macOS and Windows, the window caption
///   bar may overlap content when running in full-screen or with a transparent
///   title bar. Flutter's `MediaQuery.padding.top` reflects this on macOS.
///
/// - **Window resizing**: Content should adapt to window size changes. Fixed
///   layouts that assume phone dimensions will look broken on desktop.
///
/// - **Multi-window**: Desktop apps can run in multiple windows simultaneously,
///   each with their own MediaQuery. Static global state is dangerous.
class DesktopDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    if (!platform.isDesktop) return issues;

    // Caption bar overlap: On macOS with transparent title bars, or on
    // Windows with custom chrome, padding.top may be > 0. Developers should
    // account for this in layouts.
    if (insets.captionBar.top > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.statusBarOverlap,
          title: 'Caption Bar Inset Detected',
          problem:
              'The window caption bar is consuming top space. Content placed '
              'at the very top of the window may be obscured by the title bar '
              'or traffic-light buttons on macOS.',
          evidence: 'captionBar.top = ${insets.captionBar.top}',
          recommendation:
              'Use EdgeGuardSafeArea(top: true) or add top padding equal to '
              'captionBar.top to protect your content from the title bar area. '
              'On macOS, this is the area with the traffic-light close/minimize/zoom buttons.',
          confidence: EdgeGuardConfidence.confirmed,
        ),
      );
    }

    // Small window / non-adaptive layout risk
    if (insets.windowSize.width < 400 || insets.windowSize.height < 300) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.multiWindow,
          title: 'Very Small Desktop Window',
          problem:
              'The window is very small. Layouts that assume typical mobile '
              'or tablet dimensions may overflow or clip content.',
          evidence:
              'width = ${insets.windowSize.width}, height = ${insets.windowSize.height}',
          recommendation:
              'Set a minimum window size using `window.setMinimumSize()` from '
              'the `window_manager` package, and use `LayoutBuilder` or '
              '`MediaQuery` to build responsive layouts.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    // macOS-specific: waterfall / rounded corners may clip edge content.
    if (platform.isMacOS && insets.waterfall.horizontal > 0) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.info,
          type: EdgeGuardIssueType.displayCutout,
          title: 'macOS Waterfall / Rounded Corner Inset',
          problem:
              'The display has rounded corners or a waterfall edge that may '
              'clip content placed at the horizontal edges.',
          evidence: 'waterfall.left = ${insets.waterfall.left}, '
              'waterfall.right = ${insets.waterfall.right}',
          recommendation:
              'Avoid placing critical content at the very left or right edges '
              'of the window on MacBooks with rounded display corners.',
          confidence: EdgeGuardConfidence.informational,
        ),
      );
    }

    return issues;
  }
}
