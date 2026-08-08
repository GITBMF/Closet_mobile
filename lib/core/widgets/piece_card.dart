import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Carte produit — transcription du composant « Product Card » de `11:30`.
///
/// 169 × 249, fond gris très clair `#F3F3F3` bordé `#E6E6E6`, rayon 8.
/// L'image occupe la partie haute sur toute la largeur ; le badge d'état est
/// posé en haut à gauche, le cœur en haut à droite dans un cercle blanc.
/// Sous l'image : maison en petites capitales dorées, nom en Cormorant
/// Garamond, prix en EB Garamond.
class PieceCard extends StatelessWidget {
  const PieceCard({
    super.key,
    required this.maison,
    required this.nom,
    required this.prix,
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
  final String? imageUrl;

  /// Image en arche (coins supérieurs très arrondis).
  final bool isImageArche;

  final String? statusBadgeText;
  final bool isFavorite;
  final bool isSold;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  /// Hauteur de la zone image dans la maquette.
  static const double _hauteurImage = 160;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ClosetColors.carteFond,
          border: Border.all(
            color: ClosetColors.carteBordure,
            width: AppStroke.fin,
          ),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Visuel(
              imageUrl: imageUrl,
              hauteur: _hauteurImage,
              arche: isImageArche,
              isSold: isSold,
              statusBadgeText: statusBadgeText,
              isFavorite: isFavorite,
              onFavoriteTap: onFavoriteTap,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.p8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    maison.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.microLegende.copyWith(
                      color: ClosetColors.dore,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.nomProduit,
                  ),
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    isSold ? 'Indisponible' : prix,
                    style: ClosetTextStyles.prix.copyWith(
                      color: isSold ? ClosetColors.taupe : ClosetColors.noir,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Visuel extends StatelessWidget {
  const _Visuel({
    required this.imageUrl,
    required this.hauteur,
    required this.arche,
    required this.isSold,
    required this.statusBadgeText,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final String? imageUrl;
  final double hauteur;
  final bool arche;
  final bool isSold;
  final String? statusBadgeText;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final rayon = arche
        ? const BorderRadius.vertical(top: Radius.circular(45))
        : const BorderRadius.vertical(top: Radius.circular(AppRadius.carte));

    return SizedBox(
      height: hauteur,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: rayon,
            child: imageUrl == null
                ? const ColoredBox(color: ClosetColors.beige)
                : CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    color: isSold ? Colors.black.withValues(alpha: 0.5) : null,
                    colorBlendMode: isSold ? BlendMode.darken : null,
                    placeholder: (context, url) =>
                        const ColoredBox(color: ClosetColors.ligne),
                    errorWidget: (context, url, error) => const ColoredBox(
                      color: ClosetColors.beige,
                      child: Icon(
                        Icons.image_not_supported,
                        color: ClosetColors.taupe,
                      ),
                    ),
                    fadeInDuration: const Duration(milliseconds: 250),
                  ),
          ),
          if (statusBadgeText != null && !isSold)
            Positioned(
              top: AppSpacing.p8,
              left: AppSpacing.p8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p12,
                  vertical: AppSpacing.p4,
                ),
                decoration: BoxDecoration(
                  color: ClosetColors.emeraude100,
                  borderRadius: BorderRadius.circular(AppRadius.vignette),
                ),
                child: Text(
                  statusBadgeText!.toUpperCase(),
                  style: ClosetTextStyles.attribut.copyWith(
                    color: ClosetColors.emeraude500,
                  ),
                ),
              ),
            ),
          if (!isSold)
            Positioned(
              top: AppSpacing.p8,
              right: AppSpacing.p8,
              child: Semantics(
                button: true,
                label: isFavorite
                    ? 'Retirer de la wishlist'
                    : 'Ajouter à la wishlist',
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? ClosetColors.erreurCouture
                          : ClosetColors.vertFonce,
                      size: 16,
                    ),
                  ),
                ),
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
      ),
    );
  }
}
