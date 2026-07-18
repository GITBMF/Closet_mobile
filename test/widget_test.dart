import 'package:flutter_test/flutter_test.dart';

import 'package:closet/main.dart';

void main() {
  testWidgets("Le parcours Devenir Sourceur s'affiche", (tester) async {
    await tester.pumpWidget(const ClosetApp());

    expect(find.text('Devenir Sourceur'), findsOneWidget);
    expect(find.text("Confiez vos pièces d'exception"), findsOneWidget);
    expect(find.text('ATELIER'), findsOneWidget);
    expect(find.text('UNIVERS'), findsOneWidget);
    expect(find.text('PAIEMENT'), findsOneWidget);
  });
}
