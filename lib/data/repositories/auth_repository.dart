import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../bff_client/api_client.dart';
import '../models/user.dart';
import '../services/auth_storage_service.dart';

class AuthRepository {
  final Ref _ref;
  final BffClient _client;

  /// Remettre à `true` quand `/auth/login` et `/auth/register` seront stables.
  static const bool useBackendAuth = false;

  // Local embedded native database of users for the MVP
  static final List<ClosetUser> _localDb = [
    ClosetUser(firstName: 'Aïcha', lastName: 'N', email: 'user@closet.com'),
  ];
  static final Map<String, String> _localPasswords = {
    'user@closet.com': 'closet123',
  };

  AuthRepository(this._ref, this._client) {
    // Referencing properties to resolve compiler warnings
    _ref.toString();
    _client.toString();
  }

  Future<ClosetUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final lowerEmail = email.toLowerCase().trim();
    if (_localPasswords.containsKey(lowerEmail)) {
      throw Exception('Un utilisateur avec cet e-mail existe déjà.');
    }

    final fullName = '$firstName $lastName'.trim();
    if (fullName.isEmpty) {
      throw Exception('Le nom complet est requis.');
    }
    if (phone.trim().isEmpty) {
      throw Exception('Le numéro de téléphone est requis.');
    }

    if (!useBackendAuth) {
      final user = ClosetUser(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: lowerEmail,
      );
      _saveToLocal(user, password);
      return user;
    }

    try {
      final response = await _client.dio.post(
        '/auth/register',
        data: {
          'email': lowerEmail,
          'password': password,
          'full_name': fullName,
          'phone': phone.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = ClosetUser.fromJson(data);
      _saveToLocal(user, password);
      return user;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['detail'] != null) {
          throw Exception(errorData['detail'].toString());
        }
        throw Exception(errorData.toString());
      }
      throw Exception('Erreur lors de l\'inscription. Veuillez réessayer.');
    }
  }

  Future<ClosetUser> logIn({
    required String email,
    required String password,
  }) async {
    final lowerEmail = email.toLowerCase().trim();

    if (!useBackendAuth) {
      ClosetUser? local;
      for (final u in _localDb) {
        if (u.email.toLowerCase() == lowerEmail) local = u;
      }
      var user = local ??
          ClosetUser(
            firstName: 'Aïcha',
            lastName: 'N',
            email: lowerEmail.isEmpty ? 'user@closet.com' : lowerEmail,
          );
      final saved = await AuthStorageService.getUserJson();
      final savedEmail = (saved?['email'] as String?)?.toLowerCase();
      final savedAvatar = saved?['avatar_path'] as String?;
      if (savedAvatar != null && savedEmail == user.email.toLowerCase()) {
        user = user.copyWith(avatarPath: savedAvatar);
      }
      _saveToLocal(user, password);
      await AuthStorageService.saveUser(user.toJson());
      return user;
    }

    try {
      final response = await _client.dio.post(
        '/auth/login',
        data: {
          'email': lowerEmail,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = (data['access_token'] ?? '') as String;
      final refreshToken = (data['refresh_token'] ?? '') as String;
      final tokenType = (data['token_type'] ?? 'bearer') as String;
      final expiresIn = data['expires_in'] is int ? data['expires_in'] as int : int.tryParse('${data['expires_in']}') ?? 0;
      final userJson = (data['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final user = ClosetUser.fromJson(userJson);

      if (accessToken.isEmpty) {
        throw Exception('Le backend n\'a pas renvoyé de jeton d\'accès.');
      }

      await AuthStorageService.saveAuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
      );
      await AuthStorageService.saveUser(userJson);
      _client.setAccessToken(accessToken);

      return user;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData['detail'] != null) {
          throw Exception(errorData['detail'].toString());
        }
        throw Exception(errorData.toString());
      }
      throw Exception('Erreur lors de la connexion. Veuillez réessayer.');
    }
  }

  void _saveToLocal(ClosetUser user, String password) {
    final lowerEmail = user.email.toLowerCase().trim();
    if (!_localDb.any((u) => u.email.toLowerCase() == lowerEmail)) {
      _localDb.add(user);
      _localPasswords[lowerEmail] = password;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(bffClientProvider);
  return AuthRepository(ref, client);
});

final currentUserProvider = StateProvider<ClosetUser?>((ref) => null);
