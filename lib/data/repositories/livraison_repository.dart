import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_json.dart';
import '../bff_client/api_client.dart';

@immutable
class DevisLivraison {
  const DevisLivraison({
    required this.montant,
    required this.aDeviser,
    this.villeId,
    this.regionId,
  });

  const DevisLivraison.aDeviser({this.villeId, this.regionId})
      : montant = 0,
        aDeviser = true;

  final double montant;
  final bool aDeviser;
  final int? villeId;
  final int? regionId;

  factory DevisLivraison.fromJson(Map<String, dynamic> json) {
    return DevisLivraison(
      montant: montantDe(json['amount']),
      aDeviser: booleenDe(json['quote_required']),
      villeId: json['city_id'] as int?,
      regionId: json['region_id'] as int?,
    );
  }
}

final livraisonRepositoryProvider = Provider<LivraisonRepository>((ref) {
  return LivraisonRepository(ref.watch(bffClientProvider));
});

final devisLivraisonProvider =
    FutureProvider.family<DevisLivraison, int?>((ref, villeId) {
  return ref.watch(livraisonRepositoryProvider).deviser(villeId: villeId);
});

class LivraisonRepository {
  LivraisonRepository(this._client);

  final BffClient _client;

  Future<DevisLivraison> deviser({int? villeId, int? regionId}) async {
    if (villeId == null && regionId == null) {
      return const DevisLivraison(montant: 0, aDeviser: false);
    }
    final json = await _client.getJson('/delivery/quote', query: {
      'city_id': ?villeId,
      'region_id': ?regionId,
    });
    return DevisLivraison.fromJson(json);
  }
}
