import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/toasts.dart';
import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';
import '../models/article.dart';
import 'auth_repository.dart';
import 'catalog_repository.dart';

class WishlistNotifier extends AsyncNotifier<List<Article>> {
  bool get _connectee => ref.read(currentUserProvider) != null;

  @override
  Future<List<Article>> build() async {
    ref.watch(currentUserProvider);
    if (!_connectee) return const [];
    await ref.read(bffClientProvider).restaurerJeton();
    return chargerDepuisServeur();
  }

  /// `GET /wishlist` → liste de `PieceSummary`.
  Future<List<Article>> chargerDepuisServeur() async {
    final client = ref.read(bffClientProvider);
    final brut = await client.getList('/wishlist');

    var maisons = const <String, String>{};
    var univers = const <String, String>{};
    try {
      final catalog = ref.read(catalogRepositoryProvider);
      maisons = {for (final m in await catalog.getMaisons()) m.id: m.nom};
      univers = {for (final u in await catalog.getUnivers()) u.id: u.nom};
    } on ApiException {
      // Les noms de maison / univers sont du confort : la liste reste lisible.
    }

    return [
      for (final o in objetsDe(brut))
        Article.fromApi(
          o,
          nomMaison: maisons[chaineDe(o['house_id'])],
          nomUnivers: univers[chaineDe(o['universe_id'])],
        ).copyWith(isWishlisted: true),
    ];
  }

  Future<String?> toggleWishlist(Article article) async {
    if (!_connectee) {
      throw const ApiException(
        message:
            'Connectez-vous pour enregistrer cette pièce dans vos favoris.',
        kind: KindErreurApi.nonAutorise,
      );
    }
    if (isWishlisted(article.id)) {
      return removeArticle(article.id);
    }
    return addArticle(article);
  }

  Future<String?> addArticle(Article article) async {
    if (!_connectee) {
      throw const ApiException(
        message:
            'Connectez-vous pour enregistrer cette pièce dans vos favoris.',
        kind: KindErreurApi.nonAutorise,
      );
    }
    final avant = state.value ?? [];
    if (!isWishlisted(article.id)) {
      state = AsyncData([...avant, article.copyWith(isWishlisted: true)]);
    }
    try {
      final message =
          await ref.read(bffClientProvider).postVide('/wishlist/${article.id}');
      state = AsyncData(await chargerDepuisServeur());
      return message;
    } catch (e) {
      state = AsyncData(avant);
      rethrow;
    }
  }

  Future<String?> removeArticle(String id) async {
    if (!_connectee) {
      throw const ApiException(
        message: 'Connectez-vous pour modifier vos favoris.',
        kind: KindErreurApi.nonAutorise,
      );
    }
    final avant = state.value ?? [];
    state = AsyncData(avant.where((a) => a.id != id).toList());
    try {
      final message = await ref.read(bffClientProvider).delete('/wishlist/$id');
      state = AsyncData(await chargerDepuisServeur());
      return message;
    } catch (e) {
      state = AsyncData(avant);
      rethrow;
    }
  }

  bool isWishlisted(String id) =>
      (state.value ?? []).any((a) => a.id == id);
}

final wishlistProvider =
    AsyncNotifierProvider<WishlistNotifier, List<Article>>(
  WishlistNotifier.new,
);

final wishlistListProvider = Provider<List<Article>>((ref) {
  return ref.watch(wishlistProvider).value ?? [];
});

/// Cœur : `POST` / `DELETE /wishlist/{id}`, puis resynchronise via `GET`.
Future<void> basculerFavori(WidgetRef ref, Article article) async {
  if (ref.read(currentUserProvider) == null) {
    toastInfo(
      ref,
      'Connexion requise',
      'Connectez-vous pour ajouter cette pièce à vos favoris.',
    );
    return;
  }
  try {
    final deja = ref.read(wishlistProvider.notifier).isWishlisted(article.id);
    final message =
        await ref.read(wishlistProvider.notifier).toggleWishlist(article);
    if (deja) {
      toastMelange(
        ref,
        titre: 'Retiré des favoris',
        local: article.title,
        backend: message,
      );
    } else {
      toastMelange(
        ref,
        titre: 'Ajouté aux favoris',
        local: article.title,
        backend: message,
        succes: true,
      );
    }
  } catch (e) {
    toastErreur(ref, e, titre: 'Favoris');
  }
}
