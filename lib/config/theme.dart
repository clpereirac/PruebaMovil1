import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF5E72E4);
  static const Color accentColor = Color(0xFF11CDEF);
  static const Color backgroundColor = Color(0xFFF8F9FE);
  static const Color textColor = Color(0xFF525F7F);
  static const Color darkBackgroundColor = Color(0xFF1A1B29);
  static const Color darkTextColor = Color(0xFFE0E0E0);

  // Tamaños de texto más grandes para accesibilidad
  static const double fontSizeSmall = 16.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeLarge = 22.0;
  static const double fontSizeExtraLarge = 26.0;

  // Tema claro
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.rubikTextTheme().copyWith(
      bodyLarge: TextStyle(color: textColor, fontSize: fontSizeMedium),
      bodyMedium: TextStyle(color: textColor, fontSize: fontSizeMedium),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: fontSizeExtraLarge,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    textTheme: GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: TextStyle(color: darkTextColor, fontSize: fontSizeMedium),
      bodyMedium: TextStyle(color: darkTextColor, fontSize: fontSizeMedium),
      titleLarge: TextStyle(
        color: darkTextColor,
        fontSize: fontSizeExtraLarge,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: darkTextColor,
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF2D2E3E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
