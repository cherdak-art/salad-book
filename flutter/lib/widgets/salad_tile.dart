import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

// Плитка салата: при нажатии слегка сжимается
class SaladTile extends StatefulWidget {
  const SaladTile({super.key, required this.salad, required this.onTap});

  final Salad salad;
  final VoidCallback onTap;

  @override
  State<SaladTile> createState() => _SaladTileState();
}

class _SaladTileState extends State<SaladTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Brand.surface2, Brand.surface],
            ),
            border: Border.all(color: Brand.brown.withValues(alpha: 0.55)),
          ),
          child: Hero(
            tag: 'salad-${widget.salad.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                widget.salad.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
