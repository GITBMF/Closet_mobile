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
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// Espace sourceur restreint : coordonnées, bascule cliente, paramètres.
class SourceurEspaceScreen extends ConsumerWidget {
  const SourceurEspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sourceurRepositoryProvider);
    final profil = repo.profile;
    final l10n = ClosetL10n.of(context);

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
                    if (profil != null) ...[
                      _FicheSourceur(
                        profile: profil,
                        raisonRefus: repo.adhesion?.raisonRefus,
                      ),
                      const SizedBox(height: AppSpacing.p16),
                    ],
                    SourceurEntree(
                      premier: true,
                      icone: Icons.person_outline,
                      label: l10n.mesInformations,
                      onTap: () => context.go('/espace/infos'),
                    ),
                    SourceurEntree(
                      icone: Icons.home_outlined,
                      label: l10n.revenirEspaceClient,
                      onTap: () => context.go('/espace'),
                    ),
                    SourceurEntree(
                      icone: Icons.shield_outlined,
                      label: l10n.policesConfidentialite,
                      onTap: () => context.go('/espace/confidentialite'),
                    ),
                    const _BasculeTheme(),
                    const _ChoixLangue(),
                    SourceurEntree(
                      icone: Icons.person_add_outlined,
                      label: l10n.ajouterCompteSourceur,
                      onTap: () => context.push('/sourceur/identification'),
                    ),
                    SourceurEntree(
                      icone: Icons.logout_rounded,
                      label: l10n.deconnexion,
                      onTap: () => context.go('/espace/deconnexion'),
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

/// Fiche `GET /sourcing/me` : nom, téléphone, statut, collaboration, paiement.
class _FicheSourceur extends StatelessWidget {
  const _FicheSourceur({required this.profile, this.raisonRefus});

  final SourceurProfile profile;
  final String? raisonRefus;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.nomAtelier,
            style: ClosetTextStyles.libelleFort.copyWith(
              color: ClosetColors.vert,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          _LigneFiche(libelle: l10n.statut, valeur: profile.libelleStatut),
          if (profile.whatsapp.isNotEmpty)
            _LigneFiche(libelle: l10n.telephone, valeur: profile.whatsapp),
          _LigneFiche(
            libelle: l10n.collaboration,
            valeur: profile.libelleCollaboration,
          ),
          _LigneFiche(
            libelle: l10n.paiement,
            valeur: profile.numeroPaiement.isEmpty
                ? profile.libelleMoyenPaiement
                : '${profile.libelleMoyenPaiement} · ${profile.numeroPaiement}',
          ),
          if (profile.depuis.isNotEmpty)
            _LigneFiche(libelle: l10n.membreDepuis, valeur: profile.depuis),
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

class _LigneFiche extends StatelessWidget {
  const _LigneFiche({required this.libelle, required this.valeur});

  final String libelle;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$libelle : $valeur',
        style: ClosetTextStyles.corps.copyWith(color: ClosetColors.neutre900),
      ),
    );
  }
}

class _BasculeTheme extends ConsumerWidget {
  const _BasculeTheme();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sombre = ref.watch<ThemeMode>(themeModeProvider) == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ClosetColors.vert,
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
              style: ClosetTextStyles.libelle,
            ),
          ),
          Switch(
            value: sombre,
            activeThumbColor: ClosetColors.vert,
            onChanged: (_) => ref
                .read<ThemeModeNotifier>(themeModeProvider.notifier)
                .toggleTheme(),
          ),
        ],
      ),
    );
  }
}

class _ChoixLangue extends ConsumerWidget {
  const _ChoixLangue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = ClosetL10n.of(context);
    final libelle = libelleLangueCourante(locale, l10n);

    return SourceurEntree(
      icone: Icons.language_outlined,
      label: '${l10n.langue} · $libelle',
      onTap: () => afficherChoixLangue(context, ref),
    );
  }
}
