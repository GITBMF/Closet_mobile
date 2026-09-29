import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bff_client/api_client.dart';
import '../models/geo.dart';

final geoRepositoryProvider = Provider<GeoRepository>((ref) {
  return GeoRepository(ref.watch(bffClientProvider));
});

final regionsProvider = FutureProvider<List<Region>>((ref) {
  return ref.watch(geoRepositoryProvider).regions();
});

final departementsProvider =
    FutureProvider.family<List<Departement>, int>((ref, regionId) {
  return ref.watch(geoRepositoryProvider).departements(regionId);
});

final villesProvider = FutureProvider<List<Ville>>((ref) {
  return ref.watch(geoRepositoryProvider).villes();
});

final quartiersProvider =
    FutureProvider.family<List<Quartier>, int>((ref, villeId) {
  return ref.watch(geoRepositoryProvider).quartiers(villeId);
});

class GeoRepository {
  GeoRepository(this._client);

  final BffClient _client;

  Future<List<Region>> regions() async {
    return [
      for (final o in await _client.getList('/geo/regions'))
        if (o is Map<String, dynamic>) Region.fromJson(o),
    ];
  }

  Future<List<Departement>> departements(int regionId) async {
    return [
      for (final o in await _client.getList('/geo/regions/$regionId/divisions'))
        if (o is Map<String, dynamic>) Departement.fromJson(o),
    ];
  }

  Future<List<Ville>> villes() async {
    return [
      for (final o in await _client.getList(
        '/geo/cities',
        query: const {'active_only': true},
      ))
        if (o is Map<String, dynamic>) Ville.fromJson(o),
    ];
  }

  Future<List<Quartier>> quartiers(int villeId) async {
    return [
      for (final o
          in await _client.getList('/geo/cities/$villeId/neighbourhoods'))
        if (o is Map<String, dynamic>) Quartier.fromJson(o),
    ];
  }
}
