import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_spacing.dart';
import 'closet_colors.dart';
import 'typography.dart';

/// Thème officiel CLOSET.
///
/// Ce fichier ne déclare aucune couleur : tout vient de [ClosetColors], et
/// toute la typographie de [AppTypography], elle-même dérivée de
/// `ClosetTextStyles`. Son rôle est de faire en sorte que les widgets Material
/// non habillés à la main tombent sur la charte plutôt que sur les défauts de
/// Flutter.
///
/// Les valeurs reprises ici sont celles relevées sur la maquette pour les
/// composants correspondants — notamment la barre de navigation `13:1182` et
/// l'en-tête des écrans, afin que le thème ne contredise plus `ClosetBottomNav`
/// et `ClosetAppBar`, qui étaient jusqu'ici les seuls conformes.
class AppTheme {
  AppTheme._();

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
      textTheme: AppTypography.textTheme.apply(
        bodyColor: ClosetColors.noir,
        displayColor: ClosetColors.noir,
      ),
      appBarTheme: const AppBarTheme(
        // `ClosetAppBar` emploie `beige` (#F3EBDD, Application Background 100).
        // Le thème utilisait un #F5F2EC absent de la palette.
        backgroundColor: ClosetColors.beige,
        foregroundColor: ClosetColors.noir,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      // ── CTA primaire : vert profond, jamais doré (charte §3.1) ──────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ClosetColors.vert,
          foregroundColor: ClosetColors.creme,
          elevation: 0,
          // La maquette écrit ses boutons en Lato 500, sans capitales ni
          // interlettrage ajouté : `labelLarge` est déjà le bon style.
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p24,
            vertical: AppSpacing.p16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClosetColors.vert,
          side: const BorderSide(
            color: ClosetColors.vert,
            width: AppStroke.moyen,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p24,
            vertical: AppSpacing.p16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        // Aligné sur `ClosetChip` : pilule, fond gris clair bordé doré à
        // l'état inactif, vert profond plein à l'état actif.
        backgroundColor: ClosetColors.carteFond,
        selectedColor: ClosetColors.vert,
        labelStyle: AppTypography.textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.bouton),
          side: const BorderSide(color: ClosetColors.fond300),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p8,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        // Relevé de `13:1182` : la pilule est en Emerald Green 500, l'onglet
        // actif porte son libellé en #B58A40, les inactifs sont blancs.
        // Le chrome autour de la pilule reprend le fond d'écran (`#F3EBDD`).
        backgroundColor: ClosetColors.fond100,
        selectedItemColor: ClosetColors.navigationActifTexte,
        unselectedItemColor: ClosetColors.navigationInactif,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ── Thème sombre ──────────────────────────────────────────────────────────
  // La maquette ne décrit pas de mode sombre. Ce thème est une extrapolation :
  // il reprend les surfaces immersives de la rampe Night Green et le doré
  // lisible sur fond sombre. Il n'a donc pas valeur de référence Figma.

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ClosetColors.vertFonce,
      primaryColor: ClosetColors.doreClair,
      colorScheme: const ColorScheme.dark(
        primary: ClosetColors.doreClair,
        secondary: ClosetColors.dore,
        surface: ClosetColors.emeraude500,
        onPrimary: ClosetColors.noir,
        onSecondary: ClosetColors.creme,
        onSurface: ClosetColors.creme,
      ),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: ClosetColors.creme,
        displayColor: ClosetColors.creme,
      ),
      cardColor: ClosetColors.emeraude500,
      canvasColor: ClosetColors.vertFonce,
      dividerColor: ClosetColors.emeraude400,
      iconTheme: const IconThemeData(color: ClosetColors.creme),
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
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p24,
            vertical: AppSpacing.p16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClosetColors.doreClair,
          side: const BorderSide(
            color: ClosetColors.doreClair,
            width: AppStroke.moyen,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p24,
            vertical: AppSpacing.p16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.bouton),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ClosetColors.emeraude500,
        selectedColor: ClosetColors.doreClair,
        labelStyle: AppTypography.textTheme.bodyMedium
            ?.copyWith(color: ClosetColors.creme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.bouton),
          side: const BorderSide(color: ClosetColors.emeraude400),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p8,
        ),
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
