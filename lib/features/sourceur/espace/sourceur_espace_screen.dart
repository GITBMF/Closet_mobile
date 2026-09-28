import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/choix_langue.dart';
import '../../../core/widgets/closet_reglages.dart';
import '../../../core/widgets/spotlight_showcase.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// Espace sourceur restreint : coordonnées, bascule cliente, paramètres —
/// mêmes cartes de réglages groupées que l'espace cliente, pour que les deux
/// se lisent comme une seule application.
class SourceurEspaceScreen extends ConsumerWidget {
  const SourceurEspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sourceurRepositoryProvider);
    final profil = repo.profile;
    final l10n = ClosetL10n.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: l10n.monEspace,
              afficherRetour: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.p20),
                children: [
                  if (profil != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p20,
                      ),
                      child: _FicheSourceur(
                        key: ClosetTourKeys.sourceurFicheKey,
                        profile: profil,
                        raisonRefus: repo.adhesion?.raisonRefus,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                  ],
                  ClosetSurtitreReglages(l10n.sourceurGroupeCompte),
                  ClosetCarteReglages(
                    children: [
                      ClosetEntreeReglages(
                        icone: Icons.person_outline,
                        label: l10n.mesInformations,
                        onTap: () => context.go('/espace/infos'),
                      ),
                      ClosetEntreeReglages(
                        icone: Icons.person_add_outlined,
                        label: l10n.ajouterCompteSourceur,
                        onTap: () => context.push('/sourceur/identification'),
                      ),
                      ClosetEntreeReglages(
                        icone: Icons.home_outlined,
                        label: l10n.revenirEspaceClient,
                        onTap: () => context.go('/espace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p20),
                  ClosetSurtitreReglages(l10n.sourceurGroupeAffichage),
                  ClosetCarteReglages(
                    children: [
                      _EntreeTheme(),
                      ClosetEntreeReglages(
                        icone: Icons.language_outlined,
                        label:
                            '${l10n.langue} · ${libelleLangueCourante(locale, l10n)}',
                        onTap: () => afficherChoixLangue(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p20),
                  ClosetSurtitreReglages(l10n.sourceurGroupeConfidentialite),
                  ClosetCarteReglages(
                    children: [
                      ClosetEntreeReglages(
                        icone: Icons.help_outline_rounded,
                        label: l10n.espaceGroupeAide,
                        sousTitre: l10n.espaceGroupeAideDetailGenerale,
                        onTap: () =>
                            context.push('/espace/reglages/aide-sourceur'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p20),
                  ClosetCarteReglages(
                    children: [
                      ClosetEntreeReglages(
                        icone: Icons.logout_rounded,
                        label: l10n.deconnexion,
                        couleurTuile: ClosetColors.erreurCouture,
                        onTap: () => context.go('/espace/deconnexion'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fiche `GET /sourcing/me` : nom, téléphone, statut, collaboration, paiement.
class _FicheSourceur extends StatelessWidget {
  const _FicheSourceur({super.key, required this.profile, this.raisonRefus});

  final SourceurProfile profile;
  final String? raisonRefus;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final sombre = context.closetSombre;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: context.closetCarte,
        border: Border.all(color: context.closetBordure, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
        boxShadow: [
          BoxShadow(
            color: (sombre ? Colors.black : ClosetColors.fond400)
                .withValues(alpha: sombre ? 0.22 : 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.nomAtelier,
                  style: ClosetTextStyles.libelleFort.copyWith(
                    color: context.closetVert,
                  ),
                ),
              ),
              _PastilleStatut(profile: profile, l10n: l10n),
            ],
          ),
          const SizedBox(height: AppSpacing.p12),
          if (profile.whatsapp.isNotEmpty)
            _LigneFiche(
              icone: Icons.phone_outlined,
              libelle: l10n.telephone,
              valeur: profile.whatsapp,
            ),
          _LigneFiche(
            icone: Icons.handshake_outlined,
            libelle: l10n.collaboration,
            valeur: profile.libelleCollaboration(l10n),
          ),
          _LigneFiche(
            icone: Icons.payments_outlined,
            libelle: l10n.paiement,
            valeur: profile.numeroPaiement.isEmpty
                ? profile.libelleMoyenPaiement(l10n)
                : '${profile.libelleMoyenPaiement(l10n)} · ${profile.numeroPaiement}',
          ),
          if (profile.depuis != null)
            _LigneFiche(
              icone: Icons.event_outlined,
              libelle: l10n.membreDepuis,
              valeur: profile.libelleDepuis,
            ),
          if (raisonRefus != null && raisonRefus!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.p8),
            Text(
              raisonRefus!,
              style: ClosetTextStyles.corps.copyWith(
                color: ClosetColors.refusTexte,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PastilleStatut extends StatelessWidget {
  const _PastilleStatut({required this.profile, required this.l10n});

  final SourceurProfile profile;
  final ClosetL10n l10n;

  @override
  Widget build(BuildContext context) {
    final valide = profile.statutApi == 'approved';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: valide
            ? ClosetColors.emeraude100
            : ClosetColors.fondsAlerte,
        borderRadius: BorderRadius.circular(AppRadius.vignette),
      ),
      child: Text(
        profile.libelleStatut(l10n),
        style: ClosetTextStyles.attribut.copyWith(
          color: valide ? ClosetColors.emeraude500 : ClosetColors.alerte,
        ),
      ),
    );
  }
}

class _LigneFiche extends StatelessWidget {
  const _LigneFiche({
    required this.icone,
    required this.libelle,
    required this.valeur,
  });

  final IconData icone;
  final String libelle;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 15, color: context.closetSecondaire),
          const SizedBox(width: AppSpacing.p8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$libelle : ',
                    style: ClosetTextStyles.corps.copyWith(
                      color: context.closetSecondaire,
                    ),
                  ),
                  TextSpan(
                    text: valeur,
                    style: ClosetTextStyles.corps.copyWith(
                      color: context.closetEncre,
                      fontWeight: FontWeight.w600,
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

class _EntreeTheme extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sombre = ref.watch<ThemeMode>(themeModeProvider) == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p12,
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: context.closetSombre
                  ? ClosetColors.emeraude300
                  : ClosetColors.vert,
              borderRadius: BorderRadius.circular(AppRadius.carte),
            ),
            child: Icon(
              sombre ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 18,
              color: ClosetColors.blanc,
            ),
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Text(
              ClosetL10n.of(context).themeSombre,
              style: ClosetTextStyles.libelle.copyWith(
                color: context.closetEncre,
              ),
            ),
          ),
          Switch(
            value: sombre,
            activeThumbColor: context.closetVert,
            onChanged: (_) => ref
                .read<ThemeModeNotifier>(themeModeProvider.notifier)
                .toggleTheme(),
          ),
        ],
      ),
    );
  }
}
