import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../widgets/sourceur_header.dart';
import '../widgets/sourceur_programme_visuel.dart';

/// Devenir Sourceur ClosET — passerelle du programme partenaire.
///
/// Fond vert profond, photo dressing en arche avec plaque « CLOS ET
/// SOURCING PROGRAM », argumentaire, puis deux sorties : adhérer ou
/// accéder à l'espace déjà partenaire.
class DevenirSourceurScreen extends StatelessWidget {
  const DevenirSourceurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p20,
                vertical: AppSpacing.p8,
              ),
              child: Row(
                children: [
                  SourceurBoutonRond(
                    icone: Icons.arrow_back_ios_new,
                    label: 'Retour',
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Devenir Sourceur ClosET',
                      textAlign: TextAlign.center,
                      style: ClosetTextStyles.sousTitre.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.p12),
            const SourceurVisuelArche(),
            const SizedBox(height: AppSpacing.p24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRAMME PARTENAIRE',
                      style: ClosetTextStyles.surtitre.copyWith(
                        letterSpacing: 1.6,
                        color: ClosetColors.fond300,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      'Confiez vos pièces, nous les valorisons',
                      style: ClosetTextStyles.titreEcran.copyWith(
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    Text(
                      'Chaque pièce que vous confiez reste tracée jusqu’à vous. '
                      'Vous suivez ses statuts en temps réel et vos gains, en '
                      'toute transparence. Deux formules : vente directe ou '
                      'dépôt-vente.',
                      style: ClosetTextStyles.corps.copyWith(
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    const _Argument(
                      titre: 'Curation soignée',
                      detail:
                          'Chaque pièce est premiumisée avant mise en ligne.',
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    const _Argument(
                      titre: 'Suivi transparent',
                      detail: 'Six statuts, notifiés à chaque étape.',
                    ),
                    const SizedBox(height: AppSpacing.p16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(39, 0, 39, AppSpacing.p8),
              child: SizedBox(
                width: double.infinity,
                child: ClosetPrimaryButton(
                  label: 'Remplir ma fiche d’adhésion',
                  dore: true,
                  hauteur: 44,
                  onPressed: () => context.push('/sourceur/inscription'),
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/sourceur/identification'),
              child: Text.rich(
                TextSpan(
                  text: 'Déjà partenaire ? ',
                  style: ClosetTextStyles.corps.copyWith(
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: 'Accéder à mon espace',
                      style: ClosetTextStyles.corps.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ClosetColors.fond300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.p8),
          ],
        ),
      ),
    );
  }
}

/// Argument du programme : titre doré EB Garamond, détail crème.
class _Argument extends StatelessWidget {
  const _Argument({required this.titre, required this.detail});

  final String titre;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: ClosetTextStyles.prix.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.26,
            color: ClosetColors.fond300,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          detail,
          style: ClosetTextStyles.meta.copyWith(
            letterSpacing: -0.20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
