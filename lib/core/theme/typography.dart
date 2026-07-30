import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'closet_colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return TextTheme(
      // Titres avec une police s'approchant de Boldonse (ex: Playfair Display)
      displayLarge: const TextStyle(
        fontFamily: 'Boldonse',
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Boldonse',
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'Boldonse',
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      
      // Sous-titres et éditorial avec Garamond
      titleLarge: GoogleFonts.ebGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.ebGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.ebGaramond(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),

      // Corps de texte avec Cormorant
      bodyLarge: GoogleFonts.cormorant(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.cormorant(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.cormorant(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: ClosetColors.taupe,
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
