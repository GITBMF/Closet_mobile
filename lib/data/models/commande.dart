import 'package:flutter/foundation.dart';

/// Statuts de commande dessinés dans la maquette `26:1255`.
enum StatutCommande { preparation, enRoute, livree }

extension LibelleStatutCommande on StatutCommande {
  String get libelle => switch (this) {
        StatutCommande.preparation => 'Préparation',
        StatutCommande.enRoute => 'En route',
        StatutCommande.livree => 'Livrée',
      };
}

/// Une pièce achetée, figée au moment de la commande.
///
/// Les valeurs sont **copiées** depuis l'article et non référencées : le prix
/// et l'état d'une commande passée ne doivent pas bouger si la fiche produit
/// est modifiée plus tard.
@immutable
class LigneCommande {
  const LigneCommande({
    required this.articleId,
    required this.maison,
    required this.nom,
    required this.prix,
    required this.etat,
    this.imageUrl,
  });

  final String articleId;
  final String maison;
  final String nom;
  final double prix;
  final String etat;
  final String? imageUrl;

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    return LigneCommande(
      articleId: json['articleId'] as String,
      maison: json['maison'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prix: (json['prix'] as num).toDouble(),
      etat: json['etat'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'articleId': articleId,
        'maison': maison,
        'nom': nom,
        'prix': prix,
        'etat': etat,
        'imageUrl': imageUrl,
      };
}

/// Une commande cliente — maquettes `25:1089` et `26:1262`.
@immutable
class Commande {
  const Commande({
    required this.numero,
    required this.statut,
    required this.dateDepot,
    required this.lignes,
    required this.livraison,
    this.estimation,
    this.adresseLivraison,
  });

  /// Numéro affiché, sans le croisillon (« CE-2641 »).
  final String numero;

  final StatutCommande statut;
  final DateTime dateDepot;
  final List<LigneCommande> lignes;

  /// Frais de livraison figés au moment de la commande.
  final double livraison;

  /// Date de livraison estimée. `null` quand elle n'est pas encore connue.
  final DateTime? estimation;

  final String? adresseLivraison;

  double get sousTotal =>
      lignes.fold<double>(0, (somme, l) => somme + l.prix);

  double get total => sousTotal + livraison;

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      numero: json['numero'] as String,
      statut: StatutCommande.values.firstWhere(
        (s) => s.name == json['statut'],
        orElse: () => StatutCommande.preparation,
      ),
      dateDepot: DateTime.parse(json['dateDepot'] as String),
      lignes: [
        for (final l in (json['lignes'] as List<dynamic>? ?? <dynamic>[]))
          LigneCommande.fromJson(l as Map<String, dynamic>),
      ],
      livraison: (json['livraison'] as num?)?.toDouble() ?? 0,
      estimation: json['estimation'] == null
          ? null
          : DateTime.parse(json['estimation'] as String),
      adresseLivraison: json['adresseLivraison'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'statut': statut.name,
        'dateDepot': dateDepot.toIso8601String(),
        'lignes': [for (final l in lignes) l.toJson()],
        'livraison': livraison,
        'estimation': estimation?.toIso8601String(),
        'adresseLivraison': adresseLivraison,
      };
}
