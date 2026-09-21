import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EdgeGuardInsetApplier', () {
    /// Helper: builds the subject widget inside a MediaQuery with given padding.
    Widget buildSubject({
      required EdgeInsets padding,
      EdgeGuardAutoFixConfig config = EdgeGuardAutoFixConfig.standard,
      Widget child = const SizedBox.expand(),
    }) {
      return MediaQuery(
        data: MediaQueryData(padding: padding),
        child: EdgeGuardInsetApplier(config: config, child: child),
      );
    }

    testWidgets('applies bottom padding from MediaQuery', (tester) async {
      const bottomInset = 34.0;

      late EdgeInsets appliedPadding;

      await tester.pumpWidget(
        buildSubject(
          padding: const EdgeInsets.only(bottom: bottomInset),
          child: Builder(
            builder: (context) {
              // Capture the padding that was injected above this widget.
              // The Padding widget wraps us, so we read via tester after pump.
              return const SizedBox.expand();
            },
          ),
        ),
      );

      // Find the Padding widget inserted by EdgeGuardInsetApplier.
      final paddingWidget = tester.widget<Padding>(find.byType(Padding).first);
      appliedPadding = paddingWidget.padding as EdgeInsets;

      expect(appliedPadding.bottom, bottomInset);
      expect(appliedPadding.top, 0.0);
      expect(appliedPadding.left, 0.0);
      expect(appliedPadding.right, 0.0);
    });

    testWidgets('zeros bottom in descendant MediaQuery (no double-pad)',
        (tester) async {
      const bottomInset = 34.0;
      EdgeInsets? descendantPadding;

      await tester.pumpWidget(
        buildSubject(
          padding: const EdgeInsets.only(bottom: bottomInset),
          child: Builder(
            builder: (context) {
              descendantPadding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            },
          ),
        ),
      );

      await tester.pump();

      // Descendant MediaQuery should have bottom = 0 (consumed above).
      expect(descendantPadding!.bottom, 0.0);
    });

    testWidgets('does NOT apply top when applyTop is false (default)',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(
          padding: const EdgeInsets.only(top: 48.0, bottom: 34.0),
        ),
      );

      final paddingWidget = tester.widget<Padding>(find.byType(Padding).first);
      final p = paddingWidget.padding as EdgeInsets;
      expect(p.top, 0.0);
      expect(p.bottom, 34.0);
    });

    testWidgets('applies top when applyTop is true', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          padding: const EdgeInsets.only(top: 48.0, bottom: 34.0),
          config: const EdgeGuardAutoFixConfig(applyTop: true),
        ),
      );

      final paddingWidget = tester.widget<Padding>(find.byType(Padding).first);
      final p = paddingWidget.padding as EdgeInsets;
      expect(p.top, 48.0);
      expect(p.bottom, 34.0);
    });

    testWidgets('renders child unmodified when disabled', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          padding: const EdgeInsets.only(bottom: 34.0),
          config: EdgeGuardAutoFixConfig.disabled,
        ),
      );

      // No Padding widget should be inserted.
      expect(find.byType(Padding), findsNothing);
    });

    testWidgets('renders child unmodified when all insets are zero',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(
          padding: EdgeInsets.zero,
        ),
      );

      // No Padding widget when there is nothing to apply.
      expect(find.byType(Padding), findsNothing);
    });
  });

  group('EdgeGuardExempt', () {
    testWidgets('isExempt returns false outside EdgeGuardExempt',
        (tester) async {
      bool? exempt;

      await tester.pumpWidget(
        Builder(builder: (context) {
          exempt = EdgeGuardExempt.isExempt(context);
          return const SizedBox.shrink();
        }),
      );

      await tester.pump();
      expect(exempt, false);
    });

    testWidgets('isExempt returns true inside EdgeGuardExempt', (tester) async {
      bool? exempt;

      await tester.pumpWidget(
        EdgeGuardExempt(
          child: Builder(builder: (context) {
            exempt = EdgeGuardExempt.isExempt(context);
            return const SizedBox.shrink();
          }),
        ),
      );

      await tester.pump();
      expect(exempt, true);
    });

    testWidgets('EdgeGuardInsetApplier skips padding inside EdgeGuardExempt',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(
            padding: EdgeInsets.only(bottom: 34.0),
          ),
          child: EdgeGuardExempt(
            child: EdgeGuardInsetApplier(
              config: EdgeGuardAutoFixConfig.standard,
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      // No Padding inserted — exempt subtree bypasses the applier.
      expect(find.byType(Padding), findsNothing);
    });
  });

  group('EdgeGuardAutoFixConfig', () {
    test('standard defaults', () {
      const config = EdgeGuardAutoFixConfig.standard;
      expect(config.enabled, true);
      expect(config.applyBottom, true);
      expect(config.applyTop, false);
      expect(config.applyLeft, true);
      expect(config.applyRight, true);
    });

    test('disabled returns enabled: false', () {
      const config = EdgeGuardAutoFixConfig.disabled;
      expect(config.enabled, false);
    });

    test('allEdges enables all sides', () {
      const config = EdgeGuardAutoFixConfig.allEdges;
      expect(config.applyTop, true);
      expect(config.applyBottom, true);
      expect(config.applyLeft, true);
      expect(config.applyRight, true);
    });

    test('copyWith overrides individual fields', () {
      const base = EdgeGuardAutoFixConfig.standard;
      final copy = base.copyWith(applyTop: true, enabled: false);
      expect(copy.applyTop, true);
      expect(copy.enabled, false);
      expect(copy.applyBottom, base.applyBottom); // unchanged
    });

    test('equality holds for identical configs', () {
      const a = EdgeGuardAutoFixConfig.standard;
      const b = EdgeGuardAutoFixConfig.standard;
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
