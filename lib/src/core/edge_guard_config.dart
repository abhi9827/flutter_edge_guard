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

  const EdgeGuardConfig({
    this.enableDiagnostics = true,
    this.enableInspector = true,
    this.enableDebugOverlay = false,
    this.protectBottomActions = true,
    this.protectBottomSheets = true,
    this.showWarnings = true,
    this.debugOnlyInspector = true,
  });

  /// The default configuration.
  static const EdgeGuardConfig standard = EdgeGuardConfig();
}
