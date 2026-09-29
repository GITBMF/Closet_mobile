/// Échelle d'état demandée par le design : 5 crans, du neuf au correct.
///
/// L'API ClosET n'expose aujourd'hui que `new` | `very_good` | `good`.
/// `excellent` et `fair` sont reconnus s'ils arrivent, et mappés depuis
/// les libellés déjà stockés côté client.
enum NiveauEtat {
  neufEtiquettes,
  excellent,
  tresBon,
  bon,
  correct,
}

extension NiveauEtatX on NiveauEtat {
  int get cran => index;

  String get libelle => switch (this) {
        NiveauEtat.neufEtiquettes => 'Neuf avec étiquettes',
        NiveauEtat.excellent => 'Excellent',
        NiveauEtat.tresBon => 'Très bon état',
        NiveauEtat.bon => 'Bon état',
        NiveauEtat.correct => 'État correct',
      };

  String get libelleCourt => switch (this) {
        NiveauEtat.neufEtiquettes => 'Neuf',
        NiveauEtat.excellent => 'Exc.',
        NiveauEtat.tresBon => 'T. bon',
        NiveauEtat.bon => 'Bon',
        NiveauEtat.correct => 'Correct',
      };

  /// 5 = neuf / excellent, 2 = correct.
  int get etoiles => switch (this) {
        NiveauEtat.neufEtiquettes || NiveauEtat.excellent => 5,
        NiveauEtat.tresBon => 4,
        NiveauEtat.bon => 3,
        NiveauEtat.correct => 2,
      };

  static NiveauEtat depuis(String? brut) {
    final t = _normaliser(brut ?? '');
    if (t.isEmpty) return NiveauEtat.tresBon;
    if (_contient(t, const [
      'new_with_tags',
      'neuf avec etiquette',
      'neuf etiquette',
    ])) {
      return NiveauEtat.neufEtiquettes;
    }
    if (t == 'new' || t == 'neuf') return NiveauEtat.neufEtiquettes;
    if (t == 'excellent') return NiveauEtat.excellent;
    if (_contient(t, const ['very_good', 'tres bon', 'très bon'])) {
      return NiveauEtat.tresBon;
    }
    if (t == 'good' || t == 'bon etat' || t == 'bon') return NiveauEtat.bon;
    if (_contient(t, const ['fair', 'correct', 'acceptable'])) {
      return NiveauEtat.correct;
    }
    return NiveauEtat.tresBon;
  }
}

/// Notes d'usure : champs API s'ils existent, sinon clauses du descriptif.
List<String> extraireImperfections({
  required Map<String, dynamic> json,
  String description = '',
  String story = '',
  required NiveauEtat niveau,
}) {
  final api = _depuisApi(json);
  if (api.isNotEmpty) return api;

  final releves = [
    ..._clausesUsage(description),
    ..._clausesUsage(story),
  ];
  final vus = <String>{};
  final uniques = <String>[];
  for (final c in releves) {
    if (vus.add(c.toLowerCase())) uniques.add(c);
  }
  if (uniques.isNotEmpty) return uniques;
  return _repliConfiance(niveau);
}

List<String> _depuisApi(Map<String, dynamic> json) {
  const cles = [
    'imperfections',
    'flaws',
    'wear_notes',
    'condition_notes',
    'wear',
  ];
  for (final cle in cles) {
    final v = json[cle];
    if (v is List) {
      final liste = [
        for (final e in v)
          if (e != null && e.toString().trim().isNotEmpty) e.toString().trim(),
      ];
      if (liste.isNotEmpty) return liste;
    }
    if (v is String && v.trim().isNotEmpty) {
      return _decouper(v);
    }
  }
  return const [];
}

List<String> _clausesUsage(String texte) {
  if (texte.trim().isEmpty) return const [];
  return [
    for (final clause in _decouper(texte))
      if (_estUsage(clause)) _capitaliser(clause),
  ];
}

List<String> _decouper(String texte) {
  return [
    for (final brut in texte.split(RegExp(r'[\n;•·]+|,(?!\s*\d)')))
      if (brut.trim().isNotEmpty) brut.trim().replaceAll(RegExp(r'\.$'), ''),
  ];
}

bool _estUsage(String clause) {
  final t = _normaliser(clause);
  if (t.length < 8) return false;
  return _stemsUsage.any(t.contains);
}

const _stemsUsage = [
  'frott',
  'usure',
  'usee',
  'uses',
  'use ',
  'rayure',
  'scratch',
  'micro-ray',
  'microray',
  'tache',
  'decolor',
  'pilling',
  'bouloche',
  'accroc',
  'trou',
  'marque',
  'fil a reprendre',
  'patine',
  'oxyd',
  'jamais port',
  'proche du neuf',
  'etiquette',
  'worn',
  'fade',
  'crease',
];

List<String> _repliConfiance(NiveauEtat niveau) => switch (niveau) {
      NiveauEtat.neufEtiquettes => const [
          'Étiquettes d’origine encore présentes.',
          'Aucun signe d’usure constaté.',
        ],
      NiveauEtat.excellent => const [
          'Pièce quasi neuve, portée très rarement.',
          'Aucun défaut structurel relevé.',
        ],
      NiveauEtat.tresBon => const [
          'Légers signes d’usage, sans altération de la forme.',
          'Aucun défaut structurel relevé.',
        ],
      NiveauEtat.bon => const [
          'Signes d’usage visibles, pièce saine et portable.',
        ],
      NiveauEtat.correct => const [
          'Usure marquée, relevée ici en toute transparence.',
        ],
    };

String _capitaliser(String s) {
  final t = s.trim();
  if (t.isEmpty) return t;
  return '${t[0].toUpperCase()}${t.substring(1)}';
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
    '’': "'",
  };
  final b = StringBuffer();
  for (final r in s.toLowerCase().trim().runes) {
    final c = String.fromCharCode(r);
    b.write(accents[c] ?? c);
  }
  return b.toString();
}

bool _contient(String hay, List<String> needles) {
  for (final n in needles) {
    if (hay.contains(n)) return true;
  }
  return false;
}
