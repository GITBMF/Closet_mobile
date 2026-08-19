import 'package:dio/dio.dart';

/// Nature d'un échec réseau, pour que l'UI choisisse le bon écran.
enum KindErreurApi {
  horsLigne,
  delaiDepasse,
  nonAutorise,
  introuvable,
  validation,
  serveur,
  autre,
}

/// Échec d'un appel HTTP, déjà traduit pour l'interface.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.kind,
    this.status,
  });

  final String message;
  final KindErreurApi kind;
  final int? status;

  bool get estHorsLigne =>
      kind == KindErreurApi.horsLigne || kind == KindErreurApi.delaiDepasse;

  factory ApiException.depuisDio(DioException e) {
    final status = e.response?.statusCode;
    if (_estHorsLigne(e)) {
      return const ApiException(
        message: 'Vous semblez hors connexion. Vérifiez votre réseau.',
        kind: KindErreurApi.horsLigne,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiException(
        message: 'Le serveur met trop de temps à répondre. Réessayez.',
        kind: KindErreurApi.delaiDepasse,
      );
    }

    final detail = _detail(e.response?.data);
    if (status == 401 || status == 403) {
      return ApiException(
        message: detail ?? 'Session expirée. Veuillez vous reconnecter.',
        kind: KindErreurApi.nonAutorise,
        status: status,
      );
    }
    if (status == 404) {
      return ApiException(
        message: detail ?? 'Ressource introuvable.',
        kind: KindErreurApi.introuvable,
        status: status,
      );
    }
    if (status == 409 || status == 422) {
      return ApiException(
        message: detail ?? 'Certaines informations sont invalides.',
        kind: KindErreurApi.validation,
        status: status,
      );
    }
    if (status != null && status >= 500) {
      return ApiException(
        message: detail ?? 'Le service est momentanément indisponible.',
        kind: KindErreurApi.serveur,
        status: status,
      );
    }
    return ApiException(
      message: detail ?? 'Une erreur est survenue. Veuillez réessayer.',
      kind: KindErreurApi.autre,
      status: status,
    );
  }

  static bool _estHorsLigne(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown &&
            (e.message?.contains('SocketException') ?? false);
  }

  static String? _detail(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        final premier = detail.first;
        if (premier is Map && premier['msg'] is String) {
          return premier['msg'] as String;
        }
        return detail.first.toString();
      }
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return null;
  }

  @override
  String toString() => message;
}

/// Extraire un message lisible depuis n'importe quelle erreur levée.
String messageErreur(Object erreur) {
  if (erreur is ApiException) return erreur.message;
  final brut = erreur.toString();
  return brut.replaceFirst(RegExp(r'^Exception:\s*'), '');
}

bool estHorsLigne(Object erreur) =>
    erreur is ApiException && erreur.estHorsLigne;
