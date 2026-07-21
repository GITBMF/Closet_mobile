import 'package:closet/core/widgets/closet_buttons.dart';
import 'package:closet/features/sourceur/revenus/sourceur_revenus_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'outils.dart';

void main() {
  final versement =
      find.widgetWithText(ClosetPrimaryButton, 'DEMANDER UN VERSEMENT');

  testWidgets("l'écran affiche le solde et le récapitulatif", (tester) async {
    await pomperEcran(
      tester,
      const SourceurRevenusScreen(
        solde: 7500,
        brut: 10000,
        commission: 2500,
        enAttente: 3000,
      ),
    );

    expect(find.text('Revenus'), findsOneWidget);
    expect(find.text('SOLDE DISPONIBLE'), findsOneWidget);
    expect(find.text('7500 FCFA'), findsOneWidget);
    expect(find.text('Versé sur MTN MoMo'), findsOneWidget);
    expect(find.text('10000 FCFA'), findsOneWidget);
    expect(find.text('− 2500 FCFA'), findsOneWidget);
    expect(find.text('3000 FCFA'), findsOneWidget);
    expect(find.text('Vos pièces adoptées'), findsOneWidget);
  });

  testWidgets('le versement est désactivé quand le solde est nul',
      (tester) async {
    await pomperEcran(tester, const SourceurRevenusScreen());

    expect(
      tester.widget<ClosetPrimaryButton>(versement).onPressed,
      isNull,
    );
    expect(
      find.text('Aucune vente pour le moment. Continuez à déposer vos plus '
          'belles pièces ✨'),
      findsOneWidget,
    );
  });

  testWidgets('le versement est actif dès que le solde est positif',
      (tester) async {
    await pomperEcran(tester, const SourceurRevenusScreen(solde: 5000));

    expect(
      tester.widget<ClosetPrimaryButton>(versement).onPressed,
      isNotNull,
    );
  });
}
