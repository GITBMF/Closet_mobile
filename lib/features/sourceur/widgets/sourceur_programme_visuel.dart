import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';

const _assetStyliste = 'assets/sourceur_styliste.jpg';

/// Cadre tombstone du programme sourceur : photo plein cadre, bordure or,
/// sans légende superposée.
class SourceurCadrePhoto extends StatelessWidget {
  const SourceurCadrePhoto({
    super.key,
    this.largeur = 217,
    this.hauteur = 275,
    this.asset = _assetStyliste,
  });

  final double largeur;
  final double hauteur;
  final String asset;

  @override
  Widget build(BuildContext context) {
    const rayon = BorderRadius.vertical(top: Radius.circular(159));
    return Container(
      width: largeur,
      height: hauteur,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: rayon,
      ),
      child: Image.asset(
        asset,
        width: largeur,
        height: hauteur,
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.15),
        errorBuilder: (_, _, _) => ColoredBox(
          color: ClosetColors.emeraude400,
          child: SizedBox(width: largeur, height: hauteur),
        ),
      ),
    );
  }
}

/// Photo dressing en arche — même cadre, pour les écrans qui l’importaient.
class SourceurVisuelArche extends StatelessWidget {
  const SourceurVisuelArche({
    super.key,
    this.largeur = 236,
    this.hauteur = 268,
  });

  final double largeur;
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return SourceurCadrePhoto(largeur: largeur, hauteur: hauteur);
  }
}

/// Photo en carte arrondie, sans overlay de texte.
class SourceurVisuelCarte extends StatelessWidget {
  const SourceurVisuelCarte({super.key, this.hauteur = 188});

  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: SizedBox(
        height: hauteur,
        width: double.infinity,
        child: Image.asset(
          _assetStyliste,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.2),
          errorBuilder: (_, _, _) =>
              const ColoredBox(color: ClosetColors.emeraude400),
        ),
      ),
    );
  }
}
