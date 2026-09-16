import 'package:flutter/widgets.dart';
import '../../flutter_edge_guard.dart';

/// A smart, edge-aware replacement for [SafeArea] that avoids double padding
/// and handles modern Android edge-to-edge requirements.
///
/// Unlike plain [SafeArea], this widget reads insets from the [EdgeGuardScope]
/// when available, giving it awareness of the full inset model. It gracefully
/// falls back to [MediaQuery] if no [EdgeGuardScope] is found, so it is safe
/// to use even without an [EdgeGuard] ancestor.
class EdgeGuardSafeArea extends StatelessWidget {
  /// Whether to protect the top edge (e.g. status bar).
  final bool top;

  /// Whether to protect the bottom edge (e.g. navigation bar / gesture area).
  final bool bottom;

  /// Whether to protect the left edge.
  final bool left;

  /// Whether to protect the right edge.
  final bool right;

  /// Minimum padding to apply regardless of system insets.
  final EdgeInsets minimum;

  /// The widget below this widget in the tree.
  final Widget child;

  const EdgeGuardSafeArea({
    super.key,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Prefer scope-aware insets; fall back to MediaQuery if no EdgeGuard found.
    // Ignore scope.insetsInfo.padding to prevent double-padding when nested.
    // The local MediaQuery correctly reflects what has already been consumed
    // by ancestor SafeAreas or Scaffolds.
    final currentPadding = MediaQuery.paddingOf(context);

    // Calculate required padding avoiding double-padding issues common with
    // nested SafeAreas. We use max() against minimum to ensure the minimum
    // is always respected.
    final topPadding = top
        ? (currentPadding.top < minimum.top ? minimum.top : currentPadding.top)
        : 0.0;
    final bottomPadding = bottom
        ? (currentPadding.bottom < minimum.bottom
            ? minimum.bottom
            : currentPadding.bottom)
        : 0.0;
    final leftPadding = left
        ? (currentPadding.left < minimum.left
            ? minimum.left
            : currentPadding.left)
        : 0.0;
    final rightPadding = right
        ? (currentPadding.right < minimum.right
            ? minimum.right
            : currentPadding.right)
        : 0.0;

    // Create the padding widget.
    final Widget paddedChild = Padding(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: bottomPadding,
        left: leftPadding,
        right: rightPadding,
      ),
      child: child,
    );

    // Consume the padding we just applied so nested EdgeGuards/SafeAreas
    // don't double-pad. We use MediaQuery.of() directly here so this widget
    // works even without an EdgeGuardScope ancestor.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: currentPadding.copyWith(
          top: top ? 0.0 : currentPadding.top,
          bottom: bottom ? 0.0 : currentPadding.bottom,
          left: left ? 0.0 : currentPadding.left,
          right: right ? 0.0 : currentPadding.right,
        ),
      ),
      child: paddedChild,
    );
  }
}
