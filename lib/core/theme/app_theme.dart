import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => _theme(Brightness.light, const Color(0xff176b5b));
  static ThemeData dark() => _theme(Brightness.dark, const Color(0xff61d5bd));
  static ThemeData _theme(Brightness b, Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: b == Brightness.light
          ? const Color(0xfff4f7f6)
          : const Color(0xff101514),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
