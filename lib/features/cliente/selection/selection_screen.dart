import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../auth/auth_screen.dart';

class SelectionScreen extends ConsumerWidget {
  const SelectionScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartListProvider);
    final subtotal = ref.watch(cartTotalProvider);
    const shippingFee = 3500.0; // Updated shipping fee to match mockup: 3.500 FCFA
    final total = subtotal > 0 ? subtotal + shippingFee : 0.0;

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/collections');
                }
              },
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
            child: const Center(
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 18,
                color: ClosetColors.vertFonce,
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
            child: const Center(
              child: Icon(
                Icons.notifications_none,
                size: 18,
                color: ClosetColors.vertFonce,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: cartItems.isEmpty
          ? const _EmptyCart()
          : Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120), // Spacing for bottom button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Ma sélection',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        // Subtitle
                        Text(
                          cartItems.length == 1
                              ? '1 pièce unique mise de côté pour vous.'
                              : '${cartItems.length} pièces uniques mises de côté pour vous.',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: ClosetColors.doreEncre,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // List of items
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final item = cartItems[i];
                            return _CartItem(
                              article: item,
                              onRemove: () {
                                final articleToRemove = item;
                                ref.read(cartProvider.notifier).removeArticle(articleToRemove.id);
                                
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${articleToRemove.title}" retirée de la sélection'),
                                    duration: const Duration(seconds: 5),
                                    action: SnackBarAction(
                                      label: 'Annuler',
                                      textColor: ClosetColors.doreClair,
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).addArticle(articleToRemove);
                                      },
                                    ),
                                    backgroundColor: ClosetColors.vertFonce,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              onTap: () => context.push('/product/${item.id}'),
                              formatPrice: _formatPrice,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Code Privilège Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ClosetColors.ligne),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_number_outlined,
                                      size: 16, color: ClosetColors.doreEncre),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CODE PRIVILÈGE',
                                    style: GoogleFonts.lato(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: ClosetColors.doreEncre,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: ClosetColors.ligne),
                                      ),
                                      child: TextField(
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          color: ClosetColors.taupe,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'CERCLE-PRIVILÈGE',
                                          hintStyle: GoogleFonts.lato(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: ClosetColors.ligne,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      // Apply coupon logic
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: ClosetColors.vertFonce,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'APPLIQUER',
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary breakdown directly on page background
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SOUS-TOTAL',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.taupe,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              _formatPrice(subtotal),
                              style: GoogleFonts.lato(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LIVRAISON DÉLICATE',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.taupe,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              _formatPrice(shippingFee),
                              style: GoogleFonts.lato(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ClosetColors.ligne, height: 1, thickness: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL À RÉGLER',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.noir,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              _formatPrice(total),
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Checkout Button
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Consumer(
                    builder: (context, ref, _) {
                      return GestureDetector(
                        onTap: () {
                          context.push('/checkout');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: ClosetColors.vertFonce,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Finaliser Ma sélection',
                              style: GoogleFonts.lato(
                                color: ClosetColors.creme,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 170,
              decoration: BoxDecoration(
                color: ClosetColors.creme,
                border: Border.all(color: ClosetColors.dore, width: 1.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(65),
                  topRight: Radius.circular(65),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  '⧉',
                  style: TextStyle(
                    fontSize: 34,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Votre dressing attend\nsa prochaine pièce',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ClosetColors.vertFonce,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Les pièces de notre sélection sont uniques — laissez-vous guider par les nouveautés de la semaine.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: ClosetColors.taupe,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => context.go('/collections'),
              child: Container(
                constraints: const BoxConstraints(minWidth: 220),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Découvrir les Collections',
                  style: GoogleFonts.lato(
                    color: ClosetColors.creme,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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

// ── Cart Item Card ───────────────────────────────────────────────────────────

class _CartItem extends StatelessWidget {
  final Article article;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final String Function(double) formatPrice;

  const _CartItem({
    required this.article,
    required this.onRemove,
    required this.onTap,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: article.imageUrls.isNotEmpty
                      ? Image.network(
                          article.imageUrls.first,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 80,
                            height: 100,
                            color: ClosetColors.ligne,
                            child: const Icon(Icons.image_not_supported_outlined, color: ClosetColors.taupe),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 100,
                          color: ClosetColors.ligne,
                          child: const Icon(Icons.image_not_supported_outlined, color: ClosetColors.taupe),
                        ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.brand.toUpperCase(),
                        style: GoogleFonts.lato(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.doreEncre,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ClosetColors.noir,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildConditionBadge(article.condition),
                      const SizedBox(height: 8),
                      Text(
                        formatPrice(article.price),
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remove Button at top right
          Positioned(
            top: 10,
            right: 10,
            child: Semantics(
              button: true,
              label: 'Retirer ${article.title} de ma sélection',
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: ClosetColors.noir,
                  ),
                ),
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
}
