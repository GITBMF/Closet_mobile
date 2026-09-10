import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../transaction/widgets/transaction_scaffold.dart';

/// Inspection et analyse de la pièce — transcription de la maquette `34:1534`.
///
/// Écran de confirmation affiché juste après le dépôt : arche blanche
/// « Pièce bien reçue ! », explication, puis accès au suivi.
class InspectionPieceScreen extends StatelessWidget {
  const InspectionPieceScreen({super.key, this.pieceId});

  /// Pièce concernée. `null` renvoie vers la liste des dépôts.
  final String? pieceId;

  @override
  Widget build(BuildContext context) {
    return TransactionScaffold(
      titre: 'Inspection et analyse de votre pièce',
      child: Column(
        children: [
          const SizedBox(height: 47),
          const _ArcheReception(),
          const SizedBox(height: 42),
          const TexteTransaction(
            'Notre équipe va examiner votre pièce avec le plus grand soin. '
            'Nous vérifions vos informations et nous vous reviendrons très '
            'rapidement avec une réponse.',
          ),
          const Spacer(),
          BoutonTransaction(
            label: 'Suivre l’analyse de ma pièce',
            onPressed: () => context.go(
              pieceId == null
                  ? '/sourceur/pieces'
                  : '/sourceur/piece/$pieceId/suivi',
            ),
          ),
          const SizedBox(height: 24),
          BoutonTransaction(
            label: 'Retour dans Mon Espace',
            dore: false,
            onPressed: () => context.go('/sourceur/espace'),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

/// Arche blanche 217 × 275 cerclée d'or, « Pièce bien reçue ! » en pied.
class _ArcheReception extends StatelessWidget {
  const _ArcheReception();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 275,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p32,
        AppSpacing.p20,
        AppSpacing.p24,
      ),
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: ClosetColors.vert,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: ClosetColors.blanc,
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Text(
            'Pièce bien reçue !',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.sousTitre.copyWith(
              letterSpacing: 0.38,
              color: ClosetColors.vert,
            ),
          ),
        ],
      ),
    );
  }
}
