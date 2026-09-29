import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';

/// Encadre son enfant d'une bordure arrondie fine et pleine
/// (anciennement en pointillés, désormais lisse pour l'élégance).
class BordurePointillee extends StatelessWidget {
  const BordurePointillee({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.couleur = ClosetColors.bordure,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: couleur,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
