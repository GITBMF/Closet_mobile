import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
    ];

    return SpotlightShowcase(
      steps: steps,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: ClosetColors.vertFonce,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    index: 0,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Dressing',
                    onTap: () => _onTap(0),
                  ),
                  _NavItem(
                    index: 1,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view,
                    label: 'Collections',
                    onTap: () => _onTap(1),
                  ),
                  _NavItem(
                    index: 2,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    label: 'Cœurs',
                    onTap: () => _onTap(2),
                  ),
                  _NavItem(
                    index: 3,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.shopping_basket_outlined,
                    activeIcon: Icons.shopping_basket,
                    label: 'Sélection',
                    badge: cartCount,
                    onTap: () => _onTap(3),
                  ),
                  _NavItem(
                    index: 4,
                    currentIndex: widget.navigationShell.currentIndex,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Espace',
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
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? ClosetColors.dore : Colors.white.withValues(alpha: 0.65),
                  size: 20,
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: ClosetColors.dore,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: ClosetColors.vertFonce,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.lato(
                  color: ClosetColors.doreEncre,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

