import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/models/adresse.dart';
import '../../../data/repositories/adresse_repository.dart';
import 'espace_sub_screens.dart';

/// Mes adresses — liste des adresses enregistrées.
class MesAdressesScreen extends ConsumerWidget {
  const MesAdressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adresses = ref.watch(mesAdressesProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: EspaceSubAppBar(
        title: 'Mes adresses',
        italicTitle: true,
        onSettingsTap: () => context.push('/espace/confidentialite'),
      ),
      body: adresses.when(
        data: (liste) => liste.isEmpty
            ? const _AucuneAdresse()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p24,
                  AppSpacing.p20,
                  AppSpacing.p32,
                ),
                itemCount: liste.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.p24),
                itemBuilder: (context, i) => _LigneAdresse(
                  adresse: liste[i],
                  onEditer: () => _aVenir(context),
                ),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: ClosetColors.dore),
        ),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
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

/// Tuile pin verte, libellé, badge par défaut, adresse, crayon doré.
class _LigneAdresse extends StatelessWidget {
  const _LigneAdresse({required this.adresse, required this.onEditer});

  final Adresse adresse;
  final VoidCallback onEditer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ClosetColors.vert,
            borderRadius: BorderRadius.circular(AppRadius.carte),
          ),
          child: const Icon(
            Icons.location_on,
            size: 22,
            color: Colors.white,
          ),
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
                      style: ClosetTextStyles.libelleFort.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (adresse.parDefaut) ...[
                    const SizedBox(width: AppSpacing.p8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ClosetColors.emeraude100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'PAR DÉFAUT',
                        style: ClosetTextStyles.micro.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                adresse.ligne,
                style: ClosetTextStyles.corps.copyWith(
                  color: ClosetColors.taupe,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Modifier ${adresse.libelle}',
          child: GestureDetector(
            onTap: onEditer,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.p8),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: ClosetColors.fond300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
