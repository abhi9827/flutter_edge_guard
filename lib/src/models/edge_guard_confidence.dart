import '../../flutter_edge_guard.dart' show EdgeGuardIssue;
import 'edge_guard_issue.dart' show EdgeGuardIssue;

/// Confidence level of an [EdgeGuardIssue].
enum EdgeGuardConfidence {
  /// The package has enough information to establish the condition is present.
  confirmed,

  /// The package sees evidence that a problem may exist but cannot prove
  /// actual widget overlap.
  possible,

  /// Useful platform/configuration information, not necessarily a problem.
  informational,
}
