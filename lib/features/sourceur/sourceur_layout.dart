import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/closet_colors.dart';

class SourceurLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const SourceurLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor ?? ClosetColors.noir,
          boxShadow: const [
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
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront,
                  label: 'ATELIER',
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  index: 1,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: 'DÉPÔTS',
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  index: 2,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  label: 'CONFIER',
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  index: 3,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'GAINS',
                  onTap: () => _onTap(context, 3),
                ),
                _NavItem(
                  index: 4,
                  currentIndex: navigationShell.currentIndex,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'ESPACE',
                  onTap: () => _onTap(context, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
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
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = index == currentIndex;
    final selectedColor = theme.bottomNavigationBarTheme.selectedItemColor ?? ClosetColors.dore;
    final unselectedColor = theme.bottomNavigationBarTheme.unselectedItemColor ?? ClosetColors.navigationInactif;

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
              color: isSelected ? selectedColor : unselectedColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
