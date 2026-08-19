import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../transaction/widgets/transaction_scaffold.dart';

/// Adhésion approuvée — transcription de la maquette `29:46`.
///
/// Arche blanche portant « Vérification approuvée ! », félicitations en EB
/// Garamond, mention WhatsApp, puis deux sorties.
class AdhesionApprouveeScreen extends StatelessWidget {
  const AdhesionApprouveeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // L'adhésion est actée côté serveur : revenir en arrière renverrait sur
      // un écran de suivi devenu faux.
      canPop: false,
      child: TransactionScaffold(
        hautTitre: 47,
        mention: 'Confirmation envoyée sur WhatsApp',
        child: Column(
          children: [
            const SizedBox(height: 124),
            const _ArcheValidation(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: Text(
                'Felicitation votre adhesion a été approuvée avec succès !',
                textAlign: TextAlign.center,
                style: ClosetTextStyles.titreEcran.copyWith(
                  letterSpacing: 0.66,
                  color: ClosetColors.beige,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: Text(
                'Votre pièce sera préparée avec soin et expédiée très\n'
                'prochainement',
                textAlign: TextAlign.center,
                style: ClosetTextStyles.labelChamp.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ClosetColors.blanc,
                ),
              ),
            ),
            const Spacer(),
            BoutonTransaction(
              label: 'Entrer dans mon espace sourceur',
              onPressed: () => context.go('/sourceur/espace'),
            ),
            const SizedBox(height: 24),
            BoutonTransaction(
              label: 'Poursuivre ma visite',
              dore: false,
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

/// Arche blanche 217 × 275 cerclée d'or, coche verte et mention de validation.
class _ArcheValidation extends StatelessWidget {
  const _ArcheValidation();

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
              Icons.verified_outlined,
              size: 44,
              color: ClosetColors.blanc,
            ),
          ),
          const Spacer(),
          Text(
            'Vérification approuvée !',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreBloc.copyWith(
              fontFamily: ClosetTextStyles.prix.fontFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.30,
              color: ClosetColors.vert,
            ),
          ),
        ],
      ),
    );
  }
}
