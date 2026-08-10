// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'closet_colors.dart';

// /// Typographies CLOSET (charte graphique avril 2026) :
// /// - Boldonse pour les très grands titres décoratifs (marque)
// /// - Garamond (EB Garamond) pour les grands titres / sous-titres
// /// - Cormorant pour les textes courants, descriptions et champs de saisie
// /// - Lato pour l'interface (UI/UX), navigation, boutons, labels
// class ClosetTextStyles {
//   ClosetTextStyles._();

//   static const TextStyle display = TextStyle(
//     fontFamily: 'Boldonse',
//     fontSize: 22,
//     color: ClosetColors.noir,
//   );

//   static TextStyle titreEcran = GoogleFonts.ebGaramond(
//     fontSize: 22,
//     fontWeight: FontWeight.w600,
//     color: ClosetColors.vertFonce,
//   );

//   static TextStyle titreHero = GoogleFonts.ebGaramond(
//     fontSize: 24,
//     fontWeight: FontWeight.w600,
//     fontStyle: FontStyle.italic,
//     color: ClosetColors.texteSurVert,
//   );

//   static TextStyle corpsSurVert = GoogleFonts.cormorant(
//     fontSize: 15,
//     height: 1.45,
//     color: ClosetColors.texteSurVert,
//   );

//   static TextStyle corps = GoogleFonts.cormorant(
//     fontSize: 15,
//     height: 1.45,
//     color: ClosetColors.noir,
//   );

//   static TextStyle saisie = GoogleFonts.cormorant(
//     fontSize: 16,
//     color: ClosetColors.noir,
//   );

//   static TextStyle saisieHint = GoogleFonts.cormorant(
//     fontSize: 16,
//     color: ClosetColors.texteSecondaire.withValues(alpha: 0.7),
//   );

//   static TextStyle labelChamp = GoogleFonts.lato(
//     fontSize: 11,
//     fontWeight: FontWeight.w700,
//     letterSpacing: 1.6,
//     color: ClosetColors.dore,
//   );

//   static TextStyle labelEtape = GoogleFonts.lato(
//     fontSize: 10.5,
//     fontWeight: FontWeight.w700,
//     letterSpacing: 1.4,
//     color: ClosetColors.noir,
//   );

//   static TextStyle badgePill = GoogleFonts.lato(
//     fontSize: 10,
//     fontWeight: FontWeight.w800,
//     letterSpacing: 1.8,
//     color: ClosetColors.noir,
//   );

//   static TextStyle bouton = GoogleFonts.lato(
//     fontSize: 13,
//     fontWeight: FontWeight.w700,
//     letterSpacing: 1.6,
//   );

//   static TextStyle navigation = GoogleFonts.lato(
//     fontSize: 10,
//     fontWeight: FontWeight.w700,
//     letterSpacing: 1.2,
//   );

//   static TextStyle numeroEtape = GoogleFonts.ebGaramond(
//     fontSize: 15,
//     fontWeight: FontWeight.w600,
//   );
// }


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

  // ── Display / Hero ─────────────────────────────────────────────────────

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

  // ── Body / Corps ──────────────────────────────────────────────────────

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

  /// Corps de texte standard (alias pour corps)
  static TextStyle get body => corps;

  /// Corps de texte secondaire (plus petit)
  static TextStyle get bodySmall => GoogleFonts.cormorant(
        fontSize: 13,
        height: 1.4,
        color: ClosetColors.taupe,
      );

  // ── Form Inputs ───────────────────────────────────────────────────────

  static TextStyle saisie = GoogleFonts.cormorant(
    fontSize: 16,
    color: ClosetColors.noir,
  );

  static TextStyle saisieHint = GoogleFonts.cormorant(
    fontSize: 16,
    color: ClosetColors.texteSecondaire.withValues(alpha: 0.7),
  );

  // ── Labels ────────────────────────────────────────────────────────────

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

  /// Libellé (pour les badges, tags, petites étiquettes)
  /// ✅ AJOUTÉ - manquant dans l'original
  static TextStyle get libelle => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: ClosetColors.taupe,
        letterSpacing: 0.5,
      );

  /// Petit label
  static TextStyle get labelSmall => GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: ClosetColors.taupe,
        letterSpacing: 0.5,
      );

  // ── Product Text ──────────────────────────────────────────────────────

  /// Nom du produit
  /// ✅ AJOUTÉ - manquant dans l'original
  static TextStyle get nomProduit => GoogleFonts.cormorant(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: ClosetColors.noir,
      );

  /// Prix du produit
  static TextStyle get prix => GoogleFonts.cormorant(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: ClosetColors.vert,
      );

  /// Prix petit
  static TextStyle get prixSmall => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: ClosetColors.vert,
      );

  /// Prix grand
  static TextStyle get prixLarge => GoogleFonts.ebGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: ClosetColors.vert,
      );

  // ── Badges / Pills ────────────────────────────────────────────────────

  static TextStyle badgePill = GoogleFonts.lato(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.8,
    color: ClosetColors.noir,
  );

  // ── Buttons ───────────────────────────────────────────────────────────

  static TextStyle bouton = GoogleFonts.lato(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
  );

  static TextStyle get button => bouton;

  static TextStyle get buttonSmall => GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      );

  // ── Navigation ────────────────────────────────────────────────────────

  static TextStyle navigation = GoogleFonts.lato(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  // ── Meta / Helper Text ───────────────────────────────────────────────

  /// Texte méta (informations secondaires)
  static TextStyle get meta => GoogleFonts.lato(
        fontSize: 11,
        height: 1.4,
        color: ClosetColors.taupe,
        letterSpacing: 0.3,
      );

  /// Caption
  static TextStyle get caption => GoogleFonts.lato(
        fontSize: 10,
        height: 1.3,
        color: ClosetColors.taupe,
      );

  /// Placeholder
  static TextStyle get placeholder => GoogleFonts.cormorant(
        fontSize: 16,
        height: 1.5,
        color: ClosetColors.taupe,
      );

  // ── Titles ────────────────────────────────────────────────────────────

  static TextStyle get title => GoogleFonts.ebGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: ClosetColors.noir,
      );

  static TextStyle get subtitle => GoogleFonts.ebGaramond(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: ClosetColors.noir,
      );

  static TextStyle get sectionTitle => GoogleFonts.ebGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: ClosetColors.noir,
      );

  // ── Headings ──────────────────────────────────────────────────────────

  static TextStyle get h1 => GoogleFonts.ebGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: ClosetColors.noir,
      );

  static TextStyle get h2 => GoogleFonts.ebGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: ClosetColors.noir,
      );

  static TextStyle get h3 => GoogleFonts.ebGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: ClosetColors.noir,
      );

  // ── Special ───────────────────────────────────────────────────────────

  static TextStyle numeroEtape = GoogleFonts.ebGaramond(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Texte d'erreur
  static TextStyle get error => GoogleFonts.lato(
        fontSize: 13,
        height: 1.4,
        color: ClosetColors.erreur,
      );

  /// Texte de succès
  static TextStyle get success => GoogleFonts.lato(
        fontSize: 13,
        height: 1.4,
        color: ClosetColors.succes,
      );
}