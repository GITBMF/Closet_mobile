import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/closet_app_bar.dart';
import '../../core/widgets/closet_filet.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/livraison_repository.dart';
import 'brouillon_commande.dart';

/// Devis de livraison de la commande en cours.
///
/// Il dépend de la ville retenue dans le brouillon : changer de ville change le
/// tarif, et l'option « Autre » le rend indéterminé.
final devisCourantProvider = Provider<AsyncValue<DevisLivraison>>((ref) {
  final villeId = ref.watch(brouillonCommandeProvider).villeIdPourDevis;
  return ref.watch(devisLivraisonProvider(villeId));
});

/// Montant à régler : sous-total − remise + livraison.
///
/// Indéterminé tant que la livraison est à devis : la maquette affiche alors
/// « A determiner » plutôt qu'un total faux (`162:5536`).
final totalAReglerProvider = Provider<double?>((ref) {
  final sousTotal = ref.watch(cartTotalProvider);
  final remise = ref.watch(brouillonCommandeProvider).remise;
  final devis = ref.watch(devisCourantProvider).value;
  if (devis == null || devis.aDeviser) return null;
  return sousTotal - remise + devis.montant;
});

/// Mention Figma `162:5119` sous le total.
const mentionReservationPiece =
    'Paiement chiffré. Votre pièce est réservée pendant 15 minutes.';

/// Récapitulatif des montants — maquette `16:3448` / `162:5119`.
///
/// Sous-total, remise éventuelle, livraison, puis total séparé par un filet
/// doré. Partagé entre la sélection et le checkout : les deux écrans doivent
/// annoncer le même total, et l'avoir en double invitait à la divergence.
class RecapMontants extends ConsumerWidget {
  const RecapMontants({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final sousTotal = ref.watch(cartTotalProvider);
    final remise = ref.watch(brouillonCommandeProvider).remise;
    final devis = ref.watch(devisCourantProvider);
    final total = ref.watch(totalAReglerProvider);

    return Column(
      children: [
        LigneMontant(label: l10n.sousTotalLabel, valeur: formatPrixFcfa(sousTotal)),
        if (remise > 0) ...[
          const SizedBox(height: AppSpacing.p20),
          LigneMontant(
            label: l10n.checkoutRecuCodePrivilege,
            valeur: '- ${formatPrixFcfa(remise)}',
          ),
        ],
        const SizedBox(height: AppSpacing.p20),
        LigneMontant(
          label: l10n.livraisonDelicate,
          valeur: switch (devis) {
            AsyncData(:final value) =>
              value.aDeviser ? l10n.aDeterminer : formatPrixFcfa(value.montant),
            AsyncError() => l10n.indisponibleLabel,
            _ => '…',
          },
        ),
        const SizedBox(height: AppSpacing.p16),
        const ClosetFilet(couleur: ClosetColors.fond400),
        const SizedBox(height: AppSpacing.p16),
        LigneMontant(
          label: l10n.totalARegler,
          valeur: total == null ? l10n.aDeterminer : formatPrixFcfa(total),
          couleurLabel: context.closetEncre,
          grand: true,
        ),
        const SizedBox(height: AppSpacing.p12),
        Text(
          mentionReservationPiece,
          style: ClosetTextStyles.mention.copyWith(
            color: ClosetColors.taupe,
          ),
        ),
      ],
    );
  }
}

/// Une ligne du récapitulatif : libellé capitalisé à gauche, montant à droite.
class LigneMontant extends StatelessWidget {
  const LigneMontant({
    super.key,
    required this.label,
    required this.valeur,
    this.couleurLabel = ClosetColors.fond500,
    this.grand = false,
  });

  final String label;
  final String valeur;
  final Color couleurLabel;
  final bool grand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label.toUpperCase(),
          style: ClosetTextStyles.meta.copyWith(color: couleurLabel),
        ),
        Text(
          valeur,
          style: grand
              ? ClosetTextStyles.prixGrand.copyWith(color: ClosetColors.vert)
              : ClosetTextStyles.prix.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.30,
                  color: ClosetColors.vert,
                ),
        ),
      ],
    );
  }
}
