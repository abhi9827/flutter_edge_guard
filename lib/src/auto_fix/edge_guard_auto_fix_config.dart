/// Configuration for the EdgeGuard auto-fix inset-protection layer.
///
/// Controls which system-bar edges are automatically padded at the
/// [MaterialApp] builder level so existing screens require no edits.
///
/// **Defaults** are chosen to be safe across the widest range of apps:
/// - [applyBottom] is `true` — the navigation / gesture bar is the most
///   common edge-to-edge migration pain point.
/// - [applyTop] is `false` — [Scaffold] + [AppBar] already handles the
///   status-bar inset internally; enabling this would create a double gap
///   above every AppBar.
/// - [applyLeft] and [applyRight] are `true` for landscape / foldable safety.
/// - [enabled] is `true` — set to `false` in release builds or during
///   individual screen testing without touching any screen code.
class EdgeGuardAutoFixConfig {
  /// Whether the auto-fix layer is active.
  ///
  /// When `false`, [EdgeGuardInsetApplier] renders its child unmodified.
  /// Useful for temporarily disabling global padding without removing
  /// [EdgeGuardApp] from the tree.
  final bool enabled;

  /// Whether to apply bottom inset padding (navigation / gesture bar).
  ///
  /// Defaults to `true`. This is the primary edge-to-edge migration fix.
  final bool applyBottom;

  /// Whether to apply top inset padding (status bar).
  ///
  /// Defaults to `false`. Leave this `false` when your screens use
  /// [Scaffold] + [AppBar], which already consume the top inset.
  /// Only set to `true` for apps whose root screens have no [AppBar].
  final bool applyTop;

  /// Whether to apply left inset padding (side gesture strip in landscape).
  ///
  /// Defaults to `true`.
  final bool applyLeft;

  /// Whether to apply right inset padding (side gesture strip in landscape).
  ///
  /// Defaults to `true`.
  final bool applyRight;

  const EdgeGuardAutoFixConfig({
    this.enabled = true,
    this.applyBottom = true,
    this.applyTop = false,
    this.applyLeft = true,
    this.applyRight = true,
  });

  /// The recommended default: protect bottom + sides, leave top to Scaffold.
  static const EdgeGuardAutoFixConfig standard = EdgeGuardAutoFixConfig();

  /// Opt out of all automatic padding (same effect as setting [enabled] to
  /// `false`, but semantically clearer when disabling for specific build
  /// flavours).
  static const EdgeGuardAutoFixConfig disabled =
      EdgeGuardAutoFixConfig(enabled: false);

  /// Full protection on all four edges. Use only for apps whose root screens
  /// have no [AppBar] at all.
  static const EdgeGuardAutoFixConfig allEdges = EdgeGuardAutoFixConfig(
    applyBottom: true,
    applyTop: true,
    applyLeft: true,
    applyRight: true,
  );

  /// Creates a copy of this config with the given fields replaced.
  EdgeGuardAutoFixConfig copyWith({
    bool? enabled,
    bool? applyBottom,
    bool? applyTop,
    bool? applyLeft,
    bool? applyRight,
  }) {
    return EdgeGuardAutoFixConfig(
      enabled: enabled ?? this.enabled,
      applyBottom: applyBottom ?? this.applyBottom,
      applyTop: applyTop ?? this.applyTop,
      applyLeft: applyLeft ?? this.applyLeft,
      applyRight: applyRight ?? this.applyRight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EdgeGuardAutoFixConfig &&
        other.enabled == enabled &&
        other.applyBottom == applyBottom &&
        other.applyTop == applyTop &&
        other.applyLeft == applyLeft &&
        other.applyRight == applyRight;
  }

  @override
  int get hashCode => Object.hash(
        enabled,
        applyBottom,
        applyTop,
        applyLeft,
        applyRight,
      );

  @override
  String toString() =>
      'EdgeGuardAutoFixConfig(enabled: $enabled, bottom: $applyBottom, '
      'top: $applyTop, left: $applyLeft, right: $applyRight)';
}
