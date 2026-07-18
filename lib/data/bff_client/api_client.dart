import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bffClientProvider = Provider<BffClient>((ref) {
  return BffClient();
});

class BffClient {
  late final Dio _dio;

  BffClient() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/v1';
    
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
          // TODO: Ajouter le token JWT de l'utilisateur ou du sourceur ici
          // final token = await _getToken();
          // options.headers['Authorization'] = 'Bearer $token';
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
}
