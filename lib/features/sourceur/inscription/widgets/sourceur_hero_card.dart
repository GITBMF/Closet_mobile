import 'package:flutter/material.dart';

import '../../../../core/l10n/closet_l10n.dart';
import '../../../../core/theme/closet_colors.dart';
import '../../../../core/theme/closet_text_styles.dart';

/// Carte d'introduction vert sapin en forme d'arche avec le badge doré
/// « Cercle des Sourceurs ».
class SourceurHeroCard extends StatelessWidget {
  const SourceurHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
      decoration: const BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: ClosetColors.dore,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 12, color: ClosetColors.noir),
                const SizedBox(width: 7),
                Text(l10n.cercleDesSourceursBadge,
                    style: ClosetTextStyles.badgePill),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.confiezVosPiecesDexception,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreHero,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.comiteClosEtAuthentifieMessage,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.corpsSurVert,
          ),
        ],
      ),
    );
  }
}
