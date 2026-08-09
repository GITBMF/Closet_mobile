import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_header.dart';

/// Historique de transaction — transcription de la maquette `32:1223`.
///
/// Ligne d'en-tête « Transactions » avec sa pastille « Voir tout », puis les
/// mouvements en cartes blanches de 350 × 74 cerclées d'or, chacune coiffée
/// d'une pastille verte de 36.
class SourceurRevenusScreen extends ConsumerWidget {
  const SourceurRevenusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenus = ref.watch(revenusSourceurProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            SourceurHeader(
              titre: 'Historique',
              onRetour: () => context.go('/sourceur/espace'),
              actions: [
                SourceurBoutonRond(
                  icone: Icons.tune,
                  label: 'Filtrer',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtres à venir.')),
                  ),
                ),
                const SizedBox(width: AppSpacing.gapListe),
                SourceurBoutonRond(
                  icone: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => context.push('/espace/alertes'),
                ),
              ],
            ),
            Expanded(
              child: revenus.when(
                data: (r) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.p20,
                    29,
                    AppSpacing.p20,
                    AppSpacing.p32,
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transactions',
                          style: ClosetTextStyles.corpsMedium.copyWith(
                            letterSpacing: -0.24,
                            color: ClosetColors.vert,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p12,
                            vertical: AppSpacing.p4,
                          ),
                          decoration: BoxDecoration(
                            color: ClosetColors.neutre300,
                            borderRadius:
                                BorderRadius.circular(AppRadius.vignette),
                          ),
                          child: Text(
                            'Voir tout',
                            style: ClosetTextStyles.attribut.copyWith(
                              color: ClosetColors.neutre900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    if (r.historique.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'Aucun mouvement pour l’instant.',
                            style: ClosetTextStyles.citation.copyWith(
                              color: ClosetColors.taupe,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final vente in r.historique) ...[
                        _LigneTransaction(vente: vente),
                        const SizedBox(height: AppSpacing.p16),
                      ],
                  ],
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: ClosetColors.dore),
                ),
                error: (e, _) => const Center(
                  child: Text('Erreur de chargement'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mouvement : carte blanche 350 × 74, pastille verte de 36, montant à droite.
class _LigneTransaction extends StatelessWidget {
  const _LigneTransaction({required this.vente});

  final VenteSourceur vente;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: ClosetColors.vert,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              size: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vente.nomPiece,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.corpsMedium.copyWith(
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: AppSpacing.p4),
                Text(
                  'Vendue le ${formatDateCourte(vente.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.actionPetite.copyWith(
                    letterSpacing: -0.20,
                    color: ClosetColors.champPlaceholder,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.p8),
          Text(
            formatPrixFcfa(vente.montant),
            style: ClosetTextStyles.corpsMedium.copyWith(
              letterSpacing: -0.24,
              color: ClosetColors.vert,
            ),
          ),
        ],
      ),
    );
  }
}

/// Date au format de la maquette : « Lun 10 Jui 2026, 10:30 ».
String formatDateCourte(DateTime d) {
  const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  const mois = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]} ${d.year}, '
      '$hh:$mm';
}
