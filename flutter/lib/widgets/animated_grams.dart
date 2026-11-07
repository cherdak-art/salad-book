import 'package:flutter/material.dart';

import '../format.dart';

// Граммы, которые плавно меняются при изменении значения
class AnimatedGrams extends StatelessWidget {
  const AnimatedGrams({super.key, required this.value, this.style});

  final double value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Text('${fmtGrams(v)} г', style: style),
    );
  }
}

// Килограммы с плавной анимацией
class AnimatedKg extends StatelessWidget {
  const AnimatedKg({super.key, required this.value, this.style});

  final double value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Text('${fmtKg(v)} кг', style: style),
    );
  }
}
