import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/models/article.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/wishlist_repository.dart';

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
  Size get preferredSize => const Size.fromHeight(64);  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: showBackButton
          ? Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back_ios_new,
                      size: 18, color: onSurfaceColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurfaceColor.withValues(alpha: 0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                // Asset Logo
                Image.asset(
                  isDark ? 'assets/fond sombre.png' : 'assets/iconheader.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, _, _) => const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.goldCloset,
                    ),
                    child: Center(
                      child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'ClosET',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      subtitle ?? 'L\'ÉLÉGANCE DURABLE',
                      style: TextStyle(
                        fontSize: 8,
                        color: onSurfaceColor.withValues(alpha: 0.6),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      actions: [
        // Search icon navigating to collections
        IconButton(
          icon: const Icon(Icons.search, size: 22),
          color: onSurfaceColor,
          onPressed: () => context.go('/collections'),
        ),
        // Profile
        IconButton(
          icon: const Icon(Icons.person_outline, size: 22),
          color: onSurfaceColor,
          onPressed: () => context.go('/espace'),
        ),
        // Cart with badge
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 22),
              color: onSurfaceColor,
              onPressed: () => context.go('/selection'),
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
        const SizedBox(width: 4),
      ],
    );
  }
}

/// Carte article réutilisable reproduisant le design de la maquette
class ArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(wishlistProvider.notifier).isWishlisted(article.id);
    final isSoldOut = article.isSoldOut;
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: onSurfaceColor.withValues(alpha: 0.06),
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
                        article.imageUrls[0],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.grey.shade300,
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
                          color: Colors.black.withValues(alpha: 0.75),
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
                    child: GestureDetector(
                      onTap: () {
                        ref.read(wishlistProvider.notifier).toggleWishlist(article);
                      },
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
                    article.brand.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(article.price),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: onSurfaceColor,
                        ),
                      ),
                      if (!isSoldOut)
                        _ConditionBadge(condition: article.condition),
                      if (isSoldOut)
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            '⏰ M\'ALERTER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'T. ${article.size} · ${article.material}',
                    style: TextStyle(
                      fontSize: 10,
                      color: onSurfaceColor.withValues(alpha: 0.6),
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
