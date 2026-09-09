import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';
import '../models/user.dart';

class PieceDeposee {
  final String id;
  final String nom;
  final String univers;
  final double prix;
  final String? imageUrl;
  final StatutPiece statut;
  final String? raisonRefus;
  final String? taille;
  final String? etat;
  final String? recit;
  final String? methodeCollecte;
  final bool partageAutorise;
  final String statutApi;
  final String? pieceId;

  const PieceDeposee({
    required this.id,
    required this.nom,
    required this.univers,
    required this.prix,
    this.imageUrl,
    required this.statut,
    this.raisonRefus,
    this.taille,
    this.etat,
    this.recit,
    this.methodeCollecte,
    this.partageAutorise = false,
    this.statutApi = '',
    this.pieceId,
  });
}

/// `condition_claimed` attendu : `new` | `very_good` | `good`.
String conditionApiDepuis(String? etat) {
  final v = (etat ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e');
  return switch (v) {
    'neuf' || 'new' => 'new',
    'tres bon etat' || 'very_good' || 'very good' => 'very_good',
    'bon etat' || 'good' || 'etat correct' || 'etat correcte' => 'good',
    _ => 'good',
  };
}

String libelleCondition(String? etat) {
  if (etat == null || etat.trim().isEmpty) return '';
  return switch (conditionApiDepuis(etat)) {
    'new' => 'Neuf',
    'very_good' => 'Très bon état',
    _ => 'Bon état',
  };
}

String libelleMethodeCollecte(String? methode) {
  return switch ((methode ?? '').trim()) {
    'pickup' => 'Collecte à domicile',
    'drop_off' => 'Dépôt en boutique',
    _ => '',
  };
}

/// Fichier ou URL à joindre via `POST /sourcing/submissions/{id}/media`.
class FichierMedia {
  const FichierMedia({required this.chemin, this.nom = ''});

  final String chemin;
  final String nom;

  bool get estUrlDistante =>
      chemin.startsWith('http://') || chemin.startsWith('https://');
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
  final String typeCollaboration;

  const SourceurInscriptionData({
    required this.nomAtelier,
    required this.ville,
    required this.whatsapp,
    required this.univers,
    this.specialite,
    required this.moyenPaiement,
    required this.numeroPaiement,
    this.typeCollaboration = 'consignment',
  });
}

class SourceurProfile {
  final String nomAtelier;
  final String ville;
  final String depuis;
  final String whatsapp;
  final String univers;
  final String statutApi;
  final String moyenPaiement;
  final String numeroPaiement;
  final String typeCollaboration;

  const SourceurProfile({
    required this.nomAtelier,
    required this.ville,
    required this.depuis,
    this.whatsapp = '',
    this.univers = '',
    this.statutApi = 'pending',
    this.moyenPaiement = '',
    this.numeroPaiement = '',
    this.typeCollaboration = '',
  });

  String get libelleStatut => switch (statutApi) {
        'approved' => 'Approuvé',
        'rejected' => 'Refusé',
        'suspended' => 'Suspendu',
        _ => 'En étude',
      };

  String get libelleCollaboration => switch (typeCollaboration) {
        'direct_sale' => 'Vente directe',
        'consignment' => 'Dépôt-vente',
        _ => typeCollaboration.isEmpty ? 'Non renseigné' : typeCollaboration,
      };

  String get libelleMoyenPaiement {
    if (moyenPaiement.isEmpty) return 'Non renseigné';
    final v = moyenPaiement.toLowerCase();
    if (v.contains('mtn')) return 'MTN Mobile Money';
    if (v.contains('orange')) return 'Orange Money';
    if (v.contains('visa') || v.contains('carte')) return 'Carte Visa';
    if (v.contains('virement')) return 'Virement bancaire';
    return moyenPaiement[0].toUpperCase() + moyenPaiement.substring(1);
  }
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

  /// Vrai seulement après un `GET /sourcing/me` (ou `POST /sourcing/apply`) réussi.
  bool _ficheServeur = false;

  bool get estInscrit => _profile != null;
  SourceurProfile? get profile => _profile;
  AdhesionSourceur? get adhesion => _adhesion;

  /// Le rôle JWT `sourcer` / `admin` ouvre l'espace même sans fiche
  /// `GET /sourcing/me` (compte créé par une admin, pas via `/sourcing/apply`).
  bool accesAutorisePour(ClosetUser? user) =>
      (user?.estSourceur ?? false) || estInscrit;

  Future<void> chargerProfil({ClosetUser? compte}) async {
    try {
      final json = await _client.getJson('/sourcing/me');
      _appliquerProfil(json);
      await Future.wait<void>([_chargerPieces(), _chargerRetraits()]);
      notifyListeners();
    } on ApiException catch (e) {
      if (!_estAbsenceDeFiche(e)) rethrow;
      if (compte?.estSourceur == true) {
        _appliquerCompteSourceur(compte!);
        notifyListeners();
        return;
      }
      _profile = null;
      _adhesion = null;
      _pieces = const [];
      _retraits = const [];
      _ficheServeur = false;
      notifyListeners();
    }
  }

  /// 404 : pas de SourcerProfile. 403 : le backend refuse `/sourcing/me`
  /// aux comptes sans fiche, y compris quand le rôle JWT est déjà `sourcer`.
  bool _estAbsenceDeFiche(ApiException e) {
    if (e.kind == KindErreurApi.introuvable) return true;
    return e.kind == KindErreurApi.nonAutorise && e.status == 403;
  }

  void _appliquerCompteSourceur(ClosetUser user) {
    _ficheServeur = false;
    _profile = SourceurProfile(
      nomAtelier: user.nomComplet.isEmpty ? 'Mon atelier' : user.nomComplet,
      ville: user.city,
      depuis: '',
      whatsapp: user.phone,
      statutApi: 'approved',
    );
    _adhesion = AdhesionSourceur(
      etape: EtapeAdhesion.validee,
      dateSoumission: DateTime.now(),
    );
  }

  void _appliquerProfil(Map<String, dynamic> json) {
    _ficheServeur = true;
    final statut = chaineDe(json['status']);
    final cree = dateDe(json['created_at']) ?? DateTime.now();
    _profile = SourceurProfile(
      nomAtelier: chaineDe(json['display_name'], 'Mon atelier'),
      ville: '',
      depuis: _moisAnnee(cree),
      whatsapp: chaineDe(json['phone']),
      statutApi: statut,
      moyenPaiement: chaineDe(json['payout_method']),
      numeroPaiement: chaineDe(json['payout_phone']),
      typeCollaboration: chaineDe(json['collaboration_type']),
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
    try {
      final page = await _client.getJson('/sourcing/submissions', query: {
        'limit': 50,
        'offset': 0,
      });
      _pieces = [
        for (final o in objetsDe(listeDe(page))) _pieceDepuisSoumission(o),
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
    } on ApiException catch (e) {
      if (e.kind != KindErreurApi.introuvable) rethrow;
      _pieces = const [];
    }
  }

  PieceDeposee _pieceDepuisSoumission(Map<String, dynamic> json) {
    final statutApi = chaineDe(json['status']);
    final medias = objetsDe(json['media']);
    String? imageUrl;
    if (medias.isNotEmpty) {
      final url = chaineDe(medias.first['url']);
      if (url.isNotEmpty) imageUrl = url;
    }
    final pieceLiee = objetDe(json['piece']);
    final statutPiece = chaineDe(
      pieceLiee['status'],
      chaineDe(json['piece_status']),
    );
    return PieceDeposee(
      id: chaineDe(json['id']),
      nom: chaineDe(json['item_type'], chaineDe(json['brand'], 'Pièce')),
      univers: chaineDe(json['brand']),
      prix: montantDe(json['desired_price']),
      imageUrl: imageUrl,
      statut: switch (statutApi) {
        'refused' => StatutPiece.refusee,
        'catalogued' when statutPiece == 'sold' => StatutPiece.vendue,
        'catalogued' => StatutPiece.publiee,
        _ when statutPiece == 'sold' => StatutPiece.vendue,
        _ => StatutPiece.enRevue,
      },
      raisonRefus: json['refusal_reason'] as String?,
      taille: chaineDe(json['size_label']).isEmpty
          ? null
          : chaineDe(json['size_label']),
      etat: chaineDe(json['condition_claimed']).isEmpty
          ? null
          : chaineDe(json['condition_claimed']),
      recit: chaineDe(json['story']).isEmpty ? null : chaineDe(json['story']),
      methodeCollecte: chaineDe(json['collection_method']).isEmpty
          ? null
          : chaineDe(json['collection_method']),
      partageAutorise: booleenDe(json['share_permission']),
      statutApi: statutApi,
      pieceId: chaineDe(json['piece_id']).isEmpty
          ? null
          : chaineDe(json['piece_id']),
    );
  }

  Future<void> _chargerRetraits() async {
    try {
      _retraits = [
        for (final o in await _client.getList('/sourcing/payouts'))
          if (o is Map<String, dynamic>) _retraitDepuis(o),
      ];
    } on ApiException catch (e) {
      if (e.kind != KindErreurApi.introuvable) rethrow;
      _retraits = const [];
    }
  }

  RetraitSourceur _retraitDepuis(Map<String, dynamic> json) {
    final statutApi = chaineDe(json['status']);
    return RetraitSourceur(
      montant: montantDe(json['amount']),
      date: dateDe(json['paid_at']) ?? dateDe(json['created_at']) ?? DateTime.now(),
      soldeApres: 0,
      moyen: chaineDe(json['method']),
      statut: switch (statutApi) {
        'paid' => StatutRetrait.approuve,
        'failed' => StatutRetrait.refuse,
        _ => StatutRetrait.enCours,
      },
    );
  }

  Future<List<PieceDeposee>> getMesPieces() async {
    await _chargerPieces();
    return List.unmodifiable(_pieces);
  }

  Future<String> deposerPiece(
    PieceDeposee piece, {
    List<FichierMedia> medias = const [],
  }) async {
    if (!_ficheServeur) {
      throw const ApiException(
        message:
            'Aucune fiche sourceur n’est enregistrée pour ce compte. Terminez l’adhésion avant de confier une pièce.',
        kind: KindErreurApi.introuvable,
        status: 404,
      );
    }
    final statut = _profile?.statutApi ?? '';
    if (statut == 'pending') {
      throw const ApiException(
        message:
            'Votre adhésion est encore à l’étude. Le dépôt s’ouvrira après validation.',
        kind: KindErreurApi.nonAutorise,
        status: 403,
      );
    }
    if (statut == 'rejected' || statut == 'suspended') {
      throw const ApiException(
        message:
            'Votre fiche sourceur n’est plus active. Contactez ClosET avant de confier une pièce.',
        kind: KindErreurApi.nonAutorise,
        status: 403,
      );
    }

    final prixEntier = piece.prix == piece.prix.roundToDouble();
    final payload = <String, dynamic>{
      'item_type': piece.nom,
      'condition_claimed': conditionApiDepuis(piece.etat),
      'desired_price': prixEntier ? piece.prix.round() : piece.prix,
      'share_permission': piece.partageAutorise,
    };
    if (piece.univers.isNotEmpty) payload['brand'] = piece.univers;
    if (piece.taille != null && piece.taille!.isNotEmpty) {
      payload['size_label'] = piece.taille;
    }
    if (piece.recit != null && piece.recit!.isNotEmpty) {
      payload['story'] = piece.recit;
    }
    if (piece.methodeCollecte != null && piece.methodeCollecte!.isNotEmpty) {
      payload['collection_method'] = piece.methodeCollecte;
    }

    late final Map<String, dynamic> creee;
    try {
      creee = await _client.postJson('/sourcing/submissions', data: payload);
    } on ApiException catch (e) {
      if (e.kind == KindErreurApi.introuvable) {
        throw ApiException(
          message: _messageDepotIntrouvable(e),
          kind: e.kind,
          status: e.status,
        );
      }
      rethrow;
    }
    final id = chaineDe(creee['id']);
    if (id.isEmpty) {
      throw const ApiException(
        message: 'Le dépôt n’a pas renvoyé d’identifiant.',
        kind: KindErreurApi.serveur,
      );
    }

    for (var i = 0; i < medias.length; i++) {
      try {
        await ajouterMedia(id, medias[i], position: i);
      } on ApiException {
        // Le dépôt est déjà créé : un média refusé ne l’annule pas.
      }
    }

    try {
      await _chargerPieces();
    } on ApiException {
      // La soumission existe déjà côté serveur.
    }
    notifyListeners();
    return id;
  }

  /// `POST /sourcing/submissions/{id}/media`.
  ///
  /// URL distante → JSON `MediaIn`. Fichier local → `multipart` (`file`),
  /// comme le catalogue admin.
  Future<void> ajouterMedia(
    String submissionId,
    FichierMedia media, {
    int position = 0,
  }) async {
    final chemin = '/sourcing/submissions/$submissionId/media';
    if (media.estUrlDistante) {
      await _client.postJson(chemin, data: {
        'url': media.chemin,
        'position': position,
      });
      return;
    }
    final nom = media.nom.isNotEmpty
        ? media.nom
        : media.chemin.split(RegExp(r'[\\/]')).last;
    await _client.postFichier(
      chemin,
      champ: 'file',
      cheminFichier: media.chemin,
      nomFichier: nom,
      champs: {'position': '$position'},
    );
  }

  /// `GET /sourcing/submissions/{id}`
  Future<PieceDeposee> getPiece(String id) async {
    for (final piece in _pieces) {
      if (piece.id == id) {
        try {
          final json = await _client.getJson('/sourcing/submissions/$id');
          return _pieceDepuisSoumission(json);
        } on ApiException {
          return piece;
        }
      }
    }
    final json = await _client.getJson('/sourcing/submissions/$id');
    return _pieceDepuisSoumission(json);
  }

  Future<RevenusSourceur> getRevenus() async {
    await _chargerRetraits();
    final enAttente = _retraits
        .where((r) => r.statut == StatutRetrait.enCours)
        .fold<double>(0, (s, r) => s + r.montant);
    final verses = _retraits
        .where((r) => r.statut == StatutRetrait.approuve)
        .fold<double>(0, (s, r) => s + r.montant);
    return RevenusSourceur(
      solde: enAttente.round(),
      brut: verses.round(),
      commission: 0,
      enAttente: enAttente.round(),
      moyenPaiement: _profile?.moyenPaiement.isNotEmpty == true
          ? _profile!.moyenPaiement
          : (_retraits.isEmpty ? '' : _retraits.first.moyen),
      retraits: List.unmodifiable(_retraits),
    );
  }

  Future<SourceurProfile> inscrire(SourceurInscriptionData data) async {
    final json = await _client.postJson('/sourcing/apply', data: {
      'display_name': data.nomAtelier,
      'phone': data.whatsapp,
      'payout_method': data.moyenPaiement,
      'payout_phone': data.numeroPaiement,
      'collaboration_type': data.typeCollaboration,
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
    _ficheServeur = false;
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

  static String _messageDepotIntrouvable(ApiException e) {
    final brut = e.message.trim();
    final minuscule = brut.toLowerCase();
    if (minuscule.contains('sourceur') ||
        minuscule.contains('sourcer') ||
        minuscule.contains('fiche') ||
        minuscule.contains('profile')) {
      return brut;
    }
    return 'Aucune fiche sourceur n’est liée à ce compte. '
        'Le serveur refuse le dépôt tant que l’adhésion n’est pas enregistrée.';
  }
}

final sourceurRepositoryProvider =
    ChangeNotifierProvider<SourceurRepository>((ref) {
  return SourceurRepository(ref.watch(bffClientProvider));
});

final mesPiecesProvider = FutureProvider<List<PieceDeposee>>((ref) {
  return ref.read(sourceurRepositoryProvider).getMesPieces();
});

final revenusSourceurProvider = FutureProvider<RevenusSourceur>((ref) {
  return ref.read(sourceurRepositoryProvider).getRevenus();
});

/// Détail d'une soumission — `GET /sourcing/submissions/{id}`.
final pieceSourceurProvider =
    FutureProvider.family<PieceDeposee, String>((ref, id) {
  return ref.read(sourceurRepositoryProvider).getPiece(id);
});
