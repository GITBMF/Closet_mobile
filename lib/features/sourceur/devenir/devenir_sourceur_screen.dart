import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../widgets/sourceur_header.dart';
import '../widgets/sourceur_programme_visuel.dart';

/// Devenir Sourceur — transcription de la maquette `26:1771`.
///
/// Photo en bandeau, arche blanche cerclée d'or, puis l'argumentaire
/// et le CTA d'adhésion.
///
/// Note : la maquette pose « Déjà partenaire ? » en `#122B31`, un bleu nuit
/// posé sur le fond vert — donc illisible. Rendu ici en crème.
class DevenirSourceurScreen extends StatelessWidget {
  const DevenirSourceurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        sourceurRetour(context);
      },
      child: Scaffold(
      backgroundColor: ClosetColors.vert,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Image.asset(
              'assets/sourceur_atelier.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.2),
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: ClosetColors.emeraude400),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ClosetColors.vert.withValues(alpha: 0.35),
                      ClosetColors.vert,
                    ],
                    stops: const [0.0, 0.42],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
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
                        onTap: () => sourceurRetour(context),
                      ),
                      Expanded(
                        child: Text(
                          'Devenir Sourceur ClosET',
                          textAlign: TextAlign.center,
                          style: ClosetTextStyles.sousTitre.copyWith(
                            color: ClosetColors.blanc,
                          ),
                        ),
                      ),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const SourceurCadrePhoto(),
                const SizedBox(height: 33),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Programme partenaire',
                          style: ClosetTextStyles.corpsMedium.copyWith(
                            fontSize: 13,
                            letterSpacing: -0.26,
                            color: ClosetColors.fond300,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        Text(
                          'Confiez vos pièces, nous les valorisons',
                          style: ClosetTextStyles.titreEcran.copyWith(
                            letterSpacing: 0.66,
                            color: ClosetColors.blanc,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p12),
                        Text(
                          'Chaque pièce que vous confiez reste tracée '
                          'jusqu’à vous. Vous suivez ses statuts en temps réel '
                          'et vos gains, en toute transparence. Deux formules : '
                          'vente directe ou dépôt-vente.',
                          style: ClosetTextStyles.labelChamp.copyWith(
                            color: ClosetColors.blanc,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p24),
                        const _Argument(
                          titre: 'Curation soignée',
                          detail:
                              'Chaque pièce est premiumisée avant mise en '
                              'ligne.',
                        ),
                        const SizedBox(height: AppSpacing.p20),
                        const _Argument(
                          titre: 'Suivi transparent',
                          detail: 'Six statuts, notifiés à chaque étape',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(39, 0, 39, AppSpacing.p8),
                  child: SizedBox(
                    height: 44,
                    child: Material(
                      color: ClosetColors.fond300,
                      borderRadius: BorderRadius.circular(AppRadius.cercle),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.cercle),
                        onTap: () => context.push('/sourceur/inscription'),
                        child: Center(
                          child: Text(
                            'Remplir ma fiche d’adhésion',
                            style: ClosetTextStyles.bouton.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ClosetColors.vert,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/sourceur/identification'),
                  child: Text.rich(
                    TextSpan(
                      text: 'Déjà partenaire ? ',
                      style: ClosetTextStyles.corps.copyWith(
                        color: ClosetColors.beige,
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
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: ClosetTextStyles.prix.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.26,
              color: ClosetColors.fond300,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            style: ClosetTextStyles.meta.copyWith(
              letterSpacing: -0.20,
              color: ClosetColors.beige,
            ),
          ),
        ],
      ),
    );
  }
}
