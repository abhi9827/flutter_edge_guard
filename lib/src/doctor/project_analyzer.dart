import 'dart:convert';
import 'dart:io';

class DoctorIssue {
  final String severity; // 'info', 'warning', 'critical'
  final String message;
  final String? file;
  final String? recommendation;

  DoctorIssue({
    required this.severity,
    required this.message,
    this.file,
    this.recommendation,
  });

  Map<String, dynamic> toJson() => {
        'severity': severity,
        'message': message,
        if (file != null) 'file': file,
        if (recommendation != null) 'recommendation': recommendation,
      };
}

class ProjectAnalyzer {
  final Directory rootDir;
  final List<DoctorIssue> issues = [];

  ProjectAnalyzer(this.rootDir);

  List<DoctorIssue> analyze({bool outputJson = false}) {
    issues.clear();

    if (!outputJson) {
      stdout.writeln('\nFlutter Edge Guard Doctor\n');
    }

    final hasFlutter = File('${rootDir.path}/pubspec.yaml').existsSync();
    final hasAndroid = Directory('${rootDir.path}/android').existsSync();
    final hasDart = Directory('${rootDir.path}/lib').existsSync();

    if (!outputJson) {
      if (hasFlutter) stdout.writeln('✓ Flutter project detected');
      if (hasDart) stdout.writeln('✓ Dart source directory detected');
      if (hasAndroid) stdout.writeln('✓ Android project detected');
      stdout.writeln('\nAndroid Configuration:');
    }
    _analyzeAndroidSdk(outputJson);

    if (!outputJson) stdout.writeln('\nEdge-to-Edge Configuration:');
    _analyzeEdgeToEdge(outputJson);

    if (!outputJson) stdout.writeln('\nPredictive Back:');
    _analyzePredictiveBack(outputJson);

    if (!outputJson) stdout.writeln('\nHardcoded Insets:');
    _analyzeHardcodedInsets(outputJson);

    if (outputJson) {
      stdout.writeln(
        jsonEncode({'issues': issues.map((e) => e.toJson()).toList()}),
      );
    } else {
      stdout.writeln('\nFound ${issues.length} issue(s).');
      for (final issue in issues) {
        final prefix = issue.severity == 'critical'
            ? '✖ [CRITICAL]'
            : (issue.severity == 'warning' ? '⚠ [WARNING]' : 'ℹ [INFO]');
        stdout.writeln('$prefix ${issue.message}');
        if (issue.file != null) stdout.writeln('  File: ${issue.file}');
        if (issue.recommendation != null) {
          stdout.writeln('  Recommendation: ${issue.recommendation}');
        }
      }
      stdout.writeln();
    }

    return issues;
  }

  void _analyzeAndroidSdk(bool outputJson) {
    final buildGradle = File('${rootDir.path}/android/app/build.gradle');
    final buildGradleKts = File('${rootDir.path}/android/app/build.gradle.kts');

    var targetSdk = _extractSdk(buildGradle, 'targetSdk');
    var compileSdk = _extractSdk(buildGradle, 'compileSdk');

    if (targetSdk == null && compileSdk == null) {
      targetSdk = _extractSdk(buildGradleKts, 'targetSdk');
      compileSdk = _extractSdk(buildGradleKts, 'compileSdk');
    }

    if (!outputJson) {
      stdout.writeln(
        'compileSdk: ${compileSdk ?? "UNAVAILABLE - could not parse"}',
      );
      stdout.writeln(
        'targetSdk: ${targetSdk ?? "UNAVAILABLE - could not parse"}',
      );
    }

    // Critical check: targetSdk below 35 means Android 15 E2E enforcement
    // won't apply and the app may break silently on Android 15+ devices.
    if (targetSdk != null) {
      final sdkInt = int.tryParse(targetSdk);
      if (sdkInt != null && sdkInt < 35) {
        issues.add(
          DoctorIssue(
            severity: 'critical',
            message:
                'targetSdk ($targetSdk) is below 35. Android 15 enforces edge-to-edge '
                'for all apps targeting API 35+. Apps with targetSdk < 35 may render '
                'incorrectly on Android 15+ devices once Google Play enforces the requirement.',
            recommendation:
                'Update targetSdk to 36 (Android 16) and compileSdk to at least 35. '
                'Test edge-to-edge behavior and use EdgeGuard to diagnose layout issues.',
          ),
        );
      }
    }
  }

  String? _extractSdk(File file, String key) {
    if (!file.existsSync()) return null;
    final lines = file.readAsLinesSync();
    final regex = RegExp('$key(?:Version)?\\s*=?\\s*([a-zA-Z0-9_.]+)');

    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final val = match.group(1);
        if (val != null && val.contains('flutter.')) {
          return _resolveFlutterProperty(val);
        }
        if (val != null && val.contains('libs.versions.')) {
          return _resolveTomlProperty(val);
        }
        return val;
      }
    }
    return null;
  }

  String? _resolveFlutterProperty(String prop) {
    final localProps = File('${rootDir.path}/android/local.properties');
    if (localProps.existsSync()) {
      final lines = localProps.readAsLinesSync();
      for (final line in lines) {
        if (line.startsWith(prop)) {
          return line.split('=')[1].trim();
        }
      }
    }
    return null; // Don't guess.
  }

  String? _resolveTomlProperty(String prop) {
    final tomlFile = File('${rootDir.path}/android/gradle/libs.versions.toml');
    if (tomlFile.existsSync()) {
      final lines = tomlFile.readAsLinesSync();
      // basic resolution logic for toml
      final versionKey = prop.replaceFirst('libs.versions.', '');
      for (final line in lines) {
        if (line.startsWith(versionKey)) {
          final parts = line.split('=');
          if (parts.length == 2) {
            return parts[1].replaceAll('"', '').replaceAll("'", "").trim();
          }
        }
      }
    }
    return null;
  }

  void _analyzeEdgeToEdge(bool outputJson) {
    var hasLegacyOptOut = false;

    // Check Manifest
    final manifest = File(
      '${rootDir.path}/android/app/src/main/AndroidManifest.xml',
    );
    if (manifest.existsSync()) {
      final content = manifest.readAsStringSync();
      if (content.contains('android:windowLayoutInDisplayCutoutMode')) {
        issues.add(
          DoctorIssue(
            severity: 'warning',
            message:
                'Manifest restricts display cutout mode. Review edge-to-edge compatibility.',
            file: manifest.path,
          ),
        );
        hasLegacyOptOut = true;
      }
    }

    // Check Styles
    final styles = File(
      '${rootDir.path}/android/app/src/main/res/values/styles.xml',
    );
    if (styles.existsSync()) {
      final content = styles.readAsStringSync();
      if (content.contains('windowTranslucentStatus') ||
          content.contains('windowTranslucentNavigation') ||
          content.contains('android:navigationBarColor') ||
          content.contains('android:statusBarColor') ||
          content.contains('enforceNavigationBarContrast') ||
          content.contains('enforceStatusBarContrast')) {
        issues.add(
          DoctorIssue(
            severity: 'warning',
            message: 'Legacy system bar theming detected in styles.xml.',
            file: styles.path,
          ),
        );
        hasLegacyOptOut = true;
      }
    }

    // A robust parser would find the actual package name. For this implementation we'll search the tree for MainActivity.
    final mainActivityFiles = _findFilesByName(
      Directory('${rootDir.path}/android/app/src/main'),
      'MainActivity',
    );
    for (final file in mainActivityFiles) {
      final content = file.readAsStringSync();
      if (content.contains('SYSTEM_UI_FLAG_') &&
          !content.contains('setDecorFitsSystemWindows')) {
        issues.add(
          DoctorIssue(
            severity: 'warning',
            message:
                'Legacy system UI visibility flags detected in MainActivity without modern edge-to-edge opt-in.',
            file: file.path,
          ),
        );
        hasLegacyOptOut = true;
      }
    }

    if (!outputJson && !hasLegacyOptOut) {
      stdout.writeln('✓ No legacy edge-to-edge opt-out patterns detected');
    }
  }

  List<File> _findFilesByName(Directory dir, String namePart) {
    final results = <File>[];
    if (!dir.existsSync()) return results;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.contains(namePart)) {
        results.add(entity);
      }
    }
    return results;
  }

  void _analyzePredictiveBack(bool outputJson) {
    final libDir = Directory('${rootDir.path}/lib');
    if (!libDir.existsSync()) return;

    // Paths to exclude from scanning — avoid false positives on the package's
    // own source files and generated code.
    final excludePatterns = [
      '${rootDir.path}/lib/src/doctor/',
      '${rootDir.path}/lib/src/models/edge_guard_issue_type',
      '.g.dart',
      '.freezed.dart',
    ];

    var foundWillPopScope = false;

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        // Skip excluded paths.
        if (excludePatterns.any((p) => entity.path.contains(p))) continue;

        final content = entity.readAsStringSync();
        if (content.contains('WillPopScope')) {
          issues.add(
            DoctorIssue(
              severity: 'warning',
              message: 'Uses deprecated WillPopScope.',
              file: entity.path,
              recommendation:
                  'Replace WillPopScope with PopScope for compatibility with Android 16/API 36 predictive back.',
            ),
          );
          foundWillPopScope = true;
        }
      }
    }

    if (!outputJson && !foundWillPopScope) {
      stdout.writeln('✓ No legacy WillPopScope detected');
    }
  }

  void _analyzeHardcodedInsets(bool outputJson) {
    final libDir = Directory('${rootDir.path}/lib');
    if (!libDir.existsSync()) return;

    var foundHardcoded = false;
    final regex = RegExp(r'EdgeInsets\.only\([^)]*bottom:\s*[0-9]+[^)]*\)');

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        if (regex.hasMatch(content)) {
          issues.add(
            DoctorIssue(
              severity: 'info',
              message: 'Possible hardcoded bottom inset found.',
              file: entity.path,
            ),
          );
          foundHardcoded = true;
        }
      }
    }

    if (!outputJson && !foundHardcoded) {
      stdout.writeln('✓ No obvious hardcoded bottom insets detected');
    }
  }
}
