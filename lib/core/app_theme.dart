import 'package:flutter/material.dart';

class AppTheme {
  // ألوان مبهجة وقريبة من التصميم
  static const Color primaryGreen = Color(0xFF66BB6A);
  static const Color accentGreen = Color(0xFF43A047);
  static const Color titleTheme = Color.fromARGB(255, 15, 75, 17);
  static const Color backraoundCard = Color(0xFFF1F8E9);
  static const Color headenTow = Color.fromARGB(255, 15, 75, 17);

  /// 🌞 Light Theme (كما هو عندك)
  static ThemeData get lightTheme {
    return ThemeData(
      canvasColor: Colors.transparent,
      fontFamily: 'Cairo',
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      primaryColor: primaryGreen,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: accentGreen,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: titleTheme),
        titleTextStyle: TextStyle(
          color: titleTheme,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: titleTheme,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontFamily: 'Cairo',
          color: titleTheme,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: headenTow,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontFamily: 'Cairo',
          color: Color.fromARGB(255, 122, 122, 122),
        ),
      ),
    );
  }

  /// 🌙 Dark Theme (إضافة بسيطة فقط)
  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Cairo',
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: primaryGreen,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreen,
        secondary: accentGreen,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontFamily: 'Cairo',
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontFamily: 'Cairo',
          color: Colors.white70,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontFamily: 'Cairo',
          color: Colors.white54,
        ),
      ),
    );
  }
}
