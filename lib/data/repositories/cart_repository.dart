import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import '../services/local_storage_service.dart';

// ── Local storage provider (async initialisation) ────────────────────────────

final localStorageProvider = FutureProvider<LocalStorageService>((ref) async {
  return LocalStorageService.create();
});

// ── Cart ─────────────────────────────────────────────────────────────────────

class CartNotifier extends AsyncNotifier<List<Article>> {
  late LocalStorageService _storage;

  @override
  Future<List<Article>> build() async {
    _storage = await ref.watch(localStorageProvider.future);
    return _storage.loadCart();
  }

  void addArticle(Article article) {
    final current = state.value ?? [];
    if (!current.any((a) => a.id == article.id)) {
      final next = [...current, article];
      state = AsyncData(next);
      _storage.saveCart(next);
    }
  }

  void removeArticle(String id) {
    final next = (state.value ?? []).where((a) => a.id != id).toList();
    state = AsyncData(next);
    _storage.saveCart(next);
  }

  void clear() {
    state = const AsyncData([]);
    _storage.saveCart([]);
  }

  bool isInCart(String id) =>
      (state.value ?? []).any((a) => a.id == id);

  double get total =>
      (state.value ?? []).fold(0, (s, a) => s + a.price);
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<Article>>(
  CartNotifier.new,
);

/// Synchronous convenience list — falls back to [] while async loads.
final cartListProvider = Provider<List<Article>>((ref) {
  return ref.watch(cartProvider).value ?? [];
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartListProvider).fold(0, (s, a) => s + a.price);
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartListProvider).length;
});
