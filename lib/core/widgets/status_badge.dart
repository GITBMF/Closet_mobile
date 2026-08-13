import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Badge d'état — transcription des composants Figma `26:1255` (statuts de
/// commande) et `36:2063` (statuts de pièce sourceur).
///
/// Géométrie commune aux deux : hauteur 18, rayon 9.5, padding 12/4,
/// pastille de 6 px, écart 7, texte Lato 400 / 8 pt. Seul le couple de
/// couleurs distingue un statut d'un autre — d'où les constructeurs nommés
/// ci-dessous plutôt que des couleurs passées à la main sur chaque écran.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  // ── Statuts de commande (`26:1255`) ───────────────────────────────────

  /// Commande livrée — vert d'eau
  factory StatusBadge.livree([String text = 'Livrée']) => StatusBadge(
        text: text,
        backgroundColor: ClosetColors.emeraude100,
        textColor: ClosetColors.emeraude500,
      );

  /// Commande en route — encre sur crème
  factory StatusBadge.enRoute([String text = 'En route']) => StatusBadge(
        text: text,
        backgroundColor: ClosetColors.neutre900,
        textColor: ClosetColors.neutre300,
      );

  /// Commande en préparation — sable
  factory StatusBadge.preparation([String text = 'Préparation']) => StatusBadge(
        text: text,
        backgroundColor: ClosetColors.fond200,
        textColor: ClosetColors.neutre800,
      );

  // ── Statuts de pièce sourceur (`36:2063`) ─────────────────────────────

  /// Pièce mise en vente — doré sur encre
  factory StatusBadge.miseEnVente([String text = 'Mis en vente']) =>
      StatusBadge(
        text: text,
        backgroundColor: ClosetColors.neutre1000,
        textColor: ClosetColors.fond400,
      );

  /// Pièce en cours d'analyse
  factory StatusBadge.enAnalyse([String text = 'En cours d’analyse']) =>
      StatusBadge(
        text: text,
        backgroundColor: ClosetColors.neutre400,
        textColor: ClosetColors.neutre900,
      );

  /// Dépôt reçu
  factory StatusBadge.depotRecu([String text = 'Dépôt reçu']) => StatusBadge(
        text: text,
        backgroundColor: ClosetColors.fond200,
        textColor: ClosetColors.fond500,
      );

  /// Pièce refusée — seul statut à sortir des rampes de la palette
  factory StatusBadge.refusee([String text = 'Refusé']) => StatusBadge(
        text: text,
        backgroundColor: ClosetColors.refusFond,
        textColor: ClosetColors.refusTexte,
      );

  /// Pièce retournée
  factory StatusBadge.retournee([String text = 'Retourné']) => StatusBadge(
        text: text,
        backgroundColor: ClosetColors.neutre300,
        textColor: ClosetColors.neutre800,
      );

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: AppSpacing.p4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.vignette),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.gapChip),
          Text(
            text,
            style: ClosetTextStyles.attribut.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
