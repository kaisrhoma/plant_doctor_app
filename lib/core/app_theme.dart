import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF66BB6A);
  static const Color accentGreen = Color(0xFF43A047);
  static const Color titleTheme = Color.fromARGB(255, 15, 75, 17);
  static const Color backraoundCard = Color(0xFFF1F8E9);
  static const Color headenTow = Color.fromARGB(255, 15, 75, 17);

  /// 🌞 Light Theme (قريب من الأصلي + تحسينات بسيطة)
  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      secondary: accentGreen,
    );

    return ThemeData(
      fontFamily: 'Cairo',
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: cs,
      primaryColor: primaryGreen,

      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.transparent,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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

      // ✅ يساعد الكروت تتبع الثيم
      cardColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        margin: EdgeInsets.zero,
      ),

      // ✅ يساعد ListTile
      listTileTheme: const ListTileThemeData(
        iconColor: titleTheme,
        textColor: titleTheme,
      ),

      // ✅ Dialog / BottomSheet يتبع الثيم بدل ما يبقى غريب في الدارك
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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

  /// 🌙 Dark Theme (نفس الأصلي لكن مضبوط)
  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      primary: primaryGreen,
      secondary: accentGreen,
    );

    return ThemeData(
      fontFamily: 'Cairo',
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: cs,
      primaryColor: primaryGreen,

      scaffoldBackgroundColor: const Color(0xFF121212),
      canvasColor: const Color(0xFF121212),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212), // ✅ بدل transparent
        surfaceTintColor: Colors.transparent,
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

      // ✅ مهم: الكروت والليست تايل والديا로그 يلتزمون بالدارك
      cardColor: const Color(0xFF1E1E1E),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
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
