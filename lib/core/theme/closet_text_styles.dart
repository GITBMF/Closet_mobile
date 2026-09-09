import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'closet_colors.dart';

/// Typographies CLOSET — deux familles seulement :
/// - **EB Garamond** — titres, noms de pièces, montants, citations
/// - **Lato** — interface : navigation, boutons, labels, corps courant
class ClosetTextStyles {
  ClosetTextStyles._();

  /// Facteur d'échelle typographique global.
  ///
  /// À `1.0`, les tailles sont celles de la maquette au point près.
  /// La maquette compte 842 calques entre 6 et 10 pt, ce qui est sous le
  /// minimum lisible usuel (~11 pt). Si le rendu sur appareil confirme le
  /// problème, monter cette valeur à ~1.4 remonte toute l'échelle d'un coup
  /// en préservant la hiérarchie relative.
  static const double scale = 1.0;

  static double _s(double v) => v * scale;

  // ══════════════════════════════════════════════════════════════════════
  // ÉCHELLE SERIF — titres, montants
  // ══════════════════════════════════════════════════════════════════════

  /// Titre d'écran — EB Garamond 600 / 22 pt
  static TextStyle titreEcran = GoogleFonts.ebGaramond(
    fontSize: _s(22),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.44,
    height: 28.7 / 22,
  );

  /// Titre de section — EB Garamond 600 / 22 pt
  static TextStyle titreSection = GoogleFonts.ebGaramond(
    fontSize: _s(22),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.44,
    height: 26.6 / 22,
  );

  /// Titre hero sur fond vert — EB Garamond 600 / 24 pt italique
  static TextStyle titreHero = GoogleFonts.ebGaramond(
    fontSize: _s(24),
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: ClosetColors.texteSurVert,
  );

  /// Sous-titre — EB Garamond 700 / 19 pt
  static TextStyle sousTitre = GoogleFonts.ebGaramond(
    fontSize: _s(19),
    fontWeight: FontWeight.w700,
  );

  /// Accroche produit — EB Garamond 600 / 18 pt
  static TextStyle accroche = GoogleFonts.ebGaramond(
    fontSize: _s(18),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.36,
    height: 21.8 / 18,
  );

  /// Titre de bloc — EB Garamond 600 / 15 pt
  static TextStyle titreBloc = GoogleFonts.ebGaramond(
    fontSize: _s(15),
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 18.2 / 15,
  );

  /// Nom de produit — EB Garamond 700 / 12 pt
  static TextStyle nomProduit = GoogleFonts.ebGaramond(
    fontSize: _s(12),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24,
    height: 14.5 / 12,
  );

  /// Citation / description serif — EB Garamond 500 / 16 pt
  static TextStyle citation = GoogleFonts.ebGaramond(
    fontSize: _s(16),
    fontWeight: FontWeight.w500,
    height: 19.2 / 16,
  );

  // ── Montants ──────────────────────────────────────────────────────────

  /// Montant principal — EB Garamond 600 / 32 pt
  static TextStyle montantHero = GoogleFonts.ebGaramond(
    fontSize: _s(32),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.64,
    height: 41.8 / 32,
  );

  /// Prix mis en avant — EB Garamond 600 / 22 pt
  static TextStyle prixGrand = GoogleFonts.ebGaramond(
    fontSize: _s(22),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.44,
    height: 28.7 / 22,
  );

  /// Prix courant — EB Garamond 500 / 14 pt
  static TextStyle prix = GoogleFonts.ebGaramond(
    fontSize: _s(14),
    fontWeight: FontWeight.w500,
    letterSpacing: -0.28,
    height: 18.3 / 14,
  );

  /// Numéro d'étape — EB Garamond 600 / 15 pt
  static TextStyle numeroEtape = GoogleFonts.ebGaramond(
    fontSize: _s(15),
    fontWeight: FontWeight.w600,
  );

  // ══════════════════════════════════════════════════════════════════════
  // ÉCHELLE SANS (Lato) — interface
  // ══════════════════════════════════════════════════════════════════════

  /// Corps courant — Lato 400 / 12 pt (style le plus fréquent, 352×)
  static TextStyle corps = GoogleFonts.lato(
    fontSize: _s(12),
    letterSpacing: -0.24,
    height: 14.4 / 12,
  );

  /// Corps sur fond vert
  static TextStyle corpsSurVert = GoogleFonts.lato(
    fontSize: _s(12),
    letterSpacing: -0.24,
    height: 14.4 / 12,
    color: ClosetColors.texteSurVert,
  );

  /// Corps accentué — Lato 500 / 12 pt
  static TextStyle corpsMedium = GoogleFonts.lato(
    fontSize: _s(12),
    fontWeight: FontWeight.w500,
    height: 17.4 / 12,
  );

  /// Libellé de liste / entrée de menu — Lato 500 / 14 pt
  static TextStyle libelle = GoogleFonts.lato(
    fontSize: _s(14),
    fontWeight: FontWeight.w500,
    height: 16.8 / 14,
  );

  /// Libellé accentué — Lato 600 / 14 pt
  static TextStyle libelleFort = GoogleFonts.lato(
    fontSize: _s(14),
    fontWeight: FontWeight.w600,
  );

  /// Métadonnée — Lato 400 / 10 pt
  static TextStyle meta = GoogleFonts.lato(
    fontSize: _s(10),
    letterSpacing: 0.2,
    height: 12 / 10,
    color: ClosetColors.texteSecondaire,
  );

  /// Action secondaire — Lato 500 / 10 pt
  static TextStyle actionPetite = GoogleFonts.lato(
    fontSize: _s(10),
    fontWeight: FontWeight.w500,
    height: 14.5 / 10,
  );

  /// Détail produit — Lato 400 / 9 pt
  static TextStyle detail = GoogleFonts.lato(
    fontSize: _s(9),
    letterSpacing: 0.18,
    height: 10.8 / 9,
    color: ClosetColors.texteSecondaire,
  );

  /// Mention légère — Lato 300 / 9 pt
  static TextStyle mention = GoogleFonts.lato(
    fontSize: _s(9),
    fontWeight: FontWeight.w300,
    letterSpacing: 0.16,
    color: ClosetColors.texteSecondaire,
  );

  /// Attribut produit (taille, matière) — Lato 400 / 8 pt
  static TextStyle attribut = GoogleFonts.lato(
    fontSize: _s(8),
    letterSpacing: -0.16,
    height: 9.6 / 8,
    color: ClosetColors.texteSecondaire,
  );

  /// Micro-légende — Lato 400 / 7 pt
  static TextStyle microLegende = GoogleFonts.lato(
    fontSize: _s(7),
    letterSpacing: 0.28,
    height: 8.4 / 7,
    color: ClosetColors.texteSecondaire,
  );

  /// Plus petit texte de la maquette — Lato 400 / 6 pt
  static TextStyle micro = GoogleFonts.lato(
    fontSize: _s(6),
    letterSpacing: 0.24,
    height: 7.2 / 6,
    color: ClosetColors.texteSecondaire,
  );

  // ── Éléments d'interface ──────────────────────────────────────────────

  /// Grand titre décoratif de marque — EB Garamond
  static TextStyle display = GoogleFonts.ebGaramond(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  /// Libellé de bouton — Lato 500 / 12 pt (CTA « Découvrir » de `11:30`).
  /// La maquette n'écrit pas les boutons en capitales.
  static TextStyle bouton = GoogleFonts.lato(
    fontSize: _s(12),
    fontWeight: FontWeight.w500,
    height: 17.4 / 12,
  );

  /// Navigation — Lato 500 / 12 pt (onglet actif ; les inactifs sont sans libellé)
  static TextStyle navigation = GoogleFonts.lato(
    fontSize: _s(12),
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    height: 14.4 / 12,
  );

  /// Saisie de champ — Lato 400 / 14 pt
  static TextStyle saisie = GoogleFonts.lato(
    fontSize: _s(14),
    letterSpacing: 0.14,
  );

  /// Placeholder de champ
  static TextStyle saisieHint = GoogleFonts.lato(
    fontSize: _s(14),
    letterSpacing: 0.14,
    color: ClosetColors.texteSecondaire.withValues(alpha: 0.7),
  );

  /// Label au-dessus d'un champ — Lato 400 / 12 pt
  static TextStyle labelChamp = GoogleFonts.lato(
    fontSize: _s(12),
    letterSpacing: 0.12,
    color: ClosetColors.texteSecondaire,
  );

  /// Label d'étape — Lato 500 / 10 pt
  static TextStyle labelEtape = GoogleFonts.lato(
    fontSize: _s(10),
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
  );

  /// Badge / pastille — Lato 400 / 9 pt, très espacé (cf. « Toutes », 2.07)
  static TextStyle badgePill = GoogleFonts.lato(
    fontSize: _s(9),
    letterSpacing: 2.07,
    height: 10.8 / 9,
  );

  /// Suréclat de section — Lato 400 / 8 pt, très espacé
  static TextStyle surtitre = GoogleFonts.lato(
    fontSize: _s(8),
    letterSpacing: 1.84,
    height: 9.6 / 8,
    color: ClosetColors.texteSecondaire,
  );
}
