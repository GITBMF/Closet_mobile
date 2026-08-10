import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Sur-titre doré en petites capitales très espacées.
///
/// Motif récurrent de la maquette : « explorer par univers », « tout
/// découvrir », « pièce de la semaine », « solde du compte »…
/// Lato 400 / 9, `ls 2.07`, doré `#B58A40`.
class ClosetSurtitre extends StatelessWidget {
  const ClosetSurtitre(this.texte, {super.key, this.couleur});

  final String texte;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte.toUpperCase(),
      style: ClosetTextStyles.badgePill.copyWith(
        color: couleur ?? ClosetColors.fond400,
      ),
    );
  }
}

/// Titre de section Cormorant à gauche, lien doré fléché à droite.
///
/// Reprend le couple « Nouveauté du dressing » / « tout découvrir » de
/// `11:30`, réutilisé sur les collections, l'espace et le sourceur.
class ClosetEnTeteSection extends StatelessWidget {
  const ClosetEnTeteSection({
    super.key,
    required this.titre,
    this.lien,
    this.onLien,
  });

  final String titre;

  /// Libellé du lien. Absent = pas de lien affiché.
  final String? lien;
  final VoidCallback? onLien;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            titre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.titreBloc,
          ),
        ),
        if (lien != null) ...[
          const SizedBox(width: 8),
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: onLien,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClosetSurtitre(lien!),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward,
                    size: 11,
                    color: ClosetColors.fond400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Signature de pied de page — « clos et. abidjan - paris - Yaoundé ».
///
/// Ferme les écrans de catalogue longs (`11:250`, `13:1032`).
class ClosetSignature extends StatelessWidget {
  const ClosetSignature({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'clos et.  abidjan - paris  - Yaoundé',
          textAlign: TextAlign.center,
          style: ClosetTextStyles.meta.copyWith(
            letterSpacing: 2,
            color: ClosetColors.taupe,
          ),
        ),
      ),
    );
  }
}

/// Titre d'écran Cormorant 600 / 22 (« Toutes les pièces », « Mon espace »).
class ClosetTitreEcran extends StatelessWidget {
  const ClosetTitreEcran(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ClosetTextStyles.titreSection.copyWith(
        color: ClosetColors.noir,
      ),
    );
  }
}
