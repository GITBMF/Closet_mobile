import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const _accessTokenKey = 'closet_access_token_v1';
  static const _refreshTokenKey = 'closet_refresh_token_v1';
  static const _tokenTypeKey = 'closet_token_type_v1';
  static const _expiresInKey = 'closet_expires_in_v1';
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
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenTypeKey, tokenType);
    await prefs.setInt(_expiresInKey, expiresIn);
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
    await prefs.remove(_userJsonKey);
  }
}
