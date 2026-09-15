import 'dart:ui';

import 'package:flutter/widgets.dart';

/// A comprehensive model of the available insets for the current window.
///
/// This does not invent values; if an inset category is not applicable or
/// unavailable on the current platform, it is represented as [EdgeInsets.zero].
class EdgeInsetsInfo {
  /// Area occupied by the system status bar.
  final EdgeInsets statusBars;

  /// Area occupied/protected by system navigation UI.
  final EdgeInsets navigationBars;

  /// Area where system gestures may conflict with application gestures.
  final EdgeInsets systemGestures;

  /// Area where system gestures will unconditionally override app gestures.
  final EdgeInsets mandatorySystemGestures;

  /// Area reserved for tappable elements to ensure they aren't obscured.
  final EdgeInsets tappableElement;

  /// Keyboard/input-method area.
  final EdgeInsets ime;

  /// Physical display cutout area.
  final EdgeInsets displayCutout;

  /// Area occupied by the caption bar (e.g., desktop window controls).
  final EdgeInsets captionBar;

  /// Area of the display that curves around the edges (waterfall display).
  final EdgeInsets waterfall;

  /// The raw `MediaQuery.paddingOf(context)` value.
  final EdgeInsets padding;

  /// The raw `MediaQuery.viewPaddingOf(context)` value.
  final EdgeInsets viewPadding;

  /// The raw `MediaQuery.viewInsetsOf(context)` value.
  final EdgeInsets viewInsets;

  /// Whether the keyboard is currently considered visible.
  final bool keyboardVisible;

  /// Whether the application appears to be running edge-to-edge.
  final bool isEdgeToEdge;

  /// The current window size.
  final Size windowSize;

  /// The current window orientation.
  final Orientation orientation;

  /// Hardware display features (e.g. fold, hinge, cutout)
  final List<DisplayFeature> displayFeatures;

  const EdgeInsetsInfo({
    required this.statusBars,
    required this.navigationBars,
    required this.systemGestures,
    required this.mandatorySystemGestures,
    required this.tappableElement,
    required this.ime,
    required this.displayCutout,
    required this.captionBar,
    required this.waterfall,
    required this.padding,
    required this.viewPadding,
    required this.viewInsets,
    required this.keyboardVisible,
    required this.isEdgeToEdge,
    required this.windowSize,
    required this.orientation,
    this.displayFeatures = const [],
  });

  /// Serializes to a deterministic JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'statusBars': _insetsToJson(statusBars),
      'navigationBars': _insetsToJson(navigationBars),
      'systemGestures': _insetsToJson(systemGestures),
      'mandatorySystemGestures': _insetsToJson(mandatorySystemGestures),
      'tappableElement': _insetsToJson(tappableElement),
      'ime': _insetsToJson(ime),
      'displayCutout': _insetsToJson(displayCutout),
      'captionBar': _insetsToJson(captionBar),
      'waterfall': _insetsToJson(waterfall),
      'padding': _insetsToJson(padding),
      'viewPadding': _insetsToJson(viewPadding),
      'viewInsets': _insetsToJson(viewInsets),
      'keyboardVisible': keyboardVisible,
      'isEdgeToEdge': isEdgeToEdge,
      'windowSize': {'width': windowSize.width, 'height': windowSize.height},
      'orientation': orientation.name,
      'displayFeatures': displayFeatures
          .map(
            (f) => {
              'type': f.type.name,
              'bounds': {
                'left': f.bounds.left,
                'top': f.bounds.top,
                'right': f.bounds.right,
                'bottom': f.bounds.bottom,
              },
            },
          )
          .toList(),
    };
  }

  Map<String, double> _insetsToJson(EdgeInsets insets) {
    return {
      'top': insets.top,
      'bottom': insets.bottom,
      'left': insets.left,
      'right': insets.right,
    };
  }
}
