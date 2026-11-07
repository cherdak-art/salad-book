import 'package:flutter/material.dart';

// Японская палитра: сумі (тушь), вашi (рисовая бумага), то (киноварь), ай (индиго), кин (золото),
// коричневый из логотипа «Ладушки»
class Brand {
  static const bg = Color(0xFF14110F); // сумі
  static const surface = Color(0xFF1F1A17);
  static const surface2 = Color(0xFF2B231E);
  static const brown = Color(0xFF8B5A2B); // из логотипа
  static const indigo = Color(0xFF2E4057); // ай
  static const amber = Color(0xFFE0B25B); // кин (золотой акцент)
  static const cream = Color(0xFFF3ECE0); // вашi
  static const text = Color(0xFFF3ECE0);
  static const muted = Color(0xFFA8978A);
  static const danger = Color(0xFFD6452E); // то (киноварь)
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
