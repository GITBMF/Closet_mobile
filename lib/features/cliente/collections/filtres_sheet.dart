import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/bandeau_defilable.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_filet.dart';
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

/// Échelle à 5 crans (API : `new` / `very_good` / `good` + excellent / fair).
const etatsCatalogue = [
  'Neuf avec étiquettes',
  'Excellent',
  'Très bon état',
  'Bon état',
  'État correct',
];

/// Ouvre le panneau de filtres — options en bandes horizontales.
Future<void> afficherFiltres(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
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
  late double? _prixMax;
  late final TextEditingController _prixMaxCtrl;

  @override
  void initState() {
    super.initState();
    _univers = ref.read(selectedUniverseProvider);
    _maison = ref.read(filterBrandProvider);
    _taille = ref.read(filterTailleProvider);
    _etat = ref.read(filterEtatProvider);
    _prixMax = ref.read(filterPriceProvider);
    _prixMaxCtrl = TextEditingController(
      text: _prixMax == null ? '' : _formaterMilliers(_prixMax!.round()),
    );
  }

  @override
  void dispose() {
    _prixMaxCtrl.dispose();
    super.dispose();
  }

  void _toutReinitialiser() {
    setState(() {
      _univers = '';
      _maison = null;
      _taille = null;
      _etat = null;
      _prixMax = null;
      _prixMaxCtrl.clear();
    });
  }

  void _appliquer() {
    ref.read(selectedUniverseProvider.notifier).setUniverse(_univers);
    ref.read(filterBrandProvider.notifier).setMaison(_maison);
    ref.read(filterTailleProvider.notifier).setTaille(_taille);
    ref.read(filterEtatProvider.notifier).setEtat(_etat);
    ref.read(filterPrixMinProvider.notifier).setPrice(null);
    ref.read(filterPriceProvider.notifier).setPrice(_prixMax);
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
        corps: _ChampBudget(
          controller: _prixMaxCtrl,
          onChanged: (v) => setState(() => _prixMax = v),
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
                const SizedBox(height: AppSpacing.p12),
                const ClosetPoignee(),
                const SizedBox(height: AppSpacing.p16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: ClosetEnTeteSection(
                    titre: l10n.affinerRecherche,
                    lien: l10n.toutReinitialiser,
                    onLien: _toutReinitialiser,
                  ),
                ),
                const SizedBox(height: AppSpacing.p8),
                _OngletsFiltres(
                  titres: [for (final p in pages) p.titre],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(23, 4, 23, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.swipe_rounded,
                        size: 14,
                        color: context.closetSecondaire,
                      ),
                      const SizedBox(width: AppSpacing.p8),
                      Expanded(
                        child: Text(
                          l10n.filtresGlisser,
                          style: ClosetTextStyles.meta.copyWith(
                            color: context.closetSecondaire,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 88,
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
                      color: context.closetAction,
                      borderRadius: BorderRadius.circular(AppRadius.cercle),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.cercle),
                        onTap: _appliquer,
                        child: Center(
                          child: Text(
                            l10n.voirLesPieces,
                            style: ClosetTextStyles.bouton.copyWith(
                              color: context.closetActionTexte,
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

/// Onglets Univers / Taille / État / Maison / Budget + flèches.
class _OngletsFiltres extends StatelessWidget {
  const _OngletsFiltres({required this.titres});

  final List<String> titres;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          children: [
            FlecheBandeau(
              versLaDroite: false,
              visible: controller.index > 0,
              onTap: () => controller.animateTo(controller.index - 1),
            ),
            Expanded(
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorWeight: AppStroke.fin,
                labelColor: context.closetVert,
                unselectedLabelColor: context.closetSecondaire,
                indicatorColor: context.closetVert,
                labelStyle: ClosetTextStyles.libelle,
                unselectedLabelStyle: ClosetTextStyles.libelle,
                tabs: [for (final t in titres) Tab(text: t)],
              ),
            ),
            FlecheBandeau(
              versLaDroite: true,
              visible: controller.index < controller.length - 1,
              onTap: () => controller.animateTo(controller.index + 1),
            ),
          ],
        );
      },
    );
  }
}

/// Une rangée de puces : glissement + flèches si le contenu déborde.
class _RangeeCoulissante extends StatelessWidget {
  const _RangeeCoulissante({required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: BandeauDefilable(
        enfants: items,
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 2),
        ecart: AppSpacing.p12,
      ),
    );
  }
}

/// Groupe les chiffres par trois (`45000` → `45.000`), sans limite haute :
/// le prix maximal reste un texte libre plutôt qu'un curseur borné.
String _formaterMilliers(int valeur) {
  final chiffres = valeur.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < chiffres.length; i++) {
    if (i > 0 && (chiffres.length - i) % 3 == 0) buffer.write('.');
    buffer.write(chiffres[i]);
  }
  return buffer.toString();
}

class _SeparateurMilliersFiltre extends TextInputFormatter {
  const _SeparateurMilliersFiltre();

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

/// Prix maximal en saisie libre — remplace le curseur, moins lisible et
/// moins précis qu'un montant tapé directement.
class _ChampBudget extends StatelessWidget {
  const _ChampBudget({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.prixMaximalLabel,
            style: ClosetTextStyles.labelChamp.copyWith(
              color: context.closetLabel,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: const [_SeparateurMilliersFiltre()],
            style: ClosetTextStyles.prix.copyWith(color: context.closetPrix),
            cursorColor: context.closetVert,
            onChanged: (texte) {
              final chiffres = texte.replaceAll(RegExp(r'[^\d]'), '');
              onChanged(chiffres.isEmpty ? null : double.parse(chiffres));
            },
            decoration: InputDecoration(
              hintText: l10n.prixMaximalHint,
              suffixText: 'FCFA',
              hintStyle: ClosetTextStyles.prix.copyWith(
                color: context.closetSecondaire,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p16,
                vertical: AppSpacing.p12,
              ),
              filled: true,
              fillColor: context.closetChamp,
              border: _bordureBudget(context.closetBordure),
              enabledBorder: _bordureBudget(context.closetBordure),
              focusedBorder: _bordureBudget(context.closetVert),
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
