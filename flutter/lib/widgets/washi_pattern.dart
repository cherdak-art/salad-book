import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

// Фон с узором сэйгайха (волны) — японский мотив, очень слабый
class WashiPattern extends StatelessWidget {
  const WashiPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SeigaihaPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _SeigaihaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Brand.amber.withValues(alpha: 0.07);
    const r = 40.0; // крупнее шаг — меньше дуг, быстрее отрисовка
    for (var row = 0; row * r * 0.5 < size.height + r; row++) {
      final shift = row.isOdd ? r / 2 : 0.0;
      for (var col = -1; col * r < size.width + r; col++) {
        final cx = col * r + shift;
        final cy = row * r * 0.5;
        for (var k = 1; k <= 3; k++) {
          canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, cy), radius: r * k / 3),
            math.pi,
            math.pi,
            false,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
