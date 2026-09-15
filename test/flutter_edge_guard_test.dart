import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';
import 'package:flutter_edge_guard/src/widgets/edge_guard_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

      expect(info.isEdgeToEdge, isTrue);
      expect(info.keyboardVisible, isTrue);
      expect(info.padding.top, 24);
      expect(info.padding.bottom, 0); // padding drops to 0 when keyboard open
      expect(info.windowSize.width, 412);
    });
  });

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
  });

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

      print('FOUND ISSUES: ${report.issues.map((e) => e.type).toList()}');
      expect(
        report.issues.any(
          (e) => e.type == EdgeGuardIssueType.gestureAreaConflict,
        ),
        isTrue,
      );
    });
  });
}
