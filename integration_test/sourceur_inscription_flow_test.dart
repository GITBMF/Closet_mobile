import 'package:closet/core/router/app_router.dart';
import 'package:closet/core/widgets/closet_buttons.dart';
import 'package:closet/data/repositories/sourceur_repository.dart';
import 'package:closet/features/auth/auth_screen.dart';
import 'package:closet/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// Parcours d'inscription sourceur de bout en bout.
///
/// Contrairement aux tests widget, rien n'est simulé ici : vrai routeur avec
/// ses redirections, vrai `SourceurRepository` avec sa latence, vrais écrans.
/// Seule l'authentification est forcée, faute de backend pour la fournir.
///
/// Exécution : `flutter test integration_test/sourceur_inscription_flow_test.dart -d <device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // `main()` charge le .env ; on l'initialise à vide pour que tout code
    // lisant dotenv trouve une instance prête plutôt qu'une erreur.
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  late ProviderContainer container;

  Future<void> demarrerSurInscription(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [isAuthenticatedProvider.overrideWith((ref) => true)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ClosetApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    container.read<GoRouter>(appRouterProvider).go('/sourceur/inscription');
    await tester.pumpAndSettle();
  }

  Future<void> taper(WidgetTester tester, Finder cible) async {
    await tester.ensureVisible(cible);
    await tester.pumpAndSettle();
    await tester.tap(cible, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'un visiteur authentifié devient partenaire en trois étapes',
    (tester) async {
      await demarrerSurInscription(tester);

      final repo = container.read<SourceurRepository>(
        sourceurRepositoryProvider,
      );
      expect(
        repo.estInscrit,
        isFalse,
        reason: 'aucune inscription avant le parcours',
      );

      // ── Étape 1 — ATELIER ────────────────────────────────────────────────
      expect(find.text('Devenir Sourceur'), findsOneWidget);
      expect(find.text('NOM DE VOTRE ATELIER'), findsOneWidget);

      final champsAtelier = find.byType(TextField);
      await tester.enterText(champsAtelier.at(0), "L'Atelier d'Awa");
      await tester.enterText(champsAtelier.at(1), 'Yaoundé');
      await tester.enterText(champsAtelier.at(2), '+237 6 77 45 22 18');
      await tester.pumpAndSettle();

      await taper(
        tester,
        find.widgetWithText(ClosetPrimaryButton, 'Continuer'),
      );

      // ── Étape 2 — UNIVERS ────────────────────────────────────────────────
      expect(find.text('SPÉCIALITÉ'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).first,
        'Pièces chinées, coupes structurées.',
      );
      await tester.pumpAndSettle();
      await taper(tester, find.text('Robes'));
      await taper(
        tester,
        find.widgetWithText(ClosetPrimaryButton, 'Continuer'),
      );

      // ── Étape 3 — PAIEMENT ───────────────────────────────────────────────
      expect(find.text('TYPE DE COLLABORATION'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).first,
        '+237 6 99 00 11 22',
      );
      await tester.pumpAndSettle();
      await taper(tester, find.text('Orange Money'));

      await taper(
        tester,
        find.widgetWithText(ClosetPrimaryButton, 'Rejoindre le cercle'),
      );

      // Le dépôt réel simule 800 ms de latence réseau.
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ── Résultat ─────────────────────────────────────────────────────────
      expect(
        repo.estInscrit,
        isTrue,
        reason: 'le parcours doit rendre le compte partenaire',
      );
      expect(repo.profile!.nomAtelier, "L'Atelier d'Awa");
      expect(repo.profile!.ville, 'Yaoundé');
      expect(repo.profile!.univers, 'Pièces chinées, coupes structurées.');

      // On a quitté l'inscription pour l'écran de statut d'adhésion.
      expect(find.text('NOM DE VOTRE ATELIER'), findsNothing);
    },
  );

  testWidgets(
    'la redirection ramène un non-partenaire vers l\'inscription',
    (tester) async {
      container = ProviderContainer(
        overrides: [isAuthenticatedProvider.overrideWith((ref) => true)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ClosetApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Un espace sourceur protégé, demandé sans être encore partenaire.
      container.read<GoRouter>(appRouterProvider).go('/sourceur/pieces');
      await tester.pumpAndSettle();

      expect(
        find.text('Devenir Sourceur'),
        findsOneWidget,
        reason: 'le garde du routeur doit imposer le parcours d\'adhésion',
      );
    },
  );

  testWidgets(
    'le bouton Retour de l\'étape 1 ne laisse pas l\'écran sans issue',
    (tester) async {
      await demarrerSurInscription(tester);

      // Sur une pile réduite à l'inscription, `context.pop()` n'a rien à
      // dépiler : on vérifie qu'aucune exception ne remonte et que l'écran
      // reste utilisable.
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
