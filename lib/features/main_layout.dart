import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/closet_colors.dart';
import '../../core/widgets/spotlight_showcase.dart';
import '../../data/repositories/cart_repository.dart';

/// Provider pour mémoriser si la visite guidée a déjà été affichée dans la session
class HasSeenTourNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markAsSeen() {
    state = true;
  }
}

final hasSeenTourProvider = NotifierProvider<HasSeenTourNotifier, bool>(() {
  return HasSeenTourNotifier();
});

class MainLayout extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasSeen = ref.read<bool>(hasSeenTourProvider);
      if (!hasSeen) {
        ref.read<HasSeenTourNotifier>(hasSeenTourProvider.notifier).markAsSeen();
        // Lance la démo interactive après une courte temporisation pour le confort visuel
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            ref.read<SpotlightTourNotifier>(spotlightTourProvider.notifier).startTour();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);

    final steps = [
      SpotlightStep(
        targetKey: ClosetTourKeys.searchKey,
        title: 'Recherche d\'Exception',
        description: 'Explorez et filtrez les pièces de créateurs soigneusement sélectionnées.',
        borderRadius: 22,
      ),
      SpotlightStep(
        targetKey: ClosetTourKeys.wishlistKey,
        title: 'Coups de Cœur',
        description: 'Enregistrez vos pépites préférées pour les retrouver à tout moment.',
        borderRadius: 22,
      ),
      SpotlightStep(
        targetKey: ClosetTourKeys.espaceKey,
        title: 'Mon Espace Closet',
        description: 'Pilotez vos informations client, ou basculez en mode Sourceur pour proposer vos dépôts.',
        borderRadius: 14,
      ),
    ];

    return SpotlightShowcase(
      steps: steps,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: ClosetColors.noir,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    index: 0,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'DRESSING',
                    onTap: () => _onTap(0),
                  ),
                  _NavItem(
                    index: 1,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view,
                    label: 'COLLECTIONS',
                    onTap: () => _onTap(1),
                  ),
                  _NavItem(
                    index: 2,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    label: 'WISHLIST',
                    onTap: () => _onTap(2),
                  ),
                  _NavItemWithBadge(
                    index: 3,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag,
                    label: 'SÉLECTION',
                    badge: cartCount,
                    onTap: () => _onTap(3),
                  ),
                  _NavItem(
                    key: ClosetTourKeys.espaceKey,
                    index: 4,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'ESPACE',
                    onTap: () => _onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? ClosetColors.dore : ClosetColors.navigationInactif,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color:
                    isSelected ? ClosetColors.dore : ClosetColors.navigationInactif,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemWithBadge extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  final VoidCallback onTap;

  const _NavItemWithBadge({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? ClosetColors.dore
                      : ClosetColors.navigationInactif,
                  size: 22,
                ),
                if (badge > 0)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: ClosetColors.vert,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: ClosetColors.creme,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color:
                    isSelected ? ClosetColors.dore : ClosetColors.navigationInactif,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
