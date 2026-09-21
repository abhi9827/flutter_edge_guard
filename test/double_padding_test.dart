import 'package:flutter/material.dart';
import 'package:flutter_edge_guard/flutter_edge_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Double padding test for EdgeGuardBottomAction inside Scaffold',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(bottom: 0),
            viewPadding: EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.only(bottom: 300), // Keyboard open
          ),
          child: EdgeGuard(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: EdgeGuardBottomAction(
                  child: Builder(
                    builder: (context) {
                      return const SizedBox(width: 50, height: 50);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    tester.getRect(find.byType(SizedBox));
  });
}
