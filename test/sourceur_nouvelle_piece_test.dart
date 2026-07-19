import 'package:closet/core/widgets/closet_buttons.dart';
import 'package:closet/core/widgets/closet_chip.dart';
import 'package:closet/features/sourceur/nouvelle/sourceur_nouvelle_piece_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'outils.dart';

void main() {
  final envoyer =
      find.widgetWithText(ClosetPrimaryButton, 'ENVOYER AU COMITÉ');

  bool envoyerActif(WidgetTester tester) =>
      tester.widget<ClosetPrimaryButton>(envoyer).onPressed != null;

  testWidgets('le formulaire affiche toutes les sections de la maquette',
      (tester) async {
    await pomperEcran(tester, const SourceurNouvellePieceScreen());

    expect(find.text('Nouvelle pièce'), findsOneWidget);
    expect(find.text('PHOTOGRAPHIES'), findsOneWidget);
    expect(find.text('NOM DE LA PIÈCE'), findsOneWidget);
    expect(find.text('UNIVERS'), findsOneWidget);
    expect(find.text('MAISON / MARQUE'), findsOneWidget);
    expect(find.text('TAILLE'), findsOneWidget);
    expect(find.text('ÉTAT'), findsOneWidget);
    expect(find.text('PRIX PROPOSÉ (FCFA)'), findsOneWidget);
    expect(find.text('DESCRIPTION & STORYTELLING'), findsOneWidget);
    expect(find.text('Réponse sous 48h ouvrées'), findsOneWidget);
    // 3 emplacements de photos.
    expect(find.byIcon(Icons.add), findsNWidgets(3));
    // Valeurs par défaut des listes déroulantes.
    expect(find.text('M'), findsOneWidget);
    expect(find.text('Excellent état'), findsOneWidget);
  });

  testWidgets("l'univers se sélectionne par chip", (tester) async {
    await pomperEcran(tester, const SourceurNouvellePieceScreen());

    ClosetChip chip(String label) =>
        tester.widget<ClosetChip>(find.widgetWithText(ClosetChip, label));

    expect(chip('Robes').selectionnee, isTrue);

    await tester.tap(find.widgetWithText(ClosetChip, 'Sacs'));
    await tester.pump();

    expect(chip('Robes').selectionnee, isFalse);
    expect(chip('Sacs').selectionnee, isTrue);
  });

  testWidgets("Envoyer au comité ne s'active qu'une fois le formulaire "
      'complet', (tester) async {
    await pomperEcran(tester, const SourceurNouvellePieceScreen());

    expect(envoyerActif(tester), isFalse);

    final champs = find.byType(TextField);
    await tester.enterText(champs.at(0), 'Robe soie ivoire');
    await tester.enterText(champs.at(1), 'Sézane');
    await tester.enterText(champs.at(2), '45000');
    await tester.pump();
    expect(envoyerActif(tester), isFalse); // description manquante

    await tester.enterText(champs.at(3), 'Portée deux fois, matière noble.');
    await tester.pump();
    expect(envoyerActif(tester), isTrue);
  });
}
