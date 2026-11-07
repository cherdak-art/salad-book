import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

// Плитка салата: при нажатии слегка сжимается, без Hero (текст не «рвётся» при переходе)
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Brand.indigo.withValues(alpha: 0.55),
                Brand.surface,
              ],
            ),
            border: Border.all(color: Brand.amber.withValues(alpha: 0.35)),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  widget.salad.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.25),
                ),
              ),
              // печать ханко в углу
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Brand.danger, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
