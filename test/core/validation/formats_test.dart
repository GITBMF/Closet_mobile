import 'package:closet/core/validation/formats.dart';
import 'package:closet/core/validation/indicateurs_pays.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validerEmail', () {
    test('accepte une adresse classique', () {
      expect(validerEmail('Aicha.N@closet.cm'), isNull);
    });

    test('refuse un domaine sans TLD', () {
      expect(validerEmail('aicha@closet'), isNotNull);
    });

    test('refuse les espaces', () {
      expect(validerEmail('aicha n@closet.cm'), isNotNull);
    });

    test('peut rester vide si facultatif', () {
      expect(validerEmail('', obligatoire: false), isNull);
    });
  });

  group('validerMotDePasse', () {
    test('accepte un mot de passe d’inscription valide', () {
      expect(validerMotDePasse('Secret12'), isNull);
    });

    test('exige une lettre et un chiffre à l’inscription', () {
      expect(validerMotDePasse('abcdefgh'), isNotNull);
      expect(validerMotDePasse('12345678'), isNotNull);
    });

    test('refuse les espaces', () {
      expect(validerMotDePasse('Secret 12'), isNotNull);
    });

    test('à la connexion, n’exige que la présence', () {
      expect(validerMotDePasse('x', connexion: true), isNull);
      expect(validerMotDePasse('', connexion: true), isNotNull);
    });
  });

  group('IndicateurPays.analyser', () {
    test('reconnaît un numéro camerounais collé', () {
      final parse = IndicateurPays.analyser('+237 6 99 88 77 66');
      expect(parse, isNotNull);
      expect(parse!.pays.iso, 'CM');
      expect(parse.national, '699887766');
    });

    test('reconnaît le préfixe 00', () {
      final parse = IndicateurPays.analyser('00237699887766');
      expect(parse?.pays.iso, 'CM');
      expect(parse?.national, '699887766');
    });

    test('valide un E.164 camerounais', () {
      expect(validerTelephone('+237699887766', obligatoire: true), isNull);
    });

    test('refuse un numéro incomplet', () {
      expect(validerTelephone('+237699', obligatoire: true), isNotNull);
    });
  });

  group('validerIdentifiantConnexion', () {
    test('accepte un e-mail', () {
      expect(validerIdentifiantConnexion('aicha@closet.cm'), isNull);
    });

    test('oriente vers l’e-mail si l’on saisit un téléphone', () {
      expect(
        validerIdentifiantConnexion('+237699887766'),
        contains('e-mail'),
      );
    });
  });
}
