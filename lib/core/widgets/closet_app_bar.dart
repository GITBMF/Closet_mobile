import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/models/article.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/wishlist_repository.dart';

/// AppBar réutilisable avec logo ClosET et icônes d'action
class ClosetAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;

  const ClosetAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.actions,
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
                Semantics(
                  button: true,
                  label: 'Retour',
                  child: Tooltip(
                    message: 'Retour',
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SizedBox(
                        width: AppSpacing.minTouchTarget,
                        height: AppSpacing.minTouchTarget,
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 18, color: onSurfaceColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.p12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: ClosetTextStyles.titreEcran.copyWith(
                        fontSize: 15,
                        color: onSurfaceColor,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: ClosetTextStyles.labelChamp.copyWith(
                          color: onSurfaceColor.withValues(alpha: 0.6),
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
                  isDark ? 'assets/logo_fond_sombre.png' : 'assets/iconheader.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, _, _) => const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ClosetColors.vert,
                    ),
                    child: Center(
                      child: Text('C', style: TextStyle(color: ClosetColors.creme, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.p8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title ?? 'ClosET',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ClosetTextStyles.titreEcran.copyWith(
                          fontSize: 16,
                          color: onSurfaceColor,
                        ),
                      ),
                      Text(
                        subtitle ?? 'L\'ÉLÉGANCE DURABLE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ClosetTextStyles.labelChamp.copyWith(
                          fontSize: 8,
                          color: onSurfaceColor.withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: actions ?? [
        // Search icon navigating to collections
        Semantics(
          button: true,
          label: 'Rechercher des pièces',
          child: IconButton(
            icon: const Icon(Icons.search, size: 22),
            color: onSurfaceColor,
            onPressed: () => context.go('/collections'),
          ),
        ),
        // Profile
        Semantics(
          button: true,
          label: 'Mon espace',
          child: IconButton(
            icon: const Icon(Icons.person_outline, size: 22),
            color: onSurfaceColor,
            onPressed: () => context.go('/espace'),
          ),
        ),
        // Cart with badge
        Stack(
          alignment: Alignment.topRight,
          children: [
            Semantics(
              button: true,
              label: cartCount > 0 ? 'Panier, $cartCount articles' : 'Panier',
              child: IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, size: 22),
                color: onSurfaceColor,
                onPressed: () => context.go('/selection'),
              ),
            ),
            if (cartCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: ClosetColors.vert,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: ClosetTextStyles.labelChamp.copyWith(
                            color: ClosetColors.creme,
                            fontSize: 9,
                          ),
                        ),
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
/// Carte article réutilisable reproduisant le design de la maquette
class ArticleCard extends ConsumerStatefulWidget {
  final Article article;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  @override
  ConsumerState<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends ConsumerState<ArticleCard> {
  bool? _localWishlisted;

  @override
  void didUpdateWidget(covariant ArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.id != widget.article.id) {
      _localWishlisted = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistListProvider);
    final isWishlistedReal = wishlist.any((a) => a.id == widget.article.id);

    // Sync local state if it matches the provider state
    if (_localWishlisted == isWishlistedReal) {
      _localWishlisted = null;
    }

    final isWishlisted = _localWishlisted ?? isWishlistedReal;
    final isSoldOut = widget.article.isSoldOut;
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: widget.onTap,
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
                        widget.article.imageUrls[0],
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
                    child: Semantics(
                      button: true,
                      label: isWishlisted ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _localWishlisted = !isWishlisted;
                          });
                          ref.read(wishlistProvider.notifier).toggleWishlist(widget.article);
                        },
                        child: Container(
                          width: AppSpacing.minTouchTarget,
                          height: AppSpacing.minTouchTarget,
                          alignment: Alignment.center,
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOutCubic,
                            transitionBuilder: (child, animation) => ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(isWishlisted),
                              size: 20,
                              color: isWishlisted ? ClosetColors.erreur : ClosetColors.taupe,
                            ),
                          ),
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
                    widget.article.brand.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.article.title,
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
                      Flexible(
                        child: Text(
                          _formatPrice(widget.article.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: onSurfaceColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (!isSoldOut)
                        Flexible(
                          child: _ConditionBadge(condition: widget.article.condition),
                        ),
                      if (isSoldOut)
                        Flexible(
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              '⏰ M\'ALERTER',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'T. ${widget.article.size} · ${widget.article.material}',
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
