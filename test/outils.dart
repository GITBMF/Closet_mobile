import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monte un écran dans un MaterialApp avec une surface de téléphone
/// suffisamment haute pour que les boutons des maquettes soient visibles.
Future<void> pomperEcran(WidgetTester tester, Widget ecran) async {
  tester.view.physicalSize = const Size(900, 1900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: ecran));
}
