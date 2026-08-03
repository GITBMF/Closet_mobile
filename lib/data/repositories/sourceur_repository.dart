import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Modèle d'une pièce déposée par un sourceur.
class PieceDeposee {
  final String id;
  final String nom;
  final String univers;
  final double prix;
  final String? imageUrl;
  final StatutPiece statut;

  const PieceDeposee({
    required this.id,
    required this.nom,
    required this.univers,
    required this.prix,
    this.imageUrl,
    required this.statut,
  });

  factory PieceDeposee.fromJson(Map<String, dynamic> json) {
    return PieceDeposee(
      id: json['id'] as String,
      nom: json['nom'] as String,
      univers: json['univers'] as String? ?? '',
      prix: (json['prix'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      statut: StatutPiece.values.firstWhere(
        (s) => s.name == json['statut'],
        orElse: () => StatutPiece.enRevue,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'univers': univers,
        'prix': prix,
        'imageUrl': imageUrl,
        'statut': statut.name,
      };
}

/// Statuts possibles d'une pièce déposée.
enum StatutPiece { enRevue, publiee, vendue, refusee }

/// Revenus résumés du sourceur.
class RevenusSourceur {
  final int solde;
  final int brut;
  final int commission;
  final int enAttente;
  final String moyenPaiement;
  final List<VenteSourceur> historique;

  const RevenusSourceur({
    required this.solde,
    required this.brut,
    required this.commission,
    required this.enAttente,
    this.moyenPaiement = 'MTN MoMo',
    this.historique = const [],
  });
}

/// Une vente historique dans l'espace sourceur.
class VenteSourceur {
  final String nomPiece;
  final double montant;
  final DateTime date;

  const VenteSourceur({
    required this.nomPiece,
    required this.montant,
    required this.date,
  });
}

/// Données soumises lors de l'inscription sourceur.
class SourceurInscriptionData {
  final String nomAtelier;
  final String ville;
  final String whatsapp;
  final String univers;
  final String? specialite;
  final String moyenPaiement;
  final String numeroPaiement;

  const SourceurInscriptionData({
    required this.nomAtelier,
    required this.ville,
    required this.whatsapp,
    required this.univers,
    this.specialite,
    required this.moyenPaiement,
    required this.numeroPaiement,
  });
}

/// Profil sourceur après inscription.
class SourceurProfile {
  final String nomAtelier;
  final String ville;
  final String depuis;
  final String whatsapp;
  final String univers;

  const SourceurProfile({
    required this.nomAtelier,
    required this.ville,
    required this.depuis,
    this.whatsapp = '',
    this.univers = '',
  });

  SourceurProfile copyWith({
    String? nomAtelier,
    String? ville,
    String? depuis,
    String? whatsapp,
    String? univers,
  }) {
    return SourceurProfile(
      nomAtelier: nomAtelier ?? this.nomAtelier,
      ville: ville ?? this.ville,
      depuis: depuis ?? this.depuis,
      whatsapp: whatsapp ?? this.whatsapp,
      univers: univers ?? this.univers,
    );
  }
}

/// Repository sourceur — mock MVP avec simulation de latence réseau.
/// Brancher sur HTTP quand le backend Dart Frog est prêt (ENV=prod).
class SourceurRepository extends ChangeNotifier {
  // ── Données mock ────────────────────────────────────────────────────────

  final List<PieceDeposee> _pieces = [];
  SourceurProfile? _profile;

  Future<List<PieceDeposee>> getMesPieces() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_pieces);
  }

  Future<void> deposerPiece(PieceDeposee piece) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _pieces.add(piece);
    notifyListeners();
  }

  Future<RevenusSourceur> getRevenus() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    // Calculer depuis les pièces vendues
    final vendues = _pieces.where((p) => p.statut == StatutPiece.vendue);
    final brut = vendues.fold<int>(0, (s, p) => s + p.prix.toInt());
    final commission = (brut * 0.25).toInt();
    return RevenusSourceur(
      solde: brut - commission,
      brut: brut,
      commission: commission,
      enAttente: 0,
      historique: vendues
          .map((p) => VenteSourceur(
                nomPiece: p.nom,
                montant: p.prix,
                date: DateTime.now(),
              ))
          .toList(),
    );
  }

  Future<SourceurProfile> inscrire(SourceurInscriptionData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _profile = SourceurProfile(
      nomAtelier: data.nomAtelier,
      ville: data.ville,
      depuis: _moisAnnee(),
      whatsapp: data.whatsapp,
      univers: data.univers,
    );
    notifyListeners();
    return _profile!;
  }

  void updateProfile(SourceurProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  bool get estInscrit => _profile != null;
  SourceurProfile? get profile => _profile;

  static String _moisAnnee() {
    final now = DateTime.now();
    const mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return '${mois[now.month - 1]} ${now.year}';
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final sourceurRepositoryProvider = ChangeNotifierProvider<SourceurRepository>((ref) {
  return SourceurRepository();
});

final mesPiecesProvider = FutureProvider<List<PieceDeposee>>((ref) {
  return ref.watch<SourceurRepository>(sourceurRepositoryProvider).getMesPieces();
});

final revenusSourceurProvider = FutureProvider<RevenusSourceur>((ref) {
  return ref.watch<SourceurRepository>(sourceurRepositoryProvider).getRevenus();
});
