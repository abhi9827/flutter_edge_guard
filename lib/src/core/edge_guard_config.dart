import '../auto_fix/edge_guard_auto_fix_config.dart';

/// Configuration options for the EdgeGuard system.
class EdgeGuardConfig {
  /// Whether diagnostics are enabled.
  final bool enableDiagnostics;

  /// Whether the EdgeGuard inspector should be enabled/available.
  final bool enableInspector;

  /// Whether the debug overlay should be shown in development.
  final bool enableDebugOverlay;

  /// Whether EdgeGuardBottomAction should actively apply protection.
  final bool protectBottomActions;

  /// Whether EdgeGuardBottomSheet should actively apply protection.
  final bool protectBottomSheets;

  /// Whether diagnostic warnings should be printed to the console.
  final bool showWarnings;

  /// Whether the inspector is strictly limited to debug mode.
  final bool debugOnlyInspector;

  /// Configuration for the auto-fix inset-protection layer.
  ///
  /// Defaults to [EdgeGuardAutoFixConfig.standard], which protects the bottom
  /// edge (navigation / gesture bar) and sides, leaving the top to [Scaffold].
  final EdgeGuardAutoFixConfig autoFix;

  const EdgeGuardConfig({
    this.enableDiagnostics = false,
    this.enableInspector = false,
    this.enableDebugOverlay = false,
    this.protectBottomActions = true,
    this.protectBottomSheets = true,
    this.showWarnings = false,
    this.debugOnlyInspector = false,
    this.autoFix = EdgeGuardAutoFixConfig.standard,
  });

  /// The default configuration.
  static const EdgeGuardConfig standard = EdgeGuardConfig();

  /// Creates a copy of this config with the given fields replaced.
  EdgeGuardConfig copyWith({
    bool? enableDiagnostics,
    bool? enableInspector,
    bool? enableDebugOverlay,
    bool? protectBottomActions,
    bool? protectBottomSheets,
    bool? showWarnings,
    bool? debugOnlyInspector,
    EdgeGuardAutoFixConfig? autoFix,
  }) {
    return EdgeGuardConfig(
      enableDiagnostics: enableDiagnostics ?? this.enableDiagnostics,
      enableInspector: enableInspector ?? this.enableInspector,
      enableDebugOverlay: enableDebugOverlay ?? this.enableDebugOverlay,
      protectBottomActions: protectBottomActions ?? this.protectBottomActions,
      protectBottomSheets: protectBottomSheets ?? this.protectBottomSheets,
      showWarnings: showWarnings ?? this.showWarnings,
      debugOnlyInspector: debugOnlyInspector ?? this.debugOnlyInspector,
      autoFix: autoFix ?? this.autoFix,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EdgeGuardConfig &&
        other.enableDiagnostics == enableDiagnostics &&
        other.enableInspector == enableInspector &&
        other.enableDebugOverlay == enableDebugOverlay &&
        other.protectBottomActions == protectBottomActions &&
        other.protectBottomSheets == protectBottomSheets &&
        other.showWarnings == showWarnings &&
        other.debugOnlyInspector == debugOnlyInspector &&
        other.autoFix == autoFix;
  }

  @override
  int get hashCode => Object.hash(
        enableDiagnostics,
        enableInspector,
        enableDebugOverlay,
        protectBottomActions,
        protectBottomSheets,
        showWarnings,
        debugOnlyInspector,
        autoFix,
      );
}
