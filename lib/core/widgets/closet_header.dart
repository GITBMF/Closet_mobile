import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import '../../features/main_layout.dart';
import '../../features/cliente/espace/notifications_screen.dart';

/// En-tête commun : bouton retour, titre serif et actions circulaires
/// (recherche, wishlist, panier, notifications) avec pastilles de compteur.
class ClosetHeader extends StatelessWidget {
  const ClosetHeader({
    super.key,
    required this.titre,
    this.sousTitre,
    this.onBack,
    this.wishlistCount = 0,
    this.panierCount = 0,
    this.notificationsCount = 0,
  });

  final String titre;

  /// Ligne secondaire en capitales sous le titre (ex. nom de l'atelier).
  final String? sousTitre;
  final VoidCallback? onBack;
  final int wishlistCount;
  final int panierCount;
  final int notificationsCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _ActionCircle(
            icon: Icons.chevron_left,
            iconSize: 28,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: ClosetTextStyles.titreEcran,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sousTitre != null)
                  Text(
                    sousTitre!.toUpperCase(),
                    style: ClosetTextStyles.labelEtape.copyWith(
                      color: ClosetColors.texteSecondaire,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          _ActionCircle(
            icon: Icons.search,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainLayout(initialIndex: 1),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
          _ActionCircle(
            icon: Icons.favorite_border,
            badgeCount: wishlistCount,
            badgeColor: ClosetColors.rougeBadge,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainLayout(initialIndex: 2),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
          _ActionCircle(
            icon: Icons.shopping_bag_outlined,
            badgeCount: panierCount,
            badgeColor: ClosetColors.noir,
            onTap: () {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainLayout(initialIndex: 1),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
          _ActionCircle(
            icon: Icons.notifications_none,
            badgeCount: notificationsCount,
            badgeColor: ClosetColors.dore,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.onTap,
    this.iconSize = 22,
    this.badgeCount = 0,
    this.badgeColor = ClosetColors.noir,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final int badgeCount;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: ClosetColors.creme,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: iconSize, color: ClosetColors.noir),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              alignment: Alignment.center,
              child: Text(
                '$badgeCount',
                style: ClosetTextStyles.navigation.copyWith(
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
