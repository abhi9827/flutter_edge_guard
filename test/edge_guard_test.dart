import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EdgeGuard Widget Tests (Tier 1)', () {
    testWidgets('Provides EdgeInsetsInfo to descendants', (tester) async {
      EdgeInsetsInfo? capturedInsets;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(top: 24, bottom: 34),
              viewInsets: EdgeInsets.only(bottom: 0),
            ),
            child: EdgeGuard(
              child: Builder(
                builder: (context) {
                  capturedInsets = EdgeGuardScope.of(context).insetsInfo;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedInsets, isNotNull);
      expect(capturedInsets!.isEdgeToEdge, isTrue);
      expect(capturedInsets!.statusBars.top, 24);
      expect(capturedInsets!.navigationBars.bottom, 34);
      expect(capturedInsets!.keyboardVisible, isFalse);
    });

    testWidgets('EdgeGuardBottomAction protects against navigation bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
            child: EdgeGuard(
              child: EdgeGuardBottomAction(
                child: Container(key: const Key('target')),
              ),
            ),
          ),
        ),
      );

      final paddingFinder = find
          .ancestor(
            of: find.byKey(const Key('target')),
            matching: find.byType(Padding),
          )
          .first;

      final paddingWidget = tester.widget<Padding>(paddingFinder);
      expect(paddingWidget.padding, const EdgeInsets.only(bottom: 34));
    });

    testWidgets('EdgeGuardBottomAction protects against IME (keyboard)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34), // Nav bar
              viewInsets: EdgeInsets.only(bottom: 300), // Keyboard
            ),
            child: EdgeGuard(
              child: EdgeGuardBottomAction(
                child: Container(key: const Key('target')),
              ),
            ),
          ),
        ),
      );

      final paddingFinder = find
          .ancestor(
            of: find.byKey(const Key('target')),
            matching: find.byType(Padding),
          )
          .first;

      final paddingWidget = tester.widget<Padding>(paddingFinder);
      // Effective protection should be the max of nav and keyboard, so 300.
      expect(paddingWidget.padding, const EdgeInsets.only(bottom: 300));
    });

    testWidgets('Diagnostics Engine detects Keyboard Overlap', (tester) async {
      EdgeGuardReport? report;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              viewInsets: EdgeInsets.only(bottom: 300),
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

      expect(report, isNotNull);
      final hasKeyboardIssue = report!.issues.any(
        (i) => i.type == EdgeGuardIssueType.keyboardOverlap,
      );
      expect(hasKeyboardIssue, isTrue);
    });

    testWidgets('Diagnostics Engine handles Immersive mode gracefully', (
      tester,
    ) async {
      EdgeGuardReport? report;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.zero, // Represents fullscreen
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

      expect(report, isNotNull);
      // Depending on platform it might trigger fullscreen, but we mock a default here.
      // If we don't set platform to Android/iOS in the test, it might not flag fullscreenMode.
      // But it should NOT crash.
      expect(report!.insetsInfo.isEdgeToEdge, isFalse);
    });
  });
}
