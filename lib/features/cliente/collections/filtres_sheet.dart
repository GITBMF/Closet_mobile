import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Repère affiché en placeholder — alignée sur les prix réels du catalogue
/// (`GET /pieces` → jusqu'à ~44.000 FCFA).
const double prixMaximum = 50000;

/// Puces taille de la maquette. Filtre `size_label` (pas de query API).
const taillesCatalogue = ['XS', 'S', 'M', 'L', 'XL'];

/// `PieceCondition` du backend : `new` / `very_good` / `good`.
const etatsCatalogue = ['new', 'very_good', 'good'];

String libelleEtatCatalogue(String code, ClosetL10n l10n) => switch (code) {
      'new' => l10n.etatNeuf,
      'very_good' => l10n.etatTresBonEtat,
      _ => l10n.etatBonEtat,
    };

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
  final _prixMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _univers = ref.read(selectedUniverseProvider);
    _maison = ref.read(filterBrandProvider);
    _taille = ref.read(filterTailleProvider);
    _etat = ref.read(filterEtatProvider);
    final prixMax = ref.read(filterPriceProvider);
    if (prixMax != null) {
      _prixMaxController.text = _formaterMilliers(prixMax.round());
    }
  }

  @override
  void dispose() {
    _prixMaxController.dispose();
    super.dispose();
  }

  void _toutReinitialiser() {
    setState(() {
      _univers = '';
      _maison = null;
      _taille = null;
      _etat = null;
      _prixMaxController.clear();
    });
  }

  void _appliquer() {
    ref.read(selectedUniverseProvider.notifier).setUniverse(_univers);
    ref.read(filterBrandProvider.notifier).setMaison(_maison);
    ref.read(filterTailleProvider.notifier).setTaille(_taille);
    ref.read(filterEtatProvider.notifier).setEtat(_etat);
    // Le prix minimum n'est plus réglable ici (saisie manuelle du maximum
    // seulement) — on ne touche donc jamais `filterPrixMinProvider`.
    final chiffres = _prixMaxController.text.replaceAll(RegExp(r'[^\d]'), '');
    final prixMax = chiffres.isEmpty ? null : double.tryParse(chiffres);
    ref.read(filterPriceProvider.notifier).setPrice(prixMax);
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
                label: libelleEtatCatalogue(e, l10n),
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
        corps: _ChampBudget(controller: _prixMaxController),
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

/// Saisie manuelle du prix maximum — remplace la réglette à deux curseurs :
/// la personne tape directement le montant qu'elle ne veut pas dépasser,
/// plutôt que de manipuler une plage.
class _ChampBudget extends StatelessWidget {
  const _ChampBudget({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ClosetL10n.of(context).filtreBudget,
            style: ClosetTextStyles.labelChamp,
          ),
          const SizedBox(height: AppSpacing.p8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [_SeparateurMilliersBudget()],
            style: ClosetTextStyles.prix.copyWith(color: ClosetColors.vert),
            decoration: InputDecoration(
              hintText: formatPrixFcfa(prixMaximum),
              suffixText: 'FCFA',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p16,
                vertical: AppSpacing.p12,
              ),
              filled: true,
              fillColor: ClosetColors.champFond,
              border: _bordureBudget(ClosetColors.champBordure),
              enabledBorder: _bordureBudget(ClosetColors.champBordure),
              focusedBorder: _bordureBudget(ClosetColors.vert),
            ),
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _bordureBudget(Color couleur) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
        borderSide: BorderSide(color: couleur, width: AppStroke.fin),
      );
}

/// Sépare les milliers par un point pendant la saisie (`45000` → `45.000`).
class _SeparateurMilliersBudget extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue ancien,
    TextEditingValue suivant,
  ) {
    final chiffres = suivant.text.replaceAll(RegExp(r'[^\d]'), '');
    if (chiffres.isEmpty) return suivant.copyWith(text: '');
    final texte = _formaterMilliers(int.parse(chiffres));
    return TextEditingValue(
      text: texte,
      selection: TextSelection.collapsed(offset: texte.length),
    );
  }
}

String _formaterMilliers(int valeur) {
  final chiffres = valeur.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < chiffres.length; i++) {
    if (i > 0 && (chiffres.length - i) % 3 == 0) buffer.write('.');
    buffer.write(chiffres[i]);
  }
  return buffer.toString();
}
