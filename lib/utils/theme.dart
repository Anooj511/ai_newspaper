import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── COLORS ──
  static const Color lightBackground = Color(0xFFF5F0E8);
  static const Color lightSurface = Color(0xFFEDE8D8);
  static const Color lightInk = Color(0xFF1A1008);
  static const Color lightAccent = Color(0xFF8B1A1A);

  static const Color darkBackground = Color(0xFF141008);
  static const Color darkSurface = Color(0xFF1E1810);
  static const Color darkInk = Color(0xFFE8E0D0);
  static const Color darkAccent = Color(0xFFC0392B);

  static const Color gold = Color(0xFFB8860B);

  // ── LIGHT THEME ──
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightAccent,
      surface: lightSurface,
      onSurface: lightInk,
    ),
    textTheme: TextTheme(
      // Masthead
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: lightInk,
      ),
      // Section headlines
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: lightInk,
      ),
      // Article headlines
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: lightInk,
      ),
      // Article body
      bodyLarge: GoogleFonts.libreBaskerville(
        fontSize: 15,
        height: 1.8,
        color: lightInk,
      ),
      bodyMedium: GoogleFonts.libreBaskerville(
        fontSize: 13,
        height: 1.75,
        color: lightInk,
      ),
      // Labels, meta, source names
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
        color: lightAccent,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightInk,
      foregroundColor: lightBackground,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: lightBackground,
      ),
    ),
    dividerColor: lightInk.withOpacity(0.2),
  );

  // ── DARK THEME ──
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkAccent,
      surface: darkSurface,
      onSurface: darkInk,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: darkInk,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: darkInk,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkInk,
      ),
      bodyLarge: GoogleFonts.libreBaskerville(
        fontSize: 15,
        height: 1.8,
        color: darkInk,
      ),
      bodyMedium: GoogleFonts.libreBaskerville(
        fontSize: 13,
        height: 1.75,
        color: darkInk,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
        color: darkAccent,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkInk,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkInk,
      ),
    ),
    dividerColor: darkInk.withOpacity(0.2),
  );
}