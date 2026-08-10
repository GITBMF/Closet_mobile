import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Barre de navigation principale : Dressing, Collections, Wishlist,
/// Sélection, Espace.
///
/// Transcription de la maquette Figma `13:1182` : fond vert nuit à coins
/// supérieurs arrondis, **seul l'onglet actif porte son libellé** — il prend
/// la forme d'une pilule crème bordée d'or. Les quatre autres sont des icônes
/// en contour crème, sans texte.
class ClosetBottomNav extends StatelessWidget {
  const ClosetBottomNav({
    super.key,
    required this.indexActif,
    this.onTap,
    this.compteurSelection,
  });

  final int indexActif;
  final ValueChanged<int>? onTap;

  /// Pastille de compte sur l'onglet Sélection. `null` = aucune pastille
  /// (état par défaut de la maquette).
  final int? compteurSelection;

  static const _items = [
    (icone: Icons.home_rounded, label: 'Dressing'),
    (icone: Icons.grid_view_outlined, label: 'Collections'),
    (icone: Icons.favorite_border, label: 'Wishlist'),
    (icone: Icons.shopping_basket_outlined, label: 'Selection'),
    (icone: Icons.person_outline, label: 'Espace'),
  ];

  static const _indexSelection = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ClosetColors.vertFonce,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.p16,
        right: AppSpacing.p16,
        top: AppSpacing.p16,
        bottom: AppSpacing.p16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < _items.length; i++)
            _Onglet(
              icone: _items[i].icone,
              label: _items[i].label,
              actif: i == indexActif,
              compteur: i == _indexSelection ? compteurSelection : null,
              onTap: onTap == null ? null : () => onTap!(i),
            ),
        ],
      ),
    );
  }
}

class _Onglet extends StatelessWidget {
  const _Onglet({
    required this.icone,
    required this.label,
    required this.actif,
    required this.compteur,
    required this.onTap,
  });

  final IconData icone;
  final String label;
  final bool actif;
  final int? compteur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icone = Icon(
      this.icone,
      size: 22,
      color: actif ? ClosetColors.dore : ClosetColors.creme,
    );

    final contenu = compteur == null
        ? icone
        : Stack(
            clipBehavior: Clip.none,
            children: [
              icone,
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.p4),
                  decoration: const BoxDecoration(
                    color: ClosetColors.dore,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$compteur',
                    style: ClosetTextStyles.micro.copyWith(
                      color: ClosetColors.vertFonce,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      selected: actif,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.bouton),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: actif ? AppSpacing.p20 : AppSpacing.p12,
            vertical: AppSpacing.p12,
          ),
          decoration: BoxDecoration(
            color: actif ? ClosetColors.creme : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.bouton),
            border: actif
                ? Border.all(color: ClosetColors.dore, width: AppStroke.fin)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              contenu,
              if (actif) ...[
                const SizedBox(width: AppSpacing.p8),
                Text(
                  label,
                  style: ClosetTextStyles.navigation.copyWith(
                    color: ClosetColors.dore,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
