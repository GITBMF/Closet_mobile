import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/cart_repository.dart';

/// AppBar réutilisable avec logo ClosET et icônes d'action
class ClosetAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;

  const ClosetAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);

    return AppBar(
      backgroundColor: AppTheme.offWhite,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: showBackButton
          ? Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 18, color: AppTheme.blackCloset),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blackCloset,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.greyText,
                          letterSpacing: 1.5,
                        ),
                      ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                // Avatar circle + logo
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.goldCloset.withValues(alpha: 0.2),
                    border: Border.all(color: AppTheme.goldCloset, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: AppTheme.goldCloset,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'ClosET',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blackCloset,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      subtitle ?? 'L\'ÉLÉGANCE DURABLE',
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppTheme.greyText,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      actions: [
        // Search
        IconButton(
          icon: const Icon(Icons.search, size: 22),
          color: AppTheme.blackCloset,
          onPressed: () {},
        ),
        // Wishlist
        IconButton(
          icon: const Icon(Icons.favorite_border, size: 22),
          color: AppTheme.blackCloset,
          onPressed: () {},
        ),
        // Cart with badge
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 22),
              color: AppTheme.blackCloset,
              onPressed: () => context.go('/cart'),
            ),
            if (cartCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.goldCloset,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Notifications
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 22),
              color: AppTheme.blackCloset,
              onPressed: () {},
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// Carte article réutilisable reproduisant le design de la maquette
class ArticleCard extends ConsumerWidget {
  final dynamic article; // Article
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = article.isWishlisted as bool;
    final isSoldOut = article.isSoldOut as bool;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.warmCream,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.blackCloset.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image zone with wish + sold-out overlay
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: ColorFiltered(
                      colorFilter: isSoldOut
                          ? const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ])
                          : const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply),
                      child: Image.network(
                        article.imageUrls[0] as String,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppTheme.sandBeige,
                        ),
                      ),
                    ),
                  ),
                  // Sold-out badge
                  if (isSoldOut)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.blackCloset.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Déjà adoptée',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Heart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isWishlisted ? Colors.red : AppTheme.greyText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info zone
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (article.brand as String).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.title as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blackCloset,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(article.price as double),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.blackCloset,
                        ),
                      ),
                      if (!isSoldOut)
                        _ConditionBadge(condition: article.condition as String),
                      if (isSoldOut)
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            '⏰ M\'ALERTER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'T. ${article.size} · ${article.material}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Format: "38 500 FCFA"
    final intPrice = price.toInt();
    if (intPrice >= 1000) {
      final thousands = intPrice ~/ 1000;
      final remainder = intPrice % 1000;
      if (remainder == 0) {
        return '$thousands 000 FCFA';
      }
      return '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
    }
    return '$intPrice FCFA';
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
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'excellent':
        bg = const Color(0xFFE8F0FE);
        fg = const Color(0xFF1A56B0);
        break;
      default:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
