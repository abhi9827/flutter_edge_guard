import 'package:flutter/services.dart' show SystemChrome;
import 'package:flutter/widgets.dart';

import '../core/edge_guard_scope.dart';

/// The edge where the scrim gradient should be rendered.
enum EdgeGuardScrimEdge {
  /// Scrim over the top (status bar) area.
  top,

  /// Scrim over the bottom (navigation bar) area.
  bottom,

  /// Scrim over both top and bottom areas.
  both,
}

/// A gradient scrim widget that improves system bar icon readability in
/// edge-to-edge mode by drawing a subtle dark-to-transparent gradient over
/// the status bar and/or navigation bar zone.
///
/// When running edge-to-edge, white or light content can scroll behind the
/// system bars, making white system icons unreadable. [EdgeGuardScrim] solves
/// this without changing [SystemChrome] colors — it simply paints a gentle
/// gradient scrim over the relevant zones.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     MyScrollableContent(),
///     EdgeGuardScrim(edge: EdgeGuardScrimEdge.both),
///   ],
/// )
/// ```
///
/// No Material or Cupertino dependency. Uses only [DecoratedBox] and
/// [LinearGradient] from `widgets.dart`.
class EdgeGuardScrim extends StatelessWidget {
  /// Which edge(s) to apply the scrim to.
  final EdgeGuardScrimEdge edge;

  /// The color of the scrim at the opaque end (closest to the system bar).
  final Color color;

  /// The opacity of the scrim color at its most opaque end.
  final double maxOpacity;

  const EdgeGuardScrim({
    super.key,
    this.edge = EdgeGuardScrimEdge.both,
    this.color = const Color(0xFF000000),
    this.maxOpacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);
    final padding = scope?.insetsInfo.padding ?? MediaQuery.paddingOf(context);

    final scrimColor = color.withValues(alpha: maxOpacity);
    const transparent = Color(0x00000000);

    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (edge == EdgeGuardScrimEdge.top || edge == EdgeGuardScrimEdge.both)
            _buildScrim(
              height: padding.top + 24,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scrimColor, transparent],
              ),
            ),
          const Spacer(),
          if (edge == EdgeGuardScrimEdge.bottom ||
              edge == EdgeGuardScrimEdge.both)
            _buildScrim(
              height: padding.bottom + 24,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [scrimColor, transparent],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScrim({
    required double height,
    required Gradient gradient,
  }) {
    return SizedBox(
      height: height.clamp(0, double.infinity),
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
      ),
    );
  }
}
