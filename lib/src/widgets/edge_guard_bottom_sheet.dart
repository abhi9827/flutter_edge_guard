import 'package:flutter/widgets.dart';

import '../core/edge_guard_scope.dart';
import 'edge_guard_bottom_action.dart'; // We can reuse the logic or build similar

/// Protects bottom sheets from edge-to-edge overlaps.
///
/// This does not force a specific visual design, it only provides safe
/// edge-aware layout padding at the bottom similar to [EdgeGuardBottomAction].
class EdgeGuardBottomSheet extends StatelessWidget {
  /// The content of the bottom sheet.
  final Widget child;

  const EdgeGuardBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Bottom sheets conceptually need the exact same protection as bottom actions.
    // They must avoid nav bars, gestures, and IME.

    final scope = EdgeGuardScope.maybeOf(context);
    if (scope != null && !scope.config.protectBottomSheets) {
      return child;
    }

    return EdgeGuardBottomAction(padding: EdgeInsets.zero, child: child);
  }
}
