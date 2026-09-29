import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// Mon adhésion — transcription de la maquette `27:1970`.
///
/// Carte de statut vert profond (350 × 171), puis frise verticale du parcours
/// d'adhésion, note de garantie, et bouton de sortie.
///
/// Écran distinct de `SourceurInscriptionScreen` : celui-ci **affiche l'état**
/// d'une adhésion déjà soumise, il ne collecte rien. Cet état vient du dépôt
/// sourceur : il était auparavant figé sur `enEtude`, ce qui rendait la frise
/// décorative.
class SourceurAdhesionScreen extends ConsumerWidget {
  const SourceurAdhesionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final adhesion =
        ref.watch<SourceurRepository>(sourceurRepositoryProvider).adhesion;

    // Aucune adhésion enregistrée : l'écran n'a rien à afficher, le parcours
    // d'entrée n'a pas été suivi.
    if (adhesion == null) return const _AucuneAdhesion();

    final etapeCourante = adhesion.etape;
    final dateSoumission = adhesion.dateSoumission;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: l10n.adhesionTitre,
              onRetour: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CarteStatut(
                      etape: etapeCourante,
                      dateSoumission: dateSoumission,
                    ),
                    const SizedBox(height: AppSpacing.p32),
                    Text(
                      l10n.adhesionParcoursSurtitre.toUpperCase(),
                      style: ClosetTextStyles.corps.copyWith(
                        letterSpacing: 0.96,
                        color: ClosetColors.fond500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    _FriseAdhesion(
                      etapeCourante: etapeCourante,
                      dateSoumission: dateSoumission,
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    Text(
                      l10n.adhesionDepotOuverture,
                      style: ClosetTextStyles.titreBloc.copyWith(
                        fontFamily: ClosetTextStyles.prix.fontFamily,
                        letterSpacing: -0.30,
                        color: context.closetVert,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      l10n.adhesionGarantie,
                      style: ClosetTextStyles.meta.copyWith(
                        letterSpacing: 0.10,
                        color: context.closetSecondaire,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p32),
                    if (etapeCourante == EtapeAdhesion.validee ||
                        etapeCourante == EtapeAdhesion.premierePiece) ...[
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: Material(
                            color: ClosetColors.fond300,
                            borderRadius:
                                BorderRadius.circular(AppRadius.cercle),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.cercle),
                              onTap: () =>
                                  context.go('/sourceur/adhesion/approuvee'),
                              child: Center(
                                child: Text(
                                  l10n.adhesionVoirValidation,
                                  style: ClosetTextStyles.bouton.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.closetVert,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p16),
                    ],
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ClosetOutlineButton(
                          label: l10n.retourAccueil,
                          onPressed: () => context.go('/home'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aucune adhésion soumise : l'écran est atteignable par lien direct alors que
/// le parcours d'entrée n'a pas été suivi.
class _AucuneAdhesion extends StatelessWidget {
  const _AucuneAdhesion();

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: l10n.adhesionTitre,
              onRetour: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.p32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 48,
                        color: context.closetSecondaire,
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      Text(
                        l10n.adhesionAucuneTitre,
                        style: ClosetTextStyles.titreBloc
                            .copyWith(color: context.closetVert),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.p8),
                      Text(
                        l10n.adhesionAucuneCorps,
                        style: ClosetTextStyles.meta
                            .copyWith(color: context.closetSecondaire),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      ClosetPrimaryButton(
                        label: l10n.devenirSourceur,
                        dore: true,
                        hauteur: AppSpacing.minTouchTarget,
                        onPressed: () => context.go('/sourceur/inscription'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de statut : 350 × 171, vert profond, rayon 8.
class _CarteStatut extends StatelessWidget {
  const _CarteStatut({required this.etape, required this.dateSoumission});

  final EtapeAdhesion etape;
  final DateTime dateSoumission;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final (titre, corps) = switch (etape) {
      EtapeAdhesion.soumise ||
      EtapeAdhesion.enEtude =>
        (l10n.adhesionSoumiseTitre, l10n.adhesionSoumiseCorps),
      EtapeAdhesion.validee =>
        (l10n.adhesionValideeTitre, l10n.adhesionValideeCorps),
      EtapeAdhesion.premierePiece =>
        (l10n.adhesionPremierePieceTitre, l10n.adhesionPremierePieceCorps),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 17, 24, 24),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adhesionStatutLabel,
            style: ClosetTextStyles.corpsMedium.copyWith(
              fontSize: 13,
              letterSpacing: -0.26,
              color: ClosetColors.fond300,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          _badge(l10n),
          const SizedBox(height: AppSpacing.p12),
          Text(
            titre,
            style: ClosetTextStyles.titreBloc.copyWith(
              fontFamily: ClosetTextStyles.prix.fontFamily,
              letterSpacing: -0.30,
              color: ClosetColors.blanc,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Text(
            '${l10n.adhesionSoumiseLePrefix} ${formatDateJourMoisAnnee(dateSoumission)}. $corps',
            style: ClosetTextStyles.meta.copyWith(
              letterSpacing: 0.10,
              color: ClosetColors.blanc,
            ),
          ),
        ],
      ),
    );
  }

  StatusBadge _badge(ClosetL10n l10n) => switch (etape) {
        EtapeAdhesion.soumise => StatusBadge.depotRecu(l10n.adhesionBadgeFicheSoumise),
        EtapeAdhesion.enEtude => StatusBadge.enAnalyse(l10n.adhesionBadgeEnEtude),
        EtapeAdhesion.validee => StatusBadge.livree(l10n.adhesionBadgeValidee),
        EtapeAdhesion.premierePiece =>
          StatusBadge.miseEnVente(l10n.adhesionBadgeDepotOuvert),
      };

}

/// Frise verticale : pastille par étape, reliée par un trait.
class _FriseAdhesion extends StatelessWidget {
  const _FriseAdhesion({
    required this.etapeCourante,
    required this.dateSoumission,
  });

  final EtapeAdhesion etapeCourante;
  final DateTime dateSoumission;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final etapes = [
      (
        EtapeAdhesion.soumise,
        l10n.adhesionBadgeFicheSoumise,
        formatDateCommande(dateSoumission),
      ),
      (
        EtapeAdhesion.enEtude,
        l10n.adhesionBadgeEnEtude,
        l10n.adhesionFriseAdminVerifie,
      ),
      (
        EtapeAdhesion.validee,
        l10n.adhesionBadgeValidee,
        etapeCourante.index >= EtapeAdhesion.validee.index
            ? l10n.adhesionFriseEspaceOuvert
            : l10n.adhesionFriseEspaceOuverture,
      ),
      (
        EtapeAdhesion.premierePiece,
        l10n.adhesionFrisePremierePiece,
        etapeCourante == EtapeAdhesion.premierePiece
            ? l10n.adhesionFrisePieceConfiee
            : l10n.adhesionFriseDeposerPiece,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < etapes.length; i++)
          _EtapeFrise(
            titre: etapes[i].$2,
            detail: etapes[i].$3,
            atteinte: etapes[i].$1.index <= etapeCourante.index,
            courante: etapes[i].$1 == etapeCourante,
            derniere: i == etapes.length - 1,
          ),
      ],
    );
  }

}

class _EtapeFrise extends StatelessWidget {
  const _EtapeFrise({
    required this.titre,
    required this.detail,
    required this.atteinte,
    required this.courante,
    required this.derniere,
  });

  final String titre;
  final String detail;
  final bool atteinte;
  final bool courante;
  final bool derniere;

  @override
  Widget build(BuildContext context) {
    final couleur = atteinte ? context.closetVert : context.closetLigne;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: atteinte ? context.closetVert : context.closetCarte,
                  shape: BoxShape.circle,
                  border: Border.all(color: couleur, width: AppStroke.moyen),
                ),
                child: atteinte
                    ? Icon(
                        Icons.check,
                        size: 11,
                        color: context.closetActionTexte,
                      )
                    : null,
              ),
              if (!derniere)
                Expanded(
                  child: Container(width: AppStroke.moyen, color: couleur),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: derniere ? 0 : AppSpacing.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: ClosetTextStyles.libelle.copyWith(
                      fontWeight:
                          courante ? FontWeight.w700 : FontWeight.w500,
                      color: atteinte
                          ? context.closetEncre
                          : context.closetSecondaire,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    detail,
                    style: ClosetTextStyles.meta.copyWith(
                      fontSize: 11,
                      color: context.closetSecondaire,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
