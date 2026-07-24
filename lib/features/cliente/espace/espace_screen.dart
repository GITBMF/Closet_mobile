import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';

class EspaceScreen extends ConsumerWidget {
  const EspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch<int>(cartCountProvider);
    final wishlistCount = ref.watch(wishlistListProvider).length;
    final ClosetUser? user = ref.watch<ClosetUser?>(currentUserProvider);
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    final isDark = ref.watch<ThemeMode>(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero Profile Header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                border: Border.all(color: theme.colorScheme.primary, width: 1.5),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mon espace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: onSurfaceColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (user != null) {
                                // Logout
                                ref.read(currentUserProvider.notifier).state = null;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vous avez été déconnecté.')),
                                );
                              } else {
                                // Login
                                context.push('/auth');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user != null ? 'Se déconnecter' : 'Se connecter',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Avatar: Initials if authenticated, logo otherwise
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user != null ? theme.colorScheme.primary : theme.colorScheme.surface,
                          border: Border.all(color: theme.colorScheme.secondary, width: 2),
                        ),
                        child: user != null
                            ? Center(
                                child: Text(
                                  user.initials,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onPrimary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              )
                            : ClipOval(
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Text(
                                      'C',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: ClosetColors.dore,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user != null ? '${user.firstName} ${user.lastName}' : 'Invité(e)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user != null ? user.email : 'Connectez-vous pour accéder à votre dressing privé',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurfaceColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip(label: 'Sélection', value: '$cartCount', color: onSurfaceColor),
                          Container(height: 30, width: 1, color: onSurfaceColor.withValues(alpha: 0.2)),
                          _StatChip(label: 'Wishlist', value: '$wishlistCount', color: onSurfaceColor),
                          Container(height: 30, width: 1, color: onSurfaceColor.withValues(alpha: 0.2)),
                          _StatChip(label: 'Commandes', value: user != null ? '1' : '0', color: onSurfaceColor),
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
                  
                  // PRÉFÉRENCES (Dark Mode switch)
                  _MenuSection(
                    title: 'PRÉFÉRENCES',
                    items: [
                      _MenuItem(
                        icon: Icons.dark_mode_outlined,
                        label: 'Mode sombre',
                        onTap: () {
                          ref.read<ThemeModeNotifier>(themeModeProvider.notifier).toggleTheme();
                        },
                        trailing: Switch(
                          value: isDark,
                          activeThumbColor: theme.colorScheme.secondary,
                          onChanged: (value) {
                            ref.read<ThemeModeNotifier>(themeModeProvider.notifier).toggleTheme();
                          },
                        ),
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
                        badgeColor: theme.colorScheme.primary,
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
                        onTap: () {
                          final sourceurRepo = ref.read(sourceurRepositoryProvider);
                          if (sourceurRepo.estInscrit) {
                            context.push('/sourceur/nouvelle');
                          } else {
                            context.push('/sourceur/inscription');
                          }
                        },
                        isHighlighted: true,
                      ),
                      _MenuItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Mes pièces soumises',
                        onTap: () => context.push('/sourceur/pieces'),
                      ),
                      _MenuItem(
                        icon: Icons.storefront_outlined,
                        label: 'Mon atelier sourceur',
                        onTap: () => context.push('/sourceur'),
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
                  Center(
                    child: Text(
                      'CLOS ET · YAOUNDÉ — DOUALA · CAMEROUN',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 2.5,
                        color: onSurfaceColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: onSurfaceColor.withValues(alpha: 0.5),
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
  final Color color;
  
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color.withValues(alpha: 0.7),
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
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: onSurfaceColor.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 54,
                      endIndent: 16,
                      color: theme.dividerColor.withValues(alpha: 0.2),
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
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.isHighlighted = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: trailing != null ? null : onTap,
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
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 17,
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : onSurface,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlighted ? theme.colorScheme.primary : onSurface,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? theme.colorScheme.secondary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? theme.colorScheme.secondary,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            trailing ?? Icon(
              Icons.chevron_right,
              size: 18,
              color: onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
