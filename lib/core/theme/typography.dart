import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      // Titres avec une police s'approchant de Boldonse (ex: Playfair Display)
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppTheme.blackCloset,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppTheme.blackCloset,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.blackCloset,
      ),
      
      // Sous-titres et éditorial avec Cormorant Garamond
      titleLarge: GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppTheme.blackCloset,
      ),
      titleMedium: GoogleFonts.cormorantGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.blackCloset,
      ),
      titleSmall: GoogleFonts.cormorantGaramond(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.blackCloset,
      ),

      // Corps de texte et UI avec Lato
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppTheme.blackCloset,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppTheme.blackCloset,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppTheme.greyText,
      ),
      
      // Boutons et labels
      labelLarge: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
