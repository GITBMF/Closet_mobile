import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';

class PieceDeposee {
  final String id;
  final String nom;
  final String univers;
  final double prix;
  final String? imageUrl;
  final StatutPiece statut;
  final String? raisonRefus;

  const PieceDeposee({
    required this.id,
    required this.nom,
    required this.univers,
    required this.prix,
    this.imageUrl,
    required this.statut,
    this.raisonRefus,
  });
}

enum StatutPiece { enRevue, publiee, vendue, refusee }

class RevenusSourceur {
  final int solde;
  final int brut;
  final int commission;
  final int enAttente;
  final String moyenPaiement;
  final List<RetraitSourceur> retraits;

  const RevenusSourceur({
    required this.solde,
    required this.brut,
    required this.commission,
    required this.enAttente,
    this.moyenPaiement = '',
    this.retraits = const [],
  });
}

enum StatutRetrait { approuve, enCours, refuse }

@immutable
class RetraitSourceur {
  const RetraitSourceur({
    required this.montant,
    required this.date,
    required this.soldeApres,
    required this.moyen,
    this.statut = StatutRetrait.approuve,
  });

  final double montant;
  final DateTime date;
  final double soldeApres;
  final String moyen;
  final StatutRetrait statut;

  String get libelle => switch (statut) {
        StatutRetrait.approuve => 'Retrait approuvé',
        StatutRetrait.enCours => 'Retrait en cours',
        StatutRetrait.refuse => 'Retrait refusé',
      };
}

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

class SourceurProfile {
  final String nomAtelier;
  final String ville;
  final String depuis;
  final String whatsapp;
  final String univers;
  final String statutApi;

  const SourceurProfile({
    required this.nomAtelier,
    required this.ville,
    required this.depuis,
    this.whatsapp = '',
    this.univers = '',
    this.statutApi = 'pending',
  });
}

enum EtapeAdhesion { soumise, enEtude, validee, premierePiece }

@immutable
class AdhesionSourceur {
  const AdhesionSourceur({
    required this.etape,
    required this.dateSoumission,
    this.raisonRefus,
  });

  final EtapeAdhesion etape;
  final DateTime dateSoumission;
  final String? raisonRefus;

  bool get estValidee =>
      etape == EtapeAdhesion.validee || etape == EtapeAdhesion.premierePiece;
}

class SourceurRepository extends ChangeNotifier {
  SourceurRepository(this._client);

  final BffClient _client;

  SourceurProfile? _profile;
  AdhesionSourceur? _adhesion;
  List<PieceDeposee> _pieces = const [];
  List<RetraitSourceur> _retraits = const [];

  bool get estInscrit => _profile != null;
  SourceurProfile? get profile => _profile;
  AdhesionSourceur? get adhesion => _adhesion;

  Future<void> chargerProfil() async {
    try {
      final json = await _client.getJson('/sourcing/me');
      _appliquerProfil(json);
      await Future.wait<void>([_chargerPieces(), _chargerRetraits()]);
      notifyListeners();
    } on ApiException catch (e) {
      if (e.kind == KindErreurApi.introuvable) {
        _profile = null;
        _adhesion = null;
        _pieces = const [];
        _retraits = const [];
        notifyListeners();
        return;
      }
      rethrow;
    }
  }

  void _appliquerProfil(Map<String, dynamic> json) {
    final statut = chaineDe(json['status']);
    final cree = dateDe(json['created_at']) ?? DateTime.now();
    _profile = SourceurProfile(
      nomAtelier: chaineDe(json['display_name'], 'Mon atelier'),
      ville: '',
      depuis: _moisAnnee(cree),
      whatsapp: chaineDe(json['phone']),
      statutApi: statut,
    );
    _adhesion = AdhesionSourceur(
      etape: _etapeDepuis(statut),
      dateSoumission: cree,
      raisonRefus: json['rejection_reason'] as String?,
    );
  }

  EtapeAdhesion _etapeDepuis(String statut) {
    return switch (statut) {
      'approved' =>
        _pieces.isEmpty ? EtapeAdhesion.validee : EtapeAdhesion.premierePiece,
      'rejected' || 'suspended' => EtapeAdhesion.soumise,
      _ => EtapeAdhesion.enEtude,
    };
  }

  Future<void> _chargerPieces() async {
    final page = await _client.getJson('/sourcing/submissions', query: {
      'limit': 50,
      'offset': 0,
    });
    _pieces = [
      for (final o in objetsDe(page['items'])) _pieceDepuisSoumission(o),
    ];
    if (_adhesion != null && _profile?.statutApi == 'approved') {
      _adhesion = AdhesionSourceur(
        etape: _pieces.isEmpty
            ? EtapeAdhesion.validee
            : EtapeAdhesion.premierePiece,
        dateSoumission: _adhesion!.dateSoumission,
        raisonRefus: _adhesion!.raisonRefus,
      );
    }
  }

  PieceDeposee _pieceDepuisSoumission(Map<String, dynamic> json) {
    final statutApi = chaineDe(json['status']);
    return PieceDeposee(
      id: chaineDe(json['id']),
      nom: chaineDe(json['item_type'], chaineDe(json['brand'], 'Pièce')),
      univers: chaineDe(json['brand']),
      prix: montantDe(json['desired_price']),
      statut: switch (statutApi) {
        'refused' => StatutPiece.refusee,
        'accepted' || 'catalogued' => StatutPiece.publiee,
        _ => StatutPiece.enRevue,
      },
      raisonRefus: json['refusal_reason'] as String?,
    );
  }

  Future<void> _chargerRetraits() async {
    _retraits = [
      for (final o in await _client.getList('/sourcing/payouts'))
        if (o is Map<String, dynamic>) _retraitDepuis(o),
    ];
  }

  RetraitSourceur _retraitDepuis(Map<String, dynamic> json) {
    final statutApi = chaineDe(json['status']);
    return RetraitSourceur(
      montant: montantDe(json['amount']),
      date: dateDe(json['paid_at']) ?? dateDe(json['created_at']) ?? DateTime.now(),
      soldeApres: 0,
      moyen: chaineDe(json['method']),
      statut: switch (statutApi) {
        'paid' || 'approved' => StatutRetrait.approuve,
        'failed' => StatutRetrait.refuse,
        _ => StatutRetrait.enCours,
      },
    );
  }

  Future<List<PieceDeposee>> getMesPieces() async {
    await _chargerPieces();
    notifyListeners();
    return List.unmodifiable(_pieces);
  }

  Future<String> deposerPiece(PieceDeposee piece, {String? photoUrl}) async {
    final creee = await _client.postJson('/sourcing/submissions', data: {
      'item_type': piece.nom,
      'brand': piece.univers,
      'desired_price': piece.prix,
      'condition_claimed': 'very_good',
    });
    final id = chaineDe(creee['id']);
    if (photoUrl != null &&
        photoUrl.startsWith('http') &&
        id.isNotEmpty) {
      await _client.postJson('/sourcing/submissions/$id/media', data: {
        'url': photoUrl,
        'position': 0,
      });
    }
    await _chargerPieces();
    notifyListeners();
    return id.isNotEmpty ? id : piece.id;
  }

  Future<RevenusSourceur> getRevenus() async {
    await _chargerRetraits();
    notifyListeners();
    final enAttente = _retraits
        .where((r) => r.statut == StatutRetrait.enCours)
        .fold<double>(0, (s, r) => s + r.montant);
    final verses = _retraits
        .where((r) => r.statut == StatutRetrait.approuve)
        .fold<double>(0, (s, r) => s + r.montant);
    return RevenusSourceur(
      solde: 0,
      brut: verses.round(),
      commission: 0,
      enAttente: enAttente.round(),
      moyenPaiement: _retraits.isEmpty ? '' : _retraits.first.moyen,
      retraits: List.unmodifiable(_retraits),
    );
  }

  Future<SourceurProfile> inscrire(SourceurInscriptionData data) async {
    final json = await _client.postJson('/sourcing/apply', data: {
      'display_name': data.nomAtelier,
      'phone': data.whatsapp,
      'payout_method': data.moyenPaiement,
      'payout_phone': data.numeroPaiement,
      'collaboration_type': 'consignment',
    });
    _appliquerProfil(json);
    notifyListeners();
    return _profile!;
  }

  Future<void> ouvrirSessionPartenaire({String? nomAtelier, String? ville}) {
    return chargerProfil();
  }

  void reset() {
    _profile = null;
    _adhesion = null;
    _pieces = const [];
    _retraits = const [];
    notifyListeners();
  }

  static String _moisAnnee(DateTime d) {
    const mois = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${mois[d.month - 1]} ${d.year}';
  }
}

final sourceurRepositoryProvider =
    ChangeNotifierProvider<SourceurRepository>((ref) {
  return SourceurRepository(ref.watch(bffClientProvider));
});

final mesPiecesProvider = FutureProvider<List<PieceDeposee>>((ref) {
  return ref
      .watch<SourceurRepository>(sourceurRepositoryProvider)
      .getMesPieces();
});

final revenusSourceurProvider = FutureProvider<RevenusSourceur>((ref) {
  return ref
      .watch<SourceurRepository>(sourceurRepositoryProvider)
      .getRevenus();
});
