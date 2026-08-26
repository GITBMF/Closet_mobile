import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Métriques d'écran pour adapter marges et cibles tactiles au téléphone.
///
/// Les boutons d'en-tête (sélection, notifications, retour) doivent rester
/// hors encoche, hors barre de geste, et assez grands pour le pouce — y
/// compris sur un SE / petit Android (~320 pt).
class ClosetLayout {
  ClosetLayout._(this.size);

  final Size size;

  factory ClosetLayout.of(BuildContext context) {
    return ClosetLayout._(MediaQuery.sizeOf(context));
  }

  /// iPhone SE, petits Android — largeur inférieure à 360.
  bool get compact => size.width < 360;

  /// Téléphones larges (Pro Max, etc.).
  bool get large => size.width >= 400;

  /// Gouttière latérale : 16 sur petit écran pour laisser de la place aux
  /// boutons, 20 ensuite (proche de la maquette).
  double get gouttiere => compact ? AppSpacing.p16 : AppSpacing.p20;

  /// Zone tactile des boutons d'en-tête. Material recommande 48, jamais moins
  /// que [AppSpacing.minTouchTarget].
  double get cibleTactile => compact ? 48 : AppSpacing.minTouchTarget;

  /// Disque visible du bouton d'en-tête.
  double get boutonHeader => compact ? 40 : 42;

  double get iconeHeader => compact ? 18 : 16;

  /// Écart entre les deux raccourcis à droite de l'en-tête.
  double get ecartBoutonsHeader => compact ? AppSpacing.p8 : AppSpacing.p12;

  /// Hauteur de la barre d'outils, hors inset statut (le Scaffold l'ajoute).
  static const double hauteurBarre = 62;

  /// Hauteur du carrousel produit, proportionnelle à l'écran.
  double get hauteurHeroProduit =>
      (size.height * 0.48).clamp(260.0, 493.0);

  /// Photo de la pièce de la semaine, un peu plus basse sur petit écran.
  double get hauteurPieceSemaine => compact ? 220.0 : 280.0;
}
