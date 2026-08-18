import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/commande.dart';
import '../../../data/repositories/commande_repository.dart';
import 'detail_commande_screen.dart';
import 'espace_sub_screens.dart';

/// Mes commandes — liste des cartes de suivi.
class MesCommandesScreen extends ConsumerWidget {
  const MesCommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandes = ref.watch(mesCommandesProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: EspaceSubAppBar(
        title: 'Mes commandes',
        italicTitle: true,
        highlightTitle: true,
        onSettingsTap: () => context.push('/espace/confidentialite'),
      ),
      body: commandes.when(
        data: (liste) => liste.isEmpty
            ? const _AucuneCommande()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p24,
                  AppSpacing.p20,
                  AppSpacing.p32,
                ),
                itemCount: liste.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.p12),
                itemBuilder: (context, i) => _CarteCommande(
                  commande: liste[i],
                  onTap: () => afficherDetailCommande(context, liste[i].numero),
                ),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: ClosetColors.dore),
        ),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
      ),
    );
  }
}

class _AucuneCommande extends StatelessWidget {
  const _AucuneCommande();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: ClosetColors.fond300,
            ),
            const SizedBox(height: AppSpacing.p20),
            Text(
              'Aucune commande pour l’instant',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              'Vos commandes apparaîtront ici dès votre première pièce '
              'adoptée.',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.citation.copyWith(
                color: ClosetColors.taupe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: ClosetColors.carteBordure,
            width: AppStroke.fin,
          ),
          borderRadius: BorderRadius.circular(AppRadius.bloc),
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
                      color: ClosetColors.noir,
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
                color: ClosetColors.taupe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge correspondant au statut, libellé en capitales comme la maquette.
StatusBadge badgeStatutCommande(StatutCommande statut) => switch (statut) {
      StatutCommande.livree => StatusBadge.livree('LIVRÉE'),
      StatutCommande.enRoute => StatusBadge.enRoute('EN ROUTE'),
      StatutCommande.preparation => StatusBadge.preparation('PRÉPARATION'),
    };

/// « Déposé le… » pour une commande livrée, estimation sinon.
String ligneDateCommande(Commande c) {
  if (c.statut == StatutCommande.livree) {
    return 'Déposé le: ${formatDateCommande(c.dateDepot)}';
  }
  return c.estimation == null
      ? 'Temps d’estimation: En cours'
      : 'Temps d’estimation: ${formatDateCommande(c.estimation!)}';
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
