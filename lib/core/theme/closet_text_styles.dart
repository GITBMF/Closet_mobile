import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'closet_colors.dart';

/// Typographies CLOSET (charte graphique avril 2026) :
/// - Boldonse pour les très grands titres décoratifs (marque)
/// - Garamond (EB Garamond) pour les grands titres / sous-titres
/// - Cormorant pour les textes courants, descriptions et champs de saisie
/// - Lato pour l'interface (UI/UX), navigation, boutons, labels
class ClosetTextStyles {
  ClosetTextStyles._();

  static const TextStyle display = TextStyle(
    fontFamily: 'Boldonse',
    fontSize: 22,
    color: ClosetColors.noir,
  );

  static TextStyle titreEcran = GoogleFonts.ebGaramond(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ClosetColors.vertFonce,
  );

  static TextStyle titreHero = GoogleFonts.ebGaramond(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: ClosetColors.texteSurVert,
  );

  static TextStyle corpsSurVert = GoogleFonts.cormorant(
    fontSize: 15,
    height: 1.45,
    color: ClosetColors.texteSurVert,
  );

  static TextStyle corps = GoogleFonts.cormorant(
    fontSize: 15,
    height: 1.45,
    color: ClosetColors.noir,
  );

  static TextStyle saisie = GoogleFonts.cormorant(
    fontSize: 16,
    color: ClosetColors.noir,
  );

  static TextStyle saisieHint = GoogleFonts.cormorant(
    fontSize: 16,
    color: ClosetColors.texteSecondaire.withValues(alpha: 0.7),
  );

  static TextStyle labelChamp = GoogleFonts.lato(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: ClosetColors.dore,
  );

  static TextStyle labelEtape = GoogleFonts.lato(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: ClosetColors.noir,
  );

  static TextStyle badgePill = GoogleFonts.lato(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.8,
    color: ClosetColors.noir,
  );

  static TextStyle bouton = GoogleFonts.lato(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
  );

  static TextStyle navigation = GoogleFonts.lato(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static TextStyle numeroEtape = GoogleFonts.ebGaramond(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}
