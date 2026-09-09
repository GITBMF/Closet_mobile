import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Une étape d'une frise verticale.
@immutable
class EtapeFrise {
  const EtapeFrise({
    required this.titre,
    required this.detail,
    this.atteinte = false,
    this.enCours = false,
    this.echec = false,
  });

  final String titre;
  final String detail;

  /// Étape franchie : pastille pleine et trait coloré.
  final bool atteinte;

  /// Étape en train de se produire : pastille cerclée de vert, non cochée.
  ///
  /// Sans cet état, une commande en préparation devait choisir entre se dire
  /// « préparée » (faux) et « pas encore commencée » (faux aussi).
  final bool enCours;

  /// Étape négative (refus, retour) : pastille en terre brûlée.
  final bool echec;
}

/// Frise verticale d'avancement — motif commun aux maquettes `27:1970`
/// (adhésion sourceur), `34:1578` / `34:1710` (suivi de pièce) et `162:5657`
/// (voyage d'une commande).
///
/// Pastille par étape reliée par un trait ; les étapes non atteintes restent
/// en gris. Une étape marquée [EtapeFrise.echec] passe en terre brûlée.
class ClosetFrise extends StatelessWidget {
  const ClosetFrise({
    super.key,
    required this.etapes,
    this.couleurSurFond = false,
  });

  final List<EtapeFrise> etapes;

  /// `true` quand la frise est posée sur un fond vert profond : les textes
  /// passent en crème.
  final bool couleurSurFond;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < etapes.length; i++)
          _Etape(
            etape: etapes[i],
            derniere: i == etapes.length - 1,
            surFond: couleurSurFond,
          ),
      ],
    );
  }
}

class _Etape extends StatelessWidget {
  const _Etape({
    required this.etape,
    required this.derniere,
    required this.surFond,
  });

  final EtapeFrise etape;
  final bool derniere;
  final bool surFond;

  @override
  Widget build(BuildContext context) {
    final Color couleurPastille;
    if (etape.echec) {
      couleurPastille = ClosetColors.erreurCouture;
    } else if (etape.atteinte || etape.enCours) {
      couleurPastille = ClosetColors.vert;
    } else {
      couleurPastille = ClosetColors.ligne;
    }

    final couleurTitre = etape.atteinte || etape.enCours || etape.echec
        ? (surFond ? ClosetColors.blanc : ClosetColors.noir)
        : (surFond ? ClosetColors.beige : ClosetColors.taupe);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: etape.atteinte || etape.echec
                      ? couleurPastille
                      : ClosetColors.blanc,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: couleurPastille,
                    width: AppStroke.moyen,
                  ),
                ),
                child: etape.echec
                    ? const Icon(Icons.close, size: 11, color: ClosetColors.blanc)
                    : etape.atteinte
                        ? const Icon(Icons.check,
                            size: 11, color: ClosetColors.blanc)
                        : null,
              ),
              if (!derniere)
                Expanded(
                  child: Container(
                    width: AppStroke.moyen,
                    // Le trait descendant appartient à l'étape suivante : une
                    // étape en cours ne l'a pas encore franchi.
                    color: etape.atteinte || etape.echec
                        ? couleurPastille
                        : ClosetColors.ligne,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: derniere ? 0 : AppSpacing.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etape.titre,
                    style: ClosetTextStyles.libelle.copyWith(
                      color: couleurTitre,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    etape.detail,
                    style: ClosetTextStyles.meta.copyWith(
                      fontSize: 11,
                      color: surFond
                          ? ClosetColors.beige
                          : ClosetColors.taupe,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
