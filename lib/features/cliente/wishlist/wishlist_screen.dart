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
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/spotlight_showcase.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

/// Mes favoris — transcription de la maquette `25:924`.
///
/// Cartes vert profond de 352 × 97 : visuel 77 × 78 à gauche, maison, titre
/// Cormorant, prix EB Garamond doré, cœur en haut à droite et bouton
/// « Ajouter au panier » de 116 × 33.
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
                              18,
                              AppSpacing.p16,
                              18,
                              AppSpacing.p32,
                            ),
                            itemCount: liste.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 23),
                            itemBuilder: (context, i) {
                              final article = liste[i];
                              return _CarteFavori(
                                // La visite guidée éclaire la première carte.
                                cleAjout:
                                    i == 0 ? ClosetTourKeys.wishlistAjoutKey : null,
                                article: article,
                                onTap: () =>
                                    context.push('/product/${article.id}'),
                                onRetirer: () =>
                                    basculerFavori(context, ref, article),
                                onAjouter: () =>
                                    basculerSelection(context, ref, article),
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

class _CarteFavori extends ConsumerWidget {
  const _CarteFavori({
    required this.article,
    required this.onTap,
    required this.onRetirer,
    required this.onAjouter,
    this.cleAjout,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback onRetirer;
  final VoidCallback onAjouter;

  /// Clé de la visite guidée, posée sur le bouton d'ajout de la première carte.
  final Key? cleAjout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dejaAjoute =
        ref.watch(cartListProvider).any((a) => a.id == article.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 97,
        padding: const EdgeInsets.all(AppSpacing.p8),
        decoration: BoxDecoration(
          color: ClosetColors.vert,
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 77,
                height: 78,
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
            ),
            const SizedBox(width: AppSpacing.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    article.brand.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.attribut.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: ClosetColors.neutre300,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.citation.copyWith(
                      fontSize: 14,
                      color: ClosetColors.blanc,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          formatPrixFcfa(article.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ClosetTextStyles.prix.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.34,
                            color: ClosetColors.fond200,
                          ),
                        ),
                      ),
                      _BoutonAjouter(
                        key: cleAjout,
                        dejaAjoute: dejaAjoute,
                        indisponible: article.isSoldOut,
                        onTap: onAjouter,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.p8),
            Semantics(
              button: true,
              label: ClosetL10n.of(context).retirerDesFavoris,
              child: GestureDetector(
                onTap: onRetirer,
                child: Container(
                  width: 19,
                  height: 19,
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
                    size: 10,
                    color: ClosetColors.erreurCouture,
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

/// Bouton doré « Ajouter au panier » : 116 × 33, rayon 100.
class _BoutonAjouter extends StatelessWidget {
  const _BoutonAjouter({
    super.key,
    required this.dejaAjoute,
    required this.indisponible,
    required this.onTap,
  });

  final bool dejaAjoute;
  final bool indisponible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actif = !indisponible;
    return SizedBox(
      width: 116,
      height: 33,
      child: Material(
        color: indisponible ? ClosetColors.doreDesactive : ClosetColors.fond300,
        borderRadius: BorderRadius.circular(AppRadius.cercle),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.cercle),
          onTap: actif ? onTap : null,
          child: Center(
            child: Text(
              indisponible
                  ? ClosetL10n.of(context).indisponibleLabel
                  : dejaAjoute
                      ? ClosetL10n.of(context).retirerCourt
                      : ClosetL10n.of(context).ajouterCourt,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ClosetTextStyles.attribut.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                color: ClosetColors.neutre1000,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
