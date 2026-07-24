import 'package:flutter/material.dart';

/// Palette officielle CLOSET (charte graphique) — SOURCE DE VÉRITÉ UNIQUE.
/// Aucune couleur ne doit être déclarée en dehors de cette classe.
class ClosetColors {
  ClosetColors._();

  // ── Couleurs principales ─────────────────────────────────────────────────

  /// Vert profond #1C3D2F — CTA primaires (boutons, surfaces fortes)
  static const Color vert = Color(0xFF1C3D2F);

  /// Vert nuit #12241D — TabBar, écrans immersifs (fond dark)
  static const Color vertFonce = Color(0xFF12241D);

  /// Noir #1D1D1B — Texte principal
  static const Color noir = Color(0xFF1D1D1B);

  /// Beige sable #F3EBDD — Fond de l'application (light)
  static const Color beige = Color(0xFFF3EBDD);

  /// Blanc cassé #FBF7EF — Cartes, champs, feuilles modales
  static const Color creme = Color(0xFFFBF7EF);

  // ── Dorés ───────────────────────────────────────────────────────────────

  /// Doré lumière #BC9746 — Décoratif uniquement (filets, icônes, accents)
  /// ⚠️  JAMAIS en fond de bouton plein ni en grande surface (charte §3.1)
  static const Color dore = Color(0xFFBC9746);

  /// Doré encre #7E611C — Seul doré autorisé en texte sur fond clair
  static const Color doreEncre = Color(0xFF7E611C);

  /// Doré clair #DCBE72 — Doré sur fond vert profond (dark mode)
  static const Color doreClair = Color(0xFFDCBE72);

  // ── Neutres ─────────────────────────────────────────────────────────────

  /// Taupe #6B5F4C — Texte secondaire sur fond clair
  static const Color taupe = Color(0xFF6B5F4C);

  /// Ligne #E2D7C2 — Lignes, bordures, séparateurs
  static const Color ligne = Color(0xFFE2D7C2);

  /// Navigation inactive #7A7870 — Icônes de navigation non-sélectionnées
  static const Color navigationInactif = Color(0xFF7A7870);

  // ── États fonctionnels ──────────────────────────────────────────────────

  /// Succès #2E6B4F (vert plus clair que le brand)
  static const Color succes = Color(0xFF2E6B4F);

  /// Fond succès (vert très doux pour badges)
  static const Color fondsSucces = Color(0xFFD6EBE0);

  /// Alerte / avertissement #8A5A17 (ocre)
  static const Color alerte = Color(0xFF8A5A17);

  /// Fond alerte (ocre très doux)
  static const Color fondsAlerte = Color(0xFFF5E8CB);

  /// Erreur #9B3A2E — Terre brûlée (jamais de rouge criard — charte §3.1)
  static const Color erreur = Color(0xFF9B3A2E);

  /// Fond erreur (terre brûlée très doux)
  static const Color fondsErreur = Color(0xFFF5DDD9);

  // ── Condition badges ─────────────────────────────────────────────────────

  /// Neuf avec étiquette : fond vert doux
  static const Color conditionNeufFond = fondsSucces;

  /// Neuf avec étiquette : texte vert succès
  static const Color conditionNeufTexte = succes;

  /// Excellent : fond doré encre très doux
  static const Color conditionExcellentFond = Color(0xFFEDE3CD);

  /// Excellent : texte doré encre
  static const Color conditionExcellentTexte = doreEncre;

  /// Très bon : fond ocre doux
  static const Color conditionTresBonFond = fondsAlerte;

  /// Très bon : texte ocre
  static const Color conditionTresBonTexte = alerte;

  // ── Aliases de compatibilité (sourceur et anciens composants) ───────────

  /// Alias : ivoire = beige
  static const Color ivoire = beige;

  /// Alias : bordure = ligne
  static const Color bordure = ligne;

  /// Alias : texteSecondaire = taupe
  static const Color texteSecondaire = taupe;

  /// Alias : texteSurVert = creme (texte clair sur fond vert)
  static const Color texteSurVert = creme;

  /// Alias : rougeBadge = erreur (jamais de rouge criard)
  static const Color rougeBadge = erreur;

  /// Sauge #A9B2A3 (couleur neutre dans l'espace sourceur)
  static const Color sauge = Color(0xFFA9B2A3);

  /// Doré désactivé #E4D2A6 (état inactif / placeholder)
  static const Color doreDesactive = Color(0xFFE4D2A6);
}
