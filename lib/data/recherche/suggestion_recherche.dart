import '../models/article.dart';

/// Facettes demandées par la maquette : marque, type, taille, état.
enum CategorieSuggestion { marque, type, taille, etat }

/// Une ligne du menu contextuel sous la barre de recherche.
class SuggestionRecherche {
  const SuggestionRecherche({
    required this.categorie,
    required this.libelle,
    this.maison,
  });

  final CategorieSuggestion categorie;
  final String libelle;
  final Maison? maison;

  @override
  bool operator ==(Object other) =>
      other is SuggestionRecherche &&
      other.categorie == categorie &&
      other.libelle.toLowerCase() == libelle.toLowerCase();

  @override
  int get hashCode => Object.hash(categorie, libelle.toLowerCase());
}

/// Référentiel local pour l’autocomplete (maisons, types, tailles, états).
class IndexRecherche {
  const IndexRecherche({
    this.maisons = const [],
    this.types = const [],
    this.tailles = const [],
    this.etats = const [],
    this.marquesTendance = const [],
    this.repliPopulaires = const [],
  });

  final List<Maison> maisons;
  final List<String> types;
  final List<String> tailles;
  final List<String> etats;

  /// Maisons les plus présentes dans le catalogue, déjà triées.
  final List<String> marquesTendance;

  /// Types / états fréquents, utilisés si l’historique est vide.
  final List<String> repliPopulaires;

  static const vide = IndexRecherche();
}

/// Contenu du panneau sous la barre : repos (populaires + tendances)
/// ou saisie (suggestions groupées dans l’ordre marque → type → taille → état).
class PanneauRecherche {
  const PanneauRecherche({
    this.recherchesPopulaires = const [],
    this.marquesTendance = const [],
    this.suggestions = const [],
  });

  final List<String> recherchesPopulaires;
  final List<String> marquesTendance;
  final List<SuggestionRecherche> suggestions;

  bool get estVide =>
      recherchesPopulaires.isEmpty &&
      marquesTendance.isEmpty &&
      suggestions.isEmpty;

  bool get estContextuel => suggestions.isNotEmpty;

  static const vide = PanneauRecherche();
}

/// Construit le panneau dès la première lettre, ou le repos si la barre
/// est active sans saisie.
PanneauRecherche construirePanneau({
  required String requete,
  required IndexRecherche index,
  List<String> historique = const [],
  int maxParCategorie = 5,
  int maxPopulaires = 6,
  int maxTendance = 6,
}) {
  final q = requete.trim();
  if (q.isEmpty) {
    return PanneauRecherche(
      recherchesPopulaires: _populaires(
        historique: historique,
        repli: index.repliPopulaires,
        max: maxPopulaires,
      ),
      marquesTendance: index.marquesTendance.take(maxTendance).toList(),
    );
  }

  final suggestions = <SuggestionRecherche>[
    ..._filtrerMaisons(q, index.maisons, maxParCategorie),
    ..._filtrerLibelles(q, index.types, CategorieSuggestion.type, maxParCategorie),
    ..._filtrerLibelles(q, index.tailles, CategorieSuggestion.taille, maxParCategorie),
    ..._filtrerLibelles(q, index.etats, CategorieSuggestion.etat, maxParCategorie),
  ];

  return PanneauRecherche(suggestions: suggestions);
}

/// Index à partir du catalogue + référentiels maisons / univers.
IndexRecherche indexDepuisCatalogue({
  required List<Maison> maisons,
  required List<String> univers,
  required List<Article> pieces,
  List<String> taillesCanoniques = const ['XS', 'S', 'M', 'L', 'XL'],
  List<String> etatsCanoniques = const [
    'Neuf avec étiquettes',
    'Excellent',
    'Très bon état',
    'Bon état',
    'État correct',
  ],
}) {
  final types = <String>{...univers.where((u) => u.trim().isNotEmpty)};
  final tailles = <String>{...taillesCanoniques};
  final etats = <String>{...etatsCanoniques};
  final freqMarque = <String, int>{};

  for (final p in pieces) {
    if (p.universe.trim().isNotEmpty) types.add(p.universe.trim());
    final typeTitre = Article.typeDepuisTitre(p.title);
    if (typeTitre != null) types.add(typeTitre);
    if (p.size.trim().isNotEmpty) tailles.add(p.size.trim());
    if (p.condition.trim().isNotEmpty) etats.add(p.condition.trim());
    final marque = p.brand.trim();
    if (marque.isNotEmpty) {
      freqMarque[marque] = (freqMarque[marque] ?? 0) + 1;
    }
  }

  final maisonsNoms = <String, Maison>{
    for (final m in maisons)
      if (m.nom.trim().isNotEmpty) m.nom.trim().toLowerCase(): m,
  };
  for (final nom in freqMarque.keys) {
    maisonsNoms.putIfAbsent(
      nom.toLowerCase(),
      () => Maison(id: nom, nom: nom),
    );
  }

  final tendance = freqMarque.keys.toList()
    ..sort((a, b) {
      final cmp = (freqMarque[b] ?? 0).compareTo(freqMarque[a] ?? 0);
      return cmp != 0 ? cmp : a.toLowerCase().compareTo(b.toLowerCase());
    });
  if (tendance.isEmpty) {
    tendance.addAll(maisons.map((m) => m.nom).where((n) => n.trim().isNotEmpty));
  }

  final typesTries = types.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return IndexRecherche(
    maisons: maisonsNoms.values.toList()
      ..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase())),
    types: typesTries,
    tailles: tailles.toList(),
    etats: etats.toList(),
    marquesTendance: tendance,
    repliPopulaires: [
      ...typesTries.take(4),
      if (etatsCanoniques.isNotEmpty) etatsCanoniques.first,
    ],
  );
}

List<String> _populaires({
  required List<String> historique,
  required List<String> repli,
  required int max,
}) {
  final vus = <String>{};
  final liste = <String>[];
  for (final brut in [...historique, ...repli]) {
    final t = brut.trim();
    if (t.isEmpty || !vus.add(t.toLowerCase())) continue;
    liste.add(t);
    if (liste.length >= max) break;
  }
  return liste;
}

List<SuggestionRecherche> _filtrerMaisons(
  String q,
  List<Maison> maisons,
  int max,
) {
  final candidats = [
    for (final m in maisons)
      if (_correspond(m.nom, q))
        SuggestionRecherche(
          categorie: CategorieSuggestion.marque,
          libelle: m.nom,
          maison: m,
        ),
  ];
  candidats.sort((a, b) {
    final rang = _rang(a.libelle, q).compareTo(_rang(b.libelle, q));
    return rang != 0
        ? rang
        : a.libelle.toLowerCase().compareTo(b.libelle.toLowerCase());
  });
  return candidats.take(max).toList();
}

List<SuggestionRecherche> _filtrerLibelles(
  String q,
  List<String> libelles,
  CategorieSuggestion categorie,
  int max,
) {
  final vus = <String>{};
  final candidats = <SuggestionRecherche>[];
  for (final brut in libelles) {
    final t = brut.trim();
    if (t.isEmpty || !vus.add(t.toLowerCase()) || !_correspond(t, q)) continue;
    candidats.add(SuggestionRecherche(categorie: categorie, libelle: t));
  }
  candidats.sort((a, b) {
    final rang = _rang(a.libelle, q).compareTo(_rang(b.libelle, q));
    return rang != 0
        ? rang
        : a.libelle.toLowerCase().compareTo(b.libelle.toLowerCase());
  });
  return candidats.take(max).toList();
}

bool _correspond(String libelle, String q) {
  final l = libelle.toLowerCase();
  final r = q.toLowerCase();
  if (l.contains(r)) return true;
  return _normaliser(l).contains(_normaliser(r));
}

int _rang(String libelle, String q) {
  final l = libelle.toLowerCase();
  final r = q.toLowerCase();
  if (l == r) return 0;
  if (l.startsWith(r)) return 1;
  if (RegExp('(?:^|\\s)${RegExp.escape(r)}').hasMatch(l)) return 2;
  return 3;
}

String _normaliser(String s) {
  const accents = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  final b = StringBuffer();
  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    b.write(accents[c] ?? c);
  }
  return b.toString();
}
