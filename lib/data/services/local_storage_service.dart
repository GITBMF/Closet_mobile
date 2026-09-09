import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

/// Service de persistance locale — wrapper shared_preferences.
/// Utilisé exclusivement par [CartNotifier] et [WishlistNotifier].
class LocalStorageService {
  static const _cartKey = 'closet_cart_v1';
  static const _wishlistKey = 'closet_wishlist_v1';

  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  // ── Cart ─────────────────────────────────────────────────────────────────

  List<Article> loadCart() {
    final raw = _prefs.getString(_cartKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<Article> items) async {
    final encoded = jsonEncode(items.map((a) => a.toJson()).toList());
    await _prefs.setString(_cartKey, encoded);
  }

  // ── Wishlist ──────────────────────────────────────────────────────────────

  List<Article> loadWishlist() {
    final raw = _prefs.getString(_wishlistKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWishlist(List<Article> items) async {
    final encoded = jsonEncode(items.map((a) => a.toJson()).toList());
    await _prefs.setString(_wishlistKey, encoded);
  }
}
