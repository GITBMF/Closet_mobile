import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

final productDetailProvider =
    FutureProvider.family<Article?, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).getById(id);
});

class ProductScreen extends ConsumerStatefulWidget {
  final String articleId;
  const ProductScreen({super.key, required this.articleId});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final thousands = intPrice ~/ 1000;
    final remainder = intPrice % 1000;
    if (remainder == 0) return '$thousands 000 FCFA';
    return '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(productDetailProvider(widget.articleId));

    return articleAsync.when(
      data: (article) {
        if (article == null) {
          return const Scaffold(body: Center(child: Text('Pièce introuvable')));
        }
        return _buildContent(context, article);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: ClosetColors.dore),
        ),
      ),
      error: (e, _) => const Scaffold(
        body: Center(child: Text('Erreur de chargement')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Article article) {
    final cartItems = ref.watch(cartListProvider);
    final isInCart = cartItems.any((a) => a.id == article.id);
    final isWishlisted = ref.watch(wishlistListProvider).any((a) => a.id == article.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new,
                size: 16, color: theme.colorScheme.onSurface),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                size: 18,
                // Erreur (terre brûlée) pour wishlist active — charte §3.1
                color: isWishlisted ? ClosetColors.erreur : theme.colorScheme.onSurface,
              ),
              onPressed: () {
                ref.read(wishlistProvider.notifier).toggleWishlist(article);
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ─── Image Gallery ──────────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.48,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: article.imageUrls.length,
                  onPageChanged: (i) =>
                      setState(() => _currentImageIndex = i),
                  itemBuilder: (context, i) {
                    return Image.network(
                      article.imageUrls[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: ClosetColors.ligne,
                        child: Icon(Icons.image_not_supported,
                            size: 48, color: ClosetColors.taupe),
                      ),
                    );
                  },
                ),
                // Page indicator dots
                if (article.imageUrls.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        article.imageUrls.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _currentImageIndex ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _currentImageIndex
                                ? ClosetColors.creme
                                : ClosetColors.creme.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Detail Sheet ───────────────────────────────────────────
          Expanded(
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand + Condition badge
                    Row(
                      children: [
                        Text(
                          article.brand.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _ConditionBadge(condition: article.condition),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      article.title,
                      style: ClosetTextStyles.h1.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price + unique pill
                    Row(
                      children: [
                        Text(
                          _formatPrice(article.price),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (article.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: ClosetColors.vert.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ClosetColors.vert.withValues(alpha: 0.18)),
                            ),
                            child: Text(
                              'PIÈCE UNIQUE',
                              style: ClosetTextStyles.caption.copyWith(
                                fontSize: 11,
                                color: ClosetColors.vert,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Details card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _DetailField(
                                  label: 'TAILLE & COUPE',
                                  value: 'T. ${article.size}',
                                ),
                              ),
                              Expanded(
                                child: _DetailField(
                                  label: 'MATIÈRE',
                                  value: article.material,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _DetailField(
                                  label: 'UNIVERS',
                                  value: article.universe,
                                ),
                              ),
                              const Expanded(
                                child: _DetailField(
                                  label: 'AUTHENTICITÉ',
                                  value: '✓ Vérifiée',
                                  valueColor: ClosetColors.succes,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description éditoriale
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 12, color: ClosetColors.dore),
                        const SizedBox(width: 6),
                        Text(
                          'À PROPOS DE CETTE PIÈCE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            // doreEncre = seul doré autorisé en texte sur clair
                            color: isDark ? theme.colorScheme.primary : ClosetColors.doreEncre,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Livraison délicate banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_shipping_outlined,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Livraison délicate — Yaoundé sous 24h, expédition internationale sous 5 jours ouvrés, écrin ClosET inclus.',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ─── Bottom CTA ─────────────────────────────────────────────────
// bottomNavigationBar: Container(
//   padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//   decoration: BoxDecoration(
//     // ✅ FIXED: Changed from Colors.red to proper theme color
//     color: Colors.red,
//     border: Border(
//       top: BorderSide(
//         color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
//       ),
//     ),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withValues(alpha: 0.08),
//         blurRadius: 20,
//         offset: const Offset(0, -4),
//       ),
//     ],
//   ),
//   child: SafeArea(
//     child: Row(
//       children: [
//         Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'À ADOPTER',
//               style: TextStyle(
//                 fontSize: 9,
//                 color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                 letterSpacing: 1.5,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               _formatPrice(article.price),
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: GestureDetector(
//             onTap: () {
//               if (!isInCart && !article.isSoldOut) {
//                 ref.read(cartProvider.notifier).addArticle(article);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Pièce ajoutée à votre sélection'),
//                     backgroundColor: ClosetColors.vert,
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     margin: const EdgeInsets.all(16),
//                   ),
//                 );
//               }
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 color: article.isSoldOut
//                     ? ClosetColors.taupe
//                     : theme.colorScheme.primary,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     isInCart
//                         ? Icons.check_circle_outline
//                         : Icons.shopping_bag_outlined,
//                     size: 18,
//                     color: theme.colorScheme.onPrimary,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     article.isSoldOut
//                         ? 'DÉJÀ ADOPTÉE'
//                         : isInCart
//                             ? 'DÉJÀ DANS MA SÉLECTION'
//                             : 'AJOUTER À MON DRESSING',
//                     style: TextStyle(
//                       color: theme.colorScheme.onPrimary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   ),
// ),
// ─── Bottom CTA (Floating) ──────────────────────────────────────
      bottomNavigationBar: Container(
        height: 100,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          // color: theme.colorScheme.surface,
          color: Color(0xFF1C382D),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'À ADOPTER',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFFE1CDA6),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 2),
                    Text(
                      _formatPrice(article.price),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isInCart && !article.isSoldOut) {
                        ref.read(cartProvider.notifier).addArticle(article);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Pièce ajoutée à votre sélection'),
                            backgroundColor: ClosetColors.vert,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        // color: article.isSoldOut
                        //     ? ClosetColors.taupe
                        //     : theme.colorScheme.primary,
                        color: Color(0xFFCDAB71),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(
                          //   isInCart
                          //       ? Icons.check_circle_outline
                          //       : Icons.shopping_bag_outlined,
                          //   size: 18,
                          //   color: theme.colorScheme.onPrimary,
                          // ),
                          const SizedBox(width: 8),
                          Text(
                            article.isSoldOut
                                ? 'DÉJÀ ADOPTÉE'
                                : isInCart
                                    ? 'DÉJÀ DANS MA SÉLECTION'
                                    : 'AJOUTER À MON DRESSING',
                            style: TextStyle(
                              color: Color(0xFF171512),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailField(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}


class _ConditionBadge extends StatelessWidget {
  final String condition;
  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (condition.toLowerCase()) {
      case 'neuf avec étiquette':
      case 'neuf':
        bg = ClosetColors.conditionNeufFond;
        fg = ClosetColors.conditionNeufTexte;
        break;
      case 'excellent':
        bg = ClosetColors.conditionExcellentFond;
        fg = ClosetColors.conditionExcellentTexte;
        break;
      default:
        bg = ClosetColors.conditionTresBonFond;
        fg = ClosetColors.conditionTresBonTexte;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
