import 'package:flutter/widgets.dart';
import '../../flutter_edge_guard.dart';

/// A smart replacement for [SafeArea] that avoids double padding and
/// handles modern Android edge-to-edge requirements.
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
    final info = EdgeGuardScope.of(context).insetsInfo;
    final currentPadding = info.padding;

    // Calculate required padding avoiding double-padding issues common with nested SafeAreas.
    // MediaQuery will consume padding if we use SafeArea, but EdgeGuard reads it and
    // we can explicitly consume it if we want to mirror SafeArea behavior.
    // For MVP, we will use Flutter's native SafeArea under the hood but with smart defaults,
    // or calculate explicit Padding. Let's calculate explicit padding to have full control.

    var topPadding = top ? currentPadding.top : 0.0;
    var bottomPadding = bottom ? currentPadding.bottom : 0.0;
    var leftPadding = left ? currentPadding.left : 0.0;
    var rightPadding = right ? currentPadding.right : 0.0;

    topPadding = topPadding < minimum.top ? minimum.top : topPadding;
    bottomPadding = bottomPadding < minimum.bottom
        ? minimum.bottom
        : bottomPadding;
    leftPadding = leftPadding < minimum.left ? minimum.left : leftPadding;
    rightPadding = rightPadding < minimum.right ? minimum.right : rightPadding;

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

    // Consume the padding we just applied so nested EdgeGuards/SafeAreas don't double-pad.
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
