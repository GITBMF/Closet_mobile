import 'package:closet/core/widgets/closet_buttons.dart';
import 'package:closet/data/bff_client/api_client.dart';
import 'package:closet/data/repositories/sourceur_repository.dart';
import 'package:closet/features/sourceur/inscription/sourceur_inscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Dépôt espion : capture ce que l'écran transmet réellement, sans latence.
class _RepoEspion extends SourceurRepository {
  _RepoEspion() : super(BffClient());
  SourceurInscriptionData? recu;
  int appels = 0;

  @override
  Future<SourceurProfile> inscrire(SourceurInscriptionData data) async {
    appels++;
    recu = data;
    return SourceurProfile(
      nomAtelier: data.nomAtelier,
      ville: data.ville,
      depuis: 'Août 2026',
      whatsapp: data.whatsapp,
      univers: data.univers,
    );
  }
}

const _ecranAdhesion = 'ÉCRAN ADHÉSION';

void main() {
  late _RepoEspion repo;

  setUp(() => repo = _RepoEspion());

  /// Monte l'écran seul, avec un routeur minimal offrant la destination
  /// d'arrivée et une page en amont pour tester le bouton retour.
  Future<void> monter(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/sourceur/inscription',
      routes: [
        GoRoute(
          path: '/sourceur/inscription',
          builder: (_, _) => const SourceurInscriptionScreen(),
        ),
        GoRoute(
          path: '/sourceur/adhesion',
          builder: (_, _) => const Scaffold(body: Text(_ecranAdhesion)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sourceurRepositoryProvider.overrideWith((ref) => repo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  ClosetPrimaryButton bouton(WidgetTester tester, String label) {
    return tester.widget<ClosetPrimaryButton>(
      find.widgetWithText(ClosetPrimaryButton, label),
    );
  }

  Future<void> taper(WidgetTester tester, Finder cible) async {
    await tester.ensureVisible(cible);
    await tester.pumpAndSettle();
    // `ClosetPrimaryButton` s'enveloppe dans un ScaleTransition : le contrôle
    // de survol vise le RenderTransform et prévient à tort, alors que le tap
    // atteint bien l'InkWell en dessous.
    await tester.tap(cible, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  /// Remplit l'étape ATELIER puis passe à la suivante.
  Future<void> remplirAtelier(WidgetTester tester) async {
    final champs = find.byType(TextField);
    await tester.enterText(champs.at(0), 'Atelier Ngo Bell');
    await tester.enterText(champs.at(1), 'Douala');
    await tester.enterText(champs.at(2), '+237 6 99 88 77 66');
    await tester.pumpAndSettle();
    await taper(tester, find.widgetWithText(ClosetPrimaryButton, 'Continuer'));
  }

  /// Remplit l'étape UNIVERS puis passe à la suivante.
  Future<void> remplirUnivers(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextField).first,
      'Pièces chinées, coupes structurées.',
    );
    await tester.pumpAndSettle();
    await taper(tester, find.text('Robes'));
    await taper(tester, find.widgetWithText(ClosetPrimaryButton, 'Continuer'));
  }

  /// Remplit l'étape PAIEMENT sans soumettre.
  Future<void> remplirPaiement(WidgetTester tester) async {
    await tester.enterText(
      find.byType(TextField).first,
      '+237 6 99 00 11 22',
    );
    await tester.pumpAndSettle();
  }

  group('Étape 1 — ATELIER', () {
    testWidgets('s\'affiche en premier, sans bouton retour', (tester) async {
      await monter(tester);

      expect(find.text('Devenir Sourceur'), findsOneWidget);
      expect(find.text('NOM DE VOTRE ATELIER'), findsOneWidget);
      expect(find.text('VILLE'), findsOneWidget);
      expect(find.text('TÉLÉPHONE WHATSAPP'), findsOneWidget);
      expect(find.widgetWithText(ClosetOutlineButton, 'Retour'), findsNothing);
    });

    testWidgets('le bouton Continuer est inactif à l\'ouverture',
        (tester) async {
      await monter(tester);

      expect(bouton(tester, 'Continuer').onPressed, isNull);
    });

    testWidgets('un champ vide suffit à garder le bouton inactif',
        (tester) async {
      await monter(tester);

      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), 'Atelier Ngo Bell');
      await tester.enterText(champs.at(1), 'Douala');
      await tester.pumpAndSettle();

      expect(bouton(tester, 'Continuer').onPressed, isNull);
    });

    testWidgets('une saisie d\'espaces ne vaut pas un champ rempli',
        (tester) async {
      await monter(tester);

      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), '   ');
      await tester.enterText(champs.at(1), '   ');
      await tester.enterText(champs.at(2), '   ');
      await tester.pumpAndSettle();

      expect(bouton(tester, 'Continuer').onPressed, isNull);
    });

    testWidgets('les trois champs remplis activent le bouton', (tester) async {
      await monter(tester);

      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), 'Atelier Ngo Bell');
      await tester.enterText(champs.at(1), 'Douala');
      await tester.enterText(champs.at(2), '+237 6 99 88 77 66');
      await tester.pumpAndSettle();

      expect(bouton(tester, 'Continuer').onPressed, isNotNull);
    });
  });

  group('Étape 2 — UNIVERS', () {
    testWidgets('est atteinte après validation de l\'atelier', (tester) async {
      await monter(tester);
      await remplirAtelier(tester);

      expect(find.text('VOTRE UNIVERS EN QUELQUES MOTS'), findsOneWidget);
      expect(find.text('SPÉCIALITÉ'), findsOneWidget);
      expect(find.widgetWithText(ClosetOutlineButton, 'Retour'), findsOneWidget);
    });

    testWidgets('exige à la fois le texte et une spécialité', (tester) async {
      await monter(tester);
      await remplirAtelier(tester);

      expect(bouton(tester, 'Continuer').onPressed, isNull);

      await tester.enterText(find.byType(TextField).first, 'Mon univers.');
      await tester.pumpAndSettle();
      expect(
        bouton(tester, 'Continuer').onPressed,
        isNull,
        reason: 'le texte seul ne doit pas suffire',
      );

      await taper(tester, find.text('Robes'));
      expect(bouton(tester, 'Continuer').onPressed, isNotNull);
    });

    testWidgets('Retour ramène à l\'atelier en préservant les saisies',
        (tester) async {
      await monter(tester);
      await remplirAtelier(tester);

      await taper(
        tester,
        find.widgetWithText(ClosetOutlineButton, 'Retour'),
      );

      expect(find.text('NOM DE VOTRE ATELIER'), findsOneWidget);
      expect(find.text('Atelier Ngo Bell'), findsOneWidget);
      expect(find.text('Douala'), findsOneWidget);
      expect(bouton(tester, 'Continuer').onPressed, isNotNull);
    });
  });

  group('Étape 3 — PAIEMENT', () {
    testWidgets('est atteinte et propose le bouton final', (tester) async {
      await monter(tester);
      await remplirAtelier(tester);
      await remplirUnivers(tester);

      expect(find.text('TYPE DE COLLABORATION'), findsOneWidget);
      expect(find.text('MOYEN DE RÉMUNÉRATION'), findsOneWidget);
      expect(
        find.widgetWithText(ClosetPrimaryButton, 'Rejoindre le cercle'),
        findsOneWidget,
      );
    });

    testWidgets('le numéro est obligatoire pour soumettre', (tester) async {
      await monter(tester);
      await remplirAtelier(tester);
      await remplirUnivers(tester);

      expect(bouton(tester, 'Rejoindre le cercle').onPressed, isNull);

      await remplirPaiement(tester);

      expect(bouton(tester, 'Rejoindre le cercle').onPressed, isNotNull);
    });
  });

  group('Soumission', () {
    testWidgets('transmet les saisies au dépôt puis redirige vers l\'adhésion',
        (tester) async {
      await monter(tester);
      await remplirAtelier(tester);
      await remplirUnivers(tester);
      await remplirPaiement(tester);

      await taper(
        tester,
        find.widgetWithText(ClosetPrimaryButton, 'Rejoindre le cercle'),
      );
      await taper(
        tester,
        find.widgetWithText(ClosetPrimaryButton, 'OK'),
      );

      expect(repo.appels, 1);
      expect(repo.recu, isNotNull);
      expect(repo.recu!.nomAtelier, 'Atelier Ngo Bell');
      expect(repo.recu!.ville, 'Douala');
      expect(repo.recu!.whatsapp, '+237 6 99 88 77 66');
      expect(repo.recu!.univers, 'Pièces chinées, coupes structurées.');
      expect(repo.recu!.specialite, 'Robes');
      expect(repo.recu!.numeroPaiement, '+237 6 99 00 11 22');
      expect(find.text(_ecranAdhesion), findsOneWidget);
    });

    testWidgets('retient MTN MoMo par défaut si aucun choix n\'est fait',
        (tester) async {
      await monter(tester);
      await remplirAtelier(tester);
      await remplirUnivers(tester);
      await remplirPaiement(tester);

      await taper(
        tester,
        find.widgetWithText(ClosetPrimaryButton, 'Rejoindre le cercle'),
      );

      expect(repo.recu!.moyenPaiement, 'MTN MoMo');
    });

    testWidgets('transmet le moyen de paiement sélectionné', (tester) async {
      await monter(tester);
      await remplirAtelier(tester);
      await remplirUnivers(tester);
      await remplirPaiement(tester);

      await taper(tester, find.text('Orange Money'));
      await taper(
        tester,
        find.widgetWithText(ClosetPrimaryButton, 'Rejoindre le cercle'),
      );

      expect(repo.recu!.moyenPaiement, 'Orange Money');
    });
  });

  group('Écarts connus du parcours', () {
    testWidgets(
      'ÉCART — le type de collaboration choisi n\'atteint pas le dépôt',
      (tester) async {
        await monter(tester);
        await remplirAtelier(tester);
        await remplirUnivers(tester);
        await remplirPaiement(tester);

        // On choisit explicitement la vente directe, à l'opposé du défaut.
        await taper(tester, find.text('Vente directe (achat immédiat)'));
        await taper(
          tester,
          find.widgetWithText(ClosetPrimaryButton, 'Rejoindre le cercle'),
        );

        // SourceurInscriptionData n'a aucun champ pour porter ce choix :
        // il est perdu entre l'écran et la couche données. Ce test verrouille
        // le constat ; il devra être réécrit quand le champ sera ajouté.
        expect(repo.recu, isNotNull);
        expect(
          repo.recu.toString(),
          isNot(contains('Vente directe')),
          reason: 'le type de collaboration devrait être transmis',
        );
      },
    );

    testWidgets(
      'ÉCART — la commission de 25% est affichée même en vente directe',
      (tester) async {
        await monter(tester);
        await remplirAtelier(tester);
        await remplirUnivers(tester);

        await taper(tester, find.text('Vente directe (achat immédiat)'));

        expect(
          find.textContaining('commission de 25%'),
          findsOneWidget,
          reason: 'texte contradictoire avec le mode de vente directe',
        );
      },
    );

    testWidgets(
      'ÉCART — un numéro WhatsApp manifestement invalide est accepté',
      (tester) async {
        await monter(tester);

        final champs = find.byType(TextField);
        await tester.enterText(champs.at(0), 'a');
        await tester.enterText(champs.at(1), 'a');
        await tester.enterText(champs.at(2), 'a');
        await tester.pumpAndSettle();

        expect(
          bouton(tester, 'Continuer').onPressed,
          isNotNull,
          reason: 'aucun contrôle de format sur le téléphone',
        );
      },
    );
  });
}
