import 'package:flutter/material.dart';

import '../../../../core/theme/closet_colors.dart';
import '../../../../core/theme/closet_text_styles.dart';

/// Carte d'introduction vert sapin en forme d'arche avec le badge doré
/// « Cercle des Sourceurs ».
class SourceurHeroCard extends StatelessWidget {
  const SourceurHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 36),
      decoration: const BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(110),
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: ClosetColors.dore,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 14, color: ClosetColors.noir),
                const SizedBox(width: 8),
                Text('CERCLE DES SOURCEURS',
                    style: ClosetTextStyles.badgePill),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Confiez vos pièces d'exception",
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero,
          ),
          const SizedBox(height: 12),
          Text(
            'Le comité Clos ET authentifie, photographie et met en '
            "lumière vos pièces auprès d'une clientèle raffinée.",
            textAlign: TextAlign.center,
            style: ClosetTextStyles.corpsSurVert,
          ),
        ],
      ),
    );
  }
}
