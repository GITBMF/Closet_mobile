import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/closet_sections.dart';
import 'collections_screen.dart';

/// Univers proposés par la maquette « Affiner ma recherche ».
const List<String> universFiltres = [
  'Robes',
  'Accessoires',
  'Vestes',
  'Sacs',
  'Chaussures',
  'Nouveautés',
];

/// Tailles proposées par la maquette.
const List<String> taillesDisponibles = ['XS', 'S', 'M', 'L', 'XL'];

/// États proposés par la maquette.
const List<String> etatsDisponibles = [
  'Neuf',
  'Très bon état',
  'Bon état',
  'Excellent',
];

/// Bornes de la fourchette de prix, en FCFA.
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
    final taille = ref.watch<String?>(filterSizeProvider);
    final etat = ref.watch<String?>(filterConditionProvider);
    final fourchette = ref.watch<RangeValues?>(filterPriceRangeProvider) ??
        const RangeValues(prixMinimum, prixMaximum);
    final catalogue = ref.watch(filteredArticlesProvider);
    final count = catalogue.asData?.value.length;
    final bas = MediaQuery.paddingOf(context).bottom;
    // Laisse visibles le panier, la cloche et la barre de recherche
    // de Collections, comme sur la maquette.
    const enteteCollections = 8.0 + 42 + 16 + 45 + 8;

    return Padding(
      padding: const EdgeInsets.only(top: enteteCollections),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: ClosetColors.beige,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.surface),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 16 + bas),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EnTete(
                onReinitialiser: () {
                  ref.read(filterBrandProvider.notifier).setBrand(null);
                  ref.read(filterSizeProvider.notifier).setSize(null);
                  ref.read(filterConditionProvider.notifier).setCondition(null);
                  ref.read(filterPriceRangeProvider.notifier).setRange(null);
                  ref
                      .read<UniverseNotifier>(selectedUniverseProvider.notifier)
                      .setUniverse(CollectionsScreen.universes.first);
                },
              ),
              const SizedBox(height: AppSpacing.p24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ClosetSurtitre('explorer par univers'),
                      const SizedBox(height: AppSpacing.p16),
                      _Puces(
                        valeurs: universFiltres,
                        actif: univers,
                        onTap: (u) => ref
                            .read<UniverseNotifier>(
                                selectedUniverseProvider.notifier)
                            .setUniverse(u == univers
                                ? CollectionsScreen.universes.first
                                : u),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      const ClosetSurtitre('taille'),
                      const SizedBox(height: AppSpacing.p16),
                      _Puces(
                        valeurs: taillesDisponibles,
                        actif: taille,
                        compact: true,
                        onTap: (t) => ref
                            .read(filterSizeProvider.notifier)
                            .setSize(t == taille ? null : t),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      const ClosetSurtitre('état de la pièce'),
                      const SizedBox(height: AppSpacing.p16),
                      _Puces(
                        valeurs: etatsDisponibles,
                        actif: etat,
                        onTap: (e) => ref
                            .read(filterConditionProvider.notifier)
                            .setCondition(e == etat ? null : e),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      const ClosetSurtitre('les prix'),
                      const SizedBox(height: AppSpacing.p16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: ClosetColors.vert,
                          inactiveTrackColor: ClosetColors.fond200,
                          overlayColor:
                              ClosetColors.vert.withValues(alpha: 0.12),
                          rangeThumbShape: const _PoucePrix(),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: RangeSlider(
                          values: RangeValues(
                            fourchette.start.clamp(prixMinimum, prixMaximum),
                            fourchette.end.clamp(prixMinimum, prixMaximum),
                          ),
                          min: prixMinimum,
                          max: prixMaximum,
                          divisions: 35,
                          onChanged: (v) => ref
                              .read(filterPriceRangeProvider.notifier)
                              .setRange(v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatPrixFcfa(fourchette.start),
                              style: ClosetTextStyles.prix.copyWith(
                                color: ClosetColors.vert,
                              ),
                            ),
                            Text(
                              formatPrixFcfa(fourchette.end),
                              style: ClosetTextStyles.prix.copyWith(
                                color: ClosetColors.vert,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
