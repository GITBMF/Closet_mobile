import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../data/models/adresse.dart';
import '../../../data/repositories/adresse_repository.dart';
import '../../sourceur/widgets/sourceur_header.dart';
import 'adresse_sheet.dart';

/// Mes adresses — liste des adresses enregistrées.
class MesAdressesScreen extends ConsumerWidget {
  const MesAdressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adresses = ref.watch(mesAdressesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ClosetColors.fond400,
                    width: AppStroke.fin,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p24,
                  AppSpacing.p20,
                  AppSpacing.p12,
                ),
                child: Row(
                  children: [
                    SourceurBoutonRond(
                      icone: Icons.arrow_back_ios_new,
                      label: 'Retour',
                      onTap: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Mes adresses',
                        textAlign: TextAlign.center,
                        style: ClosetTextStyles.accroche.copyWith(
                          fontFamily: ClosetTextStyles.prix.fontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.36,
                          color: ClosetColors.noir,
                        ),
                      ),
                    ),
                    SourceurBoutonRond(
                      icone: Icons.add,
                      label: 'Ajouter une adresse',
                      onTap: () => _ouvrirFormulaire(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: adresses.when(
                data: (liste) => liste.isEmpty
                    ? ClosetListeVide(
                        action: () => _ouvrirFormulaire(context, ref),
                        libelleAction: 'Ajouter une adresse',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          23,
                          58,
                          23,
                          AppSpacing.p32,
                        ),
                        itemCount: liste.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 49),
                        itemBuilder: (context, i) => _LigneAdresse(
                          adresse: liste[i],
                          onTap: () => _ouvrirFormulaire(
                            context,
                            ref,
                            adresse: liste[i],
                          ),
                        ),
                      ),
                loading: () => const EtatEcran.chargement(),
                error: (e, _) => EtatEcran.erreur(
                  erreur: e,
                  onRetry: () => ref.invalidate(mesAdressesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ouvre le formulaire puis rafraîchit la liste si quelque chose a changé.
  static Future<void> _ouvrirFormulaire(
    BuildContext context,
    WidgetRef ref, {
    Adresse? adresse,
  }) async {
    final modifie =
        await afficherFormulaireAdresse(context, adresse: adresse);
    if (modifie) ref.invalidate(mesAdressesProvider);
  }
}

class _LigneAdresse extends StatelessWidget {
  const _LigneAdresse({required this.adresse, required this.onEditer});

  final Adresse adresse;
  final VoidCallback onEditer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ClosetColors.vert,
              borderRadius: BorderRadius.circular(AppRadius.carte),
            ),
            child: Icon(_icone, size: 20, color: ClosetColors.blanc),
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        adresse.libelle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ClosetTextStyles.libelle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (adresse.parDefaut) ...[
                      const SizedBox(width: AppSpacing.p12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.p12,
                          vertical: AppSpacing.p4,
                        ),
                        decoration: BoxDecoration(
                          color: ClosetColors.emeraude100,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          'par Défaut',
                          style: ClosetTextStyles.attribut.copyWith(
                            color: ClosetColors.emeraude500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.p8),
                Text(
                  adresse.ligne,
                  style: ClosetTextStyles.libelle.copyWith(
                    color: ClosetColors.pinTexte,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
