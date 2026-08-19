import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';
import '../models/user.dart';
import '../services/auth_storage_service.dart';

class AuthRepository {
  AuthRepository(this._ref, this._client);

  final Ref _ref;
  final BffClient _client;

  /// Restaure la session persistée : jeton + `GET /me`.
  Future<ClosetUser?> restaurerSession() async {
    await _client.restaurerJeton();
    final jeton = await AuthStorageService.getAccessToken();
    if (jeton == null || jeton.isEmpty) return null;
    try {
      final data = await _client.getJson('/me');
      final user = ClosetUser.fromJson(data);
      await AuthStorageService.saveUser(user.toJson());
      _ref.read(currentUserProvider.notifier).state = user;
      return user;
    } on ApiException {
      await deconnecter(tousLesAppareils: false);
      return null;
    }
  }

  Future<ClosetUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final lowerEmail = email.toLowerCase().trim();
    final fullName = '$firstName $lastName'.trim();
    if (fullName.isEmpty) {
      throw const ApiException(
        message: 'Le nom complet est requis.',
        kind: KindErreurApi.validation,
      );
    }
    if (phone.trim().isEmpty) {
      throw const ApiException(
        message: 'Le numéro de téléphone est requis.',
        kind: KindErreurApi.validation,
      );
    }

    await _client.postJson('/auth/register', data: {
      'email': lowerEmail,
      'password': password,
      'full_name': fullName,
      'phone': phone.trim(),
    });

    // L'inscription ne renvoie pas de jeton : on ouvre la session tout de
    // suite avec les identifiants venant d'être créés.
    return logIn(email: lowerEmail, password: password);
  }

  Future<ClosetUser> logIn({
    required String email,
    required String password,
  }) async {
    final data = await _client.postJson('/auth/login', data: {
      'email': email.toLowerCase().trim(),
      'password': password,
    });

    if (booleenDe(data['mfa_required'])) {
      throw const ApiException(
        message:
            'Ce compte exige une double authentification, non disponible dans '
            'l’application pour le moment.',
        kind: KindErreurApi.validation,
      );
    }

    return _ouvrirSession(data);
  }

  Future<ClosetUser> _ouvrirSession(Map<String, dynamic> data) async {
    final accessToken = chaineDe(data['access_token']);
    final refreshToken = chaineDe(data['refresh_token']);
    final tokenType = chaineDe(data['token_type'], 'bearer');
    final expiresIn = entierDe(data['expires_in']);
    final userJson = objetDe(data['user']);
    final user = ClosetUser.fromJson(userJson);

    if (accessToken.isEmpty) {
      throw const ApiException(
        message: 'Le serveur n’a pas renvoyé de jeton d’accès.',
        kind: KindErreurApi.serveur,
      );
    }

    await AuthStorageService.saveAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
    await AuthStorageService.saveUser(user.toJson());
    _client.setAccessToken(accessToken);
    _ref.read(currentUserProvider.notifier).state = user;
    return user;
  }

  Future<ClosetUser> mettreAJourProfil({
    required String nomComplet,
    required String email,
    required String phone,
    String? city,
  }) async {
    final data = await _client.patchJson('/me', data: {
      'full_name': nomComplet.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      if (city != null) 'city': city.trim(),
    });
    final maj = ClosetUser.fromJson(data);
    _ref.read(currentUserProvider.notifier).state = maj;
    await AuthStorageService.saveUser(maj.toJson());
    return maj;
  }

  Future<void> demanderReinitialisation(String email) async {
    final normalise = email.trim().toLowerCase();
    if (normalise.isEmpty || !normalise.contains('@')) {
      throw const ApiException(
        message: 'Renseignez une adresse e-mail valide.',
        kind: KindErreurApi.validation,
      );
    }
    await _client.postJson('/auth/forgot-password', data: {
      'email': normalise,
    });
  }

  Future<void> deconnecter({bool tousLesAppareils = false}) async {
    final refresh = await AuthStorageService.getRefreshToken();
    try {
      await _client.postJson('/auth/logout', data: {
        'refresh_token': refresh,
        'all_devices': tousLesAppareils,
      });
    } on ApiException {
      // On purge localement même si le serveur ne répond plus.
    }
    await AuthStorageService.clearAuthData();
    _client.clearAccessToken();
    _ref.read(currentUserProvider.notifier).state = null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(bffClientProvider);
  return AuthRepository(ref, client);
});

final currentUserProvider = StateProvider<ClosetUser?>((ref) => null);
