import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_exception.dart';
import '../api/api_json.dart';
import '../services/auth_storage_service.dart';

final bffClientProvider = Provider<BffClient>((ref) => BffClient());

/// Client HTTP unique de l'application.
///
/// Tous les dépôts passent par ici : jeton, rafraîchissement, et traduction
/// des erreurs Dio en [ApiException].
class BffClient {
  BffClient({Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: 'https://closet-backend-be8g.onrender.com/api/v1',
            connectTimeout: const Duration(seconds: 45),
            receiveTimeout: const Duration(seconds: 45),
            sendTimeout: const Duration(seconds: 45),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (erreur, handler) async {
          if (_doitTenterRafraichissement(erreur)) {
            final rejoue = await _tenterRafraichissement(erreur.requestOptions);
            if (rejoue != null) {
              return handler.resolve(rejoue);
            }
          }
          return handler.next(erreur);
        },
      ),
    );
  }

  late final Dio _dio;
  Future<bool>? _promesseRafraichissement;

  /// Appelé uniquement quand le refresh token est réellement rejeté (401/403).
  void Function()? onSessionInvalide;

  Dio get dio => _dio;

  void setAccessToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAccessToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Repose le jeton persisté avant le premier appel authentifié.
  Future<void> restaurerJeton() async {
    final jeton = await AuthStorageService.getAccessToken();
    if (jeton != null && jeton.isNotEmpty) setAccessToken(jeton);
  }

  Future<Map<String, dynamic>> getJson(
    String chemin, {
    Map<String, dynamic>? query,
  }) async {
    return objetDe(await _executer(() => _dio.get<dynamic>(chemin, queryParameters: query)));
  }

  Future<List<dynamic>> getList(
    String chemin, {
    Map<String, dynamic>? query,
  }) async {
    return listeDe(
      await _executer(() => _dio.get<dynamic>(chemin, queryParameters: query)),
    );
  }

  Future<Map<String, dynamic>> postJson(
    String chemin, {
    Object? data,
  }) async {
    return objetDe(await _executer(() => _dio.post<dynamic>(chemin, data: data)));
  }

  Future<Map<String, dynamic>> patchJson(
    String chemin, {
    Object? data,
  }) async {
    return objetDe(await _executer(() => _dio.patch<dynamic>(chemin, data: data)));
  }

  /// `POST` qui répond 204 sans corps (ex. `POST /wishlist/{id}`).
  /// Si le serveur joint un `message` / `detail`, il est renvoyé tel quel.
  Future<String?> postVide(String chemin, {Object? data}) async {
    final brut = await _executer(
      () => _dio.post<dynamic>(chemin, data: data, options: _reponseVide),
    );
    final texte = messageDepuisCorps(brut);
    return texte.isEmpty ? null : texte;
  }

  Future<String?> delete(String chemin) async {
    final brut = await _executer(
      () => _dio.delete<dynamic>(chemin, options: _reponseVide),
    );
    final texte = messageDepuisCorps(brut);
    return texte.isEmpty ? null : texte;
  }

  static final _reponseVide = Options(
    responseType: ResponseType.plain,
    validateStatus: (statut) => statut != null && statut >= 200 && statut < 300,
  );

  Future<dynamic> _executer(Future<Response<dynamic>> Function() appel) async {
    try {
      final reponse = await appel();
      return reponse.data;
    } on DioException catch (e) {
      throw ApiException.depuisDio(e);
    }
  }

  bool _doitTenterRafraichissement(DioException erreur) {
    if (erreur.response?.statusCode != 401) return false;
    if (erreur.requestOptions.extra['skipAuthRefresh'] == true) return false;
    final chemin = erreur.requestOptions.path;
    if (chemin.contains('/auth/login') ||
        chemin.contains('/auth/register') ||
        chemin.contains('/auth/refresh') ||
        chemin.contains('/auth/logout')) {
      return false;
    }
    return true;
  }

  Future<Response<dynamic>?> _tenterRafraichissement(
    RequestOptions requete,
  ) async {
    final ok = await rafraichirJeton();
    if (!ok) return null;
    requete.headers['Authorization'] = _dio.options.headers['Authorization'];
    requete.extra['skipAuthRefresh'] = true;
    return _dio.fetch<dynamic>(requete);
  }

  /// Renouvelle l'accès à partir du refresh token persisté.
  ///
  /// Ne purge la session que si le serveur refuse le refresh (401/403).
  /// Un timeout réseau laisse les jetons en place.
  Future<bool> rafraichirJeton() async {
    if (_promesseRafraichissement != null) {
      return _promesseRafraichissement!;
    }
    final travail = _executerRafraichissement();
    _promesseRafraichissement = travail;
    try {
      return await travail;
    } finally {
      _promesseRafraichissement = null;
    }
  }

  Future<bool> _executerRafraichissement() async {
    final refresh = await AuthStorageService.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      // Client dédié : pas d'intercepteur, pas de Bearer expiré.
      final dioRefresh = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
          sendTimeout: _dio.options.sendTimeout,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final reponse = await dioRefresh.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
        options: Options(extra: {'skipAuthRefresh': true}),
      );
      final data = reponse.data ?? <String, dynamic>{};
      final access = chaineDe(data['access_token']);
      if (access.isEmpty) return false;

      await AuthStorageService.saveAuthTokens(
        accessToken: access,
        refreshToken: chaineDe(data['refresh_token'], refresh),
        tokenType: chaineDe(data['token_type'], 'bearer'),
        expiresIn: entierDe(data['expires_in']),
      );
      setAccessToken(access);
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await AuthStorageService.clearAuthData();
        clearAccessToken();
        onSessionInvalide?.call();
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
