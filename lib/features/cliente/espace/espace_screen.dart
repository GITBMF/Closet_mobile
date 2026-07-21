import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/cart_repository.dart';

class EspaceScreen extends ConsumerWidget {
  const EspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          // ── Hero Profile Header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.forestGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mon espace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/auth'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border:
                              Border.all(color: AppTheme.goldCloset, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'C',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Invité(e)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connectez-vous pour accéder à votre dressing privé',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip(label: 'Sélection', value: '$cartCount'),
                          Container(
                              height: 30, width: 1,
                              color: Colors.white.withValues(alpha: 0.2)),
                          const _StatChip(label: 'Wishlist', value: '2'),
                          Container(
                              height: 30, width: 1,
                              color: Colors.white.withValues(alpha: 0.2)),
                          const _StatChip(label: 'Commandes', value: '0'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Menu Sections ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _MenuSection(
                    title: 'MON DRESSING',
                    items: [
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Ma sélection',
                        badge: cartCount > 0 ? '$cartCount' : null,
                        onTap: () => context.go('/selection'),
                      ),
                      _MenuItem(
                        icon: Icons.favorite_border,
                        label: 'Ma wishlist',
                        badge: '2',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.history,
                        label: 'Mes commandes',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.local_shipping_outlined,
                        label: 'Suivi de livraison',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _MenuSection(
                    title: 'MON COMPTE',
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: 'Mes informations',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        label: 'Mes adresses',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.credit_card_outlined,
                        label: 'Mes moyens de paiement',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.notifications_none,
                        label: 'Mes alertes pièces',
                        badge: '3',
                        badgeColor: AppTheme.forestGreen,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _MenuSection(
                    title: 'ESPACE SOURCEUR',
                    items: [
                      _MenuItem(
                        icon: Icons.add_circle_outline,
                        label: 'Soumettre une pièce',
                        onTap: () {},
                        isHighlighted: true,
                      ),
                      _MenuItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Mes pièces soumises',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _MenuSection(
                    title: 'ASSISTANCE',
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline,
                        label: 'FAQ & aide',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'Nous contacter',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Politique de confidentialité',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Footer
                  const Center(
                    child: Text(
                      'CLOS ET · ABIDJAN — PARIS — YAOUNDÉ',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 2.5,
                        color: AppTheme.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Menu Section ─────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.greyText,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.warmCream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.sandBeige),
          ),
          child: Column(
            children: items
                .map((item) => item)
                .toList()
                .asMap()
                .entries
                .map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 54,
                      endIndent: 16,
                      color: AppTheme.sandBeige,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Menu Item ────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppTheme.forestGreen.withValues(alpha: 0.1)
                    : AppTheme.sandBeige.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 17,
                color: isHighlighted
                    ? AppTheme.forestGreen
                    : AppTheme.blackCloset,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isHighlighted ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlighted
                      ? AppTheme.forestGreen
                      : AppTheme.blackCloset,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppTheme.goldCloset).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? AppTheme.goldCloset,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppTheme.greyText,
            ),
          ],
        ),
      ),
    );
  }
}
