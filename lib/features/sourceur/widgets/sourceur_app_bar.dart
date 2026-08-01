import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/theme_provider.dart';

class SourceurAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const SourceurAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
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
                child: Text(
                  'C',
                  style: TextStyle(
                    color: ClosetColors.creme,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceColor,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  subtitle ?? 'CERCLE DES SOURCEURS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
                    color: isDark ? ClosetColors.doreClair : ClosetColors.dore,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.account_balance_wallet_outlined, size: 22),
          color: onSurfaceColor,
          onPressed: () => context.go('/sourceur/revenus'),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, size: 22),
          color: onSurfaceColor,
          onPressed: () => context.go('/sourceur/espace'),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: theme.dividerColor.withValues(alpha: 0.15),
          height: 1,
        ),
      ),
    );
  }
}
