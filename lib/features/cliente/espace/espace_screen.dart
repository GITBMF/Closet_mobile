import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/services/auth_storage_service.dart';

/// Mon espace — transcription de la maquette `24:39`.
///
/// Entête à l'avatar rond de 74, carte verte « Devenir Sourceur », puis liste
/// d'accès dont chaque entrée porte une tuile verte de 48 (rayon 8).
class EspaceScreen extends ConsumerWidget {
  const EspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ClosetUser? user = ref.watch<ClosetUser?>(currentUserProvider);
    final sourceurRepo =
        ref.watch<SourceurRepository>(sourceurRepositoryProvider);
    final nbFavoris = ref.watch(wishlistListProvider).length;

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
                        ? '/sourceur'
                        : '/sourceur/inscription',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              _EntreeEspace(
                icone: Icons.receipt_long_outlined,
                label: 'Mes commandes',
                onTap: () => context.push('/espace/commandes'),
              ),
              _EntreeEspace(
                icone: Icons.favorite_border,
                label: 'Mes favoris',
                compteur: nbFavoris,
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
                onTap: () => _confirmerDeconnexion(context, ref),
              ),
              const SizedBox(height: AppSpacing.p24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                child: ClosetSurtitre('aide & préférences'),
              ),
              const SizedBox(height: AppSpacing.p12),
              _EntreeEspace(
                icone: Icons.credit_card_outlined,
                label: 'Moyens de paiement',
                onTap: () => context.push('/espace/paiements'),
              ),
              _EntreeEspace(
                icone: Icons.help_outline_rounded,
                label: 'Questions fréquentes',
                onTap: () => context.push('/espace/faq'),
              ),
              _EntreeEspace(
                icone: Icons.mail_outline_rounded,
                label: 'Nous contacter',
                onTap: () => context.push('/espace/contact'),
              ),
              _EntreeEspace(
                icone: Icons.shield_outlined,
                label: 'Confidentialité',
                onTap: () => context.push('/espace/confidentialite'),
              ),
              _EntreeEspace(
                icone: Icons.star_border_rounded,
                label: 'Donner mon avis',
                onTap: () => context.push('/espace/evaluation'),
              ),
              const _BasculeTheme(),
            ],
          ),
        ),
      ),
    );
  }

  /// La déconnexion est confirmée puis **remplace** la pile de navigation.
  ///
  /// `go` et non `push` : après déconnexion, aucun écran authentifié ne doit
  /// rester atteignable par le geste de retour.
  Future<void> _confirmerDeconnexion(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ClosetColors.creme,
        title: Text('Se déconnecter', style: ClosetTextStyles.titreSection),
        content: Text(
          'Vous devrez saisir à nouveau vos identifiants pour retrouver '
          'votre dressing.',
          style: ClosetTextStyles.citation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler', style: ClosetTextStyles.bouton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Se déconnecter',
              style: ClosetTextStyles.bouton.copyWith(
                color: ClosetColors.erreurCouture,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirme != true) return;

    // Purge du stockage AVANT l'état mémoire : les jetons d'accès et de
    // rafraîchissement ainsi que le profil sont persistés en clair dans les
    // SharedPreferences. Sans cet appel, « se déconnecter » ne déconnecte
    // rien — la session reste restaurable au prochain lancement.
    await AuthStorageService.clearAuthData();

    ref.read(currentUserProvider.notifier).state = null;
    if (context.mounted) context.go('/auth');
  }
}

/// Bouton rond de réglages, en haut à droite.
class _BoutonReglages extends StatelessWidget {
  const _BoutonReglages({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Réglages',
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
          child: const Icon(Icons.tune, size: 18, color: ClosetColors.vert),
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

  static String _initiales(ClosetUser u) {
    final p = u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : '';
    final n = u.lastName.isNotEmpty ? u.lastName[0].toUpperCase() : '';
    final i = '$p$n';
    return i.isEmpty ? '?' : i;
  }

  @override
  Widget build(BuildContext context) {
    final nom = user == null
        ? 'Invitée'
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
                    ? 'Connectez-vous pour retrouver vos pièces'
                    : 'Membre du dressing',
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
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte verte 352 × 97 invitant à rejoindre le programme sourceur.
class _CarteSourceur extends StatelessWidget {
  const _CarteSourceur({required this.dejaInscrit, required this.onTap});

  final bool dejaInscrit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 97,
      padding: const EdgeInsets.all(AppSpacing.p20),
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
                      horizontal: AppSpacing.p12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ClosetColors.emeraude100,
                      borderRadius:
                          BorderRadius.circular(AppRadius.vignette),
                    ),
                    child: Text(
                      'nouveau',
                      style: ClosetTextStyles.attribut.copyWith(
                        color: ClosetColors.emeraude500,
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
                    letterSpacing: 0,
                    color: ClosetColors.neutre300,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Confiez vos pièces d’exception et rejoignez notre cercle.',
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
                    dejaInscrit ? 'mon atelier' : 'rejoindre le cercle',
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
    );
  }
}

/// Entrée de liste : tuile verte de 48 (rayon 8), libellé, chevron.
class _EntreeEspace extends StatelessWidget {
  const _EntreeEspace({
    required this.icone,
    required this.label,
    required this.onTap,
    this.compteur,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;
  final int? compteur;

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
              child: Icon(icone, size: 18, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.p16),
            Expanded(
              child: Text(
                label,
                style: ClosetTextStyles.libelle,
              ),
            ),
            if (compteur != null && compteur! > 0) ...[
              Text(
                '$compteur',
                style: ClosetTextStyles.meta.copyWith(
                  color: ClosetColors.fond400,
                ),
              ),
              const SizedBox(width: AppSpacing.p8),
            ],
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: ClosetColors.noir,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bascule clair / sombre, conservée de la version précédente.
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
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Text('Thème sombre', style: ClosetTextStyles.libelle),
          ),
          Switch(
            value: sombre,
            activeColor: ClosetColors.vert,
            onChanged: (_) => ref
                .read<ThemeModeNotifier>(themeModeProvider.notifier)
                .toggleTheme(),
          ),
        ],
      ),
    );
  }
}
