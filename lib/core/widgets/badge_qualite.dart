import 'package:flutter/material.dart';

import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Pastille « Qualité vérifiée » — confiance sur la fiche et au paiement.
class BadgeQualiteVerifiee extends StatelessWidget {
  const BadgeQualiteVerifiee({
    super.key,
    this.surPhoto = false,
    this.etendu = false,
  });

  /// Sur une photo : fond semi-opaque, texte crème.
  final bool surPhoto;

  /// Bandeau de checkout : icône + titre + courte mention.
  final bool etendu;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final fond = surPhoto
        ? ClosetColors.vert.withValues(alpha: 0.88)
        : ClosetColors.emeraude100;
    final encre = surPhoto ? ClosetColors.creme : ClosetColors.emeraude500;

    if (etendu) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.closetSombre
              ? ClosetColors.emeraude400
              : ClosetColors.emeraude100.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(AppRadius.carte),
          border: Border.all(
            color: ClosetColors.emeraude200,
            width: AppStroke.filet,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p12,
            vertical: AppSpacing.p12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 20,
                color: ClosetColors.vert,
              ),
              const SizedBox(width: AppSpacing.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.qualiteVerifiee,
                      style: ClosetTextStyles.libelleFort.copyWith(
                        color: context.closetEncre,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.qualiteVerifieeDetail,
                      style: ClosetTextStyles.meta.copyWith(
                        color: context.closetSecondaire,
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(AppRadius.vignette),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p8,
          vertical: AppSpacing.p4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 13, color: encre),
            const SizedBox(width: 4),
            Text(
              l10n.qualiteVerifiee,
              style: ClosetTextStyles.attribut.copyWith(
                color: encre,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compteur de favoris visible (ex. « 581 ») à côté du cœur.
class CompteurFavoris extends StatelessWidget {
  const CompteurFavoris({
    super.key,
    required this.nombre,
    this.actif = false,
    this.surPhoto = false,
  });

  final int nombre;
  final bool actif;
  final bool surPhoto;

  @override
  Widget build(BuildContext context) {
    final encre = surPhoto
        ? ClosetColors.creme
        : (actif ? ClosetColors.erreurCouture : context.closetEncre);
    final fond = surPhoto
        ? ClosetColors.vert.withValues(alpha: 0.82)
        : Colors.transparent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(AppRadius.vignette),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: surPhoto ? AppSpacing.p8 : 0,
          vertical: surPhoto ? AppSpacing.p4 : 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              actif ? Icons.favorite : Icons.favorite_border,
              size: surPhoto ? 12 : 14,
              color: encre,
            ),
            const SizedBox(width: 3),
            Text(
              formatCompteurFavoris(nombre),
              style: ClosetTextStyles.attribut.copyWith(
                color: encre,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 581, puis 1,2 k au-delà de 999.
String formatCompteurFavoris(int n) {
  if (n < 1000) return '$n';
  final dixiemes = (n / 100).round() / 10;
  if (dixiemes == dixiemes.roundToDouble()) {
    return '${dixiemes.round()} k';
  }
  return '${dixiemes.toStringAsFixed(1).replaceAll('.', ',')} k';
}
