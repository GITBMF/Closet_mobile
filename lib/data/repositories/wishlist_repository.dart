import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';

class WishlistNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() => [];

  void toggleWishlist(Article article) {
    if (state.any((a) => a.id == article.id)) {
      state = state.where((a) => a.id != article.id).toList();
    } else {
      state = [...state, article];
    }
  }

  void addArticle(Article article) {
    if (!state.any((a) => a.id == article.id)) {
      state = [...state, article];
    }
  }

  void removeArticle(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  bool isWishlisted(String id) => state.any((a) => a.id == id);
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<Article>>(
  WishlistNotifier.new,
);
