import 'package:flutter/material.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

/// Plaque blanche « CLOS ET / SOURCING PROGRAM » posée sur les visuels
/// d'entrée du programme sourceur.
///
/// Le wordmark reprend `iconheader.png` — même lockup que le reste de l'app.
class SourceurBadgeProgramme extends StatelessWidget {
  const SourceurBadgeProgramme({super.key, this.largeur = 220});

  final double largeur;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: largeur),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/iconheader.png',
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(
              'CLOS ET',
              style: ClosetTextStyles.libelleFort.copyWith(
                fontSize: 22,
                letterSpacing: 1.2,
                color: ClosetColors.noir,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'SOURCING PROGRAM',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.libelleFort.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              height: 1.2,
              color: ClosetColors.noir,
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo dressing en arche, coiffée du badge programme.
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
    return SizedBox(
      width: largeur,
      height: hauteur,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(159),
            ),
            child: Image.asset(
              'assets/onboarding_1.jpg',
              width: largeur,
              height: hauteur,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: ClosetColors.emeraude400,
                child: SizedBox(width: largeur, height: hauteur),
              ),
            ),
          ),
          const SourceurBadgeProgramme(),
        ],
      ),
    );
  }
}

/// Photo dressing en carte arrondie, coiffée du badge programme.
class SourceurVisuelCarte extends StatelessWidget {
  const SourceurVisuelCarte({super.key, this.hauteur = 188});

  final double hauteur;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: hauteur,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: SizedBox.expand(
              child: Image.asset(
                'assets/onboarding_1.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: ClosetColors.emeraude400),
              ),
            ),
          ),
          const SourceurBadgeProgramme(),
        ],
      ),
    );
  }
}
