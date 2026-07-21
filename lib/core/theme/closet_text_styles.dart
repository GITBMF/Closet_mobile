import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'closet_colors.dart';

/// Typographies CLOSET :
/// - Boldonse pour les très grands titres décoratifs (marque)
/// - Cormorant Garamond (serif, italique) pour les grands titres
/// - EB Garamond pour les textes courants et champs de saisie
/// - Lato pour les labels en capitales espacées
class ClosetTextStyles {
  ClosetTextStyles._();

  static const TextStyle display = TextStyle(
    fontFamily: 'Boldonse',
    fontSize: 24,
    color: ClosetColors.noir,
  );

  static TextStyle titreEcran = GoogleFonts.cormorantGaramond(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: ClosetColors.vertFonce,
  );

  static TextStyle titreHero = GoogleFonts.cormorantGaramond(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: ClosetColors.texteSurVert,
  );

  static TextStyle corpsSurVert = GoogleFonts.ebGaramond(
    fontSize: 17,
    height: 1.45,
    color: ClosetColors.texteSurVert,
  );

  static TextStyle corps = GoogleFonts.ebGaramond(
    fontSize: 17,
    height: 1.45,
    color: ClosetColors.noir,
  );

  static TextStyle saisie = GoogleFonts.ebGaramond(
    fontSize: 19,
    color: ClosetColors.noir,
  );

  static TextStyle saisieHint = GoogleFonts.ebGaramond(
    fontSize: 19,
    color: ClosetColors.texteSecondaire.withValues(alpha: 0.7),
  );

  static TextStyle labelChamp = GoogleFonts.lato(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: ClosetColors.dore,
  );

  static TextStyle labelEtape = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.8,
    color: ClosetColors.noir,
  );

  static TextStyle badgePill = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 2.4,
    color: ClosetColors.noir,
  );

  static TextStyle bouton = GoogleFonts.lato(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.4,
  );

  static TextStyle navigation = GoogleFonts.lato(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );

  static TextStyle numeroEtape = GoogleFonts.cormorantGaramond(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );
}
