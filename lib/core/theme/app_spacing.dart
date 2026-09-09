/// Grille d'espacement standardisée (multiple de 4/8).
/// À utiliser pour toutes les marges, paddings et tailles d'icônes/zones interactives.
class AppSpacing {
  AppSpacing._();

  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;
  static const double p64 = 64.0;

  /// Taille minimale pour une zone tactile accessible.
  static const double minTouchTarget = 44.0;

  // ══════════════════════════════════════════════════════════════════════
  // VALEURS FIGMA (maquette du 2026-08-06)
  // ══════════════════════════════════════════════════════════════════════
  // La maquette utilise majoritairement la grille 4/8 ci-dessus, mais avec
  // trois valeurs hors grille récurrentes, reprises ici telles quelles.

  /// Padding horizontal de contenu — valeur la plus fréquente de la maquette
  /// (224 occurrences). Hors grille 4/8, mais dominante : c'est la gouttière
  /// standard des écrans.
  static const double gouttiere = 11.0;

  /// Écart entre éléments d'une liste serrée (48 occurrences)
  static const double gapListe = 9.2;

  /// Écart entre éléments d'une puce / chip (26 occurrences)
  static const double gapChip = 7.0;
}

/// Rayons d'arrondi de la maquette Figma.
class AppRadius {
  AppRadius._();

  /// Cartes, champs, conteneurs — rayon le plus courant (48 occurrences)
  static const double carte = 8.0;

  /// Petites pastilles et vignettes (18 occurrences)
  static const double vignette = 9.5;

  /// Blocs larges, feuilles modales (11 occurrences)
  static const double bloc = 20.0;

  /// Grandes surfaces arrondies, images produit (8 occurrences)
  static const double surface = 32.0;

  /// Cartes produit de la grille catalogue (61 occurrences)
  static const double carteProduit = 36.7;

  /// Boutons pleins et champs arrondis (13 occurrences)
  static const double bouton = 50.0;

  /// Cercle parfait — avatars, badges ronds (26 occurrences)
  static const double cercle = 100.0;
}

/// Épaisseurs de trait de la maquette Figma.
class AppStroke {
  AppStroke._();

  /// Trait standard — bordures, séparateurs (754 occurrences, l'écrasante majorité)
  static const double fin = 1.0;

  /// Trait accentué — champ actif, sélection (40 occurrences)
  static const double moyen = 1.25;

  /// Trait fort — mise en avant (23 occurrences)
  static const double epais = 2.0;

  /// Filet très léger — séparateurs discrets (18 occurrences)
  static const double filet = 0.5;
}
