import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Frise « livraison · Paiement · Confirmation » du tunnel d'achat.
///
/// La maquette l'affiche sur les **trois** écrans du parcours acheteuse : sur
/// le formulaire de livraison (`56:11462`), pendant le traitement
/// (`162:5220`) et sur l'écran de succès (`162:3351`). Elle traverse donc deux
/// fonds différents — beige côté formulaire, vert profond côté tunnel — d'où
/// [surFondSombre].
///
/// Les libellés reprennent la casse de la maquette, qui écrit « livraison »
/// en minuscule et les deux suivants en capitale initiale.
class FriseTunnel extends StatelessWidget {
  const FriseTunnel({
    super.key,
    required this.etapeCourante,
    this.surFondSombre = false,
  });

  /// Étape en cours, de 1 à 3.
  final int etapeCourante;

  final bool surFondSombre;

  static const etapes = ['Livraison', 'Paiement', 'Confirmation'];

  @override
  Widget build(BuildContext context) {
    final couleurAtteinte =
        surFondSombre ? ClosetColors.fond300 : ClosetColors.vert;
    final couleurRestante =
        surFondSombre ? ClosetColors.emeraude400 : ClosetColors.ligne;
    final fondPastilleVide =
        surFondSombre ? ClosetColors.vert : ClosetColors.blanc;

    return Row(
      children: [
        for (var i = 0; i < etapes.length; i++) ...[
          _Pastille(
            numero: i + 1,
            label: etapes[i],
            atteinte: i + 1 <= etapeCourante,
            couleurAtteinte: couleurAtteinte,
            couleurRestante: couleurRestante,
            fondVide: fondPastilleVide,
          ),
          if (i < etapes.length - 1)
            Expanded(
              child: Container(
                height: AppStroke.moyen,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
                color: i + 1 < etapeCourante ? couleurAtteinte : couleurRestante,
              ),
            ),
        ],
      ],
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({
    required this.numero,
    required this.label,
    required this.atteinte,
    required this.couleurAtteinte,
    required this.couleurRestante,
    required this.fondVide,
  });

  final int numero;
  final String label;
  final bool atteinte;
  final Color couleurAtteinte;
  final Color couleurRestante;
  final Color fondVide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: atteinte ? couleurAtteinte : fondVide,
            shape: BoxShape.circle,
            border: Border.all(
              color: atteinte ? couleurAtteinte : couleurRestante,
              width: AppStroke.moyen,
            ),
          ),
          child: Text(
            '$numero',
            style: ClosetTextStyles.corps.copyWith(
              color: atteinte ? fondVide : couleurRestante,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.p4),
        Text(
          label,
          style: ClosetTextStyles.meta.copyWith(
            color: atteinte ? couleurAtteinte : couleurRestante,
          ),
        ),
      ],
    );
  }
}
