import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/geo.dart';
import 'moyens_paiement.dart';

/// Comment la cliente désigne son adresse.
///
/// La maquette propose deux saisies pour la même étape : la cascade
/// administrative Région → Département → Quartier (`162:3709`, `162:3844`) et
/// une sélection de ville plus directe (`162:5536`). Ce sont deux variantes du
/// même écran, pas deux écrans, d'où ce basculement.
enum ModeAdresse { ville, cascade }

/// Commande en cours de constitution.
///
/// Elle vit entre trois écrans : la sélection y applique le code privilège, le
/// checkout y pose l'adresse et le moyen de paiement, et l'exécuteur du tunnel
/// la lit pour créer la commande. Sans cet état partagé, le checkout poussait
/// une demande de transaction sans jamais créer de commande ni vider le panier.
@immutable
class BrouillonCommande {
  const BrouillonCommande({
    this.nomComplet = '',
    this.telephone = '',
    this.mode = ModeAdresse.ville,
    this.ville,
    this.region,
    this.departement,
    this.quartier = '',
    this.moyen,
    this.numeroPaiement = '',
    this.porteurCarte = '',
    this.numeroCarte = '',
    this.cvv = '',
    this.expiration = '',
    this.codePrivilege = '',
    this.remise = 0,
    this.coordonneesValidees = false,
  });

  final String nomComplet;
  final String telephone;

  final ModeAdresse mode;

  // ── Variante ville (`162:5536`) ─────────────────────────────────────────
  final Ville? ville;

  // ── Variante cascade (`162:3844`) ───────────────────────────────────────
  final Region? region;
  final Departement? departement;
  final String quartier;

  // ── Paiement ────────────────────────────────────────────────────────────
  final MoyenPaiement? moyen;

  /// Numéro saisi pour un paiement mobile money (`162:4647`).
  final String numeroPaiement;

  // Champs de carte (`162:5427`).
  final String porteurCarte;
  final String numeroCarte;
  final String cvv;
  final String expiration;

  // ── Code privilège (`16:3448`) ──────────────────────────────────────────

  /// Code saisi, tel quel. Vide tant que rien n'a été appliqué.
  final String codePrivilege;

  /// Remise obtenue, en FCFA.
  final double remise;

  /// La cliente a explicitement validé ses coordonnées de livraison.
  final bool coordonneesValidees;

  /// Adresse résumée en une ligne, telle que la maquette la replie une fois la
  /// saisie faite (`162:4162` : « Mbalmayo-Centre, Newtown Collège… »).
  String get adresseResumee {
    if (mode == ModeAdresse.ville) return ville?.nom ?? '';
    final morceaux = [
      if (departement != null) departement!.nom,
      if (region != null) region!.nom,
      if (quartier.trim().isNotEmpty) quartier.trim(),
    ];
    return morceaux.join(', ');
  }

  /// Identifiant de ville à transmettre au devis de livraison. Nul en mode
  /// cascade, où c'est la région qui tarifie.
  int? get villeIdPourDevis => mode == ModeAdresse.ville ? ville?.id : null;

  /// L'adresse est-elle suffisamment renseignée pour commander ?
  bool get adresseComplete => switch (mode) {
        ModeAdresse.ville => ville != null,
        ModeAdresse.cascade =>
          region != null && departement != null && quartier.trim().isNotEmpty,
      };

  /// Le moyen de paiement est-il utilisable en l'état ?
  bool get paiementComplet {
    final m = moyen;
    if (m == null) return false;
    return switch (m.saisie) {
      SaisieMoyen.aucune => true,
      SaisieMoyen.telephone => _chiffres(numeroPaiement).length >= 9,
      SaisieMoyen.carte => porteurCarte.trim().isNotEmpty &&
          _chiffres(numeroCarte).length >= 12 &&
          _chiffres(cvv).length >= 3 &&
          expiration.trim().length >= 4,
    };
  }

  static String _chiffres(String v) => v.replaceAll(RegExp(r'[^\d]'), '');

  BrouillonCommande copyWith({
    String? nomComplet,
    String? telephone,
    ModeAdresse? mode,
    Ville? ville,
    Region? region,
    Departement? departement,
    String? quartier,
    MoyenPaiement? moyen,
    String? numeroPaiement,
    String? porteurCarte,
    String? numeroCarte,
    String? cvv,
    String? expiration,
    String? codePrivilege,
    double? remise,
    bool? coordonneesValidees,
    bool effacerDepartement = false,
  }) {
    return BrouillonCommande(
      nomComplet: nomComplet ?? this.nomComplet,
      telephone: telephone ?? this.telephone,
      mode: mode ?? this.mode,
      ville: ville ?? this.ville,
      region: region ?? this.region,
      // Changer de région invalide le département : la cascade ne doit jamais
      // laisser un département étranger à la région retenue.
      departement: effacerDepartement ? null : (departement ?? this.departement),
      quartier: quartier ?? this.quartier,
      moyen: moyen ?? this.moyen,
      numeroPaiement: numeroPaiement ?? this.numeroPaiement,
      porteurCarte: porteurCarte ?? this.porteurCarte,
      numeroCarte: numeroCarte ?? this.numeroCarte,
      cvv: cvv ?? this.cvv,
      expiration: expiration ?? this.expiration,
      codePrivilege: codePrivilege ?? this.codePrivilege,
      remise: remise ?? this.remise,
      coordonneesValidees: coordonneesValidees ?? this.coordonneesValidees,
    );
  }
}

class BrouillonCommandeNotifier extends Notifier<BrouillonCommande> {
  @override
  BrouillonCommande build() => const BrouillonCommande();

  void majCoordonnees({String? nomComplet, String? telephone}) {
    state = state.copyWith(
      nomComplet: nomComplet,
      telephone: telephone,
      coordonneesValidees: false,
    );
  }

  void choisirMode(ModeAdresse mode) {
    state = state.copyWith(mode: mode, coordonneesValidees: false);
  }

  void choisirVille(Ville ville) {
    state = state.copyWith(ville: ville, coordonneesValidees: false);
  }

  void choisirRegion(Region region) {
    state = state.copyWith(
      region: region,
      effacerDepartement: true,
      coordonneesValidees: false,
    );
  }

  void choisirDepartement(Departement departement) {
    state = state.copyWith(
      departement: departement,
      coordonneesValidees: false,
    );
  }

  void majQuartier(String quartier) {
    state = state.copyWith(quartier: quartier, coordonneesValidees: false);
  }

  void choisirMoyen(MoyenPaiement moyen) {
    state = state.copyWith(moyen: moyen);
  }

  void majPaiement({
    String? numeroPaiement,
    String? porteurCarte,
    String? numeroCarte,
    String? cvv,
    String? expiration,
  }) {
    state = state.copyWith(
      numeroPaiement: numeroPaiement,
      porteurCarte: porteurCarte,
      numeroCarte: numeroCarte,
      cvv: cvv,
      expiration: expiration,
    );
  }

  void validerCoordonnees() {
    state = state.copyWith(coordonneesValidees: true);
  }

  /// Enregistre le code : la remise est calculée par le serveur au checkout.
  bool appliquerCodePrivilege(String code) {
    final normalise = code.trim();
    if (normalise.isEmpty) return false;
    state = state.copyWith(codePrivilege: normalise, remise: 0);
    return true;
  }

  void retirerCodePrivilege() {
    state = state.copyWith(codePrivilege: '', remise: 0);
  }

  void reinitialiser() => state = const BrouillonCommande();
}

final brouillonCommandeProvider =
    NotifierProvider<BrouillonCommandeNotifier, BrouillonCommande>(
  BrouillonCommandeNotifier.new,
);
