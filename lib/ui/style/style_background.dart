import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../settings/app_settings.dart';
import 'style_look.dart';

/// Full-screen backdrop of the current style. Liquid Glass needs colour and detail behind it:
/// over a flat colour it would look like a grey plate.
class StyleBackground extends StatelessWidget {
  /// [style] overrides the current one, for previews in the settings.
  const StyleBackground({super.key, this.style});

  final AppStyle? style;

  @override
  Widget build(BuildContext context) {
    final painter = switch (style ?? StyleLook.of(context).style) {
      AppStyle.rainbow => const _GlowPainter(_rainbowBase, _rainbowGlows),
      AppStyle.dark => const _GlowPainter(_darkBase, _darkGlows),
      AppStyle.white => const _GlowPainter(_whiteBase, _whiteGlows),
      AppStyle.bit64 => const _PixelPainter(),
    };
    return RepaintBoundary(
      child: CustomPaint(painter: painter, size: Size.infinite),
    );
  }
}

class _Glow {
  const _Glow(this.center, this.radius, this.color);

  /// Position and radius as fractions of the screen size.
  final Offset center;
  final double radius;
  final Color color;
}

// Colours of the Spectrum icon.
const _rainbowBase = Color(0xFF0D1030);
const _rainbowGlows = [
  _Glow(Offset(0.12, 0.08), 0.75, Color(0xA66A4CFF)),
  _Glow(Offset(0.95, 0.22), 0.55, Color(0x80FF4D6D)),
  _Glow(Offset(0.05, 0.70), 0.60, Color(0x7329B6F6)),
  _Glow(Offset(0.90, 0.92), 0.55, Color(0x5C66E08A)),
  _Glow(Offset(0.55, 0.45), 0.45, Color(0x40FFB74D)),
];

// Almost black; two faint grey lights only give the glass something to bend.
const _darkBase = Color(0xFF09090B);
const _darkGlows = [
  _Glow(Offset(0.15, 0.10), 0.70, Color(0x1FFFFFFF)),
  _Glow(Offset(0.90, 0.85), 0.60, Color(0x14FFFFFF)),
];

// Light pastel version of the rainbow.
const _whiteBase = Color(0xFFF4F5FA);
const _whiteGlows = [
  _Glow(Offset(0.12, 0.08), 0.75, Color(0x596A4CFF)),
  _Glow(Offset(0.95, 0.25), 0.55, Color(0x47FF4D6D)),
  _Glow(Offset(0.05, 0.72), 0.60, Color(0x4029B6F6)),
  _Glow(Offset(0.90, 0.95), 0.55, Color(0x3866E08A)),
];

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.base, this.glows);

  final Color base;
  final List<_Glow> glows;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final scale = size.longestSide;
    for (final glow in glows) {
      final center = Offset(
        glow.center.dx * size.width,
        glow.center.dy * size.height,
      );
      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [glow.color, glow.color.withValues(alpha: 0)],
            ).createShader(
              Rect.fromCircle(center: center, radius: glow.radius * scale),
            );
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      base != oldDelegate.base || glows != oldDelegate.glows;
}

/// Retro sunset made of big square pixels: a dithered sky with stars, a striped sun
/// and blocky hills. Drawn once; [RepaintBoundary] keeps it cached.
class _PixelPainter extends CustomPainter {
  const _PixelPainter();

  static const double _pixel = 10;

  /// Sky from top to bottom.
  static const _sky = [
    Color(0xFF0B0B2B),
    Color(0xFF1B1464),
    Color(0xFF3B1A78),
    Color(0xFF7A2A85),
    Color(0xFFC23B7D),
    Color(0xFFF2667A),
  ];
  static const _sunTop = Color(0xFFFFE066);
  static const _sunBottom = Color(0xFFFF8A4C);
  static const _hills = Color(0xFF14103A);
  static const _star = Color(0xFFFFF4D6);

  /// 4×4 ordered dither: blends two neighbouring sky colours without a smooth gradient.
  static const _bayer = [
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final columns = (size.width / _pixel).ceil();
    final rows = (size.height / _pixel).ceil();
    final paint = Paint();
    // Setting behind the hills, low enough to keep text in the middle of the screen readable.
    final sunCenter = Offset(columns / 2, rows * 0.86);
    final sunRadius = math.min(columns, rows) * 0.26;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        paint.color = _colorAt(column, row, rows, sunCenter, sunRadius);
        canvas.drawRect(
          // The extra half pixel hides hairline seams between cells.
          Rect.fromLTWH(
            column * _pixel,
            row * _pixel,
            _pixel + 0.5,
            _pixel + 0.5,
          ),
          paint,
        );
      }
    }
  }

  Color _colorAt(
    int column,
    int row,
    int rows,
    Offset sunCenter,
    double sunRadius,
  ) {
    if (row >= _hillTop(column, rows)) return _hills;

    final toSun = Offset(column + 0.5, row + 0.5) - sunCenter;
    if (toSun.distance <= sunRadius) {
      final sunT = (toSun.dy / sunRadius + 1) / 2;
      // Stripes in the lower half of the sun get thicker towards the horizon.
      final gap = sunT > 0.55 && (row % 4) < ((sunT - 0.55) * 7).floor();
      if (!gap) return Color.lerp(_sunTop, _sunBottom, sunT)!;
    }

    final skyT = (row / rows) * (_sky.length - 1);
    final lower = skyT.floor().clamp(0, _sky.length - 1);
    final upper = math.min(lower + 1, _sky.length - 1);
    final threshold = (_bayer[row % 4][column % 4] + 0.5) / 16;
    final color = (skyT - lower) > threshold ? _sky[upper] : _sky[lower];

    // Stars only in the dark upper sky, at fixed pseudo-random cells.
    if (row < rows * 0.4 && _hash(column, row) % 97 == 0) return _star;
    return color;
  }

  /// Blocky hills along the bottom.
  int _hillTop(int column, int rows) {
    final wave =
        math.sin(column * 0.21) * 2.5 + math.sin(column * 0.07 + 1.3) * 3.5;
    return (rows * 0.86 + wave).round();
  }

  static int _hash(int x, int y) =>
      ((x * 73856093) ^ (y * 19349663)) & 0x7fffffff;

  @override
  bool shouldRepaint(_PixelPainter oldDelegate) => false;
}
