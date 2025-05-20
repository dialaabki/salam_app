import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Define Colors used in Themes ---
const Color mainAppColor = Color(0xFF5588A4);
const Color darkTextColor = Color(0xFF30394F);
const Color lightTextColor = Color(0xFF6A7185);
const Color lightBgColor = Colors.white;
const Color secondaryAppColor = Color(0xFF5E94FF);

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default theme

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // --- Define Light and Dark Themes ---
  final ThemeData lightTheme = ThemeData(
    primaryColor: mainAppColor,
    scaffoldBackgroundColor: const Color(0xFFE0E6EE),
    appBarTheme: const AppBarTheme(
      backgroundColor: mainAppColor,
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: darkTextColor),
    ),
    colorScheme: ColorScheme.light(
      primary: mainAppColor,
      secondary: secondaryAppColor,
      background: const Color(0xFFE0E6EE),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: darkTextColor,
      onSurface: darkTextColor,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: darkTextColor),
      headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextColor),
      headlineSmall: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: darkTextColor),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: lightTextColor),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: lightTextColor),
      labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // For button text
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: mainAppColor),
      ),
      labelStyle: GoogleFonts.poppins(color: lightTextColor),
      hintStyle: GoogleFonts.poppins(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryAppColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mainAppColor,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
  );

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: mainAppColor, // Use the same blue as light theme
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: mainAppColor,  //  blue
      background: const Color.fromRGBO(0, 0, 0, 1),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      headlineSmall: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[300]!),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]!),
      labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: mainAppColor),
      ),
      labelStyle: TextStyle(color: Colors.grey[300]),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryAppColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mainAppColor,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
  );

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

