import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Écran Wishlist — pièces sauvegardées par l'utilisateur
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pour l'instant, wishlist mockée
    final wishlistItems = [
      {
        'id': '2',
        'brand': 'Sézane',
        'title': 'Sac Cuir Camel',
        'price': 31000.0,
        'size': 'Unique',
        'material': 'Cuir pleine fleur',
        'condition': 'Très bon',
        'image':
            'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80',
      },
      {
        'id': '4',
        'brand': 'Rue Sereine',
        'title': 'Blouse Ivoire Fluide',
        'price': 18500.0,
        'size': 'S',
        'material': 'Soie',
        'condition': 'Très bon',
        'image':
            'https://images.unsplash.com/photo-1594938298603-c8148c4b4e2f?w=600&q=80',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ma wishlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackCloset,
              ),
            ),
            Text(
              'VOS PIÈCES FAVORITES',
              style: TextStyle(
                fontSize: 8,
                color: AppTheme.greyText,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      body: wishlistItems.isEmpty
          ? _EmptyWishlist()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = wishlistItems[i];
                return _WishlistCard(
                  item: item,
                  onTap: () => context.push('/product/${item['id']}'),
                );
              },
            ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _WishlistCard({required this.item, required this.onTap});

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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'] as String,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(width: 80, height: 100, color: AppTheme.sandBeige),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item['brand'] as String).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.blackCloset,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'T. ${item['size']} · ${item['material']}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.greyText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(item['price'] as double),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.blackCloset,
                    ),
                  ),
                ],
              ),
            ),
            const Column(
              children: [
                Icon(Icons.favorite, size: 20, color: Colors.redAccent),
                SizedBox(height: 12),
                Icon(Icons.chevron_right, size: 18, color: AppTheme.greyText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
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
              decoration: const BoxDecoration(
                color: AppTheme.sandBeige,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border,
                  size: 36, color: AppTheme.greyText),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre wishlist est vide',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackCloset,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ajoutez des pièces à votre wishlist\npour les retrouver facilement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.go('/collections'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Explorer les collections',
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
