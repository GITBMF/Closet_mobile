import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'closet_colors.dart';
import 'typography.dart';

/// Thème officiel CLOSET.
/// Les constantes statiques exposées ici sont des ALIASES vers ClosetColors
/// pour la compatibilité avec les widgets qui les importent directement.
/// Ne jamais ajouter de nouvelles constantes couleur ici — utiliser ClosetColors.
class AppTheme {
  // ── Aliases de compatibilité (pointent tous vers ClosetColors) ────────────
  static const Color blackCloset = ClosetColors.noir;
  static const Color forestGreen = ClosetColors.vert;
  /// ⚠️  goldCloset est une référence décorative — ne pas utiliser en CTA fond.
  static const Color goldCloset = ClosetColors.dore;
  static const Color sandBeige = Color(0xFFE5E1D9); // Variante sable (chips)
  static const Color offWhite = Color(0xFFF5F2EC);  // AppBar fond light
  static const Color warmCream = ClosetColors.creme;
  static const Color greyText = ClosetColors.taupe;
  static const Color lightSand = Color(0xFFECE8DF);

  // ── Thème clair ───────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ClosetColors.beige,
      primaryColor: ClosetColors.vert,
      colorScheme: const ColorScheme.light(
        primary: ClosetColors.vert,
        secondary: ClosetColors.dore,
        surface: ClosetColors.creme,
        onPrimary: ClosetColors.creme,
        onSecondary: ClosetColors.noir,
        onSurface: ClosetColors.noir,
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: offWhite,
        foregroundColor: ClosetColors.noir,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      // ── CTA Primaire : VERT FORÊT (jamais doré — charte §3.1) ──────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ClosetColors.vert,
          foregroundColor: ClosetColors.creme,
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
          foregroundColor: ClosetColors.vert,
          side: const BorderSide(color: ClosetColors.vert, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmCream,
        selectedColor: ClosetColors.noir,
        labelStyle: AppTypography.textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: sandBeige),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ClosetColors.noir,
        selectedItemColor: ClosetColors.dore,
        unselectedItemColor: ClosetColors.navigationInactif,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ── Thème sombre ──────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ClosetColors.vertFonce,
      primaryColor: ClosetColors.doreClair,
      colorScheme: const ColorScheme.dark(
        primary: ClosetColors.doreClair,
        secondary: ClosetColors.dore,
        surface: Color(0xFF182E25),
        onPrimary: ClosetColors.noir,
        onSecondary: ClosetColors.creme,
        onSurface: ClosetColors.creme,
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: ClosetColors.vertFonce,
        foregroundColor: ClosetColors.creme,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ClosetColors.doreClair,
          foregroundColor: ClosetColors.noir,
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
          foregroundColor: ClosetColors.doreClair,
          side: const BorderSide(color: ClosetColors.doreClair, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF182E25),
        selectedColor: ClosetColors.doreClair,
        labelStyle: AppTypography.textTheme.bodySmall
            ?.copyWith(color: ClosetColors.creme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF223F33)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ClosetColors.vertFonce,
        selectedItemColor: ClosetColors.doreClair,
        unselectedItemColor: ClosetColors.navigationInactif,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
