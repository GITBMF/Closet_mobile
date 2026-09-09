import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import 'collections_screen.dart';

/// Bornes Figma `14:1514` (10.000 – 45.000 FCFA), alignées sur les prix
/// réels du catalogue (`GET /pieces` → ~7.000 à 44.000).
const double prixMinimum = 5000;
const double prixMaximum = 50000;

/// Puces taille de la maquette. Filtre `size_label` (pas de query API).
const taillesCatalogue = ['XS', 'S', 'M', 'L', 'XL'];

/// `PieceCondition` du backend : `new` / `very_good` / `good`.
const etatsCatalogue = ['Neuf', 'Très bon état', 'Bon état'];

/// Ouvre le panneau de filtres — options en bandes horizontales.
Future<void> afficherFiltres(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _FiltresSheet(),
  );
}

class _FiltresSheet extends ConsumerStatefulWidget {
  const _FiltresSheet();

  @override
  ConsumerState<_FiltresSheet> createState() => _FiltresSheetState();
}

class _FiltresSheetState extends ConsumerState<_FiltresSheet> {
  late String _univers;
  late Maison? _maison;
  late String? _taille;
  late String? _etat;
  late RangeValues _fourchette;

  @override
  void initState() {
    super.initState();
    _univers = ref.read(selectedUniverseProvider);
    _maison = ref.read(filterBrandProvider);
    _taille = ref.read(filterTailleProvider);
    _etat = ref.read(filterEtatProvider);
    _fourchette = _fourchetteDepuis(
      ref.read(filterPrixMinProvider),
      ref.read(filterPriceProvider),
    );
  }

  RangeValues _fourchetteDepuis(double? minBrut, double? maxBrut) {
    final min = (minBrut ?? prixMinimum)
        .clamp(prixMinimum, prixMaximum)
        .toDouble();
    final max = (maxBrut ?? prixMaximum)
        .clamp(prixMinimum, prixMaximum)
        .toDouble();
    if (min > max) return RangeValues(max, min);
    return RangeValues(min, max);
  }

  void _toutReinitialiser() {
    setState(() {
      _univers = '';
      _maison = null;
      _taille = null;
      _etat = null;
      _fourchette = const RangeValues(prixMinimum, prixMaximum);
    });
  }

  void _appliquer() {
    ref.read(selectedUniverseProvider.notifier).setUniverse(_univers);
    ref.read(filterBrandProvider.notifier).setMaison(_maison);
    ref.read(filterTailleProvider.notifier).setTaille(_taille);
    ref.read(filterEtatProvider.notifier).setEtat(_etat);
    ref.read(filterPrixMinProvider.notifier).setPrice(
          _fourchette.start <= prixMinimum ? null : _fourchette.start,
        );
    ref.read(filterPriceProvider.notifier).setPrice(
          _fourchette.end >= prixMaximum ? null : _fourchette.end,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final maisons = ref.watch(maisonsProvider).value ?? const <Maison>[];
    final universDispo = universCatalogue(ref);

    final pages = <({String titre, Widget corps})>[
      if (universDispo.isNotEmpty)
        (
          titre: l10n.filtreUnivers,
          corps: _RangeeCoulissante(
            items: [
              for (final u in universDispo)
                ClosetChip(
                  label: u,
                  isActive: u == _univers,
                  onTap: () => setState(
                    () => _univers = u == _univers ? '' : u,
                  ),
                ),
            ],
          ),
        ),
      (
        titre: l10n.filtreTaille,
        corps: _RangeeCoulissante(
          items: [
            for (final t in taillesCatalogue)
              ClosetChip(
                label: t,
                isActive: t == _taille,
                onTap: () => setState(
                  () => _taille = t == _taille ? null : t,
                ),
              ),
          ],
        ),
      ),
      (
        titre: l10n.filtreEtat,
        corps: _RangeeCoulissante(
          items: [
            for (final e in etatsCatalogue)
              ClosetChip(
                label: e,
                isActive: e == _etat,
                onTap: () => setState(
                  () => _etat = e == _etat ? null : e,
                ),
              ),
          ],
        ),
      ),
      if (maisons.isNotEmpty)
        (
          titre: l10n.filtreMaison,
          corps: _RangeeCoulissante(
            items: [
              for (final m in maisons)
                ClosetChip(
                  label: m.nom,
                  isActive: m.id == _maison?.id,
                  onTap: () => setState(
                    () => _maison = m.id == _maison?.id ? null : m,
                  ),
                ),
            ],
          ),
        ),
      (
        titre: l10n.filtreBudget,
        corps: _CurseurBudget(
          fourchette: _fourchette,
          onChanged: (v) => setState(() => _fourchette = v),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(56)),
        ),
        child: SafeArea(
          top: false,
          child: DefaultTabController(
            length: pages.length,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.p20),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: ClosetEnTeteSection(
                    titre: l10n.affinerRecherche,
                    lien: l10n.toutReinitialiser,
                    onLien: _toutReinitialiser,
                  ),
                ),
                const SizedBox(height: AppSpacing.p8),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  labelColor: ClosetColors.vert,
                  unselectedLabelColor: ClosetColors.chipTexteInactif,
                  indicatorColor: ClosetColors.vert,
                  labelStyle: ClosetTextStyles.libelle,
                  unselectedLabelStyle: ClosetTextStyles.libelle,
                  tabs: [for (final p in pages) Tab(text: p.titre)],
                ),
                SizedBox(
                  height: 108,
                  child: TabBarView(
                    children: [for (final p in pages) p.corps],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(23, 8, 23, 0),
                  child: SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: Material(
                      color: ClosetColors.vert,
                      borderRadius: BorderRadius.circular(AppRadius.cercle),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.cercle),
                        onTap: _appliquer,
                        child: Center(
                          child: Text(
                            l10n.voirLesPieces,
                            style: ClosetTextStyles.bouton.copyWith(
                              color: ClosetColors.blanc,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.p24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Une rangée de puces que l’on fait glisser de droite à gauche.
class _RangeeCoulissante extends StatelessWidget {
  const _RangeeCoulissante({required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 2),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.p12),
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }
}

class _CurseurBudget extends StatelessWidget {
  const _CurseurBudget({
    required this.fourchette,
    required this.onChanged,
  });

  final RangeValues fourchette;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
          RangeSlider(
            values: fourchette,
            min: prixMinimum,
            max: prixMaximum,
            divisions: 45,
            activeColor: ClosetColors.vert,
            inactiveColor: ClosetColors.ligne,
            labels: RangeLabels(
              formatPrixFcfa(fourchette.start),
              formatPrixFcfa(fourchette.end),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
