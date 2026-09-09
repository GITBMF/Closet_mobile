import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';
import '../models/article.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(bffClientProvider));
});

final maisonsProvider = FutureProvider<List<Maison>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  final api = await repo.getMaisons();
  if (api.isNotEmpty) return api;
  // `GET /houses` est vide : on déduit les maisons des titres du catalogue.
  final vus = <String>{};
  final liste = <Maison>[
    for (final p in await repo.getCatalog())
      if (p.brand.isNotEmpty && vus.add(p.brand.toLowerCase()))
        Maison(id: p.houseId ?? p.brand, nom: p.brand),
  ];
  liste.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
  return liste;
});

final universProvider = FutureProvider<List<Univers>>((ref) {
  return ref.watch(catalogRepositoryProvider).getUnivers();
});

/// Univers API, ou types présents dans les titres si `GET /universes` est vide.
final universFiltresProvider = FutureProvider<List<String>>((ref) async {
  final api = await ref.watch(universProvider.future);
  if (api.isNotEmpty) return [for (final u in api) u.nom];
  final types = <String>{};
  for (final p in await ref.watch(catalogRepositoryProvider).getCatalog()) {
    final t = Article.typeDepuisTitre(p.title);
    if (t != null) types.add(t);
  }
  return types.toList()..sort();
});

class FiltresCatalogue {
  const FiltresCatalogue({
    this.universId,
    this.maisonId,
    this.recherche,
    this.prixMin,
    this.prixMax,
  });

  final String? universId;
  final String? maisonId;
  final String? recherche;
  final double? prixMin;
  final double? prixMax;
}

/// Contenu de l'accueil, déjà enrichi (images, marques) depuis le catalogue.
class AccueilDressing {
  const AccueilDressing({
    required this.pieceDeLaSemaine,
    required this.hero,
    required this.nouveautes,
    required this.coupsDeCoeur,
    required this.univers,
    required this.maisons,
  });

  final Article? pieceDeLaSemaine;
  final Article? hero;
  final List<Article> nouveautes;
  final List<Article> coupsDeCoeur;
  final List<String> univers;
  final List<String> maisons;

  /// Aucune pièce ni vitrine renvoyée par le backend.
  bool get estVide =>
      pieceDeLaSemaine == null &&
      hero == null &&
      nouveautes.isEmpty &&
      coupsDeCoeur.isEmpty;
}

class CatalogRepository {
  CatalogRepository(this._client);

  final BffClient _client;

  List<Maison> _maisons = const [];
  List<Univers> _univers = const [];
  bool _referentielsCharges = false;

  Future<void> _chargerReferentiels() async {
    if (_referentielsCharges) return;
    _maisons = [
      for (final o in await _client.getList('/houses'))
        if (o is Map<String, dynamic> && booleenDe(o['is_active'], true))
          Maison.fromJson(o),
    ];
    _univers = [
      for (final o in await _client.getList('/universes'))
        if (o is Map<String, dynamic> && booleenDe(o['is_active'], true))
          Univers.fromJson(o),
    ];
    _referentielsCharges = true;
  }

  String? _nomMaison(String? id) {
    if (id == null) return null;
    for (final m in _maisons) {
      if (m.id == id) return m.nom;
    }
    return null;
  }

  String? _nomUnivers(String? id) {
    if (id == null) return null;
    for (final u in _univers) {
      if (u.id == id) return u.nom;
    }
    return null;
  }

  Article _piece(Map<String, dynamic> json) {
    return Article.fromApi(
      json,
      nomMaison: _nomMaison(json['house_id'] as String?),
      nomUnivers: _nomUnivers(json['universe_id'] as String?),
    );
  }

  Article _enrichir(Article brut, Map<String, Article> parId) {
    final complet = parId[brut.id];
    if (complet == null) return brut;
    return brut.copyWith(
      imageUrls:
          brut.imageUrls.isNotEmpty ? brut.imageUrls : complet.imageUrls,
      brand: brut.brand.isNotEmpty ? brut.brand : complet.brand,
      material: brut.material.isNotEmpty ? brut.material : complet.material,
      description:
          brut.description.isNotEmpty ? brut.description : complet.description,
      story: (brut.story != null && brut.story!.isNotEmpty)
          ? brut.story
          : complet.story,
    );
  }

  Future<List<Article>> getCatalog({
    String? universe,
    FiltresCatalogue filtres = const FiltresCatalogue(),
  }) async {
    await _chargerReferentiels();

    String? universId = filtres.universId;
    if (universId == null &&
        universe != null &&
        universe != "Tout l'univers" &&
        universe != 'Tout l’univers') {
      for (final u in _univers) {
        if (u.nom.toLowerCase() == universe.toLowerCase()) {
          universId = u.id;
          break;
        }
      }
    }

    final page = await _client.getJson('/pieces', query: _queryPieces(
      universId: universId,
      maisonId: filtres.maisonId,
      recherche: filtres.recherche,
      prixMin: filtres.prixMin,
      prixMax: filtres.prixMax,
    ));

    return [for (final o in objetsDe(page['items'])) _piece(o)];
  }

  /// Paramètres de `GET /pieces` : `house_id`, `universe_id`, `min_price`,
  /// `max_price`, `q` (120 car. max), `limit`, `offset`. Les clés vides sont
  /// omises pour ne pas envoyer `null` au backend.
  Map<String, dynamic> _queryPieces({
    String? universId,
    String? maisonId,
    String? recherche,
    double? prixMin,
    double? prixMax,
  }) {
    final query = <String, dynamic>{
      'limit': 100,
      'offset': 0,
    };
    if (universId != null && universId.isNotEmpty) {
      query['universe_id'] = universId;
    }
    if (maisonId != null && maisonId.isNotEmpty) {
      query['house_id'] = maisonId;
    }
    final q = _texteRecherche(recherche);
    if (q != null) query['q'] = q;
    if (prixMin != null) query['min_price'] = prixMin.round();
    if (prixMax != null) query['max_price'] = prixMax.round();
    return query;
  }

  /// `q` de l'OpenAPI : 1–120 caractères une fois trimé.
  static String? _texteRecherche(String? q) {
    final t = q?.trim();
    if (t == null || t.isEmpty) return null;
    return t.length > 120 ? t.substring(0, 120) : t;
  }

  Future<AccueilDressing> getAccueil() async {
    final catalogue = await getCatalog();
    final parId = {for (final a in catalogue) a.id: a};

    Article? dernierSlot(String slot, List<Map<String, dynamic>> featured) {
      Article? trouve;
      for (final entree in featured) {
        if (chaineDe(entree['slot']) != slot) continue;
        final piece = entree['piece'];
        if (piece is Map<String, dynamic>) {
          trouve = _enrichir(_piece(piece), parId);
        }
      }
      return trouve;
    }

    List<Article> tousSlots(String slot, List<Map<String, dynamic>> featured) {
      final vus = <String>{};
      final liste = <Article>[];
      for (final entree in featured) {
        if (chaineDe(entree['slot']) != slot) continue;
        final piece = entree['piece'];
        if (piece is! Map<String, dynamic>) continue;
        final article = _enrichir(_piece(piece), parId);
        if (vus.add(article.id)) liste.add(article);
      }
      return liste;
    }

    var featured = const <Map<String, dynamic>>[];
    try {
      final vitrine = await _client.getJson('/showcasing/home');
      featured = objetsDe(vitrine['featured']);
    } on ApiException {
      // L'accueil reste utilisable avec le catalogue seul.
    }

    // Uniquement les slots renvoyés par le back — jamais de pièce inventée.
    final pieceSemaine = dernierSlot('piece_of_the_week', featured);
    final hero = dernierSlot('hero', featured) ?? pieceSemaine;
    final favoris = tousSlots('favourite', featured);

    final horsUne = [
      for (final a in catalogue)
        if (a.id != pieceSemaine?.id && a.id != hero?.id) a,
    ];

    final universNoms = [for (final u in _univers) u.nom];
    final maisonsNoms = [for (final m in _maisons) m.nom];
    if (universNoms.isEmpty) {
      final types = <String>{};
      for (final a in catalogue) {
        final t = Article.typeDepuisTitre(a.title);
        if (t != null) types.add(t);
      }
      universNoms.addAll(types.toList()..sort());
    }
    if (maisonsNoms.isEmpty) {
      final vus = <String>{};
      for (final a in catalogue) {
        if (a.brand.isNotEmpty && vus.add(a.brand.toLowerCase())) {
          maisonsNoms.add(a.brand);
        }
      }
      maisonsNoms.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }

    return AccueilDressing(
      pieceDeLaSemaine: pieceSemaine,
      hero: hero,
      nouveautes: horsUne.take(4).toList(),
      coupsDeCoeur: favoris.take(4).toList(),
      univers: universNoms,
      maisons: maisonsNoms,
    );
  }

  Future<Article?> getById(String id) async {
    await _chargerReferentiels();
    try {
      return _piece(await _client.getJson('/pieces/$id'));
    } on ApiException catch (e) {
      if (e.kind == KindErreurApi.introuvable) return null;
      rethrow;
    }
  }

  Future<Article?> getFeatured() async {
    final accueil = await getAccueil();
    return accueil.pieceDeLaSemaine;
  }

  Future<List<Maison>> getMaisons() async {
    await _chargerReferentiels();
    return List.unmodifiable(_maisons);
  }

  Future<List<Univers>> getUnivers() async {
    await _chargerReferentiels();
    return List.unmodifiable(_univers);
  }

  /// Conservé pour les écrans qui groupent encore par nom d'univers.
  Future<List<String>> nomsUnivers() async {
    final univers = await getUnivers();
    return [for (final u in univers) u.nom];
  }
}
