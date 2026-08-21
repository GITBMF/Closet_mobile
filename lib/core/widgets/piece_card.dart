import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Carte produit — transcription du composant « Product Card » de `11:30`.
///
/// 169 × 249, fond `#F3F3F3` bordé `#E6E6E6`, rayon 8. L'image est **encadrée**
/// (145 × 156, retrait de 12) et non pleine largeur. Sous l'image, quatre
/// lignes : maison en petites capitales dorées, nom en Cormorant Garamond,
/// prix en EB Garamond **vert**, puis les attributs en très petit.
class PieceCard extends StatelessWidget {
  const PieceCard({
    super.key,
    required this.maison,
    required this.nom,
    required this.prix,
    this.attribut,
    this.imageUrl,
    this.isImageArche = false,
    this.statusBadgeText,
    this.isFavorite = false,
    this.isSold = false,
    this.onFavoriteTap,
    this.onTap,
  });

  final String maison;
  final String nom;
  final String prix;

  /// Ligne d'attributs (« T.36. Laine. Tweed »). Absente = ligne masquée.
  final String? attribut;

  final String? imageUrl;

  /// Image en arche (coins supérieurs très arrondis).
  final bool isImageArche;

  final String? statusBadgeText;
  final bool isFavorite;
  final bool isSold;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  /// Retrait de l'image dans la carte, d'après la maquette.
  static const double _retrait = 12;

  /// Rapport largeur/hauteur de l'image dans la maquette (145 × 156).
  ///
  /// Sert de proportion **souhaitée**, pas imposée : l'image est élastique et
  /// cède de la hauteur au texte si la cellule est trop courte. Un ratio figé
  /// faisait déborder le prix dès que le nom passait sur deux lignes.
  static const double ratioImage = 145 / 156;

  /// Rapport largeur/hauteur d'une cellule de grille.
  ///
  /// La maquette dessine 169 × 249, mais ses tailles de police sont serrées :
  /// on prévoit un peu de hauteur en plus pour absorber un nom sur deux
  /// lignes ou un réglage d'accessibilité qui agrandit le texte.
  static const double ratioCarteGrille = 169 / 268;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.closetSombre
              ? ClosetColors.emeraude400
              : ClosetColors.carteFond,
          border: Border.all(
            color: context.closetSombre
                ? ClosetColors.emeraude300
                : ClosetColors.carteBordure,
            width: AppStroke.fin,
          ),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_retrait),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Visuel(
                  imageUrl: imageUrl,
                  arche: isImageArche,
                  isSold: isSold,
                  statusBadgeText: statusBadgeText,
                  isFavorite: isFavorite,
                  onFavoriteTap: onFavoriteTap,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                maison.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ClosetTextStyles.microLegende.copyWith(
                  color: ClosetColors.fond400,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                nom,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ClosetTextStyles.nomProduit,
              ),
              const SizedBox(height: 3),
              Text(
                isSold ? 'Indisponible' : prix,
                style: ClosetTextStyles.prix.copyWith(
                  color: isSold ? ClosetColors.taupe : ClosetColors.emeraude400,
                ),
              ),
              if (attribut != null) ...[
                const SizedBox(height: AppSpacing.p4),
                Text(
                  attribut!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.micro.copyWith(
                    color: ClosetColors.neutre600,
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

class _Visuel extends StatelessWidget {
  const _Visuel({
    required this.imageUrl,
    required this.arche,
    required this.isSold,
    required this.statusBadgeText,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final String? imageUrl;
  final bool arche;
  final bool isSold;
  final String? statusBadgeText;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final rayon = arche
        ? const BorderRadius.vertical(top: Radius.circular(45))
        : BorderRadius.circular(AppRadius.carte);

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: rayon,
          child: imageUrl == null
              ? const ColoredBox(color: ClosetColors.gabaritImageClair)
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  color: isSold ? Colors.black.withValues(alpha: 0.5) : null,
                  colorBlendMode: isSold ? BlendMode.darken : null,
                  placeholder: (context, url) =>
                      const ColoredBox(color: ClosetColors.gabaritImageClair),
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: ClosetColors.gabaritImageClair,
                    child: Icon(
                      Icons.image_not_supported,
                      color: ClosetColors.taupe,
                      size: 18,
                    ),
                  ),
                  fadeInDuration: const Duration(milliseconds: 250),
                ),
        ),
        if (statusBadgeText != null && !isSold)
          Positioned(
            top: AppSpacing.p12,
            left: AppSpacing.p4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: ClosetColors.emeraude100,
                borderRadius: BorderRadius.circular(AppRadius.vignette),
              ),
              child: Text(
                statusBadgeText!,
                style: ClosetTextStyles.attribut.copyWith(
                  color: ClosetColors.emeraude500,
                ),
              ),
            ),
          ),
        if (!isSold)
          Positioned(
            top: AppSpacing.p12,
            right: AppSpacing.p4,
            child: BoutonCoeur(
              actif: isFavorite,
              onTap: onFavoriteTap,
            ),
          ),
        if (isSold)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColoredBox(
              color: ClosetColors.vertFonce.withValues(alpha: 0.9),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.p4),
                child: Text(
                  'A trouvé son dressing',
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.detail.copyWith(
                    color: ClosetColors.creme,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bouton cœur de la maquette : disque clair cerclé d'or (`11:30` — Like
/// Button). Réutilisé sur la carte produit et sur la carte à la une.
class BoutonCoeur extends StatelessWidget {
  const BoutonCoeur({
    super.key,
    required this.actif,
    this.onTap,
    this.taille = 19,
  });

  final bool actif;
  final VoidCallback? onTap;
  final double taille;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: actif ? 'Retirer de la wishlist' : 'Ajouter à la wishlist',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: taille,
              height: taille,
              decoration: BoxDecoration(
                color: ClosetColors.carteFond,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ClosetColors.fond300,
                  width: AppStroke.fin,
                ),
              ),
              child: Icon(
                actif ? Icons.favorite : Icons.favorite_border,
                size: taille * 0.55,
                color: actif ? ClosetColors.erreurCouture : ClosetColors.vert,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
