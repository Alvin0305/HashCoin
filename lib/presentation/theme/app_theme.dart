import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00796B),
      brightness: Brightness.light,
      primary: const Color(0xFF00796B),
      secondary: const Color(0xFFFF7043),
      surface: const Color(0xFFF5F5F5),
      onSurface: const Color(0xFF212121),
      error: const Color(0xFFB00020),
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.comicNeue().fontFamily,
    textTheme: GoogleFonts.comicNeueTextTheme(ThemeData.light().textTheme)
        .copyWith(
          headlineSmall: GoogleFonts.comicNeue(fontWeight: FontWeight.bold),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00796B),
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade600),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF7043),
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00796B),
      brightness: Brightness.dark,
      primary: const Color(0xFF4DB6AC),
      secondary: const Color(0xFFff8a65),
      surface: const Color(0xFF121212),
      onSurface: const Color(0xFFE0E0E0),
      error: const Color(0xFFCF6679),
    ),
    useMaterial3: true,

    fontFamily: GoogleFonts.comicNeue().fontFamily,

    textTheme: GoogleFonts.comicNeueTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          headlineSmall: GoogleFonts.comicNeue(fontWeight: FontWeight.bold),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121),
      foregroundColor: Color(0xFFE0E0E0),
      elevation: 2,
      centerTitle: true,
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4DB6AC),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade400),
      prefixIconColor: Colors.grey.shade400,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFff8a65),
      foregroundColor: Colors.black,
    ),
  );
}
