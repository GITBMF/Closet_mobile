import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../../checkout/widgets/checkout_widgets.dart';
import '../retrait/methode_retrait_sheet.dart';
import '../widgets/sourceur_header.dart';

/// Filtre de l'historique, derrière le bouton « Filtrer » de l'en-tête.
enum FiltreRetrait { tous, approuve, enCours, refuse }

extension on FiltreRetrait {
  String get libelle => switch (this) {
        FiltreRetrait.tous => 'Tous les mouvements',
        FiltreRetrait.approuve => 'Retraits approuvés',
        FiltreRetrait.enCours => 'Retraits en cours',
        FiltreRetrait.refuse => 'Retraits refusés',
      };

  bool accepte(RetraitSourceur r) => switch (this) {
        FiltreRetrait.tous => true,
        FiltreRetrait.approuve => r.statut == StatutRetrait.approuve,
        FiltreRetrait.enCours => r.statut == StatutRetrait.enCours,
        FiltreRetrait.refuse => r.statut == StatutRetrait.refuse,
      };
}

final filtreRetraitProvider = StateProvider<FiltreRetrait>(
  (ref) => FiltreRetrait.tous,
);

/// Historique de transaction — transcription de la maquette `32:1223`.
///
/// Ligne d'en-tête « Transactions » avec sa pastille « Voir tout », puis les
/// mouvements en cartes blanches de 350 × 74 cerclées d'or, chacune coiffée
/// d'une pastille verte de 36, et le CTA « Effectuer une transaction »
/// (`32:1348`) en pied d'écran.
class SourceurRevenusScreen extends ConsumerWidget {
  const SourceurRevenusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenus = ref.watch(revenusSourceurProvider);
    final filtre = ref.watch(filtreRetraitProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  onTap: () => _choisirFiltre(context, ref, filtre),
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
                data: (r) {
                  final lignes =
                      r.retraits.where(filtre.accepte).toList(growable: false);
                  return ListView(
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
                          _PastilleFiltre(
                            libelle: filtre == FiltreRetrait.tous
                                ? 'Voir tout'
                                : filtre.libelle,
                            onTap: () => _choisirFiltre(context, ref, filtre),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p20),
                      if (lignes.isEmpty)
                        const ClosetListeVide()
                      else
                        for (final retrait in lignes) ...[
                          _LigneTransaction(retrait: retrait),
                          const SizedBox(height: AppSpacing.p16),
                        ],
                      const SizedBox(height: AppSpacing.p16),
                      Center(
                        child: ClosetPrimaryButton(
                          label: 'Effectuer une transaction',
                          dore: true,
                          hauteur: AppSpacing.minTouchTarget,
                          onPressed: () => afficherMethodeRetrait(context),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () => ref.invalidate(revenusSourceurProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choisirFiltre(
    BuildContext context,
    WidgetRef ref,
    FiltreRetrait courant,
  ) async {
    final choix = await afficherSelecteur<FiltreRetrait>(
      context: context,
      titre: 'Filtrer les mouvements',
      options: FiltreRetrait.values,
      libelle: (f) => f.libelle,
      selection: courant,
    );
    if (choix != null) {
      ref.read(filtreRetraitProvider.notifier).state = choix;
    }
  }
}

/// Pastille « Voir tout » de la maquette, qui porte aussi le filtre actif.
class _PastilleFiltre extends StatelessWidget {
  const _PastilleFiltre({required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ClosetColors.neutre300,
      borderRadius: BorderRadius.circular(AppRadius.vignette),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.vignette),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p12,
            vertical: AppSpacing.p4,
          ),
          child: Text(
            libelle,
            style: ClosetTextStyles.attribut.copyWith(
              color: ClosetColors.neutre900,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mouvement : carte blanche 350 × 74, pastille verte de 36, montant retiré en
/// haut à droite et solde restant en dessous — les deux montants que la
/// maquette empile dans la colonne droite (`32:1146` / `32:1147`).
class _LigneTransaction extends StatelessWidget {
  const _LigneTransaction({required this.retrait});

  final RetraitSourceur retrait;

  @override
  Widget build(BuildContext context) {
    final refuse = retrait.statut == StatutRetrait.refuse;
    final couleurPastille =
        refuse ? ClosetColors.erreurCouture : ClosetColors.vert;

    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: AppSpacing.p12,
      ),
      decoration: BoxDecoration(
        color: ClosetColors.blanc,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: couleurPastille,
              shape: BoxShape.circle,
            ),
            child: Icon(
              refuse ? Icons.close_rounded : Icons.arrow_downward_rounded,
              size: 17,
              color: ClosetColors.blanc,
            ),
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  retrait.libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ClosetTextStyles.corpsMedium.copyWith(
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: AppSpacing.p4),
                Text(
                  '${refuse ? 'Demandé' : 'Retiré'} le '
                  '${formatDateCourte(retrait.date)}',
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPrixFcfa(retrait.montant),
                style: ClosetTextStyles.corpsMedium.copyWith(
                  letterSpacing: -0.24,
                  color: refuse ? ClosetColors.erreurCouture : ClosetColors.vert,
                ),
              ),
              if (!refuse) ...[
                const SizedBox(height: AppSpacing.p4),
                Text(
                  'Solde ${formatPrixFcfa(retrait.soldeApres)}',
                  style: ClosetTextStyles.actionPetite.copyWith(
                    letterSpacing: -0.20,
                    color: ClosetColors.champPlaceholder,
                  ),
                ),
              ],
            ],
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
