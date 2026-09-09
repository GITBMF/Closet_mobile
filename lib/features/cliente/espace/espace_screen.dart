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
import '../../../core/widgets/closet_header_button.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// Mon espace � transcription de la maquette `24:39`.
///
/// Ent�te � l'avatar rond de 74, carte verte � Devenir Sourceur �, puis liste
/// d'acc�s dont chaque entr�e porte une tuile verte de 48 (rayon 8).
class EspaceScreen extends ConsumerWidget {
  const EspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ClosetUser? user = ref.watch<ClosetUser?>(currentUserProvider);
    final sourceurRepo =
        ref.watch<SourceurRepository>(sourceurRepositoryProvider);
    final partenaire = sourceurRepo.accesAutorisePour(user);
    final l10n = ClosetL10n.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.p32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.p8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p20,
                ),
                child: ClosetTitreEcran(l10n.monEspace),
              ),
              const SizedBox(height: AppSpacing.p24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p20,
                ),
                child: _EnTeteProfil(
                  user: user,
                  onEditer: () => context.push(
                    user == null ? '/auth' : '/espace/infos',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: _CarteSourceur(
                  dejaInscrit: partenaire,
                  onTap: () => context.push(
                    user == null
                        ? '/auth'
                        : partenaire
                            ? '/sourceur/espace'
                            : '/sourceur/devenir',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              _EntreeEspace(
                icone: Icons.receipt_long_outlined,
                label: l10n.mesCommandes,
                onTap: () => user == null
                    ? context.push('/auth')
                    : context.push('/espace/commandes'),
              ),
              _EntreeEspace(
                icone: Icons.person_outline,
                label: l10n.mesInformations,
                onTap: () => context.push(
                  user == null ? '/auth' : '/espace/infos',
                ),
              ),
              const _BasculeTheme(),
              const _ChoixLangue(),
              if (user == null)
                _EntreeEspace(
                  icone: Icons.login_rounded,
                  label: l10n.seConnecterInscrire,
                  onTap: () => context.push('/auth'),
                )
              else
                _EntreeEspace(
                  icone: Icons.logout_rounded,
                  label: l10n.logout,
                  onTap: () => context.push('/espace/deconnexion'),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Bouton rond de r�glages, en haut � droite.
/// Bouton circulaire des en-t�tes de l'espace cliente.
class EspaceBoutonRond extends StatelessWidget {
  const EspaceBoutonRond({
    super.key,
    required this.icone,
    required this.label,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClosetBoutonHeader(
      icone: icone,
      label: label,
      onTap: onTap,
      fond: ClosetColors.blanc,
    );
  }
}

/// Avatar de 74, nom en Cormorant, ancienneté, et pastille d'édition.
class _EnTeteProfil extends StatelessWidget {
  const _EnTeteProfil({required this.user, required this.onEditer});

  final ClosetUser? user;
  final VoidCallback onEditer;

  static String _initiales(ClosetUser u) {
    final p = u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : '';
    final n = u.lastName.isNotEmpty ? u.lastName[0].toUpperCase() : '';
    final i = '$p$n';
    return i.isEmpty ? '?' : i;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final nom = user == null
        ? l10n.invite
        : '${user!.firstName} ${user!.lastName.isEmpty ? '' : '${user!.lastName[0]}.'}'
            .trim();

    return Row(
      children: [
        Container(
          width: 74,
          height: 74,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ClosetColors.emeraude100,
            shape: BoxShape.circle,
          ),
          child: user == null
              ? const Icon(Icons.person, size: 34, color: ClosetColors.taupe)
              : Text(
                  _initiales(user!),
                  style: ClosetTextStyles.titreSection.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ClosetTextStyles.titreSection,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      size: 12,
                      color: ClosetColors.fond300,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.p4),
              Text(
                user == null
                    ? l10n.connectezVousPieces
                    : l10n.membreDressing,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ClosetTextStyles.meta.copyWith(
                  letterSpacing: -0.20,
                  color: ClosetColors.neutre900,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: ClosetL10n.of(context).modifierProfil,
          child: GestureDetector(
            onTap: onEditer,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: ClosetColors.vert,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 15,
                color: ClosetColors.blanc,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte verte 352 � 97 invitant � rejoindre le programme sourceur.
class _CarteSourceur extends StatelessWidget {
  const _CarteSourceur({required this.dejaInscrit, required this.onTap});

  final bool dejaInscrit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Material(
      color: ClosetColors.vert,
      borderRadius: BorderRadius.circular(AppRadius.carte),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.carte),
        child: Container(
      constraints: const BoxConstraints(minHeight: 97),
      padding: const EdgeInsets.all(AppSpacing.p20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!dejaInscrit)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ClosetColors.emeraude100,
                      borderRadius:
                          BorderRadius.circular(AppRadius.vignette),
                    ),
                    child: Text(
                      l10n.nouveau,
                      style: ClosetTextStyles.attribut.copyWith(
                        color: ClosetColors.emeraude500,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.p4),
                Text(
                  dejaInscrit
                      ? l10n.monEspaceSourceur
                      : l10n.devenirSourceur,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.prix.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: ClosetColors.neutre300,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.carteSourceurCorps,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.attribut.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.16,
                    color: ClosetColors.blanc,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.p12),
          SizedBox(
            width: 130,
            height: 44,
            child: Material(
              color: ClosetColors.fond300,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                onTap: onTap,
                child: Center(
                  child: Text(
                    dejaInscrit ? l10n.monEspaceCourt : l10n.rejoindreCercleCourt,
                    textAlign: TextAlign.center,
                    style: ClosetTextStyles.actionPetite.copyWith(
                      color: ClosetColors.neutre1000,
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
    );
  }
}

/// Entrée de liste : tuile verte de 48 (rayon 8), libellé, chevron.
class _EntreeEspace extends StatelessWidget {
  const _EntreeEspace({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p24,
          vertical: AppSpacing.p12,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ClosetColors.vert,
                borderRadius: BorderRadius.circular(AppRadius.carte),
              ),
              child: Icon(icone, size: 18, color: ClosetColors.blanc),
            ),
            const SizedBox(width: AppSpacing.p16),
            Expanded(
              child: Text(
                label,
                style: ClosetTextStyles.libelle,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: ClosetColors.taupe,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Interrupteur clair / sombre — demandé côté cliente, hors maquette Figma.
class _BasculeTheme extends ConsumerWidget {
  const _BasculeTheme();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sombre = ref.watch<ThemeMode>(themeModeProvider) == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p24,
        vertical: AppSpacing.p12,
      ),
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

    return _EntreeEspace(
      icone: Icons.language_outlined,
      label: '${l10n.langue} · $libelle',
      onTap: () => afficherChoixLangue(context, ref),
    );
  }
}
