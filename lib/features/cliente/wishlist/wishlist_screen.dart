import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/closet_pressable.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/spotlight_showcase.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

/// Mes favoris — transcription de la maquette `25:924`.
///
/// Cartes vert profond : grande photo à gauche, maison, titre Cormorant, prix
/// EB Garamond doré et cœur pour retirer le favori. La pièce s'ouvre au tap
/// sur la carte — plus de bouton d'ajout à la sélection ici.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final user = ref.watch(currentUserProvider);
    final connectee = user != null;
    final favoris = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.p12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
              child: ClosetTitreEcran(l10n.mesFavorisTitre),
            ),
            Expanded(
              child: !connectee
                  ? ClosetListeVide(
                      message: l10n.connexionRequiseFavoris,
                      action: () => context.push('/auth'),
                      libelleAction: l10n.seConnecter,
                    )
                  : user.nePeutPasAcheter
                  ? ClosetListeVide(
                      titre: l10n.achatsIndisponiblesTitre,
                      message: l10n.achatsIndisponiblesMessage,
                    )
                  : corpsAsync<List<Article>>(
                      favoris,
                      onRetry: () => ref.invalidate(wishlistProvider),
                      data: (liste) => liste.isEmpty
                          ? ClosetListeVide(
                              message: l10n.aucunFavoriMessage,
                              action: () => context.go('/collections'),
                              libelleAction: l10n.decouvrirCollections,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.p20,
                                AppSpacing.p16,
                                AppSpacing.p20,
                                AppSpacing.p32,
                              ),
                              itemCount: liste.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 23),
                              itemBuilder: (context, i) {
                                final article = liste[i];
                                return _CarteFavori(
                                  // La visite guidée éclaire la première carte.
                                  cleCoeur: i == 0
                                      ? ClosetTourKeys.wishlistAjoutKey
                                      : null,
                                  article: article,
                                  onTap: () =>
                                      context.push('/product/${article.id}'),
                                  onRetirer: () =>
                                      basculerFavori(context, ref, article),
                                );
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

class _CarteFavori extends StatelessWidget {
  const _CarteFavori({
    required this.article,
    required this.onTap,
    required this.onRetirer,
    this.cleCoeur,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback onRetirer;

  /// Clé de la visite guidée, posée sur le cœur de la première carte.
  final Key? cleCoeur;

  @override
  Widget build(BuildContext context) {
    return ClosetPressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 128),
        decoration: BoxDecoration(
          color: ClosetColors.vert,
          borderRadius: BorderRadius.circular(AppRadius.carte),
          boxShadow: [
            BoxShadow(
              color: ClosetColors.vertFonce.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 128,
              child: article.imageUrls.isEmpty
                  ? const ColoredBox(color: ClosetColors.gabaritImage)
                  : CachedNetworkImage(
                      imageUrl: article.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p16,
                  AppSpacing.p12,
                  AppSpacing.p12,
                  AppSpacing.p12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      article.brand.toUpperCase(),
                      style: ClosetTextStyles.attribut.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                        color: ClosetColors.neutre300,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p4),
                    Text(
                      article.title,
                      style: ClosetTextStyles.citation.copyWith(
                        fontSize: 16,
                        color: ClosetColors.blanc,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      formatPrixFcfa(article.price),
                      style: ClosetTextStyles.prix.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.34,
                        color: ClosetColors.fond200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.p8),
              child: Semantics(
                button: true,
                label: ClosetL10n.of(context).retirerDesFavoris,
                child: GestureDetector(
                  key: cleCoeur,
                  onTap: onRetirer,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: ClosetColors.carteFond,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ClosetColors.fond300,
                        width: AppStroke.fin,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 15,
                      color: ClosetColors.erreurCouture,
                    ),
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
