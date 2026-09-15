import 'package:flutter/widgets.dart';

import '../core/edge_guard_scope.dart';

/// A compact developer overlay showing edge-to-edge diagnostics.
///
/// Wraps the rendering in [ExcludeSemantics] so the diagnostics UI never
/// pollutes the app's accessibility tree or interferes with screen-reader testing.
class EdgeGuardDebugOverlayWidget extends StatelessWidget {
  /// The widget below this overlay.
  final Widget child;

  const EdgeGuardDebugOverlayWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 48, // Below typical status bar
          right: 16,
          child: ExcludeSemantics(
            child: Builder(
              builder: (innerContext) {
                final scope = EdgeGuardScope.maybeOf(innerContext);
                if (scope == null) return const SizedBox.shrink();

                final platform = scope.platformInfo;
                final insets = scope.insetsInfo;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xB3000000,
                    ), // Colors.black.withOpacity(0.7)
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0x3DFFFFFF),
                    ), // Colors.white24
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      decoration: TextDecoration.none,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${platform.platform.toUpperCase()} ${platform.androidSdkInt ?? "API ?"}',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'E2E ${insets.isEdgeToEdge ? "✓" : "✗"}',
                          style: TextStyle(
                            color: insets.isEdgeToEdge
                                ? const Color(0xFF69F0AE)
                                : const Color(
                                    0xFFFF5252,
                                  ), // Colors.greenAccent / Colors.redAccent
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'TOP ${insets.padding.top.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 10,
                          ), // Colors.white70
                        ),
                        Text(
                          'BOTTOM ${insets.padding.bottom.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'IME ${insets.ime.bottom.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'NAV ${platform.navigationMode.name.toUpperCase()}',
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// A public widget for manual injection of the debug overlay.
class EdgeGuardDebugOverlay extends StatelessWidget {
  /// The application to wrap.
  final Widget child;

  const EdgeGuardDebugOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return EdgeGuardDebugOverlayWidget(child: child);
  }
}
