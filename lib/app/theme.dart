import 'package:flutter/material.dart';

/// Тема приложения «Питомец Финни» — стиль Funny Ugly Monster.
/// Кислотные цвета, округлые формы, асимметрия.
class AppTheme {
  static const Color primary = Color(0xFF76C8A0);
  static const Color primaryDark = Color(0xFF4A9B6F);
  static const Color accent = Color(0xFFFF8C42);
  static const Color background = Color(0xFFF5F0E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color error = Color(0xFFE85D5D);
  static const Color success = Color(0xFF4CAF50);

  // ─── HUD-палитра (главная страница) ───
  static const Color hudBg = Color(0xFFFFF9ED);
  static const Color hudRingCenter = Color(0xFFFFEFA5);
  static const Color hudRingEdge = Color(0xFFFFE58F);
  static const Color hudGreen = Color(0xFF4CCB7B);
  static const Color hudOrange = Color(0xFFF59E0B);
  static const Color hudBlue = Color(0xFF4F95FF);
  static const Color hudBadgeBg = Color(0xFFE0F7FA);
  static const Color hudBadgeText = Color(0xFF006064);

  /// Скругление карточек — не идеальное, с лёгкой асимметрией.
  static const BorderRadius cardRadius = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(22),
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(16),
  );

  /// Скругление кнопок — «пластилин».
  static const BorderRadius buttonRadius = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(28),
    bottomLeft: Radius.circular(26),
    bottomRight: Radius.circular(22),
  );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: 'System',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 56),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: Color(0xFFE0D8CC), width: 2),
        ),
        color: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: const BorderSide(color: Color(0xFFD0C8BC), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
