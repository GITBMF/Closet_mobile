import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/commande.dart';
import '../../../data/repositories/commande_repository.dart';
import '../../sourceur/widgets/sourceur_header.dart';

/// Mes commandes — transcription de la maquette `25:1089`.
///
/// Liste de cartes blanches 350 × 80 cerclées d'or : numéro de commande,
/// badge de statut, et date de dépôt ou estimation de livraison.
class MesCommandesScreen extends ConsumerWidget {
  const MesCommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final commandes = ref.watch(mesCommandesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ClosetPageHeader(
              titre: '',
              onRetour: () => context.pop(),
              action: SourceurBoutonRond(
                icone: Icons.notifications_none_rounded,
                label: l10n.notifications,
                onTap: () => context.push('/espace/alertes'),
              ),
            ),
            Expanded(
              child: commandes.when(
                data: (liste) => liste.isEmpty
                    ? const ClosetListeVide()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.p20,
                          35,
                          AppSpacing.p20,
                          AppSpacing.p32,
                        ),
                        itemCount: liste.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 13),
                        itemBuilder: (context, i) => _CarteCommande(
                          commande: liste[i],
                          onTap: () => context.push(
                            '/espace/commandes/${liste[i].numero}',
                          ),
                        ),
                      ),
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () => ref.invalidate(mesCommandesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de commande : 350 × 80, blanche cerclée d'or.
class _CarteCommande extends StatelessWidget {
  const _CarteCommande({required this.commande, required this.onTap});

  final Commande commande;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
        decoration: BoxDecoration(
          color: ClosetColors.blanc,
          border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'COMMANDE #${commande.numero}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.libelleFort.copyWith(
                      letterSpacing: -0.28,
                      color: ClosetColors.vert,
                    ),
                  ),
                ),
                badgeStatutCommande(commande.statut, l10n),
              ],
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              ligneDateCommande(commande, l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ClosetTextStyles.corps.copyWith(
                color: ClosetColors.neutre900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge correspondant au statut, d'après la maquette `26:1255`.
StatusBadge badgeStatutCommande(StatutCommande statut, ClosetL10n l10n) => switch (statut) {
      StatutCommande.livree => StatusBadge.livree(l10n.badgeLivree),
      StatutCommande.enRoute => StatusBadge.enRoute(l10n.badgeEnRoute),
      StatutCommande.preparation ||
      StatutCommande.paid ||
      StatutCommande.pending =>
        StatusBadge.preparation(l10n.badgePreparation),
      StatutCommande.annulee => StatusBadge.refusee(l10n.badgeRefusee),
      StatutCommande.devis => StatusBadge.enAnalyse(l10n.badgeEnAnalyse),
    };

/// « Déposé le… » pour une commande livrée, estimation sinon.
String ligneDateCommande(Commande c, ClosetL10n l10n) {
  if (c.statut == StatutCommande.livree) {
    return '${l10n.adhesionSoumiseLePrefix} : ${formatDateCommande(c.dateDepot)}';
  }
  return c.estimation == null
      ? '${l10n.tempsEstimationLabel} : ${l10n.tempsEstimationEnCours}'
      : '${l10n.tempsEstimationLabel} : ${formatDateCommande(c.estimation!)}';
}
