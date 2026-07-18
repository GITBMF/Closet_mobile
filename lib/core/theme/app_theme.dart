import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'typography.dart';

class AppTheme {
  // Couleurs de la charte graphique ClosET
  static const Color blackCloset = Color(0xFF1D1D1B);
  static const Color forestGreen = Color(0xFF1C3D2F);
  static const Color goldCloset = Color(0xFFBC9746);
  static const Color sandBeige = Color(0xFFE5E1D9);
  static const Color offWhite = Color(0xFFF5F2EC);
  static const Color warmCream = Color(0xFFFAF7F2);
  static const Color greyText = Color(0xFF9A9490);
  static const Color goldAccent = Color(0xFFBC8F29);
  static const Color lightSand = Color(0xFFECE8DF);
  static const Color greenLight = Color(0xFF2C5A43);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: offWhite,
      primaryColor: forestGreen,
      colorScheme: const ColorScheme.light(
        primary: forestGreen,
        secondary: goldCloset,
        surface: warmCream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: blackCloset,
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: offWhite,
        foregroundColor: blackCloset,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldCloset,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: forestGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmCream,
        selectedColor: blackCloset,
        labelStyle: AppTypography.textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: sandBeige),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blackCloset,
        selectedItemColor: goldCloset,
        unselectedItemColor: Color(0xFF7A7870),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
