import 'package:flutter/material.dart';

/// Palette officielle CLOSET — SOURCE DE VÉRITÉ UNIQUE.
/// Aucune couleur ne doit être déclarée en dehors de cette classe.
///
/// Transcription fidèle du Color System Figma (node `1:830`),
/// fichier `VmP4xqjT7R9FVcPT3tQsWg`, version du 2026-08-06.
///
/// La maquette organise la palette en 11 rampes nommées. Les rampes sont
/// exposées telles quelles ci-dessous ; les tokens sémantiques de la section
/// « Rôles » pointent dessus. Utilise de préférence les tokens sémantiques —
/// les rampes servent quand la maquette désigne explicitement un niveau.
class ClosetColors {
  ClosetColors._();

  // ══════════════════════════════════════════════════════════════════════
  // RAMPES FIGMA (valeurs exactes)
  // ══════════════════════════════════════════════════════════════════════

  /// Application Background — fond de l'application
  static const Color fond100 = Color(0xFFF3EBDD);
  static const Color fond200 = Color(0xFFE0CBA7);
  static const Color fond300 = Color(0xFFCDAB71);
  static const Color fond400 = Color(0xFFB58A40);
  static const Color fond500 = Color(0xFF7F612D);

  /// Emerald Green — vert de marque
  static const Color emeraude100 = Color(0xFFA0D0BD);
  static const Color emeraude200 = Color(0xFF71B89C);
  static const Color emeraude300 = Color(0xFF4B9779);
  static const Color emeraude400 = Color(0xFF346753);
  static const Color emeraude500 = Color(0xFF1C382D);

  /// Neutral — crème → encre
  static const Color neutre100 = Color(0xFFFBF7EF);
  static const Color neutre200 = Color(0xFFEFE2C9);
  static const Color neutre300 = Color(0xFFE1CDA6);
  static const Color neutre400 = Color(0xFFD0B685);
  static const Color neutre500 = Color(0xFFBC9F67);
  static const Color neutre600 = Color(0xFFA08550);
  static const Color neutre700 = Color(0xFF7A6844);
  static const Color neutre800 = Color(0xFF564B36);
  static const Color neutre900 = Color(0xFF353025);
  static const Color neutre1000 = Color(0xFF171512);

  /// Night Green — surfaces immersives sombres
  static const Color vertNuit100 = Color(0xFF45896F);
  static const Color vertNuit200 = Color(0xFF12241D);

  /// Doré Lumière — décoratif
  static const Color doreLumiere100 = Color(0xFFC6A24B);
  static const Color doreLumiere200 = Color(0xFF91742E);

  /// Doré Encre — doré lisible en texte
  static const Color doreEncre100 = Color(0xFFD4A73D);
  static const Color doreEncre200 = Color(0xFF7E611C);

  /// Gris Taupe — texte secondaire
  static const Color taupe100 = Color(0xFFA49680);
  static const Color taupe200 = Color(0xFF6B5F4C);

  /// Terre Brûlée — erreur « couture »
  static const Color terreBrulee100 = Color(0xFFD06C60);
  static const Color terreBrulee200 = Color(0xFF9B3A2E);

  /// Red — feedback vif
  static const Color rouge100 = Color(0xFFFB3748);
  static const Color rouge200 = Color(0xFFD00416);

  /// Yellow — feedback vif
  static const Color jaune100 = Color(0xFFFFDB43);
  static const Color jaune200 = Color(0xFFDFB400);

  /// Green — feedback vif
  static const Color vertVif100 = Color(0xFF84EBB4);
  static const Color vertVif200 = Color(0xFF1FC16B);

  // ── Hors rampes, relevés sur les composants ───────────────────────────
  // Présents dans la maquette mais absents de la planche `1:830`.

  /// Fond du badge « refusé » (`36:2063`) — rose poudré
  static const Color refusFond = Color(0xFFFFC0C6);

  /// Texte du badge « refusé » (`36:2063`)
  static const Color refusTexte = Color(0xFFB73642);

  /// Séparateur de liste dans les champs déroulants (`61:12575`)
  static const Color separateur = Color(0xFFE3E3E3);

  /// Fond des cartes produit (`11:30` — Product Card) — gris très clair
  static const Color carteFond = Color(0xFFF3F3F3);

  /// Bordure des cartes produit (`11:30` — Product Card)
  static const Color carteBordure = Color(0xFFE6E6E6);

  // ── Champs de l'écran de connexion (`5:1304`) ─────────────────────────
  // Cet écran habille ses champs en bleuté, distinct du composant
  // `61:12575` (fond blanc, bordure dorée) employé partout ailleurs.

  /// Fond des champs de connexion
  static const Color champFond = Color(0xFFF3F7FB);

  /// Bordure des champs de connexion
  static const Color champBordure = Color(0xFFD4D7E3);

  /// Texte indicatif des champs de connexion
  static const Color champPlaceholder = Color(0xFF8897AD);

  /// Filet de séparation « Ou se connecter »
  static const Color filetSeparateur = Color(0xFFCFDFE2);

  /// Libellé d'une puce de filtre non sélectionnée (`11:30` — Category Tab)
  static const Color chipTexteInactif = Color(0xFF656565);

  // ── Tunnel de transaction (`32:704` → `32:865`) ───────────────────────

  /// Case de code PIN non saisie, et filets internes des cartes
  static const Color caseVide = Color(0xFFF0F0F0);

  /// Chiffre saisi dans une case de code PIN
  static const Color pinTexte = Color(0xFF707070);

  /// Mention « informations chiffrées » en pied des écrans de transaction
  static const Color noteChiffrement = Color(0xFFE7E0E0);

  /// Texte indicatif du champ « code privilège » (`16:3448`)
  static const Color placeholderGris = Color(0xFF7F7F7F);

  // ══════════════════════════════════════════════════════════════════════
  // RÔLES SÉMANTIQUES
  // ══════════════════════════════════════════════════════════════════════

  /// Vert profond — CTA primaires, surfaces fortes.
  /// Figma « Emerald Green 500 ». (était #1C3D2F avant la refonte)
  static const Color vert = emeraude500;

  /// Vert nuit — TabBar, écrans immersifs
  static const Color vertFonce = vertNuit200;

  /// Texte principal. Figma « Neutral 1000 ». (était #1D1D1B)
  static const Color noir = neutre1000;

  /// Fond de l'application (light)
  static const Color beige = fond100;

  /// Cartes, champs, feuilles modales
  static const Color creme = neutre100;

  /// Doré décoratif — filets, icônes, accents.
  /// Figma « Doré Lumière 100 ». (était #BC9746)
  static const Color dore = doreLumiere100;

  /// Seul doré autorisé en texte sur fond clair
  static const Color doreEncre = doreEncre200;

  /// Texte secondaire sur fond clair
  static const Color taupe = taupe200;

  // ── États fonctionnels ────────────────────────────────────────────────
  // La maquette fournit deux jeux : les feedback vifs (Red/Yellow/Green)
  // et les tons « couture » (Terre Brûlée). Les rôles ci-dessous suivent
  // les feedback vifs du Figma ; `erreurCouture` reste disponible pour les
  // grandes surfaces où le rouge vif serait trop agressif.

  static const Color succes = vertVif200;
  static const Color alerte = jaune200;
  static const Color erreur = rouge100;

  /// Erreur en ton couture — Figma « Terre Brûlée 200 »
  static const Color erreurCouture = terreBrulee200;

  // ══════════════════════════════════════════════════════════════════════
  // HORS PALETTE FIGMA — conservés de la version précédente
  // ══════════════════════════════════════════════════════════════════════
  // Ces teintes n'ont pas d'équivalent dans le Color System. Elles sont
  // gardées telles quelles pour ne rien casser, et seront remplacées au fur
  // et à mesure que les écrans seront repris sur maquette.

  /// Lignes, bordures, séparateurs
  static const Color ligne = Color(0xFFE2D7C2);

  /// Icônes de navigation non sélectionnées
  static const Color navigationInactif = Color(0xFF7A7870);

  /// Doré sur fond vert profond (dark mode)
  static const Color doreClair = Color(0xFFDCBE72);

  /// Couleur neutre de l'espace sourceur
  static const Color sauge = Color(0xFFA9B2A3);

  /// État inactif / placeholder doré
  static const Color doreDesactive = Color(0xFFE4D2A6);

  static const Color fondsSucces = Color(0xFFD6EBE0);
  static const Color fondsAlerte = Color(0xFFF5E8CB);
  static const Color fondsErreur = Color(0xFFF5DDD9);

  // ── Badges de condition ───────────────────────────────────────────────

  static const Color conditionNeufFond = fondsSucces;
  static const Color conditionNeufTexte = succes;
  static const Color conditionExcellentFond = Color(0xFFEDE3CD);
  static const Color conditionExcellentTexte = doreEncre;
  static const Color conditionTresBonFond = fondsAlerte;
  static const Color conditionTresBonTexte = alerte;

  // ── Aliases de compatibilité ──────────────────────────────────────────

  static const Color ivoire = beige;
  static const Color bordure = ligne;
  static const Color texteSecondaire = taupe;
  static const Color texteSurVert = creme;
  static const Color rougeBadge = erreur;
}
