import 'dart:io';

import 'package:flutter_edge_guard/src/doctor/project_analyzer.dart';

void main(List<String> args) {
  final currentDir = Directory.current;

  if (!File('${currentDir.path}/pubspec.yaml').existsSync()) {
    stderr.writeln(
      'Error: Could not find pubspec.yaml. Please run this command from the root of a Flutter project.',
    );
    exit(1);
  }

  var outputJson = false;
  String? failOnSeverity;

  for (final arg in args) {
    if (arg == '--json') {
      outputJson = true;
    } else if (arg.startsWith('--fail-on=')) {
      failOnSeverity = arg.substring('--fail-on='.length).toLowerCase();
    }
  }

  final analyzer = ProjectAnalyzer(currentDir);
  final issues = analyzer.analyze(outputJson: outputJson);

  if (failOnSeverity != null) {
    var shouldFail = false;
    for (final issue in issues) {
      if (failOnSeverity == 'critical' && issue.severity == 'critical') {
        shouldFail = true;
      } else if (failOnSeverity == 'warning' &&
          (issue.severity == 'warning' || issue.severity == 'critical')) {
        shouldFail = true;
      }
    }
    if (shouldFail) {
      exit(1);
    }
  }
}
