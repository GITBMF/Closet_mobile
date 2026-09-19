import 'package:closet/core/l10n/closet_l10n.dart';
import 'package:closet/core/widgets/spotlight_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Visite guidée de la démo : on vérifie qu'elle s'affiche bien par-dessus
/// l'écran, qu'elle avance, et surtout qu'elle ne se bloque pas sur une cible
/// absente — un blocage laisserait l'app muette en pleine démonstration.
void main() {
  final cible1 = GlobalKey(debugLabel: 'cible1');
  final cible2 = GlobalKey(debugLabel: 'cible2');
  final jamaisMontee = GlobalKey(debugLabel: 'jamais_montee');

  List<SpotlightStep> etapes(List<GlobalKey> cles) => [
        for (var i = 0; i < cles.length; i++)
          SpotlightStep(
            targetKey: cles[i],
            ecran: 'ÉCRAN',
            title: 'Titre ${i + 1}',
            description: 'Corps ${i + 1}',
          ),
      ];

  /// Monte deux boutons ciblables, enveloppés par la visite guidée.
  Future<ProviderContainer> monter(
    WidgetTester tester,
    List<GlobalKey> cles, {
    List<SpotlightStep>? parcours,
  }) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ClosetL10n(
          locale: const Locale('fr'),
          child: MaterialApp(
            home: Builder(
              builder: (context) => SpotlightShowcase(
                steps: parcours ?? etapes(cles),
                child: Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        key: cible1,
                        onPressed: () {},
                        child: const Text('Bouton un'),
                      ),
                      ElevatedButton(
                        key: cible2,
                        onPressed: () {},
                        child: const Text('Bouton deux'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('inerte tant que la visite n’est pas lancée', (tester) async {
    await monter(tester, [cible1, cible2]);

    expect(find.text('Titre 1'), findsNothing);
    expect(find.byType(CustomPaint).evaluate().any(
          (e) => (e.widget as CustomPaint).painter is SpotlightPainter,
        ), isFalse);
  });

  testWidgets('éclaire la première cible puis avance jusqu’à la fin',
      (tester) async {
    final container = await monter(tester, [cible1, cible2]);

    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pumpAndSettle();

    expect(find.text('Titre 1'), findsOneWidget);
    expect(find.text('ÉCRAN · Étape 1 sur 2'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('Titre 2'), findsOneWidget);
    expect(find.text('Terminer'), findsOneWidget);

    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(find.text('Titre 2'), findsNothing);
    expect(container.read(spotlightTourProvider).isActive, isFalse);
  });

  testWidgets('PASSER interrompt la visite', (tester) async {
    final container = await monter(tester, [cible1, cible2]);

    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pumpAndSettle();

    await tester.tap(find.text('PASSER'));
    await tester.pumpAndSettle();

    expect(container.read(spotlightTourProvider).isActive, isFalse);
  });

  testWidgets('une cible absente est sautée au lieu de bloquer la visite',
      (tester) async {
    final container = await monter(tester, [jamaisMontee, cible2]);

    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pump();

    // La première étape n'a rien à éclairer : aucune bulle pour le moment.
    expect(find.text('Titre 1'), findsNothing);

    // Le temps d'attente écoulé, la visite passe d'elle-même à l'étape
    // suivante, dont la cible existe.
    await tester.pumpAndSettle();
    expect(find.text('Titre 2'), findsOneWidget);
    expect(container.read(spotlightTourProvider).isActive, isTrue);
  });

  testWidgets('aucune cible du tout : la visite se termine seule',
      (tester) async {
    final container = await monter(tester, [jamaisMontee]);

    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pumpAndSettle();

    expect(container.read(spotlightTourProvider).isActive, isFalse);
  });

  testWidgets('« Précédent » revient sur l’étape déjà vue', (tester) async {
    final container = await monter(tester, [cible1, cible2]);

    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pumpAndSettle();

    // Étape 1 : rien à revenir en arrière.
    expect(find.text('Précédent'), findsNothing);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Titre 2'), findsOneWidget);

    await tester.tap(find.text('Précédent'));
    await tester.pumpAndSettle();
    expect(find.text('Titre 1'), findsOneWidget);
  });

  testWidgets('une étape indisponible est sautée sans naviguer',
      (tester) async {
    var navigations = 0;
    final container = await monter(
      tester,
      [cible1, cible2],
      parcours: [
        SpotlightStep(
          targetKey: cible1,
          ecran: 'ÉCRAN',
          title: 'Titre 1',
          description: 'Corps 1',
          disponible: (_) => false,
          aller: (_, _) => navigations++,
        ),
        SpotlightStep(
          targetKey: cible2,
          ecran: 'ÉCRAN',
          title: 'Titre 2',
          description: 'Corps 2',
        ),
      ],
    );

    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pumpAndSettle();

    expect(navigations, 0);
    expect(find.text('Titre 1'), findsNothing);
    expect(find.text('Titre 2'), findsOneWidget);
  });

  testWidgets('l’étape rejoint son écran avant d’éclairer sa cible',
      (tester) async {
    final atteints = <String>[];
    final container = await monter(
      tester,
      [cible1, cible2],
      parcours: [
        SpotlightStep(
          targetKey: cible1,
          ecran: 'ÉCRAN',
          title: 'Titre 1',
          description: 'Corps 1',
          aller: (_, _) => atteints.add('un'),
        ),
        SpotlightStep(
          targetKey: cible2,
          ecran: 'ÉCRAN',
          title: 'Titre 2',
          description: 'Corps 2',
          aller: (_, _) => atteints.add('deux'),
        ),
      ],
    );

    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pumpAndSettle();
    expect(atteints, ['un']);
    expect(find.text('Titre 1'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    // Chaque écran n'est rejoint qu'une fois, malgré les rebuilds successifs.
    expect(atteints, ['un', 'deux']);
  });

  testWidgets('l’infobulle se pose sous une grande cible, sans la masquer',
      (tester) async {
    final carte = GlobalKey(debugLabel: 'carte');
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ClosetL10n(
          locale: const Locale('fr'),
          child: MaterialApp(
            home: SpotlightShowcase(
              steps: [
                SpotlightStep(
                  targetKey: carte,
                  ecran: 'ÉCRAN',
                  title: 'Grande carte',
                  description: 'Corps',
                ),
              ],
              child: Scaffold(
                body: Column(
                  children: [
                    // Carte haute, centrée légèrement sous le milieu de l'écran :
                    // c'est la configuration qui faisait recouvrir la pièce de la
                    // semaine par son infobulle.
                    Container(key: carte, height: 420, color: Colors.amber),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    container.read(spotlightTourProvider.notifier).startTour();
    await tester.pumpAndSettle();

    final cible = tester.getRect(find.byKey(carte));
    final bulle = tester.getRect(find.text('Grande carte'));
    expect(bulle.top, greaterThan(cible.bottom));
  });
}
