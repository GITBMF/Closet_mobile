import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

final productDetailProvider =
    FutureProvider.family<Article?, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).getById(id);
});

/// Fiche produit — transcription des maquettes `16:3328` et `16:3063`.
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.articleId});

  final String articleId;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final _pageController = PageController();
  int _imageCourante = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(productDetailProvider(widget.articleId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: articleAsync.when(
        data: (article) {
          if (article == null) {
            return EtatEcran.vide(
              icone: Icons.search_off_rounded,
              titre: 'Pièce introuvable',
              message: 'Cette pièce n’est plus dans le dressing.',
              action: () => context.pop(),
              libelleAction: 'Retour',
            );
          }
          return Stack(
            children: [
              _Corps(
                article: article,
                pageController: _pageController,
                imageCourante: _imageCourante,
                onImageChangee: (i) => setState(() => _imageCourante = i),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BarreAjout(article: article),
              ),
            ],
          );
        },
        loading: () => const EtatEcran.chargement(),
        error: (e, _) => EtatEcran.erreur(
          erreur: e,
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.articleId)),
        ),
      ),
    );
  }
}

class _Corps extends ConsumerWidget {
  const _Corps({
    required this.article,
    required this.pageController,
    required this.imageCourante,
    required this.onImageChangee,
  });

  final Article article;
  final PageController pageController;
  final int imageCourante;
  final ValueChanged<int> onImageChangee;

  static String? _recit(Article article) {
    final story = article.story?.trim() ?? '';
    if (story.isNotEmpty) return story;
    if (article.description.trim().isNotEmpty) {
      return article.description.trim();
    }
    return null;
  }

  List<({String label, String valeur})> get _caracteristiques {
    return [
      if (article.condition.trim().isNotEmpty)
        (label: 'État de la pièce', valeur: article.condition),
      if (article.size.trim().isNotEmpty)
        (label: 'Taille et coupe', valeur: article.size),
      if (article.material.trim().isNotEmpty)
        (label: 'Matière', valeur: article.material),
      if (article.universe.trim().isNotEmpty)
        (label: 'Univers', valeur: article.universe),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enWishlist =
        ref.watch(wishlistListProvider).any((a) => a.id == article.id);
    final recit = _recit(article);
    final lignes = _caracteristiques;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Carrousel(
            article: article,
            controller: pageController,
            indexCourant: imageCourante,
            onChange: onImageChangee,
            enWishlist: enWishlist,
            onWishlist: () =>
                ref.read(wishlistProvider.notifier).toggleWishlist(article),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.brand.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ClosetTextStyles.attribut.copyWith(
                          color: ClosetColors.fond400,
                        ),
                      ),
                    ),
                    if (article.condition.trim().isNotEmpty)
                      _BadgeMenthe(article.condition),
                  ],
                ),
                const SizedBox(height: AppSpacing.p12),
                Text(
                  article.title,
                  style: ClosetTextStyles.nomProduit.copyWith(
                    fontSize: 22,
                    letterSpacing: -0.44,
                  ),
                ),
                const SizedBox(height: AppSpacing.p16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        formatPrixFcfa(article.price),
                        style: ClosetTextStyles.prixGrand.copyWith(
                          color: ClosetColors.vert,
                        ),
                      ),
                    ),
                    const _BadgePieceUnique(),
                  ],
                ),
                if (lignes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.p24),
                  const _Filet(),
                  for (final ligne in lignes) ...[
                    _LigneCaracteristique(
                      label: ligne.label,
                      valeur: ligne.valeur,
                    ),
                    const _Filet(),
                  ],
                ],
                if (recit != null) ...[
                  const SizedBox(height: AppSpacing.p20),
                  _CarteRecit(description: recit),
                ],
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Carrousel extends StatelessWidget {
  const _Carrousel({
    required this.article,
    required this.controller,
    required this.indexCourant,
    required this.onChange,
    required this.enWishlist,
    required this.onWishlist,
  });

  final Article article;
  final PageController controller;
  final int indexCourant;
  final ValueChanged<int> onChange;
  final bool enWishlist;
  final VoidCallback onWishlist;

  @override
  Widget build(BuildContext context) {
    final images = article.imageUrls;
    final hautSafe = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 493,
      child: Stack(
        children: [
          Positioned.fill(
            child: images.isEmpty
                ? const ColoredBox(color: ClosetColors.gabaritImage)
                : PageView.builder(
                    controller: controller,
                    itemCount: images.length,
                    onPageChanged: onChange,
                    itemBuilder: (context, i) => CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
                    ),
                  ),
          ),
          Positioned(
            top: hautSafe + AppSpacing.p12,
            left: AppSpacing.p32,
            right: AppSpacing.p20,
            child: Row(
              children: [
                _BoutonRondFlottant(
                  icone: Icons.arrow_back_ios_new,
                  label: 'Retour',
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _BoutonRondFlottant(
                  icone: Icons.shopping_basket_outlined,
                  label: 'Ma sélection',
                  onTap: () => context.go('/selection'),
                ),
                const SizedBox(width: AppSpacing.gapListe),
                _BoutonRondFlottant(
                  icone: enWishlist ? Icons.favorite : Icons.favorite_border,
                  label: enWishlist
                      ? 'Retirer de la wishlist'
                      : 'Ajouter à la wishlist',
                  couleurIcone:
                      enWishlist ? ClosetColors.erreurCouture : null,
                  onTap: onWishlist,
                ),
              ],
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: AppSpacing.p16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: ClosetColors.blanc.withValues(
                          alpha: i == indexCourant ? 1 : 0.45,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BoutonRondFlottant extends StatelessWidget {
  const _BoutonRondFlottant({
    required this.icone,
    required this.label,
    required this.onTap,
    this.couleurIcone,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;
  final Color? couleurIcone;

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
          child: Icon(
            icone,
            size: 16,
            color: couleurIcone ?? ClosetColors.vert,
          ),
        ),
      ),
    );
  }
}

class _BadgeMenthe extends StatelessWidget {
  const _BadgeMenthe(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: AppSpacing.p4,
      ),
      decoration: BoxDecoration(
        color: ClosetColors.emeraude100,
        borderRadius: BorderRadius.circular(AppRadius.vignette),
      ),
      child: Text(
        texte,
        style: ClosetTextStyles.attribut.copyWith(
          color: ClosetColors.emeraude500,
        ),
      ),
    );
  }
}

class _BadgePieceUnique extends StatelessWidget {
  const _BadgePieceUnique();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
      decoration: BoxDecoration(
        color: ClosetColors.emeraude100,
        borderRadius: BorderRadius.circular(AppRadius.bouton),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: ClosetColors.vert,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.gapChip),
          Text(
            'Pièce unique',
            style: ClosetTextStyles.corps.copyWith(color: ClosetColors.vert),
          ),
        ],
      ),
    );
  }
}

class _Filet extends StatelessWidget {
  const _Filet();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: ClosetColors.fond400,
      thickness: AppStroke.fin,
      height: AppStroke.fin,
    );
  }
}

class _LigneCaracteristique extends StatelessWidget {
  const _LigneCaracteristique({required this.label, required this.valeur});

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: ClosetTextStyles.corps.copyWith(
                color: ClosetColors.taupe,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.p12),
          Expanded(
            flex: 6,
            child: Text(
              valeur,
              textAlign: TextAlign.end,
              style: ClosetTextStyles.corpsMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteRecit extends StatelessWidget {
  const _CarteRecit({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: context.closetCarte,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos de cette pièce',
            style: ClosetTextStyles.corps.copyWith(color: ClosetColors.taupe),
          ),
          const SizedBox(height: AppSpacing.p20),
          Text(description, style: ClosetTextStyles.citation),
          const SizedBox(height: AppSpacing.p20),
          Text(
            'Livrée avec packaging ClosET exclusif',
            style: ClosetTextStyles.corps.copyWith(color: ClosetColors.taupe),
          ),
        ],
      ),
    );
  }
}

class _BarreAjout extends ConsumerWidget {
  const _BarreAjout({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dejaDansPanier =
        ref.watch(cartListProvider).any((a) => a.id == article.id);
    final indisponible = article.isSoldOut;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(19, 0, 19, AppSpacing.p12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p20,
              vertical: AppSpacing.p12,
            ),
            decoration: BoxDecoration(
              color: ClosetColors.vert,
              borderRadius: BorderRadius.circular(AppRadius.carte),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'À ajouter',
                        style: ClosetTextStyles.corpsMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ClosetColors.neutre300,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p4),
                      Text(
                        formatPrixFcfa(article.price),
                        style: ClosetTextStyles.prixGrand.copyWith(
                          color: ClosetColors.blanc,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.p8),
                SizedBox(
                  width: 170,
                  height: 44,
                  child: Material(
                    color: indisponible
                        ? ClosetColors.doreDesactive
                        : ClosetColors.fond300,
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.cercle),
                      onTap: indisponible
                          ? null
                          : () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addArticle(article);
                              toastSucces(
                                ref,
                                'Ajoutée à votre sélection.',
                              );
                            },
                      child: Center(
                        child: Text(
                          indisponible
                              ? 'Indisponible'
                              : dejaDansPanier
                                  ? 'Déjà dans ma sélection'
                                  : 'Ajouter à mon dressing',
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
          ),
        ),
      ),
    );
  }
}
