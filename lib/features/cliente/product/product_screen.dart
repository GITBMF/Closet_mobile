import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
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
    if (intPrice >= 1000) {
      final thousands = intPrice ~/ 1000;
      final remainder = intPrice % 1000;
      if (remainder == 0) {
        return '$thousands.000 FCFA';
      }
      return '$thousands.${remainder.toString().padLeft(3, '0')} FCFA';
    }
    return '$intPrice FCFA';
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
        backgroundColor: ClosetColors.beige,
        body: Center(
          child: CircularProgressIndicator(color: ClosetColors.vert),
        ),
      ),
      error: (e, _) => const Scaffold(
        backgroundColor: ClosetColors.beige,
        body: Center(child: Text('Erreur de chargement')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Article article) {
    final cartItems = ref.watch(cartListProvider);
    final isInCart = cartItems.any((a) => a.id == article.id);
    final isWishlisted = ref.watch(wishlistListProvider).any((a) => a.id == article.id);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClosetColors.ligne),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: ClosetColors.vertFonce,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(
                  isInCart ? Icons.shopping_basket : Icons.shopping_basket_outlined,
                  size: 18,
                  color: ClosetColors.vertFonce,
                ),
                onPressed: () {
                  // Action navigation selection cart page if desired
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isWishlisted ? ClosetColors.erreur : ClosetColors.vertFonce,
                ),
                onPressed: () {
                  ref.read(wishlistProvider.notifier).toggleWishlist(article);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140), // Spacing for floating CTA
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Gallery PageView
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.54,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: article.imageUrls.length,
                          onPageChanged: (i) => setState(() => _currentImageIndex = i),
                          itemBuilder: (context, i) {
                            return Image.network(
                              article.imageUrls[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: ClosetColors.ligne,
                                child: Icon(Icons.image_not_supported,
                                    size: 48, color: ClosetColors.taupe),
                              ),
                            );
                          },
                        ),
                        // Page indicator dots at bottom of the gallery image
                        if (article.imageUrls.length > 1)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                article.imageUrls.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: i == _currentImageIndex ? 22 : 6,
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

                  // 2. Details Sheet Body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand and Condition tag row
                        Row(
                          children: [
                            Text(
                              'MAISON ${article.brand.toUpperCase()}',
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                letterSpacing: 1.8,
                                color: ClosetColors.taupe,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildConditionBadge(article.condition),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title in Editorial Serif
                        Text(
                          article.title,
                          style: GoogleFonts.cormorantGaramond(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: ClosetColors.noir,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Price and Pièce Unique badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatPrice(article.price),
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: ClosetColors.vert,
                              ),
                            ),
                            _buildPieceUniqueBadge(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ClosetColors.ligne, height: 1, thickness: 1),
                        const SizedBox(height: 8),

                        // Details Rows:
                        _buildDetailRow('Etat de la pièce', '${article.condition} — très bon état'),
                        const Divider(color: ClosetColors.ligne, height: 1, thickness: 1),
                        _buildDetailRow('Taille & Coupe', 'T. ${article.size} — Coupe standard'),
                        const Divider(color: ClosetColors.ligne, height: 1, thickness: 1),
                        _buildDetailRow('Matière', article.material.isNotEmpty ? article.material : 'Coton, Tweed'),
                        const Divider(color: ClosetColors.ligne, height: 1, thickness: 1),
                        _buildDetailRow('Entretien', 'Nettoyage à sec délicat'),
                        const Divider(color: ClosetColors.ligne, height: 1, thickness: 1),
                        const SizedBox(height: 28),

                        // À Propos card box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: ClosetColors.creme,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ClosetColors.ligne),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'À PROPOS DE CETTE PIÈCE',
                                style: GoogleFonts.lato(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: ClosetColors.doreEncre,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '« ${article.description} »',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 15.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  color: ClosetColors.noir,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Livrée avec packaging Clos ET exclusif',
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: ClosetColors.taupe,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Bottom CTA Box
          Positioned(
            left: 16,
            right: 16,
            bottom: 28,
            child: Container(
              height: 85,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: ClosetColors.vertFonce,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left side Price info
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À AJOUTER',
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            color: ClosetColors.creme.withValues(alpha: 0.7),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatPrice(article.price),
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: ClosetColors.creme,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right side CTA button
                  GestureDetector(
                    onTap: () {
                      if (isInCart) {
                        context.go('/selection');
                        return;
                      }
                      if (!article.isSoldOut) {
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: article.isSoldOut
                            ? ClosetColors.taupe
                            : ClosetColors.doreClair,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        article.isSoldOut
                            ? 'DÉJÀ ADOPTÉE'
                            : isInCart
                                ? 'SÉLECTIONNÉE'
                                : 'AJOUTER À MON DRESSING',
                        style: GoogleFonts.lato(
                          color: ClosetColors.vertFonce,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionBadge(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFA0D0BD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        condition.toUpperCase(),
        style: GoogleFonts.lato(
          color: ClosetColors.vertFonce,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  Widget _buildPieceUniqueBadge() {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFA0D0BD),
        borderRadius: BorderRadius.circular(999),
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
          const SizedBox(width: 6),
          Text(
            'PIÈCE UNIQUE',
            style: GoogleFonts.lato(
              color: ClosetColors.vertFonce,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12.5,
              color: ClosetColors.taupe,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 12.5,
              color: ClosetColors.vertFonce,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
