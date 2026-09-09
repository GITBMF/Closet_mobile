import 'package:flutter/material.dart';

import 'closet_text_styles.dart';

/// Projection de l'échelle CLOSET sur les emplacements Material.
///
/// **Aucune valeur typographique n'est définie ici.** `ClosetTextStyles` est la
/// seule source de vérité : c'est la transcription mesurée de la maquette. Ce
/// fichier ne fait que ranger ces styles dans les treize emplacements que
/// Material attend, afin que les widgets du framework (boutons, `Chip`,
/// `ListTile`, `Text` sans style explicite) héritent de la charte au lieu de
/// retomber sur les défauts de Flutter.
///
/// Historiquement cette classe portait sa propre échelle — corps à 16 pt,
/// boutons Lato 14 gras, display à 32 — des valeurs absentes de la maquette.
/// Elle contredisait donc les écrans, qui lisent `ClosetTextStyles`. La
/// projection ci-dessous supprime cette divergence.
///
/// L'ordre des emplacements suit la hiérarchie de tailles réellement présente
/// dans la maquette : 32 → 24 → 22 → 19 → 18 → 16 → 15 → 14 → 12 → 10 → 8.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
        // Décoratif de marque et grands montants
        displayLarge: ClosetTextStyles.montantHero,
        displayMedium: ClosetTextStyles.titreHero,
        displaySmall: ClosetTextStyles.display,

        // Titres d'écran et de section
        headlineLarge: ClosetTextStyles.titreEcran,
        headlineMedium: ClosetTextStyles.titreSection,
        headlineSmall: ClosetTextStyles.sousTitre,

        // Titres intermédiaires
        titleLarge: ClosetTextStyles.accroche,
        titleMedium: ClosetTextStyles.titreBloc,
        titleSmall: ClosetTextStyles.libelleFort,

        // Corps. `bodyMedium` est le style d'un `Text` sans style explicite :
        // il pointe donc sur `corps`, le style le plus fréquent de la maquette.
        bodyLarge: ClosetTextStyles.citation,
        bodyMedium: ClosetTextStyles.corps,
        bodySmall: ClosetTextStyles.meta,

        // Libellés. `labelLarge` habille les boutons Material.
        labelLarge: ClosetTextStyles.bouton,
        labelMedium: ClosetTextStyles.libelle,
        labelSmall: ClosetTextStyles.attribut,
      );
}
