import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../data/models/article.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import 'piece_card.dart';

/// En-tête principal — transcription de la maquette `11:30`.
///
/// À gauche « Bienvenue, » (EB Garamond) puis le nom de la cliente
/// (Cormorant, doré encre). Au centre le logo. À droite deux boutons ronds
/// de 42, fond clair cerclé d'or : panier et notifications. Un filet doré
/// ferme l'en-tête.
class ClosetAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ClosetAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.actions,
  });

  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final user = ref.watch(currentUserProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ClosetColors.beige,
        border: Border(
          bottom: BorderSide(
            color: ClosetColors.fond400,
            width: AppStroke.fin,
          ),
        ),
      ),
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
          child: Row(
            children: [
              if (showBackButton) ...[
                Semantics(
                  button: true,
                  label: 'Retour',
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const SizedBox(
                      width: AppSpacing.minTouchTarget,
                      height: AppSpacing.minTouchTarget,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: ClosetColors.noir,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.p8),
              ],
              Expanded(child: _Salutation(title: title, subtitle: subtitle, user: user)),
              Image.asset(
                'assets/iconheader.png',
                width: 73,
                height: 29,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Text(
                  'CLOS|ET',
                  style: ClosetTextStyles.titreBloc.copyWith(
                    color: ClosetColors.noir,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions ??
                      [
                        _BoutonRond(
                          icone: Icons.shopping_basket_outlined,
                          label: cartCount > 0
                              ? 'Panier, $cartCount articles'
                              : 'Panier',
                          pastille: cartCount > 0 ? cartCount : null,
                          onTap: () => context.go('/selection'),
                        ),
                        const SizedBox(width: AppSpacing.gapListe),
                        _BoutonRond(
                          icone: Icons.notifications_none_rounded,
                          label: 'Notifications',
                          onTap: () => context.go('/espace/alertes'),
                        ),
                      ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Salutation extends StatelessWidget {
  const _Salutation({
    required this.title,
    required this.subtitle,
    required this.user,
  });

  final String? title;
  final String? subtitle;
  final ClosetUser? user;

  @override
  Widget build(BuildContext context) {
    final nom = subtitle ??
        (user == null
            ? 'Invitée'
            : 'Mme ${user!.firstName} ${user!.lastName.isEmpty ? '' : '${user!.lastName[0]}.'}'
                .trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title ?? 'Bienvenue,',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ClosetTextStyles.prix.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.28,
            color: ClosetColors.noir,
          ),
        ),
        Text(
          nom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ClosetTextStyles.titreBloc.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.28,
            color: ClosetColors.doreEncre,
          ),
        ),
      ],
    );
  }
}

/// Bouton rond de l'en-tête : 42 de diamètre, fond `#F3F3F3`, cerclé d'or.
class _BoutonRond extends StatelessWidget {
  const _BoutonRond({
    required this.icone,
    required this.label,
    required this.onTap,
    this.pastille,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;
  final int? pastille;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ClosetColors.carteFond,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ClosetColors.fond300,
                  width: AppStroke.fin,
                ),
              ),
              child: Icon(icone, size: 20, color: ClosetColors.vert),
            ),
            if (pastille != null)
              Positioned(
                top: -2,
                right: -2,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.p4),
                    decoration: const BoxDecoration(
                      color: ClosetColors.vert,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$pastille',
                      style: ClosetTextStyles.micro.copyWith(
                        color: ClosetColors.creme,
                        fontWeight: FontWeight.w700,
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

/// Carte article branchée sur la wishlist.
///
/// L'habillage est entièrement délégué à [PieceCard] : il n'existe qu'une
/// seule implémentation de carte produit dans l'app. Cette classe n'apporte
/// que la liaison au modèle [Article] et le basculement de la wishlist.
class ArticleCard extends ConsumerStatefulWidget {
  const ArticleCard({super.key, required this.article, this.onTap});

  final Article article;
  final VoidCallback? onTap;

  @override
  ConsumerState<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends ConsumerState<ArticleCard> {
  bool? _localWishlisted;

  @override
  void didUpdateWidget(covariant ArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.id != widget.article.id) {
      _localWishlisted = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistListProvider);
    final isWishlistedReal = wishlist.any((a) => a.id == widget.article.id);

    // Remet l'état optimiste à zéro dès que le provider l'a rattrapé.
    if (_localWishlisted == isWishlistedReal) {
      _localWishlisted = null;
    }
    final isWishlisted = _localWishlisted ?? isWishlistedReal;

    final article = widget.article;

    return PieceCard(
      maison: article.brand,
      nom: article.title,
      prix: formatPrixFcfa(article.price),
      attribut: 'T.${article.size}. ${article.material}',
      imageUrl: article.imageUrls.isEmpty ? null : article.imageUrls.first,
      statusBadgeText: article.condition,
      isFavorite: isWishlisted,
      isSold: article.isSoldOut,
      onTap: widget.onTap,
      onFavoriteTap: () {
        setState(() => _localWishlisted = !isWishlisted);
        ref.read(wishlistProvider.notifier).toggleWishlist(article);
      },
    );
  }
}

/// Format des montants de la maquette : « 38.500 FCFA ».
String formatPrixFcfa(double prix) {
  final entier = prix.round();
  final chiffres = entier.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < chiffres.length; i++) {
    if (i > 0 && (chiffres.length - i) % 3 == 0) buffer.write('.');
    buffer.write(chiffres[i]);
  }
  return '$buffer FCFA';
}
