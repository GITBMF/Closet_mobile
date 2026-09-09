import 'package:flutter/material.dart';

/// Ce qu'un moyen de paiement réclame en plus de sa sélection.
enum SaisieMoyen {
  /// Rien à saisir.
  aucune,

  /// Un numéro de téléphone — mobile money (`162:4647`).
  telephone,

  /// Les champs d'une carte bancaire (`162:5427`).
  carte,
}

/// Un moyen de paiement de l'acheteuse — maquette `162:4255`.
///
/// Cette liste est **distincte des moyens de retrait du sourceur**
/// (`32:511`) : les deux parcours n'ont ni les mêmes options ni les mêmes
/// champs. Le checkout importait jusqu'ici la liste du module sourceur, ce qui
/// le rendait dépendant d'un écran vendeur et lui interdisait la carte
/// bancaire que la maquette prévoit.
@immutable
class MoyenPaiement {
  const MoyenPaiement({
    required this.id,
    required this.libelle,
    required this.icone,
    this.compteMasque = '',
    this.saisie = SaisieMoyen.aucune,
  });

  final String id;
  final String libelle;
  final IconData icone;

  /// Numéro déjà connu, affiché tronqué (« **** 4864 » sur la maquette).
  final String compteMasque;

  final SaisieMoyen saisie;

  /// Opérateur transmis au backend (`InitiateIn.operator`).
  String get operateur => id;
}

/// Les trois moyens de la feuille `162:4255`.
///
/// La maquette écrit « MTN Moblie Money » dans la feuille et « MTN Mobile
/// Money » une fois le choix fait : la seconde orthographe est retenue.
const List<MoyenPaiement> moyensPaiement = [
  MoyenPaiement(
    id: 'orange_money',
    libelle: 'Orange Money',
    icone: Icons.phone_android_rounded,
    saisie: SaisieMoyen.telephone,
  ),
  MoyenPaiement(
    id: 'mtn_momo',
    libelle: 'MTN Mobile Money',
    icone: Icons.phone_iphone_rounded,
    saisie: SaisieMoyen.telephone,
  ),
  MoyenPaiement(
    id: 'visa',
    libelle: 'Visa Card',
    icone: Icons.credit_card_rounded,
    compteMasque: '**** 4864',
    saisie: SaisieMoyen.carte,
  ),
];
