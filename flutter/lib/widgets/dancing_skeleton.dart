import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

// Танцующий скелет: руки и ноги качаются, корпус подпрыгивает
class DancingSkeleton extends StatefulWidget {
  const DancingSkeleton({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  State<DancingSkeleton> createState() => _DancingSkeletonState();
}

class _DancingSkeletonState extends State<DancingSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => CustomPaint(
        size: Size.square(widget.size),
        painter: _SkeletonPainter(_c.value, widget.color ?? Brand.cream),
      ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final line = Paint()
      ..color = color
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = color;

    final phase = t * 2 * math.pi;
    final bob = math.sin(phase).abs() * s * 0.05;
    final cx = s / 2;

    // голова
    canvas.drawCircle(Offset(cx, s * 0.16 - bob), s * 0.1, fill);

    final neck = Offset(cx, s * 0.3 - bob);
    final hip = Offset(cx, s * 0.58 - bob);
    canvas.drawLine(neck, hip, line);

    // руки: качаются в противофазе
    final armA = math.sin(phase) * 0.8;
    final armB = math.sin(phase + math.pi) * 0.8;
    _limb(canvas, line, neck, s * 0.26, math.pi * 0.7 + armA);
    _limb(canvas, line, neck, s * 0.26, -math.pi * 0.7 + armB);

    // ноги: переступают
    final legA = math.sin(phase + math.pi / 2) * 0.45;
    final legB = math.sin(phase - math.pi / 2) * 0.45;
    _limb(canvas, line, hip, s * 0.32, 0.35 + legA);
    _limb(canvas, line, hip, s * 0.32, -0.35 + legB);
  }

  // угол отсчитывается от направления «вниз»
  void _limb(Canvas c, Paint p, Offset from, double len, double theta) {
    final to = Offset(from.dx + len * math.sin(theta), from.dy + len * math.cos(theta));
    c.drawLine(from, to, p);
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter old) => old.t != t || old.color != color;
}
