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
          if (erreur.response?.statusCode == 401 && !_rafraichissementEnCours) {
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
  bool _rafraichissementEnCours = false;

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
    final data = await _executer(() => _dio.get<dynamic>(chemin, queryParameters: query));
    if (data is List) return data;
    return const [];
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

  Future<void> delete(String chemin) async {
    await _executer(() => _dio.delete<dynamic>(chemin));
  }

  Future<dynamic> _executer(Future<Response<dynamic>> Function() appel) async {
    try {
      final reponse = await appel();
      return reponse.data;
    } on DioException catch (e) {
      throw ApiException.depuisDio(e);
    }
  }

  Future<Response<dynamic>?> _tenterRafraichissement(
    RequestOptions requete,
  ) async {
    final refresh = await AuthStorageService.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    _rafraichissementEnCours = true;
    try {
      final reponse = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = reponse.data ?? <String, dynamic>{};
      final access = chaineDe(data['access_token']);
      if (access.isEmpty) return null;

      await AuthStorageService.saveAuthTokens(
        accessToken: access,
        refreshToken: chaineDe(data['refresh_token'], refresh),
        tokenType: chaineDe(data['token_type'], 'bearer'),
        expiresIn: entierDe(data['expires_in']),
      );
      setAccessToken(access);

      requete.headers['Authorization'] = 'Bearer $access';
      return await _dio.fetch<dynamic>(requete);
    } catch (_) {
      await AuthStorageService.clearAuthData();
      clearAccessToken();
      return null;
    } finally {
      _rafraichissementEnCours = false;
    }
  }
}
