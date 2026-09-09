import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const _accessTokenKey = 'closet_access_token_v1';
  static const _refreshTokenKey = 'closet_refresh_token_v1';
  static const _tokenTypeKey = 'closet_token_type_v1';
  static const _expiresInKey = 'closet_expires_in_v1';
  static const _expiresAtKey = 'closet_expires_at_v1';
  static const _userJsonKey = 'closet_user_json_v1';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    await prefs.setString(_tokenTypeKey, tokenType);
    await prefs.setInt(_expiresInKey, expiresIn);
    if (expiresIn > 0) {
      final expireA = DateTime.now()
          .add(Duration(seconds: expiresIn))
          .millisecondsSinceEpoch;
      await prefs.setInt(_expiresAtKey, expireA);
    }
  }

  static Future<void> saveUser(Map<String, dynamic> userJson) async {
    final prefs = await _prefs();
    await prefs.setString(_userJsonKey, jsonEncode(userJson));
  }

  static Future<String?> getAccessToken() async {
    final prefs = await _prefs();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getTokenType() async {
    final prefs = await _prefs();
    return prefs.getString(_tokenTypeKey);
  }

  static Future<int?> getExpiresIn() async {
    final prefs = await _prefs();
    return prefs.getInt(_expiresInKey);
  }

  /// Vrai s'il reste un jeton (accès ou refresh) sur l'appareil.
  static Future<bool> aUneSession() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return (access != null && access.isNotEmpty) ||
        (refresh != null && refresh.isNotEmpty);
  }

  /// Vrai si le jeton d'accès est absent, périmé, ou expire dans moins de 30 s.
  static Future<bool> accessTokenARafraichir() async {
    final access = await getAccessToken();
    if (access == null || access.isEmpty) return true;
    final prefs = await _prefs();
    final expireA = prefs.getInt(_expiresAtKey) ?? 0;
    if (expireA <= 0) return false;
    final limite = DateTime.fromMillisecondsSinceEpoch(expireA)
        .subtract(const Duration(seconds: 30));
    return DateTime.now().isAfter(limite);
  }

  static Future<Map<String, dynamic>?> getUserJson() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_userJsonKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAuthData() async {
    final prefs = await _prefs();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_expiresInKey);
    await prefs.remove(_expiresAtKey);
    await prefs.remove(_userJsonKey);
  }
}
