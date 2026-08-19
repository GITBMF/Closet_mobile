import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

/// En-tête des écrans sourceur — maquettes `31:109`, `35:1895`, `32:1223`.
///
/// Bouton de retour rond à gauche, sur-titre doré « espace sourceur » puis
/// titre Cormorant, et boutons d'action à droite. Filet doré en pied.
class SourceurHeader extends StatelessWidget {
  const SourceurHeader({
    super.key,
    required this.titre,
    this.surtitre = 'Espace sourceur',
    this.onRetour,
    this.actions = const [],
  });

  final String titre;
  final String surtitre;
  final VoidCallback? onRetour;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ClosetColors.fond400,
            width: AppStroke.fin,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.p20,
          AppSpacing.p8,
          AppSpacing.p20,
          AppSpacing.p12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SourceurBoutonRond(
              icone: Icons.arrow_back_ios_new,
              label: 'Retour',
              onTap: onRetour ?? () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.p8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    surtitre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.actionPetite.copyWith(
                      letterSpacing: -0.20,
                      color: ClosetColors.fond300,
                    ),
                  ),
                  Text(
                    titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.titreSection.copyWith(
                      color: context.closetEncre,
                    ),
                  ),
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// Bouton rond de 42, blanc cerclé d'or — récurrent dans l'espace sourceur.
class SourceurBoutonRond extends StatelessWidget {
  const SourceurBoutonRond({
    super.key,
    required this.icone,
    required this.label,
    required this.onTap,
    this.taille = 42,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            child: Center(
              child: Container(
                width: taille,
                height: taille,
                decoration: BoxDecoration(
                  color: ClosetColors.blanc,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ClosetColors.fond300,
                    width: AppStroke.fin,
                  ),
                ),
                child: Icon(icone, size: taille * 0.4, color: ClosetColors.vert),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Entrée de liste de l'espace sourceur : tuile verte de 48, libellé, chevron.
class SourceurEntree extends StatelessWidget {
  const SourceurEntree({
    super.key,
    required this.icone,
    required this.label,
    required this.onTap,
    this.premier = false,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;

  /// La maquette pose un filet au-dessus de chaque entrée sauf la première.
  final bool premier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!premier)
          const Divider(
            height: AppStroke.fin,
            thickness: AppStroke.fin,
            color: ClosetColors.ligne,
          ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ClosetColors.vert,
                    borderRadius: BorderRadius.circular(AppRadius.carte),
                  ),
                  child: Icon(icone, size: 18, color: ClosetColors.blanc),
                ),
                const SizedBox(width: AppSpacing.p16),
                Expanded(
                  child: Text(label, style: ClosetTextStyles.libelle),
                ),
                const Icon(
                Icons.chevron_right,
                size: 18,
                color: ClosetColors.taupe,
              ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
