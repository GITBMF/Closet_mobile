import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import 'closet_filet.dart';
import 'closet_pressable.dart';

/// Carte arrondie regroupant des réglages, à la manière des réglages d'un
/// téléphone : un fond unique, des filets fins entre les lignes. Partagée par
/// l'espace cliente et l'espace sourceur pour que les deux se lisent comme
/// une seule et même application.
class ClosetCarteReglages extends StatelessWidget {
  const ClosetCarteReglages({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sombre = context.closetSombre;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: sombre ? ClosetColors.emeraude500 : ClosetColors.creme,
          border: Border.all(
            color: sombre ? ClosetColors.emeraude400 : ClosetColors.fond200,
            width: AppStroke.fin,
          ),
          borderRadius: BorderRadius.circular(AppRadius.carte),
          boxShadow: [
            BoxShadow(
              color: (sombre ? Colors.black : ClosetColors.fond400)
                  .withValues(alpha: sombre ? 0.22 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.only(left: 67),
                  child: ClosetFilet(epaisseur: 0.5),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Sur-titre discret au-dessus d'une [ClosetCarteReglages] : « MON COMPTE »,
/// « GAINS »… — permet d'empiler plusieurs cartes sans qu'elles se
/// confondent visuellement.
class ClosetSurtitreReglages extends StatelessWidget {
  const ClosetSurtitreReglages(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p24,
        0,
        AppSpacing.p24,
        AppSpacing.p8,
      ),
      child: Text(
        texte.toUpperCase(),
        style: ClosetTextStyles.badgePill.copyWith(
          color: context.closetSombre ? ClosetColors.doreClair : ClosetColors.fond400,
        ),
      ),
    );
  }
}

/// Une ligne de [ClosetCarteReglages] : tuile d'icône, libellé, sous-titre
/// optionnel, chevron. Se presse comme une carte (léger tassement au tap).
class ClosetEntreeReglages extends StatelessWidget {
  const ClosetEntreeReglages({
    super.key,
    required this.icone,
    required this.label,
    required this.onTap,
    this.sousTitre,
    this.couleurTuile,
  });

  final IconData icone;
  final String label;
  final String? sousTitre;
  final VoidCallback onTap;

  /// Couleur de la tuile d'icône. `null` = vert de marque (thème-aware).
  final Color? couleurTuile;

  @override
  Widget build(BuildContext context) {
    return ClosetPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p12,
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: couleurTuile ??
                    (context.closetSombre
                        ? ClosetColors.emeraude300
                        : ClosetColors.vert),
                borderRadius: BorderRadius.circular(AppRadius.carte),
              ),
              child: Icon(icone, size: 18, color: ClosetColors.blanc),
            ),
            const SizedBox(width: AppSpacing.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: ClosetTextStyles.libelle.copyWith(
                      color: context.closetEncre,
                    ),
                  ),
                  if (sousTitre != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre!,
                      style: ClosetTextStyles.meta.copyWith(
                        color: context.closetSecondaire,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.closetSecondaire,
            ),
          ],
        ),
      ),
    );
  }
}
