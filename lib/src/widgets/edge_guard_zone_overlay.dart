import 'package:flutter/widgets.dart';

import '../../flutter_edge_guard.dart' show EdgeGuardInspector;
import '../core/edge_guard_scope.dart';
import 'edge_guard_inspector.dart' show EdgeGuardInspector;

/// A [CustomPainter] that renders color-coded zones representing each category
/// of system inset over the app's surface.
///
/// Zone color legend:
/// - 🔵 Blue    → Status bar
/// - 🟡 Yellow  → Navigation bar / gesture zone
/// - 🟠 Orange  → Keyboard (IME) zone
/// - 🔴 Red     → Display cutout zone
class _ZonePainter extends CustomPainter {
  final EdgeInsets statusBars;
  final EdgeInsets navigationBars;
  final EdgeInsets ime;
  final EdgeInsets displayCutout;

  static const _statusColor = Color(0x552196F3); // blue
  static const _navColor = Color(0x55FFC107); // amber
  static const _imeColor = Color(0x55FF9800); // orange
  static const _cutoutColor = Color(0x55F44336); // red

  const _ZonePainter({
    required this.statusBars,
    required this.navigationBars,
    required this.ime,
    required this.displayCutout,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Status bar zone (top)
    if (statusBars.top > 0) {
      paint.color = _statusColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, statusBars.top),
        paint,
      );
    }

    // Navigation bar zone (bottom)
    if (navigationBars.bottom > 0) {
      paint.color = _navColor;
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          size.height - navigationBars.bottom,
          size.width,
          navigationBars.bottom,
        ),
        paint,
      );
    }

    // Navigation bar zone (left & right, landscape)
    if (navigationBars.left > 0) {
      paint.color = _navColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, navigationBars.left, size.height),
        paint,
      );
    }
    if (navigationBars.right > 0) {
      paint.color = _navColor;
      canvas.drawRect(
        Rect.fromLTWH(
          size.width - navigationBars.right,
          0,
          navigationBars.right,
          size.height,
        ),
        paint,
      );
    }

    // IME zone (bottom, above nav bar)
    if (ime.bottom > 0) {
      paint.color = _imeColor;
      final navOffset = navigationBars.bottom;
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          size.height - ime.bottom - navOffset,
          size.width,
          ime.bottom,
        ),
        paint,
      );
    }

    // Display cutout zone (top)
    if (displayCutout.top > 0) {
      paint.color = _cutoutColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, displayCutout.top),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ZonePainter old) {
    return old.statusBars != statusBars ||
        old.navigationBars != navigationBars ||
        old.ime != ime ||
        old.displayCutout != displayCutout;
  }
}

/// An overlay widget that visually renders color-coded system inset zones
/// over the entire screen for developer debugging purposes.
///
/// Typically toggled from [EdgeGuardInspector] but can be used standalone:
///
/// ```dart
/// Stack(
///   children: [
///     MyApp(),
///     EdgeGuardZoneOverlay(),
///   ],
/// )
/// ```
///
/// Zone legend displayed in the corner:
/// - 🔵 Blue    → Status bar
/// - 🟡 Yellow  → Navigation / Gesture zone
/// - 🟠 Orange  → IME (Keyboard)
/// - 🔴 Red     → Display cutout
class EdgeGuardZoneOverlay extends StatelessWidget {
  const EdgeGuardZoneOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();

    final insets = scope.insetsInfo;

    return IgnorePointer(
      child: Stack(
        children: [
          // Zone painter
          Positioned.fill(
            child: CustomPaint(
              painter: _ZonePainter(
                statusBars: insets.statusBars,
                navigationBars: insets.navigationBars,
                ime: insets.ime,
                displayCutout: insets.displayCutout,
              ),
            ),
          ),
          // Legend
          Positioned(
            top: insets.statusBars.top + 8,
            left: 8,
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xCC1E1E1E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    decoration: TextDecoration.none,
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔵 Status Bar'),
                      Text('🟡 Nav / Gesture'),
                      Text('🟠 IME (Keyboard)'),
                      Text('🔴 Display Cutout'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
