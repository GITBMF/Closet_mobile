import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/models/article.dart';

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

    return Scaffold(
      backgroundColor: ClosetColors.creme,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ClosetColors.creme.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: ClosetColors.noir),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ClosetColors.creme.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                size: 18,
                // Erreur (terre brûlée) pour wishlist active — charte §3.1
                color: isWishlisted ? ClosetColors.erreur : ClosetColors.noir,
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
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: ClosetColors.ligne,
                        child: const Icon(Icons.image_not_supported,
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
              color: ClosetColors.creme,
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
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ClosetColors.vert,
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
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.noir,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price
                    Text(
                      _formatPrice(article.price),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.noir,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Details card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ClosetColors.beige,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ClosetColors.ligne),
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
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 12, color: ClosetColors.dore),
                        SizedBox(width: 6),
                        Text(
                          'À PROPOS DE CETTE PIÈCE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            // doreEncre = seul doré autorisé en texte sur clair
                            color: ClosetColors.doreEncre,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: ClosetColors.noir,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Livraison délicate banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ClosetColors.dore.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: ClosetColors.dore.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_shipping_outlined,
                              size: 18, color: ClosetColors.vert),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Livraison délicate — Yaoundé sous 24h, expédition internationale sous 5 jours ouvrés, écrin ClosET inclus.',
                              style: TextStyle(
                                fontSize: 12,
                                color: ClosetColors.noir,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: ClosetColors.noir,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'À ADOPTER',
                  style: TextStyle(
                    fontSize: 9,
                    color: ClosetColors.taupe,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatPrice(article.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.creme,
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
                    // CTA : vert si disponible, taupe si soldout
                    color: article.isSoldOut
                        ? ClosetColors.taupe
                        : isInCart
                            ? ClosetColors.vert
                            : ClosetColors.vert,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart
                            ? Icons.check_circle_outline
                            : Icons.shopping_bag_outlined,
                        size: 18,
                        color: ClosetColors.creme,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.isSoldOut
                            ? 'DÉJÀ ADOPTÉE'
                            : isInCart
                                ? 'DÉJÀ DANS MA SÉLECTION'
                                : 'AJOUTER À MON DRESSING',
                        style: const TextStyle(
                          color: ClosetColors.creme,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: ClosetColors.taupe,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? ClosetColors.noir,
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
