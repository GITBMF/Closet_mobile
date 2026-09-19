import 'package:flutter/material.dart';

import '../../data/models/etat_piece.dart';
import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import 'closet_sections.dart';

/// Jauge à 5 crans + puces d'usure, sous le titre de la fiche produit.
class JaugeEtatPiece extends StatelessWidget {
  const JaugeEtatPiece({
    super.key,
    required this.niveau,
    this.imperfections = const [],
  });

  final NiveauEtat niveau;
  final List<String> imperfections;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClosetSurtitre(l10n.etatDeLaPiece),
        const SizedBox(height: AppSpacing.p8),
        Text(
          niveau.libelle,
          style: ClosetTextStyles.titreBloc.copyWith(
            color: ClosetColors.vert,
          ),
        ),
        const SizedBox(height: AppSpacing.p16),
        _Cranes(actif: niveau),
        if (imperfections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.p20),
          ClosetSurtitre(l10n.signesUsage),
          const SizedBox(height: AppSpacing.p8),
          for (final note in imperfections)
            _PuceUsage(texte: note),
        ],
      ],
    );
  }
}

class _Cranes extends StatelessWidget {
  const _Cranes({required this.actif});

  final NiveauEtat actif;

  @override
  Widget build(BuildContext context) {
    const niveaux = NiveauEtat.values;
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: Row(
            children: [
              for (var i = 0; i < niveaux.length; i++) ...[
                _Point(atteint: i <= actif.cran, courant: i == actif.cran),
                if (i < niveaux.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < actif.cran
                          ? ClosetColors.vert
                          : ClosetColors.fond300.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        Row(
          children: [
            for (final n in niveaux)
              Expanded(
                child: Text(
                  n.libelleCourt,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.detail.copyWith(
                    color: n == actif
                        ? ClosetColors.vert
                        : ClosetColors.taupe,
                    fontWeight: n == actif ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.atteint, required this.courant});

  final bool atteint;
  final bool courant;

  @override
  Widget build(BuildContext context) {
    final taille = courant ? 14.0 : 10.0;
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: atteint ? ClosetColors.vert : ClosetColors.carteFond,
        border: Border.all(
          color: courant
              ? ClosetColors.doreEncre
              : (atteint ? ClosetColors.vert : ClosetColors.fond300),
          width: courant ? 2 : AppStroke.fin,
        ),
      ),
    );
  }
}

class _PuceUsage extends StatelessWidget {
  const _PuceUsage({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: ClosetColors.doreEncre,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.p12),
          Expanded(
            child: Text(
              texte,
              style: ClosetTextStyles.corps.copyWith(
                color: context.closetEncre,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
