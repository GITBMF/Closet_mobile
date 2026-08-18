import 'package:flutter/foundation.dart';

/// Nature de l'opération qui traverse le tunnel de transaction.
///
/// La maquette dessine un seul tunnel (`32:704` → `32:865`) et le réutilise
/// dans deux parcours : le retrait d'argent du sourceur (`39:2142`) et le
/// paiement d'une commande cliente (`39:3183`). Seuls les libellés changent.
enum TypeOperation {
  /// Le sourceur retire ses gains.
  retrait,

  /// La cliente règle sa sélection.
  paiement,
}

extension LibellesOperation on TypeOperation {
  /// Libellé du montant sur le reçu (« Total retiré » / « Total payé »).
  String get libelleTotal => switch (this) {
        TypeOperation.retrait => 'Total retiré',
        TypeOperation.paiement => 'Total payé',
      };

  /// Libellé de la ligne « mode » sur le reçu.
  String get libelleMode => switch (this) {
        TypeOperation.retrait => 'Mode de Retrait',
        TypeOperation.paiement => 'Mode de Paiement',
      };

  /// Destination du bouton de sortie.
  String get routeRetour => switch (this) {
        TypeOperation.retrait => '/sourceur/espace',
        TypeOperation.paiement => '/espace',
      };
}

/// Ce qu'on demande au tunnel d'exécuter.
@immutable
class DemandeTransaction {
  const DemandeTransaction({
    required this.type,
    required this.montant,
    required this.moyen,
    required this.compte,
    required this.beneficiaire,
    this.note,
  });

  final TypeOperation type;

  /// Montant en FCFA.
  final double montant;

  /// Moyen retenu (« Carte Visa », « Orange Money »…).
  final String moyen;

  /// Numéro de compte ou de carte, tel que fourni.
  ///
  /// Ne jamais l'afficher directement : passer par [compteMasque].
  final String compte;

  /// Numéro tronqué pour l'affichage : seuls les 4 derniers caractères
  /// restent visibles. Un reçu est partagé et capturé — il ne doit pas
  /// porter le numéro complet.
  String get compteMasque {
    final net = compte.replaceAll(RegExp(r'\s'), '');
    if (net.length <= 4) return net;
    return '•••• ${net.substring(net.length - 4)}';
  }

  /// Nom affiché sur le reçu.
  final String beneficiaire;

  final String? note;
}

/// Détails de pièce affichés sur le reçu commande (maquette reçu ClosEt).
@immutable
class DetailPieceRecu {
  const DetailPieceRecu({
    required this.marque,
    required this.categorie,
    required this.taille,
    required this.etat,
    required this.livraison,
  });

  final String marque;
  final String categorie;
  final String taille;
  final String etat;
  final String livraison;
}

/// Ce que le tunnel produit une fois l'opération acceptée.
@immutable
class RecuTransaction {
  const RecuTransaction({
    required this.demande,
    required this.numero,
    required this.reference,
    required this.horodatage,
    this.piece,
  });

  final DemandeTransaction demande;

  /// Numéro de transaction affiché en tête du reçu.
  final String numero;

  /// Numéro de référence de l'opérateur.
  final String reference;

  final DateTime horodatage;

  /// Présent sur un reçu d'achat ; absent sur un retrait sourceur.
  final DetailPieceRecu? piece;
}
