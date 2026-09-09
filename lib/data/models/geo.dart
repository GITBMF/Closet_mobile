import 'package:flutter/foundation.dart';

/// Découpage administratif servant à l'adresse de livraison.
///
/// Les trois classes ci-dessous reprennent **la forme des DTO du backend**
/// (`RegionOut`, `DivisionOut`, `CityOut` de `design/openapi.json`) : mêmes
/// champs, mêmes types, identifiants entiers. Les données sont pour l'instant
/// celles de la maquette (`geo_repository.dart`), mais le passage aux appels
/// `GET /geo/regions`, `GET /geo/regions/{id}/divisions` et `GET /geo/cities`
/// ne demandera aucun changement côté écrans.

/// Une région — `GET /geo/regions`.
@immutable
class Region {
  const Region({required this.id, required this.nom, required this.code});

  final int id;
  final String nom;

  /// Code court de la région (« CE » pour le Centre).
  final String code;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id'] as int,
        nom: json['name'] as String,
        code: json['code'] as String,
      );

  @override
  bool operator ==(Object other) => other is Region && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Un département — `GET /geo/regions/{id}/divisions`.
///
/// Le backend l'appelle « division » ; la maquette et l'usage camerounais
/// disent « département ». Le nom métier est retenu ici, le champ `regionId`
/// conservant la correspondance avec `DivisionOut.region_id`.
@immutable
class Departement {
  const Departement({
    required this.id,
    required this.regionId,
    required this.nom,
  });

  final int id;
  final int regionId;
  final String nom;

  factory Departement.fromJson(Map<String, dynamic> json) => Departement(
        id: json['id'] as int,
        regionId: json['region_id'] as int,
        nom: json['name'] as String,
      );

  @override
  bool operator ==(Object other) => other is Departement && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Une ville livrable — `GET /geo/cities`.
///
/// La maquette (`162:5536`) propose une saisie simplifiée par ville, avec le
/// délai annoncé sous chaque entrée, et une option « Autre » dont le tarif est
/// à devis. [delaiAnnonce] et [aDevis] portent cette information ; côté
/// backend elle vient du tarif (`GET /delivery/quote` renvoie
/// `quote_required`).
@immutable
class Ville {
  const Ville({
    required this.id,
    required this.nom,
    required this.regionId,
    required this.delaiAnnonce,
    this.aDevis = false,
  });

  final int id;
  final String nom;
  final int regionId;

  /// Délai affiché sous le nom de la ville (« Livraison à domicile 24h-48h »).
  final String delaiAnnonce;

  /// Zone non tarifée : le montant de livraison doit être devisé à la main.
  final bool aDevis;

  factory Ville.fromJson(Map<String, dynamic> json) => Ville(
        id: json['id'] as int,
        nom: json['name'] as String,
        regionId: json['region_id'] as int,
        delaiAnnonce: json['delivery_eta'] as String? ??
            'Livraison à domicile disponible sous 24h à 48h après la commande *',
        aDevis: json['quote_required'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) => other is Ville && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Quartier — `GET /geo/cities/{id}/neighbourhoods`.
@immutable
class Quartier {
  const Quartier({
    required this.id,
    required this.villeId,
    required this.nom,
  });

  final int id;
  final int villeId;
  final String nom;

  factory Quartier.fromJson(Map<String, dynamic> json) => Quartier(
        id: json['id'] as int,
        villeId: json['city_id'] as int,
        nom: json['name'] as String,
      );

  @override
  bool operator ==(Object other) => other is Quartier && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
