import 'package:flutter/material.dart';

import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Barre de navigation principale : Dressing, Collections, Wishlist,
/// Sélection, Espace. L'onglet actif est doré.
class ClosetBottomNav extends StatelessWidget {
  const ClosetBottomNav({
    super.key,
    required this.indexActif,
    this.onTap,
  });

  final int indexActif;
  final ValueChanged<int>? onTap;

  static const _items = [
    (icone: Icons.home_outlined, label: 'DRESSING'),
    (icone: Icons.grid_view_outlined, label: 'COLLECTIONS'),
    (icone: Icons.favorite_border, label: 'WISHLIST'),
    (icone: Icons.shopping_bag_outlined, label: 'SÉLECTION'),
    (icone: Icons.person_outline, label: 'ESPACE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ClosetColors.noir,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: 14 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: InkWell(
                onTap: onTap == null ? null : () => onTap!(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _items[i].icone,
                      size: 24,
                      color: i == indexActif
                          ? ClosetColors.dore
                          : ClosetColors.texteSurVert,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _items[i].label,
                      style: ClosetTextStyles.navigation.copyWith(
                        color: i == indexActif
                            ? ClosetColors.dore
                            : ClosetColors.texteSurVert,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
