import 'package:flutter/foundation.dart';

import '../api/api_json.dart';

enum StatutCommande {
  pending,
  paid,
  preparation,
  enRoute,
  livree,
  annulee,
  devis,
}

extension LibelleStatutCommande on StatutCommande {
  String get libelle => switch (this) {
        StatutCommande.pending => 'En attente',
        StatutCommande.paid => 'Payée',
        StatutCommande.preparation => 'Préparation',
        StatutCommande.enRoute => 'En route',
        StatutCommande.livree => 'Livrée',
        StatutCommande.annulee => 'Annulée',
        StatutCommande.devis => 'Devis',
      };
}

StatutCommande statutCommandeDepuis(String brut) {
  return switch (brut) {
    'pending' => StatutCommande.pending,
    'paid' => StatutCommande.paid,
    'preparing' || 'ready' => StatutCommande.preparation,
    'delivering' => StatutCommande.enRoute,
    'completed' => StatutCommande.livree,
    'cancelled' => StatutCommande.annulee,
    'quote_required' => StatutCommande.devis,
    _ => StatutCommande.preparation,
  };
}

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
      articleId: chaineDe(json['piece_id'], chaineDe(json['articleId'])),
      maison: chaineDe(json['maison']),
      nom: chaineDe(json['title'], chaineDe(json['nom'])),
      prix: montantDe(json['price'] ?? json['prix']),
      etat: chaineDe(json['etat']),
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
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

@immutable
class Commande {
  const Commande({
    required this.numero,
    required this.statut,
    required this.dateDepot,
    required this.lignes,
    required this.livraison,
    this.id,
    this.estimation,
    this.adresseLivraison,
    this.remise = 0,
    this.total,
  });

  final String? id;
  final String numero;
  final StatutCommande statut;
  final DateTime dateDepot;
  final List<LigneCommande> lignes;
  final double livraison;
  final DateTime? estimation;
  final String? adresseLivraison;
  final double remise;
  final double? total;

  double get sousTotal =>
      lignes.fold<double>(0, (somme, l) => somme + l.prix);

  double get totalCalcule => total ?? (sousTotal - remise + livraison);

  factory Commande.fromJson(Map<String, dynamic> json) {
    final adresse = json['delivery_address'];
    var adresseTexte = json['adresseLivraison'] as String?;
    if (adresseTexte == null && adresse is Map) {
      final morceaux = [
        adresse['line1'],
        adresse['neighbourhood'],
        adresse['landmark'],
      ].whereType<Object>().map((e) => e.toString()).where((e) => e.isNotEmpty);
      adresseTexte = morceaux.join(', ');
    }

    return Commande(
      id: json['id'] as String?,
      numero: chaineDe(json['order_number'], chaineDe(json['numero'])),
      statut: statutCommandeDepuis(chaineDe(json['status'], chaineDe(json['statut']))),
      dateDepot: dateDe(json['placed_at']) ??
          dateDe(json['created_at']) ??
          dateDe(json['dateDepot']) ??
          DateTime.now(),
      lignes: [
        for (final l in objetsDe(json['items'] ?? json['lignes']))
          LigneCommande.fromJson(l),
      ],
      livraison: montantDe(json['delivery_fee'] ?? json['livraison']),
      estimation: dateDe(json['estimation']),
      adresseLivraison: adresseTexte,
      remise: montantDe(json['discount_amount']),
      total: json['total'] == null ? null : montantDe(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'statut': statut.name,
        'dateDepot': dateDepot.toIso8601String(),
        'lignes': [for (final l in lignes) l.toJson()],
        'livraison': livraison,
        'estimation': estimation?.toIso8601String(),
        'adresseLivraison': adresseLivraison,
      };
}
