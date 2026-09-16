import 'dart:math' as math;
import 'package:flutter/widgets.dart';

import '../../flutter_edge_guard.dart' show EdgeGuardBottomAction;
import '../core/edge_guard_scope.dart';
import 'edge_guard_bottom_action.dart' show EdgeGuardBottomAction;

/// An animated version of [EdgeGuardBottomAction] that smoothly transitions
/// the bottom padding when the keyboard (IME) appears or disappears.
///
/// On Android 11+ and iOS, the OS animates the keyboard in/out. Flutter's
/// [MediaQuery.viewInsetsOf] updates reactively as the keyboard animates, so
/// wrapping the padding in an [AnimatedContainer] produces a smooth slide-up
/// effect that tracks the native keyboard animation closely.
///
/// Usage:
/// ```dart
/// EdgeGuardAnimatedAction(
///   duration: const Duration(milliseconds: 200),
///   curve: Curves.easeOutCubic,
///   child: ElevatedButton(
///     onPressed: onSubmit,
///     child: const Text('Submit'),
///   ),
/// )
/// ```
class EdgeGuardAnimatedAction extends StatelessWidget {
  /// The action widget (e.g., a button) to protect.
  final Widget child;

  /// Optional extra padding to apply around the child independent of system insets.
  final EdgeInsetsGeometry padding;

  /// Duration of the bottom-padding animation.
  final Duration duration;

  /// Curve for the bottom-padding animation.
  final Curve curve;

  const EdgeGuardAnimatedAction({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);

    double bottomPadding;

    if (scope != null && scope.config.protectBottomActions) {
      final insets = scope.insetsInfo;
      final sysNavBottom = math.max(
        insets.navigationBars.bottom,
        insets.systemGestures.bottom,
      );
      final imeBottom = insets.ime.bottom;
      bottomPadding = math.max(sysNavBottom, imeBottom);
    } else {
      final paddingOf = MediaQuery.paddingOf(context);
      final viewInsetsOf = MediaQuery.viewInsetsOf(context);
      bottomPadding = math.max(paddingOf.bottom, viewInsetsOf.bottom);
    }

    final resolvedPadding =
        padding.resolve(Directionality.maybeOf(context) ?? TextDirection.ltr);
    final totalBottom = bottomPadding + resolvedPadding.bottom;

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      padding: EdgeInsets.only(
        bottom: totalBottom,
        top: resolvedPadding.top,
        left: resolvedPadding.left,
        right: resolvedPadding.right,
      ),
      child: child,
    );
  }
}
