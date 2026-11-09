import 'package:flutter/material.dart';

/// Dark backdrop with soft colour glows taken from the Spectrum icon.
/// Liquid Glass needs colour behind it; on a flat background it would look like a grey plate.
class SpectrumBackground extends StatelessWidget {
  const SpectrumBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(painter: _GlowPainter(), size: Size.infinite),
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

class _GlowPainter extends CustomPainter {
  const _GlowPainter();

  static const _base = Color(0xFF0D1030);
  static const _glows = [
    _Glow(Offset(0.12, 0.08), 0.75, Color(0xA66A4CFF)),
    _Glow(Offset(0.95, 0.22), 0.55, Color(0x80FF4D6D)),
    _Glow(Offset(0.05, 0.70), 0.60, Color(0x7329B6F6)),
    _Glow(Offset(0.90, 0.92), 0.55, Color(0x5C66E08A)),
    _Glow(Offset(0.55, 0.45), 0.45, Color(0x40FFB74D)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = _base);
    final scale = size.longestSide;
    for (final glow in _glows) {
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
      canvas.drawRect(bounds, paint);
    }
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => false;
}
