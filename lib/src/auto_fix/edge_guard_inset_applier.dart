import 'package:flutter/widgets.dart';

import 'edge_guard_auto_fix_config.dart';
import 'edge_guard_exempt.dart';

/// Applies system-inset padding globally at the [MaterialApp] builder level.
///
/// This widget is the core of EdgeGuard's **auto-fix** pillar. It reads the
/// current [MediaQuery] padding and applies the edges specified by
/// [EdgeGuardAutoFixConfig], then re-emits a [MediaQuery] with those edges
/// zeroed out so that descendant [SafeArea]s and [Scaffold]s do not
/// double-pad.
///
/// ## Double-padding prevention
///
/// Flutter's [SafeArea] (and [Scaffold]'s internal padding logic) consumes
/// insets from [MediaQuery.padding]. By zeroing the consumed edges in the
/// [MediaQuery] we provide to the subtree, any nested [SafeArea] or widget
/// that reads [MediaQuery.paddingOf] will see zero for those edges and apply
/// no additional padding — giving correct behaviour without touching any
/// screen code.
///
/// ## Opt-out
///
/// Wrap any screen or widget subtree in [EdgeGuardExempt] to bypass the
/// padding applied by this widget for that branch of the tree.
///
/// ```dart
/// // In a full-bleed photo viewer route:
/// EdgeGuardExempt(child: PhotoViewerScreen())
/// ```
///
/// See also:
/// - [EdgeGuardAutoFixConfig] — controls which edges are padded.
/// - [EdgeGuardExempt] — opt-out for individual screens.
/// - [EdgeGuardApp] — wires everything together at the [MaterialApp] level.
class EdgeGuardInsetApplier extends StatelessWidget {
  /// Configuration controlling which inset edges are applied.
  final EdgeGuardAutoFixConfig config;

  /// The widget subtree to protect.
  final Widget child;

  const EdgeGuardInsetApplier({
    super.key,
    this.config = EdgeGuardAutoFixConfig.standard,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // If disabled or the subtree is explicitly opted out, pass through as-is.
    if (!config.enabled || EdgeGuardExempt.isExempt(context)) {
      return child;
    }

    final padding = MediaQuery.paddingOf(context);

    final bottom = config.applyBottom ? padding.bottom : 0.0;
    final top = config.applyTop ? padding.top : 0.0;
    final left = config.applyLeft ? padding.left : 0.0;
    final right = config.applyRight ? padding.right : 0.0;

    // Nothing to apply — avoid inserting unnecessary widgets.
    if (bottom == 0.0 && top == 0.0 && left == 0.0 && right == 0.0) {
      return child;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottom,
        top: top,
        left: left,
        right: right,
      ),
      // Zero out the edges we just consumed so nested SafeAreas/Scaffolds
      // don't re-apply them. We use MediaQuery.of() here (not paddingOf)
      // to get the full MediaQueryData object for copying.
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: padding.copyWith(
            bottom: config.applyBottom ? 0.0 : padding.bottom,
            top: config.applyTop ? 0.0 : padding.top,
            left: config.applyLeft ? 0.0 : padding.left,
            right: config.applyRight ? 0.0 : padding.right,
          ),
        ),
        child: child,
      ),
    );
  }
}
