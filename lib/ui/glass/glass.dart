import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

// The only file that uses liquid_glass_renderer (an experimental 1.0 prerelease built on the
// Flutter GPU preview). If it has to be replaced, only this file changes.
//
// Glass refracts what was painted before it. Glass that floats over scrolling content must
// therefore be painted after that content, inside one GlassLayer, so the screen is copied once.

/// Loads the glass shaders early so the first frame does not fall back to plain blur.
/// Linux has no Flutter GPU, so glass there is always the blur fallback and needs no shaders.
Future<void> precacheGlass() async {
  if (Platform.isLinux) return;
  await LiquidGlass.precache();
}

LiquidGlassSettings _settings(BuildContext context) =>
    LiquidGlassSettings.ios27Regular(brightness: Theme.of(context).brightness);

LiquidGlassAppearance _appearance(BuildContext context) =>
    LiquidGlassAppearance.ios27Regular(
      brightness: Theme.of(context).brightness,
    );

/// Turns Liquid Glass on or off for everything below it. Without glass, panels are plain
/// solid plates: no backdrop copy and no shaders, which saves GPU time and battery.
class GlassScope extends InheritedWidget {
  const GlassScope({super.key, required this.enabled, required super.child});

  final bool enabled;

  /// True when there is no [GlassScope] above.
  static bool enabledOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassScope>()?.enabled ?? true;

  @override
  bool updateShouldNotify(GlassScope oldWidget) => enabled != oldWidget.enabled;
}

/// Samples the backdrop once for every [GlassPanel] below it.
class GlassLayer extends StatelessWidget {
  const GlassLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!GlassScope.enabledOf(context)) return child;
    return LiquidGlassLayer(
      settings: _settings(context),
      defaultAppearance: _appearance(context),
      child: child,
    );
  }
}

/// A rounded piece of Liquid Glass. Its [child] is drawn on top of the glass.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 28,
    this.standalone = false,
    this.floating = false,
  });

  final Widget child;
  final double radius;

  /// True when there is no [GlassLayer] above, for example inside the video controls.
  /// Standalone panels share one backdrop copy through the nearest [BackdropGroup].
  final bool standalone;

  /// Adds a soft shadow for panels that hover above content, like the tab bar.
  final bool floating;

  static const _floatingShadow = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 24),
  ];

  @override
  Widget build(BuildContext context) {
    final shadows = floating ? _floatingShadow : const <BoxShadow>[];
    if (!GlassScope.enabledOf(context)) return _plainPanel(context, shadows);
    final shape = LiquidRoundedSuperellipse(borderRadius: radius);
    if (standalone) {
      return LiquidGlass.withOwnLayer(
        shape: shape,
        settings: _settings(context),
        appearance: _appearance(context),
        useBackdropGroup: true,
        shadows: shadows,
        child: child,
      );
    }
    return LiquidGlass(shape: shape, shadows: shadows, child: child);
  }

  Widget _plainPanel(BuildContext context, List<BoxShadow> shadows) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1F000000),
      ),
    );
    // Solid on purpose: a see-through plate would look almost like glass, and the switch
    // should make a visible difference.
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: isDark ? const Color(0xFF2A2D45) : const Color(0xFFFFFFFF),
        shadows: shadows,
      ),
      child: child,
    );
  }
}
