import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../widgets/sourceur_header.dart';

/// Devenir Sourceur — transcription de la maquette `26:1771`.
///
/// Photo en bandeau, arche blanche cerclée d'or portant la mention du
/// programme, puis l'argumentaire et le CTA d'adhésion.
///
/// Note : la maquette pose « Déjà partenaire ? » en `#122B31`, un bleu nuit
/// posé sur le fond vert — donc illisible. Rendu ici en crème.
class DevenirSourceurScreen extends StatelessWidget {
  const DevenirSourceurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Image.asset(
              'assets/onboarding_1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: ClosetColors.emeraude400),
            ),
          ),
          Positioned.fill(
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
                        onTap: () => context.pop(),
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
                const _ArcheProgramme(),
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
    );
  }
}

/// Arche blanche de 217 × 275 cerclée d'or, mention du programme en pied.
class _ArcheProgramme extends StatelessWidget {
  const _ArcheProgramme();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 275,
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
        image: const DecorationImage(
          image: AssetImage('assets/onboarding_2.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ClosetColors.blanc.withValues(alpha: 0.08),
              ClosetColors.blanc.withValues(alpha: 0.95),
            ],
            stops: const [0.4, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.p20,
            AppSpacing.p32,
            AppSpacing.p20,
            AppSpacing.p24,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                size: 40,
                color: ClosetColors.fond300,
              ),
              const Spacer(),
              Text(
                'Sourcing program',
                style: ClosetTextStyles.corpsMedium.copyWith(
                  letterSpacing: -0.24,
                  color: ClosetColors.vert,
                ),
              ),
            ],
          ),
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
