import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// Étapes du parcours d'adhésion, dans l'ordre de la maquette `27:1970`.
enum EtapeAdhesion { soumise, enEtude, validee, premierePiece }

/// Mon adhésion — transcription de la maquette `27:1970`.
///
/// Carte de statut vert profond, frise verticale (fait / en cours / à venir),
/// encadré de garantie, et CTA « Compléter mon profil en attendant ».
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
    final soumiseLe = dateSoumission ?? DateTime.now();

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Mon adhésion',
              surtitre: 'ESPACE SOURCEUR',
              afficherRetour: false,
              actions: [
                SourceurBoutonRond(
                  icone: Icons.person_outline,
                  label: 'Mon profil',
                  onTap: () => context.push('/espace/infos'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CarteStatut(
                      etape: etapeCourante,
                      dateSoumission: soumiseLe,
                    ),
                    const SizedBox(height: AppSpacing.p32),
                    Text(
                      'PARCOURS DE VOTRE ADHÉSION',
                      style: ClosetTextStyles.surtitre.copyWith(
                        letterSpacing: 1.4,
                        color: ClosetColors.fond400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    _FriseAdhesion(
                      etapeCourante: etapeCourante,
                      dateSoumission: soumiseLe,
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    const _EncadreGarantie(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: ClosetOutlineButton(
                  label: 'Compléter mon profil en attendant',
                  hauteur: 44,
                  onPressed: () {
                    ref.read(sourceurRepositoryProvider).validerAdhesion();
                    context.go('/sourceur/adhesion/approuvee');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de statut : vert profond, badge doré, titre serif italique.
class _CarteStatut extends StatelessWidget {
  const _CarteStatut({required this.etape, required this.dateSoumission});

  final EtapeAdhesion etape;
  final DateTime dateSoumission;

  @override
  Widget build(BuildContext context) {
    final (titre, corps) = switch (etape) {
      EtapeAdhesion.soumise || EtapeAdhesion.enEtude => (
          'Votre fiche est entre nos mains',
          'Notre équipe étudie chaque adhésion avec soin — vous serez '
              'notifiée par WhatsApp dès validation, sous 48 h ouvrées.',
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUT DE VOTRE ADHÉSION',
            style: ClosetTextStyles.surtitre.copyWith(
              letterSpacing: 1.4,
              color: ClosetColors.fond300,
            ),
          ),
          const SizedBox(height: AppSpacing.p12),
          _BadgeStatut(etape: etape),
          const SizedBox(height: AppSpacing.p16),
          Text(
            titre,
            style: ClosetTextStyles.titreEcran.copyWith(
              fontStyle: FontStyle.italic,
              letterSpacing: 0.2,
              height: 1.25,
              color: ClosetColors.beige,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Text(
            'Soumise le ${_jourMois(dateSoumission)}. $corps',
            style: ClosetTextStyles.corps.copyWith(
              height: 1.5,
              color: ClosetColors.neutre300,
            ),
          ),
        ],
      ),
    );
  }

  static String _jourMois(DateTime d) {
    const mois = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];
    return '${d.day} ${mois[d.month - 1]}';
  }
}

class _BadgeStatut extends StatelessWidget {
  const _BadgeStatut({required this.etape});

  final EtapeAdhesion etape;

  @override
  Widget build(BuildContext context) {
    final (libelle, fond, encre) = switch (etape) {
      EtapeAdhesion.soumise => (
          'FICHE SOUMISE',
          ClosetColors.fond300,
          ClosetColors.vert,
        ),
      EtapeAdhesion.enEtude => (
          'EN COURS D’ÉTUDE',
          ClosetColors.fond300,
          ClosetColors.vert,
        ),
      EtapeAdhesion.validee => (
          'ADHÉSION VALIDÉE',
          ClosetColors.emeraude100,
          ClosetColors.vert,
        ),
      EtapeAdhesion.premierePiece => (
          'DÉPÔT OUVERT',
          ClosetColors.fond300,
          ClosetColors.vert,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(AppRadius.cercle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: encre, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            libelle,
            style: ClosetTextStyles.attribut.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: encre,
            ),
          ),
        ],
      ),
    );
  }
}

/// Encadré crème cerclé d'or : le dépôt reste fermé tant que l'étude dure.
class _EncadreGarantie extends StatelessWidget {
  const _EncadreGarantie();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Le dépôt s’ouvrira après validation',
            style: ClosetTextStyles.titreBloc.copyWith(
              fontStyle: FontStyle.italic,
              letterSpacing: -0.2,
              color: ClosetColors.vert,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'C’est notre garantie de qualité : chaque partenaire est validé '
            'avant de confier ses pièces. Merci de votre patience.',
            style: ClosetTextStyles.meta.copyWith(
              height: 1.4,
              letterSpacing: 0.1,
              color: ClosetColors.taupe,
            ),
          ),
        ],
      ),
    );
  }
}

/// Frise verticale : pastille pleine (fait), dorée (en cours), vide (à venir).
class _FriseAdhesion extends StatelessWidget {
  const _FriseAdhesion({
    required this.etapeCourante,
    required this.dateSoumission,
  });

  final EtapeAdhesion etapeCourante;
  final DateTime dateSoumission;

  @override
  Widget build(BuildContext context) {
    final etapes = [
      (
        EtapeAdhesion.soumise,
        'Fiche soumise',
        _horodatage(dateSoumission),
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
            faite: etapes[i].$1.index < etapeCourante.index,
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
    required this.faite,
    required this.courante,
    required this.derniere,
  });

  final String titre;
  final String detail;
  final bool faite;
  final bool courante;
  final bool derniere;

  @override
  Widget build(BuildContext context) {
    final Color pastille;
    final Color filet;
    if (courante) {
      pastille = ClosetColors.fond300;
      filet = ClosetColors.fond300;
    } else if (faite) {
      pastille = ClosetColors.vert;
      filet = ClosetColors.vert;
    } else {
      pastille = ClosetColors.ligne;
      filet = ClosetColors.ligne;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: faite || courante ? pastille : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: pastille,
                    width: courante ? 3 : AppStroke.epais,
                  ),
                ),
              ),
              if (!derniere)
                Expanded(
                  child: Container(width: 1.5, color: filet),
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
                          courante || faite ? FontWeight.w700 : FontWeight.w500,
                      color: faite || courante
                          ? ClosetColors.noir
                          : ClosetColors.taupe,
                    ),
                  ),
                  const SizedBox(height: 3),
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
