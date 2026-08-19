import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/repositories/catalog_repository.dart';
import 'collections_screen.dart';

/// Bornes de la fourchette de prix, en FCFA — transmises au backend via
/// `min_price` / `max_price` de `GET /pieces`.
const double prixMinimum = 10000;
const double prixMaximum = 45000;

/// Ouvre le panneau de filtres — maquette « Affiner ma recherche ».
Future<void> afficherFiltres(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: ClosetColors.noir.withValues(alpha: 0.45),
    builder: (context) => const _FiltresSheet(),
  );
}

class _FiltresSheet extends ConsumerWidget {
  const _FiltresSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final univers = ref.watch<String>(selectedUniverseProvider);
    final maison = ref.watch<String?>(filterBrandProvider);
    final maisons = ref.watch(maisonsProvider);
    final prixMax = ref.watch<double?>(filterPriceProvider) ?? prixMaximum;
    final nombrePieces = ref.watch(filteredArticlesProvider).value?.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(56)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(23, AppSpacing.p20, 23, 0),
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: ClosetColors.fond300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.p20),
            ClosetEnTeteSection(
              titre: 'Affiner ma recherche',
              lien: 'Tout réinitialiser',
              onLien: () {
                ref.read(filterBrandProvider.notifier).setBrand(null);
                ref.read(filterPriceProvider.notifier).setPrice(null);
                ref
                    .read<UniverseNotifier>(selectedUniverseProvider.notifier)
                    .setUniverse('');
              },
            ),
            const SizedBox(height: AppSpacing.p24),
            if (universCatalogue(ref).isNotEmpty) ...[
              const ClosetSurtitre('Explorer par univers'),
              const SizedBox(height: AppSpacing.p16),
              Wrap(
                spacing: AppSpacing.p12,
                runSpacing: AppSpacing.p12,
                children: [
                  for (final u in universCatalogue(ref))
                    ClosetChip(
                      label: u,
                      isActive: u == univers,
                      onTap: () => ref
                          .read<UniverseNotifier>(
                              selectedUniverseProvider.notifier)
                          .setUniverse(u == univers ? '' : u),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.p24),
            ],
            if (maisons.value?.isNotEmpty ?? false) ...[
              const ClosetSurtitre('Maison'),
              const SizedBox(height: AppSpacing.p16),
              Wrap(
                spacing: AppSpacing.p12,
                runSpacing: AppSpacing.p12,
                children: [
                  for (final m in maisons.value!)
                    ClosetChip(
                      label: m,
                      isActive: m == maison,
                      onTap: () => ref
                          .read(filterBrandProvider.notifier)
                          .setBrand(m == maison ? null : m),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.p24),
            ],
            const ClosetSurtitre('Budget'),
            const SizedBox(height: AppSpacing.p8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatPrixFcfa(prixMinimum),
                  style: ClosetTextStyles.prix.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
                Text(
                  formatPrixFcfa(prixMax),
                  style: ClosetTextStyles.prix.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
            Slider(
              value: prixMax.clamp(prixMinimum, prixMaximum),
              min: prixMinimum,
              max: prixMaximum,
              divisions: 35,
              activeColor: ClosetColors.vert,
              inactiveColor: ClosetColors.ligne,
              label: formatPrixFcfa(prixMax),
              onChanged: (v) =>
                  ref.read(filterPriceProvider.notifier).setPrice(v),
            ),
            const SizedBox(height: AppSpacing.p20),
            SizedBox(
              height: 44,
              child: Material(
                color: ClosetColors.vert,
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(
                    child: Text(
                      // La maquette porte le compte sur le CTA (« Voir 18
                      // pièces »). Il n'est affiché qu'une fois connu, pour ne
                      // pas annoncer un nombre puis le corriger.
                      nombrePieces == null
                          ? 'Voir les pièces'
                          : nombrePieces == 1
                              ? 'Voir 1 pièce'
                              : 'Voir $nombrePieces pièces',
                      style: ClosetTextStyles.bouton.copyWith(
                        color: ClosetColors.blanc,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p32),
              SizedBox(
                width: double.infinity,
                child: ClosetPrimaryButton(
                  label: count == null
                      ? 'Voir les pièces'
                      : 'Voir $count pièce${count > 1 ? 's' : ''}',
                  hauteur: 50,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  const _EnTete({required this.onReinitialiser});

  final VoidCallback onReinitialiser;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Affiner ma recherche',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.titreSection.copyWith(
              color: ClosetColors.noir,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: 'Tout réinitialiser',
          child: GestureDetector(
            onTap: onReinitialiser,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClosetSurtitre('tout réinitialiser'),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  size: 11,
                  color: ClosetColors.fond400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Puces extends StatelessWidget {
  const _Puces({
    required this.valeurs,
    required this.onTap,
    this.actif,
    this.compact = false,
  });

  final List<String> valeurs;
  final String? actif;
  final ValueChanged<String> onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.p12,
      runSpacing: AppSpacing.p12,
      children: [
        for (final v in valeurs)
          _PuceFiltre(
            label: v,
            actif: v == actif,
            compact: compact,
            onTap: () => onTap(v),
          ),
      ],
    );
  }
}

/// Puce de la feuille de filtres : pilule blanche cerclée d'encre, ou
/// vert profond plein une fois sélectionnée.
class _PuceFiltre extends StatelessWidget {
  const _PuceFiltre({
    required this.label,
    required this.actif,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool actif;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: actif,
      child: GestureDetector(
        onTap: onTap,
        child: UnconstrainedBox(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 16,
              vertical: 8,
            ),
            constraints: compact
                ? const BoxConstraints(minWidth: 40, minHeight: 34)
                : const BoxConstraints(minHeight: 34),
            decoration: BoxDecoration(
              color: actif ? ClosetColors.vert : Colors.white,
              border: Border.all(
                color: actif ? ClosetColors.vert : ClosetColors.noir,
                width: AppStroke.fin,
              ),
              borderRadius: BorderRadius.circular(AppRadius.bouton),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corps.copyWith(
                color: actif ? Colors.white : ClosetColors.noir,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pouce du curseur de prix : disque blanc cerclé d'encre.
class _PoucePrix extends RangeSliderThumbShape {
  const _PoucePrix();

  static const double _rayon = 10;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_rayon);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      _rayon,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      _rayon,
      Paint()
        ..color = ClosetColors.noir
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppStroke.fin,
    );
  }
}
