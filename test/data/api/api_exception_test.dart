import 'package:closet/data/api/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le fichier existait vide et faisait échouer `flutter test` (donc la CI).
/// On y couvre ce qui compte vraiment : la traduction d'un échec Dio en
/// [KindErreurApi], dont dépend l'écran affiché à l'utilisateur.

DioException _statut(int code) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: code,
    ),
  );
}

DioException _type(DioExceptionType type) => DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: type,
    );

void main() {
  group('estHorsLigne', () {
    test('vrai pour une coupure réseau et un délai dépassé', () {
      for (final kind in [KindErreurApi.horsLigne, KindErreurApi.delaiDepasse]) {
        expect(
          ApiException(message: 'x', kind: kind).estHorsLigne,
          isTrue,
          reason: '$kind doit compter comme hors ligne',
        );
      }
    });

    test('faux pour les erreurs qui viennent bien du serveur', () {
      for (final kind in [
        KindErreurApi.nonAutorise,
        KindErreurApi.introuvable,
        KindErreurApi.validation,
        KindErreurApi.serveur,
        KindErreurApi.autre,
      ]) {
        expect(ApiException(message: 'x', kind: kind).estHorsLigne, isFalse);
      }
    });
  });

  group('depuisDio — code HTTP vers nature d’erreur', () {
    const attendus = {
      401: KindErreurApi.nonAutorise,
      403: KindErreurApi.nonAutorise,
      404: KindErreurApi.introuvable,
      409: KindErreurApi.validation,
      422: KindErreurApi.validation,
      500: KindErreurApi.serveur,
      503: KindErreurApi.serveur,
      418: KindErreurApi.autre,
    };

    attendus.forEach((code, kind) {
      test('$code → $kind', () {
        final erreur = ApiException.depuisDio(_statut(code));
        expect(erreur.kind, kind);
        expect(erreur.status, code, reason: 'le code doit être conservé');
      });
    });
  });

  group('depuisDio — échecs de transport', () {
    test('une connexion impossible est un hors-ligne', () {
      expect(
        ApiException.depuisDio(_type(DioExceptionType.connectionError)).kind,
        KindErreurApi.horsLigne,
      );
    });

    test('les trois délais sont des délais dépassés', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          ApiException.depuisDio(_type(type)).kind,
          KindErreurApi.delaiDepasse,
          reason: '$type doit être un délai dépassé',
        );
      }
    });

    test('sans réponse ni type connu, le status reste nul', () {
      expect(ApiException.depuisDio(_type(DioExceptionType.cancel)).status,
          isNull);
    });
  });

  group('messages de repli', () {
    test('chaque nature a un repli non vide et distinct', () {
      final replis = KindErreurApi.values.map(ApiException.repliPour).toList();
      expect(replis.every((m) => m.trim().isNotEmpty), isTrue);
      expect(replis.toSet().length, replis.length,
          reason: 'deux natures ne doivent pas partager le même message');
    });

    test('estRepli reconnaît les siens et rejette un texte du backend', () {
      for (final kind in KindErreurApi.values) {
        expect(ApiException.estRepli(ApiException.repliPour(kind)), isTrue);
      }
      expect(ApiException.estRepli('Solde insuffisant'), isFalse);
    });

    test('aucun repli ne laisse filtrer de jargon technique', () {
      for (final kind in KindErreurApi.values) {
        final m = ApiException.repliPour(kind).toLowerCase();
        expect(m.contains('internal server error'), isFalse);
        expect(m.contains('exception'), isFalse);
        expect(m.contains('null'), isFalse);
      }
    });
  });
}
