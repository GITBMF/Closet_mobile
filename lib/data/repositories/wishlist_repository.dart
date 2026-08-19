import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../bff_client/api_client.dart';
import '../models/article.dart';
import '../services/local_storage_service.dart';
import 'auth_repository.dart';
import 'cart_repository.dart' show localStorageProvider;
import 'catalog_repository.dart';

class WishlistNotifier extends AsyncNotifier<List<Article>> {
  late LocalStorageService _storage;

  bool get _connectee => ref.read(currentUserProvider) != null;

  @override
  Future<List<Article>> build() async {
    _storage = await ref.watch(localStorageProvider.future);
    if (_connectee) {
      return _depuisServeur();
    }
    return _storage.loadWishlist();
  }

  Future<List<Article>> _depuisServeur() async {
    final client = ref.read(bffClientProvider);
    final catalog = ref.read(catalogRepositoryProvider);
    final maisons = {for (final m in await catalog.getMaisons()) m.id: m.nom};
    final univers = {for (final u in await catalog.getUnivers()) u.id: u.nom};
    final brut = await client.getList('/wishlist');
    return [
      for (final o in brut)
        if (o is Map<String, dynamic>)
          Article.fromApi(
            o,
            nomMaison: maisons[o['house_id'] as String?],
            nomUnivers: univers[o['universe_id'] as String?],
          ).copyWith(isWishlisted: true),
    ];
  }

  Future<void> toggleWishlist(Article article) async {
    final actuel = isWishlisted(article.id);
    if (actuel) {
      await removeArticle(article.id);
    } else {
      await addArticle(article);
    }
  }

  Future<void> addArticle(Article article) async {
    if (_connectee) {
      try {
        await ref.read(bffClientProvider).postJson('/wishlist/${article.id}');
      } on ApiException {
        rethrow;
      }
      state = AsyncData([
        ...state.value ?? [],
        if (!isWishlisted(article.id)) article.copyWith(isWishlisted: true),
      ]);
      return;
    }
    final current = state.value ?? [];
    if (!current.any((a) => a.id == article.id)) {
      final next = [...current, article];
      state = AsyncData(next);
      await _storage.saveWishlist(next);
    }
  }

  Future<void> removeArticle(String id) async {
    if (_connectee) {
      await ref.read(bffClientProvider).delete('/wishlist/$id');
    }
    final next = (state.value ?? []).where((a) => a.id != id).toList();
    state = AsyncData(next);
    if (!_connectee) await _storage.saveWishlist(next);
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
