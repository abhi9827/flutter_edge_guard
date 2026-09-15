import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../core/edge_guard_scope.dart';

/// Protects bottom actions/buttons from navigation bars, system gestures,
/// keyboard (IME), and display cutouts.
///
/// It determines the effective bottom protection based on the maximum relevant
/// obstruction rather than blindly adding all values together, preventing
/// double-padding issues.
class EdgeGuardBottomAction extends StatelessWidget {
  /// The action widget (e.g., a button) to protect.
  final Widget child;

  /// Optional padding to apply around the child independent of system insets.
  final EdgeInsetsGeometry padding;

  const EdgeGuardBottomAction({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);

    // If EdgeGuard isn't above us, fallback to safe area behavior (or zero if we don't want to assume).
    // However, it's safer to use MediaQuery if scope is null.
    var bottomPadding = 0.0;

    if (scope != null && scope.config.protectBottomActions) {
      final insets = scope.insetsInfo;

      // Algorithm: We need to clear the gesture area and navigation bar.
      // If the keyboard is up, it consumes the navigation bar area, so IME
      // is the primary inset.
      // If we are just avoiding gestures, we take the max of padding.bottom and gesture.bottom.

      final sysNavBottom = math.max(
        insets.navigationBars.bottom,
        insets.systemGestures.bottom,
      );
      final imeBottom = insets.ime.bottom;

      // The effective bottom is the maximum of the system nav area and the IME area.
      // viewPadding is already included in sysNavBottom typically, but to be robust:
      bottomPadding = math.max(sysNavBottom, imeBottom);
    } else if (scope == null) {
      // Fallback if no scope is found
      final paddingOf = MediaQuery.paddingOf(context);
      final viewInsetsOf = MediaQuery.viewInsetsOf(context);
      bottomPadding = math.max(paddingOf.bottom, viewInsetsOf.bottom);
    }

    final totalPadding = EdgeInsets.only(bottom: bottomPadding).add(padding);

    return Padding(
      padding: totalPadding,
      child: child,
    );
  }
}
