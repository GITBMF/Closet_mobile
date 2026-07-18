import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

class CartNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() => [];

  void addArticle(Article article) {
    if (!state.any((a) => a.id == article.id)) {
      state = [...state, article];
    }
  }

  void removeArticle(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  bool isInCart(String id) => state.any((a) => a.id == id);

  double get total => state.fold(0, (sum, a) => sum + a.price);
}

final cartProvider = NotifierProvider<CartNotifier, List<Article>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).total;
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).length;
});
