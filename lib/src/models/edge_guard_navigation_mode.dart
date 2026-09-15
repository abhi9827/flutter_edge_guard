/// Indicates the type of system navigation in use.
///
/// Navigation mode detection is heuristic and will often be [unknown];
/// flutter_edge_guard intentionally does not read undocumented system settings
/// to improve accuracy.
enum EdgeGuardNavigationMode {
  /// Gesture-based navigation.
  gesture,

  /// Traditional three-button navigation.
  threeButton,

  /// The navigation mode could not be reliably determined from stable signals.
  unknown,
}
