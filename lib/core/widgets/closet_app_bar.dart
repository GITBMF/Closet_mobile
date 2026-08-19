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
/// (Cormorant, doré encre). À droite deux boutons ronds de 42, fond clair
/// cerclé d'or : sélection et notifications. Un filet doré ferme l'en-tête.
class ClosetAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ClosetAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.actions,
  });

  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  static const double _hauteurBarre = 62;

  /// Hauteur de la barre + inset statut, pour que Scaffold réserve assez
  /// d'espace et que les boutons restent sous la barre système (tappables).
  static double get _insetStatut {
    final vues = WidgetsBinding.instance.platformDispatcher.views;
    if (vues.isEmpty) return 0;
    final vue = vues.first;
    return vue.padding.top / vue.devicePixelRatio;
  }

  @override
  Size get preferredSize => Size.fromHeight(_hauteurBarre + _insetStatut);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final user = ref.watch(currentUserProvider);

    return Material(
      color: context.closetFond,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ClosetColors.fond400,
              width: AppStroke.fin,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: _hauteurBarre,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
              child: Row(
                children: [
                  if (showBackButton) ...[
                    _BoutonRond(
                      icone: Icons.arrow_back_ios_new,
                      label: 'Retour',
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: AppSpacing.p8),
                  ],
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: user == null ? () => context.push('/auth') : null,
                      child: _Salutation(
                        title: title,
                        subtitle: subtitle,
                        user: user,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions ??
                        [
                          _BoutonRond(
                            icone: Icons.shopping_basket_outlined,
                            label: cartCount > 0
                                ? 'Sélection, $cartCount pièces'
                                : 'Ma sélection',
                            pastille: cartCount > 0 ? cartCount : null,
                            onTap: () => context.go('/selection'),
                          ),
                          const SizedBox(width: AppSpacing.gapListe),
                          _BoutonRond(
                            icone: Icons.notifications_none_rounded,
                            label: 'Notifications',
                            onTap: () => context.push('/espace/alertes'),
                          ),
                        ],
                  ),
                ],
              ),
            ),
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
            ? 'Invité'
            : '${user!.firstName} ${user!.lastName.isEmpty ? '' : '${user!.lastName[0]}.'}'
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
            color: context.closetEncre,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppSpacing.minTouchTarget,
            height: AppSpacing.minTouchTarget,
            child: Center(
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
          ),
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
      attribut: [
        if (article.size.isNotEmpty) 'T.${article.size}',
        if (article.material.isNotEmpty) article.material,
      ].join('. '),
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
