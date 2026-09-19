import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';

/// Séparateur de 0,5 px — le filet Figma, plus mince que le trait `fin`.
class ClosetFilet extends StatelessWidget {
  const ClosetFilet({
    super.key,
    this.couleur = ClosetColors.ligne,
    this.hauteur = AppStroke.filet,
    this.epaisseur = AppStroke.filet,
  });

  final Color couleur;

  /// Épaisseur du trait dessiné.
  final double epaisseur;

  /// Hauteur du widget. Le trait reste [AppStroke.filet].
  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: couleur,
      thickness: epaisseur,
      height: hauteur,
    );
  }
}

/// Poignée de feuille modale : plus courte et plus fine que le barreau 48 × 4.
class ClosetPoignee extends StatelessWidget {
  const ClosetPoignee({
    super.key,
    this.couleur = ClosetColors.fond300,
  });

  final Color couleur;

  static const double largeur = 32;
  static const double epaisseur = 2;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: largeur,
        height: epaisseur,
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(epaisseur),
        ),
      ),
    );
  }
}
