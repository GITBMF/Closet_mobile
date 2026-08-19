import 'package:flutter/foundation.dart';

/// Nature de l'opération qui traverse le tunnel de transaction.
///
/// La maquette dessine **deux tunnels bâtis sur le même gabarit** :
///
/// - le retrait des gains du sourceur (`32:704` → `32:865`, parcours `39:2142`),
///   qui commence par un code PIN et se termine sur un reçu de retrait ;
/// - le paiement d'une sélection par la cliente (`162:5220` → `162:3473`,
///   parcours `39:3183`), **sans code PIN**, avec une frise 3 étapes visible
///   jusque sur l'écran de succès, et un reçu qui décrit la pièce achetée.
///
/// Ce ne sont donc pas seulement des libellés qui changent : les étapes et le
/// corps du reçu diffèrent. D'où les propriétés ci-dessous, qui pilotent le
/// tunnel plutôt que de le dupliquer.
enum TypeOperation {
  /// Le sourceur retire ses gains.
  retrait,

  /// La cliente règle sa sélection.
  paiement,
}

extension ComportementOperation on TypeOperation {
  /// Le code PIN n'appartient qu'au retrait.
  ///
  /// La maquette est explicite : `32:704` parle d'« un code PIN pour renforcer
  /// la sécurité de votre **portefeuille** ». Côté acheteuse, le backend
  /// délègue au fournisseur de paiement (`POST /payments/initiate` renvoie un
  /// `payment_url`), donc aucun code n'est saisi dans l'application.
  /// Le code PIN n'est plus demandé : l'API n'expose pas de portefeuille
  /// sourceur ni de validation PIN. Un retrait est refusé honnêtement.
  bool get exigePin => false;

  /// La frise « livraison · Paiement · Confirmation » n'existe que côté
  /// acheteuse, où elle reste affichée pendant le traitement et sur le succès.
  bool get afficheFrise => this == TypeOperation.paiement;

  /// Titre de l'écran de traitement (`162:5220` / `32:756`).
  String get titreTraitement => switch (this) {
        TypeOperation.retrait => 'Traitement en cours',
        TypeOperation.paiement => 'Paiement en cours',
      };

  /// Titre de l'écran de succès (`162:3351` / `32:813`).
  String get titreSucces => switch (this) {
        TypeOperation.retrait => 'Transaction reussie !',
        TypeOperation.paiement => 'Paiement reussi',
      };

  /// Message de succès, tel que la maquette l'écrit.
  String get messageSucces => switch (this) {
        TypeOperation.retrait =>
          'Votre opération a été effectuée avec succès. Vous allez recevoir '
              "un reçu de confirmation d'ici quelques instants.",
        TypeOperation.paiement =>
          'Votre paiement a été effectuée avec succès. Vous allez recevoir '
              "un reçu de confirmation d'ici quelques instants.",
      };

  /// Libellé du montant sur le reçu.
  ///
  /// La maquette affiche « Total retiré » sur les deux reçus, y compris celui
  /// de l'acheteuse (`162:3473`) — un report de copie du gabarit sourceur.
  /// « Total payé » est retenu côté acheteuse, où « retiré » n'a pas de sens.
  String get libelleTotal => switch (this) {
        TypeOperation.retrait => 'Total retiré',
        TypeOperation.paiement => 'Total payé',
      };

  /// Le reçu de retrait porte un numéro de référence opérateur ; celui de
  /// l'acheteuse décrit la pièce et n'en affiche pas.
  bool get afficheReference => this == TypeOperation.retrait;

  /// Libellé du bouton de sortie (`32:865` / `162:3473`).
  String get libelleSortie => switch (this) {
        TypeOperation.retrait => 'Retour dans Mon Espace',
        TypeOperation.paiement => 'Poursuivre ma visite',
      };

  /// Destination du bouton de sortie.
  String get routeRetour => switch (this) {
        TypeOperation.retrait => '/sourceur/espace',
        TypeOperation.paiement => '/dressing',
      };
}

/// Une ligne du corps du reçu : libellé à gauche, valeur à droite.
///
/// Le corps du reçu est la seule chose qui distingue vraiment les deux
/// opérations. Le composer au point d'appel évite d'avoir deux écrans de reçu.
@immutable
class LigneRecu {
  const LigneRecu(this.libelle, this.valeur);

  final String libelle;
  final String valeur;
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
    this.lignesRecu = const [],
    this.fraisLivraison = 0,
    this.note,
  });

  final TypeOperation type;

  /// Montant en FCFA. C'est la somme réellement engagée : pour un achat, le
  /// total à régler, remise déduite et livraison incluse.
  final double montant;

  /// Part de [montant] revenant à la livraison. Nulle pour un retrait.
  ///
  /// La commande enregistre ses frais de port séparément (`Commande.livraison`) ;
  /// les recalculer à partir du total obligerait à reconstituer la remise, ce
  /// qui est fragile. Ils voyagent donc explicitement.
  final double fraisLivraison;

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

  /// Corps du reçu, propre à l'opération : mode et compte pour un retrait
  /// (`32:865`), description de la pièce pour un achat (`162:3473`).
  final List<LigneRecu> lignesRecu;

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
    this.numeroCommande,
  });

  final DemandeTransaction demande;

  /// Numéro de transaction affiché en tête du reçu.
  final String numero;

  /// Numéro de référence de l'opérateur.
  final String reference;

  final DateTime horodatage;

  /// Numéro de commande, affiché sur l'écran de succès de l'acheteuse
  /// (« Commande N° ce-2641 », `162:3351`). Nul pour un retrait.
  final String? numeroCommande;
}
