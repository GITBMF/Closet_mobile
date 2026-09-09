import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_layout.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../data/models/article.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import 'closet_header_button.dart';
import 'piece_card.dart';

/// En-tête principal — transcription de la maquette `11:30`.
///
/// À gauche « Bienvenue, » puis le nom. À droite les raccourcis sélection
/// et notifications. Les boutons cèdent la place au texte (ellipsis) et
/// restent hors encoche grâce à [SafeArea] ; le Scaffold ajoute déjà
/// l'inset statut à [preferredSize], on ne le recompte pas.
class ClosetAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ClosetAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showShortcuts = true,
    this.actions,
  });

  final String? title;
  final String? subtitle;
  final bool showBackButton;

  /// Raccourcis Sélection / Notifications — réservés à l'accueil.
  final bool showShortcuts;
  final List<Widget>? actions;

  @override
  Size get preferredSize =>
      const Size.fromHeight(ClosetLayout.hauteurBarre);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final user = ref.watch(currentUserProvider);
    final layout = ClosetLayout.of(context);

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
            height: ClosetLayout.hauteurBarre,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: layout.gouttiere),
              child: Row(
                children: [
                  if (showBackButton) ...[
                    ClosetBoutonHeader(
                      icone: Icons.arrow_back_ios_new,
                      label: 'Retour',
                      onTap: () => context.pop(),
                    ),
                    SizedBox(width: layout.ecartBoutonsHeader),
                  ],
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: user == null ? () => context.push('/auth') : null,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _Salutation(
                            title: title,
                            subtitle: subtitle,
                            user: user,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (actions != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    )
                  else if (showShortcuts)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClosetBoutonHeader(
                          icone: Icons.shopping_basket_outlined,
                          label: cartCount > 0
                              ? 'Sélection, $cartCount pièces'
                              : 'Ma sélection',
                          pastille: cartCount > 0 ? cartCount : null,
                          onTap: () => context.go('/selection'),
                        ),
                        SizedBox(width: layout.ecartBoutonsHeader),
                        ClosetBoutonHeader(
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
  @override
  Widget build(BuildContext context) {
    final isWishlisted = ref
        .watch(wishlistListProvider)
        .any((a) => a.id == widget.article.id);

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
      etoiles: article.etoilesEtat,
      isFavorite: isWishlisted,
      isSold: article.isSoldOut,
      onTap: widget.onTap,
      onFavoriteTap: () => basculerFavori(ref, article),
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
