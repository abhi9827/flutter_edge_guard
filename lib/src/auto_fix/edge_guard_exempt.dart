import 'package:flutter/widgets.dart';

/// Opts a widget subtree out of the global [EdgeGuardInsetApplier] padding.
///
/// Wrap any screen or widget that manages its own insets (full-bleed media
/// viewers, splash screens, maps, custom navigation shells) in
/// [EdgeGuardExempt] to prevent the global auto-fix padding from being
/// applied to that branch of the tree.
///
/// ## Example
///
/// ```dart
/// // Routes map in your MaterialApp — only this one route is exempt:
/// routes: {
///   '/': (context) => const HomeScreen(),                    // protected ✅
///   '/gallery': (context) => EdgeGuardExempt(               // full-bleed ✅
///     child: const PhotoGalleryScreen(),
///   ),
/// }
/// ```
///
/// [EdgeGuardExempt] uses an [InheritedWidget] internally. The exemption is
/// scoped to the subtree of this widget and will not affect sibling or
/// ancestor routes.
///
/// See also:
/// - [EdgeGuardInsetApplier] — the widget this opts out of.
/// - [EdgeGuardApp] — the root that installs auto-fix globally.
class EdgeGuardExempt extends StatelessWidget {
  /// The widget subtree that should bypass EdgeGuard auto-fix padding.
  final Widget child;

  const EdgeGuardExempt({super.key, required this.child});

  /// Returns `true` when the nearest ancestor [EdgeGuardExempt] has marked
  /// this subtree as exempt.
  ///
  /// Used by [EdgeGuardInsetApplier] to skip padding application.
  static bool isExempt(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_EdgeGuardExemptionMarker>() !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    return _EdgeGuardExemptionMarker(child: child);
  }
}

/// Internal [InheritedWidget] marker — signals that descendants are exempt
/// from EdgeGuard auto-fix padding.
class _EdgeGuardExemptionMarker extends InheritedWidget {
  const _EdgeGuardExemptionMarker({required super.child});

  @override
  bool updateShouldNotify(_EdgeGuardExemptionMarker oldWidget) => false;
}
