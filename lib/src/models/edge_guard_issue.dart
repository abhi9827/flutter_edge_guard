import 'edge_guard_confidence.dart';
import 'edge_guard_issue_type.dart';
import 'edge_guard_severity.dart';

/// Represents a single issue or diagnostic finding discovered by EdgeGuard.
class EdgeGuardIssue {
  /// The severity of the issue (info, warning, critical).
  final EdgeGuardSeverity severity;

  /// The categorization of the issue.
  final EdgeGuardIssueType type;

  /// A brief human-readable title for the issue.
  final String title;

  /// A detailed description of what the problem is.
  final String problem;

  /// Information supporting the diagnosis (e.g., specific inset values).
  final String evidence;

  /// Actionable advice on how to resolve the issue.
  final String recommendation;

  /// The level of certainty EdgeGuard has regarding this diagnosis.
  final EdgeGuardConfidence confidence;

  const EdgeGuardIssue({
    required this.severity,
    required this.type,
    required this.title,
    required this.problem,
    required this.evidence,
    required this.recommendation,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'severity': severity.name,
      'type': type.name,
      'title': title,
      'problem': problem,
      'evidence': evidence,
      'recommendation': recommendation,
      'confidence': confidence.name,
    };
  }

  @override
  String toString() {
    final severityStr = severity.name.toUpperCase();
    return '''
$severityStr: $title
Type: ${type.name}

Problem:
$problem

Evidence:
$evidence

Recommendation:
$recommendation

Confidence:
${confidence.name}
''';
  }
}
