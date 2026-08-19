import 'package:closet/data/models/geo.dart';
import 'package:closet/features/checkout/brouillon_commande.dart';
import 'package:closet/features/checkout/moyens_paiement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _yaounde = Ville(
  id: 1,
  nom: 'Yaoundé',
  regionId: 2,
  delaiAnnonce: 'Livraison à domicile 24h-48h',
);

const _centre = Region(id: 2, nom: 'Centre', code: 'CE');
const _mfoundi = Departement(id: 207, regionId: 2, nom: 'Mfoundi');
const _lekie = Departement(id: 202, regionId: 2, nom: 'Lekié');
const _littoral = Region(id: 5, nom: 'Littoral', code: 'LT');

void main() {
  late ProviderContainer container;
  late BrouillonCommandeNotifier brouillon;

  setUp(() {
    container = ProviderContainer();
    brouillon = container.read(brouillonCommandeProvider.notifier);
  });

  tearDown(() => container.dispose());

  BrouillonCommande etat() => container.read(brouillonCommandeProvider);

  group('Adresse — mode ville', () {
    test('une commande neuve est en mode ville et sans adresse', () {
      expect(etat().mode, ModeAdresse.ville);
      expect(etat().adresseComplete, isFalse);
    });

    test('choisir une ville suffit à compléter l’adresse', () {
      brouillon.choisirVille(_yaounde);

      expect(etat().adresseComplete, isTrue);
      expect(etat().adresseResumee, 'Yaoundé');
      expect(etat().villeIdPourDevis, 1);
    });
  });

  group('Adresse — mode cascade', () {
    setUp(() => brouillon.choisirMode(ModeAdresse.cascade));

    test('région seule ne suffit pas', () {
      brouillon.choisirRegion(_centre);
      expect(etat().adresseComplete, isFalse);
    });

    test('région + département + quartier complètent l’adresse', () {
      brouillon.choisirRegion(_centre);
      brouillon.choisirDepartement(_mfoundi);
      brouillon.majQuartier('Newtown Collège');

      expect(etat().adresseComplete, isTrue);
      expect(etat().adresseResumee, 'Mfoundi, Centre, Newtown Collège');
    });

    test('un quartier fait de blancs ne compte pas', () {
      brouillon.choisirRegion(_centre);
      brouillon.choisirDepartement(_mfoundi);
      brouillon.majQuartier('   ');

      expect(etat().adresseComplete, isFalse);
    });

    test('changer de région efface le département retenu', () {
      brouillon.choisirRegion(_centre);
      brouillon.choisirDepartement(_lekie);
      brouillon.choisirRegion(_littoral);

      expect(etat().departement, isNull);
      expect(etat().adresseComplete, isFalse);
    });

    test('la cascade ne tarifie pas par ville', () {
      brouillon.choisirRegion(_centre);
      expect(etat().villeIdPourDevis, isNull);
    });
  });

  group('Paiement', () {
    test('aucun moyen retenu = paiement incomplet', () {
      expect(etat().paiementComplet, isFalse);
    });

    test('le mobile money exige au moins 9 chiffres', () {
      brouillon.choisirMoyen(moyensPaiement.first);
      brouillon.majPaiement(numeroPaiement: '690 12 34');
      expect(etat().paiementComplet, isFalse);

      brouillon.majPaiement(numeroPaiement: '690 12 34 56');
      expect(etat().paiementComplet, isTrue);
    });

    test('la carte exige porteur, numéro, CVV et expiration', () {
      final visa = moyensPaiement.firstWhere((m) => m.id == 'visa');
      brouillon.choisirMoyen(visa);
      expect(etat().paiementComplet, isFalse);

      brouillon.majPaiement(
        porteurCarte: 'AICHA NGONO',
        numeroCarte: '4864 0000 0000 0000',
        cvv: '123',
      );
      expect(etat().paiementComplet, isFalse, reason: 'expiration manquante');

      brouillon.majPaiement(expiration: '08/28');
      expect(etat().paiementComplet, isTrue);
    });
  });

  group('Code privilège', () {
    test('un code renseigné est conservé, la remise reste au serveur', () {
      final applique =
          brouillon.appliquerCodePrivilege('SOLDES');

      expect(applique, isTrue);
      expect(etat().remise, 0);
      expect(etat().codePrivilege, 'SOLDES');
    });

    test('le code de la maquette est stocké sans remise locale', () {
      final applique = brouillon.appliquerCodePrivilege(
        'Cercle-Privilège',
      );

      expect(applique, isTrue);
      expect(etat().codePrivilege, 'Cercle-Privilège');
      expect(etat().remise, 0);
    });

    test('le retirer remet le code à vide', () {
      brouillon.appliquerCodePrivilege('cercle-privilege');
      brouillon.retirerCodePrivilege();

      expect(etat().remise, 0);
      expect(etat().codePrivilege, isEmpty);
    });
  });

  test('toute reprise de saisie invalide la validation précédente', () {
    brouillon.choisirVille(_yaounde);
    brouillon.validerCoordonnees();
    expect(etat().coordonneesValidees, isTrue);

    brouillon.majCoordonnees(telephone: '690123456');
    expect(etat().coordonneesValidees, isFalse);
  });
}
