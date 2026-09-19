import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/l10n/closet_l10n.dart';
import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../bff_client/api_client.dart';
import '../models/user.dart';
import '../services/auth_storage_service.dart';

/// Levée par [AuthRepository.signUp] quand le compte vient d'être créé mais
/// que le backend refuse la connexion tant que l'e-mail n'est pas vérifié
/// (code `email_not_verified`). Porte les identifiants pour que l'écran de
/// vérification puisse se reconnecter une fois le code validé, sans
/// redemander le mot de passe.
class EmailNonVerifieException implements Exception {
  const EmailNonVerifieException({
    required this.email,
    required this.password,
    required this.message,
  });

  final String email;
  final String password;
  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._ref, this._client);

  final Ref _ref;
  final BffClient _client;

  /// Restaure la session persistée jusqu'à déconnexion volontaire.
  ///
  /// Un jeton d'accès expiré est renouvelé. Une panne réseau ne déconnecte
  /// pas : on reprend le profil déjà enregistré sur l'appareil.
  Future<ClosetUser?> restaurerSession() async {
    await _client.restaurerJeton();
    if (!await AuthStorageService.aUneSession()) return null;

    final cache = await _utilisateurPersiste();
    if (cache != null) {
      _ref.read(currentUserProvider.notifier).state = cache;
    }

    if (await AuthStorageService.accessTokenARafraichir()) {
      await _client.rafraichirJeton();
      if (!await AuthStorageService.aUneSession()) {
        _ref.read(currentUserProvider.notifier).state = null;
        return null;
      }
    }

    try {
      final data = await _client.getJson('/me');
      final user = ClosetUser.fromJson(data);
      await AuthStorageService.saveUser(user.toJson());
      _ref.read(currentUserProvider.notifier).state = user;
      return user;
    } on ApiException catch (e) {
      if (e.kind == KindErreurApi.nonAutorise) {
        final ok = await _client.rafraichirJeton();
        if (ok) {
          try {
            final data = await _client.getJson('/me');
            final user = ClosetUser.fromJson(data);
            await AuthStorageService.saveUser(user.toJson());
            _ref.read(currentUserProvider.notifier).state = user;
            return user;
          } on ApiException {
            // Le refresh a réussi mais /me échoue encore : on garde le cache.
          }
        }
        if (!await AuthStorageService.aUneSession()) {
          await deconnecter(tousLesAppareils: false);
          return null;
        }
      }
      return cache;
    }
  }

  Future<ClosetUser?> _utilisateurPersiste() async {
    final json = await AuthStorageService.getUserJson();
    if (json == null) return null;
    try {
      return ClosetUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<ClosetUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String city = '',
    ClosetL10n? l10n,
  }) async {
    _client.clearAccessToken();

    final payload = payloadInscriptionCliente(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
    );
    await _client.postJson('/auth/register', data: payload);

    final emailInscrit = payload['email'] as String;
    // L'inscription ne renvoie pas de jeton : on ouvre la session tout de
    // suite avec les identifiants venant d'être créés. Le backend refuse
    // toutefois la connexion tant que l'e-mail n'est pas vérifié : l'appelant
    // doit alors faire vérifier le code avant de retenter `logIn`.
    try {
      return await logIn(email: emailInscrit, password: password, l10n: l10n);
    } on ApiException catch (e) {
      if (e.code == 'email_not_verified') {
        throw EmailNonVerifieException(
          email: emailInscrit,
          password: password,
          message: e.message,
        );
      }
      rethrow;
    }
  }

  /// `POST /auth/verify-email` — code à 6 chiffres reçu par e-mail.
  Future<String> verifierEmail({
    required String email,
    required String code,
  }) async {
    final data = await _client.postJson('/auth/verify-email', data: {
      'email': email.trim().toLowerCase(),
      'code': code.trim(),
    });
    return messageDepuisCorps(data);
  }

  /// `POST /auth/verify-email/resend` — renvoie un nouveau code.
  Future<String> renvoyerCodeVerification(String email) async {
    final data = await _client.postJson('/auth/verify-email/resend', data: {
      'email': email.trim().toLowerCase(),
    });
    return messageDepuisCorps(data);
  }

  Future<ClosetUser> logIn({
    required String email,
    required String password,
    ClosetL10n? l10n,
  }) async {
    _client.clearAccessToken();
    final data = await _client.postJson('/auth/login', data: {
      'email': email.toLowerCase().trim(),
      'password': password,
    });

    if (booleenDe(data['mfa_required'])) {
      throw ApiException(
        message: messageMelange(
          local: l10n?.mfaNonDisponibleMessage ?? ClosetL10n.fr.mfaNonDisponibleMessage,
          backend: messageDepuisCorps(data),
        ),
        kind: KindErreurApi.validation,
      );
    }

    return _ouvrirSession(data, l10n);
  }

  Future<ClosetUser> _ouvrirSession(
    Map<String, dynamic> data, [
    ClosetL10n? l10n,
  ]) async {
    final accessToken = chaineDe(data['access_token']);
    final refreshToken = chaineDe(data['refresh_token']);
    final tokenType = chaineDe(data['token_type'], 'bearer');
    final expiresIn = entierDe(data['expires_in']);
    final userJson = objetDe(data['user']);
    final user = ClosetUser.fromJson(userJson);

    if (accessToken.isEmpty) {
      throw ApiException(
        message: messageMelange(
          local: l10n?.serveurPasDeJetonMessage ?? ClosetL10n.fr.serveurPasDeJetonMessage,
          backend: messageDepuisCorps(data),
        ),
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

  Future<String> demanderReinitialisation(String email) async {
    final data = await _client.postJson('/auth/forgot-password', data: {
      'email': email.trim().toLowerCase(),
    });
    return messageDepuisCorps(data);
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
  final repo = AuthRepository(ref, client);
  client.onSessionInvalide = () {
    ref.read(currentUserProvider.notifier).state = null;
  };
  return repo;
});

final currentUserProvider = StateProvider<ClosetUser?>((ref) => null);

/// Corps de `POST /auth/register` — miroir de `RegisterRequest` (OpenAPI).
///
/// Champs requis : `email`, `password`, `full_name`. `phone` et `city` ne
/// partent que s'ils sont renseignés (le schéma les accepte nuls).
@visibleForTesting
Map<String, dynamic> payloadInscriptionCliente({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  String phone = '',
  String city = '',
}) {
  final payload = <String, dynamic>{
    'email': email.toLowerCase().trim(),
    'password': password,
    'full_name': '$firstName $lastName'.replaceAll(RegExp(r'\s+'), ' ').trim(),
  };
  final tel = telephoneInscription(phone);
  if (tel != null) payload['phone'] = tel;
  final ville = city.trim();
  if (ville.isNotEmpty) {
    payload['city'] = ville.length > 100 ? ville.substring(0, 100) : ville;
  }
  return payload;
}

/// Téléphone compact (E.164 léger), 32 caractères max comme le backend.
@visibleForTesting
String? telephoneInscription(String brut) {
  final compact = brut.replaceAll(RegExp(r'[\s.\-]'), '');
  if (compact.isEmpty) return null;
  return compact.length > 32 ? compact.substring(0, 32) : compact;
}
