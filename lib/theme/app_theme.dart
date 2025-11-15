import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    textTheme: GoogleFonts.notoSansTextTheme(),
    cardTheme: const CardThemeData(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
  );
}
