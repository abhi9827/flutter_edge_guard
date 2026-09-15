import 'package:flutter/widgets.dart';

import '../core/edge_guard_scope.dart';
import '../diagnostics/edge_guard_diagnostics.dart';

/// A visual overlay that displays the full diagnostics report for developers.
class EdgeGuardInspector extends StatefulWidget {
  /// The application widget to wrap.
  final Widget child;

  const EdgeGuardInspector({super.key, required this.child});

  @override
  State<EdgeGuardInspector> createState() => _EdgeGuardInspectorState();
}

class _EdgeGuardInspectorState extends State<EdgeGuardInspector> {
  bool _showReport = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ExcludeSemantics(
          child: Builder(
            builder: (innerContext) {
              final scope = EdgeGuardScope.maybeOf(innerContext);
              if (scope == null || !scope.config.enableInspector) {
                return const SizedBox.shrink();
              }

              final report = EdgeGuardDiagnostics.inspect(innerContext);

              return Positioned(
                bottom:
                    16 +
                    report.insetsInfo.ime.bottom +
                    report.insetsInfo.navigationBars.bottom,
                left: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_showReport)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        width: report.insetsInfo.windowSize.width - 32,
                        constraints: const BoxConstraints(maxHeight: 400),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF4A4A4A)),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            report.toString(),
                            style: const TextStyle(
                              color: Color(0xFFE0E0E0),
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showReport = !_showReport;
                        });
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6200EA), // deepPurple roughly
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'BUG',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
