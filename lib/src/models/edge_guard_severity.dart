import '../../flutter_edge_guard.dart' show EdgeGuardIssue;
import 'edge_guard_issue.dart' show EdgeGuardIssue;

/// Severity of an [EdgeGuardIssue].
enum EdgeGuardSeverity {
  /// Informational context, not an error.
  info,

  /// A potential issue that may cause visual or interactive problems.
  warning,

  /// A critical issue strongly likely to cause broken UI.
  critical,
}
