import 'package:flutter/widgets.dart';

import '../core/edge_guard_scope.dart';
import '../diagnostics/edge_guard_diagnostics.dart';
import '../models/edge_guard_report.dart';
import 'edge_guard_zone_overlay.dart';

/// A visual overlay that displays the full diagnostics report for developers.
///
/// Tap the 🐛 button to toggle the text report.
/// Tap the 🎨 button to toggle the visual zone overlay.
///
/// Diagnostics are cached and only recomputed when the [EdgeGuardScope] data
/// actually changes, avoiding unnecessary computation on every frame.
class EdgeGuardInspector extends StatefulWidget {
  /// The application widget to wrap.
  final Widget child;

  const EdgeGuardInspector({super.key, required this.child});

  @override
  State<EdgeGuardInspector> createState() => _EdgeGuardInspectorState();
}

class _EdgeGuardInspectorState extends State<EdgeGuardInspector> {
  bool _showZones = false;

  // Tracks whether we just printed to console (for a brief visual confirmation).
  bool _justPrinted = false;

  // Cached report to avoid re-running diagnostics on every build.
  // Rebuilt only when scope data changes (handled by InheritedWidget notify).
  EdgeGuardReport? _cachedReport;
  Object? _lastScopeIdentity;

  EdgeGuardReport? _getReport(BuildContext context) {
    final scope = EdgeGuardScope.maybeOf(context);
    if (scope == null) return null;
    if (!scope.config.enableInspector) return null;

    // Use identity of insetsInfo + platformInfo as cache key.
    final identity = (scope.insetsInfo, scope.platformInfo, scope.config);
    if (identity != _lastScopeIdentity) {
      _lastScopeIdentity = identity;
      _cachedReport = EdgeGuardDiagnostics.tryInspect(context);
    }
    return _cachedReport;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in Directionality so this overlay works even when placed above
    // MaterialApp (i.e., before any WidgetsApp introduces a text direction).
    // This fixes Text, RichText, Column(crossAxisAlignment.start), etc.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: ExcludeSemantics(
              child: Builder(
                builder: (innerContext) {
                  final report = _getReport(innerContext);
                  if (report == null) return const SizedBox.shrink();

                  final insets = report.insetsInfo;
                  final bottomOffset =
                      16 + insets.ime.bottom + insets.navigationBars.bottom;

                  return Stack(
                    children: [
                      // Zone overlay (behind report panel)
                      if (_showZones) const EdgeGuardZoneOverlay(),

                      // Inspector FAB cluster
                      Positioned(
                        bottom: bottomOffset,
                        left: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Button row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 🐛 — print full diagnostics report to console
                                _InspectorButton(
                                  label: _justPrinted ? '✅' : '🐛',
                                  active: _justPrinted,
                                  tooltip: 'Print Report to Console',
                                  onTap: () {
                                    debugPrint(
                                      '\n╔══ EdgeGuard Diagnostic Report ══╗\n'
                                      '${report.toString()}\n'
                                      '╚══════════════════════════════════╝',
                                    );
                                    setState(() => _justPrinted = true);
                                    // Reset the ✅ indicator after 2 seconds.
                                    Future<void>.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        if (mounted) {
                                          setState(() => _justPrinted = false);
                                        }
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Zone overlay toggle
                                _InspectorButton(
                                  label: '🎨',
                                  active: _showZones,
                                  tooltip: 'Toggle Zones',
                                  onTap: () => setState(() {
                                    _showZones = !_showZones;
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectorButton extends StatelessWidget {
  final String label;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _InspectorButton({
    required this.label,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF7C4DFF) : const Color(0xFF6200EA),
          shape: BoxShape.circle,
          border: active
              ? Border.all(color: const Color(0xFFB39DDB), width: 2)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x50000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
