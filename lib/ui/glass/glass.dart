import 'dart:io';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../style/style_look.dart';

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
/// [radius] is scaled by the current style, so the pixel style gets almost square corners.
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

  /// Adds the style's shadow for panels that hover above content, like the tab bar.
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final look = StyleLook.of(context);
    final cornerRadius = look.radius(radius);
    final shadows = floating ? look.floatingShadow : const <BoxShadow>[];
    if (!GlassScope.enabledOf(context)) {
      return _solidPanel(look, cornerRadius, shadows);
    }
    final shape = LiquidRoundedSuperellipse(borderRadius: cornerRadius);
    final content = _withPixelBorder(look, cornerRadius, child);
    if (standalone) {
      return LiquidGlass.withOwnLayer(
        shape: shape,
        settings: _settings(context),
        appearance: _appearance(context),
        useBackdropGroup: true,
        shadows: shadows,
        child: content,
      );
    }
    return LiquidGlass(shape: shape, shadows: shadows, child: content);
  }

  /// The pixel style outlines glass with a thick frame; smooth styles keep the glass edge.
  static Widget _withPixelBorder(
    StyleLook look,
    double cornerRadius,
    Widget child,
  ) {
    if (look.panelBorderWidth <= 1) return child;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: ShapeDecoration(shape: _border(look, cornerRadius)),
      child: child,
    );
  }

  static ShapeBorder _border(StyleLook look, double cornerRadius) =>
      RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        side: BorderSide(color: look.panelBorder, width: look.panelBorderWidth),
      );

  Widget _solidPanel(
    StyleLook look,
    double cornerRadius,
    List<BoxShadow> shadows,
  ) {
    // Solid on purpose: a see-through plate would look almost like glass, and the switch
    // should make a visible difference.
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: _border(look, cornerRadius),
        color: look.solidPanel,
        shadows: shadows,
      ),
      child: child,
    );
  }
}
