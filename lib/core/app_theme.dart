import 'package:flutter/material.dart';

class AppTheme {
  // ألوان مبهجة وقريبة من التصميم
  static const Color primaryGreen = Color(0xFF66BB6A); // أخضر مبهج
  static const Color accentGreen = Color(0xFF43A047);
  static const Color titleTheme = Color.fromARGB(255, 15, 75, 17);
  static const Color backgroundWhite = Color(0xFFF1F8E9);

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Cairo',
      useMaterial3: true,
      scaffoldBackgroundColor: const Color.fromARGB(255, 252, 252, 252),
      primaryColor: primaryGreen,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGreen,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
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
          color: Colors.black87
          ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontFamily: 'Cairo', 
          color: Colors.black87
          ),
        
        bodySmall: TextStyle(
          fontSize: 12,
          fontFamily: 'Cairo',
          color: Color.fromARGB(255, 122, 122, 122)
          ),
      ),
    );
  }
}
