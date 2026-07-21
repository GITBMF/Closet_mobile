import 'dart:ui' show FontStyle;

import 'package:closet/core/theme/closet_colors.dart';
import 'package:closet/core/theme/closet_text_styles.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vérifie que le thème du code correspond à la charte graphique CLOSET
/// (docs/Charte Graphique CLOSET.pdf, édition avril 2026).
///
/// Les tests de typographie utilisent testWidgets : l'accès aux styles
/// google_fonts déclenche un chargement asynchrone qui doit rester dans
/// la zone de test à temps simulé.
void main() {
  group('Palette de couleurs', () {
    test('les couleurs primaires sont celles de la charte', () {
      expect(ClosetColors.noir.toARGB32(), 0xFF1D1D1B); // Noir Closet
      expect(ClosetColors.vert.toARGB32(), 0xFF1C3D2F); // Vert Forêt
      expect(ClosetColors.dore.toARGB32(), 0xFFBC9746); // Or Closet
    });
  });

  group('Typographie', () {
    testWidgets('les titres utilisent Cormorant (serif de la charte)',
        (tester) async {
      expect(
          ClosetTextStyles.titreEcran.fontFamily, startsWith('Cormorant'));
      expect(ClosetTextStyles.titreHero.fontFamily, startsWith('Cormorant'));
      expect(
          ClosetTextStyles.numeroEtape.fontFamily, startsWith('Cormorant'));
    });

    testWidgets('les corps de texte utilisent Garamond', (tester) async {
      expect(ClosetTextStyles.corps.fontFamily, startsWith('EBGaramond'));
      expect(
          ClosetTextStyles.corpsSurVert.fontFamily, startsWith('EBGaramond'));
      expect(ClosetTextStyles.saisie.fontFamily, startsWith('EBGaramond'));
    });

    testWidgets("l'interface (labels, boutons, navigation) utilise Lato",
        (tester) async {
      expect(ClosetTextStyles.labelChamp.fontFamily, startsWith('Lato'));
      expect(ClosetTextStyles.labelEtape.fontFamily, startsWith('Lato'));
      expect(ClosetTextStyles.bouton.fontFamily, startsWith('Lato'));
      expect(ClosetTextStyles.navigation.fontFamily, startsWith('Lato'));
    });

    testWidgets('le titre hero est en italique (élégance de la charte)',
        (tester) async {
      expect(ClosetTextStyles.titreHero.fontStyle, FontStyle.italic);
    });
  });
}
