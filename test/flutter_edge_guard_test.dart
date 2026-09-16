import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ─────────────────────────────────────────────────────────────
  // EdgeInsetsInfo Model Tests
  // ─────────────────────────────────────────────────────────────
  group('EdgeInsetsInfo Model Tests', () {
    testWidgets('extracts info correctly from MediaQuery', (tester) async {
      late EdgeInsetsInfo info;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 0),
              viewInsets: EdgeInsets.only(bottom: 300), // Keyboard open
              viewPadding: EdgeInsets.only(bottom: 34),
              systemGestureInsets: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 34,
              ),
              size: Size(412, 915),
            ),
            child: EdgeGuard(
              child: Builder(
                builder: (context) {
                  info = EdgeGuardScope.of(context).insetsInfo;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // viewPadding.bottom (34) is used as fallback since padding.bottom = 0
      // when keyboard is open — so isEdgeToEdge should be true.
      expect(info.isEdgeToEdge, isTrue);
      expect(info.keyboardVisible, isTrue);
      expect(info.padding.top, 24);
      expect(info.padding.bottom, 0); // padding drops to 0 when keyboard open
      expect(info.windowSize.width, 412);
    });

    test('EdgeInsetsInfo equality works correctly', () {
      const a = EdgeInsetsInfo(
        statusBars: EdgeInsets.only(top: 24),
        navigationBars: EdgeInsets.only(bottom: 34),
        systemGestures: EdgeInsets.only(bottom: 34),
        mandatorySystemGestures: EdgeInsets.only(bottom: 34),
        tappableElement: EdgeInsets.only(top: 24, bottom: 34),
        ime: EdgeInsets.zero,
        displayCutout: EdgeInsets.zero,
        captionBar: EdgeInsets.zero,
        waterfall: EdgeInsets.zero,
        padding: EdgeInsets.only(top: 24, bottom: 34),
        viewPadding: EdgeInsets.only(bottom: 34),
        viewInsets: EdgeInsets.zero,
        keyboardVisible: false,
        isEdgeToEdge: true,
        windowSize: Size(412, 915),
        orientation: Orientation.portrait,
      );

      // Same values — must be equal.
      const b = EdgeInsetsInfo(
        statusBars: EdgeInsets.only(top: 24),
        navigationBars: EdgeInsets.only(bottom: 34),
        systemGestures: EdgeInsets.only(bottom: 34),
        mandatorySystemGestures: EdgeInsets.only(bottom: 34),
        tappableElement: EdgeInsets.only(top: 24, bottom: 34),
        ime: EdgeInsets.zero,
        displayCutout: EdgeInsets.zero,
        captionBar: EdgeInsets.zero,
        waterfall: EdgeInsets.zero,
        padding: EdgeInsets.only(top: 24, bottom: 34),
        viewPadding: EdgeInsets.only(bottom: 34),
        viewInsets: EdgeInsets.zero,
        keyboardVisible: false,
        isEdgeToEdge: true,
        windowSize: Size(412, 915),
        orientation: Orientation.portrait,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EdgeGuardConfig Tests
  // ─────────────────────────────────────────────────────────────
  group('EdgeGuardConfig Tests', () {
    test('copyWith produces correct copy', () {
      const original = EdgeGuardConfig.standard;
      final copy = original.copyWith(enableDebugOverlay: true);

      expect(copy.enableDebugOverlay, isTrue);
      expect(copy.enableDiagnostics, original.enableDiagnostics);
      expect(copy.enableInspector, original.enableInspector);
    });

    test('equality works correctly', () {
      const a = EdgeGuardConfig.standard;
      const b = EdgeGuardConfig();
      expect(a, equals(b));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EdgeGuard Widget Tests
  // ─────────────────────────────────────────────────────────────
  group('EdgeGuard Widget Tests', () {
    testWidgets('EdgeGuard applies correct padding and consumes MediaQuery', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: EdgeGuard(
              child: EdgeGuardSafeArea(
                child: Builder(
                  builder: (context) {
                    // Inside EdgeGuardSafeArea, the padding should be consumed (0).
                    final mq = MediaQuery.of(context);
                    expect(mq.padding.top, 0);
                    expect(mq.padding.bottom, 0);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });

    testWidgets('EdgeGuardSafeArea works without EdgeGuard (graceful fallback)',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: 24, bottom: 34),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: EdgeGuardSafeArea(
              child: Builder(
                builder: (context) {
                  final mq = MediaQuery.of(context);
                  // Should still consume the padding via MediaQuery fallback.
                  expect(mq.padding.top, 0);
                  expect(mq.padding.bottom, 0);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Diagnostics Tests
  // ─────────────────────────────────────────────────────────────
  group('Diagnostics Tests', () {
    testWidgets('detects gesture navigation risk', (tester) async {
      late EdgeGuardReport report;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34),
              systemGestureInsets: EdgeInsets.only(left: 20),
            ),
            child: EdgeGuard(
              child: Builder(
                builder: (context) {
                  report = EdgeGuardDiagnostics.inspect(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        report.issues.any(
          (e) => e.type == EdgeGuardIssueType.gestureAreaConflict,
        ),
        isTrue,
      );
    });

    testWidgets('AccessibilityDetector warns on wide side gesture zones',
        (tester) async {
      late EdgeGuardReport report;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              systemGestureInsets: EdgeInsets.only(left: 30, right: 30),
              padding: EdgeInsets.only(top: 24, bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: EdgeGuard(
              child: Builder(
                builder: (context) {
                  report = EdgeGuardDiagnostics.inspect(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        report.issues.any(
          (e) => e.type == EdgeGuardIssueType.accessibilityTouchTarget,
        ),
        isTrue,
      );
    });

    testWidgets('ContrastDetector warns in edge-to-edge mode', (tester) async {
      late EdgeGuardReport report;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: EdgeGuard(
              child: Builder(
                builder: (context) {
                  report = EdgeGuardDiagnostics.inspect(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        report.issues.any(
          (e) => e.type == EdgeGuardIssueType.systemBarReadability,
        ),
        isTrue,
      );
    });

    testWidgets('EdgeGuardAnimatedAction renders without error',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: EdgeGuard(
              child: Scaffold(
                body: EdgeGuardAnimatedAction(
                  child: SizedBox(height: 50, child: Text('Action')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('EdgeGuardScrim renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: EdgeGuard(
              child: Stack(
                children: [
                  SizedBox.expand(),
                  EdgeGuardScrim(edge: EdgeGuardScrimEdge.both),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('EdgeGuardZoneOverlay renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: EdgeGuard(
              child: Stack(
                children: [
                  SizedBox.expand(),
                  EdgeGuardZoneOverlay(),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tryInspect returns null without EdgeGuard', (tester) async {
      late EdgeGuardReport? report;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            report = EdgeGuardDiagnostics.tryInspect(context);
            return const SizedBox();
          },
        ),
      );
      expect(report, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Platform Compatibility Tests
  // ─────────────────────────────────────────────────────────────
  group('Platform Compatibility Tests', () {
    test('EdgeGuardPlatformInfo default desktop fields are false', () {
      // Default constructor: isMacOS/isWindows/isLinux all default to false.
      const info = EdgeGuardPlatformInfo(
        platform: 'android',
        isAndroid: true,
        isIOS: false,
        isWeb: false,
        isDesktop: false,
        navigationMode: EdgeGuardNavigationMode.gesture,
        isLargeScreen: false,
        isFoldable: false,
        isMultiWindow: false,
      );
      expect(info.isMacOS, isFalse);
      expect(info.isWindows, isFalse);
      expect(info.isLinux, isFalse);
      expect(info.isDesktop, isFalse);
    });

    test('EdgeGuardPlatformInfo desktop constructor works', () {
      const info = EdgeGuardPlatformInfo(
        platform: 'macos',
        isAndroid: false,
        isIOS: false,
        isWeb: false,
        isDesktop: true,
        isMacOS: true,
        isWindows: false,
        isLinux: false,
        navigationMode: EdgeGuardNavigationMode.unknown,
        isLargeScreen: true,
        isFoldable: false,
        isMultiWindow: false,
      );
      expect(info.isMacOS, isTrue);
      expect(info.isDesktop, isTrue);
      expect(info.isAndroid, isFalse);
      expect(info.toJson()['isMacOS'], isTrue);
      expect(info.toJson()['platform'], 'macos');
    });

    test('EdgeGuardPlatformInfo web constructor works', () {
      const info = EdgeGuardPlatformInfo(
        platform: 'web',
        isAndroid: false,
        isIOS: false,
        isWeb: true,
        isDesktop: false,
        navigationMode: EdgeGuardNavigationMode.unknown,
        isLargeScreen: false,
        isFoldable: false,
        isMultiWindow: false,
      );
      expect(info.isWeb, isTrue);
      expect(info.isDesktop, isFalse);
      expect(info.toJson()['platform'], 'web');
    });

    testWidgets('NavigationDetector skips checks on test platform (non-mobile)',
        (tester) async {
      // The test environment runs on the host machine (macOS/Linux desktop).
      // EdgeGuard should not crash and should NOT produce navigation-bar
      // overlap issues since there are no mobile navigation bars on desktop.
      late EdgeGuardReport report;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              // Zero padding simulates desktop where there are no system bars.
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
            ),
            child: EdgeGuard(
              child: Builder(
                builder: (context) {
                  report = EdgeGuardDiagnostics.inspect(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // Should not have any navigation-bar overlap issue since not mobile.
      final navIssues = report.issues
          .where((e) => e.type == EdgeGuardIssueType.navigationBarOverlap)
          .toList();
      expect(navIssues, isEmpty);
    });
  });
}
