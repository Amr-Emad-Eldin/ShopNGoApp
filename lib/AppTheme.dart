import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color lightGreen = Color(0xFF738440);
  static const Color darkGreen = Color(0xFF36430D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color splashBg = Color(0xFFE8F0DC);
  static const Color Bg = Color(0xFFF4F6F1);

  static TextStyle get primaryFont => GoogleFonts.schibstedGrotesk();

  static final ThemeData LightTheme = ThemeData(
    scaffoldBackgroundColor: Bg,
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      centerTitle: true,
      foregroundColor: darkGreen,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    textTheme: TextTheme(
      headlineLarge: GoogleFonts.schibstedGrotesk(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: darkGreen,
      ),
      headlineSmall: GoogleFonts.schibstedGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: darkGreen,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      selectedItemColor: AppTheme.darkGreen,
      unselectedItemColor: AppTheme.darkGreen,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedLabelStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
