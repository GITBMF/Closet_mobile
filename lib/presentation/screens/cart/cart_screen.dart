import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/models/article.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final thousands = intPrice ~/ 1000;
    final remainder = intPrice % 1000;
    if (remainder == 0) return '$thousands 000 FCFA';
    return '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ma sélection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackCloset,
              ),
            ),
            Text(
              'VOTRE DRESSING PERSONNALISÉ',
              style: TextStyle(
                fontSize: 8,
                color: AppTheme.greyText,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      body: cartItems.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      return _CartItem(
                        article: cartItems[i],
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .removeArticle(cartItems[i].id),
                        onTap: () =>
                            context.push('/product/${cartItems[i].id}'),
                      );
                    },
                  ),
                ),
                _CartSummary(
                  items: cartItems,
                  total: total,
                  formatPrice: _formatPrice,
                ),
              ],
            ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.sandBeige,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: AppTheme.greyText,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre dressing attend\nsa prochaine pièce',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackCloset,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explorez nos collections pour trouver\nla pièce qui vous ressemble.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.go('/catalog'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Découvrir les collections',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

  const _CartItem({
    required this.article,
    required this.onRemove,
    required this.onTap,
  });

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final thousands = intPrice ~/ 1000;
    final remainder = intPrice % 1000;
    if (remainder == 0) return '$thousands 000 FCFA';
    return '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.warmCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.sandBeige),
          boxShadow: [
            BoxShadow(
              color: AppTheme.blackCloset.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.imageUrls.first,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 80,
                  height: 100,
                  color: AppTheme.sandBeige,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.brand.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.blackCloset,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'T. ${article.size} · ${article.material}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.greyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _ConditionBadge(condition: article.condition),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(article.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.blackCloset,
                    ),
                  ),
                ],
              ),
            ),

            // Remove button
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.sandBeige,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppTheme.greyText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart Summary / Checkout ──────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  final List<Article> items;
  final double total;
  final String Function(double) formatPrice;

  const _CartSummary({
    required this.items,
    required this.total,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: AppTheme.warmCream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackCloset.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.sandBeige,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            children: [
              const Text(
                'Récapitulatif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.blackCloset,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} pièce${items.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.greyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Promo code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.sandBeige),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.card_giftcard,
                    size: 18, color: AppTheme.goldCloset),
                SizedBox(width: 10),
                Text(
                  'Ajouter un privilège',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.greyText,
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right,
                    size: 18, color: AppTheme.greyText),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.blackCloset,
                ),
              ),
              Text(
                formatPrice(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.blackCloset,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CTA button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => context.push('/checkout'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.blackCloset,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'FINALISER MA SÉLECTION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Condition Badge ──────────────────────────────────────────────────────────

class _ConditionBadge extends StatelessWidget {
  final String condition;
  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (condition.toLowerCase()) {
      case 'excellent':
        bg = const Color(0xFFE8F0FE);
        fg = const Color(0xFF1A56B0);
        break;
      case 'très bon':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        break;
      default:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        condition,
        style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
