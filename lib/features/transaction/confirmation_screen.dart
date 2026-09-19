import 'package:flutter/material.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/closet_app_bar.dart';
import '../../core/widgets/frise_tunnel.dart';
import 'transaction_models.dart';
import 'widgets/transaction_scaffold.dart';

/// Récapitulatif avant engagement — dernier point de sortie du tunnel.
///
/// [TraitementScreen] lance l'opération dès son montage, et le backend passe
/// aussitôt la main au fournisseur de paiement (`POST /payments/initiate`).
/// Au-delà de cet écran, plus rien n'est annulable côté application : c'est
/// donc ici, et seulement ici, que l'on peut renoncer.
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    super.key,
    required this.demande,
    required this.onConfirmer,
    required this.onAnnuler,
  });

  final DemandeTransaction demande;

  /// Engage l'opération. Irréversible.
  final VoidCallback onConfirmer;

  /// Renonce et rend la main à l'écran précédent.
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return TransactionScaffold(
      titre: demande.type.titreConfirmation(l10n),
      entete: demande.type.afficheFrise
          ? const FriseTunnel(etapeCourante: 2, surFondSombre: true)
          : null,
      child: Column(
        children: [
          const SizedBox(height: 44),
          TexteTransaction(demande.type.messageConfirmation(l10n)),
          const SizedBox(height: AppSpacing.p32),
          _Recapitulatif(demande: demande),
          const Spacer(),
          BoutonTransaction(
            label: demande.type.libelleConfirmer(l10n),
            onPressed: onConfirmer,
          ),
          const SizedBox(height: AppSpacing.p16),
          BoutonTransaction(
            label: l10n.retour,
            dore: false,
            onPressed: onAnnuler,
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}

/// Ce qui est sur le point d'être engagé : montant, moyen, compte.
class _Recapitulatif extends StatelessWidget {
  const _Recapitulatif({required this.demande});

  final DemandeTransaction demande;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      child: Column(
        children: [
          Text(
            formatPrixFcfa(demande.montant),
            style: ClosetTextStyles.montantHero.copyWith(
              color: ClosetColors.fond400,
            ),
          ),
          const SizedBox(height: AppSpacing.p4),
          Text(
            demande.type.libelleTotal(l10n),
            style: ClosetTextStyles.meta.copyWith(color: ClosetColors.beige),
          ),
          const SizedBox(height: AppSpacing.p24),
          if (demande.fraisLivraison > 0)
            _Ligne(
              label: l10n.transactionDontLivraison,
              valeur: formatPrixFcfa(demande.fraisLivraison),
            ),
          _Ligne(label: l10n.transactionMoyen, valeur: demande.moyen),
          // Jamais le numéro complet : cet écran peut être capturé.
          _Ligne(label: l10n.transactionCompte, valeur: demande.compteMasque),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({required this.label, required this.valeur});

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ClosetTextStyles.meta.copyWith(color: ClosetColors.beige),
          ),
          Flexible(
            child: Text(
              valeur,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: ClosetTextStyles.corps.copyWith(
                color: ClosetColors.blanc,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
