import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// Portrait par défaut de la maquette « Mon espace ».
const String _avatarDefaut = 'assets/avatar_aicha.png';

/// Mon espace — transcription de la maquette profil cliente.
///
/// Titre, avatar photo, carte « Devenir Sourceur », puis six accès
/// (tuile beige, icône encre, chevron).
class EspaceScreen extends ConsumerWidget {
  const EspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ClosetUser? user = ref.watch<ClosetUser?>(currentUserProvider);
    final sourceurRepo =
        ref.watch<SourceurRepository>(sourceurRepositoryProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
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
                child: Row(
                  children: [
                    const Expanded(child: ClosetTitreEcran('Mon espace')),
                    _BoutonReglages(
                      onTap: () => context.push('/espace/confidentialite'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p20,
                ),
                child: _EnTeteProfil(
                  user: user,
                  onEditer: () => context.push('/espace/infos'),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: _CarteSourceur(
                  dejaInscrit: sourceurRepo.estInscrit,
                  onTap: () => context.push(
                    sourceurRepo.estInscrit
                        ? '/sourceur/espace'
                        : '/sourceur/devenir',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p8),
              _EntreeEspace(
                icone: Icons.inventory_2_outlined,
                label: 'Mes commandes',
                premier: true,
                onTap: () => context.push('/espace/commandes'),
              ),
              _EntreeEspace(
                icone: Icons.favorite_border,
                label: 'Mes favoris',
                onTap: () => context.go('/wishlist'),
              ),
              _EntreeEspace(
                icone: Icons.location_on_outlined,
                label: 'Mes adresses',
                onTap: () => context.push('/espace/adresses'),
              ),
              _EntreeEspace(
                icone: Icons.person_outline,
                label: 'Mes informations',
                onTap: () => context.push('/espace/infos'),
              ),
              _EntreeEspace(
                icone: Icons.notifications_none_rounded,
                label: 'Mes notifications',
                onTap: () => context.push('/espace/alertes'),
              ),
              _EntreeEspace(
                icone: Icons.logout_rounded,
                label: 'Logout',
                onTap: () => context.push('/espace/deconnexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton circulaire des en-têtes de l'espace cliente.
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
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: ClosetColors.fond300,
              width: AppStroke.fin,
            ),
          ),
          child: Icon(icone, size: 18, color: ClosetColors.vert),
        ),
      ),
    );
  }
}

class _BoutonReglages extends StatelessWidget {
  const _BoutonReglages({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EspaceBoutonRond(
      icone: Icons.tune,
      label: 'Réglages',
      onTap: onTap,
    );
  }
}

/// Avatar photo, nom Cormorant, ancienneté, pastille d'édition verte.
class _EnTeteProfil extends StatelessWidget {
  const _EnTeteProfil({required this.user, required this.onEditer});

  final ClosetUser? user;
  final VoidCallback onEditer;

  @override
  Widget build(BuildContext context) {
    final nom = user == null
        ? 'Aïcha N.'
        : '${user!.firstName} ${user!.lastName.isEmpty ? '' : '${user!.lastName[0]}.'}'
            .trim();

    return Row(
      children: [
        ClipOval(
          child: _PortraitEspace(user: user),
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
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified,
                    size: 14,
                    color: ClosetColors.fond300,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.p4),
              Text(
                user == null
                    ? 'Connectez-vous pour retrouver vos pièces'
                    : 'Membre du dressing depuis mars 2026',
                maxLines: 2,
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
          label: 'Modifier mon profil',
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
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PortraitEspace extends StatelessWidget {
  const _PortraitEspace({required this.user});

  final ClosetUser? user;

  @override
  Widget build(BuildContext context) {
    final chemin = user?.avatarPath;
    final fichier = chemin == null ? null : File(chemin);
    if (fichier != null && fichier.existsSync()) {
      return Image.file(
        fichier,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      _avatarDefaut,
      width: 74,
      height: 74,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: 74,
        height: 74,
        color: ClosetColors.emeraude100,
        alignment: Alignment.center,
        child: const Icon(
          Icons.person,
          size: 34,
          color: ClosetColors.taupe,
        ),
      ),
    );
  }
}

/// Carte verte invitant à rejoindre le programme sourceur.
class _CarteSourceur extends StatelessWidget {
  const _CarteSourceur({required this.dejaInscrit, required this.onTap});

  final bool dejaInscrit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 97),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
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
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ClosetColors.emeraude100,
                      borderRadius: BorderRadius.circular(AppRadius.vignette),
                    ),
                    child: Text(
                      'NOUVEAU',
                      style: ClosetTextStyles.attribut.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.p4),
                Text(
                  dejaInscrit
                      ? 'Mon espace Sourceur'
                      : 'Devenir Sourceur Clos ET',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.prix.copyWith(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0,
                    color: ClosetColors.doreClair,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dejaInscrit
                      ? 'Retrouvez vos dépôts, vos revenus et votre atelier.'
                      : 'Confiez vos pièces d’exception et rejoignez notre '
                          'cercle privé de curatrices',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.attribut.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.p8),
          SizedBox(
            width: 118,
            height: 40,
            child: Material(
              color: ClosetColors.fond300,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                onTap: onTap,
                child: Center(
                  child: Text(
                    dejaInscrit ? 'MON ATELIER' : 'REJOINDRE LE CERCLE',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: ClosetTextStyles.micro.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: ClosetColors.vert,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Entrée : tuile beige, icône encre, libellé, chevron. Filet entre les lignes.
class _EntreeEspace extends StatelessWidget {
  const _EntreeEspace({
    required this.icone,
    required this.label,
    required this.onTap,
    this.premier = false,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;
  final bool premier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!premier)
          const Divider(
            height: AppStroke.fin,
            thickness: AppStroke.fin,
            color: ClosetColors.ligne,
            indent: 24,
            endIndent: 24,
          ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p24,
              vertical: AppSpacing.p12,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ClosetColors.neutre200,
                    borderRadius: BorderRadius.circular(AppRadius.carte),
                  ),
                  child: Icon(icone, size: 18, color: ClosetColors.noir),
                ),
                const SizedBox(width: AppSpacing.p16),
                Expanded(
                  child: Text(label, style: ClosetTextStyles.libelle),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: ClosetColors.noir,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
