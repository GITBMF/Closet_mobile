import 'package:flutter/material.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/frise_tunnel.dart';
import 'transaction_models.dart';
import 'widgets/transaction_scaffold.dart';

/// Traitement en cours — `32:756` pour le retrait, `162:5220` pour le paiement.
///
/// Grande icône de transaction, puis anneau de chargement en bas d'écran. Côté
/// acheteuse, la maquette ajoute la frise 3 étapes en tête et un libellé
/// « Paiement en cours » sous l'anneau.
///
/// L'écran est purement passif : il attend la fin de [operation] et bascule
/// ensuite sur [onTermine] ou [onEchec].
class TraitementScreen extends StatefulWidget {
  const TraitementScreen({
    super.key,
    required this.type,
    required this.operation,
    required this.onTermine,
    required this.onEchec,
  });

  final TypeOperation type;

  /// Traitement réel (appel au backend).
  final Future<void> Function() operation;

  final VoidCallback onTermine;
  final ValueChanged<Object> onEchec;

  @override
  State<TraitementScreen> createState() => _TraitementScreenState();
}

class _TraitementScreenState extends State<TraitementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _lancer());
  }

  Future<void> _lancer() async {
    try {
      await widget.operation();
      if (mounted) widget.onTermine();
    } catch (e) {
      if (mounted) widget.onEchec(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return TransactionScaffold(
      titre: widget.type.titreTraitement(l10n),
      entete: widget.type.afficheFrise
          ? const FriseTunnel(etapeCourante: 2, surFondSombre: true)
          : null,
      child: Column(
        children: [
          const SizedBox(height: 62),
          TexteTransaction(l10n.transactionPatientez),
          const SizedBox(height: 104),
          const Icon(
            Icons.swap_horiz_rounded,
            size: 86,
            color: ClosetColors.blanc,
          ),
          const Spacer(),
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: ClosetColors.blanc,
            ),
          ),
          if (widget.type.afficheFrise) ...[
            const SizedBox(height: AppSpacing.p12),
            Text(
              l10n.transactionTraitementPaiement,
              style: ClosetTextStyles.corps.copyWith(color: ClosetColors.beige),
            ),
          ],
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}

/// Écran de succès — `32:813` pour le retrait, `162:3351` pour le paiement.
///
/// Carte blanche en arche (217 × 275, coins supérieurs à 159) cerclée d'or,
/// coche verte, « C'est tout bon ! », puis deux boutons. Côté acheteuse, la
/// maquette ajoute la frise, le numéro de commande et la mention WhatsApp.
class SuccesScreen extends StatelessWidget {
  const SuccesScreen({
    super.key,
    required this.recu,
    required this.onVoirRecu,
    required this.onRetour,
  });

  final RecuTransaction recu;
  final VoidCallback onVoirRecu;
  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final type = recu.demande.type;

    return TransactionScaffold(
      titre: type.titreSucces(l10n),
      entete: type.afficheFrise
          ? const FriseTunnel(etapeCourante: 3, surFondSombre: true)
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 47),
            _ArcheSucces(
              legende: type == TypeOperation.paiement
                  ? l10n.transactionColisPreparation
                  : null,
            ),
            const SizedBox(height: AppSpacing.p20),
            if (recu.numeroCommande != null) ...[
              Text(
                l10n.transactionCommandeNumero(recu.numeroCommande!),
                style: ClosetTextStyles.libelleFort.copyWith(
                  color: ClosetColors.fond300,
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
            ],
            TexteTransaction(type.messageSucces(l10n)),
            if (type == TypeOperation.paiement) ...[
              const SizedBox(height: AppSpacing.p16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 14,
                    color: ClosetColors.emeraude100,
                  ),
                  const SizedBox(width: AppSpacing.gapChip),
                  Text(
                    l10n.transactionConfirmationWhatsapp,
                    style: ClosetTextStyles.meta.copyWith(
                      color: ClosetColors.emeraude100,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.p32),
            BoutonTransaction(label: l10n.transactionVoirRecu, onPressed: onVoirRecu),
            const SizedBox(height: AppSpacing.p24),
            BoutonTransaction(
              label: type.libelleSortie(l10n),
              dore: false,
              onPressed: onRetour,
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _ArcheSucces extends StatelessWidget {
  const _ArcheSucces({this.legende});

  /// Phrase inscrite sous « C'est tout bon ! » dans la variante acheteuse.
  final String? legende;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Container(
      width: 217,
      height: 275,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: ClosetColors.vert,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 44, color: ClosetColors.blanc),
          ),
          const Spacer(),
          Text(l10n.transactionToutBon, style: ClosetTextStyles.accroche),
          if (legende != null) ...[
            const SizedBox(height: AppSpacing.p8),
            Text(
              legende!,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.meta.copyWith(color: ClosetColors.taupe),
            ),
          ],
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
