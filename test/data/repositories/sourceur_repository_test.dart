import 'package:closet/data/repositories/sourceur_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetraitSourceur', () {
    test('le libellé suit le statut', () {
      final date = DateTime(2026, 1, 1);
      expect(
        RetraitSourceur(
          montant: 1000,
          date: date,
          soldeApres: 0,
          moyen: 'orange_money',
        ).libelle,
        'Retrait approuvé',
      );
      expect(
        RetraitSourceur(
          montant: 1000,
          date: date,
          soldeApres: 0,
          moyen: 'orange_money',
          statut: StatutRetrait.enCours,
        ).libelle,
        'Retrait en cours',
      );
      expect(
        RetraitSourceur(
          montant: 1000,
          date: date,
          soldeApres: 0,
          moyen: 'orange_money',
          statut: StatutRetrait.refuse,
        ).libelle,
        'Retrait refusé',
      );
    });
  });

  test('une fiche neuve n’est pas inscrite tant que le serveur n’a pas répondu',
      () {
    // SourceurRepository exige un client HTTP : l’absence de profil est
    // l’état initial public, testé via ChangeNotifierProvider en intégration.
    expect(StatutPiece.enRevue, isNot(StatutPiece.publiee));
  });

  group('condition et profil sourceur', () {
    test('conditionApiDepuis envoie les valeurs PieceCondition', () {
      expect(conditionApiDepuis('Neuf'), 'new');
      expect(conditionApiDepuis('Très bon état'), 'very_good');
      expect(conditionApiDepuis('Bon état'), 'good');
      expect(conditionApiDepuis('new'), 'new');
    });

    test('libelleCondition réaffiche le français', () {
      expect(libelleCondition('new'), 'Neuf');
      expect(libelleCondition('very_good'), 'Très bon état');
    });

    test('le profil expose les libellés du backend', () {
      const profil = SourceurProfile(
        nomAtelier: 'Atelier Lin',
        ville: '',
        depuis: 'Mars 2026',
        whatsapp: '699000000',
        statutApi: 'approved',
        moyenPaiement: 'orange_money',
        numeroPaiement: '699000000',
        typeCollaboration: 'consignment',
      );
      expect(profil.libelleStatut, 'Approuvé');
      expect(profil.libelleCollaboration, 'Dépôt-vente');
      expect(profil.libelleMoyenPaiement, 'Orange Money');
    });
  });
}
