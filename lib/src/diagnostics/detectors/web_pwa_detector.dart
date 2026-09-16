import '../../models/edge_guard_confidence.dart';
import '../../models/edge_guard_issue.dart';
import '../../models/edge_guard_issue_type.dart';
import '../../models/edge_guard_platform_info.dart';
import '../../models/edge_guard_severity.dart';
import '../../models/edge_insets_info.dart';

/// Detects safe-area / inset problems specific to web and PWA (Progressive
/// Web App) deployments.
///
/// When a Flutter web app is installed as a PWA and run in standalone mode on
/// mobile, iOS and Android browsers provide `env(safe-area-inset-*)` CSS
/// variables. However, if the HTML shell does not include the `viewport-fit=cover`
/// meta tag and corresponding CSS, these safe areas are zero, causing content
/// to be obscured by device notches or rounded corners.
///
/// This detector runs only on web and checks for signs of a missing safe-area
/// configuration.
class WebPwaDetector {
  static List<EdgeGuardIssue> detect(
    EdgeInsetsInfo insets,
    EdgeGuardPlatformInfo platform,
  ) {
    final issues = <EdgeGuardIssue>[];

    if (!platform.isWeb) return issues;

    // On web/PWA, if all padding is zero and window dimensions suggest a mobile
    // screen (narrow width), safe-area insets are likely not configured.
    final isMobileScreen =
        insets.windowSize.width < 768 && insets.windowSize.height > 0;

    if (isMobileScreen && !insets.isEdgeToEdge) {
      issues.add(
        EdgeGuardIssue(
          severity: EdgeGuardSeverity.warning,
          type: EdgeGuardIssueType.edgeToEdgeConfiguration,
          title: 'PWA Safe Area Not Applied',
          problem:
              'Running as a web app on a mobile-sized viewport with zero safe-area insets. '
              'Content may be obscured by device notches, status bars, or rounded display corners '
              'if the PWA is installed and run in standalone mode.',
          evidence:
              'isWeb = true, isEdgeToEdge = false, windowWidth = ${insets.windowSize.width}',
          recommendation:
              'Add viewport-fit=cover to the <meta name="viewport"> tag in your web/index.html. '
              'Then apply env(safe-area-inset-*) in your CSS body/html rules, or use '
              'Flutter\'s MediaQuery.paddingOf() which reads these values on web.',
          confidence: EdgeGuardConfidence.possible,
        ),
      );
    }

    return issues;
  }
}
