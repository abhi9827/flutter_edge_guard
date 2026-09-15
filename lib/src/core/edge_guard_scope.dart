import 'package:flutter/widgets.dart';

import '../models/edge_guard_platform_info.dart';
import '../models/edge_insets_info.dart';
import 'edge_guard_config.dart';

/// Provides [EdgeInsetsInfo], [EdgeGuardPlatformInfo], and [EdgeGuardConfig] to descendants.
class EdgeGuardScope extends InheritedWidget {
  /// The current configuration.
  final EdgeGuardConfig config;

  /// The current inset information.
  final EdgeInsetsInfo insetsInfo;

  /// The current platform information.
  final EdgeGuardPlatformInfo platformInfo;

  const EdgeGuardScope({
    super.key,
    required this.config,
    required this.insetsInfo,
    required this.platformInfo,
    required super.child,
  });

  /// Retrieves the nearest [EdgeGuardScope] from the given [context].
  ///
  /// Returns null if no [EdgeGuardScope] is found above in the widget tree.
  static EdgeGuardScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EdgeGuardScope>();
  }

  /// Retrieves the nearest [EdgeGuardScope] from the given [context].
  ///
  /// Throws if no [EdgeGuardScope] is found.
  static EdgeGuardScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No EdgeGuardScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(EdgeGuardScope oldWidget) {
    return insetsInfo != oldWidget.insetsInfo ||
        platformInfo != oldWidget.platformInfo ||
        config != oldWidget.config;
  }
}
