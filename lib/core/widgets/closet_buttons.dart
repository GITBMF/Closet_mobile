import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Bouton pilule plein. Vert sapin (ou doré) actif, sauge/beige désactivé.
class ClosetPrimaryButton extends StatelessWidget {
  const ClosetPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.dore = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Variante dorée (bouton final « Rejoindre le cercle »).
  final bool dore;

  @override
  Widget build(BuildContext context) {
    final actif = onPressed != null;
    final Color fond;
    final Color texte;
    if (dore) {
      fond = actif ? ClosetColors.dore : ClosetColors.doreDesactive;
      texte = actif ? ClosetColors.noir : ClosetColors.dore;
    } else {
      fond = actif ? ClosetColors.vert : ClosetColors.sauge;
      texte = ClosetColors.texteSurVert;
    }

    return SizedBox(
      height: 64,
      child: Material(
        color: fond,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: ClosetTextStyles.bouton.copyWith(color: texte),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton pilule contour (« Retour »).
class ClosetOutlineButton extends StatelessWidget {
  const ClosetOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: const BorderSide(color: ClosetColors.vert, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                label.toUpperCase(),
                style: ClosetTextStyles.bouton
                    .copyWith(color: ClosetColors.vert),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
