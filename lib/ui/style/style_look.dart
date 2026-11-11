import 'package:flutter/material.dart';

import '../../settings/app_settings.dart';

/// Colours and shapes of one [AppStyle] that Material's [ColorScheme] has no slot for.
/// Widgets read it with [StyleLook.of], so a style change repaints everything at once.
@immutable
class StyleLook extends ThemeExtension<StyleLook> {
  const StyleLook({
    required this.style,
    required this.foreground,
    required this.foregroundMuted,
    required this.selection,
    required this.accent,
    required this.onAccent,
    required this.solidPanel,
    required this.panelBorder,
    required this.panelBorderWidth,
    required this.cornerScale,
    required this.floatingShadow,
  });

  final AppStyle style;

  /// Text and icons drawn on the background or on panels.
  final Color foreground;
  final Color foregroundMuted;

  /// Highlight of the selected tab.
  final Color selection;

  /// The main "play" button.
  final Color accent;
  final Color onAccent;

  /// Panel fill when Liquid Glass is off.
  final Color solidPanel;
  final Color panelBorder;

  /// A thick border is part of the pixel look; other styles use a hairline.
  final double panelBorderWidth;

  /// Multiplies every corner radius: 1 for smooth styles, small for square pixel corners.
  final double cornerScale;

  final List<BoxShadow> floatingShadow;

  static StyleLook of(BuildContext context) =>
      Theme.of(context).extension<StyleLook>() ??
      forStyle(AppSettings.defaultStyle);

  double radius(double base) => base * cornerScale;

  static const _softShadow = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 24),
  ];

  static StyleLook forStyle(AppStyle style) => switch (style) {
    AppStyle.rainbow => const StyleLook(
      style: AppStyle.rainbow,
      foreground: Colors.white,
      foregroundMuted: Color(0xB3FFFFFF),
      selection: Color(0x2EFFFFFF),
      accent: Colors.white,
      onAccent: Color(0xFF2B2F6B),
      solidPanel: Color(0xFF2A2D45),
      panelBorder: Color(0x1FFFFFFF),
      panelBorderWidth: 1,
      cornerScale: 1,
      floatingShadow: _softShadow,
    ),
    AppStyle.dark => const StyleLook(
      style: AppStyle.dark,
      foreground: Color(0xFFF2F2F5),
      foregroundMuted: Color(0x99F2F2F5),
      selection: Color(0x24FFFFFF),
      accent: Color(0xFFF2F2F5),
      onAccent: Color(0xFF0B0B0D),
      solidPanel: Color(0xFF1C1C1F),
      panelBorder: Color(0x1FFFFFFF),
      panelBorderWidth: 1,
      cornerScale: 1,
      floatingShadow: _softShadow,
    ),
    AppStyle.white => const StyleLook(
      style: AppStyle.white,
      foreground: Color(0xFF1B1D2A),
      foregroundMuted: Color(0x991B1D2A),
      selection: Color(0x1A1B1D2A),
      accent: Color(0xFF3D4FA0),
      onAccent: Colors.white,
      solidPanel: Colors.white,
      panelBorder: Color(0x1F000000),
      panelBorderWidth: 1,
      cornerScale: 1,
      floatingShadow: [
        BoxShadow(
          color: Color(0x1F1B1D2A),
          offset: Offset(0, 8),
          blurRadius: 24,
        ),
      ],
    ),
    AppStyle.bit64 => const StyleLook(
      style: AppStyle.bit64,
      foreground: Color(0xFFFFF4D6),
      foregroundMuted: Color(0xB3FFF4D6),
      selection: Color(0xFFE0457B),
      accent: Color(0xFFFFC94A),
      onAccent: Color(0xFF1B1464),
      solidPanel: Color(0xFF1B1464),
      panelBorder: Color(0xFFFFF4D6),
      panelBorderWidth: 3,
      cornerScale: 0.15,
      // A hard offset shadow without blur, like old console menus.
      floatingShadow: [
        BoxShadow(color: Color(0xFF0B0B2B), offset: Offset(4, 4)),
      ],
    ),
  };

  /// The whole Material theme of a style, with this look attached.
  static ThemeData themeFor(AppStyle style) {
    final look = forStyle(style);
    final colorScheme = switch (style) {
      AppStyle.rainbow => ColorScheme.fromSeed(
        seedColor: const Color(0xFF5A6EB1),
        brightness: Brightness.dark,
      ),
      AppStyle.dark => ColorScheme.fromSeed(
        seedColor: const Color(0xFF8E8E93),
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
      ),
      AppStyle.white => ColorScheme.fromSeed(
        seedColor: const Color(0xFF5A6EB1),
        brightness: Brightness.light,
      ),
      AppStyle.bit64 => ColorScheme.fromSeed(
        seedColor: const Color(0xFFE0457B),
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      ),
    };
    final base = ThemeData(
      colorScheme: colorScheme,
      fontFamily: style == AppStyle.bit64 ? pixelFontFamily : null,
      extensions: [look],
    );
    if (style != AppStyle.bit64) return base;
    // The pixel font is twice as wide as a normal one; smaller sizes keep Russian text in place.
    // The theme's own text styles leave their sizes empty until MaterialApp fills them in,
    // so the smaller sizes are taken from the Material type scale. Only the size is set:
    // styles that differ in more than that cannot be animated when the style changes.
    final scale = base.typography.englishLike;
    TextStyle? smaller(TextStyle? style) => style?.fontSize == null
        ? null
        : TextStyle(fontSize: style!.fontSize! * _pixelFontScale);
    final smallerSizes = TextTheme(
      displayLarge: smaller(scale.displayLarge),
      displayMedium: smaller(scale.displayMedium),
      displaySmall: smaller(scale.displaySmall),
      headlineLarge: smaller(scale.headlineLarge),
      headlineMedium: smaller(scale.headlineMedium),
      headlineSmall: smaller(scale.headlineSmall),
      titleLarge: smaller(scale.titleLarge),
      titleMedium: smaller(scale.titleMedium),
      titleSmall: smaller(scale.titleSmall),
      bodyLarge: smaller(scale.bodyLarge),
      bodyMedium: smaller(scale.bodyMedium),
      bodySmall: smaller(scale.bodySmall),
      labelLarge: smaller(scale.labelLarge),
      labelMedium: smaller(scale.labelMedium),
      labelSmall: smaller(scale.labelSmall),
    );
    return base.copyWith(
      textTheme: base.textTheme.merge(smallerSizes),
      primaryTextTheme: base.primaryTextTheme.merge(smallerSizes),
    );
  }

  static const String pixelFontFamily = 'PressStart2P';
  static const double _pixelFontScale = 0.72;

  @override
  StyleLook copyWith() => this;

  /// Styles switch instantly; there is nothing meaningful between two of them.
  @override
  StyleLook lerp(StyleLook? other, double t) =>
      other == null || t < 0.5 ? this : other;
}
