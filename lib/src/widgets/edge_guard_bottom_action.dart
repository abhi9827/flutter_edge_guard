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

    final paddingOf = MediaQuery.paddingOf(context);
    final viewPaddingOf = MediaQuery.viewPaddingOf(context);
    final sysGesturesOf = MediaQuery.systemGestureInsetsOf(context);
    final viewInsetsOf = MediaQuery.viewInsetsOf(context);

    if (scope != null && scope.config.protectBottomActions) {
      // Use local MediaQuery values to ensure we respect padding that has
      // already been consumed by ancestors like Scaffold or SafeArea.
      final sysNavBottom = math.max(
        math.max(paddingOf.bottom, viewPaddingOf.bottom),
        sysGesturesOf.bottom,
      );
      final imeBottom = viewInsetsOf.bottom;
      
      // The effective bottom is the maximum of the system nav area and the IME area.
      bottomPadding = math.max(sysNavBottom, imeBottom);
    } else if (scope == null) {
      // Fallback if no scope is found
      bottomPadding = math.max(paddingOf.bottom, viewInsetsOf.bottom);
    }

    final totalPadding = EdgeInsets.only(bottom: bottomPadding).add(padding);

    return Padding(
      padding: totalPadding,
      child: child,
    );
  }
}
