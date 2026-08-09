import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/adresse.dart';

final adresseRepositoryProvider = Provider<AdresseRepository>((ref) {
  return AdresseRepository();
});

/// Adresses enregistrées de la cliente connectée.
final mesAdressesProvider = FutureProvider<List<Adresse>>((ref) {
  return ref.watch(adresseRepositoryProvider).getMesAdresses();
});

/// Accès aux adresses de livraison.
///
/// TODO(backend): remplacer les données simulées par les appels API.
class AdresseRepository {
  Future<List<Adresse>> getMesAdresses() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _adressesSimulees;
  }
}

const List<Adresse> _adressesSimulees = [
  Adresse(
    id: '1',
    libelle: 'Maison',
    ligne: '61480 Sunbrook Park, PC 5679',
    type: TypeAdresse.maison,
    parDefaut: true,
  ),
  Adresse(
    id: '2',
    libelle: 'Bureau',
    ligne: '69993 Meadow Valley Terra, PC 3637',
    type: TypeAdresse.bureau,
  ),
  Adresse(
    id: '3',
    libelle: 'Appartement',
    ligne: '21833 Clyde Gallagher, PC 4662',
    type: TypeAdresse.appartement,
  ),
  Adresse(
    id: '4',
    libelle: 'Maison Familiale',
    ligne: '5259 Blue Bill Park, PC 4627',
    type: TypeAdresse.autre,
  ),
];
