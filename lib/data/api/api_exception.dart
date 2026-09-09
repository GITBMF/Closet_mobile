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

/// Échec d'un appel HTTP.
///
/// [message] est un texte affichable : le détail backend s'il est humain,
/// sinon un repli français. Le jargon technique (« Internal Server Error »)
/// n'est jamais exposé.
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
        local: repliPour(kind),
        backend: messageDepuisCorps(e.response?.data),
      ),
      kind: kind,
      status: status,
    );
  }

  static String repliPour(KindErreurApi kind) => switch (kind) {
        KindErreurApi.horsLigne =>
          'Vous semblez hors connexion. Vérifiez votre réseau.',
        KindErreurApi.delaiDepasse =>
          'Le serveur met trop de temps à répondre. Réessayez.',
        KindErreurApi.nonAutorise =>
          'Session expirée. Veuillez vous reconnecter.',
        KindErreurApi.introuvable => 'Ressource introuvable.',
        KindErreurApi.validation => 'Certaines informations sont invalides.',
        KindErreurApi.serveur =>
          'Le service est momentanément indisponible. Réessayez dans un instant.',
        KindErreurApi.autre => 'Une erreur est survenue. Veuillez réessayer.',
      };

  static bool estRepli(String texte) =>
      KindErreurApi.values.any((k) => texte.trim() == repliPour(k));

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

  final error = data['error'];
  if (error is Map) {
    final depuisErreur = _texteDepuisObjetErreur(error);
    if (depuisErreur.isNotEmpty) return depuisErreur;
  }

  final depuisRacine = _texteDepuisObjetErreur(data);
  if (depuisRacine.isNotEmpty) return depuisRacine;

  return '';
}

String _texteDepuisObjetErreur(Map<dynamic, dynamic> objet) {
  final detail = objet['detail'];
  if (detail is String && detail.trim().isNotEmpty) return detail.trim();
  if (detail is List && detail.isNotEmpty) {
    final messages = <String>[];
    for (final item in detail) {
      if (item is Map) {
        final msg = item['msg'] ?? item['message'];
        if (msg is String && msg.trim().isNotEmpty) {
          messages.add(msg.trim());
        }
      } else if (item != null && item.toString().trim().isNotEmpty) {
        messages.add(item.toString().trim());
      }
    }
    if (messages.isNotEmpty) return messages.join('\n');
  }

  final message = objet['message'];
  if (message is String && message.trim().isNotEmpty) {
    final details = objet['details'];
    if (details is Map) {
      final fields = details['fields'];
      if (fields is List && fields.isNotEmpty) {
        final extras = [
          for (final f in fields)
            if (f is Map && f['message'] is String && (f['message'] as String).trim().isNotEmpty)
              (f['message'] as String).trim(),
        ];
        if (extras.isNotEmpty) return '${message.trim()}\n${extras.join('\n')}';
      }
    }
    return message.trim();
  }
  return '';
}

/// Phrases HTTP / traces / HTML : jamais à montrer telles quelles.
bool estMessageTechnique(String texte) {
  final t = texte.trim().toLowerCase();
  if (t.isEmpty) return true;
  const jargon = [
    'internal server error',
    'internal error',
    'server error',
    'not found',
    'bad gateway',
    'service unavailable',
    'gateway timeout',
    'bad request',
    'unauthorized',
    'forbidden',
    'method not allowed',
    'unprocessable entity',
    'too many requests',
    'traceback',
    'stack trace',
    'sqlalchemy',
    'psycopg',
    'nullpointer',
    '<html',
    '<!doctype',
    'dioexception',
    'socketexception',
    'httpexception',
  ];
  if (jargon.any(t.contains)) return true;
  if (RegExp(r'^\d{3}(\s|$)').hasMatch(t)) return true;
  if (t.contains('exception') && (t.contains('/') || t.contains(' at '))) {
    return true;
  }
  return false;
}

/// Titre local + détail serveur, si le backend est lisible.
String messageMelange({required String local, String? backend}) {
  final distant = (backend ?? '').trim();
  if (distant.isEmpty || estMessageTechnique(distant)) return local;
  return distant;
}

/// Extraire le message affichable depuis une erreur levée.
String messageErreur(Object erreur) {
  if (erreur is ApiException) {
    final texte = erreur.message.trim();
    if (texte.isEmpty || estMessageTechnique(texte)) return '';
    return texte;
  }
  if (erreur is DioException) {
    return ApiException.depuisDio(erreur).message;
  }
  if (erreur is String) {
    final texte = erreur.trim();
    if (texte.isEmpty || estMessageTechnique(texte)) return '';
    return texte;
  }
  final texte =
      erreur.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  if (texte.isEmpty || estMessageTechnique(texte)) return '';
  return texte;
}

bool estHorsLigne(Object erreur) =>
    erreur is ApiException && erreur.estHorsLigne;
