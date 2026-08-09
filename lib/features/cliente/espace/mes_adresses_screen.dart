import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/models/adresse.dart';
import '../../../data/repositories/adresse_repository.dart';
import '../../sourceur/widgets/sourceur_header.dart';

/// Mes adresses — transcription de la maquette `26:1588`.
///
/// Liste d'entrées à tuile verte de 48 : libellé, badge « par Défaut » sur
/// l'adresse retenue, puis l'adresse complète en gris.
class MesAdressesScreen extends ConsumerWidget {
  const MesAdressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adresses = ref.watch(mesAdressesProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
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
                  AppSpacing.p8,
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
                      onTap: () => _aVenir(context),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: adresses.when(
                data: (liste) => liste.isEmpty
                    ? const _AucuneAdresse()
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
                          onTap: () => _aVenir(context),
                        ),
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

  static void _aVenir(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestion des adresses bientôt disponible.')),
    );
  }
}

class _AucuneAdresse extends StatelessWidget {
  const _AucuneAdresse();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 48,
              color: ClosetColors.fond300,
            ),
            const SizedBox(height: AppSpacing.p20),
            Text(
              'Aucune adresse enregistrée',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              'Ajoutez une adresse pour accélérer vos prochaines commandes.',
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

/// Entrée d'adresse : tuile verte de 48, libellé, badge par défaut, adresse.
class _LigneAdresse extends StatelessWidget {
  const _LigneAdresse({required this.adresse, required this.onTap});

  final Adresse adresse;
  final VoidCallback onTap;

  IconData get _icone => switch (adresse.type) {
        TypeAdresse.maison => Icons.home_outlined,
        TypeAdresse.bureau => Icons.business_center_outlined,
        TypeAdresse.appartement => Icons.apartment_rounded,
        TypeAdresse.autre => Icons.place_outlined,
      };

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
            child: Icon(_icone, size: 20, color: Colors.white),
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
