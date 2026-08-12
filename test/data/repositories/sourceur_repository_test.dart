import 'package:closet/data/repositories/sourceur_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Jeu de données d'inscription complet, tel qu'un sourceur le saisirait.
const _donnees = SourceurInscriptionData(
  nomAtelier: "L'Atelier d'Awa",
  ville: 'Yaoundé',
  whatsapp: '+237 6 77 45 22 18',
  univers: 'Pièces chinées, coupes structurées.',
  specialite: 'Robes',
  moyenPaiement: 'Orange Money',
  numeroPaiement: '+237 6 99 00 11 22',
);

String _moisAnneeCourants() {
  final now = DateTime.now();
  const mois = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  return '${mois[now.month - 1]} ${now.year}';
}

PieceDeposee _piece({
  required String id,
  required double prix,
  required StatutPiece statut,
  String nom = 'Robe en tweed',
}) {
  return PieceDeposee(
    id: id,
    nom: nom,
    univers: 'Robes',
    prix: prix,
    statut: statut,
  );
}

void main() {
  late SourceurRepository repo;

  setUp(() => repo = SourceurRepository());

  group('SourceurRepository — inscription', () {
    test('un dépôt neuf n\'a ni profil ni statut de partenaire', () {
      expect(repo.estInscrit, isFalse);
      expect(repo.profile, isNull);
    });

    test('inscrire() crée le profil et fait basculer estInscrit', () async {
      final profil = await repo.inscrire(_donnees);

      expect(repo.estInscrit, isTrue);
      expect(repo.profile, same(profil));
    });

    test('inscrire() reporte atelier, ville, whatsapp et univers', () async {
      final profil = await repo.inscrire(_donnees);

      expect(profil.nomAtelier, "L'Atelier d'Awa");
      expect(profil.ville, 'Yaoundé');
      expect(profil.whatsapp, '+237 6 77 45 22 18');
      expect(profil.univers, 'Pièces chinées, coupes structurées.');
    });

    test('inscrire() horodate l\'adhésion au mois courant', () async {
      final profil = await repo.inscrire(_donnees);

      expect(profil.depuis, _moisAnneeCourants());
    });

    test('inscrire() notifie ses auditeurs une seule fois', () async {
      var notifications = 0;
      repo.addListener(() => notifications++);

      await repo.inscrire(_donnees);

      expect(notifications, 1);
    });

    test('une seconde inscription remplace le profil précédent', () async {
      await repo.inscrire(_donnees);
      final second = await repo.inscrire(
        const SourceurInscriptionData(
          nomAtelier: 'Maison Bibi',
          ville: 'Douala',
          whatsapp: '+237 6 00 00 00 00',
          univers: 'Sacs en raphia.',
          moyenPaiement: 'MTN MoMo',
          numeroPaiement: '+237 6 11 11 11 11',
        ),
      );

      expect(repo.profile, same(second));
      expect(repo.profile!.nomAtelier, 'Maison Bibi');
    });

    test('updateProfile() remplace le profil et notifie', () async {
      await repo.inscrire(_donnees);
      var notifications = 0;
      repo.addListener(() => notifications++);

      repo.updateProfile(repo.profile!.copyWith(ville: 'Kribi'));

      expect(repo.profile!.ville, 'Kribi');
      expect(repo.profile!.nomAtelier, "L'Atelier d'Awa");
      expect(notifications, 1);
    });
  });

  group('SourceurRepository — écarts connus de l\'inscription', () {
    // Ces trois données sont saisies dans le parcours puis reçues par
    // inscrire(), mais SourceurProfile n'a aucun champ pour les porter :
    // elles sont perdues à la soumission. Retirer le `skip` une fois les
    // champs ajoutés au modèle — le test doit alors être complété.
    test(
      'la spécialité choisie devrait être conservée dans le profil',
      () async {
        await repo.inscrire(_donnees);
        fail('SourceurProfile ne porte pas encore de champ `specialite`.');
      },
      skip: 'Écart connu : `specialite` est reçue par inscrire() puis ignorée.',
    );

    test(
      'le moyen et le numéro de paiement devraient être conservés',
      () async {
        await repo.inscrire(_donnees);
        fail(
          'SourceurProfile ne porte ni `moyenPaiement` ni `numeroPaiement`.',
        );
      },
      skip: 'Écart connu : toute l\'étape PAIEMENT est perdue à la soumission.',
    );
  });

  group('SourceurRepository — pièces déposées', () {
    test('un dépôt neuf n\'a aucune pièce', () async {
      expect(await repo.getMesPieces(), isEmpty);
    });

    test('deposerPiece() ajoute la pièce et notifie', () async {
      var notifications = 0;
      repo.addListener(() => notifications++);

      await repo.deposerPiece(
        _piece(id: '1', prix: 40000, statut: StatutPiece.enRevue),
      );

      expect(await repo.getMesPieces(), hasLength(1));
      expect(notifications, 1);
    });

    test('la liste renvoyée est non modifiable', () async {
      final pieces = await repo.getMesPieces();

      expect(
        () => pieces.add(
          _piece(id: 'x', prix: 1, statut: StatutPiece.enRevue),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('SourceurRepository — revenus', () {
    test('sans pièce vendue, tous les montants sont à zéro', () async {
      await repo.deposerPiece(
        _piece(id: '1', prix: 40000, statut: StatutPiece.enRevue),
      );

      final revenus = await repo.getRevenus();

      expect(revenus.brut, 0);
      expect(revenus.commission, 0);
      expect(revenus.solde, 0);
      expect(revenus.historique, isEmpty);
    });

    test('la commission est de 25% du brut et le solde le reste', () async {
      await repo.deposerPiece(
        _piece(id: '1', prix: 40000, statut: StatutPiece.vendue),
      );

      final revenus = await repo.getRevenus();

      expect(revenus.brut, 40000);
      expect(revenus.commission, 10000);
      expect(revenus.solde, 30000);
    });

    test('seules les pièces vendues entrent dans le calcul', () async {
      await repo.deposerPiece(
        _piece(id: '1', prix: 40000, statut: StatutPiece.vendue),
      );
      await repo.deposerPiece(
        _piece(id: '2', prix: 100000, statut: StatutPiece.enRevue),
      );
      await repo.deposerPiece(
        _piece(id: '3', prix: 50000, statut: StatutPiece.refusee),
      );
      await repo.deposerPiece(
        _piece(id: '4', prix: 20000, statut: StatutPiece.vendue, nom: 'Sac'),
      );

      final revenus = await repo.getRevenus();

      expect(revenus.brut, 60000);
      expect(revenus.commission, 15000);
      expect(revenus.solde, 45000);
      expect(revenus.historique, hasLength(2));
      expect(
        revenus.historique.map((v) => v.nomPiece),
        containsAll(<String>['Robe en tweed', 'Sac']),
      );
    });

    test('la commission est tronquée, jamais arrondie au supérieur', () async {
      // 25% de 4 999 = 1 249,75 → doit donner 1 249.
      await repo.deposerPiece(
        _piece(id: '1', prix: 4999, statut: StatutPiece.vendue),
      );

      final revenus = await repo.getRevenus();

      expect(revenus.commission, 1249);
      expect(revenus.solde, 3750);
    });
  });
}
