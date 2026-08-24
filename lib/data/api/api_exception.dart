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

/// Échec d'un appel HTTP. Le [message] est le texte renvoyé par le backend
/// (`detail` ou `message`), jamais une phrase inventée côté client.
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
    final kind = _kind(e, status);
    return ApiException(
      message: messageMelange(
        local: _repli(kind),
        backend: messageDepuisCorps(e.response?.data),
      ),
      kind: kind,
      status: status,
    );
  }

  static String _repli(KindErreurApi kind) => switch (kind) {
        KindErreurApi.horsLigne =>
          'Vous semblez hors connexion. Vérifiez votre réseau.',
        KindErreurApi.delaiDepasse =>
          'Le serveur met trop de temps à répondre. Réessayez.',
        KindErreurApi.nonAutorise =>
          'Session expirée. Veuillez vous reconnecter.',
        KindErreurApi.introuvable => 'Ressource introuvable.',
        KindErreurApi.validation => 'Certaines informations sont invalides.',
        KindErreurApi.serveur => 'Le service est momentanément indisponible.',
        KindErreurApi.autre => 'Une erreur est survenue. Veuillez réessayer.',
      };

  static KindErreurApi _kind(DioException e, int? status) {
    if (_estHorsLigne(e)) return KindErreurApi.horsLigne;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return KindErreurApi.delaiDepasse;
    }
    if (status == 401 || status == 403) return KindErreurApi.nonAutorise;
    if (status == 404) return KindErreurApi.introuvable;
    if (status == 409 || status == 422) return KindErreurApi.validation;
    if (status != null && status >= 500) return KindErreurApi.serveur;
    return KindErreurApi.autre;
  }

  static bool _estHorsLigne(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown &&
            (e.message?.contains('SocketException') ?? false);
  }

  @override
  String toString() => message;
}

/// Texte utile d'un corps JSON d'API : `detail` (chaîne ou liste FastAPI)
/// ou `message`. Chaîne vide si le serveur n'a rien envoyé.
String messageDepuisCorps(dynamic data) {
  if (data is String && data.trim().isNotEmpty) return data.trim();
  if (data is! Map) return '';

  final detail = data['detail'];
  if (detail is String && detail.trim().isNotEmpty) return detail.trim();
  if (detail is List && detail.isNotEmpty) {
    final messages = <String>[];
    for (final item in detail) {
      if (item is Map) {
        final msg = item['msg'];
        if (msg is String && msg.trim().isNotEmpty) {
          messages.add(msg.trim());
        }
      } else if (item != null && item.toString().trim().isNotEmpty) {
        messages.add(item.toString().trim());
      }
    }
    if (messages.isNotEmpty) return messages.join('\n');
  }

  final message = data['message'];
  if (message is String && message.trim().isNotEmpty) return message.trim();
  return '';
}

/// Titre local + détail serveur : on affiche le backend s’il est là.
String messageMelange({required String local, String? backend}) {
  final distant = (backend ?? '').trim();
  return distant.isEmpty ? local : distant;
}

/// Extraire le message affichable depuis une erreur levée.
String messageErreur(Object erreur) {
  if (erreur is ApiException) return erreur.message.trim();
  if (erreur is String) return erreur.trim();
  return erreur.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
}

bool estHorsLigne(Object erreur) =>
    erreur is ApiException && erreur.estHorsLigne;
