import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../data/models/article.dart';
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
    final favoris = ref.watch(wishlistListProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: const ClosetAppBar(title: 'Mes favoris'),
      body: favoris.isEmpty
          ? const _WishlistVide()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 33, 18, AppSpacing.p32),
              itemCount: favoris.length,
              separatorBuilder: (_, _) => const SizedBox(height: 23),
              itemBuilder: (context, i) {
                final article = favoris[i];
                return _CarteFavori(
                  article: article,
                  onTap: () => context.push('/product/${article.id}'),
                  onRetirer: () => ref
                      .read(wishlistProvider.notifier)
                      .toggleWishlist(article),
                  onAjouter: () {
                    ref.read(cartProvider.notifier).addArticle(article);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ajoutée à votre sélection.'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _WishlistVide extends StatelessWidget {
  const _WishlistVide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 48,
              color: ClosetColors.fond300,
            ),
            const SizedBox(height: AppSpacing.p20),
            Text(
              'Aucun favori pour l’instant',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              'Touchez le cœur sur une pièce pour la retrouver ici.',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.citation.copyWith(
                color: ClosetColors.taupe,
              ),
            ),
            const SizedBox(height: AppSpacing.p24),
            SizedBox(
              width: 240,
              height: 44,
              child: Material(
                color: ClosetColors.vert,
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  onTap: () => context.go('/collections'),
                  child: Center(
                    child: Text(
                      'Découvrir les collections',
                      style: ClosetTextStyles.bouton.copyWith(
                        color: Colors.white,
                      ),
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

class _CarteFavori extends ConsumerWidget {
  const _CarteFavori({
    required this.article,
    required this.onTap,
    required this.onRetirer,
    required this.onAjouter,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback onRetirer;
  final VoidCallback onAjouter;

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
                    ? const ColoredBox(color: Color(0xFFD9D9D9))
                    : CachedNetworkImage(
                        imageUrl: article.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const ColoredBox(color: Color(0xFFD9D9D9)),
                        errorWidget: (_, _, _) =>
                            const ColoredBox(color: Color(0xFFD9D9D9)),
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
                      color: Colors.white,
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
              label: 'Retirer des favoris',
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
    required this.dejaAjoute,
    required this.indisponible,
    required this.onTap,
  });

  final bool dejaAjoute;
  final bool indisponible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actif = !indisponible && !dejaAjoute;
    return SizedBox(
      width: 116,
      height: 33,
      child: Material(
        color: actif ? ClosetColors.fond300 : ClosetColors.doreDesactive,
        borderRadius: BorderRadius.circular(AppRadius.cercle),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.cercle),
          onTap: actif ? onTap : null,
          child: Center(
            child: Text(
              indisponible
                  ? 'Indisponible'
                  : dejaAjoute
                      ? 'Dans ma sélection'
                      : 'Ajouter au panier',
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
