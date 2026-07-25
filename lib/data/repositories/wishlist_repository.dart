import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../services/local_storage_service.dart';
import 'cart_repository.dart' show localStorageProvider;

class WishlistNotifier extends AsyncNotifier<List<Article>> {
  late LocalStorageService _storage;

  @override
  Future<List<Article>> build() async {
    _storage = await ref.watch(localStorageProvider.future);
    return _storage.loadWishlist();
  }

  void toggleWishlist(Article article) {
    final current = state.value ?? [];
    final List<Article> next;
    if (current.any((a) => a.id == article.id)) {
      next = current.where((a) => a.id != article.id).toList();
    } else {
      next = [...current, article];
    }
    state = AsyncData(next);
    _storage.saveWishlist(next);
  }

  void addArticle(Article article) {
    final current = state.value ?? [];
    if (!current.any((a) => a.id == article.id)) {
      final next = [...current, article];
      state = AsyncData(next);
      _storage.saveWishlist(next);
    }
  }

  void removeArticle(String id) {
    final next =
        (state.value ?? []).where((a) => a.id != id).toList();
    state = AsyncData(next);
    _storage.saveWishlist(next);
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
