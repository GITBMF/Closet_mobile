import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/status_badge.dart';
import '../widgets/sourceur_header.dart';

/// Étapes du parcours d'adhésion, dans l'ordre de la maquette `27:1970`.
enum EtapeAdhesion { soumise, enEtude, validee, premierePiece }

/// Mon adhésion — transcription de la maquette `27:1970`.
///
/// Carte de statut vert profond (350 × 171), puis frise verticale du parcours
/// d'adhésion, note de garantie, et bouton de sortie.
///
/// Écran distinct de `SourceurInscriptionScreen` : celui-ci **affiche l'état**
/// d'une adhésion déjà soumise, il ne collecte rien.
class SourceurAdhesionScreen extends ConsumerWidget {
  const SourceurAdhesionScreen({
    super.key,
    this.etapeCourante = EtapeAdhesion.enEtude,
    this.dateSoumission,
  });

  final EtapeAdhesion etapeCourante;
  final DateTime? dateSoumission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Mon adhésion',
              onRetour: () => context.go('/espace'),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => context.push('/espace/alertes'),
                ),
              ],
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
                      'parcours de votre adhesion'.toUpperCase(),
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
                      'Le dépôt s’ouvrira après validation',
                      style: ClosetTextStyles.titreBloc.copyWith(
                        fontFamily: ClosetTextStyles.prix.fontFamily,
                        letterSpacing: -0.30,
                        color: ClosetColors.vert,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      'C’est notre garantie de qualité : chaque partenaire est '
                      'validé avant de confier ses pièces.',
                      style: ClosetTextStyles.meta.copyWith(
                        letterSpacing: 0.10,
                        color: ClosetColors.taupe,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p32),
                    Center(
                      child: SizedBox(
                        width: 312,
                        height: 44,
                        child: Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.cercle),
                            side: const BorderSide(
                              color: ClosetColors.vert,
                              width: AppStroke.fin,
                            ),
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppRadius.cercle),
                            onTap: () => context.push('/espace/infos'),
                            child: Center(
                              child: Text(
                                'Compléter mon profil en attendant',
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

/// Carte de statut : 350 × 171, vert profond, rayon 8.
class _CarteStatut extends StatelessWidget {
  const _CarteStatut({required this.etape, required this.dateSoumission});

  final EtapeAdhesion etape;
  final DateTime? dateSoumission;

  @override
  Widget build(BuildContext context) {
    final (titre, corps) = switch (etape) {
      EtapeAdhesion.soumise => (
          'Votre fiche est entre nos mains',
          'Notre équipe étudie chaque adhésion avec soin — vous serez '
              'notifiée dès la validation.',
        ),
      EtapeAdhesion.enEtude => (
          'Votre fiche est entre nos mains',
          'Notre équipe étudie chaque adhésion avec soin — vous serez '
              'notifiée dès la validation.',
        ),
      EtapeAdhesion.validee => (
          'Bienvenue dans le cercle',
          'Votre adhésion est validée : votre espace de dépôt est ouvert.',
        ),
      EtapeAdhesion.premierePiece => (
          'À vous de jouer',
          'Confiez votre première pièce d’exception.',
        ),
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
            'Statut de votre adhésion',
            style: ClosetTextStyles.corpsMedium.copyWith(
              fontSize: 13,
              letterSpacing: -0.26,
              color: ClosetColors.fond300,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          _badge,
          const SizedBox(height: AppSpacing.p12),
          Text(
            titre,
            style: ClosetTextStyles.titreBloc.copyWith(
              fontFamily: ClosetTextStyles.prix.fontFamily,
              letterSpacing: -0.30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Text(
            dateSoumission == null
                ? corps
                : 'Soumise le ${_jourMois(dateSoumission!)}. $corps',
            style: ClosetTextStyles.meta.copyWith(
              letterSpacing: 0.10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  StatusBadge get _badge => switch (etape) {
        EtapeAdhesion.soumise => StatusBadge.depotRecu('Fiche soumise'),
        EtapeAdhesion.enEtude => StatusBadge.enAnalyse('En cours d’étude'),
        EtapeAdhesion.validee => StatusBadge.livree('Adhésion validée'),
        EtapeAdhesion.premierePiece =>
          StatusBadge.miseEnVente('Dépôt ouvert'),
      };

  static String _jourMois(DateTime d) {
    const mois = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];
    return '${d.day} ${mois[d.month - 1]}';
  }
}

/// Frise verticale : pastille par étape, reliée par un trait.
class _FriseAdhesion extends StatelessWidget {
  const _FriseAdhesion({
    required this.etapeCourante,
    required this.dateSoumission,
  });

  final EtapeAdhesion etapeCourante;
  final DateTime? dateSoumission;

  @override
  Widget build(BuildContext context) {
    final etapes = [
      (
        EtapeAdhesion.soumise,
        'Fiche soumise',
        dateSoumission == null
            ? 'Votre dossier nous est parvenu'
            : _horodatage(dateSoumission!),
      ),
      (
        EtapeAdhesion.enEtude,
        'En cours d’étude',
        'L’administratrice vérifie vos informations',
      ),
      (
        EtapeAdhesion.validee,
        'Adhésion validée',
        'Votre espace de dépôt s’ouvrira',
      ),
      (
        EtapeAdhesion.premierePiece,
        'Première pièce confiée',
        'Vous pourrez déposer votre première pièce',
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

  static String _horodatage(DateTime d) {
    const mois = [
      'Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${mois[d.month - 1]}, $hh:$mm';
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
    final couleur = atteinte ? ClosetColors.vert : ClosetColors.ligne;

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
                  color: atteinte ? ClosetColors.vert : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: couleur, width: AppStroke.moyen),
                ),
                child: atteinte
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
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
                      color: atteinte ? ClosetColors.noir : ClosetColors.taupe,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    detail,
                    style: ClosetTextStyles.meta.copyWith(
                      fontSize: 11,
                      color: ClosetColors.taupe,
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
