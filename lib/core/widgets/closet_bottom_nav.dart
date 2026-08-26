import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_layout.dart';
import '../theme/closet_text_styles.dart';

/// Une entrée de la barre de navigation.
///
/// L'icône existe en deux versions : contour à l'état inactif, plein à
/// l'état actif — le même bascule que Dressing, Collections, Wishlist et
/// Espace. Selection utilise le sac Material (`shopping_bag`), pas le
/// panier (`shopping_basket`), pour garder le même trait que les autres.
class ClosetNavItem {
  const ClosetNavItem({
    required this.icone,
    required this.iconeActive,
    required this.label,
    this.cle,
  });

  final IconData icone;
  final IconData iconeActive;
  final String label;

  /// Clé posée sur l'onglet, pour que la visite guidée puisse le cibler.
  final Key? cle;
}

/// Barre de navigation principale — transcription de la maquette `13:1182`.
///
/// Relevé calque par calque des cinq variantes de la maquette :
///
/// - la barre est une **pilule** `#1C382D` de 58 px, `r100`, padding 8,
///   écart 20 entre onglets, **dont la largeur s'ajuste au contenu** ;
/// - un onglet inactif est un carré de 42 (padding 11 autour d'une icône de
///   20) sans fond, icône tracée en blanc ;
/// - **seul l'onglet actif porte son libellé** : il devient une pilule
///   `#F3F3F3` bordée `#CDAB71`, `r36.67`, écart 4 entre icône et texte,
///   icône `#CDAB71` et libellé `#B58A40` en Lato 500 / 12 pt.
///
/// Les icônes de la maquette proviennent de quatre jeux Iconify distincts
/// (`fa7-solid`, `icon-park-outline`, `mage`, `solar`) ; aucune librairie du
/// projet ne les couvre toutes et le dump Figma ne permet pas d'exporter les
/// SVG. Les paires Material retenues ci-dessous reproduisent la bascule
/// contour/plein de la maquette, à défaut du tracé exact.
class ClosetBottomNav extends StatelessWidget {
  const ClosetBottomNav({
    super.key,
    required this.items,
    required this.indexActif,
    this.onTap,
    this.compteurs = const {},
  });

  /// Entrées de la barre, dans l'ordre d'affichage.
  final List<ClosetNavItem> items;

  final int indexActif;
  final ValueChanged<int>? onTap;

  /// Pastilles de compte, indexées par position d'onglet. Une valeur nulle ou
  /// à zéro n'affiche rien — c'est l'état de la maquette, qui ne montre aucune
  /// pastille sur ses cinq variantes.
  final Map<int, int> compteurs;

  /// Entrées du parcours cliente, libellées comme la maquette — qui écrit bien
  /// « Wishlist » et « Selection », sans accent.
  static const itemsCliente = [
    ClosetNavItem(
      icone: Icons.home_outlined,
      iconeActive: Icons.home,
      label: 'Dressing',
    ),
    ClosetNavItem(
      icone: Icons.grid_view_outlined,
      iconeActive: Icons.grid_view,
      label: 'Collections',
    ),
    ClosetNavItem(
      icone: Icons.favorite_border,
      iconeActive: Icons.favorite,
      label: 'Wishlist',
    ),
    ClosetNavItem(
      icone: Icons.shopping_bag_outlined,
      iconeActive: Icons.shopping_bag,
      label: 'Selection',
    ),
    ClosetNavItem(
      icone: Icons.person_outline,
      iconeActive: Icons.person,
      label: 'Espace',
    ),
  ];

  /// Entrées du parcours sourceur. La maquette ne décrit pas de barre pour cet
  /// espace : la géométrie est reprise du composant cliente, seules les
  /// entrées changent.
  static const itemsSourceur = [
    ClosetNavItem(
      icone: Icons.storefront_outlined,
      iconeActive: Icons.storefront,
      label: 'Espace',
    ),
    ClosetNavItem(
      icone: Icons.inventory_2_outlined,
      iconeActive: Icons.inventory_2,
      label: 'Dépôts',
    ),
    ClosetNavItem(
      icone: Icons.add_circle_outline,
      iconeActive: Icons.add_circle,
      label: 'Confier',
    ),
    ClosetNavItem(
      icone: Icons.account_balance_wallet_outlined,
      iconeActive: Icons.account_balance_wallet,
      label: 'Gains',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final layout = ClosetLayout.of(context);
    final ecartOnglets = layout.compact ? AppSpacing.p8 : AppSpacing.p20;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p8),
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.p8),
                decoration: BoxDecoration(
                  color: ClosetColors.navigationFond,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) SizedBox(width: ecartOnglets),
                      _Onglet(
                        key: items[i].cle,
                        item: items[i],
                        actif: i == indexActif,
                        compteur: compteurs[i],
                        onTap: onTap == null ? null : () => onTap!(i),
                        compact: layout.compact,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Onglet extends StatelessWidget {
  const _Onglet({
    super.key,
    required this.item,
    required this.actif,
    required this.compteur,
    required this.onTap,
    this.compact = false,
  });

  final ClosetNavItem item;
  final bool actif;
  final int? compteur;
  final VoidCallback? onTap;
  final bool compact;

  /// Taille des icônes de la maquette : 20 px dans un cadre de 42.
  static const _tailleIcone = 20.0;

  @override
  Widget build(BuildContext context) {
    final couleur =
        actif ? ClosetColors.navigationActifTrait : ClosetColors.navigationInactif;

    Widget icone = Icon(
      actif ? item.iconeActive : item.icone,
      size: _tailleIcone,
      color: couleur,
    );

    if (compteur != null && compteur! > 0) {
      icone = Stack(
        clipBehavior: Clip.none,
        children: [
          icone,
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ClosetColors.fond300,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$compteur',
                style: ClosetTextStyles.micro.copyWith(
                  color: ClosetColors.emeraude500,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      selected: actif,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.carteProduit),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(
            compact ? AppSpacing.p8 : AppSpacing.gouttiere,
          ),
          decoration: BoxDecoration(
            color: actif ? ClosetColors.navigationActifFond : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.carteProduit),
            border: actif
                ? Border.all(
                    color: ClosetColors.navigationActifTrait,
                    width: AppStroke.fin,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icone,
              if (actif) ...[
                const SizedBox(width: AppSpacing.p4),
                Text(
                  item.label,
                  style: ClosetTextStyles.navigation.copyWith(
                    color: ClosetColors.navigationActifTexte,
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
