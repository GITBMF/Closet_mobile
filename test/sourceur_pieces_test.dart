import 'package:closet/core/widgets/closet_chip.dart';
import 'package:closet/features/sourceur/pieces/sourceur_pieces_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'outils.dart';

void main() {
  testWidgets('la liste vide affiche les filtres et son état vide',
      (tester) async {
    await pomperEcran(tester, const SourceurPiecesScreen());

    for (final label in ['Toutes', 'En revue', 'Publiée', 'Vendue',
        'Refusée']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Aucune pièce pour le moment.'), findsOneWidget);
    expect(find.text('DÉPOSER UNE PIÈCE'), findsOneWidget);
  });

  testWidgets('les filtres se sélectionnent', (tester) async {
    await pomperEcran(tester, const SourceurPiecesScreen());

    ClosetChip chip(String label) =>
        tester.widget<ClosetChip>(find.widgetWithText(ClosetChip, label));

    expect(chip('Toutes').selectionnee, isTrue);

    await tester.tap(find.widgetWithText(ClosetChip, 'Vendue'));
    await tester.pump();

    expect(chip('Toutes').selectionnee, isFalse);
    expect(chip('Vendue').selectionnee, isTrue);
  });

  testWidgets('le bouton flottant ouvre le formulaire Nouvelle pièce',
      (tester) async {
    await pomperEcran(tester, const SourceurPiecesScreen());

    // Le bouton flottant est un Material personnalisé : on le cible
    // par son icône + (la dernière du tree, après celle de l'état vide).
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle pièce'), findsOneWidget);
  });
}
