import 'package:flutter/material.dart';

import '../format.dart';

// Число граммов, которое плавно меняется при изменении значения
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
