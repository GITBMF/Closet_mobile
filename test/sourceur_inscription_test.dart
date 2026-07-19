import 'package:closet/core/widgets/closet_buttons.dart';
import 'package:closet/core/widgets/closet_chip.dart';
import 'package:closet/features/sourceur/inscription/sourceur_inscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'outils.dart';

void main() {
  Finder bouton(String label) =>
      find.widgetWithText(ClosetPrimaryButton, label);

  bool boutonActif(WidgetTester tester, String label) =>
      tester.widget<ClosetPrimaryButton>(bouton(label)).onPressed != null;

  Future<void> remplirEtape1(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'Chez Awa');
    await tester.enterText(find.byType(TextField).at(1), 'Yaoundé');
    await tester.enterText(find.byType(TextField).at(2), '+237 6 77 45 22 18');
    await tester.pump();
  }

  testWidgets("l'étape Atelier s'affiche avec le hero et le stepper",
      (tester) async {
    await pomperEcran(tester, const SourceurInscriptionScreen());

    expect(find.text('Devenir Sourceur'), findsOneWidget);
    expect(find.text("Confiez vos pièces d'exception"), findsOneWidget);
    expect(find.text('ATELIER'), findsOneWidget);
    expect(find.text('UNIVERS'), findsOneWidget);
    expect(find.text('PAIEMENT'), findsOneWidget);
    expect(find.text('NOM DE VOTRE ATELIER'), findsOneWidget);
  });

  testWidgets('Continuer reste désactivé tant que les champs sont vides',
      (tester) async {
    await pomperEcran(tester, const SourceurInscriptionScreen());

    expect(boutonActif(tester, 'CONTINUER'), isFalse);

    await remplirEtape1(tester);
    expect(boutonActif(tester, 'CONTINUER'), isTrue);
  });

  testWidgets("le parcours complet mène au tableau de bord de l'atelier",
      (tester) async {
    await pomperEcran(tester, const SourceurInscriptionScreen());

    // Étape 1 — Atelier
    await remplirEtape1(tester);
    await tester.ensureVisible(bouton('CONTINUER'));
    await tester.tap(bouton('CONTINUER'));
    await tester.pumpAndSettle();

    // Étape 2 — Univers
    expect(find.text('VOTRE UNIVERS EN QUELQUES MOTS'), findsOneWidget);
    expect(boutonActif(tester, 'CONTINUER'), isFalse);

    await tester.enterText(
        find.byType(TextField).first, 'Pièces vintage chinées avec soin.');
    await tester.tap(find.widgetWithText(ClosetChip, 'Robes'));
    await tester.pump();
    expect(boutonActif(tester, 'CONTINUER'), isTrue);

    await tester.ensureVisible(bouton('CONTINUER'));
    await tester.tap(bouton('CONTINUER'));
    await tester.pumpAndSettle();

    // Étape 3 — Paiement
    expect(find.text('MOYEN DE RÉMUNÉRATION'), findsOneWidget);
    expect(find.text('MTN MoMo'), findsOneWidget);
    expect(boutonActif(tester, 'REJOINDRE LE CERCLE'), isFalse);

    await tester.enterText(find.byType(TextField).first, '+237 6 77 45 22 18');
    await tester.pump();
    expect(boutonActif(tester, 'REJOINDRE LE CERCLE'), isTrue);

    await tester.ensureVisible(bouton('REJOINDRE LE CERCLE'));
    await tester.tap(bouton('REJOINDRE LE CERCLE'));
    await tester.pumpAndSettle();

    // Arrivée sur l'Atelier avec les informations saisies.
    expect(find.text('Atelier'), findsOneWidget);
    expect(find.text('Chez Awa'), findsOneWidget);
  });

  testWidgets("Retour revient à l'étape précédente", (tester) async {
    await pomperEcran(tester, const SourceurInscriptionScreen());

    await remplirEtape1(tester);
    await tester.ensureVisible(bouton('CONTINUER'));
    await tester.tap(bouton('CONTINUER'));
    await tester.pumpAndSettle();
    expect(find.text('VOTRE UNIVERS EN QUELQUES MOTS'), findsOneWidget);

    final retour = find.widgetWithText(ClosetOutlineButton, 'RETOUR');
    await tester.ensureVisible(retour);
    await tester.tap(retour);
    await tester.pumpAndSettle();

    expect(find.text('NOM DE VOTRE ATELIER'), findsOneWidget);
    // Les saisies sont conservées.
    expect(find.text('Chez Awa'), findsOneWidget);
  });
}
