import 'package:flutter/material.dart';

import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import 'spotlight_showcase.dart';

/// Une entrée de la barre de navigation.
///
/// L'icône existe en deux versions : contour à l'état inactif, plein à
/// l'état actif — le même bascule que Dressing, Collections, Favoris et
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

/// Barre de navigation principale — cinq onglets toujours visibles.
///
/// La maquette `13:1182` dessine une pilule qui s'élargit avec le libellé
/// actif. Sur téléphone, « Mon Dressing » / « My Wardrobe » poussait le
/// cinquième onglet hors écran : l'accueil semblait n'avoir que 4 items.
/// Tous les onglets occupent donc la même largeur, avec icône + libellé,
/// cible tactile 48 dp.
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

  /// Pastilles de compte, indexées par position d'onglet.
  final Map<int, int> compteurs;

  /// Hauteur de la rangée d'onglets, hors inset système.
  static const double hauteurOnglets = 48;

  /// Entrées du parcours cliente.
  static List<ClosetNavItem> itemsClientePour(ClosetL10n l10n) => [
    ClosetNavItem(
      icone: Icons.home_outlined,
      iconeActive: Icons.home,
      label: l10n.navDressingCourt,
      cle: ClosetTourKeys.dressing,
    ),
    ClosetNavItem(
      icone: Icons.grid_view_outlined,
      iconeActive: Icons.grid_view,
      label: l10n.navCollections,
      cle: ClosetTourKeys.collections,
    ),
    ClosetNavItem(
      icone: Icons.favorite_border,
      iconeActive: Icons.favorite,
      label: l10n.navWishlist,
      cle: ClosetTourKeys.wishlist,
    ),
    ClosetNavItem(
      icone: Icons.shopping_bag_outlined,
      iconeActive: Icons.shopping_bag,
      label: l10n.navSelection,
      cle: ClosetTourKeys.selection,
    ),
    ClosetNavItem(
      icone: Icons.person_outline,
      iconeActive: Icons.person,
      label: l10n.navEspace,
      cle: ClosetTourKeys.espace,
    ),
  ];

  /// Entrées du parcours sourceur.
  static List<ClosetNavItem> itemsSourceurPour(ClosetL10n l10n) => [
    ClosetNavItem(
          icone: Icons.inventory_2_outlined,
          iconeActive: Icons.inventory_2,
          label: l10n.navDepotsCourt,
          cle: ClosetTourKeys.sourceurDepotsNavKey,
        ),
        ClosetNavItem(
          icone: Icons.add_circle_outline,
          iconeActive: Icons.add_circle,
          label: l10n.navConfier,
          cle: ClosetTourKeys.sourceurConfierNavKey,
        ),
        ClosetNavItem(
          icone: Icons.account_balance_wallet_outlined,
          iconeActive: Icons.account_balance_wallet,
          label: l10n.navGains,
          cle: ClosetTourKeys.sourceurGainsNavKey,
        ),
        ClosetNavItem(
          icone: Icons.person_outline,
          iconeActive: Icons.person,
          label: l10n.navEspace,
          cle: ClosetTourKeys.sourceurEspaceNavKey,
        ),
  ];

  /// Compatibilité tests / appels historiques (français).
  static List<ClosetNavItem> get itemsCliente =>
      itemsClientePour(ClosetL10n.fr);
  static List<ClosetNavItem> get itemsSourceur =>
      itemsSourceurPour(ClosetL10n.fr);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.1),
      ),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.p8,
              AppSpacing.p4,
              AppSpacing.p8,
              AppSpacing.p4,
            ),
            child: Container(
              key: ClosetTourKeys.barre,
              height: hauteurOnglets,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ClosetColors.navigationFond,
                borderRadius: BorderRadius.circular(AppRadius.cercle),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _Onglet(
                        key: items[i].cle,
                        item: items[i],
                        actif: i == indexActif,
                        compteur: compteurs[i],
                        onTap: onTap == null ? null : () => onTap!(i),
                      ),
                    ),
                ],
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
  });

  final ClosetNavItem item;
  final bool actif;
  final int? compteur;
  final VoidCallback? onTap;

  static const _tailleIcone = 20.0;

  @override
  Widget build(BuildContext context) {
    final couleur = actif
        ? ClosetColors.navigationActifTrait
        : ClosetColors.navigationInactif;

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
            top: -3,
            right: -5,
            child: Container(
              width: 12,
              height: 12,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ClosetColors.fond300,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$compteur',
                style: ClosetTextStyles.micro.copyWith(
                  fontSize: 8,
                  color: ClosetColors.emeraude500,
                  fontWeight: FontWeight.w800,
                  height: 1,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.cercle),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: actif
                  ? ClosetColors.navigationActifFond
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              border: actif
                  ? Border.all(
                      color: ClosetColors.navigationActifTrait,
                      width: AppStroke.fin,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icone,
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.navigation.copyWith(
                    fontSize: 9,
                    height: 1.1,
                    letterSpacing: 0,
                    color: actif
                        ? ClosetColors.navigationActifTexte
                        : ClosetColors.navigationInactif,
                    fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
