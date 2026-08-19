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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.p32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.p8),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.p20,
                ),
                child: ClosetTitreEcran('Mon espace'),
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
                onTap: () => user == null
                    ? context.push('/auth')
                    : context.push('/espace/commandes'),
              ),
              _EntreeEspace(
                icone: Icons.favorite_border,
                label: 'Mes favoris',
                onTap: () => context.go('/wishlist'),
              ),
              _EntreeEspace(
                icone: Icons.location_on_outlined,
                label: 'Mes adresses',
                onTap: () => user == null
                    ? context.push('/auth')
                    : context.push('/espace/adresses'),
              ),
              _EntreeEspace(
                icone: Icons.person_outline,
                label: 'Mes informations',
                onTap: () => context.push(
                  user == null ? '/auth' : '/espace/infos',
                ),
              ),
              _EntreeEspace(
                icone: Icons.notifications_none_rounded,
                label: 'Mes notifications',
                onTap: () => context.push('/espace/alertes'),
              ),
              const _BasculeTheme(),
              if (user == null)
                _EntreeEspace(
                  icone: Icons.login_rounded,
                  label: 'Se connecter / S’inscrire',
                  onTap: () => context.push('/auth'),
                )
              else
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
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: ClosetColors.blanc,
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

/// Avatar de 74, nom en Cormorant, ancienneté, et pastille d'édition.
class _EnTeteProfil extends StatelessWidget {
  const _EnTeteProfil({required this.user, required this.onEditer});

  final ClosetUser? user;
  final VoidCallback onEditer;

  @override
  Widget build(BuildContext context) {
    final nom = user == null
        ? 'Invité'
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
                      'Nouveau',
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
                  'Confiez vos pièces d’exception et rejoignez notre cercle '
                  'privé des meilleurs stylistes.',
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
                    dejaInscrit ? 'Mon espace' : 'Rejoindre le cercle',
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

/// Entr�e de liste : tuile verte de 48 (rayon 8), libell�, chevron.
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
    return InkWell(
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
            child: Text('Thème sombre', style: ClosetTextStyles.libelle),
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
