import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bffClientProvider = Provider<BffClient>((ref) {
  return BffClient();
});

class BffClient {
  late final Dio _dio;

  BffClient() {
    const baseUrl = 'https://closet-backend-be8g.onrender.com/api/v1';
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Ajout d'intercepteurs pour gérer les logs et l'authentification (si besoin)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Gestion centralisée des erreurs API
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setAccessToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAccessToken() {
    _dio.options.headers.remove('Authorization');
  }
}
