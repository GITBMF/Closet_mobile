<<<<<<< HEAD
import 'package:flutter/material.dart';
=======
>>>>>>> 3c5c3f710d7ae947e034d4bd20611279258f4c61
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:closet/main.dart';

void main() {
<<<<<<< HEAD
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ClosEtApp()));

    // Verify that our app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
=======
  testWidgets("Le parcours Devenir Sourceur s'affiche", (tester) async {
    await tester.pumpWidget(const ClosetApp());

    expect(find.text('Devenir Sourceur'), findsOneWidget);
    expect(find.text("Confiez vos pièces d'exception"), findsOneWidget);
    expect(find.text('ATELIER'), findsOneWidget);
    expect(find.text('UNIVERS'), findsOneWidget);
    expect(find.text('PAIEMENT'), findsOneWidget);
>>>>>>> 3c5c3f710d7ae947e034d4bd20611279258f4c61
  });
}
