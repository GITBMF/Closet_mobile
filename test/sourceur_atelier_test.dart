import 'package:closet/features/sourceur/atelier/sourceur_atelier_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'outils.dart';

void main() {
  testWidgets("le tableau de bord affiche l'identité et les stats",
      (tester) async {
    await pomperEcran(
      tester,
      const SourceurAtelierScreen(nomAtelier: 'Chez Awa', ville: 'Douala'),
    );

    expect(find.text('Atelier'), findsOneWidget);
    expect(find.text('Chez Awa'), findsWidgets); // sous-titre + hero
    expect(find.text('DOUALA · DEPUIS JUILLET 2026'), findsOneWidget);
    expect(find.text('DÉPÔTS'), findsOneWidget);
    expect(find.text('PUBLIÉES'), findsOneWidget);
    expect(find.text('VENDUES'), findsOneWidget);
    expect(find.text('Net après commission Clos ET (25%)'), findsOneWidget);
  });

  testWidgets("sans dépôt, l'état vide propose de déposer une pièce",
      (tester) async {
    await pomperEcran(tester, const SourceurAtelierScreen());

    expect(find.text('Aucune pièce déposée pour le moment.'), findsOneWidget);
    expect(find.text('DÉPOSER MA PREMIÈRE PIÈCE'), findsOneWidget);
  });

  testWidgets('Déposer ouvre le formulaire Nouvelle pièce', (tester) async {
    await pomperEcran(tester, const SourceurAtelierScreen());

    await tester.tap(find.text('Déposer'));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle pièce'), findsOneWidget);
    expect(find.text('PHOTOGRAPHIES'), findsOneWidget);
  });

  testWidgets('le chevron doré ouvre le détail des revenus', (tester) async {
    await pomperEcran(
      tester,
      const SourceurAtelierScreen(revenusNet: 7500, revenusBrut: 10000),
    );

    await tester.tap(find.byIcon(Icons.chevron_right).last);
    await tester.pumpAndSettle();

    expect(find.text('Revenus'), findsOneWidget);
    expect(find.text('7500 FCFA'), findsOneWidget); // solde
    expect(find.text('− 2500 FCFA'), findsOneWidget); // commission
  });

  testWidgets('Mes dépôts ouvre la liste des pièces', (tester) async {
    await pomperEcran(tester, const SourceurAtelierScreen());

    await tester.tap(find.text('Mes dépôts'));
    await tester.pumpAndSettle();

    expect(find.text('Toutes'), findsOneWidget);
    expect(find.text('En revue'), findsOneWidget);
  });
}
