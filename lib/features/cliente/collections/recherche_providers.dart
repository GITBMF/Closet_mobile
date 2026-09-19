import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/recherche/suggestion_recherche.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/services/historique_recherche_service.dart';

final historiqueRechercheProvider =
    FutureProvider<List<String>>((ref) => HistoriqueRechercheService.lire());

/// Maisons, types, tailles et états dérivés du catalogue vivant.
final indexRechercheProvider = FutureProvider<IndexRecherche>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  final maisons = await ref.watch(maisonsProvider.future);
  final univers = await ref.watch(universFiltresProvider.future);
  final pieces = await repo.getCatalog();
  return indexDepuisCatalogue(
    maisons: maisons,
    univers: univers,
    pieces: pieces,
  );
});
