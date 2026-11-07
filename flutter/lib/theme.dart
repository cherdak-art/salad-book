import 'package:flutter/material.dart';

// Цвета: тёмная основа, коричневый из логотипа «Ладушки» и янтарный акцент
class Brand {
  static const bg = Color(0xFF120C08);
  static const surface = Color(0xFF1E1510);
  static const surface2 = Color(0xFF2A1E17);
  static const brown = Color(0xFF9A5A2B);
  static const amber = Color(0xFFF2B35A);
  static const cream = Color(0xFFF4EFE9);
  static const text = Color(0xFFF6EDE3);
  static const muted = Color(0xFFA89383);
  static const danger = Color(0xFFE05A4F);
}

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Brand.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Brand.brown,
      brightness: Brightness.dark,
      primary: Brand.amber,
      surface: Brand.surface,
      error: Brand.danger,
    ),
    textTheme: base.textTheme.apply(bodyColor: Brand.text, displayColor: Brand.text),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Brand.surface2,
      hintStyle: const TextStyle(color: Brand.muted),
      labelStyle: const TextStyle(color: Brand.muted),
      prefixIconColor: Brand.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.amber,
        foregroundColor: Brand.bg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
