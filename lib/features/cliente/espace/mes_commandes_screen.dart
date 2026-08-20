import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
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
    final commandes = ref.watch(mesCommandesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ClosetPageHeader(
              titre: 'Mes commandes',
              onRetour: () => context.pop(),
              action: SourceurBoutonRond(
                icone: Icons.notifications_none_rounded,
                label: 'Notifications',
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
                badgeStatutCommande(commande.statut),
              ],
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              ligneDateCommande(commande),
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
StatusBadge badgeStatutCommande(StatutCommande statut) => switch (statut) {
      StatutCommande.livree => StatusBadge.livree(),
      StatutCommande.enRoute => StatusBadge.enRoute(),
      StatutCommande.preparation ||
      StatutCommande.paid ||
      StatutCommande.pending =>
        StatusBadge.preparation(),
      StatutCommande.annulee => StatusBadge.refusee(),
      StatutCommande.devis => StatusBadge.enAnalyse(),
    };

/// « Déposé le… » pour une commande livrée, estimation sinon.
String ligneDateCommande(Commande c) {
  if (c.statut == StatutCommande.livree) {
    return 'Déposé le : ${formatDateCommande(c.dateDepot)}';
  }
  return c.estimation == null
      ? 'Temps d’estimation : En cours'
      : 'Temps d’estimation : ${formatDateCommande(c.estimation!)}';
}

/// Format de la maquette : « Mer 8 Juil, 15:30 ».
String formatDateCommande(DateTime d) {
  const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  const mois = [
    'Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]}, $hh:$mm';
}
