import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/theme/police_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/choix_langue.dart';
import '../../../core/widgets/choix_police.dart';
import '../../../core/widgets/closet_filet.dart';
import '../../../core/widgets/closet_header_button.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/spotlight_showcase.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../../checkout/widgets/code_privilege.dart';
import 'espace_sub_screens.dart';

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
                  key: ClosetTourKeys.espaceProfilKey,
                  user: user,
                  onEditer: () => context.push(
                    user == null ? '/auth' : '/espace/infos',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
                child: _CarteSourceur(
                  key: ClosetTourKeys.espaceSourceurKey,
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
              _CarteReglages(
                children: [
                  _EntreeEspace(
                    key: ClosetTourKeys.espaceCommandesKey,
                    icone: Icons.person_outline,
                    label: l10n.espaceGroupeCompte,
                    sousTitre: l10n.espaceGroupeCompteDetail,
                    onTap: () => context.push('/espace/reglages/compte'),
                  ),
                  _EntreeEspace(
                    key: ClosetTourKeys.espaceLangueKey,
                    icone: Icons.palette_outlined,
                    label: l10n.espaceGroupeAffichage,
                    sousTitre:
                        '${libelleLangueCourante(ref.watch(localeProvider), l10n)}'
                        ' · ${libelleTaillePolice(ref.watch(policeProvider), l10n)}',
                    onTap: () => context.push('/espace/reglages/affichage'),
                  ),
                  _EntreeEspace(
                    key: ClosetTourKeys.espaceVisiteKey,
                    icone: Icons.help_outline_rounded,
                    label: l10n.espaceGroupeAide,
                    sousTitre: l10n.espaceGroupeAideDetail,
                    onTap: () => context.push('/espace/reglages/aide'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.p16),
              _CarteReglages(
                children: [
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
  const _EnTeteProfil({
    super.key,
    required this.user,
    required this.onEditer,
  });

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
              ? Icon(Icons.person, size: 34, color: context.closetSecondaire)
              : Text(
                  _initiales(user!),
                  style: ClosetTextStyles.titreSection.copyWith(color: ClosetColors.vert),
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
                      style: ClosetTextStyles.titreSection.copyWith(
                        color: context.closetEncre,
                      ),
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
                  color: context.closetSecondaire,
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
  const _CarteSourceur({
    super.key,
    required this.dejaInscrit,
    required this.onTap,
  });

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
                    color: ClosetColors.texteSurVert,
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
          Material(
            color: ClosetColors.creme,
            borderRadius: BorderRadius.circular(AppRadius.cercle),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p16,
                  vertical: AppSpacing.p12,
                ),
                child: Text(
                  dejaInscrit
                      ? l10n.monEspaceCourt
                      : l10n.rejoindreCercleCourt,
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.actionPetite.copyWith(
                    color: ClosetColors.vert,
                    fontWeight: FontWeight.w600,
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
    super.key,
    required this.icone,
    required this.label,
    required this.onTap,
    this.sousTitre,
  });

  final IconData icone;
  final String label;
  final String? sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
      child: Padding(
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
                color: context.closetSombre ? ClosetColors.emeraude300 : ClosetColors.vert,
                borderRadius: BorderRadius.circular(AppRadius.carte),
              ),
              child: Icon(icone, size: 18, color: ClosetColors.blanc),
            ),
            const SizedBox(width: AppSpacing.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: ClosetTextStyles.libelle.copyWith(
                      color: context.closetEncre,
                    ),
                  ),
                  if (sousTitre != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sousTitre!,
                      style: ClosetTextStyles.meta.copyWith(
                        color: context.closetSecondaire,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.closetSecondaire,
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
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p12,
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: context.closetSombre ? ClosetColors.emeraude300 : ClosetColors.vert,
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

class _ChoixPolice extends ConsumerWidget {
  const _ChoixPolice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final libelle = libelleTaillePolice(ref.watch(policeProvider), l10n);

    return _EntreeEspace(
      icone: Icons.text_fields_rounded,
      label: '${l10n.taillePolice} · $libelle',
      onTap: () => afficherChoixPolice(context),
    );
  }
}

/// Carte arrondie regroupant des entrées, à la manière des réglages d'un
/// téléphone : un fond unique, des filets fins entre les lignes.
class _CarteReglages extends StatelessWidget {
  const _CarteReglages({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sombre = context.closetSombre;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: sombre ? ClosetColors.emeraude500 : ClosetColors.creme,
          border: Border.all(
            color: sombre ? ClosetColors.emeraude400 : ClosetColors.fond200,
            width: AppStroke.fin,
          ),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.only(left: 67),
                  child: ClosetFilet(epaisseur: 0.5),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Page d'un groupe de réglages : `compte`, `affichage` ou `aide`.
class EspaceGroupeScreen extends ConsumerWidget {
  const EspaceGroupeScreen({super.key, required this.groupe});

  final String groupe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final user = ref.watch<ClosetUser?>(currentUserProvider);

    final (String titre, List<Widget> entrees) = switch (groupe) {
      'affichage' => (
          l10n.espaceGroupeAffichage,
          [const _BasculeTheme(), const _ChoixLangue(), const _ChoixPolice()],
        ),
      'aide' => (
          l10n.espaceGroupeAide,
          [
            _EntreeEspace(
              icone: Icons.auto_awesome_outlined,
              label: l10n.visiteGuidee,
              sousTitre: l10n.espaceGroupeAideDetail,
              onTap: () {
                ref.read(spotlightTourProvider.notifier).startTour();
                context.go('/home');
              },
            ),
          ],
        ),
      _ => (
          l10n.espaceGroupeCompte,
          [
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
            _EntreeEspace(
              icone: Icons.local_activity_outlined,
              label: l10n.codePrivilegeLabel,
              onTap: () => afficherCodePrivilege(context),
            ),
          ],
        ),
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: EspaceSubAppBar(title: titre),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p20),
          children: [_CarteReglages(children: entrees)],
        ),
      ),
    );
  }
}
