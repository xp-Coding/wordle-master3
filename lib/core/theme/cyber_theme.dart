import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neon_colors.dart';

class CyberTheme {
  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.orbitronTextTheme();

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: NeonColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: NeonColors.cyan,
        secondary: NeonColors.neonMagenta,
        surface: NeonColors.cardSurface,
      ),
      cardTheme: CardTheme(
        color: NeonColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: NeonColors.surfaceBorder, width: 1.5),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: NeonColors.cyan,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          shadows: [
            const Shadow(blurRadius: 10, color: NeonColors.cyan, offset: Offset(0, 0)),
          ],
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: NeonColors.textBright,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: NeonColors.textBright,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: NeonColors.textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonColors.cyan,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 8,
          shadowColor: NeonColors.cyan.withOpacity(0.5),
        ),
      ),
    );
  }
}
