import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import '../theme/police_provider.dart';

String libelleTaillePolice(TaillePolice taille, ClosetL10n l10n) =>
    switch (taille) {
      TaillePolice.normale => l10n.policeNormale,
      TaillePolice.grande => l10n.policeGrande,
      TaillePolice.tresGrande => l10n.policeTresGrande,
    };

/// Ouvre la feuille de choix de la taille du texte.
void afficherChoixPolice(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ChoixPoliceSheet(),
  );
}

class _ChoixPoliceSheet extends ConsumerWidget {
  const _ChoixPoliceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actuelle = ref.watch(policeProvider);
    final l10n = ClosetL10n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p24,
        AppSpacing.p20,
        AppSpacing.p24,
        AppSpacing.p32,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.p20),
                decoration: BoxDecoration(
                  color: ClosetColors.carteBordure,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(l10n.taillePolice, style: ClosetTextStyles.titreSection),
            const SizedBox(height: AppSpacing.p8),
            Text(
              l10n.taillePoliceAide,
              style: ClosetTextStyles.meta.copyWith(color: ClosetColors.taupe),
            ),
            const SizedBox(height: AppSpacing.p20),
            for (final taille in TaillePolice.values) ...[
              _TuilePolice(
                taille: taille,
                libelle: libelleTaillePolice(taille, l10n),
                actif: taille == actuelle,
                onTap: () => ref.read(policeProvider.notifier).choisir(taille),
              ),
              if (taille != TaillePolice.values.last)
                const SizedBox(height: AppSpacing.p8),
            ],
          ],
        ),
      ),
    );
  }
}

class _TuilePolice extends StatelessWidget {
  const _TuilePolice({
    required this.taille,
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final TaillePolice taille;
  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: actif ? ClosetColors.emeraude100 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.carte),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.carte),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p14,
          ),
          child: Row(
            children: [
              Text(
                'Aa',
                style: ClosetTextStyles.libelle.copyWith(
                  fontSize: 14 * taille.facteur,
                  color: ClosetColors.vert,
                ),
              ),
              const SizedBox(width: AppSpacing.p16),
              Expanded(
                child: Text(
                  libelle,
                  style: ClosetTextStyles.libelle.copyWith(
                    color: actif ? ClosetColors.noir : context.closetEncre,
                  ),
                ),
              ),
              if (actif)
                const Icon(
                  Icons.check_circle,
                  color: ClosetColors.vert,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
