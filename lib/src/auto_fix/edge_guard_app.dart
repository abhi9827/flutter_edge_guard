import 'package:flutter/material.dart';

import '../core/edge_guard.dart';
import '../core/edge_guard_config.dart';
import 'edge_guard_auto_fix_config.dart';
import 'edge_guard_exempt.dart';
import 'edge_guard_inset_applier.dart';

/// A drop-in replacement for [MaterialApp] that automatically applies
/// edge-to-edge inset protection to every screen in your app — with zero
/// changes required to individual screen classes.
///
/// ## Migration (one line change)
///
/// ```dart
/// // BEFORE
/// MaterialApp(home: HomeScreen(), routes: { ... })
///
/// // AFTER — zero edits to HomeScreen or any route
/// EdgeGuardApp(home: HomeScreen(), routes: { ... })
/// ```
///
/// ## What it does
///
/// 1. Installs [EdgeGuard] at the root for diagnostics and inset data.
/// 2. Wraps every route in [EdgeGuardInsetApplier], which pads the edges
///    specified by [autoFixConfig] and zeros them out of [MediaQuery] so
///    descendant [SafeArea]s and [Scaffold]s do not double-pad.
///
/// ## Default behaviour
///
/// - **Bottom** inset (navigation / gesture bar) is **always** padded.
/// - **Top** inset (status bar) is **not** padded by default — [Scaffold] +
///   [AppBar] already handles this. Enable [EdgeGuardAutoFixConfig.applyTop]
///   only for screens without an [AppBar].
/// - **Left / Right** insets (side gesture strips in landscape) are padded.
///
/// ## Opting individual screens out
///
/// Full-bleed screens (media viewers, splash screens, custom navigation
/// shells) can opt out of the global padding:
///
/// ```dart
/// routes: {
///   '/': (context) => const HomeScreen(),                    // protected ✅
///   '/gallery': (context) => EdgeGuardExempt(               // full-bleed ✅
///     child: const GalleryScreen(),
///   ),
/// }
/// ```
///
/// ## Keeping your existing MaterialApp
///
/// If you can't replace [MaterialApp] directly, use the static [wrap] helper
/// inside your existing `builder:` parameter instead:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => EdgeGuardApp.wrap(
///     context,
///     child!,
///     config: const EdgeGuardConfig(),
///     autoFixConfig: const EdgeGuardAutoFixConfig(),
///   ),
///   home: const HomeScreen(),
/// )
/// ```
///
/// See also:
/// - [EdgeGuardAutoFixConfig] — controls which edges are padded.
/// - [EdgeGuardExempt] — opt-out for individual screens.
/// - [EdgeGuardInsetApplier] — the underlying padding widget.
/// - [EdgeGuardConfig] — diagnostics configuration.
class EdgeGuardApp extends StatelessWidget {
  // ─── EdgeGuard-specific parameters ─────────────────────────────────────────

  /// Configuration for the EdgeGuard diagnostics layer.
  final EdgeGuardConfig config;

  /// Configuration for the auto-fix inset-protection layer.
  final EdgeGuardAutoFixConfig autoFixConfig;

  // ─── MaterialApp parameters (forwarded verbatim) ────────────────────────────

  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget? home;
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final TransitionBuilder? builder;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;
  final ThemeMode? themeMode;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool debugShowMaterialGrid;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final String? restorationScopeId;
  final ScrollBehavior? scrollBehavior;

  const EdgeGuardApp({
    super.key,
    // EdgeGuard params
    this.config = EdgeGuardConfig.standard,
    this.autoFixConfig = EdgeGuardAutoFixConfig.standard,
    // MaterialApp params
    this.navigatorKey,
    this.home,
    this.routes,
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.theme,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
  });

  /// Wraps a [child] widget (typically the [MaterialApp.builder] child) with
  /// the EdgeGuard diagnostics scope and inset-protection layer.
  ///
  /// Use this when you already have a [MaterialApp] and cannot replace it:
  ///
  /// ```dart
  /// MaterialApp(
  ///   builder: (context, child) => EdgeGuardApp.wrap(
  ///     context,
  ///     child!,
  ///   ),
  ///   home: const HomeScreen(),
  /// )
  /// ```
  static Widget wrap(
    BuildContext context,
    Widget child, {
    EdgeGuardConfig config = EdgeGuardConfig.standard,
    EdgeGuardAutoFixConfig autoFixConfig = EdgeGuardAutoFixConfig.standard,
  }) {
    return EdgeGuard(
      config: config,
      child: EdgeGuardInsetApplier(
        config: autoFixConfig,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: home,
      routes: routes ?? const <String, WidgetBuilder>{},
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      title: title,
      onGenerateTitle: onGenerateTitle,
      theme: theme,
      darkTheme: darkTheme,
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
      debugShowMaterialGrid: debugShowMaterialGrid,
      showPerformanceOverlay: showPerformanceOverlay,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
      showSemanticsDebugger: showSemanticsDebugger,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      shortcuts: shortcuts,
      actions: actions,
      restorationScopeId: restorationScopeId,
      scrollBehavior: scrollBehavior,
      builder: (context, child) {
        // 1. Run the user's own builder first (if they supplied one),
        //    so their wrapping (e.g. a custom overlay) is still applied.
        final innerChild = builder?.call(context, child) ?? child!;

        // 2. Wrap with EdgeGuard diagnostics scope + auto-fix inset applier.
        return EdgeGuard(
          config: config,
          child: EdgeGuardInsetApplier(
            config: autoFixConfig,
            child: innerChild,
          ),
        );
      },
    );
  }
}

/// A convenience alias — [EdgeGuardExempt] re-exported via the auto_fix
/// barrel so callers only need one import.
///
/// ```dart
/// import 'package:flutter_edge_guard/flutter_edge_guard.dart';
///
/// EdgeGuardExempt(child: GalleryScreen())
/// ```
// ignore: unused_element
typedef _ExemptAlias = EdgeGuardExempt;
