import 'package:flutter/material.dart';

import '../../data/models/etat_piece.dart';
import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import 'closet_sections.dart';

/// État de la pièce, sous le titre de la fiche produit : le libellé complet
/// (« Très bon état »…) seul, sans jauge — la puce l'affiche déjà ailleurs
/// sur la fiche, la jauge à crans était redondante.
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
            color: context.closetVert,
          ),
        ),
        if (imperfections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.p16),
          ClosetSurtitre(l10n.signesUsage),
          const SizedBox(height: AppSpacing.p8),
          for (final note in imperfections)
            _PuceUsage(texte: note),
        ],
      ],
    );
  }
}

class _PuceUsage extends StatelessWidget {
  const _PuceUsage({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p4),
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
